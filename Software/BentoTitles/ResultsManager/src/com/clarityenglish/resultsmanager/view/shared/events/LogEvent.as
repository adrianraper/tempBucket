package com.clarityenglish.resultsmanager.view.shared.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class LogEvent extends Event {
		
		public static const NOTICE:String = "notice";
		public static const WARNING:String = "warning";
		public static const ERROR:String = "error";
		
		public var message:String;
		
		public function LogEvent(type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.message = message;
		} 
		
		public override function clone():Event { 
			return new LogEvent(type, message, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("LogEvent", "type", "message", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}