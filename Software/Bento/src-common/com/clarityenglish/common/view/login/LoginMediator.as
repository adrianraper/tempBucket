/*
 Mediator - PureMVC
 */
package com.clarityenglish.common.view.login {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class LoginMediator extends BentoMediator implements IMediator {
		
		public function LoginMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():LoginComponent {
			return viewComponent as LoginComponent;
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			view.addEventListener(LoginEvent.LOGIN, onLogin);
			view.addEventListener(LoginEvent.ADD_USER, onAddUser);
			
			// Inject some data to the login view
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.setLicencee(configProxy.getAccount().name);
			
			view.setProductVersion(configProxy.getProductVersion());
			view.setProductCode(configProxy.getProductCode());
			
			// #341
			view.setLoginOption(configProxy.getLoginOption()); // GH #44
			view.setSelfRegister(configProxy.getAccount().selfRegister);
			view.setVerified(configProxy.getAccount().verified);
			view.setLicenceType(configProxy.getLicenceType());
			
			// #41
			var noAccount:Boolean = !(configProxy.getRootID());
			view.setNoAccount(noAccount);
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
				
				case CommonNotifications.CONFIRM_NEW_USER:
					view.setState("register");
					break;
				
				case CommonNotifications.INVALID_LOGIN:
					// If we catch this notification here, I want to handle it on the loginView
					// So I need to reimplement view.showInvalidLogin, and also stop the notification
					// from going on to be caught be IELTSApplicationMediator.
					trace("caught login error in login mediator");
					
					// AR Clear anything that is in the fields out - relevant to returning to this screen on logout
					view.clearData();
						
					break;
				
				case CommonNotifications.ADDED_USER:
					// #341
					// Check if successful. If yes, then just login that user
					var user:User = note.getBody() as User;
					if (user) {
						var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
						onLogin(new LoginEvent(LoginEvent.LOGIN, user, configProxy.getAccount().loginOption));
					} else {
						trace("error from add new user");
						// Need to pass the error in. Perhaps the error is flagged as a popup just like wrong password in login.
						view.setState("registerError");
					}
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
		/*
		private function onTestDrive(productCode:String):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.getConfig().productCode = productCode;			
		}
		*/
	}
}