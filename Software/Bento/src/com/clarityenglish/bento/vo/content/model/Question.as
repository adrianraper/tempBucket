package com.clarityenglish.bento.vo.content.model {
	
	public class Question {
		
		private var xml:XML;
		
		private var _answers:Vector.<Answer>;
		
		public function Question(xml:XML) {
			this.xml = xml;
			
			// Create an Answer object for each <answer> child node
			_answers = new Vector.<Answer>();
			for each (var answerNode:XML in xml.answer)
				_answers.push(Answer.create(answerNode));
		}
		
		public function get type():String {
			return xml.name().toString()
		}
		
		public function get source():String {
			return xml.@source.toString()
		}
		
		public function get answers():Vector.<Answer> {
			return _answers;
		}
		
		/**
		 * Create a new Question from a question XML node
		 * 
		 * @param questionNode
		 * @return 
		 */
		public static function create(questionNode:XML):Question {
			var question:Question = new Question(questionNode);
			return question;
		}
		
	}
}
