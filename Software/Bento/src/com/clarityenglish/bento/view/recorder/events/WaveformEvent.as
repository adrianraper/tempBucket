package com.clarityenglish.bento.view.recorder.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class WaveformEvent extends Event {
		
		public static const PLAY:String = "waveform/play";
		public static const PAUSE:String = "waveform/pause";
		public static const STOP:String = "waveform/stop";
		public static const RECORD:String = "waveform/record";
		public static const SAVE_MP3:String = "waveform/save_mp3";
		public static const LOAD_MP3:String = "waveform/load_mp3";
		public static const NEW_WAVE:String = "waveform/new_wave";
		// For scrub bar in playback skin
		public static const SEEK:String = "waveform/seek";
		
		public function WaveformEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new WaveformEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("WaveformEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}