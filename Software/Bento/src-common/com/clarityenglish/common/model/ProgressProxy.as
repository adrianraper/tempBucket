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
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.common.vo.progress.Progress;
	import com.clarityenglish.common.vo.progress.Score;
	import com.clarityenglish.dms.vo.account.Account;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.formatters.DateFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.Fault;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.UIDUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is all rather confused - the roles of XHTMLProxy and ProgressProxy are rather mixed up.  These should be looked at carefully at some point.
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
		
		public function reset():void {
			// #472
			for each (var resource:* in loadedResources)
				if (resource is XML)
					System.disposeXML(resource);
			
			loadedResources = new Dictionary();
			dataLoading = new Dictionary();
			href = null;
		}
		
		public function hasLoadedResource(href:*):Boolean {
			return loadedResources[href];
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
			// Temporarily disable caching
			if (loadedResources[progressType]) {
				/*if (progressType == Progress.PROGRESS_MY_DETAILS) {
					// GH #95 - again, XHTMLProxy and ProgressProxy *need* to be consolidated
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					bentoProxy.menuXHTML = loadedResources[progressType];
				}*/
				notifyDataLoaded(progressType);
				return;
			}
			
			// If the resource is already loading then do nothing
			for each (var loadingData:String in dataLoading)
				if (progressType === loadingData) {
					return;
				}
					

			// Some progress is read from the databse, some is calculated from other progress
			switch (progressType) {
				case Progress.PROGRESS_MY_SUMMARY:
					updateSummaryData();
					notifyDataLoaded(progressType);
					break;
					
				default:
					// Send user details and the URL of the menu to the backend
					// #338 Add group so you can get hidden content. No, this group is top level
					// and hidden content needs my group. So just grab it from userID in the backside.
					//var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
					// #issue25 Need to know user type, so send full object
					var params:Array = [ user, account.id, (account.titles[0] as Title).id, progressType, href.url ];
					new RemoteDelegate("getProgressData", params, this).execute();
					
					// Maintain a note that we are currently loading this data
					dataLoading[progressType] = true;
			}
			
			// And save the href
			this.href = href;
		}
		
		/**
		 * This function takes menu data back from the server and saves
		 * it in the correct proxy and format.
		 * #338
		 * TODO. DK recommends that at some point we move the saving back to XHTMLProxy as that is
		 * where it really should be. Even if we actually get the data from ProgressProxy.
		 */
		private function saveMenuData(dataProvider:Object):Boolean {
			
			// If this is the menu xhtml store it in BentoProxy and send a special notification (this only happens once per title) 
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (!bentoProxy.menuXHTML) {
				
				// Whilst I get back a full <head><script> xml structure, I never want more than the <menu> node.
				// Use the XHTML class to strip the namespace from the XML
				//var data:XHTML = new XHTML(new XML(dataProvider));
				//var menuXHTML:XHTML = new XHTML(data.head.script.menu[0], this.href);
				//var menuXHTML:XHTML = new XHTML(data.head.script.(@id == "model" && @type == "application/xml").menu[0], this.href);
				var menuXHTML:XHTML = new XHTML(new XML(dataProvider), this.href);
				
				// #338
				// If courseID is defined, disable the other courses.
				// TODO. Need to update the circular animation to also respect enabledFlag.
				// TODO. Also need to do similar thing for hiddenContent, so perhaps take it out somewhere
				// This is also handled in state machine. Either I can do the menu enabling bits here
				// and the direct start there, or...
				var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
				var directStart:Object = configProxy.getDirectStart();
				
				// #338 If you get back a course, hide the others.
				// If you get back a unit, get it's course too for inverted-hiding as well as the other units.
				// Road to IELTS has a group ID within a unit for an extra level of interface grouping. Pick that up too.
				
				if (directStart) {
					if (directStart.exerciseID)
						directStart.unitID = menuXHTML..unit.(descendants("exercise").@id.contains(directStart.exerciseID))[0].@id.toString();
					
					if (directStart.unitID)
						directStart.courseID = menuXHTML..course.(descendants("unit").@id.contains(directStart.unitID))[0].@id.toString();
					
					if (directStart.courseID) {
						for each (var course:XML in menuXHTML..course) {
							if (course.@id == directStart.courseID) {
								course.@enabledFlag = 3;
								if (directStart.unitID) {
									for each (var unit:XML in course.unit) {
										if (unit.@id == directStart.unitID) {
											unit.@enabledFlag = 3;
											if (directStart.exerciseID) {
												for each (var exercise:XML in unit.exercise) {
													if (exercise.@id == directStart.exerciseID) {
														exercise.@enabledFlag = 3;
													} else {
														exercise.@enabledFlag = 8;
													}
												}
											} else if (directStart.groupID) {
												for each (exercise in unit.exercise) {
													if (exercise.@group == directStart.groupID) {
														exercise.@enabledFlag = 3;
													} else {
														exercise.@enabledFlag = 8;
													}
												}
											}
										} else {
											unit.@enabledFlag = 8;
										}
									}
								}
							} else {
								course.@enabledFlag = 8;
							}
						}
					}
				}
				
				//loadedResources[href] = menuXHTML; // GH #95
				bentoProxy.menuXHTML = menuXHTML;
				
				sendNotification(BBNotifications.MENU_XHTML_LOADED, menuXHTML);
			}
			
			return true;
		}

		/**
		 * This sends out the notification with the requested data
		 * 
		 * @param progressType
		 */
		private function notifyDataLoaded(progressType:String):void {
			// #338. Note that loadedResources[progress_my_details] is just a boolean to show that we have the data
			// already, the actual data is held in bentoProxy
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			var dataProvider:Object;
			if (progressType == Progress.PROGRESS_MY_DETAILS) {
				dataProvider = bentoProxy.menu;
				//dataProvider = loadedResources[href]; // GH #95
			} else {
				dataProvider = loadedResources[progressType];
			}
			
			sendNotification(BBNotifications.PROGRESS_DATA_LOADED, { type: progressType, dataProvider: dataProvider } );
		}
		
		/**
		 * This will calculate and update the summary information for progress.
		 * It acts directly on the stored detail XML object 
		 * 
		 */
		private function updateSummaryData():void {
			// #250. Save xml rather than a string
			//var detailXML:XML = new XML(loadedResources[Progress.PROGRESS_MY_DETAILS]);
			// #338 loadedResources holds the full XHTML for menu
			//var detailXML:XML = loadedResources[Progress.PROGRESS_MY_DETAILS];
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			//var detailXML:XHTML = bentoProxy.menuXHTML;
			var detailXML:XML = bentoProxy.menu;
			
			var summaryXML:XML = <progress />;
			
			// for each course in detailXML.course
			// of = number of exercises in the course node
			// count = how many of the exercises have we done (doesn't count multiple goes at one exercise)
			// totalDone = add up all the done attributes in the exercises 
			// scoredCount = how many exercises have we got a score for (includes duplicates)
			// durationCount = how many exercises have we got a duration for (includes duplicates)
			// averageScore = add up all the scores in the score nodes and divide by number of score nodes (ignore score=-1)
			// duration = add up all the durations in the score nodes
			// averageDuration = duration divided by count
			// coverge = count exercises that have done attribute divided by of
			for each (var course:XML in detailXML..course) {
			
				var count:uint = 0;
				var of:uint = 0;
				var scoredCount:uint = 0;
				var durationCount:uint = 0;
				var duration:uint = 0;
				var totalScore:uint = 0;
				var totalDone:uint = 0;
				var averageScore:uint = 0;
				var averageDuration:uint = 0;
				var coverage:uint = 0;
				for each (var exercise:XML in course..exercise) {
					of++;
					if (Number(exercise.@done) > 0) {
						count++;
						totalDone+=Number(exercise.@done);
					}
					for each (var score:XML in exercise.score) {
						// #232. #161. Don't let non-marked exercise scores impact the average
						if (Number(score.@score) >= 0) {
							totalScore += Number(score.@score);
							scoredCount++;
						}
						// #318. 0 duration is for offline exercises (downloading a pdf for instance)
						// so ignore it.
						if (Number(score.@duration) > 0) {
							durationCount++;
							duration += Number(score.@duration);
						}
					}
				}
				if (scoredCount>0)
					averageScore = Math.floor(totalScore / scoredCount);
				
				if (durationCount>0)
					averageDuration = Math.floor(duration / durationCount);
				
				if (of > 0)
					coverage = Math.floor(100 * count / of);
				
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
			
			// #250. Save xml rather than a string
			//loadedResources[Progress.PROGRESS_MY_SUMMARY] = summaryXML.toString();
			loadedResources[Progress.PROGRESS_MY_SUMMARY] = summaryXML;
		}
		
		/**
		 * Use the database to record that this user has started using this title 
		 * @return void
		 * 
		 */
		public function startSession(user:User, account:Account):void {
			// $userID, $rootID, $productCode, $dateNow
			// #336 SCORM needs an internal record of how long the session has been going for
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.getConfig().sessionStartTime = new Date().time;

			var params:Array = [ user, account.id, (account.titles[0] as Title).id, configProxy.getConfig().sessionStartTime ];
			new RemoteDelegate("startSession", params, this).execute();			
		}
		/**
		 * Update the database session record 
		 * @return void
		 * 
		 */
		public function updateSession():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var params:Array = [ configProxy.getConfig().sessionID ];
			new RemoteDelegate("updateSession", params, this).execute();			
		}
		
		/**
		 * Use the database to record that this user has stopped using this title 
		 * @return void
		 * 
		 */
		public function stopSession():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var params:Array = [ configProxy.getConfig().sessionID, new Date().getTime() ];
			new RemoteDelegate("stopSession", params, this).execute();			
		}
		
		/**
		 * Use the database to record that the user has done an exercise/activity
		 * @return void
		 * 
		 */
		public function writeScore(mark:ExerciseMark):void {
			log.debug("Writing the score for exercise to the database");
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			// We have always passed dates between AS and PHP as strings
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYY-MM-DD JJ:NN:SS";
			var dateNow:String = dateFormatter.format(new Date());
			
			// Just send whole user
			//var params:Array = [ (loginProxy.user) ? loginProxy.user.id : null, sessionID, dateNow, mark ];
			var params:Array = [ loginProxy.user, configProxy.getConfig().sessionID, dateNow, mark ];
			new RemoteDelegate("writeScore", params, this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void {
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			// TODO: Most of these generate errors on the client side; I need to implement this
			switch (operation) {
				case "getProgressData":
					if (data) {
						// Take the data loading note out now that we have a result
						var loadingData:String = data.progress.type;
						delete dataLoading[loadingData];
						
						log.info("Successfully loaded data for type {0}", loadingData);
						
						// Put the returned data into the cache and send out the notification
						
						// Menu.xml is a different type, we get back a full xhtml object, not just the menu level xml
						//if (href.type == Href.MENU_XHTML) {
						if (loadingData == Progress.PROGRESS_MY_DETAILS) {
							// #338 All I want is the menu bit, not the full xhtml
							//loadedResources[href] = new XHTML(new XML(data.progress.dataProvider), href);
							// For consistency with other progress data, just grab the menu bit
							//var myMenu:XML = new XHTML(new XML(data.progress.dataProvider)).xml;
							//var myMenu:XML = new XML(data.progress.dataProvider);
							// #250. Save xml rather than a string
							//loadedResources[loadingData] = myMenu.head.script.menu.toXMLString();
							//loadedResources[loadingData] = myMenu.head.script.menu[0];
							loadedResources[loadingData] = this.saveMenuData(data.progress.dataProvider);
						} else {
							// #250. Save xml rather than a string
							//loadedResources[loadingData] = data.progress.dataProvider;
							loadedResources[loadingData] = new XML(data.progress.dataProvider);
						}
						notifyDataLoaded(loadingData);						
					} else {
						// Can't read from the database
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorDatabaseReading"));
					}
					break;
				
				case "startSession":
					if (data) {
						configProxy.getConfig().sessionID = data.sessionID;
						sendNotification(BBNotifications.SESSION_STARTED, data);
					} else {
						// Can't write to the database
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorDatabaseWriting"));
					}
					break;
				
				case "stopSession":
					if (data) {
						sendNotification(BBNotifications.SESSION_STOPPED, data);
					} else {
						// Can't write to the database
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorDatabaseWriting"));
					}
					break;
				
				case "writeScore":
					// #308 
					if (data) {
						sendNotification(BBNotifications.SCORE_WRITTEN, data);
					} else {
						// Can't write to the database
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorDatabaseWriting"));
					}
					break;
					
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, fault:Fault):void {
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			switch (operation) {
				case "getProgressData":
					// Special case of progress error when the whole title is blocked by hidden content
					// in which case you don't want this user to login and take up a licence record
					var progressError:BentoError = BentoError.create(fault);
					if (progressError.errorNumber == copyProxy.getCodeForId("errorTitleBlockedByHiddenContent")) {
						// First show an error
						//sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorTitleBlockedByHiddenContent", null, true ));
						sendNotification(CommonNotifications.BENTO_ERROR, progressError);
						
						// Then notify the state machine
						sendNotification(BBNotifications.MENU_XHTML_NOT_LOADED);
						
					// gh#92
					} else if (progressError.errorNumber == copyProxy.getCodeForId("errorCourseDoesNotExist")) {
							// First show an error
							//sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorTitleBlockedByHiddenContent", null, true ));
							sendNotification(CommonNotifications.BENTO_ERROR, progressError);
							
							// Then notify the state machine
							sendNotification(BBNotifications.MENU_XHTML_NOT_LOADED);
							
					} else {
					
						sendNotification(CommonNotifications.INVALID_DATA, progressError);
						
					}
					
					// TODO: Current ProgressOps doesn't throw specific errors so this is commented for now and everything is assumed to be INVALID_DATA
					// If the error has stopped the loading of menu.xml, then can't get past login
					/*if (progressError.errorNumber == BentoError.ERROR_CONTENT_MENU) {
						sendNotification(CommonNotifications.INVALID_DATA, progressError);
					} else {
						// This might be complicated, but in this case we probably just want
						// to warn the user that their progress records can't be saved or read
						// but we could still go on with the show?
						sendNotification(BBNotifications.INVALID_PROGRESS_DATA, progressError);
					}
					break;*/
			}
			
			sendNotification(CommonNotifications.TRACE_ERROR, fault.faultString);
		}
		
		// Since this loads the menu xml, we need to be able to return it from cache if asked
		public function loadXHTML(href:Href):void {
			if (!href) {
				log.error("progressProxy loadXHTML received a null Href");
				return;
			}
			
			// If the resource has already been loaded then just return it.
			// #338 But this is not keyed on href, but on progress_type
			//if (loadedResources[href]) {
			if (loadedResources[Progress.PROGRESS_MY_DETAILS]) {
				log.debug("Href already loaded so returning cached copy {0}", href);
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				sendNotification(BBNotifications.XHTML_LOADED, { xhtml: bentoProxy.menuXHTML, href: href } );
				return;
			} else {
				log.error("progressProxy loadXHTML doesn't have the menu yet");
				return;				
			}
			
		}
				
	}
}
