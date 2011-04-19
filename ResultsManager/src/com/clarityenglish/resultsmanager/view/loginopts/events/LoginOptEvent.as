package com.clarityenglish.resultsmanager.view.loginopts.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class LoginOptEvent extends Event {
		
		public static const UPDATE:String = "update";
		public static const REVERT:String = "revert";
		
		public function LoginOptEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new LoginOptEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("LoginOptEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}