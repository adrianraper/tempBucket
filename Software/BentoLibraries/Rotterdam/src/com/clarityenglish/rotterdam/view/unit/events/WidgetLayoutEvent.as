package com.clarityenglish.rotterdam.view.unit.events {
	import flash.events.Event;
	
	public class WidgetLayoutEvent extends Event {
		
		public static const LAYOUT_CHANGED:String = "layoutChanged";
		
		public function WidgetLayoutEvent(type:String, bubbles:Boolean) {
			super(type, bubbles, false);
		}
		
		public override function clone():Event {
			return new WidgetLayoutEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("WidgetValidateEvent", "bubbles");
		}
		
	}
}
