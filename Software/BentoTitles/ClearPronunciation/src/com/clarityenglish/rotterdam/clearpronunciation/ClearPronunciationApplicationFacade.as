package com.clarityenglish.rotterdam.clearpronunciation
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.CommonAbstractApplicationFacade;
	import com.clarityenglish.rotterdam.clearpronunciation.controller.ClearPronunciationStartupCommand;
	import com.clarityenglish.rotterdam.clearpronunciation.view.course.CourseMediator;
	import com.clarityenglish.rotterdam.clearpronunciation.view.course.CourseView;
	import com.clarityenglish.rotterdam.clearpronunciation.view.home.HomeMediator;
	import com.clarityenglish.rotterdam.clearpronunciation.view.home.HomeView;
	import com.clarityenglish.rotterdam.clearpronunciation.view.title.TitleMediator;
	import com.clarityenglish.rotterdam.clearpronunciation.view.title.TitleView;
	import com.clarityenglish.rotterdam.controller.RotterdamStartupStateMachineCommand;
	
	public class ClearPronunciationApplicationFacade extends CommonAbstractApplicationFacade
	{
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new ClearPronunciationApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(TitleView, TitleMediator);
			mapView(HomeView, HomeMediator);
			mapView(CourseView, CourseMediator);
			
			registerCommand(BBNotifications.STARTUP, ClearPronunciationStartupCommand);
		}
	}
}