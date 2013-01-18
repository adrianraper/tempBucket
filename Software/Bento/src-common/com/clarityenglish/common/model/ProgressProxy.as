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
				// TODO: We no longer have a getProgressData, but there are these specific errors here which Adrian put in and don't exist in the new system.
				// Need to check whether they still matter and if so re-implement.
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
				
	}
}
