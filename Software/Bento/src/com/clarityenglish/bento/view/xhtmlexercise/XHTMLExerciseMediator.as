package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.bento.vo.content.model.Question;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class XHTMLExerciseMediator extends BentoMediator {
		
		public function XHTMLExerciseMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		public function get view():XHTMLExerciseView {
			return viewComponent as XHTMLExerciseView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			view.addEventListener(SectionEvent.QUESTION_ANSWERED, onQuestionAnswered);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.addEventListener(SectionEvent.QUESTION_ANSWERED, onQuestionAnswered);
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
					view.questionAnswered(note.getBody().question as Question, note.getBody().answer as Answer);
					
					if (!note.getBody().delayedMarking)
						view.questionMark(note.getBody().question as Question, note.getBody().answer as Answer);
					
					break;
			}
		}
		
		protected function onQuestionAnswered(event:SectionEvent):void {
			sendNotification(BBNotifications.QUESTION_ANSWER, { question: event.question, answer: event.answer } );
		}
		
	}
	
}