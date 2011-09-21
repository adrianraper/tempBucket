package com.clarityenglish.bento.view.base.events {
	import flash.events.Event;
	
	public class BentoEvent extends Event {
		
		public static const HREF_CHANGED:String = "hrefChanged";
		
		public function BentoEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event {
			return new BentoEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("BentoEvent", "bubbles", "cancelable");
		}
		
	}
	
}
