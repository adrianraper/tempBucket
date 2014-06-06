package com.clarityenglish.rotterdam.view.unit.events {
	import flash.events.Event;
	
	public class WidgetMenuEvent extends Event {
		
		public static const MENU_SHOW:String = "menuShow";
		public static const MENU_HIDE:String = "menuHide";
		
		public static const WIDGET_DELETE:String = "widgetDelete";
		public static const WIDGET_EDIT:String = "widgetEdit";
		//gh#187
		public static const WIDGET_RENAME:String = "widgetRename";
		
		private var _xml:XML;
		private var __hideSpanButtonBar:Boolean;
		
		public function WidgetMenuEvent(type:String, bubbles:Boolean, xml:XML = null, hideSpanButtonBar = false) {
			super(type, bubbles, false);
			
			this._xml = xml;
			this.__hideSpanButtonBar = hideSpanButtonBar;
		}
		
		public function get xml():XML {
			return _xml;
		}
		
		// hiding span button bar for youku video
		public function get hideSpanButtonBar():Boolean {
			return __hideSpanButtonBar;
		}
		
		public override function clone():Event {
			return new WidgetMenuEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("WidgetMenuEvent", "bubbles");
		}
		
	}
}
