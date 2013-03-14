package com.clarityenglish.rotterdam.view.courseselector.events {
	import flash.events.Event;
	
	public class CourseDeleteEvent extends Event {
		
		public static const COURSE_DELETE:String = "courseDelete";
		
		private var _course:XML;
		
		public function CourseDeleteEvent(type:String, course:XML, bubbles:Boolean = false) {
			super(type, bubbles, false);
			
			_course = course;
		}
		
		public function get course():XML {
			return _course;
		}
		
		public override function clone():Event {
			return new CourseDeleteEvent(type, course, bubbles);
		}
		
		public override function toString():String {
			return formatToString("UnitDeleteEvent", "course", "bubbles");
		}
		
	}
}
