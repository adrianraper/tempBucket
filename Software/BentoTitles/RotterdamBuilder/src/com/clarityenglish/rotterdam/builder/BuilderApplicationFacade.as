package com.clarityenglish.rotterdam.builder {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.controller.BentoResetCommand;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.CommonAbstractApplicationFacade;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.builder.controller.BuilderStartupCommand;
	import com.clarityenglish.rotterdam.builder.controller.ContentWindowShowCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseCreateCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseCreateWindowShowCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseDeleteCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseSaveCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseSavedCommand;
	import com.clarityenglish.rotterdam.builder.controller.MediaCloudSelectCommand;
	import com.clarityenglish.rotterdam.builder.controller.MediaSelectCommand;
	import com.clarityenglish.rotterdam.builder.controller.MediaUploadCommand;
	import com.clarityenglish.rotterdam.builder.controller.WidgetAddCommand;
	import com.clarityenglish.rotterdam.builder.controller.WidgetDeleteCommand;
	import com.clarityenglish.rotterdam.builder.controller.widgets.AudioWidgetAddCommand;
	import com.clarityenglish.rotterdam.builder.controller.widgets.ExerciseWidgetAddCommand;
	import com.clarityenglish.rotterdam.builder.controller.widgets.ImageWidgetAddCommand;
	import com.clarityenglish.rotterdam.builder.controller.widgets.PDFWidgetAddCommand;
	import com.clarityenglish.rotterdam.builder.controller.widgets.TextWidgetAddCommand;
	import com.clarityenglish.rotterdam.builder.controller.widgets.VideoWidgetAddCommand;
	import com.clarityenglish.rotterdam.builder.model.ContentProxy;
	import com.clarityenglish.rotterdam.builder.view.course.ToolBarMediator;
	import com.clarityenglish.rotterdam.builder.view.course.ToolBarView;
	import com.clarityenglish.rotterdam.builder.view.courseselector.CourseCreateMediator;
	import com.clarityenglish.rotterdam.builder.view.courseselector.CourseCreateView;
	import com.clarityenglish.rotterdam.builder.view.filemanager.FileManagerMediator;
	import com.clarityenglish.rotterdam.builder.view.filemanager.FileManagerView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.ContentSelectorMediator;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.ContentSelectorView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.UnitEditorMediator;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.UnitEditorView;
	import com.clarityenglish.rotterdam.controller.RotterdamStartupStateMachineCommand;
	import com.clarityenglish.rotterdam.view.settings.SettingsMediator;
	import com.clarityenglish.rotterdam.view.settings.SettingsView;
	
	public class BuilderApplicationFacade extends CommonAbstractApplicationFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new BuilderApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			registerProxy(new ContentProxy());
			
			mapView(ToolBarView, ToolBarMediator);
			mapView(UnitEditorView, UnitEditorMediator);
			mapView(FileManagerView, FileManagerMediator);
			mapView(ContentSelectorView, ContentSelectorMediator);
			mapView(SettingsView, SettingsMediator);
			mapView(CourseCreateView, CourseCreateMediator);
			
			registerCommand(RotterdamNotifications.COURSE_CREATE, CourseCreateCommand);
			registerCommand(RotterdamNotifications.COURSE_SAVE, CourseSaveCommand);
			registerCommand(RotterdamNotifications.COURSE_SAVED, CourseSavedCommand);
			registerCommand(RotterdamNotifications.COURSE_DELETE, CourseDeleteCommand);
			
			// gh#13
			registerCommand(RotterdamNotifications.COURSE_RESET, BentoResetCommand);
			
			registerCommand(RotterdamNotifications.WIDGET_ADD, WidgetAddCommand);
			registerCommand(RotterdamNotifications.WIDGET_DELETE, WidgetDeleteCommand);
			
			registerCommand(RotterdamNotifications.TEXT_WIDGET_ADD, TextWidgetAddCommand);
			registerCommand(RotterdamNotifications.PDF_WIDGET_ADD, PDFWidgetAddCommand);
			registerCommand(RotterdamNotifications.VIDEO_WIDGET_ADD, VideoWidgetAddCommand);
			registerCommand(RotterdamNotifications.IMAGE_WIDGET_ADD, ImageWidgetAddCommand);
			registerCommand(RotterdamNotifications.AUDIO_WIDGET_ADD, AudioWidgetAddCommand);
			registerCommand(RotterdamNotifications.EXERCISE_WIDGET_ADD, ExerciseWidgetAddCommand);
			
			registerCommand(RotterdamNotifications.MEDIA_SELECT, MediaSelectCommand);
			registerCommand(RotterdamNotifications.MEDIA_CLOUD_SELECT, MediaCloudSelectCommand);
			registerCommand(RotterdamNotifications.MEDIA_UPLOAD, MediaUploadCommand);
			
			registerCommand(RotterdamNotifications.CONTENT_WINDOW_SHOW, ContentWindowShowCommand);
			registerCommand(RotterdamNotifications.COURSE_CREATE_WINDOW_SHOW, CourseCreateWindowShowCommand);
			
			// Remove the default Bento state machine (which isn't quite applicable to the builder) and replace it with a new one
			removeCommand(CommonNotifications.CONFIG_LOADED);
			registerCommand(CommonNotifications.CONFIG_LOADED, RotterdamStartupStateMachineCommand);
			
			registerCommand(BBNotifications.STARTUP, BuilderStartupCommand);
		}
		
	}
	
}