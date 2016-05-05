package com.clarityenglish.ielts.view {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.utilities.statemachine.State;
	import org.puremvc.as3.utilities.statemachine.StateMachine;
	import com.clarityenglish.bento.model.SCORMProxy;
	
	public class IELTSApplicationMediator extends AbstractApplicationMediator implements IMediator {
		
		public static const NAME:String = "IELTSApplicationMediator";
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function IELTSApplicationMediator(viewComponent:Object) {
			super(NAME, viewComponent);
		}

		private function get view():IELTSApplication {
			return viewComponent as IELTSApplication;
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
				case BBStates.STATE_NO_NETWORK:
					view.currentState = "nonetwork";
					break;
				case BBStates.STATE_LOAD_COPY:
				case BBStates.STATE_LOAD_ACCOUNT:
				// gh#21
				//case BBStates.STATE_RELOAD_ACCOUNT:
				case BBStates.STATE_LOAD_MENU:
					view.currentState = "loading";
					break;
				case BBStates.STATE_TITLE:
					view.currentState = "title";
					view.callLater(handleDirectStart); // need to use callLater as otherwise the title state hasn't validated yet
					break;
				case BBStates.STATE_CREDITS:
					view.currentState = "credits";
					break;
			}
		}
		
		/**
		 * Handle the various options for direct start. IELTS supports:
		 * 
		 * courseClass, courseID
		 * unitID, exerciseID
		 * 
		 * @return 
		 */
		private function handleDirectStart():Boolean {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
			var directStart:Object = configProxy.getDirectStart();
			
			if (!directStart) return false;
			
			// #338
			// If exerciseID is defined go straight into an exercise.
			if (directStart.exerciseID) {
					var exercise:XML = bentoProxy.menuXHTML.getElementById(directStart.exerciseID);
					if (exercise) {
						var href:Href = bentoProxy.createRelativeHref(Href.EXERCISE, exercise.@href);
						if (href.extension == "rss") {
							directStart.unitID = exercise.parent().@id;
						} else if (href.extension == "pdf") {
							// go to certain tab and open pdf pop up window
							directStart.unitID = exercise.parent().@id;
							sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise);
						} else {
							// gh#877
							var unit:XML = bentoProxy.menuXHTML.getElementById(directStart.exerciseID).parent();
							if (!directStart.scorm || unit.exercise.(@id == directStart.exerciseID).attribute("group").length() <= 0) {
								sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise);
							} else {
								var groupID:Number = unit.exercise.(@id == directStart.exerciseID).@group;
								var unitLength:Number = unit.exercise.(@group == groupID).length();
								var exerciseGroupXMLList:XMLList = unit.exercise.(@group == groupID);
								var exerciseIndex:Number = 0;
								
								// gh#879
								scormProxy.setTotalExercise(unitLength);

								// gh#1469 unrelated to issue, but just a strange loop?
								for (var exerciseGroup in exerciseGroupXMLList) {
									if (exerciseGroup.@id == directStart.exerciseID)
										break;
									exerciseIndex++;
								}

								// Currently, the bookmark will not empty when last exercise ID stored, so here we need to force it open the first exercise manually.
								var nextExercise:XML = (exerciseIndex + 1 == unitLength)? unit.exercise.(@group == groupID)[0] : exerciseGroupXMLList[exerciseIndex + 1];
								if(nextExercise)
									sendNotification(BBNotifications.SELECTED_NODE_CHANGE, nextExercise);
							}
								
							return true;
						}					
					}
			}
			
			
			// If groupID is defined, go straight to the first exercise in the group
			if (directStart.groupID) {
				// If you don't have a unitID as well, the group is meaningless
				if (directStart.unitID) {
					unit = bentoProxy.menuXHTML..unit.(@id == directStart.unitID)[0];
					
					if (unit) {
						trace("exercise length: "+unit.exercise.(@group == directStart.groupID).length());
						scormProxy.setTotalExercise(unit.exercise.(@group == directStart.groupID).length());
						exercise = unit.exercise.(@group == directStart.groupID)[0];
						if (exercise) {
							sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise);
							return true;
						}
					}
				}				
			}

			// #338
			// Does it mean hide all other units? Or just go direct to this unit and leave others accessible?
			// In general, I think that if you go to directStart you want to skip as much menu as possible
			// leaving the student with no choices.
			if (directStart.unitID) {
				unit = bentoProxy.menuXHTML..unit.(@id == directStart.unitID)[0];
				
				if (unit) {
					sendNotification(BBNotifications.SELECTED_NODE_CHANGE, unit.parent());
					return true;
				}
			}
			
			// If courseID is defined go straight into that course, having disabled the other courses.
			// TODO. Need to update the circular animation to also respect enabledFlag.
			if (directStart.courseID) {
				var course:XML = bentoProxy.menuXHTML..course.(@id == directStart.courseID)[0];
				
				if (course) {
					sendNotification(BBNotifications.SELECTED_NODE_CHANGE, course);
					return true;
				}
			}
			return false;
		}
	
	}
}