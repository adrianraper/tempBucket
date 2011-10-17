package com.clarityenglish.common.vo.config {
	import com.clarityenglish.common.vo.config.Licence;
	
	/**
	 * This holds configuration information that comes from any source.
	 * It includes licence control, user and account information.
	 */
	public class Config {
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
		
		public var errorNumber:uint;
		
		// Is it worth paths being a separate class?
		public var paths:Object;
		// Licence control is a separate class fed by this one
		public var licence:Licence;
		
		public function Config() {
			this.paths = {content: '', streamingMedia: '', sharedMedia: '', brandingMedia: '', accountRepository: ''};
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
			
			if (parameters.dbHost)
				this.dbHost = parameters.dbHost;
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
				if (parameters.username)
					this.username = parameters.username;
				if (parameters.studentID)
					this.studentID = parameters.studentID;
				if (parameters.email)
					this.email = parameters.email;
			}
			if (parameters.password)
				this.password = parameters.password;
			
			if (parameters.courseID)
				this.courseID = parameters.courseID;
			if (parameters.courseFile)
				this.courseFile = parameters.courseFile;
			if (parameters.startingPoint)
				this.startingPoint = parameters.startingPoint;
			if (parameters.sessionID)
				this.sessionID = parameters.sessionID;
			
			if (parameters.language)
				this.language = parameters.language;
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
			
			if (xml.dbHost)
				this.dbHost = xml.dbHost;
			if (xml.action)
				this.action = xml.action;
			
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
			// TODO. This is not working if there is no brandingMedia node
			if (xml.brandingMedia) {
				this.paths.brandingMedia = xml.brandingMedia;
			} else {
				this.paths.brandingMedia = '';
			}
			
			if (xml.courseID)
				this.courseID = xml.courseID;
			if (xml.courseFile)
				this.courseFile = xml.courseFile;
			
			if (xml.language)
				this.language = xml.language;
		}
		
		/**
		 *  You can read the following from the database about the account
		 * 	  contentLocation
		 * 	  licenceType
		 * 	  licenceSize
		 * 	  accountName
		 * 	  licenceStartDate
		 * 	  licenceExpiryDate
		 * 	  licenceAttributes[IP, referrerURL, limitCourses, allowedCourses, action, ]
		 *
		 */
		public function mergeAccountData(data:Object):void {
			
			// You might come back with an error rather than valid data
			if (data.error && data.error>0) {
				// Accept any error number coming back. You can handle the details later.
				this.errorNumber = data.error;
				
				// No point going on, this is all you need
				return;
			}
			// This is the title specific subFolder. It will be something like TenseBuster-International
			// and comes from T_ProductLocation. Its purpose is to allow an account to swap language versions easily for a title.
			if (data.contentLocation) {
				this.paths.content += data.contentLocation;
			}
			// You can now adjust the streamingMedia and sharedMedia as necessary
			// Remember that streamingMedia might look like 
			// streamingMedia=http://streaming.clarityenglish.com:1935/cfx/ty/[version]/streamingMedia
			this.paths.streamingMedia = this.paths.streamingMedia.toString().split('[version]').join(data.contentLocation);
			this.paths.sharedMedia = this.paths.sharedMedia.toString().split('[version]').join(data.contentLocation);
			this.paths.brandingMedia = this.paths.brandingMedia.toString().split('[prefix]').join(data.prefix);
				
			// Licence details
			if (data.licenceType) {
				this.licence.type = (data.licenceType as uint);
			} else {
				this.licence.type == Licence.LEARNER_TRACKING;
			}
			if (data.licenceSize) {
				this.licence.size = data.licenceSize;
			} else {
				this.licence.size = 1;
			}
			// TODO. Would it be better to keep all dates in the model as real dates, not as strings?
			if (data.licenceExpiryDate) {
				this.licence.expiryDate = new Date(data.licenceExpiryDate as Number);
			} else {
				this.licence.expiryDate = new Date(); // well, what? yesterday?
			}
			if (data.licenceStartDate) {
				this.licence.startDate = new Date(data.licenceStartDate as Number);
			} else {
				this.licence.startDate = new Date(); // well, what? today?
			}
		}
		
		/**
		 * This method tests to see if the account has a record for this title 
		 * Will look in T_Accounts keyed on rootID
		 * @return true if there is no such title
		 * 
		 */
		public function noSuchTitle():Boolean {
			return this.errorNumber == BentoError.ERROR_NO_SUCH_ACCOUNT;
		}
		/**
		 * This method tests to see if the account has been suspended
		 * T_AccountRoot.F_AccountStatus 
		 * @return true if the account is suspended
		 * 
		 */
		public function accountSuspended():Boolean {
			return this.errorNumber == BentoError.ERROR_ACCOUNT_SUSPENDED;
		}
		/**
		 * This method tests to see if the account has been suspended
		 * T_AccountRoot.F_TermsAndConditions 
		 * @return true if the account has not had the terms and conditions accepted
		 * 
		 */
		public function termsNotAccepted():Boolean {
			return this.errorNumber == BentoError.ERROR_TERMS_NOT_ACCEPTED
		}
		/**
		 * This method tests to see if the licence is corrupt
		 * T_Account.F_Checksum 
		 * @return true if the data in the record is corrupt
		 * 
		 */
		public function licenceInvalid():Boolean {
			return this.errorNumber == BentoError.ERROR_LICENCE_INVALID;
		}
		/**
		 * This method tests to see if the account has not started yet
		 * T_Accounts.F_StartDate compare to today
		 * @return true if the account hasn't started yet
		 *
		 * TODO. Actually I suppose that the backside will do this test and just send back an error number? 
		 */
		public function licenceNotStarted():Boolean {
			//return (this.licence.startDate > new Date());
			return this.errorNumber == BentoError.ERROR_LICENCE_NOT_STARTED;
		}
		/**
		 * This method tests to see if the account has expired
		 * T_Accounts.F_ExpiryDate compare to today
		 * @return true if the account has expired
		 * 
		 * TODO. Actually I suppose that the backside will do this test and just send back an error number? 
		 */
		public function licenceExpired():Boolean {
			//return (this.licence.expiryDate < new Date());
			return this.errorNumber == BentoError.ERROR_LICENCE_EXPIRED;
		}
		/**
		 * This method tests to see if the user is outside the licence IP range
		 * T_LicenceAttributes
		 * @return true if the users is from outside the IP range
		 * 
		 */
		public function outsideIPRange():Boolean {
			return this.errorNumber == BentoError.ERROR_OUTSIDE_IP_RANGE;
		}
		/**
		 * This method tests to see if the user is outside the licence referrer range
		 * T_LicenceAttributes
		 * @return true if the users is from outside the RU range
		 * 
		 */
		public function outsideRURange():Boolean {
			return this.errorNumber == BentoError.ERROR_OUTSIDE_RU_RANGE;
		}
	}
}
