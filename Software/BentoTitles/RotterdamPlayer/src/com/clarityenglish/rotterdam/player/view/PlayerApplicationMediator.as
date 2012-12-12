package com.clarityenglish.rotterdam.player.view {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
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
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var directStart:Object = configProxy.getDirectStart();
			
			if (!directStart) return false;
			
			// gh#92
			// If courseID is defined go straight into that course.
			// But this is more complex than you think because we haven't loaded course.xml yet
			if (directStart.courseID) {

				// One possibility is to simply try to load the course that you are told and just 
				// suffer the consequences if this course doesn't exist. Which will be fine if
				// you can catch the exception nicely.
				var menu:String = directStart.courseID + '/menu.xml';
				sendNotification(BBNotifications.MENU_XHTML_LOAD, { filename: menu } );
				return true;
			}
			
			return false;
		}
	
	}
}