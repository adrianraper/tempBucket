package com.clarityenglish.dms {
	import flash.net.URLRequestMethod;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class Constants {
		
		/**
		 * The version of the software, used to tie bugs and version control together.
		 * Keep this in sync with RM since there is so much common code.
		 */
		public static var version:String = "3.7.2.987";
		
		/** Making this false activates various debug and test friendly attributes in the application */
		public static function get DEBUG_MODE():Boolean {
			include "/../../../return_debug_mode.txt";
		}
		
		/** This is used to determine what to open when the user selected 'Open in Results Manager' in DMS.  This page must accept
		 *  username and password as request parameters */
		public static function get RESULTS_MANAGER_URL():String {
			//include "/../../../return_resultsmanager_url.txt";
			return 'ResultsManager/Start.php';
		}
		
		/** This is overridden by any passed parameter */
		//public static var HOST:String = "http://clarity.localhost/";
		//public static var HOST:String = "http://localhost/resultsmanager/";
		//public static var HOST:String = "http://192.168.8.11/Fixbench/Software/ResultsManager/";
		//public static var HOST:String = "http://claritydata/Clarity/Software/ResultsManager/";
		
		private static var _host:String;
		
		public static function get HOST():String {
			if (_host) return _host;
			
			include "/../../../return_test_host.txt";
		}
		
		public static function set HOST(h:String):void {
			_host = h;
		}
		
		public static var SESSIONID:String = "";
		
		public static var SWFBRIDGEID:String = "";
		
		public static function get AMFPHP_BASE():String {
			return HOST + "amfphp/";
		}
		
		public static var AMFPHP_SERVICE:String = "DMSService";
		
		public static var LOGO_FOLDER:String = "title_logos";
		
		public static var URL_REQUEST_METHOD:String = URLRequestMethod.GET;
		
		/**
		 * The ID of the logged in user
		 */
		public static var userID:String;
		
		/**
		 * The type of the logged in user - for DMS this is always User.USER_TYPE_DMS
		 */
		public static var userType:Number;
		
		/**
		 * The database connection string
		 */
		public static var dbDetails:String;
		
		/**
		 * This is used to set a filtering string when you login so you only ever see a few accounts.
		 */
		public static var filterString:String;
		
		/**
		 * Use this section to define colours and other style settings that are not in css
		 */
		public static const popupBackgroundColour:uint = 0xE8E750;
		public static const mainBackgroundColour:uint = 0x5B5072;
	}
	
}