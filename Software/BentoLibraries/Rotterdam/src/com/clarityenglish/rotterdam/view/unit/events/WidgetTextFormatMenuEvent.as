package com.clarityenglish.rotterdam.view.unit.events {
	import flash.events.Event;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
	public class WidgetTextFormatMenuEvent extends Event {
		
		public static const TEXT_SELECTED:String = "textSelected";
		
		private var _format:TextLayoutFormat;
		
		public function WidgetTextFormatMenuEvent(type:String, bubbles:Boolean, format:TextLayoutFormat = null) {
			super(type, bubbles, false);
			
			this._format = format;
		}
		
		public function get format():TextLayoutFormat {
			return _format;
		}
		
		public override function clone():Event {
			return new WidgetTextFormatMenuEvent(type, bubbles, format);
		}
		
		public override function toString():String {
			return formatToString("WidgetTextFormatMenuEvent", "bubbles");
		}
		
	}
}
