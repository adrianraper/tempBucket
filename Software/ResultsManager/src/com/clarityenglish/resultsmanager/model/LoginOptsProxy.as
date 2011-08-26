/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import com.clarityenglish.utils.TraceUtils;

	/**
	 * A proxy
	 */
	public class LoginOptsProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "LoginOptsProxy";
		
		private var loginOption:Number;
		private var selfRegister:Number;
		private var passwordRequired:Boolean;
		
		public static const USERNAME_ONLY:int = 1;
		public static const STUDENTID_ONLY:int = 2;
		public static const USERNAME_AND_STUDENTID:int = 4;
		public static const ALLOW_ANONYMOUS:int = 8;
		public static const NON_CE_LOGIN:int = 16;
		public static const ALLOW_CHANGE_PASSWORD:int = 32;
		public static const CE_LOGIN:int = 64;
		public static const CE_SHARED_LOGIN:int = 128;
		
		public static const SR_NAME:int = 1;
		public static const SR_STUDENTID:int = 2;
		public static const SR_EMAIL:int = 4;
		public static const SR_PASSWORD:int = 16;
		public static const SR_BIRTHDAY:int = 32;
		public static const SR_COUNTRY:int = 64;
		public static const SR_COMPANY:int = 128;
		public static const SR_CUSTOM1:int = 256;
		public static const SR_CUSTOM2:int = 512;
		public static const SR_CUSTOM3:int = 1024;
		public static const SR_CUSTOM4:int = 2048;

		public function LoginOptsProxy(data:Object = null) {
			super(NAME, data);
			
			getLoginOpts();
		}
		
		public function getLoginOpts():void {
			TraceUtils.myTrace("proxy.getEmailOpts");
			new RemoteDelegate("getLoginOpts", [], this).execute();
		}
		
		public function saveLoginOpts():void {
			//TraceUtils.myTrace("proxy.saveLoginOpts loginOption=" + loginOption + " selfReg=" + selfRegister + " passReq=" + passwordRequired);
			new RemoteDelegate("setLoginOpts", [ loginOption, selfRegister, passwordRequired ], this).execute();
		}
		
		public function getLoginTypeLoginOpt():int {
			if (isLoginOptionSet(USERNAME_ONLY)) return USERNAME_ONLY;
			if (isLoginOptionSet(STUDENTID_ONLY)) return STUDENTID_ONLY;
			if (isLoginOptionSet(USERNAME_AND_STUDENTID)) return USERNAME_AND_STUDENTID;
			
			return 0;
		}
		
		public function isAnonLoginAllowed():Boolean {
			return isLoginOptionSet(ALLOW_ANONYMOUS);
		}
		
		public function isPasswordRequired():Boolean {
			return passwordRequired;
		}
		
		public function canUnregisteredUsersLogin():Boolean {
			//TraceUtils.myTrace("proxy.canUnregisteredUsersLogin selfReg=" + selfRegister);
			return (selfRegister > 0);
		}
		
		public function setLoginTypeLoginOpt(opt:int):void {
			setLoginOption(USERNAME_ONLY, (opt == USERNAME_ONLY));
			setLoginOption(STUDENTID_ONLY, (opt == STUDENTID_ONLY));
			setLoginOption(USERNAME_AND_STUDENTID, (opt == USERNAME_AND_STUDENTID));
		}
		
		public function setAnonLoginAllowed(anonLoginAllowed:Boolean):void {
			setLoginOption(ALLOW_ANONYMOUS, anonLoginAllowed);
		}
		
		public function setPasswordRequired(passwordRequired:Boolean):void {
			this.passwordRequired = passwordRequired;
		}
		
		public function setCanUnregisteredUsersLogin(canUnregisteredUsersLogin:Boolean):void {
			//TraceUtils.myTrace("loginOptsProxy.setCanUnregisteredUsersLogin to " + canUnregisteredUsersLogin);
			this.selfRegister = (canUnregisteredUsersLogin) ? 1 : 0;
			//TraceUtils.myTrace("proxy.setCanUnregisteredUsersLogin selfReg=" + this.selfRegister);
		}
		
		public function setRequiredSelfRegisterFields(selfRegisterField:int, enabled:Boolean):void {
			setSelfRegisterOption(selfRegisterField, enabled);
		}
		
		private function isLoginOptionSet(flag:int):Boolean {
			return ((loginOption | flag) == loginOption);
		}
		
		private function setLoginOption(flag:int, enabled:Boolean):void {
			if (enabled)
				loginOption |= flag;
			else
				loginOption &= ~flag;
		}
		
		public function isSelfRegisterOptionSet(flag:int):Boolean {
			return ((selfRegister | flag) == selfRegister);
		}
		
		private function setSelfRegisterOption(flag:int, enabled:Boolean):void {
			if (enabled)
				selfRegister |= flag;
			else
				selfRegister &= ~flag;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getLoginOpts":
					// v3.5 data type checking. Note that simply setting x as Number is not good enough to 
					// convert the strings that MySQL sends back instead of numbers
					loginOption = Number(data.loginOption);
					//loginOption = data.loginOption as Number;
					//selfRegister = data.selfRegister as Number;
					selfRegister = Number(data.selfRegister);
					// v3.5 This fails to correctly tell between 0 (false) and 1 (true). The db field is an integer.
					//passwordRequired = data.passwordRequired as Boolean;
					passwordRequired = (Number(data.passwordRequired) == 0) ? false: true;
					
					sendNotification(RMNotifications.LOGINOPTS_LOADED);
					break;
				case "setLoginOpts":
					getLoginOpts();
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);

			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void {
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
			
			switch (operation) {
				case "setLoginOpts":
					break;
				case "getLoginOpts":
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Fault from unknown operation: " + operation);
			}
		}
		
	}
}