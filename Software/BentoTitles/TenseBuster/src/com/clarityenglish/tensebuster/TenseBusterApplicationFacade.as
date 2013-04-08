package com.clarityenglish.tensebuster {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.tensebuster.controller.TenseBusterStartupCommand;
	
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
			mapView(LoginView, LoginMediator);
			mapView(TitleView, TitleMediator);
			mapView(HomeView, HomeMediator);
			mapView(AccountView, AccountMediator);
			mapView(CreditsView, CreditsMediator);
			mapView(SupportView, SupportMediator);
			mapView(ExerciseView, ExerciseMediator);
			
			mapView(ZoneView, ZoneMediator);
			mapView(AdviceZoneSectionView, AdviceZoneSectionMediator);
			mapView(QuestionZoneVideoSectionView, QuestionZoneVideoSectionMediator);
			mapView(QuestionZoneSectionView, QuestionZoneSectionMediator);
			mapView(PracticeZoneSectionView, PracticeZoneSectionMediator);
			mapView(PracticeZonePopoutView, PracticeZonePopoutMediator);
			mapView(ExamPracticeZoneSectionView, ExamPracticeZoneSectionMediator);*/
			
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