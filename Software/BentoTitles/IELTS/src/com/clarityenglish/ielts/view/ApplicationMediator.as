package com.clarityenglish.ielts.view {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;

	public class ApplicationMediator extends AbstractApplicationMediator implements IMediator {
		
		public static const NAME:String = "ApplicationMediator";
		
		public function ApplicationMediator(viewComponent:Object) {
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
				
			}
		}
		
	}
}