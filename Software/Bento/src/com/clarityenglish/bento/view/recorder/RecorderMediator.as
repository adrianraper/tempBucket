package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.RecorderNotifications;
	import com.clarityenglish.bento.model.AudioProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.events.CloseEvent;
	
	import org.davekeen.util.PlayerUtils;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	import ws.tink.spark.controls.Alert;
	
	/**
	 * A Mediator
	 */
	public class RecorderMediator extends BentoMediator implements IMediator {
		
		private var stateBeforeProgress:String;
		
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
				RecorderNotifications.WAV_ENCODE_START,
				RecorderNotifications.WAV_ENCODE_COMPLETE,
				RecorderNotifications.MP3_ENCODE_START,
				RecorderNotifications.MP3_ENCODE_PROGRESS,
				RecorderNotifications.MP3_ENCODE_COMPLETE,
				RecorderNotifications.MP3_LOAD_START,
				RecorderNotifications.MP3_LOAD_PROGRESS,
				RecorderNotifications.MP3_LOAD_COMPLETE,
				RecorderNotifications.MP3_SAVE_COMPLETE,
				/*ApplicationFacade.COMPARE_TO,
				ApplicationFacade.COMPARE_STATE,
				ApplicationFacade.PLAYING_COMPLETE,
				ApplicationFacade.RECORDING_STOPPED,
				ApplicationFacade.RELEASE_ALWAYS_ON_TOP,
				ApplicationFacade.NO_MICROPHONE,
				ApplicationFacade.GOT_MICROPHONE,*/
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				case RecorderNotifications.MP3_LOAD_START:
					stateBeforeProgress = view.currentState;
					
					view.setCurrentState("progress");
					
					view.progressLabel.text = "Loading MP3...";
					view.progressBar.indeterminate = false;
					view.progressBar.setProgress(0, 100);
					break;
				case RecorderNotifications.MP3_LOAD_COMPLETE:
					view.setCurrentState(stateBeforeProgress);
					break;
				case RecorderNotifications.WAV_ENCODE_START:
					stateBeforeProgress = view.currentState;
					
					view.setCurrentState("progress");
					
					view.progressLabel.text = "Processing data...";
					view.progressBar.indeterminate = true;
					break;
				case RecorderNotifications.WAV_ENCODE_COMPLETE:
					break;
				case RecorderNotifications.MP3_ENCODE_START:
					view.progressLabel.text = "Preparing MP3...";
					view.progressBar.indeterminate = false;
					view.progressBar.setProgress(0, 100);
					break;
				case RecorderNotifications.MP3_LOAD_PROGRESS:
				case RecorderNotifications.MP3_ENCODE_PROGRESS:
					view.progressBar.setProgress(note.getBody().bytesLoaded, note.getBody().bytesTotal);
					break;
				case RecorderNotifications.MP3_ENCODE_COMPLETE:
					view.setCurrentState(stateBeforeProgress);
					
					if (!PlayerUtils.isAirApplication()) {
						Alert.show("Click OK to save your MP3 file", "Save", Vector.<String>(["OK"]), view, function(e:CloseEvent):void {
							if (e.detail == 0) {
								var audioProxy:AudioProxy = facade.retrieveProxy(note.getType()) as AudioProxy;
								audioProxy.saveMP3Data(note.getBody() as ByteArray);
							}
						} );
					}
					break;
				case RecorderNotifications.MP3_SAVE_COMPLETE:
					break;
			}
		}
		
		protected function onCompare(event:Event):void {
			sendNotification(RecorderNotifications.COMPARE_TO, "http://www.ruffness.com/ruffness/mp3/fortress.mp3");
		}
		
	}
}
