package com.clarityenglish.rotterdam.builder.view.error.events{

	import flash.events.Event;
	
	public class SaveEvent extends Event {
		
		public static const COURSE_SAVE_ERROR:String = "course_save_error";
		
		public function SaveEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event {
			return new SaveEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("SaveEvent", "bubbles", "cancelable");
		}
		
	}
	
}
