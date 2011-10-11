package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class XHTMLExerciseMediator extends BentoMediator {
		
		private var answeredQuestions:Vector.<AnsweredQuestion>;
		
		public function XHTMLExerciseMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
			
			answeredQuestions = new Vector.<AnsweredQuestion>();
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
				
			]);
		}
		
		public override function handleNotification(notification:INotification):void {
			super.handleNotification(notification);
			
			switch (notification.getName()) {
				
			}
		}
		
		protected function onQuestionAnswered(event:SectionEvent):void {
			log.debug("Added to answered question list {0} - {1}", event.question, event.answer);
			answeredQuestions.push(new AnsweredQuestion(event.question, event.answer));
		}
		
	}
	
}
import com.clarityenglish.bento.vo.content.model.Answer;
import com.clarityenglish.bento.vo.content.model.Question;

class AnsweredQuestion {
	
	public var question:Question;
	
	public var answer:Answer;
	
	public function AnsweredQuestion(question:Question, answer:Answer) {
		this.question = question;
		this.answer = answer;
	}
	
}