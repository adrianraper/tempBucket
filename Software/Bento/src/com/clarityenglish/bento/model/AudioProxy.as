/*
Proxy - PureMVC
*/
package com.clarityenglish.bento.model {
	import com.adobe.audio.format.WAVWriter;
	import com.clarityenglish.bento.RecorderNotifications;
	import com.clarityenglish.bento.model.adaptor.IRecorderAdaptor;
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.vo.config.BentoError;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	import fr.kikko.lab.ShineMP3Encoder;

	import org.davekeen.util.PlayerUtils;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.observer.Notifier;
	import org.puremvc.as3.patterns.proxy.Proxy;

    // gh#1556 Flex SDK does not include these, but needed by AIR SDK.
    // So you must comment them out, and the code that uses them when compiling a swf for browser use
    //import flash.events.PermissionEvent;
    //import flash.permissions.PermissionStatus;

	/**
	 * A proxy
	 */
	public class AudioProxy extends Proxy implements IProxy {

		public static const SAMPLE_RATE:Number = 44100;
        public static const MICROPHONE_RATE:uint = 44;

		/**
		 * Certain functions happen differently in the AIR or the web version; the IRecorderAdaptor provides an adaptor such that we can treat both
		 * versions of the application in the same way.  This is passed into the constructor of the proxy.
		 */
		private var recorderAdaptor:IRecorderAdaptor;
		
		/**
		 * The sample data in float format, 4 bytes per sample (2 bytes for float left, 2 bytes for float right)
		 */
		[Bindable]
		public var samples:ByteArray;

		/**
		 * The sound object
		 */
		private var sound:Sound;
		
		/**
		 * The sound channel object for the current playback
		 */
		private var soundChannel:SoundChannel;
		
		/**
		 * The current position of the playhead in samples
		 */
		private var currentSamplesPosition:Number = 0;
		
		/**
		 * The microphone that this proxy records from
		 */
		private var microphone:Microphone;
		
		/**
		 * Whether or not we are currently recording in this proxy
		 */
		private var isRecording:Boolean;
		
		/**
		 * Whether or not we are currently playing in this proxy
		 */
		private var isPlaying:Boolean;
		
		/**
		 * Whether or not the sound is currently paused
		 */
		private var isPaused:Boolean;

		private var isSeek:Boolean;
		
		/**
		 * A temporary fix to get around a problem with the display head rendering in the wrong place after a pause.  If the user has paused
		 * the sound at least once this is set to true (in which case the playback head is no longer drawn), and it is reset to false either
		 * at the end of the sound or when the user presses stop.
		 */
		private var suppressPlayheadNotifications:Boolean;
		
		/**
		 * Stop playing the sound when we reach a certain position (used when playing a selection)
		 */
		private var stopPlayingAtSample:Number;
		
		/**
		 * Proxies can be record enabled or not (configured in the constructor)
		 */
		private var _recordEnabled:Boolean;
		private var _saveThisPlease:Boolean;
		
		// gh#456
		[Bindable]
		private var _isMp3Saved:Boolean;
		
		public function isMap3Saved():Boolean {
			return _isMp3Saved;
		}
		
		public function resetMap3Saved():void {
			_isMp3Saved = false;
		}
		
		public function isRecordEnabled():Boolean { return _recordEnabled; }
		public var audioStatus:String;
		
		public function AudioProxy(name:String, recordEnabled:Boolean = false, recorderAdaptor:IRecorderAdaptor = null) {
			super(name);
			
			_recordEnabled = recordEnabled;
			this.recorderAdaptor = recorderAdaptor;
		}
		
		override public function onRegister():void {
            super.onRegister();

            // Initialize the samples to an empty bytearray
            samples = new ByteArray();

            // Initialize the sound
            sound = new Sound();
            sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSoundSampleData);

            // If this proxy is record enabled then setup the default microphone
            if (isRecordEnabled() && Microphone.isSupported) {
                // v4.0.1.2 But -1 is the default microphone, 0 is simply the
                // gh#1438 Is there a better microphone than the default?
                //setMicrophone(0);
                setTimeout(function():void {
                    var rc:Boolean = setMicrophone();
                }, 500);
            }
        }

		private function microphoneStatusHandler(e:StatusEvent):void {
			trace("micStatusEvent " + e.code + " mic is " + getMicrophoneName());
			if (e.code == "Microphone.Muted") {
				sendNotification(RecorderNotifications.NO_MICROPHONE);
				//throw new Error("You have blocked the Recorder from using your microphone. Please use Settings to clear this.");
				//Security.showSettings(SecurityPanel.PRIVACY);
                _recordEnabled = false;
			} else if (e.code == "Microphone.Unmuted") {
				sendNotification(RecorderNotifications.GOT_MICROPHONE);
                _recordEnabled = true;
			}
		}
		
		/**
		 * The sound object never actually contains any data - this injects samples from the samples bytearray into the sound object as it plays instead.
		 * 
		 * @param	e
		 */
		private function onSoundSampleData(e:SampleDataEvent):void {
			if (soundChannel)
				sendNotification(RecorderNotifications.PLAYHEAD_POSITION, {playHeadPosition: (suppressPlayheadNotifications) ? -1 : msToSamplePosition(soundChannel.position), samplePosition: currentSamplesPosition}, getProxyName());
			
			// If we have reached stopPlayingAtSample (used when playing a selection) then stop playing
			if (stopPlayingAtSample > 0 && currentSamplesPosition >= stopPlayingAtSample) {
				//audioStatus = "stopPlayingAtSample=" + stopPlayingAtSample;
				stop();
				return;
			}
			
			// Since other parts of the application can change the position within the byte array ensure we are in the right place for playback here
			samples.position = currentSamplesPosition;
			
			for (var n:uint = 0; n < 4096; n++) {
				if (samples.bytesAvailable > 0) {
					e.data.writeFloat(samples.readFloat());
					e.data.writeFloat(samples.readFloat());
				}
			}
			
			// And update the position variable ready for the next onSoundSampleData block
			currentSamplesPosition = samples.position;
		}
		
		/**
		 * Load the given mp3 and extract the samples once it is loaded
		 * 
		 * @param	filename
		 */
		public function loadMP3(filename:String):void {
			//trace("loadMP3 for " + filename);
			sendNotification(RecorderNotifications.MP3_LOAD_START);
			
			var loadSound:Sound = new Sound();
			loadSound.addEventListener(Event.COMPLETE, onLoadMP3Complete);
			loadSound.addEventListener(ProgressEvent.PROGRESS, onLoadMP3Progress);
			loadSound.load(new URLRequest(filename));
		}
		
		private function onLoadMP3Progress(e:ProgressEvent):void {
			sendNotification(RecorderNotifications.MP3_LOAD_PROGRESS, { bytesLoaded: e.bytesLoaded, bytesTotal: e.bytesTotal } );
		}
		
		private function onLoadMP3Complete(e:Event):void {
			var loadSound:Sound = e.currentTarget as Sound;
			
			// Extract the audio into the bytearray
			samples = new ByteArray();
			loadSound.extract(samples, Math.floor(loadSound.length / 1000 * SAMPLE_RATE));
			
			sendNotification(RecorderNotifications.MP3_LOAD_COMPLETE);
			
			// Send a notification that the bytearray has been filled with the audio data
			sendNotification(RecorderNotifications.AUDIO_BYTES_READY, samples, getProxyName());
		}
		
		// This is all guesswork from Adrian. How to get the byteArray into the correct format?
		/*
		public function loadMP3FromBytes(samples:ByteArray):void {
			
			sendNotification(ApplicationFacade.MP3_LOAD_COMPLETE);
			
			// See http://www.flexiblefactory.co.uk/flexible/?p=46 for an example
			var samplesAsMP3:ByteArray = manipulateByteArray(samples);
			
			// Send a notification that the bytearray has been filled with the audio data
			sendNotification(ApplicationFacade.AUDIO_BYTES_READY, samplesAsMP3, getProxyName());			
		}
		*/
		
		/**
		 * Encode the samples as an MP3 using alchemy Shine, by converting to a temporary WAV on the way.  All references are weak so this holds no references
		 * and shouldn't leak memory.
		 */
		public function encodeSamplesToMP3():void {
			// Stop playback or record before encoding otherwise the AVM will grind to an unpleasant halt
			stop();
			
			if (!samples || samples.length == 0)
				throw new Error("Attempted to encode mp3 when there was no sample data loaded.");
			
			sendNotification(RecorderNotifications.WAV_ENCODE_START);
			
			// This is something of a hack, but we need to wait for the screen to refresh to the 'Encoding WAV', and the alternative to a simple 500ms timeout
			// is passing back callLater notifications from the mediator which will be very confusing.
			setTimeout(encodeWav, 500);
		}
		
		public function encodeWav():void {
			var wavByteArray:ByteArray = new ByteArray();
			
			// First write the samples data into wav format
			samples.position = 0;
			new WAVWriter().processSamples(wavByteArray, samples, 44100, 2);
			
			sendNotification(RecorderNotifications.WAV_ENCODE_COMPLETE);
			
			sendNotification(RecorderNotifications.MP3_ENCODE_START);
			
			wavByteArray.position = 0;
			var mp3Encoder:ShineMP3Encoder = new ShineMP3Encoder(wavByteArray);
			mp3Encoder.addEventListener(Event.COMPLETE, mp3EncodeComplete);
			mp3Encoder.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
			mp3Encoder.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
			mp3Encoder.start();
		}

		private function mp3EncodeProgress(e:ProgressEvent) : void {			
			sendNotification(RecorderNotifications.MP3_ENCODE_PROGRESS, { bytesLoaded: e.bytesLoaded, bytesTotal: e.bytesTotal }, getProxyName());
		}

		private function mp3EncodeError(e:ErrorEvent) : void {				
			sendNotification(RecorderNotifications.MP3_ENCODE_ERROR, e.text, getProxyName());
		}

		private function mp3EncodeComplete(e:Event) : void {		
			sendNotification(RecorderNotifications.MP3_ENCODE_COMPLETE, e.currentTarget.mp3Data, getProxyName());
			
			// If this is an AIR application we can call saveMP3Data directly, otherwise we count on a mediator to listen for MP3_ENCODE_COMPLETE and popup
			// a window to then call saveMP3Data (to get around the click/popup security restriction).
			if (PlayerUtils.isAirApplication())
				saveMP3Data(e.currentTarget.mp3Data);
		}
		
		public function saveMP3Data(mp3Data:ByteArray):void {
			// Can I listen for the events generated in the adaptor here? Not like this you can't. How to get the adaptor to extend EventDispatcher?
			//recorderAdaptor.addEventListener(Event.SELECT, mp3SaveComplete);
			//recorderAdaptor.addEventListener(Event.CANCEL, mp3SaveComplete);
			recorderAdaptor.saveMp3Data(mp3Data, null);
			// gh#456
			recorderAdaptor.addEventListener(RecorderEvent.SAVE_COMPLETE, onSaveComplete);
            // gh#1348
			recorderAdaptor.addEventListener(RecorderEvent.SAVE_ERROR, onSaveError);
		}
		
		protected function onSaveComplete(event:RecorderEvent):void {
			// gh#456
			_isMp3Saved = true;
		}
        // gh#1348
		protected function onSaveError(event:RecorderEvent):void {
            var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
            var thisError:BentoError = copyProxy.getBentoErrorForId("errorCantSaveFile", { message: event.data.type + " " + event.data.text }, false);
            sendNotification(CommonNotifications.BENTO_ERROR, thisError, "warning");
		}
		
		private function mp3SaveComplete(e:Event) : void {
			// In order to switch off alwaysInFront, send a notification back to the mediator
			sendNotification(RecorderNotifications.MP3_SAVE_COMPLETE, true, getProxyName());	
		}
		
		/**
		 * Start playing the sound from the current position
		 */
		public function play(left:Number = -1, right:Number = -1):void {
			if (samples.length == 0) return;

			// Stop the sound if it is currently playing (and we are not paused)
			if (soundChannel && !isPaused)
				stop();
			
			// If a section was given just play that
			if (left != right && left >= 0 && right >= 0) {
				suppressPlayheadNotifications = true; // Don't show the playhead when playing a selection
				currentSamplesPosition = sanitizeSamplePosition(left) * 4;
				stopPlayingAtSample = sanitizeSamplePosition(right) * 4;
			}
			
			samples.position = currentSamplesPosition;

			soundChannel = sound.play();

			isPlaying = true;
			isPaused = false;
			isSeek = false;
			soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundChannelComplete, false, 0, true);
		}
		
		public function pause():void {
			if (soundChannel) {
				if (isPaused && !isSeek) {
					trace("I am paused, so start playing again");
					// Unpause
					play();
				} else {
					// Pause
					soundChannel.stop();
					currentSamplesPosition = (samples.position - (samples.position % 4096));
					suppressPlayheadNotifications = isPaused = true;
					isPlaying = false;
				}
			}
		}
		
		/**
		 * Stop playing the sound
		 */
		public function stop():void {
			if (soundChannel) {
				soundChannel.stop();
				currentSamplesPosition = stopPlayingAtSample = 0;
				suppressPlayheadNotifications = isPlaying = isPaused = false;
				sendNotification(RecorderNotifications.PLAYHEAD_POSITION, {playHeadPosition: -1}, getProxyName());
				// Bug 16. 17 July 2010. AR
				// When you stop the play, this has the same impact as playing complete.
				// But you can't do this here as it screws up regular play. I don't know why.
				//sendNotification(ApplicationFacade.PLAYING_COMPLETE, null, getProxyName());
			}

			// Stop recording if we were recording
			if (microphone && isRecording) {
				isRecording = false;
				sendNotification(RecorderNotifications.RECORDING_STOPPED, samples.length, getProxyName());
			}
			
			// Stop listening
			if (microphone) microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onMicrophoneSampleData);
		}

		// For scrub bar in recorder playback skin. Seeking the audio play position when drag the scrub bar button
		public function seek(time:Number):void {
			isSeek = true;
			pause();
			samples.position = time;
		}
		
		/**
		 * If the sound plays to the end then stop the playback, reset the timer and dispatch an event to hide the playhead
		 * 
		 * @param	e
		 */
		private function onSoundChannelComplete(e:Event):void {
			soundChannel.stop();
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundChannelComplete);
			currentSamplesPosition = 0;
			suppressPlayheadNotifications = isPlaying = isPaused = false;
			sendNotification(RecorderNotifications.PLAYHEAD_POSITION, {playHeadPosition: -1}, getProxyName());
			// v3.4 Also tell anyone else that the sound finished playing
			//trace("audio proxy playing complete");
			sendNotification(RecorderNotifications.PLAYING_COMPLETE, null, getProxyName());
		}
		
		/**
		 * Configure the microphone. Must switch this to different version if using Flex SDK not AIR SDK
		 * 
		 * @param	idx
		 */
        public function setMicrophone():Boolean {
            try {
                microphone = Microphone.getMicrophone();
                trace("set microphone, Microphone.names=" + Microphone.names.toString() + " microphone.name=" + microphone.name + " muted=" + microphone.muted);
                // v4.0.1.2 Error checking
                if (!Microphone.isSupported || microphone == null) {
                    _recordEnabled = false;
                    // gh#1464 This notification has no effect as mediator not complete yet
                    // when this is called from onRegister
                    //sendNotification(RecorderNotifications.NO_MICROPHONE);
                    //Security.showSettings(SecurityPanel.MICROPHONE);
                } else {
                    // gh#530
                    // gh#1464 Even a muted microphone needs a status handler in case the user unmutes it
                    if (!microphone.hasEventListener(StatusEvent.STATUS))
                        microphone.addEventListener(StatusEvent.STATUS, microphoneStatusHandler);
                    microphone.setSilenceLevel(0);
                    // gh#1438
                    microphone.rate = MICROPHONE_RATE;
                    if (microphone.muted)
                        Security.showSettings(SecurityPanel.MICROPHONE);
                    _recordEnabled = (!microphone.muted);
                }
            } catch (e:Error) {
                _recordEnabled = false;
            }
            return _recordEnabled;
        }

		public function record(clearWaveform:Boolean = false):void {
            // gh#1438 Check that the mic has not been denied since we first started
            // and also it might have been allowed, but not properly initialised
            if (!setMicrophone())
                return;

			// If we are recording then pressing record stops the recording
			if (isRecording) {
				stop();
				return;
			}
			
			// Start listening
			microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onMicrophoneSampleData);
			microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onMicrophoneSampleData);
			
			// If clear waveform is true then clear the wave
			if (clearWaveform)
				sendNotification(RecorderNotifications.CLEAR_WAVEFORM, null, getProxyName());
			
			// Ensure the views are watching the current sample data
			sendNotification(RecorderNotifications.AUDIO_BYTES_READY, samples, getProxyName());
			
			// Start recording
			isRecording = true;
			isPlaying = false;
			isPaused = false;
			
			sendNotification(RecorderNotifications.RECORDING_STARTED, null, getProxyName());
		}
		
		/**
		 * When we receive microphone data we need to add it onto the end of the sample data.  Since our microphone is going to be mono, and the sample data
		 * is stereo we need to write each float twice onto the end of the sample bytearray.
		 * 
		 * @param	e
		 */
		private function onMicrophoneSampleData(e:SampleDataEvent):void {
			if (isPlaying) return; // We don't record or send INPUT_LEVEL when playing back
			
			var newSamples:ByteArray = e.data;
			newSamples.position = 0;
			
			// If we are recording set the main samples bytearray position to the end ready to receive the new data
			if (isRecording)
				samples.position = samples.length;
			
			// Use these to calculate the average level (to display on the level meter)
			var totalLevel:Number = 0;
			var totalSamples:Number = newSamples.bytesAvailable / 8;
			
			while (newSamples.bytesAvailable > 0) {
				var amplitude:Number = newSamples.readFloat();
				
				totalLevel += Math.abs(amplitude);
				
				// If we are recording write the sound data into the main samples byte array
				if (isRecording) {
					samples.writeFloat(amplitude);
					samples.writeFloat(amplitude);
				}
			}
			
			sendNotification(RecorderNotifications.INPUT_LEVEL, Math.abs(totalLevel / totalSamples), getProxyName());
		}
		
		private function sanitizeSamplePosition(position:Number):Number {
			return Math.round(position) + (Math.round(position) % 4);
		}
		
		public function cutWaveform(leftSelection:Number, rightSelection:Number):void {
			leftSelection = sanitizeSamplePosition(leftSelection);
			rightSelection = sanitizeSamplePosition(rightSelection);
			
			samples.position = leftSelection * 4;
			
			var newSamples:ByteArray = new ByteArray();
			newSamples.position = 0;
			
			// First write the existing samples up to the leftSelection, then write from rightSelection to the end
			newSamples.writeBytes(samples, 0, leftSelection * 4);
			newSamples.writeBytes(samples, rightSelection * 4, samples.length - rightSelection * 4);
			
			// Replace samples with our new version
			samples = newSamples;
			
			// Let the application know that the sample has changed
			sendNotification(RecorderNotifications.AUDIO_BYTES_READY, samples, getProxyName());
		}
		
		public function clearWaveform():void {
			samples = new ByteArray();
			
			// Let the application know that the sample has changed
			sendNotification(RecorderNotifications.AUDIO_BYTES_READY, samples, getProxyName());
		}
		
		/**
		 * Convert millisecond position to position in samples
		 * 
		 * @param	msPosition
		 * @return
		 */
		private function msToSamplePosition(msPosition:Number):Number {
			return msPosition * SAMPLE_RATE / 1000 * 2;
		}

		// For debugging
		public function getMicrophoneInfo():String {
			return "codec=" + microphone.codec + "\n" + "rate=" + microphone.rate;
		}
        public function getMicrophoneRate():uint { return (microphone) ? microphone.rate : 0; }
        public function getMicrophoneName():String { return microphone.name; }
        public function hasMicrophone():Boolean { return (microphone != null); }
        public function hasMicrophones():Boolean { return (Microphone.names.length > 0); }
        public function isMicrophoneMuted():Boolean { return (microphone.muted); }
    }
}