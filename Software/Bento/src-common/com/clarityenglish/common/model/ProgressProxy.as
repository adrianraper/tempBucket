/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.common.vo.progress.Progress;
	import com.clarityenglish.common.vo.progress.Score;
	import com.clarityenglish.dms.vo.account.Account;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.formatters.DateFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.UIDUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class ProgressProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "ProgressProxy";
		
		/**
		 * A cache of progress types to loaded data sets 
		 */
		private var loadedResources:Dictionary;		
		/**
		 * Whilst data is loading we need to know so that we don't try to load it again
		 */
		private var dataLoading:Dictionary;
		
		/**
		 * sessionID is the key to the session table for this user using this course
		 */
		public var sessionID:String;
		
		/**
		 * score is an object used to hold score information
		 */
		public var score:Score;
		
		/**
		 * I need to save the href for the menu.xml as so much of progress depends on it
		 */
		// DKmenu.xml Is this OK?
		public var href:Href;
		
		/**
		 * Progress information comes from a database. Sometimes we want lots of details, and sometimes averages.
		 */
		public function ProgressProxy(data:Object = null) {
			super(NAME, data);
			
			// For caching and load once control
			loadedResources = new Dictionary();
			dataLoading = new Dictionary();
		}
		
		/**
		 * Not sure if we should be sending an object full of data (userID, groupID, rootID, productCode, country)
		 * or just the userID as that will let the backend get it all anyway, albeit with another db call.
		 * Or do we just let the backend keep everything in session variables? 
		 * I don't really like that much - it seems much safer to pass the little that we do need.
		 * 
		 * progressType:
		 * 	Progress.PROGRESS_MY_DETAILS - this is the same as the menu
		 * 	Progress.PROGRESS_MY_SUMMARY - this is calculated from MY_DETAILS
		 * 	Progress.PROGRESS_EVERYONE_SUMMARY - this is read from a calculated table
		 * 
		 * @param number userID 
		 */
		public function getProgressData(user:User, account:Account, href:Href, progressType:String):void {

			// If the data has already been loaded then just return it
			if (loadedResources[progressType]) {
				notifyDataLoaded(progressType);
				return;
			}
			
			// If the resource is already loading then do nothing
			for each (var loadingData:String in dataLoading)
				if (progressType === loadingData)
					return;

			// Some progress is read from the databse, some is calculated from other progress
			switch (progressType) {
				case Progress.PROGRESS_MY_SUMMARY:
					updateSummaryData();
					notifyDataLoaded(progressType);
					break;
					
				default:
					// Send user details and the URL of the menu to the backend
					var params:Array = [ user.userID, account.id, (account.titles[0] as Title).id, progressType, href.url ];
					new RemoteDelegate("getProgressData", params, this).execute();
					
					// Maintain a note that we are currently loading this data
					dataLoading[progressType] = true;
					
			}
				
			// And save the href
			this.href = href;
			
		}
		
		/**
		 * This sends out the notification with the requested data 
		 * @param progressType
		 * 
		 */
		private function notifyDataLoaded(progressType:String):void {
			
			if (progressType == Progress.PROGRESS_MY_DETAILS) {
				
				// If this is the menu xhtml store it in BentoProxy and send a special notification (this only happens once per title) 
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				if (!bentoProxy.menuXHTML) {
					bentoProxy.menuXHTML = new XHTML(new XML(loadedResources[progressType]), this.href);
					sendNotification(BBNotifications.MENU_XHTML_LOADED);
				}
			}

			var data:Object = {type:progressType, dataProvider:loadedResources[progressType]};
			sendNotification(BBNotifications.PROGRESS_DATA_LOADED, data);
		}
		
		/**
		 * This will calculate and update the summary information for progress.
		 * It acts directly on the stored detail XML object 
		 * 
		 */
		private function updateSummaryData():void {
			var detailXML:XML = new XML(loadedResources[Progress.PROGRESS_MY_DETAILS]);
			
			var summaryXML:XML = <progress />;
			
			// for each course in detailXML.course
			// of = number of exercises in the course node
			// count = each exercise that we have done
			// totalDone = add up all the done attributes in the exercises 
			// averageScore = add up all the scores in the score nodes and divide by number of score nodes (ignore score=-1)
			// duration = add up all the durations in the score nodes
			// averageDuration = duration divided by count
			// coverge = count exercises that have done attribute divided by of
			for each (var course:XML in detailXML..course) {
			
				var count:uint = 0;
				var of:uint = 0;
				var scoredCount:uint = 0;
				var duration:uint = 0;
				var totalScore:uint = 0;
				var totalDone:uint = 0;
				for each (var exercise:XML in course..exercise) {
					of++;
					if (Number(exercise.@done) > 0) {
						count++;
						totalDone+=Number(exercise.@done);
					}
					for each (var score:XML in exercise.score) {
						totalScore += Number(score.@score);
						scoredCount++;
						duration += Number(score.@duration);
					}
				}
				if (scoredCount>0) {
					var averageScore:uint = Math.floor(totalScore / scoredCount);
					var averageDuration:uint = Math.floor(duration / scoredCount);
				}
				var coverage:uint = Math.floor(100 * count / of);
				
				var courseNode:XML = <course id={course.@id} 
											class={course.@["class"]} 
											caption={course.@caption} 
											count={count}
											of={count}
											coverage={coverage}
											averageScore={averageScore}
											averageDuration={averageDuration}
											duration={duration}
											totalDone={totalDone} />;
				
				summaryXML[0].appendChild(courseNode);
			}
			
			loadedResources[Progress.PROGRESS_MY_SUMMARY] = summaryXML.toString();
		}
		
		/**
		 * Use the database to record that this user has started using this title 
		 * @return void
		 * 
		 */
		public function startSession(user:User, account:Account):void {
			// $userID, $rootID, $productCode, $dateNow
			var params:Array = [ user.userID, account.id, (account.titles[0] as Title).id, new Date().getTime() ];
			new RemoteDelegate("startSession", params, this).execute();			
		}
		
		/**
		 * Use the database to record that this user has stopped using this title 
		 * @return void
		 * 
		 */
		public function stopSession():void {
			
			// sessionID is the only key we need, and that is held in this model
			var params:Array = [ sessionID, new Date().getTime() ];
			new RemoteDelegate("stopSession", params, this).execute();			
		}
		/**
		 * Use the database to record that the user has done an exercise/activity
		 * @return void
		 * 
		 */
		public function writeScore(mark:ExerciseMark):void {
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;;
			
			// We have always passed dates between AS and PHP as strings
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYY-MM-DD JJ:NN:SS";
			var dateNow:String = dateFormatter.format(new Date());
			
			var params:Array = [ (loginProxy.user) ? loginProxy.user.id : null, sessionID, dateNow, mark ];
			
			new RemoteDelegate("writeScore", params, this).execute();
			
			// TODO. Decide if we want to update our local cache of my progress with each new score
			// or do you want to just get it afresh from the database. The former I suppose.
			if (loadedResources[Progress.PROGRESS_MY_DETAILS]) {
				
				// Get the cached records
				var currentRecords:XML = new XML(loadedResources[Progress.PROGRESS_MY_DETAILS]);
				
				// what is the UID of this record?
				var uid:Object = UIDUtil.UID(mark.UID);
				
				// build the new score node
				var newScoreNode:XML = <score score={mark.correctPercent} duration={mark.duration} datetime={dateNow} />;
				
				// insert into the cache
				var thisExercise:XML = currentRecords.(@id==uid.productCode).course.(@id==uid.courseID).unit.(@id==uid.unitID).exercise.(@id==uid.exerciseID)[0];
				if (thisExercise) {
					if (thisExercise.@done) {
						thisExercise.@done++;
					} else {
						thisExercise.@done = 1;
					}
					currentRecords.(@id==uid.productCode).course.(@id==uid.courseID).unit.(@id==uid.unitID).exercise.(@id==uid.exerciseID)[0].appendChild(newScoreNode);
					loadedResources[Progress.PROGRESS_MY_DETAILS] = currentRecords.toString();

					// #164. A copy of this was saved in BentoProxy.menuXHTML too (above on line 134)
					// But because of new XML() cloning (?) - you need to update that too. Seems wrong.
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					bentoProxy.menuXHTML.xml.(@id==uid.productCode).course.(@id==uid.courseID).unit.(@id==uid.unitID).exercise.(@id==uid.exerciseID)[0].appendChild(newScoreNode);
				}
				
				// #164. After changing the detail records, recalculate the summary
				updateSummaryData();
			}
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getProgressData":
					if (data) {
						// Take the data loading note out now that we have a result
						var loadingData:String = data.progress.type;
						delete dataLoading[loadingData];
						
						/*
						We will get back the following objects in data
						error - should this be called status and include info/warning/error objects?
						progress - this should be structured so that we can directly use it as a data-provider for any charts
						*/
						// First need to see if the return has an error
						if (data.error && data.error.errorNumber>0) {
							
							log.error("loadData received an error");

							// Who will handle this?
							sendNotification(CommonNotifications.PROGRESS_LOAD_ERROR, data.error);
							
						} else {

							log.info("Successfully loaded data for type {0}", loadingData);

							// Put the returned data into the cache and send out the notification
							
							// Menu.xml is a different type, we get back a full xhtml object, not just the menu level xml
							//if (href.type == Href.MENU_XHTML) {
							if (loadingData == Progress.PROGRESS_MY_DETAILS) {
								loadedResources[href] = new XHTML(new XML(data.progress.dataProvider), href);
								// For consistency with other progress data, just grab the menu bit
								var myMenu:XML = new XHTML(new XML(data.progress.dataProvider)).xml;
								loadedResources[loadingData] = myMenu.head.script.menu.toXMLString();
							} else {
								loadedResources[loadingData] = data.progress.dataProvider;
							}
							notifyDataLoaded(loadingData);
							
						}							
					} else {
						// Can't read from the database
						var error:BentoError = new BentoError(BentoError.ERROR_DATABASE_READING);
					}
					break;
				
				case "startSession":
					if (data) {
						sessionID = data.sessionID;
						sendNotification(BBNotifications.SESSION_STARTED, data);
					} else {
						// Can't write to the database
						error = new BentoError(BentoError.ERROR_DATABASE_WRITING);
					}
					break;
				
				case "stopSession":
					if (data) {
						sendNotification(BBNotifications.SESSION_STOPPED, data);
					} else {
						// Can't write to the database
						error = new BentoError(BentoError.ERROR_DATABASE_WRITING);
					}
					break;
				
				case "writeScore":
					if (data) {
						sendNotification(BBNotifications.SCORE_WRITTEN, data);
					} else {
						// Can't write to the database
						error = new BentoError(BentoError.ERROR_DATABASE_WRITING);
					}
					break;
					
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, data);
		}
		
		// Since this loads the menu xml, we need to be able to return it from cache if asked
		public function loadXHTML(href:Href):void {
			if (!href) {
				log.error("progressProxy loadXHTML received a null Href");
				return;
			}
			
			// If the resource has already been loaded then just return it
			if (loadedResources[href]) {
				log.debug("Href already loaded so returning cached copy {0}", href);
				sendNotification(BBNotifications.XHTML_LOADED, { xhtml: loadedResources[href], href: href } );
				return;
			} else {
				log.error("progressProxy loadXHTML doesn't have the menu yet");
				return;				
			}
			
		}
				
	}
}
