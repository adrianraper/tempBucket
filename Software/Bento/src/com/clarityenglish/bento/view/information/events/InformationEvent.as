package com.clarityenglish.bento.view.information.events {
	import flash.events.Event;
	
	public class InformationEvent extends Event {
		
		public static const OK:String = "yes";
		
		public function InformationEvent(type:String, bubbles:Boolean = false) {
			super(type, bubbles);
		}
		
		public override function clone():Event {
			return new InformationEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("InformationEvent", "bubbles");
		}
		
	}
}