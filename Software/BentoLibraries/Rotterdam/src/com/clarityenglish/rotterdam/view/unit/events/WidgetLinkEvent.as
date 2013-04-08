package com.clarityenglish.rotterdam.view.unit.events
{
	import flash.events.Event;
	
	public class WidgetLinkEvent extends Event
	{
		public static const ADD_LINK:String = "addLink";
		
		public function WidgetLinkEvent(type:String, bubbles:Boolean)
		{
			super(type, bubbles);
		}
	}
}