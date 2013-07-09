package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.RecorderNotifications;
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
			
			view.record.add(onRecord);
			view.stop.add(onStop);
			view.play.add(onPlay);
			view.pause.add(onPause);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.record.remove(onRecord);
			view.stop.remove(onStop);
			view.play.remove(onPlay);
			view.pause.remove(onPause);
		}
		
		override public function listNotificationInterests():Array {
			return [
				RecorderNotifications.INPUT_LEVEL,
				RecorderNotifications.RECORDING_STARTED,
			];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				case RecorderNotifications.INPUT_LEVEL:
					//if (note.getType() == audioProxyName)
					view.levelMeter.data = note.getBody();
					break;
				case RecorderNotifications.RECORDING_STARTED:
					view.pauseButton.enabled = false;
					view.playButton.enabled = false;
					break;
			}
		}
		
		private function onRecord():void {
			sendNotification(RecorderNotifications.RECORDING_START);
		}
		
		private function onStop():void {
			
		}
		
		private function onPlay():void {
			
		}
		
		private function onPause():void {
			
		}
		
	}
}
