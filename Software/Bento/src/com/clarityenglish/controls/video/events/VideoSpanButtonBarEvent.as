package com.clarityenglish.controls.video.events
{
	import flash.events.Event;
	
	public class VideoSpanButtonBarEvent extends Event {
		
		public static const SPANBUTTONBAR_HIDE:String = "spanButtonBarHide";
		
		private var _isHideSpanButtonBar:Boolean;
		
		public function VideoSpanButtonBarEvent(type:String, bubbles:Boolean=false, isHideSpanButtonBar:Boolean = false) {
			super(type, bubbles, isHideSpanButtonBar);
			
			this._isHideSpanButtonBar = isHideSpanButtonBar;
		}
		
		public function get isHideSpanButtonBar():Boolean {
			return _isHideSpanButtonBar;
		}
		
		public override function clone():Event {
			return new VideoSpanButtonBarEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("WidgetMenuEvent", "bubbles");
		}
	}
}