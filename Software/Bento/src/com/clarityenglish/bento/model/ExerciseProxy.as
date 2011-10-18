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
	import org.flexunit.internals.namespaces.classInternal;
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
		}
		
	}
	
}