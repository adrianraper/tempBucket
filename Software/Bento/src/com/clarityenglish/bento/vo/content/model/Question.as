package com.clarityenglish.bento.vo.content.model {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	
	public class Question {
		
		public static const MULTIPLE_CHOICE_QUESTION:String = "MultipleChoiceQuestion";
		public static const TARGET_SPOTTING_QUESTION:String = "TargetSpottingQuestion";
		public static const DRAG_QUESTION:String = "DragQuestion";
		public static const GAP_FILL_QUESTION:String = "GapFillQuestion";
		public static const ERROR_CORRECTION_QUESTION:String = "ErrorCorrectionQuestion";
		public static const DROP_DOWN_QUESTION:String = "DropDownQuestion";
		
		private var xml:XML;
		
		private var _answers:Vector.<Answer>;
		
		public function Question(xml:XML) {
			this.xml = xml;
			
			// Create an Answer object for each predefined <answer> child node
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
		 * Return a Vector of correct answers for this question, where a correct answer is any answer with a positive score
		 * 
		 * @return 
		 */
		public function getCorrectAnswers():Vector.<Answer> {
			var correctAnswers:Vector.<Answer> = new Vector.<Answer>();
			for each (var answer:Answer in answers)
				if (answer.score > 0)
					correctAnswers.push(answer);
			
			return correctAnswers;
		}

		/**
		 * Get the maximum possible score that an answer for this question can generate
		 * 
		 * @return 
		 */
		public function getMaximumScore():int {
			var maximumScore:int = 0;
			for each (var answer:Answer in answers)
				maximumScore = Math.max(maximumScore, answer.score);
			
			return maximumScore;
		}
		
		public function getSourceNodes(exercise:Exercise):Vector.<XML> {
			return Model.sourceToNodes(exercise, source);
		}
		
		/**
		 * @return 
		 */
		public function isSelectable():Boolean {
			return (type == Question.MULTIPLE_CHOICE_QUESTION ||
					type == Question.TARGET_SPOTTING_QUESTION);
		}
		
		/**
		 * @return 
		 */
		public function isMutuallyExclusive():Boolean {
			return isSelectable();
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
