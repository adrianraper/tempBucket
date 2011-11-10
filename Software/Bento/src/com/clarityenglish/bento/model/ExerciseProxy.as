package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ExerciseProxy extends Proxy implements IProxy {
		
		/**
		 * This is a bit of a funny function, but the idea is to give a dynamic NAME (based on the exercise) so instead of making it a constant like in
		 * most Proxies, it is actually a function.  That means that doing something like facade.retrieveProxy(ExerciseProxy.NAME) will throw a compile
		 * error, and the developer will work out that in this case it needs to be facade.retrieveProxy(ExerciseProxy.NAME(exercise)).
		 * 
		 * @param exercise
		 * @return 
		 */
		public static function NAME(exercise:Exercise):String { return exercise.uid; }
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		/**
		 * The current exercise 
		 */
		private var exercise:Exercise;
		
		/**
		 * This maintains a map of the answers that will count towards the exercise score.  If instant marking is turned on this is populated as questions are
		 * answered, otherwise it happens the first time the exercise mark is requested.
		 */
		private var markableAnswerMap:Dictionary;
		
		/**
		 * This maintains a map of the currently selected answers
		 */
		private var selectedAnswerMap:Dictionary;
		
		/**
		 * This defines whether or not we are using delayed marking 
		 */
		private var delayedMarking:Boolean = false;
		
		public function ExerciseProxy(exercise:Exercise) {
			// Exercise proxies are indexed by the exercise's uid property
			super(NAME(exercise));
			
			this.exercise = exercise;
		}
		
		private function checkExercise():void {
			if (!exercise)
				throw new Error("Attempted to call a method in ExerciseProxy when no exercise was set");
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			markableAnswerMap = new Dictionary(true);
			selectedAnswerMap = new Dictionary(true);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			exercise = null;
			markableAnswerMap = null;
			selectedAnswerMap = null;
		}
		
		public function getMarkableAnswerMap(question:Question):AnswerMap {
			checkExercise();
			
			// If there is no selected answer map yet then create one
			if (!markableAnswerMap[question])
				markableAnswerMap[question] = new AnswerMap();
			
			return markableAnswerMap[question];
		}
		
		public function getSelectedAnswerMap(question:Question):AnswerMap {
			checkExercise();
			
			// If there is no selected answer map yet then create one
			if (!selectedAnswerMap[question])
				selectedAnswerMap[question] = new AnswerMap();
			
			return selectedAnswerMap[question];
		}
		
		/** 
		 * @param question
		 * @param answer
		 * @param key
		 */
		public function questionAnswer(question:Question, answer:Answer, key:Object = null):void {
			checkExercise();
			
			log.debug("Answered question {0} - {1} [result: {2}, score: {3}]", question, answer, answer.markingClass, answer.score);
			
			// If we are using instant marking then we may need to store an answer for this question (if it has been marked already this will have no effect)
			if (!delayedMarking)
				markQuestion(exercise, question, answer, key);
			
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
			if (answer.feedback) {
				// Create substitutions where appropriate
				var correctAnswers:Vector.<Answer> = question.getCorrectAnswers();
				var substitutions:Object = {};
				substitutions.yourAnswer = answer.toReadableString(exercise);
				substitutions.correctAnswer = (correctAnswers.length > 0) ? correctAnswers[0].toReadableString(exercise) : "";
				
				sendNotification(BBNotifications.SHOW_FEEDBACK, { exercise: exercise, feedback: answer.feedback, substitutions: substitutions } );
			}
		}
		
		private function markQuestion(exercise:Exercise, question:Question, answer:Answer, key:Object = null):void {
			checkExercise();
			
			var markableAnswerMap:AnswerMap = getMarkableAnswerMap(question);
			
			if (question.isMutuallyExclusive()) {
				// For mutually exlusive questions we store the answer if there isn't one already
				if (markableAnswerMap.keys.length == 0) {
					markableAnswerMap.put(key, answer);
					log.debug("Setting as markable question {0} = {1}", (key is XML) ? key.toXMLString() : key, answer);
				}
			} else {
				// For non-mutually exclusive question we store the answer if there isn't already an entry for the particular key
				if (!(markableAnswerMap.containsKey(key))) {
					markableAnswerMap.put(key, answer);
					log.debug("Setting as markable question {0} = {1}", (key is XML) ? key.toXMLString() : key, answer);
				}
			}
		}
		
		/**
		 * This method returns an AnswerMap containing the correct answers for the given questions.  This takes into account answers that
		 * are currently selected, and deals correctly with unordered groups of answers.
		 * 
		 * @param question
		 * @param exercise
		 * @return 
		 */
		public function getCorrectAnswerMap(question:Question):AnswerMap {
			checkExercise();
			
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
		
		/**
		 * Count the number of correct, incorrect and missed answers and return them.  If instant marking was on the markable answers will already have been set,
		 * otherwise the currently selected answers will become the markable answers.
		 * 
		 * @return 
		 */
		public function getExerciseMark():ExerciseMark {
			checkExercise();
			
			// TODO: This assumes instant marking was on for the moment
			
			var exerciseMark:ExerciseMark = new ExerciseMark();
			
			// Go through the questions
			for each (var question:Question in exercise.model.questions) {
				var answerMap:AnswerMap = markableAnswerMap[question] as AnswerMap;
				
				// These are the correct and incorrect count for this question
				var correctCount:uint = 0;
				var incorrectCount:uint = 0;
				
				if (answerMap) {
					for each (var key:Object in answerMap.keys) {
						var answer:Answer = answerMap.get(key);
						
						switch (answer.markingClass) {
							case Answer.CORRECT:
								correctCount++;
								break;
							case Answer.INCORRECT:
								incorrectCount++;
								break;
							case Answer.NEUTRAL:
								// TODO: Don't know what to do with neutral answers
								// !!! Neutral questions don't go towards any counts (i.e. neither correct, incorrect nor missed)
								throw new Error("Check with Adrian what to do in this situation");
						}
					}
					
					// Add values to the exercise mark, including calculating the number of missed points
					exerciseMark.correctCount += correctCount;
					exerciseMark.incorrectCount += incorrectCount;
					exerciseMark.missedCount += (question.getMaximumPossibleScore() - correctCount - incorrectCount);
				} else {
					// The entire question was missed
					exerciseMark.missedCount += question.getMaximumPossibleScore();
				}
			}
			
			return exerciseMark;
		}
		
	}
	
}