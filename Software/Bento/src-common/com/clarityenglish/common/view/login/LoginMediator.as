﻿/*
 Mediator - PureMVC
 */
package com.clarityenglish.common.view.login {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.login.LoginView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	
	import mx.core.FlexGlobals;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class LoginMediator extends BentoMediator implements IMediator {
		
		public function LoginMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():LoginView {
			return viewComponent as LoginView;
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			view.addEventListener(LoginEvent.LOGIN, onLogin);
			view.addEventListener(LoginEvent.ADD_USER, onAddUser);
			
			view.getTestDrive().add(onTestDrive);
			view.startDemo.add(onStartDemo);
			
			// Inject some data to the login view
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			// gh#1090
			view.licenceeName = configProxy.getAccount().name;
			
			// gh#1090 Not generally needed. If a specific view wants it, it can get it direct from view.config.platform
			/*
			// get the login platform
			if (configProxy.isPlatformTablet()) {
				view.setPlatformTablet(true);
				if (configProxy.isPlatformiPad()) {
					view.setPlatformiPad(true);
				} else if (configProxy.isPlatformAndroid()) {
					view.setPlatformAndroid(true);
				}
			} else {
				view.setPlatformTablet(false);
			}
			*/
			
			// gh#224
			//view.setBranding(configProxy.getConfig().customisation);
			view.branding = configProxy.getBranding('login');
			
			view.productVersion = configProxy.getProductVersion();
			view.productCode = configProxy.getProductCode();
			
			// gh#659 using productCodes to distinguish the ipad login and online login
			// And using productCodes length to distinguish an account has IPrange setting.
			/*
			if (configProxy.getAccount().IPMatchedProductCodes.length > 0){
				view.setHasMatchedIPrange(true);
				view.setIPMatchedProductCodes(configProxy.getAccount().IPMatchedProductCodes);
			} else {
				view.setHasMatchedIPrange(false);
			}
			*/
			
			// #341
			view.loginOption = configProxy.getLoginOption(); // gh#44
			view.selfRegister = configProxy.getAccount().selfRegister;
			view.verified = (configProxy.getAccount().verified == Config.LOGIN_REQUIRE_PASSWORD);
			view.licenceType = configProxy.getLicenceType();
			
			// #41
			view.noAccount = !(configProxy.getRootID());
			
			// gh#886
			view.noLogin = configProxy.getConfig().noLogin;
			
			// gh#1090
			view.clearData();
			view.setState("normal");
		}
        
		override public function onRemove():void {
			super.onRemove();
			
			view.removeEventListener(LoginEvent.LOGIN, onLogin);
			view.removeEventListener(LoginEvent.ADD_USER, onAddUser);
		}
		
		/**
		 * List all notifications this Mediator is interested in.
		 * <P>
		 * Automatically called by the framework when the mediator
		 * is registered with the view.</P>
		 * 
		 * @return Array the list of Nofitication names
		 */
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				CommonNotifications.INVALID_LOGIN,
				CommonNotifications.COPY_LOADED,
				CommonNotifications.CONFIRM_NEW_USER,
				CommonNotifications.ADDED_USER,
			]);
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * <P>
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * (see <code>listNotificationInterests</code>.</P>
		 * 
		 * @param INotification a notification 
		 */
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					view.setCopyProvider(copyProvider);
					
					// AR Clear anything that is in the fields out - relevant to returning to this screen on logout
					view.clearData();
					break;
				
				// gh#1090 no longer used
				/*
				case CommonNotifications.CONFIRM_NEW_USER:
					view.setState("register");
					break;
				case CommonNotifications.ADDED_USER:
					// #341
					// Check if successful. If yes, then just login that user
					var user:User = note.getBody() as User;
					if (user) {
						var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
						onLogin(new LoginEvent(LoginEvent.LOGIN, user, configProxy.getAccount().loginOption));
					} else {
						//trace("error from add new user");
						// Need to pass the error in. Perhaps the error is flagged as a popup just like wrong password in login.
						view.setState("error");
					}
					break;
				*/
				
				case CommonNotifications.INVALID_LOGIN:
					// If we catch this notification here, I want to handle it on the loginView
					// So I need to reimplement view.showInvalidLogin, and also stop the notification
					// from going on to be caught be IELTSApplicationMediator.
					//trace("caught login error in login mediator");
					
					// AR Clear anything that is in the fields out - relevant to returning to this screen on logout
					//view.clearData();
					view.clearPassword();
						
					break;
				
				default:
					break;
			}
		}
		
		private function onLogin(e:LoginEvent):void {
			sendNotification(CommonNotifications.LOGIN, e);
		}

		private function onAddUser(e:LoginEvent):void {
			sendNotification(CommonNotifications.ADD_USER, e);
		}
		
		// gh#41 Make sure that we know which productCode they want to run
		private function onTestDrive(productCode:String):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.getConfig().productCode = productCode;			
		}
		
		// gh#1090
		private function onStartDemo(prefix:String, productCode:String):void {
			FlexGlobals.topLevelApplication.parameters.prefix = 'DEMO';
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.reset();
			sendNotification(CommonNotifications.ACCOUNT_RELOAD);
		}
		
	}
}