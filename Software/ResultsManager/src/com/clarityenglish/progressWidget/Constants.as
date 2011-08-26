package com.clarityenglish.progressWidget {
	import flash.net.URLRequestMethod;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class Constants {
		
		/** Making this false activates various debug and test friendly attributes in the application */
		public static function get DEBUG_MODE():Boolean {
			include "/../../../return_debug_mode.txt";
		}
		
		private static var _host:String;
		
		public static function get HOST():String {
			if (_host) return _host;
			
			include "/../../../return_test_host.txt";
		}
		
		public static function set HOST(h:String):void {
			_host = h;
		}
		
		public static var SESSIONID:String = "";
		
		public static function get AMFPHP_BASE():String {
			return HOST + "amfphp/";
		}
		
		public static var LOGO_FOLDER:String = "title_logos";
		public static var HELP_FOLDER:String = "Help";
		
		public static var AMFPHP_SERVICE:String = "PWService";
		
		public static var URL_REQUEST_METHOD:String = URLRequestMethod.POST;
		
		/**
		 * The ID of the logged in user
		 */
		public static var userID:String;
		
		/**
		 * The type of the logged in user - either:
		 * 
		 * User.USER_TYPE_TEACHER
		 * User.USER_TYPE_ADMINISTRATOR
		 * User.USER_TYPE_REPORTER
		 * User.USER_TYPE_AUTHOR
		 */
		public static var userType:Number;
		public static var userStartDate:Date;
		
		/**
		 * The version of the software, used to tie bugs and version control together.
		 */
		public static var version:String = "3.0.5";
		
		/**
		 * Use this section to define colours and other style settings that are not in css
		 */
		public static const popupBackgroundColour:uint = 0xE8E750;
		public static const mainBackgroundColour:uint = 0x5B5072;
		
	}
	
}