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
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.googlecode.bindagetools.Bind;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.observer.Notification;
	
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
			view.nodeSelect.add(onNodeSelect);
			view.printExercise.add(onPrintExercise);
			view.backToMenu.add(onBackToMenu);
			view.showFeedbackReminder.add(onShowFeedbackReminder); // gh#388
			view.audioPlayed.add(onAudioPlayed); // gh#267
			view.record.add(onRecord); // gh#267
			view.logout.add(onLogout);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			if (view.hasOwnProperty("selectedExerciseNode"))
				Bind.fromProperty(bentoProxy, "selectedExerciseNode").toProperty(view, "selectedExerciseNode");
			
			Bind.fromProperty(bentoProxy, "selectedExerciseNode").convert(function(node:XML):Href {
				return (node) ? bentoProxy.createRelativeHref(Href.EXERCISE, node.@href, (bentoProxy.selectedNodeType == "test")) : null; // gh#265
			}).toProperty(view, "href");
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (configProxy.getDirectStart().exerciseID && !configProxy.getDirectStart().scorm) {
				view.isDirectStartEx = true;
			}
			
			view.languageCode = configProxy.getConfig().languageCode;
			view.isPlatformiPad = configProxy.isPlatformiPad();
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.startAgain.remove(onStartAgain);
			view.showFeedback.remove(onShowFeedback);
			view.showMarking.remove(onShowMarking);
			view.nextExercise.remove(onNextExercise);
			view.previousExercise.remove(onPreviousExercise);
			view.nodeSelect.remove(onNodeSelect);
			view.printExercise.remove(onPrintExercise);
			view.backToMenu.remove(onBackToMenu);
			view.showFeedbackReminder.remove(onShowFeedbackReminder); // gh#388
			view.audioPlayed.remove(onAudioPlayed); // gh#267
			view.logout.remove(onLogout);
			
			// #414
			sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.EXERCISE_STARTED,
				BBNotifications.MARKING_SHOWN,
				BBNotifications.EXERCISE_PRINTED,
				BBNotifications.EXERCISE_TRY_AGAIN,
				BBNotifications.GOT_QUESTION_FEEDBACK,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.EXERCISE_STARTED:
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					
					var breadcrumb:Array = [];
					try { // #303
						breadcrumb.push(bentoProxy.selectedCourseNode.@caption);
						if (bentoProxy.selectedGroupNode) breadcrumb.push(bentoProxy.selectedGroupNode.@caption);
						breadcrumb.push(bentoProxy.selectedExerciseNode.@caption);
						view.exerciseTitle = breadcrumb.join(" > ");
						
						view.courseCaption = bentoProxy.selectedCourseNode.@caption.toLowerCase();
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
					
					view.hasVideoScript = exercise.hasVideoScript();
					
					// #171
					configureButtonVisibility(exercise);
					break;
				case BBNotifications.MARKING_SHOWN:
					configureButtonVisibility(note.getBody() as Exercise);
					break;
				case BBNotifications.EXERCISE_PRINTED:
					//trace("exercise printed");
					break;
				case BBNotifications.EXERCISE_TRY_AGAIN:
					view.isMarked = false;
					configureButtonVisibility(note.getBody() as Exercise);
					break;
				// gh#413
				case BBNotifications.GOT_QUESTION_FEEDBACK:
					feedbackButtonVisibility(note.getBody() as Boolean);
					break;
			}
		}
		
		private function configureButtonVisibility(exercise:Exercise):void {
			// gh#1139
			if (view.markingButton) 
				view.markingButton.visible = view.markingButton.includeInLayout = !(getExerciseProxy(exercise).exerciseMarked) && exercise.hasQuestions() && !exercise.noMarking();
			// gh#1113
			if (view.startAgainButton) view.startAgainButton.visible =  view.startAgainButton.includeInLayout = exercise.hasQuestions();
			
			// If there is exercise feedback then show the exercise feedback button
			// gh#413
			if (view.feedbackButton) {
				if (getExerciseProxy(exercise).exerciseMarked){
					if (getExerciseProxy(exercise).hasExerciseFeedback())
						view.hasExerciseFeedback = feedbackVisible = true;
					
					if (getExerciseProxy(exercise).hasQuestionFeedback())
						view.hasQuestionFeedback = feedbackVisible = true;
					
				} else {
					var feedbackVisible:Boolean = false;
				}
				view.feedbackButton.visible = view.feedbackButton.includeInLayout = feedbackVisible;
			}
			
			if (exercise.getRule() != null) {
				view.ruleLink = exercise.getRule();
			} else {
				view.ruleLink = null;
			}

			if (view.ruleButton) {
				if (exercise.getRule() != null) {
					view.ruleButton.visible = true;
				} else {
					view.ruleButton.visible = false;
				}
			}
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.selectedExerciseNode.@id == bentoProxy.selectedUnitNode.exercise[0].@id) {
				view.isFirstExercise = true;
			}else {
				view.isFirstExercise = false;
			}
		}
		
		// gh#388
		// gh#413
		private function feedbackButtonVisibility(value:Boolean):void {
			if (view.feedbackButton) {
				view.feedbackButton.visible = view.feedbackButton.includeInLayout = value;
			}
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
		
		private function onNodeSelect(node:XML):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, node);
		}
		
		private function onBackToMenu():void {
			// #210 - can you simply stop the exercise now, or do you need any warning first?
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			if (exerciseProxy.attemptToLeaveExercise(new Notification(BBNotifications.SELECTED_NODE_UP))) {
				sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view); // #265
				sendNotification(BBNotifications.SELECTED_NODE_UP);
			}
		}
		
		// gh#388
		private function onShowFeedbackReminder(value:String):void {
			sendNotification(BBNotifications.FEEDBACK_REMINDER_SHOW, value);
		}
		
		// gh#267
		private function onAudioPlayed(src:String):void {
			sendNotification(BBNotifications.AUDIO_PLAYED, src);
		}
		
		// gh#267
		private function onRecord():void {
			sendNotification(BBNotifications.RECORDER_SHOW);
		}
		
		private function onLogout():void {
			sendNotification(CommonNotifications.LOGOUT);
		}
	}
}
