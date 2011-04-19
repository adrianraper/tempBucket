/*
 Mediator - PureMVC
 */
package com.clarityenglish.recorder.view.waveform {
	import com.clarityenglish.recorder.ApplicationFacade;
	import com.clarityenglish.recorder.model.AudioProxy;
	import com.clarityenglish.recorder.view.waveform.events.WaveformEvent;
	import com.clarityenglish.recorder.view.waveform.events.WaveformRangeEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	import com.clarityenglish.recorder.view.waveform.components.WaveformView;
	import com.clarityenglish.recorder.view.waveform.*;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * A Mediator
	 */
	public class WaveformMediator extends Mediator implements IMediator {
		
		// The name of the audio proxy that drives this waveform view
		private var audioProxyName:String;
		
		//private var mp3FileReference:FileReference;
		private var fileReference:FileReference;
		
		public function WaveformMediator(viewComponent:Object, audioProxyName:String) {
			// Since we have multiple waveform mediators in a single application construct its unique name out of NAME, the linked proxy and a counter
			// to ensure we don't end up with mediators with the same name.
			super(audioProxyName + "Mediator", viewComponent);
			
			this.audioProxyName = audioProxyName;
		}
		
		private function get waveformView():WaveformView {
			return viewComponent as WaveformView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			waveformView.addEventListener(WaveformEvent.PLAY, onPlay);
			waveformView.addEventListener(WaveformEvent.PAUSE, onPause);
			waveformView.addEventListener(WaveformEvent.STOP, onStop);
			waveformView.addEventListener(WaveformEvent.RECORD, onRecord);
			waveformView.addEventListener(WaveformEvent.SAVE_MP3, onSaveMP3);
			//waveformView.addEventListener(WaveformEvent.LOAD_MP3, onLoadMP3);
			waveformView.addEventListener(WaveformEvent.NEW, onNew);
			
			waveformView.addEventListener(WaveformRangeEvent.CUT, onCut);
			
			// Inject variables into the view
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			waveformView.isRecordEnabled = audioProxy.isRecordEnabled();
			waveformView.sampleRate = AudioProxy.SAMPLE_RATE;
			// v4.0.1.1 Small step to help trouble shoot
			// which microphone are we recording from?
			if (waveformView.isRecordEnabled) {
				waveformView.microphoneName = audioProxy.getMicrophoneName();
				waveformView.audioStatus = audioProxy.audioStatus;
			}
			
			// Prepare the view
			prepareView();
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			waveformView.removeEventListener(WaveformEvent.PLAY, onPlay);
			waveformView.removeEventListener(WaveformEvent.PAUSE, onPause);
			waveformView.removeEventListener(WaveformEvent.STOP, onStop);
			waveformView.removeEventListener(WaveformEvent.RECORD, onRecord);
			waveformView.removeEventListener(WaveformEvent.SAVE_MP3, onSaveMP3);
			//waveformView.removeEventListener(WaveformEvent.LOAD_MP3, onLoadMP3);
			waveformView.removeEventListener(WaveformEvent.NEW, onNew);
			
			waveformView.removeEventListener(WaveformRangeEvent.CUT, onCut);
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
					ApplicationFacade.AUDIO_BYTES_READY,
					ApplicationFacade.PLAYHEAD_POSITION,
					ApplicationFacade.INPUT_LEVEL,
					ApplicationFacade.RECORDING_STARTED,
					ApplicationFacade.RECORDING_STOPPED,
					ApplicationFacade.CLEAR_WAVEFORM,
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
				case ApplicationFacade.AUDIO_BYTES_READY:
					prepareView();
					break;
				case ApplicationFacade.PLAYHEAD_POSITION:
					if (note.getType() == audioProxyName)
						waveformView.waveformRenderer.playheadPosition = note.getBody() as Number;
					break;
				case ApplicationFacade.INPUT_LEVEL:
					if (note.getType() == audioProxyName)
						waveformView.levelMeter.data = note.getBody();
					break;
				case ApplicationFacade.RECORDING_STARTED:
					if (note.getType() == audioProxyName) {
						waveformView.waveformRenderer.recording = true;
						
						waveformView.mp3FileSizeText = "Recording...";
						waveformView.durationText = "";
					}
					break;
				case ApplicationFacade.RECORDING_STOPPED:
					//trace("waveformMediator." + note.getName());
					if (note.getType() == audioProxyName) {
						waveformView.waveformRenderer.recording = false;
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
							waveformView.pauseButton.enabled = true;
							waveformView.playButton.enabled = true;
							//trace("set play button on later");
						}

					}
					break;
				case ApplicationFacade.CLEAR_WAVEFORM:
					if (note.getType() == audioProxyName) {
						waveformView.reset();
						updateMp3Info();
					}
					break;
				default:
					break;
			}
		}
		
		private function prepareView():void {
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			waveformView.samples = audioProxy.samples;
			
			updateMp3Info();
		}
		
		private function updateMp3Info():void {
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			
			waveformView.mp3FileSizeText = (audioProxy.samples) ? "MP3 file size " + Math.round(audioProxy.samples.length / 22000) + "kb" : "-";
			var duration:String = ((audioProxy.samples.length / AudioProxy.SAMPLE_RATE / 8) as Number).toFixed(1);
			waveformView.durationText = (audioProxy.samples) ? "Duration " + duration + "s" : "-";
		}
		
		private function onPlay(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			trace(waveformView.waveformRenderer.leftSelection + "-" +  waveformView.waveformRenderer.rightSelection);
			audioProxy.play(waveformView.waveformRenderer.leftSelection, waveformView.waveformRenderer.rightSelection);
		}
		
		private function onPause(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			audioProxy.pause();
		}
		
		private function onStop(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			audioProxy.stop();
		}
		
		private function onRecord(e:WaveformEvent):void {
			//trace("on record");
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			// Bug 4. 27 July 2010. AR
			// You should stop playing before you start recording.
			audioProxy.stop();
			audioProxy.record();
			// Bug 4. 17 July 2010. AR
			// You can't pause or play whilst you are recording. Disable it here, then enable once you stop recording.
			waveformView.pauseButton.enabled = false;
			waveformView.playButton.enabled = false;
		}
		
		private function onSaveMP3(e:WaveformEvent):void {
			var audioProxy:AudioProxy = facade.retrieveProxy(audioProxyName) as AudioProxy;
			audioProxy.encodeSamplesToMP3();
		}
		
		private function onNew(e:WaveformEvent):void {
			sendNotification(ApplicationFacade.CLEAR_WAVEFORM, null, audioProxyName);
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
			sendNotification(ApplicationFacade.CUT_WAVEFORM, { left: e.left, right: e.right }, audioProxyName);
		}
		
	}
}
