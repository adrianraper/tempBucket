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
		
		/*public function getCorrectAnswerMap(question:Question, exercise:Exercise):AnswerMap {
			var answerMap:AnswerMap = new AnswerMap();
			
			for each (var answer:Answer in question.answers) {
				// Find the first correct answer
				if (answer.score > 0) {
					var answerNodes:Array;
					switch (ClassUtil.getClass(answer)) {
						case NodeAnswer:
							answerNodes = (answer as NodeAnswer).getSourceNodes(exercise);
							break;
						case TextAnswer:
							answerNodes = question.getSourceNodes(exercise);
							break;
					}
					
					if (answerNodes) {
						var markableNodes:Array = question.getSourceNodes(exercise);
						if (!markableNodes || markableNodes.length == 0)
							markableNodes = answerNodes;
						
						answerMap.put(markableNodes[0], answer);
					} else {
						log.error("Unable to find matching node for {0}, {1}", question, answer);
					}
					
					break;
				}
			}
			
			return answerMap;
		}*/
		
		public function getCorrectAnswerMap(question:Question, exercise:Exercise):AnswerMap {
			var answerMap:AnswerMap = new AnswerMap();
			var selectedAnswerMap:AnswerMap = getSelectedAnswerMap(question);
			
			// 1. Get all the possible correct answers
			var correctAnswers:Vector.<Answer> = question.getCorrectAnswers();
			
			// 2. Get the target nodes (i.e. the things that actually get 'marked')
			var targetNodes:Vector.<XML> = (question.isSelectable()) ? (correctAnswers[0] as NodeAnswer).getSourceNodes(exercise) : question.getSourceNodes(exercise);
			
			if (question.isSelectable()) {
				// Something you click on
				
				// 2. Find the markable node(s)
				
				
				// 3. If the selected answer is wrong or empty add to answer map
			} else {
				// Something you type or drag into
				
				// 2. Get the markable nodes
				
				
				// 3. Remove any correct answers from the correct answer list
				// 4. Go through the answers adding correct answers where the selected answer is wrong or empty
			}
			
			// First get the markableNodes - these are the things that actually get marked; for example, a <g> for a Target Spotting question,
			// an <input> for a GapFill or a Drag and Drop, etc.  Some questions have multiple markableNodes.
			//var markableNodes:Array = question.getSourceNodes(exercise);
			
			// However, if this is a selection question that doesn't work as the markableNodes are contained in the answer not the question
			
			/*for each (var answer:Answer in question.answers) {
				// Find the first correct answer
				if (answer.score > 0) {
					var answerNodes:Array;
					switch (ClassUtil.getClass(answer)) {
						case NodeAnswer:
							answerNodes = (answer as NodeAnswer).getSourceNodes(exercise);
							break;
						case TextAnswer:
							answerNodes = question.getSourceNodes(exercise);
							break;
					}
					
					if (answerNodes) {
						var markableNodes:Array = question.getSourceNodes(exercise);
						if (!markableNodes || markableNodes.length == 0)
							markableNodes = answerNodes;
						
						answerMap.put(markableNodes[0], answer);
					} else {
						log.error("Unable to find matching node for {0}, {1}", question, answer);
					}
					
					break;
				}
			}*/
			
			return answerMap;
		}
		
		/**
		 * TODO: Need to store the first result (for instant marking)
		 * 
		 * @param question
		 * @param answer
		 * @param key
		 */
		public function questionAnswer(question:Question, answer:Answer, key:Object = null):void {
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
		}
		
	}
	
}