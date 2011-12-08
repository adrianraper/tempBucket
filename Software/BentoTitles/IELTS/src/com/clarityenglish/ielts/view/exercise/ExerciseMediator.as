package com.clarityenglish.ielts.view.exercise {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.Exercise;
	
	import flash.display.DisplayObject;
	
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
			view.showFeedback.add(onShowFeedback);
			view.showMarking.add(onShowMarking);
			view.nextExercise.add(onNextExercise);
			view.previousExercise.add(onPreviousExercise);
			view.printExercise.add(onPrintExercise);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.startAgain.remove(onStartAgain);
			view.showFeedback.remove(onShowFeedback);
			view.showMarking.remove(onShowMarking);
			view.nextExercise.remove(onNextExercise);
			view.previousExercise.remove(onPreviousExercise);
			view.printExercise.remove(onPrintExercise);
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
					
					// #108
					if ((note.getBody() as Exercise).model.questions.length == 0) {
						view.markingButton.visible = false;
						view.startAgainButton.visible = false;
					} else {
						view.markingButton.visible = !(getExerciseProxy(note.getBody() as Exercise).exerciseMarked);
						view.startAgainButton.visible = true;
					}
					break;
				case BBNotifications.MARKING_SHOWN:
					view.markingButton.visible = !(getExerciseProxy(note.getBody() as Exercise).exerciseMarked);
					
					// If there is exercise feedback then show the exercise feedback button
					view.feedbackButton.visible = getExerciseProxy(note.getBody() as Exercise).hasExerciseFeedback();
					break;
				case BBNotifications.EXERCISE_PRINTED:
					trace("exericse printed");
					break;
			}
		}
		
		private function onPrintExercise(dynamicView:DynamicView):void {
			//var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			//sendNotification(BBNotifications.EXERCISE_PRINT, { view: dynamicView } );
			sendNotification(BBNotifications.EXERCISE_PRINT, dynamicView.href);
		}
		
		private function onStartAgain():void {
			facade.sendNotification(BBNotifications.EXERCISE_RESTART);
		}
		
		private function onShowFeedback():void {
			log.debug("The user clicked on feedback");
			sendNotification(BBNotifications.EXERCISE_SHOW_FEEDBACK);
		}
		
		private function onShowMarking():void {
			log.debug("The user clicked on marking");
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
		
		/**
		 * For printing using snapshots of the DisplayObjects
		 * 
		 */
		public function printRubric():DisplayObject {
			return view.dynamicView;
		}
	}
}
