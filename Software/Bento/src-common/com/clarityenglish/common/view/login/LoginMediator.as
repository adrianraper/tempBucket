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
			
			// Inject some data to the login view
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.setLicencee(configProxy.getAccount().name);
			view.setProductVersion(configProxy.getProductVersion());
			view.setProductCode(configProxy.getProductCode());
			view.setLoginOption(configProxy.getAccount().loginOption);
			view.setSelfRegister(configProxy.getAccount().selfRegister);

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
				CommonNotifications.ADDED_NEW_USER,
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
				
				case CommonNotifications.INVALID_LOGIN:
					// If we catch this notification here, I want to handle it on the loginView
					// So I need to reimplement view.showInvalidLogin, and also stop the notification
					// from going on to be caught be IELTSApplicationMediator.
					trace("caught login error in login mediator");
					
					// AR Clear anything that is in the fields out - relevant to returning to this screen on logout
					view.clearData();
					break;
				
				case CommonNotifications.ADDED_NEW_USER:
					// #341
					// Just if successful. If yes, then just login
					var user:User = note.getBody() as User;
					if (user) {
						onLogin(new LoginEvent(LoginEvent.LOGIN, user.name, user.password, true));
					} else {
						trace ("error from add new user");
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
			sendNotification(CommonNotifications.ADD_NEW_USER, e);
		}

	}
}