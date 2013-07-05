package com.clarityenglish.bento {
	
	public class RecorderNotifications {

		// The two audio proxy names (one is for recording, the other is for playback)
		public static const RECORD_PROXY_NAME:String = "recorder/record_proxy";
		public static const MODEL_PROXY_NAME:String = "recorder/model_proxy";
		
		public static const STARTUP:String = "recorder/startup";
		public static const CLOSE_RECORDER:String = "recorder/close_recorder";
		
		// Notify that the audio data has loaded
		public static const AUDIO_BYTES_READY:String = "recorder/audio_bytes_ready";
		
		// Playback notifications
		public static const PLAYHEAD_POSITION:String = "recorder/playhead_position";
		
		// Level notifications
		public static const INPUT_LEVEL:String = "recorder/input_level";
		
		// Loading notification
		public static const MP3_LOAD_START:String = "recorder/mp3_load_start";
		public static const MP3_LOAD_PROGRESS:String = "recorder/mp3_load_progress";
		public static const MP3_LOAD_COMPLETE:String = "recorder/mp3_load_complete";
		
		// Encoding notifications
		public static const WAV_ENCODE_START:String = "recorder/wav_encode_start";
		public static const WAV_ENCODE_COMPLETE:String = "recorder/wav_encode_complete";
		public static const MP3_ENCODE_START:String = "recorder/mp3_encode_start";
		public static const MP3_ENCODE_PROGRESS:String = "recorder/mp3_encode_progress";
		public static const MP3_ENCODE_COMPLETE:String = "recorder/mp3_encode_complete";
		public static const MP3_ENCODE_ERROR:String = "recorder/mp3_encode_error";
		public static const MP3_SAVE_COMPLETE:String = "recorder/mp3_save_complete";
		
		public static const CUT_WAVEFORM:String = "recorder/cut_waveform";
		
		public static const CLEAR_WAVEFORM:String = "recorder/clear_waveform";
		
		public static const RECORDING_STARTED:String = "recorder/recording_started";
		public static const RECORDING_STOPPED:String = "recorder/recording_stopped";
		
		public static const COMPARE_TO:String = "recorder/compare_to";
		public static const COMPARE_STATE:String = "recorder/compare_state";
		public static const PLAYING_COMPLETE:String = "recorder/playing_complete";
		
		public static const RELEASE_ALWAYS_ON_TOP:String = "recorder/release_always_on_top";
		
		public static const NO_MICROPHONE:String = "recorder/no_microphone";
		public static const GOT_MICROPHONE:String = "recorder/got_microphone";
		
	}
	
}