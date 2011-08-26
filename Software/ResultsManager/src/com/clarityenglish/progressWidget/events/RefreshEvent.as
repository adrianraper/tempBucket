package com.clarityenglish.progressWidget.events {
	import flash.events.Event;
	import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * ...
	 * @author Adrian Raper
	 */
	public class RefreshEvent extends Event {
		
		public static const DATA:String = "refreshData";
		
		public function RefreshEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) { 
			//MonsterDebugger.trace(this, "new refreshEvent:" + type);
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new RefreshEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("RefreshEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}