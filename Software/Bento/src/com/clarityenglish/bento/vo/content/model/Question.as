package com.clarityenglish.bento.vo.content.model {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	
	public class Question {
		
		public static const MULTIPLE_CHOICE_QUESTION:String = "MultipleChoiceQuestion";
		public static const TARGET_SPOTTING_QUESTION:String = "TargetSpottingQuestion";
		public static const DRAG_QUESTION:String = "DragQuestion";
		public static const GAP_FILL_QUESTION:String = "GapFillQuestion";
		public static const ERROR_CORRECTION_QUESTION:String = "ErrorCorrectionQuestion";
		public static const DROP_DOWN_QUESTION:String = "DropDownQuestion";
		
		private var xml:XML;
		
		private var exercise:Exercise;
		
		private var _answers:Vector.<Answer>;
		
		public function Question(xml:XML, exercise:Exercise) {
			this.xml = xml;
			this.exercise = exercise;
			
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
		public function getMaximumPossibleScore():int {
			if (answers.length == 0)
				return 0;
			
			// Construct an array of the possible scores sorted in descending order
			var scores:Array = answers.map(function(answer:Answer, idx:int, vector:Vector.<Answer>):int {
				return answer.score;
			}).sort(Array.DESCENDING | Array.NUMERIC);
			
			if (isMutuallyExclusive()) {
				// Return the first array entry (which will be the highest score)
				return scores[0];
			} else {
				// If more than one answer is possible we calculate the highest score we can possibly get
				// Count how many answers there are for the question
				var numAnswers:int = getSourceNodes(exercise).length;
				
				// The maximum possible score is therefore the first numAnswers elements of the scores array summed
				// TODO: This assumes we can only use each answer once
				var sum:int = 0;
				for (var n:uint = 0; n < numAnswers; n++)
					sum += scores[n];
				
				return sum;
			}
			
			return 0; // dummy
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
		 * @param exercise
		 * @return 
		 */
		public static function create(questionNode:XML, exercise:Exercise):Question {
			var question:Question = new Question(questionNode, exercise);
			return question;
		}
		
	}
}
