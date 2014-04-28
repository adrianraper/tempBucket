package com.clarityenglish.rotterdam.builder.view.uniteditor.events {
	import flash.events.Event;
	
	public class AnswerDeleteEvent extends Event {
		
		public static const ANSWER_DELETE:String = "answerDelete";
		
		private var _answer:XML;
		
		public function AnswerDeleteEvent(type:String, answer:XML, bubbles:Boolean = false) {
			super(type, bubbles, false);
			
			_answer = answer;
		}
		
		public function get answer():XML {
			return _answer;
		}
		
		public override function clone():Event {
			return new AnswerDeleteEvent(type, answer, bubbles);
		}
		
		public override function toString():String {
			return formatToString("UnitDeleteEvent", "answer", "bubbles");
		}
		
	}
}
