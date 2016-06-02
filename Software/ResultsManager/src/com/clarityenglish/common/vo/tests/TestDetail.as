package com.clarityenglish.common.vo.tests {
	import com.adobe.serialization.json.JSON;
	
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
		private var _startConditions:String; // {"type": "code", "value": "xxxx"}
		public var startType:String;
		public var startData:String;
		public var scheduledStartTime:String;
		public var closeTime:String;
		
		public function TestDetail() {}
		
		public function set startConditions(value:String):void {
			// TODO how to catch JSON errors?
			var data:Object = JSON.decode(value);
     		this.startType = data.type
			if (data.value)
				this.startData = data.value;
		}
		public function get startConditions():String {
			var data:Object = { type: this.startType, value: this.startData };
			return JSON.encode(data);
		}
	}
	
}