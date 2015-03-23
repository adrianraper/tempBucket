package com.clarityenglish.common.events {
	
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Clarity
	 */
	public class MemoryEvent extends Event {
		
		public static const WRITE:String = "write";

		public var memory:Object;
		
		public function MemoryEvent(type:String, memory:Object, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			
			this.memory = memory;
		} 
		
		public override function clone():Event { 
			return new MemoryEvent(type, memory, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("MemoryEvent", "type", "memory", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}