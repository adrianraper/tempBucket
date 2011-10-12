/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.common.CommonNotifications;
	
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
		
		public function LoginProxy(data:Object = null) {
			super(NAME, data);
			
			// TODO: We might want to maintain sessions later on, but for the moment always ensure authentication is cleared
			// on each startup.
			logout();
		}
		
		public function login(username:String, password:String):void {
			// The rootID can optionally be defined in FlashVars (in fact this will always be done in the live application, but leave
			// it optional to make testing easier - if the rootID is not defined then get it for the logged in user.  In the event that
			// there is more than one user with the given username/password in different roots the login will fail with a message to
			// that effect.
			var params:Array = [ username, password ];
			if (FlexGlobals.topLevelApplication.parameters.rootID) {
				params.push(new Number(FlexGlobals.topLevelApplication.parameters.rootID));
			} else {
				// Just push a null if it hasn't been passed
				params.push(null);
			}
			// v3.4 If you pass dbHost, the backend wants to know it. But by the time you can read from here, it is too late.
			// So we will have to stick to session variables.
			/*
			if (Application.application.parameters.dbHost) {
				params.push(new Number(Application.application.parameters.dbhost));
			} else {
				// Just push a null if it hasn't been passed
				params.push(null);
			}
			// v3.1 If you pass a productCode, then limit account information to that product
			// I think this is not used at all in the backend.
			if (Application.application.parameters.productCode) {
				params.push(new Number(Application.application.parameters.productCode));
			} else {
				// Just push a null if it hasn't been passed
				params.push(null);
			}
			*/
			// I think that for now I don't have RemoteDelegate working - so fake a return
			//new RemoteDelegate("login", params, this).execute();
			trace("In LoginProxy calling RemoteDelegate");
			onDelegateResult("login", {status:"success", userID:"10189"});
		}
		
		public function logout():void {
			new RemoteDelegate("logout", [ ], this).execute();
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "login":
					if (data) {
						// Successful login
						CopyProxy.languageCode = data.languageCode as String;
						
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
		
	}
}