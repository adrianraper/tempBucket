package com.clarityenglish.recorder.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class AIRWindowEvent extends Event {
		
		public static const SET_ALWAYS_IN_FRONT:String = "set_always_in_front";
		public static const RELEASE_ALWAYS_IN_FRONT:String = "release_always_in_front";
		
		public function AIRWindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new AIRWindowEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("AIRWindowEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}