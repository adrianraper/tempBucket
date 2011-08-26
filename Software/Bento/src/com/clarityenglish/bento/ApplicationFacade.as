package com.clarityenglish.bento {
	import com.clarityenglish.common.controller.*;
	import com.clarityenglish.resultsmanager.controller.*;
	import com.clarityenglish.resultsmanager.model.*;
	import com.clarityenglish.resultsmanager.view.*;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class ApplicationFacade extends Facade implements IFacade {
		// Notification name constants
		
		public static function getInstance():ApplicationFacade {
			if (instance == null) instance = new ApplicationFacade();
			return instance as ApplicationFacade;
		}
		
		// Register commands with the controller
		override protected function initializeController():void {
			super.initializeController();
			
			/*registerCommand(RMNotifications.STARTUP, StartupCommand);
			registerCommand(CommonNotifications.LOGIN, LoginCommand);
			registerCommand(CommonNotifications.LOGOUT, LogoutCommand);
			registerCommand(CommonNotifications.LOGGED_IN, LoggedInCommand);
			registerCommand(CommonNotifications.LOGGED_OUT, LoggedOutCommand);*/
		}
	}
	
}