package com.clarityenglish.bento {
	
	public class BBNotifications {
		
		public static const STARTUP:String = "startup";
		
		public static const XHTML_LOAD:String = "xhtml_load";
		public static const XHTML_LOADED:String = "xhtml_loaded";
		
		public static const PROGRESS_DATA_LOADED:String = "progress_data_loaded";
		public static const PROGRESS_DATA_LOAD:String = "progress_data_load";
		
		public static const SESSION_START:String = "session_start";
		public static const SESSION_STARTED:String = "session_started";
		public static const SESSION_STOP:String = "session_stop";
		public static const SESSION_STOPPED:String = "session_stopped";
		public static const SCORE_WRITTEN:String = "score_written";
		
		// The notifications are sent when the user answers a question
		public static const QUESTION_NODE_ANSWER:String = "question_node_answer";
		public static const QUESTION_STRING_ANSWER:String = "question_string_answer";
		public static const QUESTION_ANSWERED:String = "question_answered";
		
		// These notifications are sent when the user clicks the next or previous buttons
		public static const EXERCISE_SHOW_NEXT:String = "exercise_show_next";
		public static const EXERCISE_SHOW_PREVIOUS:String = "exercise_show_previous";
		
		// These are sent by XHTMLExerciseMediator when exercises start and stop.
		public static const EXERCISE_START:String = "exercise_start";
		public static const EXERCISE_STARTED:String = "exercise_started";
		public static const EXERCISE_STOP:String = "exercise_stop";
		public static const EXERCISE_STOPPED:String = "exercise_stopped";
		
		public static const SHOW_ANSWERS:String = "show_answers";
		public static const SHOW_FEEDBACK:String = "show_feedback";
		public static const SHOW_MARKING:String = "show_marking";
		
		// The specific title will want to implement actions on these two notifications
		public static const EXERCISE_SHOW:String = "exercise_show";
		public static const EXERCISE_SECTION_FINISHED:String = "exercise_section_finished";
	}
	
}