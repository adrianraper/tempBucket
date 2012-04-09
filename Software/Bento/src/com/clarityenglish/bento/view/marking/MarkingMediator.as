package com.clarityenglish.bento.view.marking {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.marking.events.MarkingEvent;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class MarkingMediator extends BentoMediator implements IMediator {
		
		public function MarkingMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():MarkingView {
			return viewComponent as MarkingView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.addEventListener(MarkingEvent.TRY_AGAIN, onTryAgain);
			view.addEventListener(MarkingEvent.SEE_ANSWERS, onSeeAnswers);
			view.addEventListener(MarkingEvent.MOVE_FORWARD, onMoveForward);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.removeEventListener(MarkingEvent.TRY_AGAIN, onTryAgain);
			view.removeEventListener(MarkingEvent.SEE_ANSWERS, onSeeAnswers);
			view.removeEventListener(MarkingEvent.MOVE_FORWARD, onMoveForward);
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				
			}
		}
		
		protected function onTryAgain(event:Event):void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			facade.sendNotification(BBNotifications.EXERCISE_TRY_AGAIN, bentoProxy.currentExercise);
		}
		
		protected function onSeeAnswers(event:Event):void {
			facade.sendNotification(BBNotifications.ANSWERS_SHOW);
		}
		
		protected function onMoveForward(event:Event):void {
			log.debug("The user clicked on next exercise");
			sendNotification(BBNotifications.EXERCISE_SHOW_NEXT);
		}
		
	}
}
