package com.clarityenglish.tensebuster.view {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.tensebuster.TenseBusterApplication;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.utilities.statemachine.State;
	import org.puremvc.as3.utilities.statemachine.StateMachine;
	
	public class TenseBusterApplicationMediator extends AbstractApplicationMediator implements IMediator {
		
		public static const NAME:String = "TenseBusterApplicationMediator";
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function TenseBusterApplicationMediator(viewComponent:Object) {
			super(NAME, viewComponent);
		}

		private function get view():TenseBusterApplication {
			return viewComponent as TenseBusterApplication;
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
				case BBStates.STATE_CREDITS:
					view.currentState = "credits";
					break;
			}
		}
		
		/**
		 * Handle the various options for direct start. TenseBuster supports:
		 * 
		 * ...
		 * 
		 * @return 
		 */
		private function handleDirectStart():Boolean {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var directStart:Object = configProxy.getDirectStart();
			
			if (!directStart) return false;
			
			// #338
			// If exerciseID is defined go straight into an exercise.
			if (directStart.exerciseID) {
				var exercise:XML = bentoProxy.menuXHTML.getElementById(directStart.exerciseID);
				
				if (exercise) {
					sendNotification(BBNotifications.SELECTED_NODE_CHANGE, exercise);
					return true;
				}
				
			}
			
			return false;
		}
	
	}
}