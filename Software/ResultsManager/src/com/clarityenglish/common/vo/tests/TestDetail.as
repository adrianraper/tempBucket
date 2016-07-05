package com.clarityenglish.common.vo.tests {
	import com.adobe.serialization.json.JSON;
	
	import mx.utils.ObjectUtil;
	
	import org.davekeen.utils.DateUtils;
	
	/**
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.tests.TestDetail")]
	[Bindable]
	public class TestDetail  {
		
		/**
		 * ids as keys
		 */
		public var testDetailId:String;
		public var groupId:String;
		public var testId:String;
		
		/**
		 * Caption for the test, and what language instructions should be in if possible
		 */
		public var caption:String;
		public var language:String;
		public var showResult:Boolean;
		
		/**
		 * How the test can be started and stopped
		 */
		public var startType:String;
		public var startData:String;
		private var _startTime:Date;
		private var _closeTime:Date;
		
		public function TestDetail() {}
		
		public function set closeTime(value:String):void {
			_closeTime = DateUtils.ansiStringToDate(value);
		}
		public function get closeTime():String {
			return (_closeTime) ? DateUtils.dateToAnsiString(_closeTime) : null;
		}
		public function set startTime(value:String):void {
			_startTime = DateUtils.ansiStringToDate(value);
		}
		public function get startTime():String {
			return (_startTime) ? DateUtils.dateToAnsiString(_startTime) : null;
		}
		
		public function isTestClosed():Boolean {
			return (ObjectUtil.dateCompare(_closeTime, new Date()) < 0);
		}
		public function isTestStarted():Boolean {
			return (ObjectUtil.dateCompare(_startTime, new Date()) <= 0);
		}
	}
	
}