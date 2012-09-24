package com.clarityenglish.rotterdam {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.rotterdam.controller.CourseStartCommand;
	import com.clarityenglish.rotterdam.controller.UnitStartCommand;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorMediator;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	
	public class CommonAbstractApplicationFacade extends BentoFacade {
		
		override protected function initializeController():void {
			super.initializeController();
			
			registerProxy(new CourseProxy());
			
			registerCommand(RotterdamNotifications.COURSE_START, CourseStartCommand);
			registerCommand(RotterdamNotifications.UNIT_START, UnitStartCommand);
			
			mapView(CourseSelectorView, CourseSelectorMediator);
		}
		
	}
	
}