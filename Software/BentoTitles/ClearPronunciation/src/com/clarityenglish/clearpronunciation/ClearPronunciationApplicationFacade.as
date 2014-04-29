package com.clarityenglish.clearpronunciation {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.view.exercise.ExerciseMediator;
	import com.clarityenglish.clearpronunciation.controller.ClearPronunciationStartupCommand;
	import com.clarityenglish.clearpronunciation.controller.SettingsShowCommand;
	import com.clarityenglish.clearpronunciation.controller.YouWillShowCommand;
	import com.clarityenglish.clearpronunciation.view.exercise.YouWillMediator;
	import com.clarityenglish.clearpronunciation.view.exercise.YouWillView;
	import com.clarityenglish.clearpronunciation.view.exercise.ExerciseView;
	import com.clarityenglish.clearpronunciation.view.home.HomeMediator;
	import com.clarityenglish.clearpronunciation.view.home.HomeView;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressAnalysisMediator;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressAnalysisView;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressCertificateMediator;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressCertificateView;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressCompareMediator;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressCompareView;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressCoverageMediator;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressCoverageView;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressMediator;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressScoreMediator;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressScoreView;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressView;
	import com.clarityenglish.clearpronunciation.view.settings.SettingsMediator;
	import com.clarityenglish.clearpronunciation.view.settings.SettingsView;
	import com.clarityenglish.clearpronunciation.view.title.TitleMediator;
	import com.clarityenglish.clearpronunciation.view.title.TitleView;
	
	public class ClearPronunciationApplicationFacade extends BentoFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new ClearPronunciationApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(TitleView, TitleMediator);
			mapView(HomeView, HomeMediator);
			mapView(ExerciseView, ExerciseMediator);
			mapView(SettingsView, SettingsMediator);
			mapView(YouWillView, YouWillMediator);
			mapView(ProgressView, ProgressMediator);
			mapView(ProgressCoverageView, ProgressCoverageMediator);
			mapView(ProgressAnalysisView, ProgressAnalysisMediator);
			mapView(ProgressScoreView, ProgressScoreMediator);
			mapView(ProgressCompareView, ProgressCompareMediator);
			mapView(ProgressCertificateView, ProgressCertificateMediator);
			
			registerCommand(BBNotifications.STARTUP, ClearPronunciationStartupCommand);
			registerCommand(ClearPronunciationNotifications.SETTINGS_SHOW, SettingsShowCommand);
			registerCommand(ClearPronunciationNotifications.YOUWILL_SHOW, YouWillShowCommand);
		}
	}
}