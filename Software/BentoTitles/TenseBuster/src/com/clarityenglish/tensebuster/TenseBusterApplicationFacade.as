package com.clarityenglish.tensebuster {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.view.exercise.ExerciseMediator;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.tensebuster.controller.TenseBusterStartupCommand;
	import com.clarityenglish.tensebuster.view.help.HelpMediator;
	import com.clarityenglish.tensebuster.view.help.HelpView;
	import com.clarityenglish.tensebuster.view.home.HomeMediator;
	import com.clarityenglish.tensebuster.view.home.HomeView;
	import com.clarityenglish.tensebuster.view.login.LoginView;
	import com.clarityenglish.tensebuster.view.profile.ProfileMediator;
	import com.clarityenglish.tensebuster.view.profile.ProfileView;
	import com.clarityenglish.tensebuster.view.progress.ProgressAnalysisMediator;
	import com.clarityenglish.tensebuster.view.progress.ProgressAnalysisView;
	import com.clarityenglish.tensebuster.view.progress.ProgressCertificateMediator;
	import com.clarityenglish.tensebuster.view.progress.ProgressCertificateView;
	import com.clarityenglish.tensebuster.view.progress.ProgressCompareMediator;
	import com.clarityenglish.tensebuster.view.progress.ProgressCompareView;
	import com.clarityenglish.tensebuster.view.progress.ProgressMediator;
	import com.clarityenglish.tensebuster.view.progress.ProgressView;
	import com.clarityenglish.tensebuster.view.title.TitleMediator;
	import com.clarityenglish.tensebuster.view.title.TitleView;
	import com.clarityenglish.tensebuster.view.unit.UnitMediator;
	import com.clarityenglish.tensebuster.view.unit.UnitView;
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
			/*mapView(NoNetworkView, NoNetworkMediator);*/
			mapView(LoginView, LoginMediator);
			mapView(TitleView, TitleMediator);
			mapView(HomeView, HomeMediator);
			mapView(UnitView, UnitMediator);
			mapView(ZoneView, ZoneMediator);
			mapView(ExerciseView, ExerciseMediator);
			mapView(ProgressView, ProgressMediator);
			mapView(ProgressAnalysisView, ProgressAnalysisMediator);
			mapView(ProgressCompareView, ProgressCompareMediator);
			mapView(ProgressCertificateView, ProgressCertificateMediator);
			mapView(HelpView, HelpMediator);
			/*mapView(AccountView, AccountMediator);
			mapView(CreditsView, CreditsMediator);
			mapView(SupportView, SupportMediator);*/
			
			registerCommand(BBNotifications.STARTUP, TenseBusterStartupCommand);
		}
		
	}
	
}