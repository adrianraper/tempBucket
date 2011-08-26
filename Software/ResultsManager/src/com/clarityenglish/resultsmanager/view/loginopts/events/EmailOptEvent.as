package com.clarityenglish.resultsmanager.view.loginopts.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class EmailOptEvent extends Event {
		
		public static const UPDATE:String = "emailoptupdate";
		public static const REVERT:String = "emailoptrevert";
		
		public function EmailOptEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new EmailOptEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("EmailOptEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}