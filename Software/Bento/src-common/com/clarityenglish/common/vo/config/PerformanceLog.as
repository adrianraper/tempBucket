package com.clarityenglish.common.vo.config {
	
	/**
	 * This holds login information that you want to write somewhere.
	 */
	public class PerformanceLog {
		
		public static const APP_LOADED:String = "app_loaded";

		/**
		 * Information is held in simple variables for the most part
		 */
		public var startTime:Number;
		public var endTime:Number;
		private var _IP:String;
		public var task:String;
		private var _data:String;
		
		public function PerformanceLog(task:String, startTime:Number = 0, endTime:Number = 0) {
			this.task = task;
			
			var timeStamp:Date = new Date();
			if (startTime && startTime > 0) {
				this.startTime = startTime;
			} else {
				this.startTime = timeStamp.getTime();
			}
			if (endTime && endTime > 0) {
				this.endTime = endTime;
			}
		}
		
		public function get IP():String {
			return _IP;
		}
		public function set IP(IP:String):void {
			_IP = IP;
		}
		public function get data():String {
			return _data;
		}
		public function set data(data:String):void {
			_data = data;
		}
		
		public function timeTaken():Number {
			if (this.endTime > 0 && this.startTime > 0)
				return this.endTime - this.startTime;
			
			return -1;
		}
	}
}
