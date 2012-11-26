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
		
		public static const XHTML_LOAD:String = "bb/xhtml_load";
		public static const XHTML_LOADED:String = "bb/xhtml_loaded";
		public static const XHTML_LOAD_IOERROR:String = "bb/xhtml_load_ioerror";
		
		public static const PROGRESS_DATA_LOADED:String = "bb/progress_data_loaded";
		public static const PROGRESS_DATA_LOAD:String = "bb/progress_data_load";
		
		public static const SESSION_START:String = "bb/session_start";
		public static const SESSION_STARTED:String = "bb/session_started";
		public static const SESSION_STOP:String = "bb/session_stop";
		public static const SESSION_STOPPED:String = "bb/session_stopped";
		public static const SCORE_WRITE:String = "bb/score_write";
		public static const SCORE_WRITTEN:String = "bb/score_written";
		
		public static const USER_UPDATE:String = "bb/user_update";
		public static const USER_UPDATED:String = "bb/user_updated";
		
		// The notifications are sent when the user answers a question
		public static const QUESTION_NODE_ANSWER:String = "bb/question_node_answer";
		public static const QUESTION_STRING_ANSWER:String = "bb/question_string_answer";
		public static const QUESTION_INCORRECT_ANSWER:String = "bb/question_incorrect_answer";
		public static const QUESTION_ANSWERED:String = "bb/question_answered";
		
		// Dictionary behaviour
		public static const WORD_CLICK:String = "bb/word_click";
		
		// Exercise navigation notifications
		public static const EXERCISE_RESTART:String = "bb/exercise_restart";
		public static const EXERCISE_TRY_AGAIN:String = "bb/exercise_try_again";
		public static const EXERCISE_SHOW_NEXT:String = "bb/exercise_show_next";
		public static const EXERCISE_SHOW_PREVIOUS:String = "bb/exercise_show_previous";
		public static const EXERCISE_SHOW_OFFSET:String = "bb/exercise_show_offset";
		public static const EXERCISE_SHOW_FEEDBACK:String = "bb/exercise_show_feedback";
		
		// These are sent by XHTMLExerciseMediator when exercises start and stop.
		public static const EXERCISE_START:String = "bb/exercise_start";
		public static const EXERCISE_STARTED:String = "bb/exercise_started";
		public static const EXERCISE_STOP:String = "bb/exercise_stop";
		public static const EXERCISE_STOPPED:String = "bb/exercise_stopped";
		
		// This notification is sent when the user clicks the print button
		public static const EXERCISE_PRINT:String = "bb/exercise_print";
		public static const EXERCISE_PRINTED:String = "bb/exercise_printed";
		
		public static const MARKING_SHOW:String = "bb/marking_show";
		public static const MARKING_SHOWN:String = "bb/marking_shown";
		
		public static const ANSWERS_SHOW:String = "bb/answers_show";
		
		public static const FEEDBACK_SHOW:String = "bb/feedback_show";
		
		// The specific title will want to implement actions on these two notifications
		public static const EXERCISE_SHOW:String = "bb/exercise_show";
		public static const EXERCISE_SECTION_FINISHED:String = "bb/exercise_section_finished";
		
		// Warnings that you are about to do something that will lose your data
		public static const WARN_DATA_LOSS:String = "bb/warn_data_loss";
		
		// Check that the same user is only logged in once
		public static const FAILED_INSTANCE_CHECK:String = "bb/failed_instance_check";
		
		// Handle errors in loading data
		public static const INVALID_PROGRESS_DATA:String = "bb/invalid_progress_data";
		
		public static const CLOSE_ALL_POPUPS:String = "bb/close_all_popups";
		
	}
	
}