package com.clarityenglish.resultsmanager {
	import flash.net.URLRequestMethod;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class Constants {
		
		/**
		 * The version of the software, used to tie bugs and version control together.
		 */
		public static var version:String = "3.8.1489";
		
		/** Making this false activates various debug and test friendly attributes in the application */
		public static function get DEBUG_MODE():Boolean {
			include "/../../../return_debug_mode.txt";
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
		
		public static function get AMFPHP_BASE():String {
			return HOST + "amfphp/";
		}
		
		public static var UPLOAD_SCRIPT:String = "upload.php";
		
		public static var LOGO_FOLDER:String = "title_logos";
		public static var HELP_FOLDER:String = "Help";
		
		public static var AMFPHP_SERVICE:String = "ClarityService";
		
		public static var URL_REQUEST_METHOD:String = URLRequestMethod.POST;
		public static var BASE_FOLDER:String = 'www.ClarityEnglish.com';
		
		/**
		 * The ID of the logged in user
		 */
		public static var userID:String;
		// TODO Just temporary
		public static var userName:String;
		public static var password:String;
		public static var accountName:String;
		// Getting worse and worse!
		public static var maxAuthors:Number;
		public static var maxTeachers:Number;
		public static var maxReporters:Number;
		
		/**
		 * The type of the logged in user - either:
		 * 
		 * User.USER_TYPE_TEACHER
		 * User.USER_TYPE_ADMINISTRATOR
		 * User.USER_TYPE_REPORTER
		 * User.USER_TYPE_AUTHOR
		 */
		public static var userType:Number;
		
		/**
		 * If there are more than a certain number of manageables in the teachers tree students will be ignored for performance reasons.
		 */
		[Bindable]
		public static var noStudents:Boolean;
		public static var manageablesCount:Number;
		
		/**
		 * Read from database for account root information
		 * TODO, maybe this should be an Account instance and NOT saved in Constants!
		 */
		public static var prefix:String;
		public static var groupID:String;
		public static var parentGroupIDs:Array;
		public static var licenceType:Number;
		
		/**
		 * Use this section to define colours and other style settings that are not in css
		 */
		public static const popupBackgroundColour:uint = 0xfce999;
		public static const mainBackgroundColour:uint = 0x5B5072;
		
		/**
		 * Use this section for error codes that come from outside RM
		public static const errorCodeOrchid:Object = {	'205':"Unknown reason", 
														'206':"Duplicate user name",
														'203':"No such learner ID",
														'204':"Password doesn't match",
														'207':"Unknown reason",
														'208':"This user's account has expired",
														'209':"All licences have been used"};
		*/
	}
	
}