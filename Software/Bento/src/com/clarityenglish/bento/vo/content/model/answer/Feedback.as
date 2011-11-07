package com.clarityenglish.bento.vo.content.model.answer {
	
	public class Feedback {
		
		private var xml:XML;
		
		private var _answer:Answer;
		
		public function Feedback(xml:XML = null, answer:Answer = null) {
			this.xml = xml;
			this._answer = answer;
		}
		
		public function get source():String {
			return xml.@source;
		}
		
		public function get title():String {
			return xml.@title || "Feedback";
		}
		
		public function get answer():Answer {
			return _answer;
		}
		
	}
	
}
