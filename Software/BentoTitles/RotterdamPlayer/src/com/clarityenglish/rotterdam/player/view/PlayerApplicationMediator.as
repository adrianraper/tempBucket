package com.clarityenglish.rotterdam.player.view {
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.rotterdam.BuilderStates;
	import com.clarityenglish.rotterdam.player.PlayerApplication;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.utilities.statemachine.State;
	import org.puremvc.as3.utilities.statemachine.StateMachine;
	
	public class PlayerApplicationMediator extends AbstractApplicationMediator implements IMediator {
		
		public static const NAME:String = "PlayerApplicationMediator";
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function PlayerApplicationMediator(viewComponent:Object) {
			super(NAME, viewComponent);
		}

		private function get view():PlayerApplication {
			return viewComponent as PlayerApplication;
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		public override function onRemove():void {
			super.onRemove();
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
			/*var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var directStart:Object = configProxy.getDirectStart();
			
			if (!directStart) return false;
			
			// #338
			// If exerciseID is defined go straight into an exercise.
			if (directStart.exerciseID) {
				var exercise:XML = bentoProxy.menuXHTML.getElementById(directStart.exerciseID);
				
				if (exercise) {
					var href:Href = bentoProxy.menuXHTML.href.createRelativeHref(Href.EXERCISE, exercise.@href);
					sendNotification(IELTSNotifications.HREF_SELECTED, href);
					return true;
				}
				
			}
			// If groupID is defined, go straight to the first exercise in the group
			if (directStart.groupID) {
				// If you don't have a unitID as well, the group is meaningless
				if (directStart.unitID) {
					unit = bentoProxy.menuXHTML..unit.(@id == directStart.unitID)[0];
					
					if (unit) {
						exercise = unit.exercise.(@group == directStart.groupID)[0];
						href = bentoProxy.menuXHTML.href.createRelativeHref(Href.EXERCISE, exercise.@href);
						sendNotification(IELTSNotifications.HREF_SELECTED, href);
						return true;
					}
				}				
			}

			// #338
			// Does it mean hide all other units? Or just go direct to this unit and leave others accessible?
			// In general, I think that if you go to directStart you want to skip as much menu as possible
			// leaving the student with no choices.
			if (directStart.unitID) {
				var unit:XML = bentoProxy.menuXHTML..unit.(@id == directStart.unitID)[0];
				
				if (unit) {
					sendNotification(IELTSNotifications.COURSE_SHOW, unit.parent());
					return true;
				}
			}
			
			// If courseID is defined go straight into that course, having disabled the other courses.
			// TODO. Need to update the circular animation to also respect enabledFlag.
			if (directStart.courseID) {
				var course:XML = bentoProxy.menuXHTML..course.(@id == directStart.courseID)[0];
				
				if (course) {
					sendNotification(IELTSNotifications.COURSE_SHOW, course);
					return true;
				}
			}
			return false;*/
			
			return false;
		}
	
	}
}