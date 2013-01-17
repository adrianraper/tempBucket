package com.clarityenglish.common.vo.progress {

	/**
	 * 
	 * @author Adrian
	 * This class is for holding progress records
	 * 
	 */
	[RemoteClass(alias = "com.clarityenglish.bento.vo.progress.Score")]
	[Bindable]
	public class Score {
		
		public var score:int;
		public var correct:uint;
		public var wrong:uint;
		public var skipped:uint;
		public var coverage:uint;
		public var duration:uint;
		public var dateStamp:String;
		public var courseID:String;
		public var exerciseID:String;
		
		/**
		 * An empty constructor 
		 * @param Array data
		 * 
		 */
		public function Score() {
		}
		
	}
}