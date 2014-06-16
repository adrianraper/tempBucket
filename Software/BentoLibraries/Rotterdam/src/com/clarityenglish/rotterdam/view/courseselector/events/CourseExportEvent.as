package com.clarityenglish.rotterdam.view.courseselector.events {
	import flash.events.Event;
	
	public class CourseExportEvent extends Event {
		
		public static const COURSE_DELETE:String = "courseExport";
		
		private var _course:XML;
		
		public function CourseExportEvent(type:String, course:XML, bubbles:Boolean = false) {
			super(type, bubbles, false);
			
			_course = course;
		}
		
		public function get course():XML {
			return _course;
		}
		
		public override function clone():Event {
			return new CourseExportEvent(type, course, bubbles);
		}
		
		public override function toString():String {
			return formatToString("CourseExportEvent", "course", "bubbles");
		}
		
	}
}
