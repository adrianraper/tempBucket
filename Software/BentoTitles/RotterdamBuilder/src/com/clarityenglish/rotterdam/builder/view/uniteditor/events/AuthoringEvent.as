package com.clarityenglish.rotterdam.builder.view.uniteditor.events {
	import flash.events.Event;
	
	public class AuthoringEvent extends Event {
		
		public static const OPEN_SETTINGS:String = "openSettings";
		
		public function AuthoringEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event {
			return new AuthoringEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("AuthoringEvent", "type");
		}
	}
}
