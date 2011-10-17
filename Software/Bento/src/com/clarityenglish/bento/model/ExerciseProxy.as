package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.Answer;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
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
		private var markableAnswers:Dictionary;
		
		/**
		 * This maintains a map of the currently selected answers
		 */
		//private var selectedAnswers:Dictionary;
		
		private var selectedAnswerMap:Dictionary;
		
		private var delayedMarking:Boolean = false;
		
		public function ExerciseProxy() {
			super(NAME);
			
			markableAnswers = new Dictionary(true);
			//selectedAnswers = new Dictionary(true);
			
			selectedAnswerMap = new Dictionary(true);
		}
		
		/*public function getSelectedAnswerForQuestion(question:Question):Answer {
			return selectedAnswers[question];
		}*/
		
		public function getSelectedAnswerMap(question:Question):AnswerMap {
			return selectedAnswerMap[question];
		}
		
		/**
		 * TODO: Need to figure out what to do for questions that have multiple answers (e.g. DragAndDrop3)
		 * 
		 * Possibilities:
		 * 1. Map question to array
		 * 2. Composite pattern on answer (MultiAnswer)
		 * 
		 * TODO: Need to figure out how this will work with dynamic views and custom exercises (i.e. whether they will have questions and answers)
		 * 
		 * @param question
		 * @param answer
		 * @param key
		 */
		public function questionAnswer(question:Question, answer:Answer, key:Object = null):void {
			log.debug("Answered question {0} - {1} [result: {2}, score: {3}]", question, answer, answer.result, answer.score);
			
			// TODO: Marking still needs to be figured out, especially for multi answers
			// If delayed marking is off and this is the first answer for the question record this seperately
			//if (!delayedMarking && !markableAnswers[question]) markableAnswers[question] = answer;
			
			// Set the currently selected answer for this question
			//selectedAnswers[question] = answer;
			
			/*var multiAnswer:AnswerMap = getSelectedAnswerForQuestion(question) as AnswerMap || new AnswerMap();
			multiAnswer.putAnswer(key, answer);
			selectedAnswers[question] = multiAnswer;*/
			
			// Get the answer map for this question (or if there isn't one yet then create it) and put the answer
			var answerMap:AnswerMap = getSelectedAnswerMap(question) || new AnswerMap();
			
			if (key) {
				answerMap.put(key, answer);
			} else {
				answerMap.putOne(answer);
			}
			
			selectedAnswerMap[question] = answerMap;
			
			// Send a notification to say the question has been answered
			sendNotification(BBNotifications.QUESTION_ANSWERED, { question: question, delayedMarking: delayedMarking } );
		}
		
	}
	
}