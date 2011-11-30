package com.clarityenglish.ielts.view {
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.utilities.statemachine.State;
	import org.puremvc.as3.utilities.statemachine.StateMachine;
	
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
		
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		/**
		 * List all notifications this Mediator is interested in.
		 *
		 * @return Array the list of nofitication names
		 */
		override public function listNotificationInterests():Array {
			// Concatenate any extra notifications to the array returned by this function in the superclass
			return super.listNotificationInterests().concat([
				// Register interest in LOGGED_IN here
				// so that this mediator can change the state of the application from login to home.
				CommonNotifications.INVALID_LOGIN,
				CommonNotifications.LOGGED_IN,
				CommonNotifications.CONFIG_LOADED,
				StateMachine.CHANGED,
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
					var state:State = note.getBody() as State;
					handleStateChange(state);
					break;
			}
		}
		
		private function handleStateChange(state:State):void {
			log.debug("State machine moved into state {0}", state.name);
			
			switch (state.name) {
				case BBStates.STATE_LOAD_CONFIG:
				case BBStates.STATE_LOAD_MENU:
					view.currentState = "loading";
					break;
				case BBStates.STATE_LOGIN:
					view.currentState = "login";
					break;
				case BBStates.STATE_TITLE:
					view.currentState = "title";
					break;
			}
		}
	
	}
}
