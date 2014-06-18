package com.clarityenglish.rotterdam.builder {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.controller.ShowErrorCommand;
	import com.clarityenglish.rotterdam.CommonAbstractApplicationFacade;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.builder.controller.BuilderStartupCommand;
	import com.clarityenglish.rotterdam.builder.controller.ContentWindowShowCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseCreateCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseCreateWindowShowCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseDeleteCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseExportCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseImportCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseImportedCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseSaveCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseSaveErrorCommand;
	import com.clarityenglish.rotterdam.builder.controller.CourseSavedCommand;
	import com.clarityenglish.rotterdam.builder.controller.HelpPublishWindowShowCommand;
	import com.clarityenglish.rotterdam.builder.controller.MediaCloudSelectCommand;
	import com.clarityenglish.rotterdam.builder.controller.MediaSelectCommand;
	import com.clarityenglish.rotterdam.builder.controller.MediaUploadCommand;
	import com.clarityenglish.rotterdam.builder.controller.MediaUploadErrorCommand;
	import com.clarityenglish.rotterdam.builder.controller.PreviewModeCommand;
	import com.clarityenglish.rotterdam.builder.controller.SendWelcomeEmailCommand;
	import com.clarityenglish.rotterdam.builder.controller.UnitCopyCommand;
	import com.clarityenglish.rotterdam.builder.controller.UnitPasteCommand;
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
	import com.clarityenglish.rotterdam.builder.view.error.SavingErrorMediator;
	import com.clarityenglish.rotterdam.builder.view.error.SavingErrorView;
	import com.clarityenglish.rotterdam.builder.view.filemanager.FileManagerMediator;
	import com.clarityenglish.rotterdam.builder.view.filemanager.FileManagerView;
	import com.clarityenglish.rotterdam.builder.view.help.HelpMediator;
	import com.clarityenglish.rotterdam.builder.view.help.HelpView;
	import com.clarityenglish.rotterdam.builder.view.schedule.HelpScheduleMediator;
	import com.clarityenglish.rotterdam.builder.view.schedule.HelpScheduleView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.ContentSelectorMediator;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.ContentSelectorView;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.UnitEditorMediator;
	import com.clarityenglish.rotterdam.builder.view.uniteditor.UnitEditorView;
	import com.clarityenglish.rotterdam.controller.CourseStartCommand;
	import com.clarityenglish.rotterdam.controller.RotterdamStartupStateMachineCommand;
	import com.clarityenglish.rotterdam.view.schedule.ScheduleMediator;
	import com.clarityenglish.rotterdam.view.schedule.ScheduleView;
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
			mapView(ScheduleView, ScheduleMediator);
			mapView(SettingsView, SettingsMediator);
			mapView(CourseCreateView, CourseCreateMediator);
			mapView(HelpScheduleView, HelpScheduleMediator);
			mapView(HelpView, HelpMediator);
			// gh#751
			mapView(SavingErrorView, SavingErrorMediator);
			
			// gh#88 (see CommonAbstractApplicationFacade for comments on this)
			registerCommand(BBNotifications.MENU_XHTML_LOADED, CourseStartCommand);
			
			registerCommand(RotterdamNotifications.COURSE_CREATE, CourseCreateCommand);
			registerCommand(RotterdamNotifications.COURSE_SAVE, CourseSaveCommand);
			registerCommand(RotterdamNotifications.COURSE_SAVED, CourseSavedCommand);
			registerCommand(RotterdamNotifications.COURSE_DELETE, CourseDeleteCommand);
			// gh#233
			registerCommand(RotterdamNotifications.COURSE_EXPORT, CourseExportCommand);
			registerCommand(RotterdamNotifications.COURSE_IMPORT, CourseImportCommand);
			registerCommand(RotterdamNotifications.COURSE_IMPORTED, CourseImportedCommand);
			
			registerCommand(RotterdamNotifications.WIDGET_ADD, WidgetAddCommand);
			registerCommand(RotterdamNotifications.WIDGET_DELETE, WidgetDeleteCommand);
			
			registerCommand(RotterdamNotifications.TEXT_WIDGET_ADD, TextWidgetAddCommand);
			registerCommand(RotterdamNotifications.PDF_WIDGET_ADD, PDFWidgetAddCommand);
			registerCommand(RotterdamNotifications.VIDEO_WIDGET_ADD, VideoWidgetAddCommand);
			registerCommand(RotterdamNotifications.IMAGE_WIDGET_ADD, ImageWidgetAddCommand);
			registerCommand(RotterdamNotifications.AUDIO_WIDGET_ADD, AudioWidgetAddCommand);
			registerCommand(RotterdamNotifications.EXERCISE_WIDGET_ADD, ExerciseWidgetAddCommand);
			
			// gh#64
			registerCommand(RotterdamNotifications.VIDEO_LOAD_ERROR, ShowErrorCommand);
			
			// gh#751
			registerCommand(RotterdamNotifications.COURSE_SAVE_ERROR, CourseSaveErrorCommand);
			
			registerCommand(RotterdamNotifications.MEDIA_SELECT, MediaSelectCommand);
			registerCommand(RotterdamNotifications.MEDIA_CLOUD_SELECT, MediaCloudSelectCommand);
			registerCommand(RotterdamNotifications.MEDIA_UPLOAD, MediaUploadCommand);
			registerCommand(RotterdamNotifications.MEDIA_UPLOAD_ERROR, MediaUploadErrorCommand);
			
			registerCommand(RotterdamNotifications.CONTENT_WINDOW_SHOW, ContentWindowShowCommand);
			registerCommand(RotterdamNotifications.COURSE_CREATE_WINDOW_SHOW, CourseCreateWindowShowCommand);
			//alice s
			registerCommand(RotterdamNotifications.HELP_PUBLISH_WINDOW_SHOW, HelpPublishWindowShowCommand);
			
			// gh#110
			registerCommand(RotterdamNotifications.UNIT_COPY, UnitCopyCommand);
			registerCommand(RotterdamNotifications.UNIT_PASTE, UnitPasteCommand);
			
			// gh#91
			registerCommand(RotterdamNotifications.PREVIEW_SHOW, PreviewModeCommand);
			registerCommand(RotterdamNotifications.PREVIEW_HIDE, PreviewModeCommand);
			
			// gh#122
			registerCommand(RotterdamNotifications.SEND_WELCOME_EMAIL, SendWelcomeEmailCommand);
			
			// Remove the default Bento state machine (which isn't quite applicable to the builder) and replace it with a new one
			removeCommand(CommonNotifications.CONFIG_LOADED);
			registerCommand(CommonNotifications.CONFIG_LOADED, RotterdamStartupStateMachineCommand);
			
			registerCommand(BBNotifications.STARTUP, BuilderStartupCommand);
		}
		
	}
	
}