package com.clarityenglish.common.vo.config {
	//import com.clarityenglish.common.vo.config.Licence;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.dms.vo.account.Account;
	import com.clarityenglish.dms.vo.account.Licence;
	
	/**
	 * This holds configuration information that comes from any source.
	 * It includes licence control, user and account information.
	 */
	public class Config {
		/**
		 * Information is held in simple variables for the most part
		 */
		// TODO. Many of these are NOT in the config class. They are in user, for instance
		public var dbHost:Number;
		public var productCode:uint;
		public var productVersion:String;
		public var prefix:String;
		public var rootID:Number;
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
		public var remoteGateway:String;
		public var remoteService:String;
		public var instanceID:String;
		public var ip:String;
		public var referrer:String;
		
		// To help with testing
		public var configID:String;
		
		// TODO: Or should this be a BentoError object?
		public var error:BentoError;
		//public var errorNumber:uint;
		//public var errorDescription:String;
		
		// Is it worth paths being a separate class?
		public var paths:Object;
		
		// Licence control is a separate class fed by this one
		public var licence:Licence;
		// Actually, we might just use the Account class rather than a special licence class
		public var account:Account;
		
		// For holding chart templates
		private var _chartTemplates:XML;
		
		/**
		 * Developer option
		 */
		public static var DEVELOPER:Object = { name: "XX" };
		
		public function Config() {
			this.paths = {content: '', streamingMedia: '', sharedMedia: '', brandingMedia: '', accountRepository: ''};
			//this.licence = new Licence();
			this.error = new BentoError();
		}
		
		/**
		 *  You can pass the following to the application from start page or command line
		 * 	  prefix
		 * 	  rootID
		 * 	  productCode
		 * 	  username
		 * 	  password
		 * 	  courseID
		 *    startingPoint
		 * 	  sessionID
		 * 	  dbHost
		 * 	  userID
		 * 	  courseFile
		 * 	  language
		 *    ip
		 *    referrer
		 */
		public function mergeParameters(parameters:Object):void {
			if (parameters.dbHost)
				this.dbHost = parameters.dbHost;
			// Prefix takes precedence over rootID
			if (parameters.prefix) {
				this.prefix = parameters.prefix;
			} else if (parameters.rootID) {
				this.rootID = parameters.rootID;
			}
			
			// userID takes precedence over name/studentID/email
			// Not until you can login with it!
			if (parameters.userID)
				this.userID = parameters.userID;
			
			if (parameters.username) this.username = parameters.username;
			if (parameters.studentID) this.studentID = parameters.studentID;
			if (parameters.email) this.email = parameters.email;
			
			if (parameters.productCode) this.productCode = parameters.productCode;
			if (parameters.password) this.password = parameters.password;
			if (parameters.courseID) this.courseID = parameters.courseID;
			if (parameters.courseFile) this.paths.menuFilename = parameters.courseFile;
			if (parameters.startingPoint) this.startingPoint = parameters.startingPoint;
			if (parameters.sessionID) this.sessionID = parameters.sessionID;
			if (parameters.language) this.language = parameters.language;
			
			if (parameters.ip) this.ip = parameters.ip;
			if (parameters.referrer) this.referrer = parameters.referrer;
			
		}
		/**
		 * Do any substitutions that you can for the menu filename
		 */
		private function buildMenuFilename():void {
			// For loginService, the config.xml might not know which productCode you are
			// <courseFile>menu-{productCode}-{productVersion}.xml</courseFile>
			
			// TODO. This hardcoding is duplicated in ContentOps.php, which is not a good idea
			if (paths.menuFilename.indexOf("{productCode}")>=0) {
				switch (productCode) {
					case 52:
						var replace:String = "Academic";
						break;
					case 53:
						replace = "GeneralTraining";
						break;
					default:
						replace = "";
				}
				paths.menuFilename = paths.menuFilename.replace("{productCode}", replace);
			}
			
			if (paths.menuFilename.indexOf("{productVersion}")>=0) {
				switch (productVersion) {
					case 'R2ILM':
						replace = "LastMinute";
						break;
					case 'R2ITD':
						replace = "TestDrive";
						break;
					case 'R2IFV':
						replace = "FullVersion";
						break;
					default:
						replace = "";
				}
				paths.menuFilename = paths.menuFilename.replace("{productVersion}", replace);
			}

		}
		/**
		 *  You can pass the following to the application from the config file
		 * 	  dbHost
		 * 	  productCode
		 * 	  content
		 * 	  streamingMedia
		 * 	  sharedMedia
		 * 	  action
		 * 	  courseID
		 * 	  courseFile
		 * 	  language
		 * 	  remoteGateway
		 * 	  remoteService
		 */
		public function mergeFileData(xml:XML):void {
			
			//ODD. For some reason, xml.config.dbHost.length() fails but xml..dbHost.length(); succeeds.
			//var myL:int = xml.config.dbHost.length();
			//var myS:String = xml..dbHost.toString();
			//if (xml..dbHost.length() > 0) this.dbHost = xml..dbHost.toString();
			if (xml..dbHost.toString())	this.dbHost = xml..dbHost.toString();
			if (xml..productCode.toString()) this.productCode = xml..productCode.toString();
			if (xml..productVersion.toString()) this.productVersion = xml..productVersion.toString();
			if (xml..action.toString()) this.action = xml..action.toString();
			
			// Use the config.xml to help with developer options
			if (xml..developer.toString()) Config.DEVELOPER.name = xml..developer.toString();
			
			// This is the base content folder, we expect it to be added to with title specific subFolder
			if (xml..contentPath.toString()) {
				this.paths.content = xml..contentPath.toString();
			} else {
				this.paths.content = "/Content";
			}
			
			// Name of the menu file (called courseFile to fit in with Orchid)
			var courseFile:String = xml..courseFile.toString();
			if (courseFile) {
				this.paths.menuFilename = courseFile;
			} else {
				this.paths.menuFilename = "menu.xml";
			}
			
			if (xml..streamingMedia.toString()) this.paths.streamingMedia = xml..streamingMedia.toString();
			if (xml..sharedMedia.toString()) this.paths.sharedMedia = xml..sharedMedia.toString();
			
			if (xml..brandingMedia.toString()) {
				this.paths.brandingMedia = xml..brandingMedia.toString();
			} else {
				this.paths.brandingMedia = '';
			}
			
			if (xml..courseID.toString()) this.courseID = xml..courseID.toString();
//			if (xml..courseFile.toString()) this.courseFile = xml..courseFile.toString();
			if (xml..language.toString()) this.language = xml..language.toString();
			
			// To handle the amfphp gateway
			if (xml..remoteGateway.toString()) {
				this.remoteGateway = xml..remoteGateway.toString();
			} else {
				this.remoteGateway = "/Software/ResultsManager/web/amfphp/";
			}
			
			if (xml..remoteService.toString()) {
				this.remoteService = xml..remoteService.toString();
			} else {
				this.remoteService = "BentoService";
			}
			
			// For help with testing
			if (xml..id.toString()) {
				this.configID = xml..id.toString();
			} else {
				this.configID = '-';
			}
			
			trace("config.xml has id=" + this.configID);
		}
		
		/**
		 * You can read the following from the database about the account
		 *
		 * @param data This object contains account, error and config objects
		 *
		 * the account object includes a title object
		 * 	  licenceType
		 * 	  licenceSize
		 * 	  accountName
		 * 	  licenceStartDate
		 * 	  licenceExpiryDate
		 * 	  licenceAttributes[IP, referrerURL, limitCourses, allowedCourses, action, ]
		 */
		public function mergeAccountData(data:Object):void {
			
			// You might come back with an error rather than valid data
			if (data.error && data.error.errorNumber > 0) {
				// Accept any error number coming back. You can handle the details later.
				// This doesn't seem to coerce well, do it a long handed way
				//this.error = data.error as BentoError;
				this.error = new BentoError(data.error.errorNumber as uint);
				this.error.errorContext = data.error.errorContext;
				//this.errorNumber = data.error.errorNumber;
				//this.errorDescription = data.error.errorDescription;
				
				// No point going on, this is all you need
				return;
			}
			
			// Grab the account and title into our classes
			this.account = data.account as Account;
			
			// #306 Specifically set rootID in config
			this.rootID = Number(this.account.id);
			
			// A temporary variable for the title - there can only be one
			// Which I think should be caught in getRMSettings really
			if (this.account.children.length != 1) {
				this.error.errorNumber = BentoError.ERROR_DATABASE_READING;
				this.error.errorContext = 'More than one title matched the product code';
			}
			
			var thisTitle:Title = this.account.getTitle();
			
			// The account holds the languageCode - which in Bento terms is productVersion
			if (thisTitle.languageCode) 
				this.productVersion = thisTitle.languageCode;
			
			// This is the title specific subFolder. It will be something like RoadToIELTS2-Academic
			// and comes from a mix of T_ProductLanguage and T_Accounts. 
			// Its purpose is to allow an account to swap language versions easily for a title.
			if (thisTitle.contentLocation) {
				this.paths.content += thisTitle.contentLocation;
			}
			
			// See if you can now do any substitutions on the menu filename
			buildMenuFilename();

			// You can now adjust the streamingMedia and sharedMedia as necessary
			// Remember that streamingMedia might look like 
			// streamingMedia=http://streaming.clarityenglish.com:1935/cfx/ty/{version}/streamingMedia
			this.paths.streamingMedia = this.paths.streamingMedia.toString().split('{productCode}').join(data.contentLocation);
			this.paths.sharedMedia = this.paths.sharedMedia.toString().split('{productCode}').join(data.contentLocation);
			this.paths.brandingMedia = this.paths.brandingMedia.toString().split('{prefix}').join(data.prefix);
		
			// Whilst the title/account holds most licence info, it is nice to keep it in one class
			this.licence = data.licence as Licence;
		}

		/**
		 * Check for all the errors that you might know about now
		 */
		public function checkErrors():void {
			// IP range
			// Match the user's IP against the range listed in the licence attributes
			var gotLA:Boolean = false;
			for each (var lA:Object in account.licenceAttributes) {
				if (lA.licenceKey.toLowerCase() == 'iprange') {
					gotLA = true;
					break;
				}
			}
			if (gotLA) {
				if (!isIPInRange(ip, lA.licenceValue)) {
					error.errorNumber = BentoError.ERROR_OUTSIDE_IP_RANGE;
					//error.errorDescription = 'This program can only be run from limited computers or through one website.';
					error.errorContext = "Your IP doesn't match and is " + ip;
				} else {
					trace("your ip, " + ip + ", is in the listed range.");
				}
			}
			
		}
		/**
		 * This sends back the XML that is the chart templates
		 * 
		 * @return
		 */
		public function get chartTemplates():XML {
			return _chartTemplates;
		}
		
		public function set chartTemplates(value:XML):void {
			_chartTemplates = value;
		}
		
		/**
		 * This getter lets you find the licence type directly from the config object
		 * 
		 * @return the licence type - can match against Title.LEARNER_TRACKING etc
		 */
		public function get licenceType():uint {
			return (this.account) ? this.account.getTitle().licenceType : null;
		}
		
		/**
		 * This getter lets you find the account name directly from the config object
		 * 
		 * @return the account name
		 */
		public function get accountName():String {
			return this.account.name;
		}
		
		/**
		 * This method tests to see if the account has a record for this title
		 * Will look in T_Accounts keyed on rootID
		 * 
		 * @return true if there is no such title
		 */
		public function noSuchTitle():Boolean {
			return this.error.errorNumber == BentoError.ERROR_NO_SUCH_ACCOUNT;
		}
		
		/**
		 * This method tests to see if the account has been suspended
		 * T_AccountRoot.F_AccountStatus
		 * 
		 * @return true if the account is suspended
		 */
		public function accountSuspended():Boolean {
			return this.error.errorNumber == BentoError.ERROR_ACCOUNT_SUSPENDED;
		}
		
		/**
		 * This method tests to see if the account has been suspended
		 * T_AccountRoot.F_TermsAndConditions
		 * 
		 * @return true if the account has not had the terms and conditions accepted
		 */
		public function termsNotAccepted():Boolean {
			return this.error.errorNumber == BentoError.ERROR_TERMS_NOT_ACCEPTED
		}
		
		/**
		 * This method tests to see if the licence is corrupt
		 * T_Account.F_Checksum
		 * 
		 * @return true if the data in the record is corrupt
		 */
		public function licenceInvalid():Boolean {
			return this.error.errorNumber == BentoError.ERROR_LICENCE_INVALID;
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
			return this.error.errorNumber == BentoError.ERROR_LICENCE_NOT_STARTED;
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
			return this.error.errorNumber == BentoError.ERROR_LICENCE_EXPIRED;
		}
		
		/**
		 * This method tests to see if the user is outside the licence IP range
		 * T_LicenceAttributes
		 * 
		 * @return true if the users is from outside the IP range
		 */
		public function outsideIPRange():Boolean {
			return this.error.errorNumber == BentoError.ERROR_OUTSIDE_IP_RANGE;
		}
		
		/**
		 * This method tests to see if the user is outside the licence referrer range
		 * T_LicenceAttributes
		 * 
		 * @return true if the users is from outside the RU range
		 */
		public function outsideRURange():Boolean {
			return this.error.errorNumber == BentoError.ERROR_OUTSIDE_RU_RANGE;
		}
		
		/**
		 * This method tests to see if any error has been generated
		 * 
		 * @return true if there is any error
		 */
		public function anyError():Boolean {
			return this.error.errorNumber > 0;
		}

		/**
		 * Detail function to see if one specific IP address is in a range 
		 * @param ip
		 * @param range
		 * @return Boolean
		 * 
		 */
		private function isIPInRange(thisIP:String, range:String):Boolean {
			var ipRangeArray:Array = range.split(",");
			for (var t:String in ipRangeArray) {
				// first, is there an exact match?
				if (thisIP == ipRangeArray[t])
					return true;
				
				// or does it fall in the range? 
				// assume nnn.nnn.nnn.x-y or nnn.nnn.x-y
				var targetBlocks:Array = ipRangeArray[t].split(".");
				var thisBlocks:Array = thisIP.split(".");
				// how far down do they specify?
				for (var i:uint=0; i<thisBlocks.length; i++) {
					//myTrace("match " + thisBlocks[i] + " against " + targetBlocks[i]);
					if (targetBlocks[i] == thisBlocks[i]) {
					} else if (targetBlocks[i].indexOf("-")>0) {
						var target:Array = targetBlocks[i].split("-");
						var targetStart:uint = Number(target[0]);
						var targetEnd:uint = Number(target[1]);
						var thisDetail:uint = Number(thisBlocks[i]);
						if (targetStart <= thisDetail && thisDetail <= targetEnd) {
							//myTrace("range match " + thisDetail + " between " + targetStart + " and " + targetEnd);
							return true;
						}
					} else {
						//myTrace("no match between " + targetBlocks[i] + " and " + thisBlocks[i]);
						break;
					}
				}
			}
			return false;
		}
	}
}
