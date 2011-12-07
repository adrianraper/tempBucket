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
		
		/**
		 * This is used in score based feedback
		 * 
		 * @return 
		 */
		public function get min():Number {
			if (!xml.hasOwnProperty("@min")) return 100;
			
			var percentString:String = xml.@min.toString();
			return new Number(percentString.substr(0, percentString.length - 1));
		}
		
		public function get answer():Answer {
			return _answer;
		}
		
	}
	
}
