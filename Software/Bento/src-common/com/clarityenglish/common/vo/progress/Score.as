package com.clarityenglish.common.vo.progress {

	/**
	 * @author Adrian
	 * This class is for holding progress records
	 * 
	 */
	[RemoteClass(alias = "com.clarityenglish.bento.vo.progress.Score")]
	[Bindable]
	public class Score {
		
		public var score:int;
		public var scoreCorrect:uint;
		public var scoreWrong:uint;
		public var scoreMissed:uint;
		public var coverage:uint;
		public var duration:uint;
		public var dateStamp:String;
		public var courseID:String;
		public var exerciseID:String;
		// Mirror the PHP Score object
		public var userID:String;
		public var sessionID:String;
		public var productCode:uint;
		public var unitID:String;
		public var uid:String;
		
		/**
		 * An empty constructor 
		 * @param Array data
		 * 
		 */
		public function Score() {
		}
		
	}
}