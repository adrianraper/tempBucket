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
		
		// The user sees the warning and clicks Yes. Sometimes this means go on, sometimes it means stop!
		protected function onYes(event:Event):void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exercise:Exercise = bentoProxy.currentExercise;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			
			switch (view.type) {
				case "lose_answers":
					// Set the condition that caused the warning to false and try again
					exerciseProxy.exerciseDirty = false;
					break;
				
				// Don't just go back, trigger the feedback display
				case "feedback_not_seen":
					sendNotification(BBNotifications.EXERCISE_SHOW_FEEDBACK);
					return;
					break;
				
				default:
					return;
			}
			// Take action if you are still here
			warningIgnored();

		}
		
		// The user sees the warning and clicks No. Sometimes this means stop, sometimes it means go on!
		protected function onNo(event:Event):void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exercise:Exercise = bentoProxy.currentExercise;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
		
			// Some types of warning have NO action
			switch (view.type) {
				// #256
				case "feedback_not_seen":
					// Set the condition that caused the warning to false and try again
					exerciseProxy.exerciseFeedbackSeen = true;
					break;
				default:
					return;
			}
			// Take action if you are still here
			warningIgnored();
			
		}
		// Go on with what you were doing before the warning 
		protected function warningIgnored():void {
			switch (view.action) {
				case "show_next":
					sendNotification(BBNotifications.EXERCISE_SHOW_NEXT);
					break;
				case "show_previous":
					sendNotification(BBNotifications.EXERCISE_SHOW_PREVIOUS);
					break;
				case "start_again":
					sendNotification(BBNotifications.EXERCISE_RESTART);
					break;
				case "back_to_menu":
					// Hijack this notification as it has the same effect
					sendNotification(BBNotifications.EXERCISE_SECTION_FINISHED);
					break;
			}
		}
		
	}
}
