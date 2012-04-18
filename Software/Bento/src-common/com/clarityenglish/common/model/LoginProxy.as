﻿/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Licence;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.Fault;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.DateUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class LoginProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "LoginProxy";
		public static const LICENCE_UPDATE_DELAY:Number = 60000;
		
		private var _user:User;
		private var _group:Group;
		//private var _licence:Licence;

		private var licenceTimer:Timer;

		public function LoginProxy(data:Object = null) {
			super(NAME, data);
			
			// TODO: We might want to maintain sessions later on, but for the moment always ensure authentication is cleared
			// on each startup.
			//logout();
		}
		
		public function get user():User {
			return _user;
		}
		
		public function get group():Group {
			return _group;
		}
		
		public function login(key:String, password:String):void {
			// getAccountSettings will already have established rootID and productCode
			// The parameters you pass are controlled by loginOption
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			// For AA licences you still do the call as this does getLicenceSlot
			
			var loginOption:uint = configProxy.getAccount().loginOption;
			if (loginOption & 1) {
				var loginObj:Object = {username:key, password:password};
			} else if (loginOption & 2) {
				loginObj = {studentID:key, password:password};
			}
			if (configProxy.getConfig().ip)
				loginObj.ip = configProxy.getConfig().ip;
			
			// Create a unique number to use as an instance ID, and save it in the config object
			var instanceID:Number = new Date().getTime();
			configProxy.getConfig().instanceID = instanceID.toString();
			
			// Off to the database
			// #307 Add rootID and productCode
			var params:Array = [ loginObj, loginOption, instanceID, configProxy.getConfig().licence, configProxy.getRootID(), configProxy.getProductCode() ];
			new RemoteDelegate("login", params, this).execute();
		}
		
		public function logout():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var params:Array = [ configProxy.getConfig().licence ];
			new RemoteDelegate("logout", params, this).execute();
			
			// Stop the licence update timer
			if (licenceTimer) licenceTimer.stop();
		}
		
		/**
		 * Method to get user's instance ID from the database
		 *
		 * @return void - Asynchronous call. Will return instanceID and error objects later. 
		 */
		public function checkInstance():void {
			if (user) {
				var userDetails:Object = { userID: user.userID };
				var params:Array = [ userDetails ];
				new RemoteDelegate("getInstanceID", params, this).execute();
			}
		}

		public function updateUser(userChanges:Object):void {
			// Current user details are already here
			// So the user details you are passed just overwrite the relevant ones
			// Do I need to clone the user in case I end up not managing to make the change?
			var newUserDetails:User = user;
			
			// Get new details from the passed object
			// We could either cycle through all properties or just do expected ones
			if (userChanges.password)
				newUserDetails.password = userChanges.password;
			if (userChanges.examDate)
				newUserDetails.birthday = userChanges.examDate;
			if (userChanges.email)
				newUserDetails.email = userChanges.email;
			
			// #307 pass rootID too
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			// Off to the database
			var params:Array = [ newUserDetails, configProxy.getRootID() ];
			new RemoteDelegate("updateUser", params, this).execute();
		}

		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void {
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			switch (operation) {
				case "getInstanceID":
					if (data) {
						// Check if the returned instance ID is the same as our current session
						configProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
						
						// To help Alfred trigger the error screen
						if (Config.DEVELOPER.name == "AN") {
							var config:Config = configProxy.getConfig();
							config.instanceID = '123';
						}
						
						// DK: Disabled this for me as its stopping me testing any exercises
						if (data.instanceID != configProxy.getInstanceID() && Config.DEVELOPER.name != "DK") {
							sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorFailedInstanceCheck", { instanceID: data.instanceID, sessionID: configProxy.getInstanceID() } ));
						}
						
					} else {
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorGetInstanceId"));
					}
					break;
				
				case "updateLicence":
					break;
				
				case "updateUser":
					sendNotification(BBNotifications.USER_UPDATED, data);	
					break;
				
				case "login":
					if (data) {
						// Successful login
						// This should have been set in configProxy
						//CopyProxy.languageCode = data.languageCode as String;
						
						// AR Use the loginProxy as a model as well as a service by holding the data that comes back here
						// TODO. Although id and name are properties of manageable and thus user in PHP
						// it seems that it doesn't get set here. It is in manageables[0].inherited data
						// And id and name are the two key pieces of information I need.
						_user = data.group.manageables[0] as User;
						//var manageable:Manageable = data.group.manageables[0] as Manageable;
						//_user.id = user.userID;
						//_user.name = user.fullName;
						//_user = new User();
						//_user.buildUser(data.group.manageables[0]);
						
						_group = data.group as Group;
						//_user = _group.children[0];
						
						// Add the licence id you just got to the config
						var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
						configProxy.getConfig().licence.id = (data.licence as Licence).id;
						
						// Carry on with the process
						sendNotification(CommonNotifications.LOGGED_IN, data);
						
						// Now that you are logged in, trigger the session start command
						var sessionData:Object = {user: _user, account: configProxy.getAccount()};
						sendNotification(BBNotifications.SESSION_START, sessionData);
						
						// Create a timer that will be fire off every minute to update the licence
						licenceTimer = new Timer(LICENCE_UPDATE_DELAY, 0)
						licenceTimer.addEventListener(TimerEvent.TIMER, licenceTimerHandler);
						licenceTimer.start();
					} else {
						// Invalid login
						sendNotification(CommonNotifications.INVALID_LOGIN);
					}
					break;
				
				case "logout":
					trace("back from logout");
					sendNotification(CommonNotifications.LOGGED_OUT);
					break;
				
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, fault:Fault):void {
			switch (operation) {
				case "login":
					sendNotification(CommonNotifications.INVALID_LOGIN, BentoError.create(fault));
					break;
				case "updateLicence":
					sendNotification(CommonNotifications.BENTO_ERROR, BentoError.create(fault));
					break;
				case "updateUser":
					sendNotification(CommonNotifications.UPDATE_FAILED);
					break;
				case "getInstanceID":
					sendNotification(CommonNotifications.BENTO_ERROR, BentoError.create(fault));
					break;
			}
			
			sendNotification(CommonNotifications.TRACE_ERROR, fault.faultString);
		}
		
		/**
		 * A timer handler that tells the database to update the licence record to show that the user is still active 
		 * @param event
		 * @param TimerEvent
		 * 
		 */
		private function licenceTimerHandler(event:TimerEvent):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			log.info("fire the timer to update licence {0}", configProxy.getConfig().licence.id);
			var params:Array = [ configProxy.getConfig().licence ];
			new RemoteDelegate("updateLicence", params, this).execute();
		}
		
	}
}