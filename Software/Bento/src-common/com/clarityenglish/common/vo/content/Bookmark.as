package com.clarityenglish.common.vo.content {
	import org.davekeen.util.UIDUtil;
	
	/**
	* Bookmarks show you where you can get back to
	*/
	public class Bookmark {
		
		public var title:String;
		public var course:String;
		public var unit:String;
		public var exercise:String;

		public function Bookmark(uid:String = null) {
			if (!uid) {
				title = course = unit = exercise = null;
			} else {
				var UIDArray:Array = uid.split('.');
				if (UIDArray.length>0 && UIDArray[0]>0)
					title = UIDArray[0];
				if (UIDArray.length>1 && UIDArray[1]>0) 
					course = UIDArray[1];
				if (UIDArray.length>2 && UIDArray[2]>0) 
					unit = UIDArray[2];
				if (UIDArray.length>3 && UIDArray[3]>0) 
					exercise = UIDArray[3];
			}
		}
		
		public function get startingPoint():String { 
			if (exercise)
				return "ex:" + exercise;
			if (unit)
				return "unit:" + unit;
			return '';
		}
		
		public function get uid():String {
			var buildString:String = (title) ? title : '';
			buildString += (course) ? '.' + course : '';
			buildString += (unit) ? '.' + unit : '';
			buildString += (exercise) ? '.' + exercise : '';
			return buildString;
		}
	}
}