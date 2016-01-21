package com.clarityenglish.ieltsair {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.ielts.IELTSApplicationFacade;
	import com.clarityenglish.ieltsair.controller.NativeExitCommand;
	
	import com.clarityenglish.ieltsair.view.more.MoreView;
	import com.clarityenglish.ieltsair.view.more.MoreMediator;
	
	public class IELTSAirApplicationFacade extends IELTSApplicationFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new IELTSAirApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			// gh#11
			mapView(MoreView, MoreMediator);
			
			// If a fatal error occurs we want to actually exit the app, not just go to the exited state like on the web
			removeCommand(CommonNotifications.EXIT);
			registerCommand(CommonNotifications.EXIT, NativeExitCommand);
		}
		
	}
}
