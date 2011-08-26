package com.clarityenglish.recorder.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ResizeWindowEvent extends Event {
		
		public static const RESIZE_HEIGHT_BY_RATIO:String = "resize_height_by_ratio";
		
		public var ratio:Number;
		
		public function ResizeWindowEvent(type:String, ratio:Number, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.ratio = ratio;
		} 
		
		public override function clone():Event { 
			return new ResizeWindowEvent(type, ratio, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ResizeWindowEvent", "type", "ratio", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}