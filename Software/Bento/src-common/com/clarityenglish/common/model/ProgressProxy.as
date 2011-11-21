/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.common.vo.progress.Progress;
	import com.clarityenglish.common.vo.progress.Score;
	import com.clarityenglish.dms.vo.account.Account;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
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
			
			// Send user details and the URL of the menu to the backend
			var menuFile:String = href.currentDir+'/'+href.filename;
			var params:Array = [ user.userID, account.id, (account.titles[0] as Title).id, progressType, menuFile ];
			new RemoteDelegate("getProgressData", params, this).execute();
			
			// Maintain a note that we are currently loading this data
			dataLoading[progressType] = true;

		}
		
		/**
		 * This sends out the notification with the requested data 
		 * @param progressType
		 * 
		 */
		private function notifyDataLoaded(progressType:String):void {
			var data:Object = {type:progressType, dataProvider:loadedResources[progressType]};
			sendNotification(BBNotifications.PROGRESS_DATA_LOADED, data);
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
		public function writeScore(percent:int, correct:uint, wrong:uint, skipped:uint, coverage:uint):void {
			// $userID, $rootID, $productCode, $dateNow
			score = new Score();
			score.score = percent;
			score.correct = correct;
			score.wrong = wrong;
			score.skipped = skipped;
			score.coverage = coverage;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;;
			var config:Config = configProxy.getConfig();
			var account:Account = configProxy.getAccount();
			
			var params:Array = [ configProxy.getUserID(), account.id, (account.titles[0] as Title).id, new Date().getTime(), score ];
			new RemoteDelegate("writeScore", params, this).execute();			
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
							//loadedResources[loadingData] = new ArrayCollection(data.progress.dataProvider);
							loadedResources[loadingData] = data.progress.dataProvider;
							notifyDataLoaded(loadingData);
							
						}							
					} else {
						// Can't read from the database
						var error:BentoError = new BentoError(BentoError.ERROR_DATABASE_READING);
					}
					break;
				
				case "startSession":
					if (data) {
						sessionID = data.progress['sessionID'] as String;
						sendNotification(BBNotifications.SESSION_STARTED, data);
					} else {
						// Can't write to the database
						error = new BentoError(BentoError.ERROR_DATABASE_WRITING);
					}
				case "stopSession":
					if (data) {
						sendNotification(BBNotifications.SESSION_STOPPED, data);
					} else {
						// Can't write to the database
						error = new BentoError(BentoError.ERROR_DATABASE_WRITING);
					}
				case "writeScore":
					if (data) {
						sendNotification(BBNotifications.SCORE_WRITTEN, data);
					} else {
						// Can't write to the database
						error = new BentoError(BentoError.ERROR_DATABASE_WRITING);
					}
					
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, data);
		}
		

	}
}
