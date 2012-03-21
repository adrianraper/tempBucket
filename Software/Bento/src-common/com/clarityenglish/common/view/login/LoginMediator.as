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
				case CommonNotifications.INVALID_LOGIN:
					view.showInvalidLogin(note.getBody() as BentoError);
					break;
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					view.setCopyProvider(copyProvider);
					
					// AR Clear anything that is in the fields out - relevant to returning to this screen on logout
					view.clearData();
					break;
				default:
					break;
			}
		}
		
		private function onLogin(e:LoginEvent):void {
			sendNotification(CommonNotifications.LOGIN, e);
		}

	}
}