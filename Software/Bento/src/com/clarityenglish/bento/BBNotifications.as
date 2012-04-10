﻿package com.clarityenglish.bento {
	
	public class BBNotifications {
		
		public static const STARTUP:String = "startup";
		
		public static const ACTIVITY_TIMER_RESET:String = "activity_timer_reset";
		
		public static const MENU_XHTML_LOAD:String = "menu_xhtml_load";
		public static const MENU_XHTML_LOADED:String = "menu_xhtml_loaded";
		
		public static const XHTML_LOAD:String = "xhtml_load";
		public static const XHTML_LOADED:String = "xhtml_loaded";
		
		public static const PROGRESS_DATA_LOADED:String = "progress_data_loaded";
		public static const PROGRESS_DATA_LOAD:String = "progress_data_load";
		
		public static const SESSION_START:String = "session_start";
		public static const SESSION_STARTED:String = "session_started";
		public static const SESSION_STOP:String = "session_stop";
		public static const SESSION_STOPPED:String = "session_stopped";
		public static const SCORE_WRITE:String = "score_write";
		public static const SCORE_WRITTEN:String = "score_written";
		
		public static const USER_UPDATE:String = "user_update";
		public static const USER_UPDATED:String = "user_updated";
		
		public static const COURSE_SELECT:String = "course_select";
		public static const COURSE_SELECTED:String = "course_selected";
		
		// The notifications are sent when the user answers a question
		public static const QUESTION_NODE_ANSWER:String = "question_node_answer";
		public static const QUESTION_STRING_ANSWER:String = "question_string_answer";
		public static const QUESTION_INCORRECT_ANSWER:String = "question_incorrect_answer";
		public static const QUESTION_ANSWERED:String = "question_answered";
		
		// Dictionary behaviour
		public static const WORD_CLICK:String = "word_click";
		
		// Exercise navigation notifications
		public static const EXERCISE_RESTART:String = "exercise_restart";
		public static const EXERCISE_TRY_AGAIN:String = "exercise_try_again";
		public static const EXERCISE_SHOW_NEXT:String = "exercise_show_next";
		public static const EXERCISE_SHOW_PREVIOUS:String = "exercise_show_previous";
		public static const EXERCISE_SHOW_FEEDBACK:String = "exercise_show_feedback";
		
		// These are sent by XHTMLExerciseMediator when exercises start and stop.
		public static const EXERCISE_START:String = "exercise_start";
		public static const EXERCISE_STARTED:String = "exercise_started";
		public static const EXERCISE_STOP:String = "exercise_stop";
		public static const EXERCISE_STOPPED:String = "exercise_stopped";
		
		// This notification is sent when the user clicks the print button
		public static const EXERCISE_PRINT:String = "exercise_print";
		public static const EXERCISE_PRINTED:String = "exercise_printed";
		
		public static const MARKING_SHOW:String = "marking_show";
		public static const MARKING_SHOWN:String = "marking_shown";
		
		public static const ANSWERS_SHOW:String = "answers_show";
		
		public static const FEEDBACK_SHOW:String = "feedback_show";
		
		// The specific title will want to implement actions on these two notifications
		public static const EXERCISE_SHOW:String = "exercise_show";
		public static const EXERCISE_SECTION_FINISHED:String = "exercise_section_finished";
		
		// Warnings that you are about to do something that will lose your data
		public static const WARN_DATA_LOSS:String = "warn_data_loss";
		
		// Check that the same user is only logged in once
		public static const FAILED_INSTANCE_CHECK:String = "failed_instance_check";
		
		// Handle errors in loading data
		public static const INVALID_PROGRESS_DATA:String = "invalid_progress_data";
		
	}
	
}