package com.clarityenglish.resultsmanager.view.shared.events {
	import com.clarityenglish.common.vo.tests.TestDetail;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Clarity
	 */
	public class TestDetailEvent extends Event {
		
		public static const UPDATE:String = "testdetailupdate";
		public static const DELETE:String = "testdetaildelete";
		public static const ADD:String = "testdetailadd";
		
		public var testDetail:TestDetail;
		
		public function TestDetailEvent(type:String, testDetail:TestDetail, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.testDetail = testDetail;
		} 
		
		public override function clone():Event { 
			return new TestDetailEvent(type, testDetail, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("TestDetailEvent", "type", "testDetail", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}