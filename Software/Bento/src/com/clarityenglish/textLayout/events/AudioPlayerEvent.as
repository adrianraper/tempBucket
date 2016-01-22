package com.clarityenglish.textLayout.events {
	import flash.events.Event;
	
	public class AudioPlayerEvent extends Event {
		
		public static var PLAY:String = "audioplayer/play";
		public static const AUDIO_PLAYED:String = "audioPlayed";
		public static const AUDIO_PAUSED:String = "audioPaused";
		
		private var _src:String;
		
		public function AudioPlayerEvent(type:String, src:String = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			
			this._src = src;
		}
		
		public function get src():String {
			return _src;
		}
		
		public override function clone():Event {
			return new RenderFlowEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("AudioPlayerEvent");
		}
		
	}
}