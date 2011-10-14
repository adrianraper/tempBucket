package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.bento.vo.content.model.Question;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class XHTMLExerciseMediator extends BentoMediator {
		
		private var exerciseProxy:ExerciseProxy; 
		
		public function XHTMLExerciseMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
			
			exerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME) as ExerciseProxy;
		}
		
		public function get view():XHTMLExerciseView {
			return viewComponent as XHTMLExerciseView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			view.addEventListener(SectionEvent.QUESTION_ANSWER, onQuestionAnswered);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.addEventListener(SectionEvent.QUESTION_ANSWER, onQuestionAnswered);
		}
		
		public override function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.QUESTION_ANSWERED,
			]);
		}
		
		public override function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.QUESTION_ANSWERED:
					var question:Question = note.getBody().question as Question;
					var answer:Answer = exerciseProxy.getSelectedAnswerForQuestion(question);
					
					view.questionAnswered(question, answer);
					
					if (!note.getBody().delayedMarking)
						view.questionMark(question, answer);
					
					break;
			}
		}
		
		/**
		 * A question has been answered, so send a notification to the framework.  Note that at this point event.answer can be an Answer or a String.
		 * 
		 * @param event
		 */
		protected function onQuestionAnswered(event:SectionEvent):void {
			sendNotification(BBNotifications.QUESTION_ANSWER, { question: event.question, answerOrString: event.answerOrString } );
		}
		
	}
	
}