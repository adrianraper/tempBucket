package com.clarityenglish.ielts {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.controller.XHTMLLoadCommand;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.ielts.controller.StartupCommand;
	import com.clarityenglish.ielts.view.login.LoginView;
	import com.clarityenglish.ielts.view.menu.MenuMediator;
	import com.clarityenglish.ielts.view.menu.MenuView;
	import com.clarityenglish.ielts.view.module.ModuleMediator;
	import com.clarityenglish.ielts.view.module.ModuleView;
	import com.clarityenglish.ielts.view.progress.ProgressMediator;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class ApplicationFacade extends BentoFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new ApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(LoginView, LoginMediator);
			mapView(MenuView, MenuMediator);
			mapView(ModuleView, ModuleMediator);
			mapView(ProgressView, ProgressMediator);
			
			registerCommand(BBNotifications.STARTUP, StartupCommand);
			registerCommand(BBNotifications.XHTML_LOAD, XHTMLLoadCommand);
		}
		
	}
	
}