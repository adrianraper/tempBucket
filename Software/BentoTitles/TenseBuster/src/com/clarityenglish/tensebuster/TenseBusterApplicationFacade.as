package com.clarityenglish.tensebuster {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.view.exercise.ExerciseMediator;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.tensebuster.controller.TenseBusterStartupCommand;
	import com.clarityenglish.tensebuster.view.home.HomeMediator;
	import com.clarityenglish.tensebuster.view.home.HomeView;
	import com.clarityenglish.tensebuster.view.title.TitleMediator;
	import com.clarityenglish.tensebuster.view.title.TitleView;
	import com.clarityenglish.tensebuster.view.zone.ZoneMediator;
	import com.clarityenglish.tensebuster.view.zone.ZoneView;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class TenseBusterApplicationFacade extends BentoFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new TenseBusterApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			// Map IELTS specific views to their mediators
			/*mapView(NoNetworkView, NoNetworkMediator);
			mapView(LoginView, LoginMediator);*/
			mapView(TitleView, TitleMediator);
			mapView(HomeView, HomeMediator);
			mapView(ZoneView, ZoneMediator);
			mapView(ExerciseView, ExerciseMediator);
			/*mapView(AccountView, AccountMediator);
			mapView(CreditsView, CreditsMediator);
			mapView(SupportView, SupportMediator);
			
			// Register IELTS specific commands
			/*registerCommand(IELTSNotifications.HREF_SELECTED, HrefSelectedCommand);
			registerCommand(IELTSNotifications.PDF_SHOW, PdfShowCommand);*/
			
			// Upgrade, register and buy
			// registerCommand(IELTSNotifications.IELTS_UPGRADE_WINDOW_SHOW, IELTSUpgradeWindowShowCommand);
			/*registerCommand(IELTSNotifications.IELTS_REGISTER, IELTSRegisterCommand);*/
			
			registerCommand(BBNotifications.STARTUP, TenseBusterStartupCommand);
		}
		
	}
	
}