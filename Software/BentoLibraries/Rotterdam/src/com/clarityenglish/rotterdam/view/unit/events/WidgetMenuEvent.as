package com.clarityenglish.rotterdam.view.unit.events {
	import flash.events.Event;
	
	public class WidgetMenuEvent extends Event {
		
		public static const MENU_SHOW:String = "menuShow";
		public static const MENU_HIDE:String = "menuHide";
		
		public function WidgetMenuEvent(type:String) {
			super(type, true, false);
		}
		
		public override function clone():Event {
			return new WidgetMenuEvent(type);
		}
		
		public override function toString():String {
			return formatToString("WidgetMenuEvent");
		}
		
	}
}
