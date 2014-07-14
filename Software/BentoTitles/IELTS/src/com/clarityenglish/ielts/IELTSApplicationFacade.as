package com.clarityenglish.ielts {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.view.exercise.ExerciseMediator;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.ielts.controller.IELTSRegisterCommand;
	import com.clarityenglish.ielts.controller.IELTSStartupCommand;
	import com.clarityenglish.ielts.view.account.AccountMediator;
	import com.clarityenglish.ielts.view.account.AccountView;
	import com.clarityenglish.ielts.view.candidates.CandidatesMediator;
	import com.clarityenglish.ielts.view.candidates.CandidatesView;
	import com.clarityenglish.ielts.view.home.HomeMediator;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.login.LoginView;
	import com.clarityenglish.ielts.view.support.SupportMediator;
	import com.clarityenglish.ielts.view.support.SupportView;
	import com.clarityenglish.ielts.view.title.TitleMediator;
	import com.clarityenglish.ielts.view.title.TitleView;
	import com.clarityenglish.ielts.view.zone.AdviceZoneSectionMediator;
	import com.clarityenglish.ielts.view.zone.AdviceZoneSectionView;
	import com.clarityenglish.ielts.view.zone.ExamPracticeZoneSectionMediator;
	import com.clarityenglish.ielts.view.zone.ExamPracticeZoneSectionView;
	import com.clarityenglish.ielts.view.zone.PracticeZonePopoutMediator;
	import com.clarityenglish.ielts.view.zone.PracticeZonePopoutView;
	import com.clarityenglish.ielts.view.zone.PracticeZoneSectionMediator;
	import com.clarityenglish.ielts.view.zone.PracticeZoneSectionView;
	import com.clarityenglish.ielts.view.zone.QuestionZoneSectionMediator;
	import com.clarityenglish.ielts.view.zone.QuestionZoneSectionView;
	import com.clarityenglish.ielts.view.zone.QuestionZoneVideoSectionMediator;
	import com.clarityenglish.ielts.view.zone.QuestionZoneVideoSectionView;
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
			mapView(AccountView, AccountMediator);
			mapView(SupportView, SupportMediator);
			mapView(ExerciseView, ExerciseMediator);
			mapView(CandidatesView, CandidatesMediator);
			
			mapView(ZoneView, ZoneMediator);
			mapView(AdviceZoneSectionView, AdviceZoneSectionMediator);
			mapView(QuestionZoneVideoSectionView, QuestionZoneVideoSectionMediator);
			mapView(QuestionZoneSectionView, QuestionZoneSectionMediator);
			mapView(PracticeZoneSectionView, PracticeZoneSectionMediator);
			mapView(PracticeZonePopoutView, PracticeZonePopoutMediator);
			mapView(ExamPracticeZoneSectionView, ExamPracticeZoneSectionMediator);
			
			// Upgrade, register and buy
			// registerCommand(IELTSNotifications.IELTS_UPGRADE_WINDOW_SHOW, IELTSUpgradeWindowShowCommand);
			registerCommand(IELTSNotifications.IELTS_REGISTER, IELTSRegisterCommand);
			
			registerCommand(BBNotifications.STARTUP, IELTSStartupCommand);
			
			// Common ones are done in BentoFacade
			// AR And I would have thought that LoggedIn should be common too, but RM and DMS both have their own...
			//registerCommand(CommonNotifications.LOGGED_IN, LoggedInCommand);
		}
		
	}
	
}