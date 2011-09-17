package com.clarityenglish.textLayout.events {
	import flash.events.Event;
	
	public class XHTMLEvent extends Event {
		
		public static const EXTERNAL_STYLESHEETS_LOADED:String = "externalStylesheetsLoaded";
		
		public static const TEXT_FLOW_CLEARED:String = "textFlowCleared";
		
		public function XHTMLEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, bubbles);
		}
		
		public override function clone():Event {
			return new XHTMLEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("XHTMLEvent");
		}
		
	}
}