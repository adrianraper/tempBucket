/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Account;
	
	import mx.formatters.DateFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.Fault;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ProgressProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "ProgressProxy";
		
		/**
		 * Progress information comes from a database. Sometimes we want lots of details, and sometimes averages.
		 */
		public function ProgressProxy(data:Object = null) {
			super(NAME, data);
		}
		
		public function reset():void {
			
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
			//log.debug("Writing the score for exercise to the database");
			
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
			// gh#793 Handle server errors
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			var thisError:BentoError = BentoError.create(fault, false);
			switch (thisError.errorNumber) {
				case copyProxy.getCodeForId("errorServerConnection"):
					thisError.errorContext = copyProxy.getCopyForId("errorServerConnection", { message: fault.faultString });
					break;
				case copyProxy.getCodeForId("errorServer"):
					thisError.errorContext = copyProxy.getCopyForId("errorServer", { message: fault.faultString });
					break;
				default:
			}
			switch (operation) {
				// These operations would ideally queue for when you have your internet connection back again.
				// Until that happens you are probably best off just dropping them
				case "writeScore":
				case "updateSession":
				case "stopSession":
					break;
				case "startSession":
				default:
					thisError.isFatal = true;
			}

			sendNotification(CommonNotifications.BENTO_ERROR, thisError);
			sendNotification(CommonNotifications.TRACE_ERROR, thisError);
		}
		
	}
}
