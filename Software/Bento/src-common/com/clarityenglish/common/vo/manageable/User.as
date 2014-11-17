package com.clarityenglish.common.vo.manageable {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.vo.content.Title;
	
	import mx.core.IUID;
	
	import org.davekeen.util.DateUtil;
	
	/**
	* ...
	* @author Clarity
	*
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.manageable.User")]
	[Bindable]
	public class User extends Manageable implements IUID {
		
		public static const USER_TYPE_DMS_VIEWER:int = -2;
		public static const USER_TYPE_DMS:int = -1;
		public static const USER_TYPE_STUDENT:int = 0;
		public static const USER_TYPE_TEACHER:int = 1;
		public static const USER_TYPE_ADMINISTRATOR:int = 2;
		public static const USER_TYPE_AUTHOR:int = 3;
		public static const USER_TYPE_REPORTER:int = 4;
		
		/**
		 * The password of this user - this may or may not be MD5 hashed (determined in the license.txt file, but assume that its
		 * plain for the moment.
		 */
		public var password:String;
		
		/**
		 * -1 - DMS
		 * 0  - Student
		 * 1  - Teacher
		 * 2  - Administrator
		 * 3  - Author
		 * 4  - Reporter
		 */
		public var userType:Number;
		
		/**
		 * Another identification for the student - this does not mean the database id!
		 */
		public var studentID:String;
		
		/** The date that this user's account expires.  This is stored as an ANSI string (use DateUtils.dateToAnsiString to convert
		 *  Date to a valid String before storing it) */
		public var expiryDate:String;
		// v3.1 Added for EMU processing
		public var startDate:String;
		public var contactMethod:String;
		public var registrationDate:String;
		public var userProfileOption:Number = 0;
		public var registerMethod:String;
		
		/** 
		 * The user's birthday. 
		 * Change to use this as a 'key' date for the user.
		 * For Road to IELTS this will be the exam date/time.
		 * TODO. Change the name to keydate from birthday. 
		 *   Orchid php. ok
		 *   Orchid as. check
		 *   RM php. check
		 *   RM as. check
		 *   DMS php. check
		 *   DMS as. check
		 *   javascript login. check
		 * */
		public var birthday:String;
		
		public var email:String;
		public var country:String;
		public var city:String;
		// #319
		//public var company:String;
		
		// v3.3 Extra data from special imports
		public var fullName:String;
		
		// v3.4 Multi-group users
		public var userID:String;
		
		// gh#956
		//public var memory:String;
		
		public function User(data:Object = null) {
			if (data)
				buildUser(data);
		}
		
		// AR A temporary constructor. Used to populate data into a new user
		public function buildUser(data:Object):void {
			if (data.userID)
				this.id = data.userID;
			if (data.name)
				this.name = data.name;
			if (data.email)
				this.email = data.email;
			if (data.studentID)
				this.studentID = data.studentID;
			if (data.password)
				this.password = data.password;
		}
		/**
		 * A single user always has a userCount of 1
		 */
		override public function get userCount():uint {
			return 1;
		}
		
		// TODO: Check that this still works with the excel import parser now that we have changed date from number to string
		// The purpose of this is get rid of any non-valid dates by going from string to object and back again.
		// Use the dateUtils to allow both Y-m-d and Y/m/d
		public function set expiryDateAsString(dateString:String):void {
			var date:Date = new Date(DateUtil.ansiStringToDate(dateString));
			expiryDate = DateUtil.dateToAnsiString(date);
		}
		
		public function set birthdayAsString(dateString:String):void {
			var date:Date = new Date(DateUtil.ansiStringToDate(dateString));
			birthday = DateUtil.dateToAnsiString(date);
		}
		
		public function get expiryDateAsDate():Date {
			//TraceUtils.myTrace("user.as.expriyDate=" + expiryDate);
			return (expiryDate) ? DateUtil.ansiStringToDate(expiryDate) : null;
		}
		
		public function get birthdayAsDate():Date {
			return (birthday) ? DateUtil.ansiStringToDate(birthday) : null;
		}
		
		/**
		 * Shorthand for the exam date, including conversion from database String to program Date
		 * Change, only use the examDate IF it is explicitly set. Otherwise keep as null.
		 */
		public function get examDate():Date {
			if (birthday) {
				var thisDateString:String = birthday;
			//} else if (expiryDate) {
			//	thisDateString = expiryDate;
			//} else {
			//	thisDateString = DateUtil.dateToAnsiString(new Date());				
			//}
			//trace("get exam date string is " + thisDateString);
				return DateUtil.ansiStringToDate(thisDateString);
			} else {
				return null;
			}
		}
		public function set examDate(value:Date):void {
			birthday = DateUtil.dateToAnsiString(value);
			//trace("set exam date set birthday to " + birthday + " from " + value.toDateString()); 
		}
		
		// gh#1040 I think we will end up with a much more sophisticated memory handler
		/*
		public function get memoryXml():XML {
			if (memory) {
				return new XML(memory);
			} else {
				return null;
			}
		}
		*/
		
		/**
		 * Has this user expired?
		 * 
		 * @return
		 */
		public function isExpired():Boolean {
			if (!expiryDate) return false;
			
			// User never expires
			if (DateUtil.ansiStringToDate(expiryDate).getTime() == 0) return false;
			
			// TODO: This uses the client time - need to check if this is really correct. yes it is.
			// But if the expiry date is 30-April, it should apply all day. So set 'now' to be 00:00:00.000
			// Alternatively we could set all expiry dates to 23:59:59.999 when we create them,
			var rightNow:Date = new Date();
			rightNow.setHours(0);
			rightNow.setMinutes(0);
			rightNow.setSeconds(0);
			rightNow.setMilliseconds(0);
			//TraceUtils.myTrace("user.as.isExpired=" + DateUtils.ansiStringToDate(expiryDate).getTime() + " now=" + rightNow.getTime());
			return (DateUtil.ansiStringToDate(expiryDate).getTime() < rightNow.getTime());
		}
		
		/**
		 * Is this an anonymous user?
		 * 
		 * @return 
		 */
		public function isAnonymous():Boolean {
			return Number(id) <= 0;
		}
		
		/**
		 * Check if a user is licenced for the given title
		 * v3.2 Should be deprectated
		 * @param	title
		 * @return
		 */
		/*override public function isLicencedForTitle(title:Title):Boolean {
			// We shouldn't really be retrieving proxies from value objects, but the alternatives are much messier and we know
			// we are doing it for a good reason :)
			var licenceProxy:LicenceProxy = ApplicationFacade.getInstance().retrieveProxy(LicenceProxy.NAME) as LicenceProxy;
			return (licenceProxy && licenceProxy.isUserInTitle(this, title));
		}*/
		
		/** 
		 * Returns all groups in and below this manageables (all the way down the tree).  For example calling this on a
		 * top level group will return every group in that tree.
		 * 
		 * @param ids An optional array of ids to search for
		 * @return An array of Group objects
		 */
		override public function getSubGroups(ids:Array = null):Array {
			return [ ];
		}
		
		/**
		 * Returns all users in and below this manageable (all the way down the tree).  For example calling this on the
		 * top level group will return every user in the tree.
		 * 
		 * @param userType If this parameter is given only users of the specified userType are returned
		 * @return An array of User objects
		 */
		override public function getSubUsers(userType:int = -1):Array {
			if (userType == -1) {
				return [ this ];
			} else {
				return (this.userType == userType) ? [ this ] : [];
			}
		}
		
		/**
		 * Determines whether this manageable contains the given manageable
		 * 
		 * @param	manageable
		 * @return
		 */
		override public function contains(manageable:Manageable):Boolean {
			return false;
		}
		
		/**
		 * By linking the uid (used by Flex dataProviders) to a unique key based on the type and database id we can ensure
		 * that Flex components still know which object is which even when performing a complete refresh from the backend.
		 */
		override public function get uid():String{
			if (id) {
				return "user" + id;
			} else {
				return "";
			}
		}
		
		override public function set uid(value:String):void { }
		
		/**
		 * Check if all the users in the array are of the same userType.
		 * 
		 * @param	users An array of users
		 * @return	This return the userType of the users or -1 if the array contains a mix (or is empty)
		 */
		public static function checkUserTypes(users:Array):int {
			if (users.length == 0) return -1;
			
			var userType:int = users[0].userType;
			
			for each (var user:User in users) {
				if (!(user.userType == userType)) {
					userType = -1;
					break;
				}
			}
			
			return userType;
		}
		
		/**
		 * Check if the array of users contains at least one user of the given userType
		 * 
		 * @param	users
		 * @param	userType
		 * @return
		 */
		public static function containsUserOfType(users:Array, userType:int):Boolean {
			if (users.length == 0) return false;
			
			for each (var user:User in users)
				if (user.userType == userType) return true;
				
			return false;
		}
		
		public static function createDefault():User {
			var user:User = new User();
			return user;
		}
		
		
		public function toString():String {
			return "U:" + name + " expiry:" + expiryDate;
		}
		
	}
	
}