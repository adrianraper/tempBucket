package com.clarityenglish.bento.vo.content.model.answer {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	
	public class Answer {
		
		public static const SELECTED:String = "selected";
		
		public static const CORRECT:String = "correct";
		public static const INCORRECT:String = "incorrect";
		public static const NEUTRAL:String = "neutral";
		
		protected var xml:XML;
		
		private var _feedback:Feedback;
		
		public function Answer(xml:XML = null) {
			this.xml = xml;
			
			if (xml.hasOwnProperty("feedback"))
				_feedback = new Feedback(xml.feedback[0]);
		}
		
		public function get score():int {
			// The @score attribute takes priority, if it exists
			if (xml.hasOwnProperty("@score"))
				return xml.@score;
			
			// Otherwise if @correct is true, then the score is +1
			if (xml.hasOwnProperty("@correct"))
				if (xml.@correct == "true")
					return 1;
			
			// Otherwise there is no score
			return 0;
		}
		
		/**
		 * When marking this defines the CSS class that is applied to the answer.
		 * 
		 * @return 
		 */
		public function get markingClass():String {
			if (score > 0)
				return CORRECT;
			
			if (score < 0)
				return INCORRECT;
			
			// If score is 0 then the marking class can be either neutral or incorrect based on the value of @correct
			return (xml.hasOwnProperty("@correct") && xml.@correct == "neutral") ? NEUTRAL : INCORRECT;
		}
		
		public function get feedback():Feedback {
			return _feedback;
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
