﻿package com.clarityenglish.rotterdam {
	
	public class RotterdamNotifications {
		
		// Course notifications
		public static const COURSE_CREATE:String = "rotterdam/course_create";
		public static const COURSE_CREATED:String = "rotterdam/course_created";
		
		public static const COURSE_DELETE:String = "rotterdam/course_delete";
		public static const COURSE_DELETED:String = "rotterdam/course_deleted";
		
		public static const COURSE_SAVE:String = "rotterdam/course_save";
		public static const COURSE_SAVED:String = "rotterdam/course_saved";
		
		// gh#13
		public static const COURSE_RESET:String = "rotterdam/course_reset";
		
		// Widget notifications
		public static const WIDGET_SELECT:String = "rotterdam/widget_select";
		public static const WIDGET_ADD:String = "rotterdam/widget_add";
		public static const WIDGET_DELETE:String = "rotterdam/widget_delete";
		public static const WIDGET_EDIT:String = "rotterdam/widget_edit";
		//gh#187
		public static const WIDGET_RENAME:String = "rotterdam/widget_rename";
		
		public static const TEXT_WIDGET_ADD:String = "rotterdam/text_widget_add";
		public static const PDF_WIDGET_ADD:String = "rotterdam/pdf_widget_add";
		public static const VIDEO_WIDGET_ADD:String = "rotterdam/video_widget_add";
		public static const IMAGE_WIDGET_ADD:String = "rotterdam/image_widget_add";
		public static const AUDIO_WIDGET_ADD:String = "rotterdam/audio_widget_add";
		public static const EXERCISE_WIDGET_ADD:String = "rotterdam/exercise_widget_add";
		
		public static const COURSE_CREATE_WINDOW_SHOW:String = "rotterdam/course_create_window_show";
		public static const CONTENT_WINDOW_SHOW:String = "rotterdam/content_window_show";
		
		// gh#64
		public static const VIDEO_LOAD_ERROR:String = "rotterdam/video_load_error";
		
		// gh#33
		public static const CONTENT_OPEN:String = "rotterdam/content_open";
		
		// Text notifications
		public static const TEXT_FORMAT:String = "rotterdam/text_format";
		public static const TEXT_SELECTED:String = "rotterdam/text_selected";
		// gh#306
		public static const CAPTION_SELECTED:String = "rotterdam/caption_selected";
		
		// Preview notifications
		public static const PREVIEW_SHOW:String = "rotterdam/preview_show";
		public static const PREVIEW_HIDE:String = "rotterdam/preview_hide";
				
		// Upload notifications
		public static const MEDIA_SELECT:String = "rotterdam/media_select";
		
		public static const MEDIA_CLOUD_SELECT:String = "rotterdam/media_cloud_select";
		
		public static const MEDIA_UPLOAD:String = "rotterdam/media_upload";
		public static const MEDIA_UPLOAD_START:String = "rotterdam/media_upload_start";
		public static const MEDIA_UPLOAD_PROGRESS:String = "rotterdam/media_upload_progress";
		public static const MEDIA_UPLOAD_ERROR:String = "rotterdam/media_upload_error";
		public static const MEDIA_UPLOADED:String = "rotterdam/media_uploaded";
		
		// Copy/paste unit gh#110
		public static const UNIT_COPY:String = "rotterdam/unit_copy";
		public static const UNIT_PASTE:String = "rotterdam/unit_paste";
		
		// alice s
		public static const HELP_PUBLISH_WINDOW_SHOW:String = "rotterdam/help_publish_window_show";

		// gh#122
		public static const SEND_WELCOME_EMAIL:String = "rotterdam/send_welcome_email"; 
		public static const WELCOME_EMAIL_SENT:String = "rotterdam/welcome_email_sent"; 
		
		// gh#221
		public static const WEB_URL_ADD:String = "rotterdam/web_url_add";
		public static const WEB_URL_CANCEL:String = "rotterdam/web_url_cancel";
	}
	
}