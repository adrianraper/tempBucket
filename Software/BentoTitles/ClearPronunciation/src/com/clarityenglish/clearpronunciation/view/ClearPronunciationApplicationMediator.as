package com.clarityenglish.clearpronunciation.view
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.bento.model.BentoProxy;
import com.clarityenglish.bento.model.SCORMProxy;
import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.clearpronunciation.ClearPronunciationApplication;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
import mx.utils.ObjectUtil;

import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.utilities.statemachine.State;
	import org.puremvc.as3.utilities.statemachine.StateMachine;
	
	public class ClearPronunciationApplicationMediator extends AbstractApplicationMediator implements IMediator {
		
		public static const NAME:String = "ClearPronunciationApplicationMediator";
				
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function ClearPronunciationApplicationMediator(viewComponent:Object) {
			super(NAME, viewComponent);
		}
		
		private function get view():ClearPronunciationApplication {
			return viewComponent as ClearPronunciationApplication;
		}
		
		/**
		 * List all notifications this Mediator is interested in.
		 *
		 * @return Array the list of nofitication names
		 */
		override public function listNotificationInterests():Array {
			// Concatenate any extra notifications to the array returned by this function in the superclass
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		/**
		 * Handle all notifications this Mediator is interested in.
		 *
		 * @param INotification a notification
		 */
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case StateMachine.CHANGED:
					handleStateChange(note.getBody() as State);
					break;
			}
		}
		
		private function handleStateChange(state:State):void {
			log.debug("State machine moved into state {0}", state.name);
			
			switch (state.name) {
				case BBStates.STATE_LOAD_COPY:
				case BBStates.STATE_LOAD_ACCOUNT:
				case BBStates.STATE_LOAD_MENU:
					view.currentState = "loading";
					break;
				case BBStates.STATE_TITLE:
					view.currentState = "title";
					view.callLater(handleDirectStart); // need to use callLater as otherwise the title state hasn't validated yet
					break;
				case BBStates.STATE_ENDING:
					view.currentState = "ending";
					break;
			}
		}
		
		/**
		 * Handle the various options for direct start.
		 * 
		 * gh#1467 This is probably common to all bento programs
		 *
		 */
        private function handleDirectStart():Boolean {
            var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
            var directStart:Object = configProxy.getDirectStart();
			// gh#1521 You cannot use directStart null or not to decide whether the program is direct start or not. You can only know it through the number of item in side the directStartObject.
            if (ObjectUtil.getClassInfo(directStart).properties.length <= 0) return false;

            // #338
            // If exerciseID is defined go straight into an exercise.
            if (!directStart.scorm) {
				if (directStart.exerciseID) {
                    var exercise:XML = bentoProxy.menuXHTML.getElementById(directStart.exerciseID);

                    if (exercise) {
                        sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise);
                        return true;
                    }
                } else {
                    // For CP, unit direct start will open the first exercise.
                    if (directStart.unitID) {
                        unit = bentoProxy.menuXHTML.getElementById(directStart.unitID);
						var exercise:XML = unit.exercise[0];
                        sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise);
                    } else if (directStart.courseID) {
                        var course:XML = bentoProxy.menuXHTML.getElementById(directStart.courseID);
                        sendNotification(BBNotifications.SELECTED_NODE_CHANGE, course);
                    }
                }
            } else {
                var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
                // gh#858
				// gh#1521 Through the emptiness of launchData we can know the LMS platform is TalentLMS.
                if (directStart.exerciseID && scormProxy.scorm.launchData) {
                    var unit:XML = bentoProxy.menuXHTML.getElementById(directStart.exerciseID).parent();
                    var unitLength:Number = unit.exercise.length();
                    var exerciseIndex:Number = unit.exercise.(@id == directStart.exerciseID).childIndex();
                    // gh#879
                    scormProxy.setTotalExercise(unitLength);
                    // Currently, the bookmark will not empty when last exercise ID stored, so here we need to force it open the first exercise manually.
                    var nextExercise:XML = (exerciseIndex + 1 == unitLength) ? unit.exercise[0] : unit.exercise[exerciseIndex + 1];

					if (nextExercise)
                        sendNotification(BBNotifications.SELECTED_NODE_CHANGE, nextExercise);
                } else if (directStart.unitID) {
                    unit = bentoProxy.menuXHTML.getElementById(directStart.unitID);

                    if (unit) {
						// gh#879
						scormProxy.setTotalExercise(unit.exercise.length());
                        sendNotification(BBNotifications.SELECTED_NODE_CHANGE, unit.exercise[0]);
                    }
                }
            }

            return false;
        }
    }
}