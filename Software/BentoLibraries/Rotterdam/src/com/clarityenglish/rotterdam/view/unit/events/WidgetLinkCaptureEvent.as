package com.clarityenglish.rotterdam.view.unit.events
{
	import flash.events.Event;
	
	public class WidgetLinkCaptureEvent extends Event
	{
		public static const CAPTION_SELECTED:String = "captionSelected";
		
		private var _caption:String;
		private var _urlString:String;
		
		public function WidgetLinkCaptureEvent(type:String, bubbles:Boolean, caption:String, urlString:String = "")
		{
			super(type, bubbles, false);
			
			this._caption = caption;
			this._urlString = urlString;
		}
		
		public function get caption():String {
			return this._caption;
		}
		
		public function get urlString():String {
			return this._urlString;
		}
		
		public override function clone():Event {
			return new WidgetLinkCaptureEvent(type, bubbles, caption, urlString);
		}
	}
}