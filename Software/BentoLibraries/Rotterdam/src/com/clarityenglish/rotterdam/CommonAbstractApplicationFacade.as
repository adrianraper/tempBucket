package com.clarityenglish.rotterdam {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.rotterdam.controller.CourseStartCommand;
	import com.clarityenglish.rotterdam.controller.UnitStartCommand;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorMediator;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	import com.clarityenglish.rotterdam.view.login.LoginView;
	import com.clarityenglish.rotterdam.view.unit.UnitMediator;
	import com.clarityenglish.rotterdam.view.unit.UnitView;
	import com.clarityenglish.rotterdam.view.unit.WidgetMediator;
	import com.clarityenglish.rotterdam.view.unit.widgets.AudioWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ImageWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.PDFWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.TextWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.VideoWidget;
	
	public class CommonAbstractApplicationFacade extends BentoFacade {
		
		override protected function initializeController():void {
			super.initializeController();
			
			registerProxy(new CourseProxy());
			
			registerCommand(RotterdamNotifications.COURSE_START, CourseStartCommand);
			registerCommand(RotterdamNotifications.UNIT_START, UnitStartCommand);
			
			mapView(LoginView, LoginMediator);
			
			mapView(TextWidget, WidgetMediator);
			mapView(PDFWidget, WidgetMediator);
			mapView(VideoWidget, WidgetMediator);
			mapView(ImageWidget, WidgetMediator);
			mapView(AudioWidget, WidgetMediator);
			
			mapView(CourseSelectorView, CourseSelectorMediator);
			mapView(UnitView, UnitMediator);
		}
		
	}
	
}