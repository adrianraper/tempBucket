package com.clarityenglish.bento.view.exercise {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.googlecode.bindagetools.Bind;
	
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
			view.backToMenu.add(onBackToMenu);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			Bind.fromProperty(bentoProxy, "selectedExerciseNode").convert(function(node:XML):Href {
				return (node) ? bentoProxy.createRelativeHref(Href.EXERCISE, node.@href) : null;
			}).toProperty(view, "href");
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.startAgain.remove(onStartAgain);
			view.showFeedback.remove(onShowFeedback);
			view.showMarking.remove(onShowMarking);
			view.nextExercise.remove(onNextExercise);
			view.previousExercise.remove(onPreviousExercise);
			view.printExercise.remove(onPrintExercise);
			view.backToMenu.remove(onBackToMenu);
			
			// #414
			sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.EXERCISE_STARTED,
				BBNotifications.MARKING_SHOWN,
				BBNotifications.EXERCISE_PRINTED,
				BBNotifications.EXERCISE_TRY_AGAIN,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.EXERCISE_STARTED:
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					
					var breadcrumb:Array = [];
					try { // #303
						breadcrumb.push(bentoProxy.currentCourseNode.@caption);
						if (bentoProxy.currentGroupNode) breadcrumb.push(bentoProxy.currentGroupNode.@caption);
						breadcrumb.push(bentoProxy.currentExerciseNode.@caption);
						view.exerciseTitle = breadcrumb.join(" > ");
						
						view.courseCaption = bentoProxy.currentCourseNode.@caption.toLowerCase();
					} catch (e:BentoError) {
						sendNotification(CommonNotifications.BENTO_ERROR, e);
						return;
					}
					
					var exercise:Exercise = note.getBody() as Exercise;
					
					// #108, #171
					view.isMarked = getExerciseProxy(exercise).exerciseMarked;
					view.hasQuestions = exercise.hasQuestions();
					
					// #123
					view.hasPrintStylesheet = exercise.hasPrintStylesheet();
					
					// #171
					configureButtonVisibility(exercise);
					break;
				case BBNotifications.MARKING_SHOWN:
					configureButtonVisibility(note.getBody() as Exercise);
					break;
				case BBNotifications.EXERCISE_PRINTED:
					trace("exercise printed");
					break;
				case BBNotifications.EXERCISE_TRY_AGAIN:
					view.isMarked = false;
					configureButtonVisibility(note.getBody() as Exercise);
					break;
			}
		}
		
		private function configureButtonVisibility(exercise:Exercise):void {
			if (view.markingButton) view.markingButton.visible = view.markingButton.includeInLayout = !(getExerciseProxy(exercise).exerciseMarked) && exercise.hasQuestions();
			
			// If there is exercise feedback then show the exercise feedback button
			if (view.feedbackButton) view.feedbackButton.visible = view.feedbackButton.includeInLayout = getExerciseProxy(exercise).hasExerciseFeedback();
		}
		
		private function onPrintExercise(dynamicView:DynamicView):void {
			sendNotification(BBNotifications.EXERCISE_PRINT, dynamicView.href);
		}
		
		private function onStartAgain():void {
			log.debug("The user clicked on start again");
			facade.sendNotification(BBNotifications.EXERCISE_RESTART);
		}
		
		private function onShowFeedback():void {
			// #256
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exercise:Exercise = bentoProxy.currentExercise;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			exerciseProxy.exerciseFeedbackSeen = true;
			
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
		
		private function onBackToMenu():void {
			sendNotification(BBNotifications.SELECTED_NODE_UP);
		}
		
	}
}
