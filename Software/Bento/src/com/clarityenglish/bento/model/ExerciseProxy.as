package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ExerciseProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "ExerciseProxy";
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * This maintains a map of the answers that will count towards the exercise score
		 */
		//private var markableAnswers:Dictionary;
		
		/**
		 * This maintains a map of the currently selected answers
		 */
		private var selectedAnswerMap:Dictionary;
		
		private var delayedMarking:Boolean = false;
		
		public function ExerciseProxy() {
			super(NAME);
			
			//markableAnswers = new Dictionary(true);
			
			selectedAnswerMap = new Dictionary(true);
		}
		
		public function getSelectedAnswerMap(question:Question):AnswerMap {
			// If there is no selected answer map yet then create one
			if (!selectedAnswerMap[question])
				selectedAnswerMap[question] = new AnswerMap();
			
			return selectedAnswerMap[question];
		}
		
		/**
		 * TODO: Need to store the first result (for instant marking)
		 * 
		 * @param question
		 * @param answer
		 * @param key
		 */
		public function questionAnswer(exercise:Exercise, question:Question, answer:Answer, key:Object = null):void {
			log.debug("Answered question {0} - {1} [result: {2}, score: {3}]", question, answer, answer.markingClass, answer.score);
			
			// If delayed marking is off and this is the first answer for the question record this seperately
			// if (!delayedMarking && !markableAnswers[question]) markableAnswers[question] = answer;
			
			// Get the answer map for this question
			var answerMap:AnswerMap = getSelectedAnswerMap(question);
			
			// If this is a mutually exclusive question (e.g. multiple choice) then clear the answer map before adding the new answer so we
			// can only have one answer at a time in the map.
			if (question.isMutuallyExclusive())
				answerMap.clear();
			
			// Add the answer
			answerMap.put(key, answer);
			
			// Send a notification to say the question has been answered
			sendNotification(BBNotifications.QUESTION_ANSWERED, { question: question, delayedMarking: delayedMarking } );
			
			// If there is any feedback attached to the answer send a notification to tell the framework to display some feedback
			if (answer.feedback)
				sendNotification(BBNotifications.SHOW_FEEDBACK, { exercise: exercise, feedback: answer.feedback } );
		}
		
		/**
		 * This method returns an AnswerMap containing the correct answers for the given questions.  This takes into account answers that
		 * are currently selected, and deals correctly with unordered groups of answers.
		 * 
		 * @param question
		 * @param exercise
		 * @return 
		 */
		public function getCorrectAnswerMap(question:Question, exercise:Exercise):AnswerMap {
			var answerMap:AnswerMap = new AnswerMap();
			var selectedAnswerMap:AnswerMap = getSelectedAnswerMap(question);
			
			// 1. Get all the possible correct answers.  If there are no correct answers for this question do nothing at all.
			var correctAnswers:Vector.<Answer> = question.getCorrectAnswers();
			if (correctAnswers.length == 0)
				return answerMap;
			
			// 2. Get the target nodes (these are the keys in the answer map)
			var targetNodes:Vector.<XML> = (question.isSelectable()) ? (correctAnswers[0] as NodeAnswer).getSourceNodes(exercise) : question.getSourceNodes(exercise);
			
			// 3. Remove any correct answers from the target nodes and correct answers
			if (targetNodes) {
				targetNodes.filter(function(targetNode:XML, idx:int, vector:Vector.<XML>):Boolean {
					var selectedAnswer:Answer = selectedAnswerMap.get(targetNode);
					
					if (selectedAnswer && selectedAnswer.markingClass == Answer.CORRECT) {
						var idx:int = correctAnswers.indexOf(selectedAnswer);
						if (idx > -1) {
							correctAnswers.splice(idx, 1);
							return true;
						}
					}
					
					return false;
				});
			
				// For each question
				for each (var targetNode:XML in targetNodes) {
					// 3. Get the answer currently in this target node
					var selectedAnswer:Answer = selectedAnswerMap.get(targetNode);
					
					// 4. If the current answer is empty or incorrect then add it to the answer map
					if (!selectedAnswer || selectedAnswer.markingClass == Answer.INCORRECT) {
						answerMap.put(targetNode, correctAnswers[0]);
						correctAnswers.shift();
					}	
				}
			} else {
				log.error("Unable to find any target nodes for question {0}", question);
			}
			
			return answerMap;
		}
		
	}
	
}