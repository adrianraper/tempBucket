package com.clarityenglish.bento {
	import com.clarityenglish.textLayout.util.TLF2Application;
	
	import mx.events.FlexEvent;

	public class BentoApplication extends TLF2Application {
		
		protected var facade:ApplicationFacade = ApplicationFacade.getInstance();
		
		public function BentoApplication() {
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}

		private function onCreationComplete(event:FlexEvent):void {
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			// Start the PureMVC framework
			facade.sendNotification(BBNotifications.STARTUP, this);
		}
		
	}
}