package com.clarityenglish.bento.view {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;

	public class ApplicationMediator extends AbstractApplicationMediator implements IMediator {
		
		// Cannonical name of the Mediator
		public static const NAME:String = "ApplicationMediator";
		
		public function ApplicationMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		private function get application():BentoApplication {
			return viewComponent as BentoApplication;
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
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
			return ApplicationMediator.NAME;
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
			// Concatenate any extra notifications to the array returned by this function in the superclass
			return super.listNotificationInterests().concat([
				
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
				
			}
		}
		
	}
}