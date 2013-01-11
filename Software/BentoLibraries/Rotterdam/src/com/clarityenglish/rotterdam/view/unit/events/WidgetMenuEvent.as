package com.clarityenglish.rotterdam.view.unit.events {
	import flash.events.Event;
	
	public class WidgetMenuEvent extends Event {
		
		public static const MENU_SHOW:String = "menuShow";
		public static const MENU_HIDE:String = "menuHide";
		
		public static const WIDGET_DELETE:String = "widgetDelete";
		public static const WIDGET_EDIT:String = "widgetEdit";
		
		private var _xml:XML;
		
		public function WidgetMenuEvent(type:String, bubbles:Boolean, xml:XML = null) {
			super(type, bubbles, false);
			
			this._xml = xml;
		}
		
		public function get xml():XML {
			return _xml;
		}
		
		public override function clone():Event {
			return new WidgetMenuEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("WidgetMenuEvent", "bubbles");
		}
		
	}
}
