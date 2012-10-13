package com.clarityenglish.controls {
	import flash.events.Event;
	
	public class BentoVideoSelectorEvent extends Event {
		
		public static const VIDEO_SELECTED:String = "videoSelected";
		
		public function BentoVideoSelectorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
	}
}
