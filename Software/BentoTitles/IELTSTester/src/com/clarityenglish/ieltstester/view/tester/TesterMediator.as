package com.clarityenglish.ieltstester.view.tester {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class TesterMediator extends BentoMediator {
		
		public function TesterMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():TesterView {
			return viewComponent as TesterView;
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				
			}
		}
		
	}
	
}