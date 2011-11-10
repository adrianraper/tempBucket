/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.common.vo.progress.Progress;
	import com.clarityenglish.dms.vo.account.Account;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
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
		 * For holding results in a cache 
		 */
		private var _everyoneSummary:Array;
		private var _mySummary:Array;
		private var _myDetails:ArrayCollection;
		
		/**
		 * Progress information comes from a database. Sometimes we want lots of details, and sometimes averages.
		 */
		public function ProgressProxy(data:Object = null) {
			super(NAME, data);
		}
		
		/**
		 * Not sure if we should be sending an object full of data (userID, groupID, rootID, productCode, country)
		 * or just the userID as that will let the backend get it all anyway, albeit with another db call.
		 * Or do we just let the backend keep everything in session variables? 
		 * I don't really like that much - it seems much safer to pass the little that we do need.
		 * @param number userID 
		 */
		public function getProgressData(user:User, account:Account, href:Href, progressType:String):void {
			
			// Check cache
			if (progressType == Progress.PROGRESS_EVERYONE_SUMMARY && _everyoneSummary) {
				var data:Object = {type:progressType, dataProvider:_everyoneSummary};
				sendNotification(BBNotifications.PROGRESS_DATA_LOADED, data);
			}
			// We could keep other details in the cache as well if we are prepared to update them
			// from any new data we write.
			if (progressType == Progress.PROGRESS_MY_SUMMARY && _mySummary) {
				var data:Object = {type:progressType, dataProvider:_mySummary};
				sendNotification(BBNotifications.PROGRESS_DATA_LOADED, data);
			}
			if (progressType == Progress.PROGRESS_MY_DETAILS && _myDetails) {
				var data:Object = {type:progressType, dataProvider:_myDetails};
				sendNotification(BBNotifications.PROGRESS_DATA_LOADED, data);
			}
			
			// Send userID, rootID and productCode. Also say whether you want some or all data to come back.
			// TODO. user doesn't currently have userID set. Check up on what comes back from login.
			var menuFile:String = href.currentDir+'/'+href.filename;
			var params:Array = [ user.userID, account.id, (account.titles[0] as Title).id, progressType, menuFile ];
			new RemoteDelegate("getProgressData", params, this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getProgressData":
					if (data) {
						/*
						We will get back the following objects in data
						error - should this be called status and include info/warning/error objects?
						progress - this should be structured so that we can directly use it as a data-provider for any charts
						*/
						// First need to see if the return has an error
						if (data.error && data.error.errorNumber>0) {
							// Who will handle this?
							sendNotification(CommonNotifications.PROGRESS_LOAD_ERROR, data.error);						
						} else {
							// Fake data
							/*
							data.type = "my_summary";
							data.dataProvider = [
							{name:'Writing', value:'23'},
							{name:'Speaking', value:'39'},
							{name:'Reading', value:'68'},
							{name:'Listening', value:'65'},
							{name:'Exam tips', value:'100'}
							];
							*/
							// Save retrieved data in cache
							if (data.progress.type == Progress.PROGRESS_EVERYONE_SUMMARY) {
								_everyoneSummary = data.progress.dataProvider;
							} else if (data.progress.type == Progress.PROGRESS_MY_SUMMARY) {
								_mySummary = data.progress.dataProvider;
							} else if (data.progress.type == Progress.PROGRESS_MY_DETAILS) {
								_myDetails = data.progress.dataProvider;
							}
							sendNotification(BBNotifications.PROGRESS_DATA_LOADED, data.progress);
						}							
					} else {
						// Can't read from the database
						var error:BentoError = new BentoError(BentoError.ERROR_DATABASE_READING);
					}
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, data);
		}
		

	}
}
