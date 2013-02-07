package com.clarityenglish.rotterdam.view.courseselector.events
{
	import flash.events.Event;
	
	public class CourseDeleteEvent extends Event
	{		
		public static const COURSE_DELETE:String = "courseDelete";
		
		public function CourseDeleteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}