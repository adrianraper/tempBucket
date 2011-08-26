/*
 Mediator - PureMVC
 */
package com.clarityenglish.common.view {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.LoginMediator;
	import mx.controls.Alert;
	import mx.core.Application;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class AbstractApplicationMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ApplicationMediator";
		
		public function AbstractApplicationMediator(NAME:String, viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		private function get application():Application {
			return viewComponent as Application;
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			// Since Application is a parent class we need to reference loginView (which must exist) dynamically
			if (application["loginView"] == null)
				throw new Error("The main application class must have an instance named 'loginView'");
			
			facade.registerMediator(new LoginMediator(application["loginView"]));
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
			return AbstractApplicationMediator.NAME;
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
					CommonNotifications.LOGGED_OUT,
					CommonNotifications.TRACE_NOTICE,
					CommonNotifications.TRACE_WARNING,
					CommonNotifications.TRACE_ERROR,
					CommonNotifications.LOGGED_IN,
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
				case CommonNotifications.TRACE_NOTICE:
					trace("[Notice] " + note.getBody() as String);
					break;
				case CommonNotifications.TRACE_WARNING:
					trace("[Warning] " + note.getBody() as String);
					break;
				case CommonNotifications.TRACE_ERROR:
					trace("[Error] " + note.getBody() as String);
					Alert.show(note.getBody() as String, "Error", Alert.OK, application);
					break;
				case CommonNotifications.COPY_LOADED:
					// Set the alert box labels from the copy
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					Alert.yesLabel = copyProvider.getCopyForId("yes");
					Alert.noLabel = copyProvider.getCopyForId("no");
					break;
				default:
					break;		
			}
		}

	}
}
