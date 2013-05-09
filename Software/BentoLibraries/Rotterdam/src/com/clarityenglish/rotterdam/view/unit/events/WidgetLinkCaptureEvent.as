package com.clarityenglish.rotterdam.view.unit.events
{
	import flash.events.Event;
	
	public class WidgetLinkCaptureEvent extends Event
	{
		public static const LINK_CAPTURE:String = "linkCapture";
		
		private var _anchorPosition:Number;
		private var _activePosition:Number;
		
		public function WidgetLinkCaptureEvent(type:String, bubbles:Boolean, anchorPosition:Number, activePosition:Number)
		{
			super(type, bubbles, false);
			
			this._anchorPosition = anchorPosition;
			this._activePosition = activePosition;
		}
		
		public function get anchorPosition():Number {
			return this._anchorPosition;
		}
		
		public function get activePosition():Number {
			return this._activePosition;
		}
		
		public override function clone():Event {
			return new WidgetLinkCaptureEvent(type, bubbles, anchorPosition, activePosition);
		}
	}
}