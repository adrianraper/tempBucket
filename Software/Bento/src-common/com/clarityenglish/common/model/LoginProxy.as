﻿/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.manageable.User;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class LoginProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "LoginProxy";
		
		public var _user:User;

		public function LoginProxy(data:Object = null) {
			super(NAME, data);
			
			// TODO: We might want to maintain sessions later on, but for the moment always ensure authentication is cleared
			// on each startup.
			logout();
		}
		
		public function login(key:String, password:String):void {
			
			// getAccountSettings will already have established rootID and productCode
			// The parameters you pass are controlled by loginOption
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var loginOption:uint = configProxy.getAccount().loginOption;
			if (loginOption==1) {
				var loginObj:Object = {username:key, password:password};
			} else if (loginOption==2) {
				loginObj = {studentID:key, password:password};
			}
			
			// Create a unique number to use as an instance ID, and save it in the config object
			var instanceID:Number = new Date().getTime();
			configProxy.getConfig().instanceID = instanceID;
			
			// Off to the database
			var params:Array = [ loginObj, loginOption, instanceID ];
			new RemoteDelegate("login", params, this).execute();
			//trace("In LoginProxy calling RemoteDelegate");
			//onDelegateResult("login", {status:"success", user:{id:"10159", name:username}, languageCode:"EN"});
		}
		
		public function logout():void {
			onDelegateResult("logout", {status:"success"});
			//new RemoteDelegate("logout", [ ], this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "login":
					if (data) {
						// Successful login
						CopyProxy.languageCode = data.languageCode as String;
						
						// AR Use the loginProxy as a model as well as a service by holding the data that comes back here
						_user = new User();
						_user.buildUser(data.user);
						
						sendNotification(CommonNotifications.LOGGED_IN, data);
					} else {
						// Invalid login
						sendNotification(CommonNotifications.INVALID_LOGIN);
					}
					break;
				case "logout":
					sendNotification(CommonNotifications.LOGGED_OUT);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, data);
		}
		
		/**
		 * If anyone wants the logged in user's details
		 * 
		 */
		public function get user():User {
			return _user;
		}
		
	}
}