package com.clarityenglish.textLayout.events {
	import flash.events.Event;
	
	public class XHTMLEvent extends Event {
		
		public static const EXTERNAL_STYLESHEETS_LOADED:String = "externalStylesheetsLoaded";
		
		public function XHTMLEvent(type:String) {
			super(type, false, false);
		}
		
		public override function clone():Event {
			return new XHTMLEvent(type);
		}
		
		public override function toString():String {
			return formatToString("XHTMLEvent");
		}
		
	}
}