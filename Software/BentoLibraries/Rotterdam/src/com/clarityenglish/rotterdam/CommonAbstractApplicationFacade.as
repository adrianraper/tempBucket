package com.clarityenglish.rotterdam {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.rotterdam.controller.ContentOpenCommand;
	import com.clarityenglish.rotterdam.controller.CourseStartCommand;
	import com.clarityenglish.rotterdam.controller.UnitStartCommand;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.clarityenglish.rotterdam.view.course.CourseMediator;
	import com.clarityenglish.rotterdam.view.course.CourseView;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorMediator;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	import com.clarityenglish.rotterdam.view.login.LoginView;
	import com.clarityenglish.rotterdam.view.title.TitleMediator;
	import com.clarityenglish.rotterdam.view.title.TitleView;
	import com.clarityenglish.rotterdam.view.unit.UnitHeaderMediator;
	import com.clarityenglish.rotterdam.view.unit.UnitHeaderView;
	import com.clarityenglish.rotterdam.view.unit.UnitMediator;
	import com.clarityenglish.rotterdam.view.unit.UnitView;
	import com.clarityenglish.rotterdam.view.unit.WidgetMediator;
	import com.clarityenglish.rotterdam.view.unit.widgets.AudioWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ExerciseWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ImageWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.PDFWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.TextWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.VideoWidget;
	
	public class CommonAbstractApplicationFacade extends BentoFacade {
		
		override protected function initializeController():void {
			super.initializeController();
			
			registerProxy(new CourseProxy());
			
			/**
			 * GH #88 - ideally this should only be linked to MENU_XHTML_LOADED, but because of the complications of XHTMLProxy vs ProgressProxy this need to be linked
			 * to MENU_XHTML_LOADED for the builder and PROGRESS_DATA_LOADED for the player.  Therefore this notification is in BuilderApplicationFacade and 
			 * PlayerApplicationFacade respectively.
			 * 
			 * TODO: At some point we really need to consolidate XHTMLProxy and ProgressProxy!
			 */
			//registerCommand(BBNotifications.MENU_XHTML_LOADED, CourseStartCommand);
			
			registerCommand(RotterdamNotifications.UNIT_START, UnitStartCommand);
			registerCommand(RotterdamNotifications.CONTENT_OPEN, ContentOpenCommand);
			
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
		}
		
	}
	
}