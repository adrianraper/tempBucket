package com.clarityenglish.bento.view.xhtmlexercise.events {
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.Question;
	
	import flash.events.Event;
	
	public class DictionaryEvent extends Event {
		
		public static const WORD_CLICK:String = "wordClick";
		
		private var _word:String
		
		public function DictionaryEvent(type:String, word:String, bubbles:Boolean = false) {
			super(type, bubbles);
			
			this._word = word;
		}
		
		public function get word():String {
			return _word;
		}
		
		public override function clone():Event {
			return new DictionaryEvent(type, _word, bubbles);
		}
		
		public override function toString():String {
			return formatToString("DictionaryEvent", "word", "bubbles");
		}
		
	}
}