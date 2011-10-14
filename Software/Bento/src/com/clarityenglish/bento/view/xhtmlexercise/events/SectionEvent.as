package com.clarityenglish.bento.view.xhtmlexercise.events {
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.bento.vo.content.model.Question;
	
	import flash.events.Event;
	
	public class SectionEvent extends Event {
		
		public static const QUESTION_ANSWER:String = "questionAnswer";
		
		private var _question:Question;
		private var _answer:*;
		
		public function SectionEvent(type:String, question:Question, answer:*, bubbles:Boolean = false) {
			super(type, bubbles);
			
			if (!(answer is Answer || answer is String))
				throw new Error("An answer must be either an Answer or a String");
			
			this._question = question;
			this._answer = answer;
		}
		
		public function get question():Question {
			return _question;
		}
		
		public function get answer():* {
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
