package com.clarityenglish.rotterdam {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.controller.ExerciseStopCommand;
	import com.clarityenglish.bento.controller.WarningShowCommand;
	import com.clarityenglish.common.controller.ShowErrorCommand;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.rotterdam.controller.ContentOpenCommand;
	import com.clarityenglish.rotterdam.controller.CourseResetCommand;
	import com.clarityenglish.rotterdam.controller.CourseStartCommand;
	import com.clarityenglish.rotterdam.controller.UnitStartCommand;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.rotterdam.view.course.CourseMediator;
	import com.clarityenglish.rotterdam.view.course.CourseView;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorMediator;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	import com.clarityenglish.rotterdam.view.title.TitleMediator;
	import com.clarityenglish.rotterdam.view.title.TitleView;
	import com.clarityenglish.rotterdam.view.unit.UnitHeaderMediator;
	import com.clarityenglish.rotterdam.view.unit.UnitHeaderView;
	import com.clarityenglish.rotterdam.view.unit.UnitMediator;
	import com.clarityenglish.rotterdam.view.unit.UnitView;
	import com.clarityenglish.rotterdam.view.unit.WidgetMediator;
	import com.clarityenglish.rotterdam.view.unit.widgets.AnimationWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.AudioWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.AuthoringWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ExerciseWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.GroupWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ImageWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.OrchidWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.PDFWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.SelectorWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.TextWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.VideoWidget;
	
	public class CommonAbstractApplicationFacade extends BentoFacade {
		
		override protected function initializeController():void {
			super.initializeController();
			
			registerProxy(new CourseProxy());
			
			registerCommand(BBNotifications.MENU_XHTML_LOADED, CourseStartCommand);
			registerCommand(BBNotifications.UNIT_START, UnitStartCommand);
			
			registerCommand(RotterdamNotifications.CONTENT_OPEN, ContentOpenCommand);
			registerCommand(RotterdamNotifications.CONTENT_BLOCKED_ON_TABLET, ShowErrorCommand);
			
			// gh#13
			registerCommand(RotterdamNotifications.COURSE_RESET, CourseResetCommand);
			
			// gh#1033
			removeCommand(BBNotifications.EXERCISE_STOP);
			
			mapView(LoginView, LoginMediator);
			mapView(TitleView, TitleMediator);
			mapView(CourseSelectorView, CourseSelectorMediator);
			mapView(CourseView, CourseMediator);
			mapView(UnitView, UnitMediator);
			mapView(UnitHeaderView, UnitHeaderMediator);
			
			mapView(TextWidget, WidgetMediator);
			mapView(PDFWidget, WidgetMediator);
			mapView(VideoWidget, WidgetMediator);
			mapView(ImageWidget, WidgetMediator);
			mapView(AudioWidget, WidgetMediator);
			mapView(ExerciseWidget, WidgetMediator);
			mapView(AuthoringWidget, WidgetMediator);
			// gh#867
			mapView(AnimationWidget, WidgetMediator);
			// gh#869
			mapView(OrchidWidget, WidgetMediator);
			// gh#866
			mapView(SelectorWidget, WidgetMediator);
			// gh#865
			mapView(GroupWidget, WidgetMediator);
		}
		
	}
	
}