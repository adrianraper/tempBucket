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
			// gh#347
			return (xml.hasOwnProperty("@title")) ? xml.@title : "Feedback";
		}
		
		public function get width():Number {
			return xml.@width || NaN;
		}
		
		public function get height():Number {
			return xml.@height || NaN;
		}
		
		/**
		 * This is used in score based feedback.  If min is not defined the default is 0 (which matches all scores)
		 * 
		 * @return 
		 */
		public function get min():Number {
			if (!xml.hasOwnProperty("@min")) return 0;
			
			var percentString:String = xml.@min.toString();
			return new Number(percentString.substr(0, percentString.length - 1));
		}
		
		public function get answer():Answer {
			return _answer;
		}
		
	}
	
}
