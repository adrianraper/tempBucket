package com.clarityenglish.bento.view.recorder.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class WaveformRangeEvent extends Event {
		
		public static const SELECT:String = "select";
		public static const CUT:String = "cut";
		
		public var left:Number;
		public var right:Number;
		
		public function WaveformRangeEvent(type:String, left:Number, right:Number, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.left = left;
			this.right = right;
		} 
		
		public override function clone():Event { 
			return new WaveformRangeEvent(type, left, right, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("WaveformRangeEvent", "type", "left", "right", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}