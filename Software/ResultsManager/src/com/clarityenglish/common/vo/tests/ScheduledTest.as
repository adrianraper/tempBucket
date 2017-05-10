package com.clarityenglish.common.vo.tests {
	import com.clarityenglish.common.vo.Reportable;
	import com.adobe.serialization.json.JSON;
	
	import mx.utils.ObjectUtil;
	
	import org.davekeen.utils.DateUtils;
	
	/**
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.tests.ScheduledTest")]
	[Bindable]
	// gh#1523
	public class ScheduledTest extends Reportable {
		
		public static const STATUS_PRERELEASE:uint = 0;
		public static const STATUS_RELEASED:uint = 1;
		public static const STATUS_OPEN:uint = 2;
		public static const STATUS_CLOSED:uint = 3;
		public static const STATUS_DELETED:uint = 4;
		
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
		
		// ctp#214
		//public var emailInsertion:String;
		// ctp#400
		public var followUp:String;

		public var menuFilename:String;
		
		/**
		 * Status of the test to control what you can to do it
		 */
		public var status:uint;
		
		public function ScheduledTest() {}
		
		public function clone():ScheduledTest {
			var newTest:ScheduledTest = new ScheduledTest();
			newTest.testId = this.testId;
			newTest.groupId = this.groupId;
			newTest.productCode = this.productCode;
			newTest.caption = this.caption;
			newTest.language = this.language;
			newTest.showResult = this.showResult;
			newTest.startType = this.startType;
			newTest.startData = this.startData;
			newTest._openTime = this._openTime;
			newTest._closeTime = this._closeTime;
			newTest.menuFilename = this.menuFilename;
			newTest.status = this.status;
			newTest.followUp = this.followUp;
			return newTest;
		}
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
		public function isTestReleased():Boolean {
			return (status > ScheduledTest.STATUS_PRERELEASE);
		}
		public function isTestDraft():Boolean {
			return (status == ScheduledTest.STATUS_PRERELEASE);
		}
		/**
		 * Convert all times for the test into UTC for writing to the database
		 */
		public function convertTestTimesToUTC():ScheduledTest {
			var newTest:ScheduledTest = this.clone();
			newTest._openTime = this.convertToUTC(this._openTime);
			newTest._closeTime = this.convertToUTC(this._closeTime);
			return newTest;
		}
		public function convertTestTimesToLocal():ScheduledTest {
			var newTest:ScheduledTest = this.clone();
			newTest._openTime = this.convertToLocal(this._openTime);
			newTest._closeTime = this.convertToLocal(this._closeTime);
			return newTest;
		}
		private function convertToUTC(thisDate:Date):Date {
			var utcDate:Date = new Date();
			utcDate.setTime(thisDate.getTime() + (thisDate.getTimezoneOffset() * 60 * 1000));
			return utcDate;
		}
		private function convertToLocal(thisDate:Date):Date {
			var localDate:Date = new Date();
			localDate.setTime(thisDate.getTime() - (thisDate.getTimezoneOffset() * 60 * 1000));
			return localDate;
		}
		
		// Section to let scheduled test become a reportable
		/**
		 * This returns the label of the reportable to be shown in the tree (in this case the caption)
		 * Override to name.
		 */
		[Transient]
		override public function get reportableLabel():String { return caption; }
		
		//[Transient]
		//override public function get children():Array { return new Array(); }		
		//override public function set children(children:Array):void {}

		// gh#1523 Needed for reportable.toIDObject
		override public function get id():String {
			return (testId) ? testId.toString() : '';
		}
		override protected function set id(id:String):void { }
		override public function get uid():String {
			return (testId) ? testId.toString() : '';
		}
		// gh#1523 This set to protected so that json.encode works - and it is never used anyway
		override protected function set uid(value:String):void { }
		
	}	
}