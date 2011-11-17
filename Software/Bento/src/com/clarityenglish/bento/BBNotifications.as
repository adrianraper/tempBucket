package com.clarityenglish.bento {
	
	public class BBNotifications {
		
		public static const STARTUP:String = "startup";
		
		public static const XHTML_LOAD:String = "xhtml_load";
		public static const XHTML_LOADED:String = "xhtml_loaded";
		
		public static const PROGRESS_DATA_LOADED:String = "progress_data_loaded";
		public static const PROGRESS_DATA_LOAD:String = "progress_data_load";
		
		public static const QUESTION_NODE_ANSWER:String = "question_node_answer";
		public static const QUESTION_STRING_ANSWER:String = "question_string_answer";
		public static const QUESTION_ANSWERED:String = "question_answered";
		
		public static const EXERCISE_SHOW_NEXT:String = "exercise_show_next";
		public static const EXERCISE_SHOW_PREVIOUS:String = "exercise_show_previous";
		
		public static const SHOW_ANSWERS:String = "show_answers";
		public static const SHOW_FEEDBACK:String = "show_feedback";
		public static const SHOW_MARKING:String = "show_marking";
		
		// The specific title will want to implement actions on these two notifications
		public static const EXERCISE_SHOW:String = "exercise_show";
		public static const EXERCISE_SECTION_FINISHED:String = "exercise_section_finished";
	}
	
}