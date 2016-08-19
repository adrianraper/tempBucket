package com.clarityenglish.common.vo.tests {
	import com.adobe.serialization.json.JSON;
	
	import mx.utils.ObjectUtil;
	
	import org.davekeen.utils.DateUtils;
	
	/**
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.tests.ScheduledTest")]
	[Bindable]
	public class ScheduledTest  {
		
		/**
		 * ids as keys
		 */
		public var testId:String;
		public var groupId:String;
		public var productCode:String;
		
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
		private var _openTime:Date;
		private var _closeTime:Date;
		
		public function ScheduledTest() {}
		
		public function set closeTime(value:String):void {
			_closeTime = DateUtils.ansiStringToDate(value);
		}
		public function get closeTime():String {
			return (_closeTime) ? DateUtils.dateToAnsiString(_closeTime) : null;
		}
		public function set openTime(value:String):void {
			_openTime = DateUtils.ansiStringToDate(value);
		}
		public function get openTime():String {
			return (_openTime) ? DateUtils.dateToAnsiString(_openTime) : null;
		}
		
		public function isTestClosed():Boolean {
			return (ObjectUtil.dateCompare(_closeTime, new Date()) < 0);
		}
		public function isTestStarted():Boolean {
			return (ObjectUtil.dateCompare(_openTime, new Date()) <= 0);
		}
	}
	
}