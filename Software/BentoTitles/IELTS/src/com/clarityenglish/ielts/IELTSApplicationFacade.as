package com.clarityenglish.ielts {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.controller.LoggedInCommand;
	import com.clarityenglish.common.controller.LogoutCommand;
	import com.clarityenglish.common.controller.ShowErrorCommand;
	import com.clarityenglish.common.controller.UpdateUserCommand;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.ielts.controller.HrefSelectedCommand;
	import com.clarityenglish.ielts.controller.PdfShowCommand;
	import com.clarityenglish.ielts.controller.StartupCommand;
	import com.clarityenglish.ielts.view.account.AccountMediator;
	import com.clarityenglish.ielts.view.account.AccountView;
	import com.clarityenglish.ielts.view.credits.CreditsMediator;
	import com.clarityenglish.ielts.view.credits.CreditsView;
	import com.clarityenglish.ielts.view.exercise.ExerciseMediator;
	import com.clarityenglish.ielts.view.exercise.ExerciseView;
	import com.clarityenglish.ielts.view.home.HomeMediator;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.login.LoginView;
	import com.clarityenglish.ielts.view.progress.ProgressMediator;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	import com.clarityenglish.ielts.view.progress.components.ProgressAnalysisMediator;
	import com.clarityenglish.ielts.view.progress.components.ProgressAnalysisView;
	import com.clarityenglish.ielts.view.progress.components.ProgressCompareMediator;
	import com.clarityenglish.ielts.view.progress.components.ProgressCompareView;
	import com.clarityenglish.ielts.view.progress.components.ProgressCoverageMediator;
	import com.clarityenglish.ielts.view.progress.components.ProgressCoverageView;
	import com.clarityenglish.ielts.view.progress.components.ProgressScoreMediator;
	import com.clarityenglish.ielts.view.progress.components.ProgressScoreView;
	import com.clarityenglish.ielts.view.support.SupportMediator;
	import com.clarityenglish.ielts.view.support.SupportView;
	import com.clarityenglish.ielts.view.title.TitleMediator;
	import com.clarityenglish.ielts.view.title.TitleView;
	import com.clarityenglish.ielts.view.zone.ZoneMediator;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
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
			
			// Map IELTS specific views to their mediators
			mapView(LoginView, LoginMediator);
			mapView(TitleView, TitleMediator);
			mapView(HomeView, HomeMediator);
			mapView(ZoneView, ZoneMediator);
			mapView(ProgressView, ProgressMediator);
			mapView(AccountView, AccountMediator);
			mapView(CreditsView, CreditsMediator);
			mapView(SupportView, SupportMediator);
			mapView(ExerciseView, ExerciseMediator);
			mapView(ProgressScoreView, ProgressScoreMediator);
			mapView(ProgressCompareView, ProgressCompareMediator);
			mapView(ProgressAnalysisView, ProgressAnalysisMediator);
			mapView(ProgressCoverageView, ProgressCoverageMediator);
			
			// Register IELTS specific commands
			registerCommand(IELTSNotifications.HREF_SELECTED, HrefSelectedCommand);
			registerCommand(IELTSNotifications.PDF_SHOW, PdfShowCommand);
			registerCommand(BBNotifications.STARTUP, StartupCommand);
			
			// Common ones are done in BentoFacade
			// AR And I would have thought that LoggedIn should be common too, but RM and DMS both have their own...
			registerCommand(CommonNotifications.LOGGED_IN, LoggedInCommand);
			registerCommand(BBNotifications.USER_UPDATE, UpdateUserCommand);
			
			// For use with errors and exit
			registerCommand(CommonNotifications.CONFIG_ERROR, ShowErrorCommand);
			registerCommand(CommonNotifications.LOGIN_ERROR, ShowErrorCommand);
			registerCommand(CommonNotifications.INSTANCE_ERROR, ShowErrorCommand);
			registerCommand(CommonNotifications.EXIT, LogoutCommand);
			
		}
		
	}
	
}