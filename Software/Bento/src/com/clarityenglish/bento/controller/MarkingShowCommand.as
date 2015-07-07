package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.marking.MarkingView;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.content.Exercise;
import com.clarityenglish.common.model.CopyProxy;
import com.clarityenglish.common.model.interfaces.CopyProvider;

import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.TitleWindow;
	import spark.events.TitleWindowBoundsEvent;
	import com.clarityenglish.common.model.ConfigProxy;
	
	public class MarkingShowCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var titleWindow:TitleWindow;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var exercise:Exercise = note.getBody().exercise as Exercise;

			// Get the marks
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			var exerciseMark:ExerciseMark = exerciseProxy.getExerciseMark();
			
			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleWindow();
			titleWindow.styleName = "markingTitleWindow";
            var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			titleWindow.title = copyProvider.getCopyForId('exerciseMarkingButton');

			titleWindow.addEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving, false, 0, true);
			
			var markingView:MarkingView = new MarkingView();
			markingView.exerciseMark = exerciseMark;
			titleWindow.addElement(markingView);
			
            // gh#1256 See if the view was sent so marking can be aligned
            if (note.getBody().view) {
                var parentDisplayObject:DisplayObject = note.getBody().view as DisplayObject;
            } else {
			    parentDisplayObject = FlexGlobals.topLevelApplication as DisplayObject;
            }
			// Create and centre the popup
            PopUpManager.addPopUp(titleWindow, parentDisplayObject, false, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
            PopUpManager.centerPopUp(titleWindow);

			// Hide the close button
			titleWindow.closeButton.visible = false;
			
			// Listen for the close event so that we can cleanup
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);

			// #294 - if the exercise has questions then the score gets written here, but only the first time the marking window opens (per exercise)
			if (exercise.hasQuestions() && !exerciseProxy.exerciseMarkWritten) {
				var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
				
				// Add more data to the exerciseMark ready to send it as a score
				exerciseMark.duration = Math.round(exerciseProxy.duration / 1000);
				exerciseMark.UID = bentoProxy.getExerciseUID(exercise.href); // TODO: This assumes that Adrian's getExerciseUID works as intended; check that with him
				
				sendNotification(BBNotifications.SCORE_WRITE, exerciseMark);
				
				exerciseProxy.exerciseMarkWasWritten();
			}
			
			sendNotification(BBNotifications.MARKING_SHOWN, { exercise: exercise });
		}
		
		/**
		 * Close the popup and make all variables eligible for garbage collection
		 * 
		 * @param event
		 */
		protected function onClosePopUp(event:CloseEvent = null):void {
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			titleWindow.removeEventListener(TitleWindowBoundsEvent.WINDOW_MOVING, onWindowMoving);
			
			PopUpManager.removePopUp(titleWindow);
			titleWindow = null;
		}
		
		protected function onWindowMoving(evt:TitleWindowBoundsEvent):void {
			if (evt.afterBounds.left < 0) {
				evt.afterBounds.left = 0;
			} else if (evt.afterBounds.right > FlexGlobals.topLevelApplication.width) {
				evt.afterBounds.left = FlexGlobals.topLevelApplication.width - evt.afterBounds.width;
			}
			
			if (evt.afterBounds.top < 0) {
				evt.afterBounds.top = 0;
			} else if (evt.afterBounds.bottom > FlexGlobals.topLevelApplication.height) {
				evt.afterBounds.top = FlexGlobals.topLevelApplication.height - evt.afterBounds.height;
			}
		}
		
	}
	
}