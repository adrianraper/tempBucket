package com.clarityenglish.bento.view.warning.events {
	import flash.events.Event;
	
	public class WarningEvent extends Event {
		
		public static const YES:String = "yes";
		public static const NO:String = "no";
		
		public function WarningEvent(type:String, bubbles:Boolean = false) {
			super(type, bubbles);
		}
		
		public override function clone():Event {
			return new WarningEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("WarningEvent", "bubbles");
		}
		
	}
}