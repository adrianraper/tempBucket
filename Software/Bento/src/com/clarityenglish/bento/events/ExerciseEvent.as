package com.clarityenglish.bento.events {
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.Event;
	
	public class ExerciseEvent extends Event {
		
		public static const EXERCISE_SELECTED:String = "exerciseSelected";
		
		private var _hrefFilename:String;
		
		public function ExerciseEvent(type:String, hrefFilename:String) {
			super(type, true, false);
			
			this._hrefFilename = hrefFilename;
		}
		
		public function get hrefFilename():String {
			return _hrefFilename;
		}

		public override function clone():Event {
			return new ExerciseEvent(type, _hrefFilename);
		}
		
		public override function toString():String {
			return formatToString("ExerciseEvent", "hrefFilename");
		}
		
	}
}
