package com.clarityenglish.recorder.view.waveform.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class RecorderEvent extends Event {
		
		public static const CHANGE_STATE:String = "change_state";
		public static const HELP:String = "help";
		public static const WEBLINK:String = "weblink";
		
		public var data:Object;
		
		public function RecorderEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.data = data;
		} 
		
		public override function clone():Event { 
			return new RecorderEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("RecorderEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}