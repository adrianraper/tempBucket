package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.bento.vo.content.model.answer.AnswerMap;
	import com.clarityenglish.bento.vo.content.model.answer.NodeAnswer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
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
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
			
			sendNotification(BBNotifications.EXERCISE_START, view.exercise);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.removeEventListener(SectionEvent.QUESTION_ANSWER, onQuestionAnswered);
			
			sendNotification(BBNotifications.EXERCISE_STOP, view.exercise);
		}
		
		public override function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.QUESTION_ANSWERED,
				BBNotifications.SHOW_ANSWERS,
				BBNotifications.MARKING_SHOWN,
			]);
		}
		
		public override function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.QUESTION_ANSWERED:
					handleQuestionAnswered(note);
					break;
				case BBNotifications.SHOW_ANSWERS:
					handleShowAnswers(note);
					break;
				case BBNotifications.MARKING_SHOWN:
					view.setExerciseMarked();
					break;
			}
		}
		
		protected function handleQuestionAnswered(note:INotification):void {
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(view.exercise)) as ExerciseProxy;
			
			var question:Question = note.getBody().question as Question;
			var answerMap:AnswerMap = exerciseProxy.getSelectedAnswerMap(question);
			
			view.selectAnswerMap(question, answerMap);
			
			if (!note.getBody().delayedMarking)
				view.markAnswerMap(question, answerMap);
			
		}
		
		protected function handleShowAnswers(note:INotification):void {
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(view.exercise)) as ExerciseProxy;
			
			// Go through the questions marking each of them
			if (view.exercise.model) {
				for each (var question:Question in view.exercise.model.questions) {
					var answerMap:AnswerMap = exerciseProxy.getCorrectAnswerMap(question);
					view.markAnswerMap(question, answerMap, true);
				}
			}
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
				sendNotification(BBNotifications.QUESTION_NODE_ANSWER, { exercise: view.exercise, question: event.question, nodeAnswer: event.answerOrString, key: event.key, disabled: XHTML.hasClass(event.key as XML, "disabled") } );
			} else if (answerOrString is String) {
				sendNotification(BBNotifications.QUESTION_STRING_ANSWER, { exercise: view.exercise, question: event.question, answerString: event.answerOrString, key: event.key, disabled: XHTML.hasClass(event.key as XML, "disabled") } );
			} else {
				throw new Error("onQuestionAnswered received an answer that was neither a NodeAnswer nor a String - " + answerOrString);
			}
		}
		
	}
	
}