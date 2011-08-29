package com.clarityenglish.bento {
	import com.clarityenglish.common.controller.*;
	import com.clarityenglish.bento.controller.*;
	//import com.clarityenglish.bento.model.*;
	import com.clarityenglish.bento.view.*;
	
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
			
			registerCommand(BBNotifications.STARTUP, StartupCommand);
			
			/*registerCommand(CommonNotifications.LOGIN, LoginCommand);
			registerCommand(CommonNotifications.LOGOUT, LogoutCommand);
			registerCommand(CommonNotifications.LOGGED_IN, LoggedInCommand);
			registerCommand(CommonNotifications.LOGGED_OUT, LoggedOutCommand);*/
		}
	}
	
}