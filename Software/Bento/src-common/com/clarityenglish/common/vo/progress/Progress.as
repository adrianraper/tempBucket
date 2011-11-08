package com.clarityenglish.common.vo.progress {
	import com.clarityenglish.bento.vo.Href;

	/**
	 * 
	 * @author Adrian
	 * This class is for loading and working with progress records
	 * 
	 */
	[RemoteClass(alias = "com.clarityenglish.bento.vo.progress.Progress")]
	[Bindable]
	public class Progress {
		
		// There are different types of progress records
		public static const PROGRESS_MY_SUMMARY:String = "progress_my_summary";
		public static const PROGRESS_EVERYONE_SUMMARY:String = "progress_everyone_summary";
		public static const PROGRESS_MY_DETAILS:String = "progress_my_details";
		
		//public var loadMySummary:Boolean = false;
		//public var loadEveryoneSummary:Boolean = false;
		//public var loadMyDetails:Boolean = false;
		
		private var _mySummary:Array;
		private var _everyoneSummary:Array;
		private var _myDetails:Array;
		
		public var href:Href;
		public var type:String;
		public var dataProvider:Array;
		
		/**
		 * The constructor lets you set data that has come back from the backside 
		 * @param Array data
		 * 
		 */
		public function Progress(data:Object = null) {
			//if (data.type == PROGRESS_MY_SUMMARY) {
			//	mySummary = data.dataProvider;
			//}
		}
		
		/**
		 * MySummary contains averages for me grouped by course 
		 * @return mySummary - an array that can be used as a data provider to a chart
		 * 
		 */
		public function get mySummary():Array {
			return _mySummary;
		}
		public function set mySummary(value:Array):void {
			_mySummary = value;
		}
		public function get myDetails():Array {
			return _myDetails;
		}
		public function set myDetails(value:Array):void {
			_myDetails = value;
		}
		public function get everyoneSummary():Array {
			return _everyoneSummary;
		}
		public function set everyoneSummary(value:Array):void {
			_everyoneSummary = value;
		}
	}
}