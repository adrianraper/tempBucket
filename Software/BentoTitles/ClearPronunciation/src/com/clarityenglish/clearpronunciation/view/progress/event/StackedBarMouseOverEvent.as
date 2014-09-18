package com.clarityenglish.clearpronunciation.view.progress.event
{
	import flash.events.Event;
	
	public class StackedBarMouseOverEvent extends Event {
		
		public static const WEDGE_OVER:String = "wedgeOver";
		
		private var _caption:String;
		
		public function StackedBarMouseOverEvent(type:String, bubbles:Boolean, caption:String) {
			super(type, bubbles, false);
			
			this._caption = caption;
		}
		
		public function get caption():String {
			return _caption;
		}
		
		public override function clone():Event {
			return new StackedBarMouseOverEvent(type, bubbles, caption);
		}
		
		
	}
}