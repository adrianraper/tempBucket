package com.clarityenglish.rotterdam.view.settings.events {
	import flash.events.Event;
	
	public class SettingsEvent extends Event {
		
		public static const CALENDER_SETTINGS_DELETE:String = "calenderSettingsDelete";
		
		public function SettingsEvent(type:String, bubbles:Boolean) {
			super(type, bubbles, false);
		}
		
		public override function clone():Event {
			return new SettingsEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("SettingsEvent", "bubbles");
		}
		
	}
}
