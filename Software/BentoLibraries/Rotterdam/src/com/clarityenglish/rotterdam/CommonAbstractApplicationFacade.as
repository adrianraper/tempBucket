package com.clarityenglish.rotterdam {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.rotterdam.controller.CourseStartCommand;
	import com.clarityenglish.rotterdam.controller.UnitStartCommand;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorMediator;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	import com.clarityenglish.rotterdam.view.unit.WidgetMediator;
	import com.clarityenglish.rotterdam.view.unit.widgets.AbstractWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.PDFWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.TextWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.VideoWidget;
	
	public class CommonAbstractApplicationFacade extends BentoFacade {
		
		override protected function initializeController():void {
			super.initializeController();
			
			registerProxy(new CourseProxy());
			
			registerCommand(RotterdamNotifications.COURSE_START, CourseStartCommand);
			registerCommand(RotterdamNotifications.UNIT_START, UnitStartCommand);
			
			mapView(TextWidget, WidgetMediator);
			mapView(PDFWidget, WidgetMediator);
			mapView(VideoWidget, WidgetMediator);
			
			mapView(CourseSelectorView, CourseSelectorMediator);
		}
		
	}
	
}