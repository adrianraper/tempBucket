package com.clarityenglish.bento.vo.content.model {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;

	public class Model {
		
		private var exercise:Exercise;
		
		private var xml:XML;
		
		private var _questions:Vector.<Question>;
		
		private var _exerciseFeedback:Vector.<Feedback>;
		
		public function Model(exercise:Exercise, xml:XML) {
			this.exercise = exercise;
			this.xml = xml;
			
			// Create any questions
			_questions = new Vector.<Question>();
			for each (var questionNode:XML in xml.questions.*)
				_questions.push(Question.create(questionNode, exercise));
			
			// Create any exercise feedback
			_exerciseFeedback = new Vector.<Feedback>();
			for each (var feedbackNode:XML in xml.settings.feedback.feedback)
				_exerciseFeedback.push(new Feedback(feedbackNode));
				
		}
		
		public function get questions():Vector.<Question> {
			return _questions;
		}
		
		public function get view():String {
			return xml.view.name.toString();
		}
		
		public function get popups():XMLList {
			return xml.popups.popup;
		}
		
		public function getViewParam(paramName:String):* {
			// TODO: These params need to be parsed and typecast similar to getSettingParam
			return xml.view.param.(@name == paramName).@value;
		}
		
		public function hasSettingParam(paramName:String):Boolean {
			return (xml.hasOwnProperty("settings") && xml.settings.param.(@name == paramName).length() > 0);
		}
		
		public function getSettingParam(paramName:String):* {
			var value:* = (xml.hasOwnProperty("settings") && xml.settings.param.(@name == paramName).length() > 0) ? xml.settings.param.(@name == paramName).@value : null;
			
			if (value == "true") return true;
			if (value == "false") return false;
			
			return value;
		}
		
		public function getExerciseFeedback():Vector.<Feedback> {
			return _exerciseFeedback;
		}
		
		public function getRule():String {
			var value:String = (xml.hasOwnProperty("settings") && xml.settings.param.(@name == "rule").length() > 0) ? xml.settings.param.(@name == "rule").@value : null;
			return value;
		}
		
		// gh#388
		public function hasQuestionFeedback():Boolean {
			for each (var question:Question in _questions) {
				if (question.unmatchedFeedbackSource)
					return true;
				
				for each (var answer:Answer in question.answers) {
					if (answer.feedback)
						return true;
				}
			}
			return false;
		}
		
		/**
		 * Given a node in the body of the exercise, this returns all the possible Answer nodes that could match it.  This only really applies for
		 * <input> and <select> nodes, and returns all the Answers in a matching Question.
		 *  
		 * @param id
		 * @return 
		 * 
		 */
		public function getPossibleAnswersForNode(node:XML):Vector.<Answer> {
			var results:Vector.<Answer> = new Vector.<Answer>();
			for each (var question:Question in _questions) {
				var matchingNodes:Vector.<XML> = Model.sourceToNodes(exercise, question.source);
				
				if (matchingNodes.indexOf(node) != -1) {
					for each (var answer:Answer in question.answers) {
						if (results.indexOf(answer) < 0) {
							results.push(answer);
						}
					}
				}
			}
			
			return results;
		}
		
		/**
		 * This method gets all source nodes relevant to the exercise.  This will be any bit of XHTML that is linked to a question or answer.
		 * In Bento this is used to determine which bits need to be turned off when marking is complete.
		 * 
		 * @return 
		 */
		public function getAllSourceNodes():Vector.<XML> {
			var sourceNodes:Vector.<XML> = new Vector.<XML>;
			
			// Get all nodes relevant to the exercise model.  This should include all inputs, dropdowns, drag sources, etc
			for each (var question:Question in exercise.model.questions) {
				var questionSourceNodes:Vector.<XML> = question.getSourceNodes(exercise);
				if (questionSourceNodes) sourceNodes = sourceNodes.concat(questionSourceNodes);
				
				for each (var answer:Answer in question.answers) {
					if (answer is NodeAnswer) {
						var answerSourceNodes:Vector.<XML> = (answer as NodeAnswer).getSourceNodes(exercise);
						if (answerSourceNodes) sourceNodes = sourceNodes.concat(answerSourceNodes);
					}
				}
			}
			
			return sourceNodes;
		}
		
		/**
		 * In exercise files the 'source' parameter (which is used to specify a node in the body) can either be a straight id - for example source="myInput" which references
		 * <input id="myInput">, or it can be a CSS selector in curly braces - for example source="{input.yellowInputs}", which references all the inputs with class 'yellowInputs'.
		 * 
		 * This method takes a source string and returns an array of matching nodes.
		 * 
		 * @param exercise
		 * @param source
		 * @return 
		 */
		public static function sourceToNodes(exercise:Exercise, source:String):Vector.<XML> {
			var matches:Array = source.match(/\{([^}]*)\}$/);
			if (matches !== null) {
				// If the source is wrapped in curly braces then its a CSS selector
				return Vector.<XML>(exercise.select(matches[1]));
			} else {
				// Otherwise it is a straight id
				var matchingNode:XMLList = exercise.body..*.(attribute("id") == source);
				return matchingNode.length() == 1 ? Vector.<XML>( [ matchingNode[0] ] ) : null;
			}
			
			return null;
		}
		
	}
	
}