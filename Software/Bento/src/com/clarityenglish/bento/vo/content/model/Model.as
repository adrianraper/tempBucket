package com.clarityenglish.bento.vo.content.model {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.newgonzo.web.css.CSS;

	public class Model {
		
		private var exercise:Exercise;
		
		private var xml:XML;
		
		private var _questions:Vector.<Question>;
		
		public function Model(exercise:Exercise, xml:XML) {
			this.exercise = exercise;
			this.xml = xml;
			
			// Create any questions
			_questions = new Vector.<Question>();
			for each (var questionNode:XML in xml.questions.*)
				_questions.push(Question.create(questionNode));
		}
		
		public function get questions():Vector.<Question> {
			return _questions;
		}
		
		public function get view():String {
			return xml.view.name.toString();
		}
		
		public function getViewParam(paramName:String):String {
			return xml.view.param.(@name == paramName).@value.toString();
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
				var matchingNode:XMLList = exercise.body..*.(hasOwnProperty("@id") && @id == source);
				return matchingNode.length() == 1 ? Vector.<XML>( [ matchingNode[0] ] ) : null;
			}
			
			return null;
		}
		
	}
	
}