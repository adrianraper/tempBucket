package com.clarityenglish.rotterdam.builder.view.uniteditor.events {
	import flash.events.Event;
	
	public class QuestionDeleteEvent extends Event {
		
		public static const QUESTION_DELETE:String = "questionDelete";
		
		private var _question:XML;
		
		public function QuestionDeleteEvent(type:String, question:XML, bubbles:Boolean = false) {
			super(type, bubbles, false);
			
			_question = question;
		}
		
		public function get question():XML {
			return _question;
		}
		
		public override function clone():Event {
			return new QuestionDeleteEvent(type, question, bubbles);
		}
		
		public override function toString():String {
			return formatToString("QuestionDeleteEvent", "question", "bubbles");
		}
		
	}
}
