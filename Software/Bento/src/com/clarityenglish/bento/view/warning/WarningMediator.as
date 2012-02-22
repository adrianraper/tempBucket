package com.clarityenglish.bento.view.warning {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.warning.events.WarningEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class WarningMediator extends BentoMediator implements IMediator {
		
		public function WarningMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():WarningView {
			return viewComponent as WarningView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.addEventListener(WarningEvent.YES, onYes);
			view.addEventListener(WarningEvent.NO, onNo);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.removeEventListener(WarningEvent.YES, onYes);
			view.removeEventListener(WarningEvent.NO, onNo);
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
		
		// The user sees the warning and wants to go on anyway.
		protected function onYes(event:Event):void {
			// Set the condition that caused the warning to false and try again
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exercise:Exercise = bentoProxy.currentExercise;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			exerciseProxy.exerciseDirty = false;
			
			// TODO. You don't know if you are going next or previous...
			sendNotification(BBNotifications.EXERCISE_SHOW_NEXT);

		}
		
		// The user sees the warning and wants to heed it.
		protected function onNo(event:Event):void {
			// Do nothing
			log.info("Clicked no on warning so go back to where you were.");

		}
		
	}
}
