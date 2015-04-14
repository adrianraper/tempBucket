package com.clarityenglish.progressWidget {
	import com.clarityenglish.common.CommonNotifications;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	import com.clarityenglish.progressWidget.model.*;
	import com.clarityenglish.progressWidget.view.*;
	import com.clarityenglish.progressWidget.controller.*;
	import com.clarityenglish.common.controller.*;
	
	/**
	* ...
	* @author Adrian Raper
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
			
			registerCommand(PWNotifications.STARTUP, StartupCommand);
			registerCommand(CommonNotifications.LOGIN, LoginCommand);
			registerCommand(CommonNotifications.LOGOUT, LogoutCommand);
			registerCommand(CommonNotifications.LOGGED_IN, LoggedInCommand);
			registerCommand(CommonNotifications.LOGGED_OUT, LoggedOutCommand);
		}
		
	}
	
}