package com.clarityenglish.controls.video.events {
	import com.clarityenglish.bento.vo.ExerciseMark;
	
	import flash.events.Event;
	
	public class VideoScoreEvent extends Event {
		
		public static const VIDEO_SCORE:String = "videoScore";
		
		private var _exerciseMark:ExerciseMark;
		
		public function VideoScoreEvent(type:String, exerciseMark:ExerciseMark, bubbles:Boolean = false) {
			super(type, bubbles, false);
			
			this._exerciseMark = exerciseMark;
		}
		
		public function get exerciseMark():ExerciseMark {
			return _exerciseMark;
		}
		
		public override function clone():Event {
			return new VideoScoreEvent(type, exerciseMark, bubbles);
		}
		
		public override function toString():String {
			return formatToString("VideoScoreEvent", "exerciseMark", "bubbles");
		}
		
	}
}
