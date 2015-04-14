package com.clarityenglish.resultsmanager.view.licence.events
{
	import flash.events.Event;
	
	public class LicenceTypeEvent extends Event
	{
		public static const LICENCE:String = "licence";
		
		public var isAAlicence:Boolean;
		
		public function LicenceTypeEvent(type:String, isAAlicence:Boolean, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.isAAlicence = isAAlicence;
		}
		
		public override function clone():Event {
			return new LicenceTypeEvent(type, isAAlicence, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("LicenceTypeEvent", "type", "isAAlicence", "title", "bubbles", "cancelable", "eventPhase");
		}
	}
}