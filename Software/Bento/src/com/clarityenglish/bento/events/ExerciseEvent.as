package com.clarityenglish.bento.events {
	import flash.events.Event;
	
	public class ExerciseEvent extends Event {
		
		public static const EXTERNAL_STYLESHEETS_LOADED:String = "externalStylesheetsLoaded";
		
		public function ExerciseEvent(type:String) {
			super(type, false, false);
		}
		
		public override function clone():Event {
			return new ExerciseEvent(type);
		}
		
		public override function toString():String {
			return formatToString("ExerciseEvent");
		}
		
	}
}
