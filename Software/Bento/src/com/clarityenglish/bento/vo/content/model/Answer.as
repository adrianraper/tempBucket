package com.clarityenglish.bento.vo.content.model {
	
	public class Answer {
		
		private var xml:XML;
		
		public function Answer(xml:XML) {
			this.xml = xml;
		}
		
		public function getSourceNodes(html:XML):XMLList {
			// TODO: This should also accept {} for CSS selectors
			return html.body..*.(hasOwnProperty("@id") && @id == xml.@source);
		}
		
		public function get value():String {
			return xml.@value;
		}
		
		public function get source():String {
			return xml.@source;
		}
		
		public function get score():int {
			// The @score attribute takes priority, if it exists
			if (xml.hasOwnProperty("@score"))
				return xml.@score;
			
			// Otherwise we use the @correct properties (true is +1, false is -1)
			if (xml.hasOwnProperty("@correct")) {
				if (xml.@correct == "true") {
					return 1;
				} else if (xml.@correct == "false") {
					return -1;
				}
			}
			
			// Otherwise the question is neutral (note that this will pick up correct="neutral" too)
			return 0;
		}
		
		public static function create(answerNode:XML):Answer {
			var answer:Answer = new Answer(answerNode);
			return answer;
		}
		
	}
}
