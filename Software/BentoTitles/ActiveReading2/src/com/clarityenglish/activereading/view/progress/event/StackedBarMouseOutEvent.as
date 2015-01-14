package com.clarityenglish.activereading.view.progress.event
{
	import flash.events.Event;
	
	public class StackedBarMouseOutEvent extends Event {
		
		public static const WEDGE_OUT:String = "wedgeOut";
		
		public function StackedBarMouseOutEvent(type:String, bubbles:Boolean) {
			super(type, bubbles, false);
		}
	}
}