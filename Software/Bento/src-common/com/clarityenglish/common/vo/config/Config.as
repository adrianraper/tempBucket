package com.clarityenglish.common.vo.config
{
	import com.clarityenglish.common.vo.config.Licence;
	/**
	 * This holds configuration information that comes from any source
	 */
	public class Config
	{
		/**
		 * Information is held in simple variables for the most part
		 */
		public var dbHost:Number;
		public var productCode:uint;
		public var prefix:String;
		public var rootID:Number
		public var username:String;
		public var studentID:String;
		public var email:String;
		public var password:String;
		public var courseID:String;
		public var startingPoint:String;
		public var sessionID:String;
		public var userID:String;
		public var courseFile:String;
		public var language:String;
		public var action:String;
		
		// Is it worth paths being a separate class?
		public var paths:Object;
		// ditto licence
		public var licence:Licence;
		
		public function Config() {
			this.paths = {content:'',
							streamingMedia:'',
							sharedMedia:'',
							accountRepository:''
			};
			this.licence = new Licence();
		}
		
		/**
		 *  You can pass the following to the application from start page or command line
		 * 	  prefix
		 * 	  rootID
		 * 	  username
		 * 	  password
		 * 	  courseID
		 *    startingPoint
		 * 	  sessionID
		 * 	  dbHost
		 * 	  userID
		 * 	  courseFile
		 * 	  language
		 */
		public function mergeParameters(parameters:Object):void {
			
			if (parameters.dbHost) this.dbHost = parameters.dbHost;
			// Prefix takes precedence over rootID
			if (parameters.prefix) {
				this.prefix = parameters.prefix;
			} else if (parameters.rootID) {
				this.rootID = parameters.rootID
			}
			// userID takes precedence over name/studentID/email
			if (parameters.userID) {
				this.userID = parameters.userID;
			} else {
				if (parameters.username) this.username = parameters.username;
				if (parameters.studentID) this.studentID = parameters.studentID;
				if (parameters.email) this.email = parameters.email;
			}
			if (parameters.password) this.password = parameters.password;
			
			if (parameters.courseID) this.courseID = parameters.courseID;
			if (parameters.courseFile) this.courseFile = parameters.courseFile;
			if (parameters.startingPoint) this.startingPoint = parameters.startingPoint;
			if (parameters.sessionID) this.sessionID = parameters.sessionID;
			
			if (parameters.language) this.language = parameters.language;
		}

		/**
		 *  You can pass the following to the application from the config file
		 * 	  dbHost
		 * 	  content
		 * 	  streamingMedia
		 * 	  sharedMedia
		 * 	  action
		 * 	  courseID
		 * 	  courseFile
		 * 	  language
		 */
		public function mergeFileData(xml:XML):void {
			
			if (xml.dbHost) this.dbHost = xml.dbHost;
			if (xml.action) this.action = xml.action;
			
			// This is the base content folder, we expect it to be added to with title specific subFolder
			if (xml.content) {
				this.paths.content = xml.content;
			} else {
				this.paths.content = "/Content";
			}
			if (xml.streamingMedia) {
				this.paths.streamingMedia = xml.streamingMedia;
			} 
			if (xml.sharedMedia) {
				this.paths.sharedMedia = xml.sharedMedia;
			} 
			
			if (xml.courseID) this.courseID = xml.courseID;
			if (xml.courseFile) this.courseFile = xml.courseFile;
			
			if (xml.language) this.language = xml.language;
		}
		
		/**
		 *  You can read the following from the database about the account
		 * 	  contentLocation
		 * 	  licenceType
		 * 	  licenceSize
		 * 	  accountName
		 * 	  licenceExpiryDate
		 * 	  licenceAttributes[IP, referrerURL, limitCourses, allowedCourses, action, ]
		 * 	  
		 */
		public function mergeAccountData(data:Object):void {
			
			// This is the title specific subFolder
			if (data.contentLocation) {
				this.paths.content += data.contentLocation;
			}
			// You can now adjust the streamingMedia and sharedMedia as necessary
			// Remember that streamingMedia might look like 
			// streamingMedia=http://streaming.clarityenglish.com:1935/cfx/ty/[version]/streamingMedia
			
			// Licence details
			if (data.licenceType) {
				this.licence.type = (data.licenceType as uint);
			} else {
				this.licence.type==Licence.LEARNER_TRACKING;
			}
			if (data.licenceSize) {
				this.licence.size = data.licenceSize;
			} else {
				this.licence.size = 1;
			}
			if (data.licenceExpiryDate) {
				this.licence.expiryDate = data.licenceExpiryDate;
			} else {
				this.licence.expiryDate = undefined; // well, what? yesterday?
			}
		}
	}
}