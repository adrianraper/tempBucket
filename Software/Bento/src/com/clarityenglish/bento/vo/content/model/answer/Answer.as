package com.clarityenglish.bento.vo.content.model.answer {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	
	public class Answer {
		
		public static const SELECTED:String = "selected";
		
		public static const CORRECT:String = "correct";
		public static const INCORRECT:String = "incorrect";
		public static const NEUTRAL:String = "neutral";
		
		protected var xml:XML;
		
		public function Answer(xml:XML = null) {
			this.xml = xml;
		}
		
		public function get score():int {
			// The @score attribute takes priority, if it exists
			if (xml.hasOwnProperty("@score"))
				return xml.@score;
			
			// Otherwise we use the @correct properties (true is +1, false is -1)
			if (xml.hasOwnProperty("@correct"))
				if (xml.@correct == "true")
					return 1;
			
			// Otherwise the question is neutral (note that this will pick up correct="neutral" too)
			return 0;
		}
		
		/**
		 * As well as a numerical score we can use 'result' to return a constant CORRECT, INCORRECT or NEUTRAL.  This is more
		 * convenient in some use cases.
		 * 
		 * @return 
		 */
		public function get result():String {
			if (score > 0)
				return CORRECT;
			
			if (score < 0)
				return INCORRECT;
			
			return NEUTRAL;
		}
		
		public function toXMLString():String {
			return xml.toXMLString();
		}
		
		/**
		 * Factory method for creating the correct answer class based on the question type. 
		 * 
		 * @param answerNode
		 * @return 
		 */
		public static function create(answerNode:XML):Answer {
			var questionType:String = answerNode.parent().name().toString();
			
			var answer:Answer;
			switch (questionType) {
				case Question.GAP_FILL_QUESTION:
				case Question.ERROR_CORRECTION_QUESTION:
					return new TextAnswer(answerNode);
				case Question.DRAG_QUESTION:
				case Question.DROP_DOWN_QUESTION:
				case Question.MULTIPLE_CHOICE_QUESTION:
				case Question.TARGET_SPOTTING_QUESTION:
					return new NodeAnswer(answerNode);
				default:
					throw new Error("Unknown question type " + questionType);
			}
			
			return null;
		}
		
	}
}
