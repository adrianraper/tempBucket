/*
 Mediator - PureMVC
 */
package com.clarityenglish.common.view.login {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.controller.LoginCommand;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.events.LoginEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.clarityenglish.utils.TraceUtils;
	
	/**
	 * A Mediator
	 */
	public class LoginMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "LoginMediator";
		
		public function LoginMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
			
			if (!(viewComponent is LoginComponent))
				throw new Error("The viewComponent passed to LoginMediator MUST implement the LoginComponent interface");
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			loginView.addEventListener(LoginEvent.LOGIN, onLogin);
		}
		
		private function get loginView():LoginComponent {
			return viewComponent as LoginComponent;
		}

		/**
		 * Get the Mediator name.
		 * <P>
		 * Called by the framework to get the name of this
		 * mediator. If there is only one instance, we may
		 * define it in a constant and return it here. If
		 * there are multiple instances, this method must
		 * return the unique name of this instance.</P>
		 * 
		 * @return String the Mediator name
		 */
		override public function getMediatorName():String {
			return LoginMediator.NAME;
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
			return [
					CommonNotifications.INVALID_LOGIN,
					CommonNotifications.COPY_LOADED,
				];
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
			switch (note.getName()) {
				case CommonNotifications.INVALID_LOGIN:
					loginView.showInvalidLogin();
					break;
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					loginView.setCopyProvider(copyProvider);
					// AR Clear anything that is in the fields out - relevant to returning to this screen on logout
					loginView.clearData();
					break;
				default:
					break;
			}
		}
		
		private function onLogin(e:LoginEvent):void {
			// AR Since this successful, clear out the name/password so that when/if you return to this
			// screen they do not contain your details.
			// Gives a manageables error!! So do it on copyloaded.
			//loginView.clearData();
			TraceUtils.myTrace("onLogin for " + e.username);
			sendNotification(CommonNotifications.LOGIN, e);
		}

	}
}
