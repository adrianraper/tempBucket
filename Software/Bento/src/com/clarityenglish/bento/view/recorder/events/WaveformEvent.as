package com.clarityenglish.bento.view.recorder.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class WaveformEvent extends Event {
		
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const STOP:String = "stop";
		public static const RECORD:String = "record";
		public static const SAVE_MP3:String = "save_mp3";
		public static const LOAD_MP3:String = "load_mp3";
		public static const NEW_WAVE:String = "new_wave";
		public static const COMPARE:String = "compare";
		
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