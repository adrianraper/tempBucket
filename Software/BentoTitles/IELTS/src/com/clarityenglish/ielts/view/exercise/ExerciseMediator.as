package com.clarityenglish.ielts.view.exercise {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.Exercise;
	
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
		
		private function getExerciseProxy(exercise:Exercise):ExerciseProxy {
			return facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy; 
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.startAgain.add(onStartAgain);
			view.showMarking.add(onShowMarking);
			view.nextExercise.add(onNextExercise);
			view.previousExercise.add(onPreviousExercise);
			view.printExercise.add(onPrintExercise);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.startAgain.remove(onStartAgain);
			view.showMarking.remove(onShowMarking);
			view.nextExercise.remove(onNextExercise);
			view.previousExercise.remove(onPreviousExercise);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.EXERCISE_STARTED,
				BBNotifications.MARKING_SHOWN,
				BBNotifications.EXERCISE_PRINTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.EXERCISE_STARTED:
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					
					// Determine the exercise title
					var breadcrumb:Array = [];
					if (bentoProxy.currentGroupNode) breadcrumb.push(bentoProxy.currentGroupNode.@caption);
					breadcrumb.push(bentoProxy.currentExerciseNode.@caption);
					view.exerciseTitle = breadcrumb.join(" > ");
					
					view.courseCaption = bentoProxy.currentCourseNode.@caption.toLowerCase();
					
					view.markingButton.visible = !(getExerciseProxy(note.getBody() as Exercise).exerciseMarked);
					break;
				case BBNotifications.MARKING_SHOWN:
					view.markingButton.visible = !(getExerciseProxy(note.getBody() as Exercise).exerciseMarked);
					break;
				case BBNotifications.EXERCISE_PRINTED:
					trace("exericse printed");
					break;
			}
		}
		
		private function onPrintExercise():void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			sendNotification(BBNotifications.EXERCISE_PRINT, { exercise: bentoProxy.currentExercise } );
		}
		
		private function onStartAgain():void {
			facade.sendNotification(BBNotifications.EXERCISE_RESTART);
		}
		
		private function onShowMarking():void {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			sendNotification(BBNotifications.MARKING_SHOW, { exercise: bentoProxy.currentExercise } );
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
