package com.clarityenglish.controls.video.events {
	import flash.events.Event;
	
	public class VideoEvent extends Event {
		
		public static const VIDEO_READY:String = "videoReady";
		public static const VIDEO_PLAYED:String = "videoPlayed";
		public static const VIDEO_PAUSED:String = "videoPaused";
		public static const VIDEO_STOPPED:String = "videoStopped";
		public static const VIDEO_COMPLETE:String = "videoComplete";
		
		public function VideoEvent(type:String, bubbles:Boolean = false) {
			super(type, bubbles, false);
		}
		
		public override function clone():Event {
			return new VideoEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("VideoEvent", "bubbles");
		}
		
	}
}
