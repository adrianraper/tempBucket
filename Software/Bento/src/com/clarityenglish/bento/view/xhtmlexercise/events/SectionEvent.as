package com.clarityenglish.bento.view.xhtmlexercise.events {
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.Question;
	
	import flash.events.Event;
	
	public class SectionEvent extends Event {
		
		public static const QUESTION_ANSWER:String = "questionAnswer";
		public static const INCORRECT_QUESTION_ANSWER:String = "incorrectQuestionAnswer";
		
		private var _question:Question;
		private var _answerOrString:*;
		private var _key:Object;
		
		public function SectionEvent(type:String, question:Question = null, answerOrString:* = null, key:Object = null, bubbles:Boolean = false) {
			super(type, bubbles);
			
			if (type == QUESTION_ANSWER && !(answerOrString is Answer || answerOrString is String))
				throw new Error("An answer must be either an Answer or a String");
			
			this._question = question;
			this._answerOrString = answerOrString;
			this._key = key;
		}
		
		public function get question():Question {
			return _question;
		}
		
		public function get answerOrString():* {
			return _answerOrString;
		}
		
		public function get key():Object {
			return _key;
		}
		
		public override function clone():Event {
			return new SectionEvent(type, question, answerOrString, bubbles);
		}
		
		public override function toString():String {
			return formatToString("SectionEvent", "question", "answerOrString", "bubbles");
		}
		
	}
}