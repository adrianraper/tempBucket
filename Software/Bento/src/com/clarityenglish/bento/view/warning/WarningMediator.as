﻿package com.clarityenglish.bento.view.warning {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.RecorderNotifications;
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
		
		/**
		 * The user sees the warning and clicks Yes. Sometimes this means go on, sometimes it means stop!
		 */
		protected function onYes(event:Event):void {
			switch (view.type) {
				case "lose_answers":
					// Set the condition that caused the warning to false and try again
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					var exercise:Exercise = bentoProxy.currentExercise;
					var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
					
					exerciseProxy.exerciseDirty = false;
					break;
				case "feedback_not_seen":
					// Don't just go back, trigger the feedback display
					sendNotification(BBNotifications.EXERCISE_SHOW_FEEDBACK);
					return;
					break;
				case "changes_not_saved":
					if (view.body && view.body.func is Function)
						view.body.func(); // GH #83 - if the user clicks yes then run the function in the body
					break;
				case "recording_not_saved":
					sendNotification(RecorderNotifications.CLEAR_WAVEFORM, null, RecorderNotifications.RECORD_PROXY_NAME);
					break;
				default:
					return;
			}
			
			// Take action if you are still here
			warningIgnored();
		}
		
		/**
		 * The user sees the warning and clicks No. Sometimes this means stop, sometimes it means go on!
		 */
		protected function onNo(event:Event):void {
			// Some types of warning have NO action
			switch (view.type) {
				// #256
				case "feedback_not_seen":
					// Set the condition that caused the warning to false and try again
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					var exercise:Exercise = bentoProxy.currentExercise;
					var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
					
					exerciseProxy.exerciseFeedbackSeen = true;
					break;
				case "changes_not_saved":
					return; // GH #83 - if the user clicks no then do nothing
					break;
				default:
					return;
			}
			
			// Take action if you are still here
			warningIgnored();
		}
		
		/**
		 * Go on with what you were doing before the warning 
		 */
		protected function warningIgnored():void {
			if (view.body is INotification)
				sendNotification(view.body.getName(), view.body.getBody(), view.body.getType());
		}
		
	}
}
