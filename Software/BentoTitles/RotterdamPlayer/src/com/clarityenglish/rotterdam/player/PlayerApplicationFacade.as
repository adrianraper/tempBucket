package com.clarityenglish.rotterdam.player {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.CommonAbstractApplicationFacade;
	import com.clarityenglish.rotterdam.controller.RotterdamStartupStateMachineCommand;
	import com.clarityenglish.rotterdam.player.controller.PlayerStartupCommand;
	
	public class PlayerApplicationFacade extends CommonAbstractApplicationFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new PlayerApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			// Remove the default Bento state machine (which isn't quite applicable to the builder) and replace it with a new one
			removeCommand(CommonNotifications.CONFIG_LOADED);
			registerCommand(CommonNotifications.CONFIG_LOADED, RotterdamStartupStateMachineCommand);
			
			// GH #88 (see CommonAbstractApplicationFacade for comments on this)
			// TODO: This notification doesn't exist any more!  What to do?
			//registerCommand(BBNotifications.PROGRESS_DATA_LOADED, CourseStartCommand);
			
			registerCommand(BBNotifications.STARTUP, PlayerStartupCommand);
		}
		
	}
	
}