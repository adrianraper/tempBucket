package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.bento.view.xhtmlexercise.events.SectionEvent;
	
	import flash.events.Event;
	
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
			
			// Note that AnswerableBehaviour dispatches this event directly on 'container' (XHTMLExerciseView), so there is no need to XHTMLExerciseView to listen for anything.
			view.addEventListener(SectionEvent.QUESTION_ANSWERED, onQuestionAnswered);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.removeEventListener(SectionEvent.QUESTION_ANSWERED, onQuestionAnswered);
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
		
		protected function onQuestionAnswered(e:SectionEvent):void {
			log.info("Question: " + e.question + " answered with " + e.answer + " -- score delta=" + e.answer.score);
		}
		
	}
	
}