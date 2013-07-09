package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
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
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				
			}
		}
		
	}
}
