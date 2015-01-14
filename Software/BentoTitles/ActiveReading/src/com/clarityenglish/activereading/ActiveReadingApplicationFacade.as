package com.clarityenglish.activereading {
	import com.clarityenglish.activereading.controller.ActiveReadingStartupCommand;
	import com.clarityenglish.activereading.view.credits.CreditsMediator;
	import com.clarityenglish.activereading.view.credits.CreditsView;
	import com.clarityenglish.activereading.view.exercise.ExerciseView;
	import com.clarityenglish.activereading.view.home.HomeMediator;
	import com.clarityenglish.activereading.view.home.HomeView;
	import com.clarityenglish.activereading.view.login.LoginView;
	import com.clarityenglish.activereading.view.progress.ProgressAnalysisMediator;
	import com.clarityenglish.activereading.view.progress.ProgressAnalysisView;
	import com.clarityenglish.activereading.view.progress.ProgressCertificateMediator;
	import com.clarityenglish.activereading.view.progress.ProgressCertificateView;
	import com.clarityenglish.activereading.view.progress.ProgressCompareMediator;
	import com.clarityenglish.activereading.view.progress.ProgressCompareView;
	import com.clarityenglish.activereading.view.progress.ProgressCoverageMediator;
	import com.clarityenglish.activereading.view.progress.ProgressCoverageView;
	import com.clarityenglish.activereading.view.progress.ProgressMediator;
	import com.clarityenglish.activereading.view.progress.ProgressScoreMediator;
	import com.clarityenglish.activereading.view.progress.ProgressScoreView;
	import com.clarityenglish.activereading.view.progress.ProgressView;
	import com.clarityenglish.activereading.view.title.TitleMediator;
	import com.clarityenglish.activereading.view.title.TitleView;
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.view.exercise.ExerciseMediator;
	import com.clarityenglish.common.view.login.LoginMediator;
	
	public class ActiveReadingApplicationFacade extends BentoFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new ActiveReadingApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(LoginView, LoginMediator);
			mapView(TitleView, TitleMediator);
			mapView(HomeView, HomeMediator);
			mapView(ExerciseView, ExerciseMediator);
			mapView(ProgressView, ProgressMediator);
			mapView(ProgressCoverageView, ProgressCoverageMediator);
			mapView(ProgressAnalysisView, ProgressAnalysisMediator);
			mapView(ProgressCompareView, ProgressCompareMediator);
			mapView(ProgressScoreView, ProgressScoreMediator);
			mapView(ProgressCertificateView, ProgressCertificateMediator);
			mapView(CreditsView, CreditsMediator);
			
			registerCommand(BBNotifications.STARTUP, ActiveReadingStartupCommand);
		}
	}
}