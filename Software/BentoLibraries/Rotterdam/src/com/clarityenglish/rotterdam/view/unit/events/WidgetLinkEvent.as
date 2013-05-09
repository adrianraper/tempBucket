package com.clarityenglish.rotterdam.view.unit.events
{
	import flash.events.Event;
	
	public class WidgetLinkEvent extends Event
	{
		public static const ADD_LINK:String = "addLink";
		
		private var _text:String;
		
		public function WidgetLinkEvent(type:String, bubbles:Boolean, text:String = "")
		{
			super(type, bubbles, false);
			
			this._text = text;
		}
		
		[Bindable]
		public function get text():String {
			return this._text;
		}
		
		public function set text(value:String):void {
			_text = value;
		}
		
		public override function clone():Event {
			return new WidgetLinkEvent(type, bubbles, text);
		}
	}
}