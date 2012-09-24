package com.clarityenglish.rotterdam.builder {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.rotterdam.CommonAbstractApplicationFacade;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.builder.controller.BuilderStartupCommand;
	import com.clarityenglish.rotterdam.builder.controller.BuilderStartupStateMachineCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseCreateCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseSaveCommand;
	import com.clarityenglish.rotterdam.builder.controller.MediaUploadCommand;
	import com.clarityenglish.rotterdam.builder.controller.WidgetAddCommand;
	import com.clarityenglish.rotterdam.builder.controller.WidgetDeleteCommand;
	import com.clarityenglish.rotterdam.builder.view.courseeditor.CourseEditorMediator;
	import com.clarityenglish.rotterdam.builder.view.courseeditor.CourseEditorView;
	import com.clarityenglish.rotterdam.builder.view.courseeditor.ToolBarMediator;
	import com.clarityenglish.rotterdam.builder.view.courseeditor.ToolBarView;
	import com.clarityenglish.rotterdam.builder.view.filemanager.FileManagerMediator;
	import com.clarityenglish.rotterdam.builder.view.filemanager.FileManagerView;
	import com.clarityenglish.rotterdam.builder.view.login.LoginView;
	import com.clarityenglish.rotterdam.builder.view.title.TitleMediator;
	import com.clarityenglish.rotterdam.builder.view.title.TitleView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.UnitEditorMediator;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.UnitEditorView;
	import com.clarityenglish.rotterdam.controller.CourseStartCommand;
	
	public class BuilderApplicationFacade extends CommonAbstractApplicationFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new BuilderApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(LoginView, LoginMediator);
			mapView(TitleView, TitleMediator);
			mapView(CourseEditorView, CourseEditorMediator);
			mapView(ToolBarView, ToolBarMediator);
			mapView(UnitEditorView, UnitEditorMediator);
			mapView(FileManagerView, FileManagerMediator);
			
			registerCommand(RotterdamNotifications.COURSE_CREATE, CourseCreateCommand);
			registerCommand(RotterdamNotifications.COURSE_SAVE, CourseSaveCommand);
			registerCommand(RotterdamNotifications.WIDGET_ADD, WidgetAddCommand);
			registerCommand(RotterdamNotifications.WIDGET_DELETE, WidgetDeleteCommand);
			registerCommand(RotterdamNotifications.MEDIA_UPLOAD, MediaUploadCommand);
			
			// Remove the default Bento state machine (which isn't quite applicable to the builder) and replace it with a new one
			removeCommand(CommonNotifications.CONFIG_LOADED);
			registerCommand(CommonNotifications.CONFIG_LOADED, BuilderStartupStateMachineCommand);
			
			registerCommand(BBNotifications.STARTUP, BuilderStartupCommand);
		}
		
	}
	
}