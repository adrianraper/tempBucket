package com.clarityenglish.bento.view.xhtmlexercise.events {
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.bento.vo.content.model.Question;
	
	import flash.events.Event;
	
	public class SectionEvent extends Event {
		
		public static const QUESTION_ANSWERED:String = "questionAnswered";
		
		private var _question:Question;
		private var _answer:Answer;
		
		public function SectionEvent(type:String, question:Question, answer:Answer, bubbles:Boolean = false) {
			super(type, bubbles);
			
			this._question = question;
			this._answer = answer;
		}
		
		public function get question():Question {
			return _question;
		}
		
		public function get answer():Answer {
			return _answer;
		}
		
		public override function clone():Event {
			return new SectionEvent(type, question, answer, bubbles);
		}
		
		public override function toString():String {
			return formatToString("SectionEvent", "question", "answer", "bubbles");
		}
		
	}
}
