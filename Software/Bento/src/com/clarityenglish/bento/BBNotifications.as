package com.clarityenglish.bento {
	
	public class BBNotifications {
		
		public static const STARTUP:String = "bb/startup";
		
		public static const ACTIVITY_TIMER_RESET:String = "bb/activity_timer_reset";
		public static const BENTO_RESET:String = "bb/bento_reset";
		
		public static const LANGUAGE_CHANGE:String = "bb/language_change";
		public static const LANGUAGE_CHANGED:String = "bb/language_changed";
		
		public static const NETWORK_CHECK_AVAILABILITY:String = "bb/network_check_availability";
		public static const NETWORK_UNAVAILABLE:String = "bb/network_unavailable";
		public static const NETWORK_AVAILABLE:String = "bb/network_available";
		
		public static const MENU_XHTML_LOAD:String = "bb/menu_xhtml_load";
		public static const MENU_XHTML_LOADED:String = "bb/menu_xhtml_loaded";
		public static const MENU_XHTML_NOT_LOADED:String = "bb/menu_xhtml_not_loaded";
		
		public static const MENU_XHTML_RELOAD:String = "bb/menu_xhtml_reload";
		
		public static const XHTML_LOAD:String = "bb/xhtml_load";
		public static const XHTML_LOADED:String = "bb/xhtml_loaded";
		public static const XHTML_LOAD_IOERROR:String = "bb/xhtml_load_ioerror";
		public static const XHTML_RELOAD:String = "bb/xhtml_reload";
		
		public static const SESSION_START:String = "bb/session_start";
		public static const SESSION_STARTED:String = "bb/session_started";
		public static const SESSION_STOP:String = "bb/session_stop";
		public static const SESSION_STOPPED:String = "bb/session_stopped";
		public static const SCORE_WRITE:String = "bb/score_write";
		public static const SCORE_WRITTEN:String = "bb/score_written";
		
		// Selection and navigation notifications
		public static const SELECTED_NODE_CHANGE:String = "bb/selected_node_change";
		public static const SELECTED_NODE_CHANGED:String = "bb/selected_node_changed";
		
		public static const SELECTED_NODE_UP:String = "bb/selected_node_up";
		
		public static const COURSE_START:String = "bb/course_start";
		public static const COURSE_STARTED:String = "bb/course_started";
		public static const COURSE_STOP:String = "bb/course_stop";
		public static const COURSE_STOPPED:String = "bb/course_stopped";
		
		public static const UNIT_START:String = "bb/unit_start";
		public static const UNIT_STARTED:String = "bb/unit_started";
		public static const UNIT_STOP:String = "bb/unit_stop";
		public static const UNIT_STOPPED:String = "bb/unit_stopped";
		
		public static const EXERCISE_START:String = "bb/exercise_start";
		public static const EXERCISE_STARTED:String = "bb/exercise_started";
		public static const EXERCISE_STOP:String = "bb/exercise_stop";
		public static const EXERCISE_STOPPED:String = "bb/exercise_stopped";
		public static const EXERCISE_SWITCH:String = "bb/exercise_switch";
		public static const EXERCISE_SWITCHED:String = "bb/exercise_switched";
		
		public static const PDF_SHOW:String = "bb/pdf_show";
		
		// Account notifications
		public static const USER_UPDATE:String = "bb/user_update";
		public static const USER_UPDATED:String = "bb/user_updated";
		
		// The notifications are sent when the user answers a question
		public static const QUESTION_NODE_ANSWER:String = "bb/question_node_answer";
		public static const QUESTION_STRING_ANSWER:String = "bb/question_string_answer";
		public static const QUESTION_INCORRECT_ANSWER:String = "bb/question_incorrect_answer";
		public static const QUESTION_ANSWERED:String = "bb/question_answered";
		public static const QUESTION_CLEAR:String = "bb/question_clear";
		
		// Dictionary behaviour
		public static const WORD_CLICK:String = "bb/word_click";
		
		// Exercise navigation notifications
		public static const EXERCISE_RESTART:String = "bb/exercise_restart";
		public static const EXERCISE_TRY_AGAIN:String = "bb/exercise_try_again";
		public static const EXERCISE_SHOW_NEXT:String = "bb/exercise_show_next";
		public static const EXERCISE_SHOW_PREVIOUS:String = "bb/exercise_show_previous";
		public static const EXERCISE_SHOW_OFFSET:String = "bb/exercise_show_offset";
		public static const EXERCISE_SHOW_FEEDBACK:String = "bb/exercise_show_feedback";
		
		// This notification is sent when the user clicks the print button
		public static const EXERCISE_PRINT:String = "bb/exercise_print";
		public static const EXERCISE_PRINTED:String = "bb/exercise_printed";
		
		public static const MARKING_SHOW:String = "bb/marking_show";
		public static const MARKING_SHOWN:String = "bb/marking_shown";
		
		public static const ANSWERS_SHOW:String = "bb/answers_show";
		
		public static const FEEDBACK_SHOW:String = "bb/feedback_show";
		
		// gh#388
		// gh#413
		public static const GOT_QUESTION_FEEDBACK:String = "bb/got_question_feedback";
		public static const FEEDBACK_REMINDER_SHOW:String = "bb/feedback_reminder_show";
		
		// gh#90 - set items (which can be anything) dirty or clean
		public static const ITEM_DIRTY:String = "bb/item_dirty";
		public static const ITEM_CLEAN:String = "bb/item_clean";
		
		// DataProxy notifications
		public static const DATA_CHANGED:String = "bb/data_changed";
		
		// Warnings that you are about to do something that will lose your data
		public static const WARN_DATA_LOSS:String = "bb/warn_data_loss";
		
		// Check that the same user is only logged in once
		public static const FAILED_INSTANCE_CHECK:String = "bb/failed_instance_check";
		
		// Handle errors in loading data
		public static const INVALID_PROGRESS_DATA:String = "bb/invalid_progress_data";
		
		public static const CLOSE_ALL_POPUPS:String = "bb/close_all_popups";
		
		// gh#338
		public static const HINT_SHOW:String = "bb/hint_show";
		
		// gh#267
		public static const AUDIO_PLAYED:String = "bb/audio_played";
		
		// gh#267
		public static const RECORDER_SHOW:String = "bb/recorder_show";
	}
	
}