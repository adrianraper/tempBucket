package com.clarityenglish.bento.view.recorder.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class RecorderEvent extends Event {
		
		public static const CHANGE_STATE:String = "recorder/change_state";
		public static const HELP:String = "recorder/help";
		public static const WEBLINK:String = "recorder/weblink";
		public static const MINIMIZE:String = "recorder/minimize";
		public static const MAXIMIZE:String = "recorder/maximize";
		public static const COMPARE:String = "recorder/compare";
		public static const SHOW:String = "recorder/show";
		// gh#456
		public static const SAVE_COMPLETE:String = "recorder/save_complete";
		// gh#1438
		public static const SAVE_ERROR:String = "recorder/save_error";

		public var data:Object;
		
		public function RecorderEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) { 
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