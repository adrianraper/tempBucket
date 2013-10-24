package com.clarityenglish.rotterdam.view.courseselector.events
{
	import flash.events.Event;
	
	public class CourseSelectEvent extends Event
	{
		public static const COURSE_SELECT:String = "courseSelect";
		
		public function CourseSelectEvent(type:String, bubbles:Boolean = false) {
			super(type, bubbles, false);
		}
		
		public override function clone():Event {
			return new CourseSelectEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("CourseSelectEvent", "bubbles");
		}
	}
}