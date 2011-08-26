package org.davekeen.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class DKTreeEvent extends Event {
		
		public static const DATA_PROVIDER_SET:String = "data_provider_set";
		
		public function DKTreeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new DKTreeEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("DKTreeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}