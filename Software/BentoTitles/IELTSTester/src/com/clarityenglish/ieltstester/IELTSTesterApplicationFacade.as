package com.clarityenglish.ieltstester {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.ieltstester.controller.StartupCommand;
	import com.clarityenglish.ieltstester.view.tester.TesterMediator;
	import com.clarityenglish.ieltstester.view.tester.TesterView;
	
	/**
	* @author Dave Keen
	*/
	public class IELTSTesterApplicationFacade extends BentoFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new IELTSTesterApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(TesterView, TesterMediator);
			
			registerCommand(BBNotifications.STARTUP, StartupCommand);
		}
		
	}
	
}