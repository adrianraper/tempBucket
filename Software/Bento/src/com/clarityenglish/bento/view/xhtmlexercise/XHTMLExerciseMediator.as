package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.marking.events.MarkingEvent;
	import com.clarityenglish.bento.view.xhtmlexercise.events.DictionaryEvent;
	import com.clarityenglish.bento.view.xhtmlexercise.events.FeedbackEvent;
	import com.clarityenglish.bento.view.xhtmlexercise.events.HintEvent;
import com.clarityenglish.bento.view.xhtmlexercise.events.ImageEvent;
import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.textLayout.vo.XHTML;

import flash.geom.Rectangle;

import org.puremvc.as3.interfaces.INotification;
	
	public class XHTMLExerciseMediator extends BentoMediator {
		
		public function XHTMLExerciseMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		public function get view():IExerciseView {
			return viewComponent as IExerciseView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			if (!(view is IExerciseView))
				throw new Error("Attempted to use a view with XHTMLExerciseMediator that did not implement IExerciseView");
			
			view.addEventListener(SectionEvent.QUESTION_ANSWER, onQuestionAnswered, false, 0, true);
			view.addEventListener(SectionEvent.QUESTION_CLEAR, onQuestionCleared, false, 0, true);
			view.addEventListener(SectionEvent.INCORRECT_QUESTION_ANSWER, onIncorrectQuestionAnswered, false, 0, true);
			view.addEventListener(FeedbackEvent.FEEDBACK_SHOW, onFeedbackShow, false, 0, true);
			view.addEventListener(DictionaryEvent.WORD_CLICK, onWordClick, false, 0, true);
			view.addEventListener(HintEvent.HINT_SHOW, onHintShow, false, 0, true); // gh#338
			view.addEventListener(ImageEvent.IMAGE_ENLARGE, onEnlargeImage, false, 0, true); // gh#1219
			view.getQuestionFeedback().add(onGotQuestionFeedback); // gh#388, gh#413
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			// #71
			view.stopAllAudio();
			
			view.removeEventListener(SectionEvent.QUESTION_ANSWER, onQuestionAnswered);
			view.removeEventListener(SectionEvent.QUESTION_CLEAR, onQuestionCleared);
			view.removeEventListener(SectionEvent.INCORRECT_QUESTION_ANSWER, onIncorrectQuestionAnswered);
			view.removeEventListener(FeedbackEvent.FEEDBACK_SHOW, onFeedbackShow);
			view.removeEventListener(DictionaryEvent.WORD_CLICK, onWordClick);
			view.removeEventListener(HintEvent.HINT_SHOW, onHintShow);
			view.addEventListener(ImageEvent.IMAGE_ENLARGE, onEnlargeImage);
			view.getQuestionFeedback().remove(onGotQuestionFeedback);
		}
		
		public override function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.QUESTION_ANSWERED,
				BBNotifications.ANSWERS_SHOW,
				BBNotifications.MARKING_SHOWN,
				BBNotifications.EXERCISE_STARTED,
				BBNotifications.EXERCISE_TRY_AGAIN,
			]);
		}
		
		public override function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.QUESTION_ANSWERED:
					handleQuestionAnswered(note);
					break;
				case BBNotifications.ANSWERS_SHOW:
					handleShowAnswers(note);
					break;
				case BBNotifications.MARKING_SHOWN:
					handleMarkingShown(note);
					break;
				case BBNotifications.EXERCISE_STARTED:
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					view.courseCaption = bentoProxy.selectedCourseNode.@caption.toLowerCase();
					
					view.stopAllAudio();
					break;
				case BBNotifications.EXERCISE_TRY_AGAIN:
					view.setExerciseMarked(false);
					break;
			}
		}
		
		protected function handleQuestionAnswered(note:INotification):void {
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(view.exercise)) as ExerciseProxy;
			
			var question:Question = note.getBody().question as Question;
			
			// Show the selected answer map
			view.selectAnswerMap(question, exerciseProxy.getSelectedAnswerMap(question));
			
			// Show the marked answer map (gh#620 - we actually mark the selected answer map rather than the markable answer map)
			if (!note.getBody().delayedMarking && !view.exercise.hasNoMarking())
				view.markAnswerMap(question, exerciseProxy.getSelectedAnswerMap(question));
		}
		
		protected function handleShowAnswers(note:INotification):void {
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(view.exercise)) as ExerciseProxy;
			
			// Go through the questions marking each of them
			// gh#1442
			if (view.exercise.model) {
				for each (var question:Question in view.exercise.model.questions) {
					var answerMap:AnswerMap = exerciseProxy.getCorrectAnswerMap(question);
					view.markAnswerMap(question, answerMap, true);
				}
			}
			
			// gh#1501
			view.exercise.dispatchEvent(new MarkingEvent(MarkingEvent.SEE_ANSWERS));
		}
		
		protected function handleMarkingShown(note:INotification):void {
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(view.exercise)) as ExerciseProxy;
			// Set the exercise marked (this will disable interaction)
			view.setExerciseMarked();
			
			// gh#627
			if (view.exercise.model) {
				for each (var question:Question in view.exercise.model.questions) {
					var selectedAnswerMap:AnswerMap = exerciseProxy.getSelectedAnswerMap(question);
					var markableAnswerMap:AnswerMap = exerciseProxy.getMarkableAnswerMap(question);
					if (!view.exercise.model.getSettingParam("delayedMarking") && markableAnswerMap.keys.length > 0) {
						view.modifyMarkingClass(question, selectedAnswerMap, markableAnswerMap);
					}					
				}
			}
			
			// Stop all audio
			view.stopAllAudio();		
		}
		
		/**
		 * A question has been answered, so send a notification to the framework.  Note that at this point event.answer can be an Answer or a String.
		 * 
		 * @param event
		 */
		protected function onQuestionAnswered(event:SectionEvent):void {
			var answerOrString:* = event.answerOrString;

			// Dispatch the appropriate notitification depending on whether the answer is a NodeAnswer or a String
			if (answerOrString is NodeAnswer) {
				sendNotification(BBNotifications.QUESTION_NODE_ANSWER, { exercise: view.exercise, question: event.question, nodeAnswer: event.answerOrString, key: event.key, disabled: XHTML.hasClass(event.key as XML, "disabled"), bounds: event.bounds, container: event.container } );
			} else if (answerOrString is String) {
				sendNotification(BBNotifications.QUESTION_STRING_ANSWER, { exercise: view.exercise, question: event.question, answerString: event.answerOrString, key: event.key, disabled: XHTML.hasClass(event.key as XML, "disabled"), bounds: event.bounds, container: event.container } );
			} else {
				throw new Error("onQuestionAnswered received an answer that was neither a NodeAnswer nor a String - " + answerOrString);
			}

			view.isClickFlowElement = true;
		}
		
		/**
		 * gh#474 - clear the selected answer map
		 */
		protected function onQuestionCleared(event:SectionEvent):void {
			facade.sendNotification(BBNotifications.QUESTION_CLEAR, { exercise: view.exercise, question: event.question, key: event.key, disabled: XHTML.hasClass(event.key as XML, "disabled") } );
		}
		
		/**
		 * #258
		 * Exercises can have a 'incorrectClickSection' parameter which generates an incorrect answer for every click that isn't on an interactive element.  This is
		 * used in target spotting exercises where missing a target counts as a wrong answer.  Since this is a very specialized kind of behaviour we use kind of a hack
		 * to display the incorrect icon at the mouse position 
		 * 
		 * @param event
		 */
		protected function onIncorrectQuestionAnswered(event:SectionEvent):void {
			facade.sendNotification(BBNotifications.QUESTION_INCORRECT_ANSWER, view.exercise);
		}
		
		protected function onFeedbackShow(e:FeedbackEvent):void {
			facade.sendNotification(BBNotifications.FEEDBACK_SHOW, { exercise: view.exercise, feedback: e.feedback } );
		}
		
		protected function onWordClick(event:DictionaryEvent):void {
			sendNotification(BBNotifications.WORD_CLICK, event.word);
		}
		
		protected function onHintShow(event:HintEvent):void {
			sendNotification(BBNotifications.HINT_SHOW, { exercise: view.exercise, question: event.question } );
		}
		
		// gh#388, gh#413
		protected function onGotQuestionFeedback(value:Boolean):void {
			sendNotification(BBNotifications.GOT_QUESTION_FEEDBACK, value);
		}

		protected function onEnlargeImage(e:ImageEvent):void {
			sendNotification(BBNotifications.IMAGE_ENLARGE, e.image);
		}
	}
	
}