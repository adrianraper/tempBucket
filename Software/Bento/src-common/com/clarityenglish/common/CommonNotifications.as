package com.clarityenglish.common {
	
	/**
	 * ...
	 * @author ...
	 */
	public class CommonNotifications {
		
		public static const LOGIN:String = "login";
		public static const LOGGED_IN:String = "logged_in";
		
		public static const LOGOUT:String = "logout";
		public static const LOGGED_OUT:String = "logged_out";
		
		public static const CONFIG_LOAD:String = "config_load";
		public static const CONFIG_LOADED:String = "config_loaded";

		// 341
		public static const ADD_USER:String = "add_user";
		public static const ADDED_USER:String = "added_user";
		public static const ADD_USER_FAILED:String = "added_user_failed";
		public static const CONFIRM_NEW_USER:String = "confirm_new_user";
		
		// #322
		public static const ACCOUNT_LOAD:String = "account_load";
		public static const ACCOUNT_LOADED:String = "account_loaded";
		
		// gh#21
		public static const ACCOUNT_RELOAD:String = "account_reload";
		//public static const ACCOUNT_RELOADED:String = "account_reloaded";
		
		public static const INVALID_LOGIN:String = "invalid_login";
		public static const INVALID_DATA:String = "invalid_data";
		
		public static const COPY_LOAD:String = "copy_load";
		public static const COPY_LOADED:String = "copy_loaded";
		
		public static const DICTIONARIES_LOADED:String = "dictionaries_loaded";
		
		public static const CHART_TEMPLATES_LOADED:String = "chart_templates_loaded";
		
		public static const BENTO_ERROR:String = "bento_error"; // we might be able to replace all other errors with this?
		public static const CONFIG_ERROR:String = "config_error";
		public static const COPY_ERROR:String = "copy_error";
		public static const PROGRESS_LOAD_ERROR:String = "progress_load_error";
		public static const UPDATE_FAILED:String = "update_failed";
		
		public static const TRACE_NOTICE:String = "trace_notice";
		public static const TRACE_WARNING:String = "trace_warning";
		public static const TRACE_ERROR:String = "trace_error";
		
		public static const EXIT:String = "exit";
		
		public static const PERFORMANCE_LOG:String = "performance_log";
		
		public static const GESTURE_SWIPE_LEFT:String = "gesture_swipe_left";
		public static const GESTURE_SWIPE_RIGHT:String = "gesture_swipe_right";
		
		// gh#1067
		public static const WRITE_MEMORY:String = "write_memory";
	}
	
}