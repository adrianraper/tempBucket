/*
 Mediator - PureMVC
 */
package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.RecorderNotifications;
	import com.clarityenglish.bento.model.AudioProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.recorder.events.WaveformEvent;
	import com.clarityenglish.bento.view.recorder.events.WaveformRangeEvent;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.Timer;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class WaveformMediator extends BentoMediator implements IMediator {
		
		//private var mp3FileReference:FileReference;
		private var fileReference:FileReference;
		
		public function WaveformMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
			
			//this.audioProxyName = RecorderNotifications.RECORD_PROXY_NAME; // TODO: should be defined in the mxml instantiating the view
		}
		
		private function get view():WaveformView {
			return viewComponent as WaveformView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.addEventListener(WaveformEvent.PLAY, onPlay);
			view.addEventListener(WaveformEvent.PAUSE, onPause);
			view.addEventListener(WaveformEvent.STOP, onStop);
			view.addEventListener(WaveformEvent.RECORD, onRecord);
			view.addEventListener(WaveformEvent.SAVE_MP3, onSaveMP3);
			//view.addEventListener(WaveformEvent.LOAD_MP3, onLoadMP3);
			view.addEventListener(WaveformEvent.NEW_WAVE, onNewWave);
			view.addEventListener(WaveformRangeEvent.CUT, onCut);
			
			// Inject variables into the view
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			view.isRecordEnabled = audioProxy.isRecordEnabled();
			view.sampleRate = AudioProxy.SAMPLE_RATE;
			// v4.0.1.1 Small step to help trouble shoot
			// which microphone are we recording from?
			if (view.isRecordEnabled) {
				view.microphoneName = audioProxy.getMicrophoneName();
				view.audioStatus = audioProxy.audioStatus;
			}
			
			// gh#683
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (configProxy.isPlatformTablet() && configProxy.isPlatformiPad()) {
				view.isSaveEnabled = false;
			} else {
				view.isSaveEnabled = true;
			}
			// Prepare the view
			prepareView();
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.removeEventListener(WaveformEvent.PLAY, onPlay);
			view.removeEventListener(WaveformEvent.PAUSE, onPause);
			view.removeEventListener(WaveformEvent.STOP, onStop);
			view.removeEventListener(WaveformEvent.RECORD, onRecord);
			view.removeEventListener(WaveformEvent.SAVE_MP3, onSaveMP3);
			//view.removeEventListener(WaveformEvent.LOAD_MP3, onLoadMP3);
			view.removeEventListener(WaveformEvent.NEW_WAVE, onNewWave);
			view.removeEventListener(WaveformRangeEvent.CUT, onCut);
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
			return super.listNotificationInterests().concat([
				RecorderNotifications.AUDIO_BYTES_READY,
				RecorderNotifications.PLAYHEAD_POSITION,
				RecorderNotifications.INPUT_LEVEL,
				RecorderNotifications.RECORDING_STARTED,
				RecorderNotifications.RECORDING_STOPPED,
				RecorderNotifications.CLEAR_WAVEFORM,
				BBNotifications.DATA_CHANGED,
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
			switch (note.getName()) {
				case RecorderNotifications.AUDIO_BYTES_READY:
					prepareView();
					break;
				case RecorderNotifications.PLAYHEAD_POSITION:
					if (note.getType() == view.audioProxyName)
						view.waveformRenderer.playheadPosition = note.getBody() as Number;
					break;
				case RecorderNotifications.INPUT_LEVEL:
					if (note.getType() == view.audioProxyName)
						view.levelMeter.data = note.getBody();
					break;
				case RecorderNotifications.RECORDING_STARTED:
					if (note.getType() == view.audioProxyName) {
						view.isRecording = true;
						view.waveformRenderer.recording = true;
						
						view.mp3FileSizeText = "Recording...";
						view.durationText = "";
					}
					break;
				case RecorderNotifications.RECORDING_STOPPED:
					if (note.getType() == view.audioProxyName) {
						view.isRecording = false;
						view.waveformRenderer.recording = false;
						updateMp3Info();
						// Bug 4. 17 July 2010. AR
						// You can't pause or play whilst you are recording. Enable once you stop recording.
						// This works for the stop button, but not for the record button. Yet the flow is correct.
						// So I guess that the button enabling/disabling is doubling up somehow as you go through onRecord in the same display cycle.
						// So use the old chestnut of a tiny delay to get it nice.
						//waveformView.pauseButton.enabled = true;
						//waveformView.playButton.enabled = true;
						//trace("set play button on");
						var myTimer:Timer = new Timer(100, 1); // 0.1 second
						myTimer.addEventListener(TimerEvent.TIMER, runOnce);
						myTimer.start();

						function runOnce(event:TimerEvent):void {
							if (view.pauseButton) view.pauseButton.enabled = true;
							if (view.playButton) view.playButton.enabled = true;
							if (view.newButton) view.newButton.enabled = true;
							if (view.saveButton) view.saveButton.enabled = true;
						}
					}
					break;
				case RecorderNotifications.CLEAR_WAVEFORM:
					if (note.getType() == view.audioProxyName) {
						view.reset();
						updateMp3Info();
					}
					break;
				case BBNotifications.DATA_CHANGED:
					if (note.getType() == "lastPlayedAudioInExerise") {
						view.isCompareEnabled = (note.getBody() !== null);
					}
					break;
				default:
					break;
			}
		}
		
		private function prepareView():void {
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			view.samples = audioProxy.samples;
			
			updateMp3Info();
		}
		
		private function updateMp3Info():void {
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			
			view.mp3FileSizeText = (audioProxy.samples) ? "MP3 file size " + Math.round(audioProxy.samples.length / 22000) + "kb" : "-";
			var duration:String = ((audioProxy.samples.length / AudioProxy.SAMPLE_RATE / 8) as Number).toFixed(1);
			view.durationText = (audioProxy.samples) ? "Duration " + duration + "s" : "-";
		}
		
		private function onPlay(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			audioProxy.play(view.waveformRenderer.leftSelection, view.waveformRenderer.rightSelection);
		}
		
		private function onPause(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			audioProxy.pause();
		}
		
		private function onStop(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			audioProxy.stop();
		}
		
		private function onRecord(e:WaveformEvent):void {
			//trace("on record");
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			// Bug 4. 27 July 2010. AR
			// You should stop playing before you start recording.
			audioProxy.stop();
			audioProxy.record();
			// Bug 4. 17 July 2010. AR
			// You can't pause or play whilst you are recording. Disable it here, then enable once you stop recording.
			if (view.pauseButton) view.pauseButton.enabled = false;
			if (view.playButton) view.playButton.enabled = false;
			if (view.newButton) view.newButton.enabled = false;
			if (view.saveButton) view.saveButton.enabled = false;
			
			// gh#456 reset the isMp3Saved flag to false
			audioProxy.resetMap3Saved();
		}
		
		private function onSaveMP3(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			audioProxy.encodeSamplesToMP3();
		}
		
		private function onNewWave(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(view.audioProxyName) as AudioProxy;
			if (audioProxy.isMap3Saved()) {
				sendNotification(RecorderNotifications.CLEAR_WAVEFORM, null, view.audioProxyName);
			} else {
				sendNotification(BBNotifications.WARN_DATA_LOSS, null, "recording_not_saved");
			}
			
		}
		
		/*
		 * Work this out later
		 * 
		private function onLoadMP3(e:WaveformEvent):void {
			trace("onLoadMP3");
			// TODO: We have a bit of an issue here; FileReference will only load() into a ByteArray and for some crazy reason you can't load a ByteArray
			// into a Sound() and therefore can't call extract().  This means that we can't load local mp3s from FileReference on a local machine unless
			// we already know which directory it is in.
			
			// We discussed it and for the moment Adrian doesn't need this in.
			
			// It would seem sensible to let AIR do this as FileSystem.File can work fine. How to structure it?
			// v4.0.1.2 Why can't you go from here direct to AudioProxy.loadMP3?
			// Because FileReference doesn't know or tell you about folders. 
			
			// But FileSystem does although that is purely AIR. So could openMP3 go in the adaptor just like saveMP3 does?
			
			//var fileReference:FileReference = new FileReference();
			fileReference = new FileReference();
			fileReference.addEventListener(Event.SELECT, onFileReferenceSelect);
			fileReference.addEventListener(Event.CANCEL, onFileReferenceCancel);
			fileReference.addEventListener(Event.OPEN, onLoadStarted);
			fileReference.addEventListener(Event.COMPLETE, onLoadComplete);
			fileReference.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			fileReference.browse( [ new FileFilter("MP3 File", "*.mp3") ] );
		}
		private function onFileReferenceSelect(e:Event):void {
			// Ar v4.0.1.2 It seems to me that you can't completely pass the fileReference around like this.
			// as the load function never triggers any events.
			// So set it up as a class variable.
			//var fileReference:FileReference = e.target as FileReference;			
			trace("onFileReference for " + fileReference.name + ", " + fileReference.size);
			//fileReference.load();			
		}
		private function onFileReferenceCancel(e:Event):void {
			trace("cancelled");
		}
		private function onLoadStarted(e:Event):void {
			trace("started loading");
		}
		private function onLoadProgress(e:ProgressEvent):void {
			trace("progress=" + e.bytesLoaded + " of " + e.bytesTotal);
		}
		private function onLoadError(e:IOErrorEvent):void {
			trace("error loading");
		}
		private function onLoadComplete(e:Event):void {
			//var fileReference:FileReference = e.target as FileReference;
			fileReference.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			trace("loaded the file to a byteArray with " + fileReference.data.bytesAvailable);
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			audioProxy.loadMP3FromBytes(fileReference.data);
		}
		*/
		
		private function onCut(e:WaveformRangeEvent):void {
			sendNotification(RecorderNotifications.CUT_WAVEFORM, { left: e.left, right: e.right }, view.audioProxyName);
		}
		
	}
}
