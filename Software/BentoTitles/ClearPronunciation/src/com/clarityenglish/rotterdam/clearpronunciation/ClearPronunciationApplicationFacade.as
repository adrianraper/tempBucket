package com.clarityenglish.rotterdam.clearpronunciation
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.clearpronunciation.controller.ClearPronunciationStartupCommand;
	import com.clarityenglish.rotterdam.CommonAbstractApplicationFacade;
	import com.clarityenglish.rotterdam.controller.RotterdamStartupStateMachineCommand;
	
	public class ClearPronunciationApplicationFacade extends CommonAbstractApplicationFacade
	{
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new ClearPronunciationApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			// Remove the default Bento state machine (which isn't quite applicable to the builder) and replace it with a new one
			removeCommand(CommonNotifications.CONFIG_LOADED);
			registerCommand(CommonNotifications.CONFIG_LOADED, RotterdamStartupStateMachineCommand);
			
			registerCommand(BBNotifications.STARTUP, ClearPronunciationStartupCommand);
		}
	}
}