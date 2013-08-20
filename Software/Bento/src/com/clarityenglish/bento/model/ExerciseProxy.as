package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.bento.vo.content.model.answer.TextAnswer;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.observer.Notification;
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
		 * A flag to track whether or not the exercise has been marked 
		 */
		private var _exerciseMarked:Boolean = false;
		
		/**
		 * #294 - a flag that is set when a mark for this particular exercise has been written to the db.  This does not get reset on 'try again'.
		 */
		private var _exerciseMarkWritten:Boolean = false;
		
		/**
		 * A flag to track whether or not the exercise has had its feedback seen 
		 */
		private var _exerciseFeedbackSeen:Boolean = false;

		/**
		 * A flag to track whether or not the exercise has had anything done to it 
		 */
		private var _exerciseDirty:Boolean = false;
		
		/**
		 * An exercise can only be marked once; once it has been marked the mark is stored here 
		 */
		private var _exerciseMark:ExerciseMark;
		
		/**
		 * #258 - used to records the number of extra incorrect answers to add for param incorrectClickSection
		 */
		private var _incorrectOffset:uint = 0;
		
		/**
		 * This saves how long since the exercise was started
		 */
		private var _startTime:Number = 0;
		
		private var autoMarkTimer:Timer;
		
		public function ExerciseProxy(exercise:Exercise) {
			// Exercise proxies are indexed by the exercise's uid property
			super(NAME(exercise));
			
			this.exercise = exercise;
		}
		
		/**
		 * You can set the start time, and see how long it has been going for
		 */
		public function startExercise():void {
			_startTime = new Date().getTime();
			
			// If the exercise has an auto timer complete setting then start a timer
			if (exercise.model && exercise.model.hasSettingParam("autoMarkTimeout")) {
				var autoMarkTimerDelay:int = exercise.model.getSettingParam("autoMarkTimeout");
				
				// gh#510 and at least 2 seconds!
				if (autoMarkTimerDelay > 1) {
					autoMarkTimer = new Timer(autoMarkTimerDelay * 1000, 1);
					autoMarkTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onAutoTimerComplete);
					autoMarkTimer.start();
				}
			}
		}
		
		/**
		 * If the auto marking timeout completes then show marking
		 * 
		 * @param event
		 */
		protected function onAutoTimerComplete(event:TimerEvent):void {
			if (!_exerciseMarked) sendNotification(BBNotifications.MARKING_SHOW, { exercise: exercise } );
		}
		
		public function get duration():int {
			return new Date().getTime() - _startTime;
		}
		
		public function get exerciseMarked():Boolean {
			return _exerciseMarked;
		}
		
		public function get exerciseMarkWritten():Boolean {
			return _exerciseMarkWritten;
		}
		
		public function exerciseMarkWasWritten():void {
			_exerciseMarkWritten = true;
		}
		
		public function get exerciseFeedbackSeen():Boolean {
			return _exerciseFeedbackSeen;
		}
		public function set exerciseFeedbackSeen(value:Boolean):void {
			_exerciseFeedbackSeen = value;
		}
		
		public function get exerciseDirty():Boolean {
			return _exerciseDirty;
		}
		
		public function set exerciseDirty(value:Boolean):void {
			_exerciseDirty = value;
		}
		
		/**
		 * This checks the current exercise for any warnings that should be thrown.  If there are warnings preventing the exercise from being left
		 * this will trigger the warnings and return false.  Otherwise this will return true, meaning that it is ok to leave the exercise.  This
		 * method accepts parameters which tell it what notification to send in the event of the user overriding the warning. #210, #255
		 * 
		 * @param notificationName
		 * @param body
		 * @param type
		 * @return 
		 */
		public function attemptToLeaveExercise(note:INotification):Boolean {
			if (isLeavingGoingToLoseAnswers()) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, note, "lose_answers");
				return false;
			} else if (isLeavingGoingToMissFeedback()) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, note, "feedback_not_seen");
				return false;
			}
			
			return true;
		}
		
		/**
		 * Returns true if leaving this exercise would result in the user losing their answers - #210
		 */
		private function isLeavingGoingToLoseAnswers():Boolean {
			return !exerciseMarked && exerciseDirty;
		}
		
		/**
		 * Returns true if leaving this exercise would result in the user not seeing some feedback -  #210
		 */
		private function isLeavingGoingToMissFeedback():Boolean {
			return exerciseMarked && hasExerciseFeedback() && !exerciseFeedbackSeen;
		}
		
		/**
		 * Determine if this is a delayed marking exercise from the settings
		 * 
		 * @return 
		 */
		private function get delayedMarking():Boolean {
			return exercise.model && exercise.model.getSettingParam("delayedMarking");
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
			
			if (autoMarkTimer) {
				autoMarkTimer.stop();
				autoMarkTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onAutoTimerComplete);
				autoMarkTimer = null;
			}
			
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
		
		public function getAllSelectedAnswerMaps():Dictionary {
			return selectedAnswerMap;
		}
		
		/** 
		 * @param question
		 * @param answer
		 * @param key
		 * @param disabled If this is true then the only effect of this will be to display feedback, if there is any.  
		 * 				   This is used when things happen after marking has been shown.
		 */
		public function questionAnswer(question:Question, answer:Answer, key:Object = null, disabled:Boolean = false):void {
			checkExercise();

			if (!disabled) {
				log.debug("Answered question {0} - {1} [result: {2}, score: {3}]", question, answer, answer.markingClass, answer.score);
				
				// If we are using instant marking then we may need to store an answer for this question (if it has been marked already this will have no effect)
				if (!delayedMarking)
					markQuestion(question, answer, key);
				
				// Get the answer map for this question
				var answerMap:AnswerMap = getSelectedAnswerMap(question);
				
				// gh#526: comment out
				//var didKeyAlreadyExist:Boolean = answerMap.containsKey(key);
				
				// If this is a mutually exclusive question (e.g. multiple choice) then clear the answer map before adding the new answer so we
				// can only have one answer at a time in the map.
				if (question.isMutuallyExclusive()) answerMap.clear();
				
				// gh#526: comment out
				/*if (question.isSelectable()) {
					if (!didKeyAlreadyExist) answerMap.put(key, answer);
				} else {
					// Add the answer
					answerMap.put(key, answer);
				}*/				
				answerMap.put(key, answer);
				// gh#347
				if (question.type == Question.TARGET_SPOTTING_QUESTION && exercise.model.getSettingParam("delayedMarking") == null) {
					exerciseDirty = false;											
				} else {
					// Trac 121. You have now answered a question, so the exercise is dirty
					exerciseDirty = true;
				}
				
				// Send a notification to say the question has been answered
				sendNotification(BBNotifications.QUESTION_ANSWERED, { question: question, delayedMarking: delayedMarking } );
			}
			
			// If there is any feedback attached to the answer send a notification to tell the framework to display some feedback.  
			// If delayed marking is on we only show feedback once the exercise has been marked.
			if (answer.feedback && (!delayedMarking || exerciseMarked)) {
				// Create substitutions where appropriate
				var correctAnswers:Vector.<Answer> = question.getCorrectAnswers();
				var substitutions:Object = {};
				substitutions.yourAnswer = answer.toReadableString(exercise);
				substitutions.correctAnswer = (correctAnswers.length > 0) ? correctAnswers[0].toReadableString(exercise) : "";
				
				sendNotification(BBNotifications.FEEDBACK_SHOW, { exercise: exercise, feedback: answer.feedback, substitutions: substitutions } );
			}
		}
		
		/** #258
		 * Exercises can have a 'incorrectClickSection' parameter which generates an incorrect answer for every click that isn't on an interactive element.  This is
		 * used in target spotting exercises where missing a target counts as a wrong answer.  We maintain an incorrectOffset for this special case.
		 */
		public function questionIncorrectAnswer():void {
			checkExercise();
			
			_incorrectOffset++;
		}
		
		private function markQuestion(question:Question, answer:Answer, key:Object = null):void {
			checkExercise();
			
			var markableAnswerMap:AnswerMap = getMarkableAnswerMap(question);
			
			// If the answer is in a synonym group then check if it has already been used and if so replace this answer with an incorrect copy (#201)
			// #201 comments; I *think* its the case that no matter whether or not a text answer is in a synonym group it can only be used once per question, so I
			// have removed the synonymGroup check.  It needs to be confirmed that this has no undesirable side effects.
			if (answer is TextAnswer /*&& answer.synonymGroup*/) {
				var existingIdx:int = markableAnswerMap.values.indexOf(answer);
				//trace("answer: "+answer.toXMLString());
				//trace("existingIdx: "+existingIdx);
				if (existingIdx >= 0) {
					answer = new TextAnswer(<answer value={(answer as TextAnswer).value} correct={false}/>);
				}
			}

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
				} else {
					// gh#351
					var removedAnswer:Answer = markableAnswerMap.remove(key);
					markableAnswerMap.put(key, answer);
				}
			}
			
			if (answer.markingClass == Answer.CORRECT && answer.synonymGroup) {
				// If a correct answer is given then make all the other answers in the same synonym group incorrect (#97)
				for each (var possibleAnswer:Answer in question.answers) {
					if (possibleAnswer.synonymGroup == answer.synonymGroup && possibleAnswer !== answer) {
						possibleAnswer.correct = false;
					}
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
			
			// 2. Get the target nodes (these will be the keys in the answer map)
			var targetNodes:Vector.<XML> = (question.isSelectable()) ? (correctAnswers[0] as NodeAnswer).getSourceNodes(exercise) : question.getSourceNodes(exercise);
			
			// 3. Remove any correct answers from the target nodes and correct answers
			if (targetNodes) {
				targetNodes = targetNodes.filter(function(targetNode:XML, idx:int, vector:Vector.<XML>):Boolean {
					var selectedAnswer:Answer = selectedAnswerMap.get(targetNode);
					if (selectedAnswer && selectedAnswer.markingClass == Answer.CORRECT) {
						var idx:int = correctAnswers.indexOf(selectedAnswer);
						if (idx > -1) {
							// Remove the correct answer
							correctAnswers.splice(idx, 1);
							return false;
						}
					}
					
					return true;
				});
				
				// For each question
				for each (var targetNode:XML in targetNodes) {
					// 4. Get the answer currently in this target node
					var selectedAnswer:Answer = selectedAnswerMap.get(targetNode);
					
					// 5. If the current answer is empty or incorrect then add it to the answer map
					// gh#474 add selectedAnswer.markingClass == Answer.NEUTRAL for drag an drop: drag in and drag out an answer operation
					if (!selectedAnswer || selectedAnswer.markingClass == Answer.INCORRECT || selectedAnswer.markingClass == Answer.NEUTRAL) {
						var correctAnswer:Answer = correctAnswers[0]

						answerMap.put(targetNode, correctAnswer);
						correctAnswers.shift();
						
						// Remove other answers from the same synonym group (#97)
						if (correctAnswer.synonymGroup) {
							correctAnswers = correctAnswers.filter(function(remainingCorrectAnswer:Answer, idx:int, vector:Vector.<Answer>):Boolean {
								if (remainingCorrectAnswer.synonymGroup == correctAnswer.synonymGroup && remainingCorrectAnswer !== correctAnswer) {
									var idx:int = correctAnswers.indexOf(remainingCorrectAnswer);
									if (idx > -1) return false;
								}
								
								return true;
							});
						}
						
					}	
				}
			} else {
				log.error("Unable to find any target nodes for question {0}", question);
			}
			
			return answerMap;
		}
		
		/**
		 * Count the number of correct, incorrect and missed answers and return them. If instant marking was on the markable answers will already have been set,
		 * otherwise the currently selected answers will become the markable answers.
		 * 
		 * @return 
		 */
		public function getExerciseMark():ExerciseMark {
			checkExercise();
			
			if (!exercise.model) return null;
			
			// An exercise can only be marked once - if its already been marked then return the cached mark
			if (_exerciseMarked) return _exerciseMark;
			
			// Set the exercise as marked
			_exerciseMarked = true;
			
			// If we are using delayed marking then mark all selected questions now
			if (delayedMarking) markSelectedQuestions();
			
			_exerciseMark = new ExerciseMark();
			
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
								// !!! Neutral questions don't go towards any counts (i.e. neither correct, incorrect nor missed)
								break;
						}
					}
					
					// Add values to the exercise mark, including calculating the number of missed points
					_exerciseMark.correctCount += correctCount;
					_exerciseMark.incorrectCount += incorrectCount;
					
					// #106. If a target spotting is wrong and you click it, you shouldn't end up with missed count of -1
					if (question.getMaximumPossibleScore() > 0) {
						_exerciseMark.missedCount += (question.getMaximumPossibleScore() - correctCount - incorrectCount);
					} else {
						_exerciseMark.missedCount += 0;
					}
				} else {
					// The entire question was missed
					_exerciseMark.missedCount += question.getMaximumPossibleScore();
				}
			}
			
			// Add the incorrect offset
			_exerciseMark.incorrectCount += _incorrectOffset;
			
			return _exerciseMark;
		}
		
		public function unmarkExercise():void {
			_exerciseMarked = false;
			_exerciseMark = null;
			_exerciseFeedbackSeen = false;
			//_incorrectOffset = 0; In fact we want to roll this score over when using try again so don't reset it
			
			if (delayedMarking)
				markableAnswerMap = markableAnswerMap = new Dictionary(true);
		}
		
		/**
		 * Mark the questions that are currently selected.  Used in delayed marking exercises.
		 */
		private function markSelectedQuestions():void {
			for (var questionObj:Object in selectedAnswerMap) {
				var question:Question = questionObj as Question;
				var answerMap:AnswerMap = selectedAnswerMap[question];
				
				for each (var key:Object in answerMap.keys) {
					var answer:Answer = answerMap.get(key);
					
					markQuestion(question, answer, key);
					sendNotification(BBNotifications.QUESTION_ANSWERED, { question: question } );
				}
			}
		}
		
		// gh#388
		public function hasQuestionFeedback():Boolean {
			return exercise.model.hasQuestionFeedback();
		}
		
		public function hasExerciseFeedback():Boolean {
			return (getExerciseFeedback() != null);
		}
		
		public function showExerciseFeedback():void {
			var exerciseFeedback:Feedback = getExerciseFeedback();
			
			if (exerciseFeedback) {
				// gh#554
				var substitutions:Object = {};
				substitutions.yourScore = _exerciseMark.correctPercent;

				sendNotification(BBNotifications.FEEDBACK_SHOW, { exercise: exercise, feedback: exerciseFeedback , substitutions: substitutions } );
			}
		}
		
		private function getExerciseFeedback():Feedback {
			if (!_exerciseMarked || !_exerciseMark) {
				log.error("Attemped to get exercise feedback before an exercise was marked");
				return null;
			}
			
			// Get the exercise feedback and sort it into descending order by min (this means the first matched feedback will be the most restrictive)
			var exerciseFeedbacks:Vector.<Feedback> = exercise.model.getExerciseFeedback();
			exerciseFeedbacks.sort(function(a:Feedback, b:Feedback):Number {
				var aMin:Number = a.min;
				var bMin:Number = b.min;
				
				if (aMin > bMin) {
					return -1;
				} else if (aMin < bMin) {
					return 1;
				}
				
				return 0;
			});
			
			// Get the exercise score as a percentage (if there are no questions you get 100%)
			var percent:Number = (_exerciseMark.totalQuestions > 0) ?  _exerciseMark.correctPercent : 100;
			for each (var feedback:Feedback in exerciseFeedbacks) {
				if (percent >= feedback.min) {
					return feedback;
				}
			}
			
			return null;
		}
		
	}
	
}