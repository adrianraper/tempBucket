﻿/*
 Mediator - PureMVC
 */
package com.clarityenglish.common.view.login {
	import com.clarityenglish.bento.view.BentoMediator;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class LoginMediator extends BentoMediator implements IMediator {
		
		public function LoginMediator(mediatorName:String, viewComponent:LoginComponent) {
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
					view.showInvalidLogin();
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
			// AR Since this successful, clear out the name/password so that when/if you return to this
			// screen they do not contain your details.
			// Gives a manageables error!! So do it on copyloaded.
			//loginView.clearData();
			sendNotification(CommonNotifications.LOGIN, e);
		}

	}
}
