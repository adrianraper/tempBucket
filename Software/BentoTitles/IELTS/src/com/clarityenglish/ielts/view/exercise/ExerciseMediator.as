﻿package com.clarityenglish.ielts.view.exercise {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ExerciseMediator extends BentoMediator implements IMediator {
		
		public function ExerciseMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ExerciseView {
			return viewComponent as ExerciseView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.showMarking.add(onShowMarking);
			view.nextExercise.add(onNextExercise);
			view.previousExercise.add(onPreviousExercise);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.showMarking.remove(onShowMarking);
			view.nextExercise.remove(onNextExercise);
			view.previousExercise.remove(onPreviousExercise);
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
		
		private function onShowMarking():void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			sendNotification(BBNotifications.SHOW_MARKING, { exercise: bentoProxy.currentExercise } );
		}
		
		private function onNextExercise():void {
			log.debug("The user clicked on next exercise");
			sendNotification(BBNotifications.EXERCISE_SHOW_NEXT);
		}
		
		private function onPreviousExercise():void {
			log.debug("The user clicked on previous exercise");
			sendNotification(BBNotifications.EXERCISE_SHOW_PREVIOUS);
		}
		
	}
}
