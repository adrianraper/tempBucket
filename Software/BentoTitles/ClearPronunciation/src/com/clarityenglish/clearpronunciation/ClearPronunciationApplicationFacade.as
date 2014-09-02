package com.clarityenglish.clearpronunciation
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.view.exercise.ExerciseMediator;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.clearpronunciation.controller.ClearPronunciationStartupCommand;
	import com.clarityenglish.clearpronunciation.view.course.CourseMediator;
	import com.clarityenglish.clearpronunciation.view.course.CourseView;
	import com.clarityenglish.clearpronunciation.view.home.HomeMediator;
	import com.clarityenglish.clearpronunciation.view.home.HomeView;
	import com.clarityenglish.clearpronunciation.view.title.TitleMediator;
	import com.clarityenglish.clearpronunciation.view.title.TitleView;
	import com.clarityenglish.clearpronunciation.view.unit.UnitMediator;
	import com.clarityenglish.clearpronunciation.view.unit.UnitView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.CommonAbstractApplicationFacade;
	
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
			mapView(UnitView, UnitMediator);
			mapView(ExerciseView, ExerciseMediator);
			
			registerCommand(BBNotifications.STARTUP, ClearPronunciationStartupCommand);
		}
	}
}