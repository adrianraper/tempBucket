package com.clarityenglish.ielts {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.ielts.controller.StartupCommand;
	import com.clarityenglish.ielts.view.account.AccountMediator;
	import com.clarityenglish.ielts.view.account.AccountView;
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
	public class IELTSApplicationFacade extends BentoFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new IELTSApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(LoginView, LoginMediator);
			mapView(MenuView, MenuMediator);
			mapView(ModuleView, ModuleMediator);
			mapView(ProgressView, ProgressMediator);
			mapView(AccountView, AccountMediator);
			
			registerCommand(BBNotifications.STARTUP, StartupCommand);
		}
		
	}
	
}