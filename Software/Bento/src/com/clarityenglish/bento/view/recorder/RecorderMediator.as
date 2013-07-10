package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.RecorderNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class RecorderMediator extends BentoMediator implements IMediator {
		
		public function RecorderMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():RecorderView {
			return viewComponent as RecorderView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.addEventListener(RecorderEvent.COMPARE, onCompare);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.removeEventListener(RecorderEvent.COMPARE, onCompare);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				
			}
		}
		
		protected function onCompare(event:Event):void {
			sendNotification(RecorderNotifications.COMPARE_TO, "http://www.ruffness.com/ruffness/mp3/fortress.mp3");
		}
		
	}
}
