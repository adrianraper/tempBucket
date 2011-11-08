package com.clarityenglish.bento.view.marking.events {
	import flash.events.Event;
	
	public class MarkingEvent extends Event {
		
		public static const TRY_AGAIN:String = "tryAgain";
		public static const SEE_ANSWERS:String = "seeAnswers";
		public static const MOVE_FORWARD:String = "moveForward";
		
		public function MarkingEvent(type:String, bubbles:Boolean = false) {
			super(type, bubbles);
		}
		
		public override function clone():Event {
			return new MarkingEvent(type, bubbles);
		}
		
		public override function toString():String {
			return formatToString("MarkingEvent", "bubbles");
		}
		
	}
}