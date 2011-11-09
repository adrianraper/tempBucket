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
		
		private var exerciseProxy:ExerciseProxy; 
		
		public function XHTMLExerciseMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
			
			//exerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME) as ExerciseProxy;
		}
		
		public function get view():IExerciseView {
			return viewComponent as IExerciseView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			if (!(view is IExerciseView))
				throw new Error("Attempted to use a view with XHTMLExerciseMediator that did not implement IExerciseView");
			
			view.addEventListener(SectionEvent.QUESTION_ANSWER, onQuestionAnswered);
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			bentoProxy.currentExercise = view.exercise;
			
			exerciseProxy = new ExerciseProxy(view.exercise);
			facade.registerProxy(exerciseProxy);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.addEventListener(SectionEvent.QUESTION_ANSWER, onQuestionAnswered);
			
			// Clean up after this exercise
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			bentoProxy.currentExercise = null;
			
			facade.removeProxy(ExerciseProxy.NAME(view.exercise));
			exerciseProxy = null;
		}
		
		public override function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.QUESTION_ANSWERED,
				BBNotifications.SHOW_ANSWERS,
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
			}
		}
		
		protected function handleQuestionAnswered(note:INotification):void {
			var question:Question = note.getBody().question as Question;
			var answerMap:AnswerMap = exerciseProxy.getSelectedAnswerMap(question);
			
			view.selectAnswerMap(question, answerMap);
			
			if (!note.getBody().delayedMarking)
				view.markAnswerMap(question, answerMap);
			
		}
		
		protected function handleShowAnswers(note:INotification):void {
			// Go through the questions marking each of them
			if (view.exercise.model) {
				for each (var question:Question in view.exercise.model.questions) {
					var answerMap:AnswerMap = exerciseProxy.getCorrectAnswerMap(question);
					view.markAnswerMap(question, answerMap);
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
				sendNotification(BBNotifications.QUESTION_NODE_ANSWER, { exercise: view.exercise, question: event.question, nodeAnswer: event.answerOrString, key: event.key } );
			} else if (answerOrString is String) {
				sendNotification(BBNotifications.QUESTION_STRING_ANSWER, { exercise: view.exercise, question: event.question, answerString: event.answerOrString, key: event.key } );
			} else {
				throw new Error("onQuestionAnswered received an answer that was neither a NodeAnswer nor a String - " + answerOrString);
			}
		}
		
	}
	
}