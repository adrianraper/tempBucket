package com.clarityenglish.rotterdam.view.courseselector.events {
	import flash.events.Event;
	
	public class CourseCreateEvent extends Event {
		
		public static const COURSE_CREATE:String = "courseCreate";
		
		private var _caption:String;
		
		public function CourseCreateEvent(type:String, caption:String, bubbles:Boolean = false) {
			super(type, bubbles, false);
			
			this._caption = caption;
		}
		
		public function get caption():String {
			return _caption;
		}
		
		/**
		 * A course is just a set of keys and values; this creates the set for passing to the server
		 */
		public function getCourseObj():Object {
			return {
				caption: _caption
			};
		}
		
		public override function clone():Event {
			return new CourseCreateEvent(type, caption, bubbles);
		}
		
		public override function toString():String {
			return formatToString("CourseCreateEvent", "caption", "bubbles");
		}
	}
}
