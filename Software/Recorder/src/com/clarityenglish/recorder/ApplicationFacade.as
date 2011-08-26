package com.clarityenglish.recorder {
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	import com.clarityenglish.recorder.model.*;
	import com.clarityenglish.recorder.view.*;
	import com.clarityenglish.recorder.controller.*;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class ApplicationFacade extends Facade implements IFacade {
		// Application name
      	public static const NAME:String = "com.clarityenglish.recorder";
		
		// The two audio proxy names (one is for recording, the other is for playback)
		public static const RECORD_PROXY_NAME:String = "record_proxy";
		public static const MODEL_PROXY_NAME:String = "model_proxy";
		
		public static const STARTUP:String = "startup";
		public static const CLOSE_RECORDER:String = "close_recorder";
		
		// Notify that the audio data has loaded
		public static const AUDIO_BYTES_READY:String = "audio_bytes_ready";
		
		// Playback notifications
		public static const PLAYHEAD_POSITION:String = "playhead_position";
		
		// Level notifications
		public static const INPUT_LEVEL:String = "input_level";
		
		// Loading notification
		public static const MP3_LOAD_START:String = "mp3_load_start";
		public static const MP3_LOAD_PROGRESS:String = "mp3_load_progress";
		public static const MP3_LOAD_COMPLETE:String = "mp3_load_complete";
		
		// Encoding notifications
		public static const WAV_ENCODE_START:String = "wav_encode_start";
		public static const WAV_ENCODE_COMPLETE:String = "wav_encode_complete";
		public static const MP3_ENCODE_START:String = "mp3_encode_start";
		public static const MP3_ENCODE_PROGRESS:String = "mp3_encode_progress";
		public static const MP3_ENCODE_COMPLETE:String = "mp3_encode_complete";
		public static const MP3_ENCODE_ERROR:String = "mp3_encode_error";
		public static const MP3_SAVE_COMPLETE:String = "mp3_save_complete";
		
		public static const CUT_WAVEFORM:String = "cut_waveform";
		
		public static const CLEAR_WAVEFORM:String = "clear_waveform";
		
		public static const RECORDING_STARTED:String = "recording_started";
		public static const RECORDING_STOPPED:String = "recording_stopped";
		
		public static const COMPARE_TO:String = "compare_to";
		public static const COMPARE_STATE:String = "compare_state";
		public static const PLAYING_COMPLETE:String = "playing_complete";
		
		public static const RELEASE_ALWAYS_ON_TOP:String = "release_always_on_top";
		
		public static const NO_MICROPHONE:String = "no_microphone";
		public static const GOT_MICROPHONE:String = "got_microphone";
		
		public function ApplicationFacade(key:String) {
			super(key);
		}
		
		public static function getInstance(key:String):ApplicationFacade {
			if (instanceMap[key] == null) instanceMap[key] = new ApplicationFacade(key);
			return instanceMap[key] as ApplicationFacade;
		}
		
		// Register commands with the controller
		override protected function initializeController():void {
			super.initializeController();
			
			registerCommand(STARTUP, StartupCommand);
			registerCommand(CUT_WAVEFORM, CutWaveformCommand);
			registerCommand(CLEAR_WAVEFORM, ClearWaveformCommand);
			registerCommand(COMPARE_TO, CompareToCommand);
			registerCommand(CLOSE_RECORDER, CloseRecorderCommand);
		}
		
	}
	
}