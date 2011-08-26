package com.clarityenglish.recorder.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class PartEvent extends Event {
		
		public static const PART_ADDED:String = "part_added";
		public static const PART_REMOVED:String = "part_removed";
		
		public var partName:String;
		public var instance:Object;
		
		public function PartEvent(type:String, partName:String, instance:Object, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.partName = partName;
			this.instance = instance;
		} 
		
		public override function clone():Event { 
			return new PartEvent(type, partName, instance, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("PartEvent", "type", "partName", "instance", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}