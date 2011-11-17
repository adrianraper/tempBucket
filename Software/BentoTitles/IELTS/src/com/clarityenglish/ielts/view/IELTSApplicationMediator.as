package com.clarityenglish.ielts.view {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class IELTSApplicationMediator extends AbstractApplicationMediator implements IMediator {
		
		public static const NAME:String = "IELTSApplicationMediator";
		
		public function IELTSApplicationMediator(viewComponent:Object) {
			super(NAME, viewComponent);
		}
		
		private function get view():IELTSApplication {
			return viewComponent as IELTSApplication;
		}
		
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		/**
		 * List all notifications this Mediator is interested in.
		 *
		 * @return Array the list of nofitication names
		 */
		override public function listNotificationInterests():Array {
			// Concatenate any extra notifications to the array returned by this function in the superclass
			return super.listNotificationInterests().concat([
				// Register interest in LOGGED_IN here
				// so that this mediator can change the state of the application from login to home.
				CommonNotifications.INVALID_LOGIN,
				CommonNotifications.LOGGED_IN,
				CommonNotifications.CONFIG_LOADED,
			]);
		}
		
		/**
		 * Handle all notifications this Mediator is interested in.
		 *
		 * @param INotification a notification
		 */
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case CommonNotifications.CONFIG_LOADED:
					view.currentState = "login";
					
					// Inject some data to the login view
					var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
					view.loginView.setLicencee(configProxy.getAccount().name);
					break;
				
				case CommonNotifications.LOGGED_IN:
					view.currentState = "title";
					
					// For now hardcode the menu file
					configProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
					view.titleView.href = new Href(Href.XHTML, configProxy.getMenuFilename(), configProxy.getContentPath());
					trace("PATH: " + configProxy.getContentPath());
					
					// DK Hardcoded this for the moment as this contains the correct captions and classes for the IELTS zones
					//view.titleView.href = new Href(Href.XHTML, "menu.xml", "../../../Content/IELTS-Dave");
					//view.titleView.href = new Href(Href.XHTML, "menu.xml", "http://dock.projectbench/Content/IELTS-Dave");
					break;
			}
		}
	
	}
}
