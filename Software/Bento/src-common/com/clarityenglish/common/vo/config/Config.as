package com.clarityenglish.common.vo.config {
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Account;
	import com.clarityenglish.dms.vo.account.Licence;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.StringUtils;
	import org.davekeen.util.XmlUtils;
	
	/**
	 * This holds configuration information that comes from any source.
	 * It includes licence control, user and account information.
	 */
	public class Config {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const LOGIN_BY_NAME:uint = 1;
		public static const LOGIN_BY_ID:uint = 2;
		public static const LOGIN_BY_NAME_AND_ID:uint = 4;
		// gh#1090
		//public static const LOGIN_BY_ANONYMOUS:uint = 8;
		public static const LOGIN_BY_EMAIL:uint = 128;
		
		// #341 These values are from compatability with Orchid and RM
		public static const SELF_REGISTER_NAME:uint = 1;
		public static const SELF_REGISTER_ID:uint = 2;
		public static const SELF_REGISTER_EMAIL:uint = 4;
		public static const SELF_REGISTER_PASSWORD:uint = 16;
		
		// #341
		public static const LOGIN_REQUIRE_PASSWORD:uint = 1;

		/**
		 * Information is held in simple variables for the most part
		 */
		// TODO. Many of these are NOT in the config class. They are in user, for instance
		// #515 Just found that I have config.rootID and config.account.id.
		// So I should avoid simple variables that are also held in objects
		public var dbHost:Number;
		// gh#39
		public var productCode:String;
		public var productVersion:String;
		public var configProductCode:String;
		public var configFilename:String;
		
		// #524 languageCode determines what content is used
		public var prefix:String;
		// #515
		//public var rootID:Number;
		private var _rootID:Number;
		private var _languageCode:String;
		
		public var username:String;
		public var studentID:String;
		public var email:String;
		public var password:String;
		public var courseID:String;
		public var startingPoint:String;
		public var userID:String;
		public var courseFile:String;
		// language determines what string literal language is used
		public var language:String;
		public var action:String;
		// #333
		public var remoteDomain:String;
		public var assetFolder:String;
		public var remoteGateway:String;
		public var remoteService:String;
        // gh#1314
        public var _sessionID:String = null;
        public var _instanceID:String = null;
        public var server:String = null;
        public var protocol:String = 'http://';

		public var ip:String;
		public var referrer:String;
		// For CCB
		public var remoteStartFolder:String;
		
		// #335
		// gh#356
		public var localStreamingMedia:String;
		public var mediaChannel:String;
		
		public var channels:Array;
		
		// #336
		public var scorm:Boolean;

		// #337
		public var upgradeURL:String;
		public var pricesURL:String;
		public var registerURL:String;
		public var manualURL:String;
		// gh#166
		public var getAccountURL:String;
		
		// To help with testing
		public var configID:String;
		
		// TODO: Or should this be a BentoError object?
		public var error:BentoError;
		
		// Is it worth paths being a separate class?
		public var paths:Object;
		public var contentRoot:String;
		
		// Licence control is a separate class fed by this one
		public var licence:Licence;
		// Actually, we might just use the Account class rather than a special licence class
		public var account:Account;
		
		// #341 Hold the top level group for this account
		public var group:Group;
		
		// #385
		public var rememberLogin:Boolean;
		public var disableAutoTimeout:Boolean;
		
		// gh#21	
		public var loginOption:Number;
		
		// gh#1090
		public var signInAs:uint = Title.SIGNIN_TRACKING;
		
		// #410
		public var checkNetworkAvailabilityUrl:String;
		public var checkNetworkAvailabilityInterval:uint;
		public var checkNetworkAvailabilityReconnectInterval:uint;
		
		// gh#914
		public var uploadMaxFilesize:String = 'unknown';
		public var uploadMaxBytes:Number = 0;
		
		// For performance logging
		public var appLaunchTime:Number;

		// #336
		public var sessionStartTime:Number;
		
		// gh#225
		public var _illustrationCloseFlag:Boolean;
		
		// gh#371
		public var otherParameters:Object;
		
		// gh#659
		public var xmlCourseFile:String;
		
		// gh#476
		public var useCacheBuster:Boolean;
		
		// gh#234
		public var platform:String = 'browser';
		
		// gh#224
		public var customisation:XML;
		
		// gh#886, gh#1090
		private var _noLogin:Boolean;

		// gh#1160, gh#1090 change from null to {}
		public var retainedParameters:Object = {};
		public var isReloadAccount:Boolean;

		/**
		 * Developer option
		 */
		public static var DEVELOPER:Object = { name: "XX" };
		
		public function Config() {
			this.paths = {content: '', streamingMedia: '', sharedMedia: '', brandingMedia: '', accountRepository: ''};
			//this.licence = new Licence();
			this.error = new BentoError();
			this.channels = [];
			this.scorm = false;
			this.illustrationCloseFlag = true;
			// gh#476
			this.useCacheBuster = false;
			
			// gh#1090
			this.rootID = 0;

		}
		
		/**
		 * Some getters and setters to tidy up variable use
		 * #515
		 */
		// RootID is part of the account object, assuming you have that. If not, use a temp variable
		public function get rootID():Number {
			if (this.account)
				return Number(this.account.id);
			
			return _rootID;
		}
		public function set rootID(value:Number):void {
			if (this.account) {
				this.account.id = value.toString();
			} else {
				_rootID = value;
			}
		}

		public function set languageCode(value:String):void {
			// gh#1182
			CopyProxy.languageCode = value;
			_languageCode = value;
		}
		
		public function get languageCode():String {
			return _languageCode;
		}
		
		public function set illustrationCloseFlag(value:Boolean):void {
			if (_illustrationCloseFlag != value) {
				_illustrationCloseFlag = value;
			}
		}
		
		public function get illustrationCloseFlag():Boolean {
			return _illustrationCloseFlag;
		}
		
		public function get noLogin():Boolean {
			return _noLogin;
		}
		
		// gh#1090
		public function set noLogin(value:Boolean):void {
			_noLogin = value;
		}

        // gh#1314
        public function set sessionID(value:String):void {
            _sessionID = value;
        }
        public function get sessionID():String {
            if (!_sessionID) {
                _sessionID = this.generateSessionId();
            }
            return _sessionID;
        }
        public function set instanceID(value:String):void {
            _instanceID = value;
        }
        public function get instanceID():String {
            if (!_instanceID) {
                _instanceID = this.generateInstanceId();
            }
            return _instanceID;
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
		 * 	  startTime
		 */
		public function mergeParameters(parameters:Object):void {
			
			// gh#371
			this.otherParameters = new Object();
			for (var property:String in parameters) {
				switch (property) {
					case 'dbHost':
					case 'prefix':
					case 'userID':
					case 'username':
					case 'studentID':
					case 'email':
					case 'productCode':
					case 'password':
					case 'courseFile':
					case 'startingPoint':
					case 'sessionID':
					case 'ip':
					case 'referrer':
					case 'instanceID':
					// #336 SCORM
					case 'scorm':
                    // gh#1314
                    case 'server':
                    case 'protocol':
						if (this.hasOwnProperty(property))
							this[property] = parameters[property];
						break;
					// #338 Legacy has parameter called course not courseID
					case 'course':
					case 'courseID':
						this.courseID = parameters[property];
						break;
					// Assuming this comes from PHP it will be in seconds, as time is in milliseconds
					// But cleaner to convert it in the start page
					case 'startTime':
						this.appLaunchTime = parameters[property];
						break;
					case 'language':
						this.language = parameters[property];
						this.languageCode = parameters[property];
						break;
					default:
						this.otherParameters[property] = parameters[property];	
				}
			}

			// #361
            // gh#1314 Done in getter initialisation now
            /*
			if (!this.instanceID) {
				var timeStamp:Date = new Date();
				this.instanceID = timeStamp.getTime().toString();
			}
			*/

            // gh#1314 Have to do this after picking up sever parameters
            // gh#1339 Substitute any dynamic domains
            var replaceObj:Object = {remoteDomain: this.remoteDomain, currentDomain: this.protocol + this.server + '/'};
            for (var searchString:String in replaceObj) {
                var regExp:RegExp = new RegExp("\{" + searchString + "\}", "g");
                this.remoteGateway = this.remoteGateway.replace(regExp, replaceObj[searchString]);
                this.contentRoot = this.contentRoot.replace(regExp, replaceObj[searchString]);
            }

            // gh#1160
			// gh#1160 If you started with passed parameters, clear [most of] them out now for a restart
			this.retainedParameters = {};
			for (property in parameters) {
				switch (property) {
					case 'dbHost':
					case 'prefix':
                    case 'rootID':
						this.retainedParameters[property] = parameters[property];
						break;
				}
			}
		}

        // gh#1314
        private function generateInstanceId():String {
            var timeStamp:Date = new Date();
            return timeStamp.getTime().toString();
        }
        private function generateSessionId():String {
            // Interleave a timestamp with a random string of letters
            var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var numChars:Number = chars.length - 1;
            var buildId:String = 'bento'; // prefix to make it clear where this session id came from
            var timeStamp:Date = new Date();
            var timeChars:String = timeStamp.getTime().toString();
            for (var ix:uint = 0; ix < timeChars.length; ix++)
                buildId += timeChars.charAt(ix) + chars.charAt(Math.floor(Math.random() * numChars));
            return buildId;
        }
		/**
		 * Do any substitutions that you can for the menu filename
		 */
		// gh#659 change private to public in order to reassigne the menu file name
		public function buildMenuFilename():void {
			// For loginService, the config.xml might not know which productCode you are
			// <courseFile>menu-{productCode}-{productVersion}.xml</courseFile>
			
			// TODO. This hardcoding is duplicated in ContentOps.php, which is not a good idea.
			// These are all set as constants in IELTSApplication, but I can't get at that here,
			// which seems to suggest that I shouldn't be even trying...
			if (paths.menuFilename.indexOf("{productCode}")>=0) {
				switch (productCode) {
					case '52':
						var replace:String = "Academic";
						break;
					case '53':
						replace = "GeneralTraining";
						break;
					case '57':
						replace= "Sounds";
						break;
					case '58':
						replace= "Speech";
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
					case 'R2IHU':
					case 'FV':
						replace = "FullVersion";
						break;
					// gh#166
					case 'DEMO':
						replace = "Demo";
						break;
					default:
						replace = "FullVersion";
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
			if (xml..prefix.toString()) this.prefix = xml..prefix.toString();
			if (xml..productCode.toString()) {
				this.configProductCode = xml..productCode.toString();;
				this.productCode = xml..productCode.toString();		
			}
			if (xml..productVersion.toString()) this.productVersion = xml..productVersion.toString();
			if (xml..action.toString()) this.action = xml..action.toString();
			
			// Use the config.xml to help with developer options
			if (xml..developer.toString()) Config.DEVELOPER.name = xml..developer.toString();
			
			// This is the base content folder, we expect it to be added to with title specific subFolder
			if (xml..contentPath.toString()) {
				this.contentRoot = xml..contentPath.toString();
			} else {
				this.contentRoot= "/";
			}
			
			// Name of the menu file (called courseFile to fit in with Orchid)
			xmlCourseFile = xml..courseFile.toString();
			if (xmlCourseFile) {
				this.configFilename = xmlCourseFile;
				this.paths.menuFilename = xmlCourseFile;
			} else {
				this.configFilename = "menu.xml";
				this.paths.menuFilename = "menu.xml";
			}
			
			// Alice: automatic multiple channel
			for each (var channel:XML in xml..channel){			
				var channelObject:ChannelObject = new ChannelObject();
				channelObject.name = channel.@name.toString();
				channelObject.caption = channel.@caption.toString();
				channelObject.streamingMedia = channel.streamingMedia.toString();
				channels.push(channelObject);
			}
			
			// #335
			if (xml..streamingMedia.toString()) this.paths.streamingMedia = xml..streamingMedia.toString();

			if (xml..mediaChannel.toString()) {
				this.mediaChannel = xml..mediaChannel.toString();
			}else {
				// TODO: It would be better to build a preference system into the .rss files
				this.mediaChannel = 'vimeo';
			}
			
			if (xml..sharedMedia.toString()) this.paths.sharedMedia = xml..sharedMedia.toString();
			if (xml..brandingMedia.toString()) this.paths.brandingMedia = xml..brandingMedia.toString();
			
			if (xml..courseID.toString()) this.courseID = xml..courseID.toString();
			//if (xml..courseFile.toString()) this.courseFile = xml..courseFile.toString();
			if (xml..language.toString()) {
				this.language = xml..language.toString();
				this.languageCode = xml..language.toString();
			}

            // For remote access and domain independence
            if (xml..remoteDomain.toString()) {
                this.remoteDomain = xml..remoteDomain.toString();
            } else {
                this.remoteDomain = "http://www.ClarityEnglish.com/";
            }

            // To handle the amfphp gateway
			if (xml..remoteGateway.toString()) {
				this.remoteGateway = xml..remoteGateway.toString();
			} else {
				this.remoteGateway = "Software/ResultsManager/web/amfphp/";
			}
			if (xml..remoteService.toString()) {
				this.remoteService = xml..remoteService.toString();
			} else {
				this.remoteService = "BentoService";
			}
			
			if (xml..assetFolder.toString()) {
				this.assetFolder = xml..assetFolder.toString();
			} else {
				this.assetFolder = "ResultsManager/web/resources/assets/";
			}
			// for CCB
			if (xml..remoteStartFolder.toString()) {
				this.remoteStartFolder = xml..remoteStartFolder.toString();
			} else {
				// gh#92
				this.remoteStartFolder = "http://www.ClarityEnglish.com/area1/";
			}			

			// #337
			if (xml..upgradeURL.toString())
				this.upgradeURL = xml..upgradeURL.toString();
			if (xml..pricesURL.toString())
				this.pricesURL = xml..pricesURL.toString();
			if (xml..registerURL.toString())
				this.registerURL = xml..registerURL.toString();
			if (xml..manualURL.toString())
				this.manualURL = xml..manualURL.toString();
			if (xml..getAccountURL.toString())
				this.getAccountURL = xml..getAccountURL.toString();
			
			// #385
			if (xml..rememberLogin.toString() == "true")
				this.rememberLogin = true;
			if (xml..disableAutoTimeout.toString() == "true")
				this.disableAutoTimeout = true;
			
			// #410
			if (xml..checkNetworkAvailabilityUrl.toString())
				this.checkNetworkAvailabilityUrl = xml..checkNetworkAvailabilityUrl.toString();
			if (xml..checkNetworkAvailabilityInterval.toString())
				this.checkNetworkAvailabilityInterval = new Number(xml..checkNetworkAvailabilityInterval.toString());
			if (xml..checkNetworkAvailabilityReconnectInterval.toString())
				this.checkNetworkAvailabilityReconnectInterval = new Number(xml..checkNetworkAvailabilityReconnectInterval.toString());

			// gh#21
			if (xml..loginOption.toString())
				this.loginOption = Number(xml..loginOption.toString());
			
			// gh#476
			if (xml..useCacheBuster.toString() == "true")
				this.useCacheBuster = true;

			// For help with testing
			if (xml..id.toString()) {
				this.configID = xml..id.toString();
			} else {
				this.configID = '-';
			}
			if (xml..ip.toString()) {
				this.ip = xml..ip.toString();
			}
			if (xml..referrer.toString()) {
				this.referrer = xml..referrer.toString();
			}
			
			// gh#234
			if (xml..platform.toString())
				this.platform = xml..platform.toString();
			
			// gh#224
			if (xml..customisation)
				this.customisation = xml..customisation[0];
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
			
			// gh#886
			// gh#1012
			if (data.config && data.config.ip)
				this.ip = data.config.ip;
			
			// gh#914
			if (data.config && data.config.uploadMaxFilesize) {
				var rawMaxFilesize:String = data.config.uploadMaxFilesize;
				var unitPattern:RegExp = /^([0-9]+)([gmk]?)/i;
				var results:Array = rawMaxFilesize.match(unitPattern);
				var maxBytes:Number = (results[1]) ? results[1] : 0;
				if (results.length > 2) {
					switch(results[2].toLowerCase()) {
						case 'g':
							maxBytes *= 1024;
						case 'm':
							maxBytes *= 1024;
						case 'k':
							maxBytes *= 1024;
					}
				}
				this.uploadMaxFilesize = rawMaxFilesize;
				this.uploadMaxBytes = maxBytes;
			}
					
			// Grab the account and title into our classes
			if (data.account)
				this.account = data.account as Account;
			
			// #341
			if (data.group)
				this.group = data.group as Group;
			
			// #306 Specifically set rootID in config
			this.rootID = Number(this.account.id);

			// A temporary variable for the title - there can only be one
			// Which I think should be caught in getRMSettings really
			if (this.account.children.length != 1) {
				this.error.errorNumber = BentoError.ERROR_DATABASE_READING;
				this.error.errorContext = 'More than one title matched the product code';
			}
			
			var thisTitle:Title = this.account.getTitle();
			
			// gh#11 thisTitle.language changed to thisTitle.productVersion due to Alice local database add F_ProductVersion column			
			// The account holds the languageCode - which in Bento terms is productVersion
			// #524
			if (thisTitle.languageCode) 
				this.languageCode = thisTitle.languageCode;
			if (thisTitle.productVersion) 
				this.productVersion = thisTitle.productVersion;
			// gh#39
			if (thisTitle.productCode) 
				this.productCode = String(thisTitle.productCode);
			// gh#20
			/*if(thisTitle.languageCode)
				this.language = thisTitle.languageCode;*/
			
			// gh#886
			// gh#1090

			/*for (var i:Number = 0; i < this.account.licenceAttributes.length; i++) {
				if (this.account.licenceAttributes[i]['licenceKey'] == 'noLogin') {
					this._noLogin = this.account.licenceAttributes[i]['licenceValue'];
				}
			}*/

			this._noLogin = (thisTitle.loginModifier & Title.LOGIN_BLOCKED);
			
			// This is the title specific subFolder. It will be something like RoadToIELTS2-Academic
			// and comes from a mix of T_ProductLanguage and T_Accounts. 
			// Its purpose is to allow an account to swap language versions easily for a title.
			if (thisTitle.dbContentLocation) {
				//loginout
				this.paths.content = this.contentRoot + thisTitle.dbContentLocation;
				//this.paths.content += thisTitle.dbContentLocation;
			} else if (thisTitle.contentLocation) {
				// #472 - only concatenate if the path doesn't already end with this.  A little hacky but the chances of the normal content URL ending with the
				// content location path already are slim to none.
				if (!StringUtils.endsWith(this.paths.content, thisTitle.contentLocation))
					//loginout
					this.paths.content = this.contentRoot + thisTitle.contentLocation;
					//this.paths.content += thisTitle.contentLocation;
			}
			
			// See if you can now do any substitutions on the menu filename
			buildMenuFilename();
			
			// You can now adjust the sharedMedia path as necessary
			// Remember that it might look like 
			// sharedMedia={contentPath}/sharedMedia
			this.paths.sharedMedia = this.paths.sharedMedia.toString().split('{contentPath}').join(this.paths.content);
			// gh#224
			this.paths.brandingMedia = this.paths.brandingMedia.toString().split('{prefix}').join(account.prefix);
		
			// gh#356 If there is a local channel available tested if it is accessible
			localStreamingMedia = getLicenceAttribute('localStreamingMedia');
			if (localStreamingMedia) {
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, onStreamingMediaCheckLoaded);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onStreamingMediaCheckError);
				urlLoader.load(new URLRequest(localStreamingMedia + "streamingMediaCheck.xml"));
			}
			
			// Whilst the title/account holds most licence info, it is nice to keep it in one class
			this.licence = data.licence as Licence;

			// gh#224
			var customisationFromDB:String = this.getLicenceAttribute('customisation');
			if (customisationFromDB)
				// this.customisation = XmlUtils.mergeXML(this.account.licenceAttributes.customisation, data.customisation);
				this.customisation = new XML(customisationFromDB);
		}

		/**
		 * Update the user details you are holding when you come back from login
		 * 
		 */
		public function mergeUser(user:User):void {
			this.username = user.name;
			this.studentID = user.studentID;
			this.email = user.email;
			this.userID = user.id;
		}
		/**
		 * Check for all the errors that you might know about now
		 * Move this into ConfigProxy so you can do better handling of the error.
		 */
		/*
		public function checkErrors():void {
			
		}
		*/
		
		/**
		 * #530
		 * This looks up a specific entry in the licence attributes
		 */
		public function get subRoots():String {
			return getLicenceAttribute('subRoots');
		}
		/**
		 * gh#356
		 */
		public function getLicenceAttribute(attr:String):String {
			if (this.account) {
				if (this.account.licenceAttributes) {
					for each (var lA:Object in this.account.licenceAttributes) {
						if (lA.licenceKey.toLowerCase() == attr.toLowerCase())
							return lA.licenceValue;
					}
				}
			}
			return null;			
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
		public function isIPInRange(thisIPList:String, range:String):Boolean {
			
			// gh#39 for tablets there may be no IP address
			if (!thisIPList) 
				return false;
			
			// #346 thisIP might be a comma delimitted string too
			// BUG, this list might have spaces which stop the matching
			var thisIPArray:Array = thisIPList.split(",");
			for each (var thisIP:String in thisIPArray) {
				// gh#902
				thisIP = StringUtils.trim(thisIP);
				var ipRangeArray:Array = range.split(",");
				
				for (var t:String in ipRangeArray) {
					// gh#902
					ipRangeArray[t] = StringUtils.trim(ipRangeArray[t] as String);
					// first, is there an exact match?
					if (thisIP == ipRangeArray[t])
						return true;
					
					// or does it fall in the range? 
					// assume nnn.nnn.nnn.x-y or nnn.nnn.x-y
					var targetBlocks:Array = ipRangeArray[t].split(".");
					var thisBlocks:Array = thisIP.split(".");
					// how far down do they specify?
					for (var i:uint=0; i<targetBlocks.length; i++) {
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
			}
			return false;
		}
		/**
		 * Detail function to see if the referrer you came from matches a range 
		 * @param referrer
		 * @param range
		 * @return Boolean
		 * 
		 */
		public function isRUInRange(thisReferrer:String, range:String):Boolean {
			
			// gh#39 rearrange checking order
			if (!thisReferrer)
				return false;
			
			var ruRangeArray:Array = range.split(",");
			for (var t:String in ruRangeArray) {
				
				if (thisReferrer.toLowerCase() == ruRangeArray[t].toLowerCase())
					return true;
				
				if (thisReferrer.toLowerCase().indexOf(ruRangeArray[t].toLowerCase()) >= 0) {
					//trace("partial referrer match");
					return true;
				}
			}
			return false;
		}
		
		// gh#356 localStreamingMedia path is accessible, so ONLY use that
		private function onStreamingMediaCheckLoaded(event:Event):void {
			channels = new Array();
			var channelObject:ChannelObject = new ChannelObject();
			channelObject.name = 'network';
			channelObject.caption = 'local';
			channelObject.streamingMedia = this.localStreamingMedia;
			channels.push(channelObject);
		}

		// gh#365 localStreamingMedia was not accessible, so just ignore it
		private function onStreamingMediaCheckError(event:IOErrorEvent):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			log.info("Could not access local streaming media " + event.text);
		}
	}
}