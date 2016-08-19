package com.clarityenglish.resultsmanager.view.shared.events {
	import com.clarityenglish.common.vo.tests.ScheduledTest;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Clarity
	 */
	public class TestEvent extends Event {
		
		public static const UPDATE:String = "testupdate";
		public static const DELETE:String = "testdelete";
		public static const ADD:String = "testadd";
		
		public var test:ScheduledTest;
		
		public function TestEvent(type:String, test:ScheduledTest, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.test = test;
		} 
		
		public override function clone():Event { 
			return new TestEvent(type, test, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("TestEvent", "type", "testDetail", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}