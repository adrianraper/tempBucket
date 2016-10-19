﻿/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.bento.BBNotifications;
    import com.clarityenglish.bento.model.BentoProxy;
    import com.clarityenglish.bento.model.DataProxy;
    import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Account;
	import com.clarityenglish.dms.vo.account.Licence;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.formatters.DateFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.Fault;
	import mx.styles.StyleManager;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class ConfigProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "ConfigProxy";
		
		private var config:Config;
		
		private var _dateFormatter:DateFormatter;
		
		// gh#853
		private var _directStartOverride:Boolean = false;

		/**
		 * Configuration information comes from three sources
		 * 1) config.xml. This holds base paths and other information that is common to all accounts, but differs between products
		 * 2) parameters passed from the start page or command line. This is specific to this account or this user or this session
		 * 3) details from the database for this account. Specific to this account.
		 * 
		 * Get it in the above order as, in theory, each could override the previous, though in practice this doesn't happen.
		 */
		public function ConfigProxy(data:Object = null) {
			super(NAME, data);
			
			_dateFormatter = new DateFormatter();
			_dateFormatter.formatString = "D MMMM YYYY";
			
			config = new Config();
		}
		
		// gh#13
		public function reset():void {
            // gh#1090 Clear everything except that which you retained on the first go, special case for logout of demo accounts
            // gh#1277 Network prefix is set to DEMO for historical reasons, so ignore that case
            if ((config.prefix == "TD" || config.prefix == "DEMO" || config.prefix == "DEMON") && getLicenceType() != Title.LICENCE_TYPE_NETWORK)
                config.retainedParameters = {};

			// TODO. Examine if these really are the right things to reset for a fresh login
            // For instance, why would you change the title details?
            // I suppose that for tablet, a new login picks up new account and title
			// Especially the licence type
			config.rootID = new Number();
			config.licence = new Licence();
			// gh#165 licence type is set in config top level AND in config.licence
			//this.setLicenceType = Title.LICENCE_TYPE_LT;
			//config.licence.licenceType = Title.LICENCE_TYPE_LT;
			config.account = new Account();
			var dummyTitle:Title = new Title();
			dummyTitle.licenceType = Title.LICENCE_TYPE_LT;
			config.account.titles = new Array(dummyTitle);
			config.account.name = '';
			config.account.verified = 1;
			config.account.selfRegister = 0;
			config.account.loginOption = config.loginOption;
			
			config.productCode = config.configProductCode;
			config.paths.menuFilename = config.configFilename;
			config.instanceID = null;
            // gh#1314 Since you can't reset the gateway, you don't want to reset the sessionID either
            //config.sessionID = null;

			// gh#1160
			config.userID = config.username = config.email = config.studentID = config.password = config.startingPoint = config.sessionID = null;
			config.group = new Group();
			config.prefix = "";
			config.noLogin = false;
			config.isReloadAccount = false;

			// #584
			config.startingPoint = '';
			config.courseID = '';

			_directStartOverride = false;

            // gh#1314
            // gh#1160 If we have already used these, just keep those that are retainable.
            // gh#1090 config.retainedParameters cannot tell the object is empty or not.
            if (config.retainedParameters["prefix"])
                config.mergeParameters(config.retainedParameters);

        }
		
		/**
		 * Method to get details sent on the command line, or from the start page
		 * 
		 */
		public function getApplicationParameters():void {
			// gh#1314 merge parameters from command line earlier now

            // gh#1405 Initialise SCORM
            // #336 SCORM initialisation might fail and raise an exception. Don't bother going on...
            if (config.scorm) {
                var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
                var rc:Boolean = scormProxy.initialise();
            }

            // Trigger the database call
			getAccountSettings();
		}

		/**
		 * Method to get details about the account from the database
		 *
		 * @return void - Asynchronous call. Will return account, title, config and error objects. 
		 */
		private function getAccountSettings():void {
			// TODO. Do you need to check that the remote gateway is up and running since we only just set it?
			if (Config.DEVELOPER.name.indexOf("DK") >= 0) {
				if (!config.prefix) config.prefix = "Clarity";
			}
			
			// gh#21 If you are basing the account on the login, then go direct to login
			if (config.loginOption && !config.prefix && !config.rootID) {
				// gh#315 Trigger a call to check the IP first
				var dbConfig:Object = { dbHost: config.dbHost, ip: config.ip, productCode: config.productCode };
				var params:Array = [ dbConfig ];
				new RemoteDelegate("getIPMatch", params, this).execute();
				
			} else {			
				// Create a subset of the config object to pass to the remote call
				// I could do some error handling before we go
				//	we must have rootID or prefix (prefix is most likely)
				//	we must have a productCode
				//  and it isn't nice to send NaN as rootID
				dbConfig = { dbHost: config.dbHost, prefix: config.prefix, rootID: config.rootID, productCode: config.productCode };
				params = [ dbConfig ];
				new RemoteDelegate("getAccountSettings", params, this).execute();
			}
		}

		// gh#315
		public function createDummyAccount():void {
			// There is a minimum of account information that you will have to default to be able to display login screen
			// productCode, productVersion and loginOption come from XML
			config.rootID = -1;
			config.account = new Account();
			var dummyTitle:Title = new Title();
			dummyTitle.licenceType = Title.LICENCE_TYPE_LT;
			config.account.titles = new Array(dummyTitle);
			config.account.name = '';
			config.account.verified = 1;
			config.account.selfRegister = 0;
			config.account.loginOption = config.loginOption;
			// trace("loginOption in ConfigProxy getAccountSettings is "+config.account.loginOption);
			config.account.IPMatchedProductCodes = new Array();
			config.licence = new Licence();
			// gh#165
			// config.licence.licenceType = Title.LICENCE_TYPE_LT;
			
			// gh#39 It seems that a problem is caused by sending the ACCOUNT_LOADED notification before the state machine 
			// has properly transitioned into the next state, causing unpredictable results.
			// So here is a hacky but working solution: 
			setTimeout(function():void {
				sendNotification(CommonNotifications.ACCOUNT_LOADED);
			}, 100); 
			
		}
		
		/**
		 * Reads the config file. Assume that this is given or picked up from application parameters.
		 *
		 * @param	filename
		 * @return
		 */
		public function loadConfig(filename:String = null):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onConfigLoadError);
			urlLoader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
			
			try {
				log.info("Open config file: {0}", filename);
				// Once the system is stable we might drop the cache clearer
				urlLoader.load(new URLRequest(filename + "?cache=" + new Date().time));
			} catch (e:SecurityError) {
				log.error("A SecurityError has occurred for the config file {0}", filename);
			}
		}
		
		public function onConfigLoadComplete(e:Event):void {
			//config = new XML(e.target.data);
			config.mergeFileData(new XML(e.target.data));

            // gh#1314  Use what is passed from start page or command line
            // gh#1160 If we have already used these, just keep those that are retainable.
            // gh#1090 config.retainedParameters cannot tell the object is empty or not.
            //if (config.retainedParameters["prefix"]) {
            //    var parameters:Object = config.retainedParameters;
            //} else {
            //    parameters = FlexGlobals.topLevelApplication.parameters;
            //}
            config.mergeParameters(FlexGlobals.topLevelApplication.parameters);

            // Configure the delegate now that you have the gateway path.  If a sessionid is defined then add it to the gateway.
            // gh#1314 Otherwise generate an id to use as a session id.
            //log.debug('use config.sessionID=' + config.sessionID);
			RemoteDelegate.setGateway(config.remoteGateway + "gateway.php", { PHPSESSID: config.sessionID });
			RemoteDelegate.setService(config.remoteService);
			
			// A special case; if disableAutoTimeout is true then turn off the activity timer #385
			facade.removeCommand(BBNotifications.ACTIVITY_TIMER_RESET);
			
			// #410 (too early though)
			sendNotification(BBNotifications.NETWORK_CHECK_AVAILABILITY);

            // Next stage is to get data from the database
			// #322 Get copy literals first
			// getApplicationParameters();
			sendNotification(CommonNotifications.CONFIG_LOADED);
		}
		
		private function onConfigLoadError(e:IOErrorEvent):void {
			log.error("Problem loading the config file: {0}", e.text);
		}
		
		// gh#234
		public function isPlatformTablet():Boolean {
			return (config.platform.toLowerCase().indexOf('tablet') >= 0);
		}
		public function isPlatformiPad():Boolean {
			return (config.platform.toLowerCase().indexOf('ipad') >= 0);
		}
		public function isPlatformAndroid():Boolean {
			return (config.platform.toLowerCase().indexOf('android') >= 0);
		}
		
		public function getAndroidSize():String {
			if (FlexGlobals.topLevelApplication.stage.stageWidth >= 1280) {
				return "10Inches";
			} else {
				return "7Inches";
			}
		}
		
		// Then methods to get parts of the configuration data
		public function getMenuFilename():String {
			return config.paths.menuFilename;
		}
		
		public function getContentPath():String {
			return config.paths.content;
		}
		
		public function getAccount():Account {
			return config.account;
		}
		
		public function getLicence():Licence {
			return config.licence;
		}
		
		public function getUserID():String {
			return config.userID;
		}
		
		public function getInstanceID():String {
			return config.instanceID;
		}
		
		public function getProductVersion():String {
			return config.productVersion;
		}
		
		public function getProductCode():String {
			return config.productCode;
		}
		
		public function getLoginOption():Number {
			// gh#44 - use the config loginOption, or if there is none use the account login option
			return getConfig().loginOption || getAccount().loginOption;
		}
		
		// gh#165 licence type stored in multiple places
		public function getLicenceType():uint {
			return config.licenceType;
		}

		public function getRemoteDomain():String {
			return config.remoteDomain;
		}

		public function getRootID():Number {
			return config.rootID;
		}
		
		// gh#660 get randomized test question total number
		// gh#1030 remove
		
		public function getConfig():Config {
			return config;
		}
		
		public function getDateFormatter():DateFormatter {
			return _dateFormatter;
		}

		// gh#371
		public function getOtherParameters():Object {
			return config.otherParameters;
		}
		
		// gh#224 get the branding for a particular section
		public function getBranding(section:String):XML {
			if (config.customisation && config.customisation.child(section))
				return config.customisation.child(section)[0];
			return null;
		}
		/**
		 * Direct login is implemented here. If a LoginEvent is returned then the application should log straight in without showing a login screen.
		 * 
		 * @return 
		 */
		public function getDirectLogin():LoginEvent {
			var loginOption:uint = getAccount() ? getAccount().loginOption : null;
			var verified:Boolean = getAccount() ? ((getAccount().verified == Config.LOGIN_REQUIRE_PASSWORD) ? true : false) : false;
			
			var configUser:User;
			
			// gh#21. You might not have an account, but you might have loginOption from config
			if (!loginOption)
				loginOption = config.loginOption ? config.loginOption : null;
			
			// Debug auto-logins
			switch (Config.DEVELOPER.name) {
				case "AR":
					configUser = new User({ name: "dandelion", password: "password", email:"dandy@email" });
					return new LoginEvent(LoginEvent.LOGIN, configUser, loginOption, verified);
				case "DKweb":
					configUser = new User({ name: "dandelion", password: "password" });
					return new LoginEvent(LoginEvent.LOGIN, configUser, loginOption, verified);
				case "DK":
					configUser = new User({ name: "Mrs white", password: "password" });
					return new LoginEvent(LoginEvent.LOGIN, configUser, loginOption, verified);
				case "network":
					configUser = new User({ name: "Student", studentID: "123", password: "password" });
					return new LoginEvent(LoginEvent.LOGIN, configUser, loginOption, verified);
			}
			
			// #385 Login from shared object
			if (config.rememberLogin) {
				var loginSharedObject:SharedObject = SharedObject.getLocal("login");
				if (loginSharedObject.data["user"]) {
					configUser = loginSharedObject.data["user"];
					return new LoginEvent(LoginEvent.LOGIN, configUser, loginOption, verified);
				}
			}
			
			// Take it from from the URL parameters (see config.as.mergeParameters)
			/*
			if (FlexGlobals.topLevelApplication.parameters.studentID &&
				FlexGlobals.topLevelApplication.parameters.password) {
				return new LoginEvent(LoginEvent.LOGIN, FlexGlobals.topLevelApplication.parameters.studentID, FlexGlobals.topLevelApplication.parameters.password);
			}
			*/
			// Take it from config rather than direct from the parameters
			// #334
			if ((config.username && (loginOption & Config.LOGIN_BY_NAME)) || 
				(config.username && (loginOption & Config.LOGIN_BY_NAME_AND_ID)) ||
				(config.studentID && (loginOption & Config.LOGIN_BY_ID)) || 
				(config.email && (loginOption & Config.LOGIN_BY_EMAIL))) {
				//trace("direct start from config, studentID=" + config.studentID + " loginOption=" + loginOption);
				
				configUser = new User({ name:config.username, studentID:config.studentID, email:config.email, password:config.password });
				return new LoginEvent(LoginEvent.LOGIN, configUser, loginOption, verified);
			}
			
			// Anonymous login
			if (this.getLicenceType() == Title.LICENCE_TYPE_AA) { // gh#165
				// gh#300 Builder doesn't allow anonymous login
				// gh#1090 An AA licence which blocks login just starts from here
				if (config.remoteService.toLowerCase().indexOf("builder") < 0 && this.getConfig().noLogin == true) {
					config.signInAs = Title.SIGNIN_ANONYMOUS;
					return new LoginEvent(LoginEvent.LOGIN, null, loginOption, verified);
				}
			}
				
			// #336 SCORM needs to be checked here as a form of direct start
			if (config.scorm) {
				var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;

                // gh#1405 SCORM might not have been initialised yet
                if (scormProxy.initialised) {
                    // gh#1227
                    configUser = new User({name: scormProxy.scorm.studentName, studentID: scormProxy.scorm.studentID, email: scormProxy.email});
                    return new LoginEvent(LoginEvent.LOGIN, configUser, loginOption, verified);
                }
			}
			
			return null;
		}
		
		/**
		 * Direct start is picked up here. This will be implemented by the titles, so there are no rules about what kind of object should be returned
		 * from this method. This is to allow any kind of direct starting (which may depend on the structure of the title).
		 * 
		 * @return 
		 */
		public function getDirectStart():Object {
			var directStartObject:Object = new Object();
			
			if (_directStartOverride)
				return directStartObject;
			
			// #336 SCORM needs to be checked here
			var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
			if (config.scorm) {
				// gh#858
				if (scormProxy.getBookmark().exerciseID) {
					var exerciseIDArray:Array = scormProxy.getBookmark().exerciseID.split(".");
					directStartObject.exerciseID = exerciseIDArray[exerciseIDArray.length - 1];
				} else {
					directStartObject = scormProxy.getBookmark();
				}
				
				directStartObject.scorm = true;
			} else {
				// #338. This is using a utility parsing function, it is for data from queryString
				// It doesn't actually have to be SCORM at all, works for all passed parameters
				if (config.startingPoint)
					directStartObject = scormProxy.parseSCORMdata(config.startingPoint, ':');
			}
			
			// #338. This is called from ProgressProxy to find out which menu bits to hide
			// and from the ApplicationMediator state machine to see what notifications to send for screens to display
			if (config.courseID)
				directStartObject.courseID = config.courseID;

            // gh#1080
            if (directStartObject.courseID) {
                var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
                var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
                if (bentoProxy.menuXHTML) {
                    var course:XML = bentoProxy.menuXHTML.getElementById(directStartObject.courseID);
                    var courseClass:String = course.(@id == directStartObject.courseID).@["class"].toString();
                    dataProxy.set("currentCourseClass", courseClass);
                }
            }
			return directStartObject;
		}
		// gh#853
		public function clearDirectStart():void {
			//config.courseID = null;
			//config.startingPoint = null;
			_directStartOverride = true;
		}

		// gh#790 Is this account a pure AA - so will avoid login
		public function isAccountJustAnonymous():Boolean {
			if (this.getLicenceType() == Title.LICENCE_TYPE_AA && this.getConfig().noLogin == true) {
				if (!isPlatformTablet()) {
					if (config.remoteService.toLowerCase().indexOf("builder") < 0) {
						return true;
					}
				} else {
					// gh#1090
					if (!config.isReloadAccount) {
						return true
					}
				}
			} else if (config.scorm) { // gh#1204 if it is SCORM object log out to credit page.
				return true;
			}
			return false;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				// gh#315
				case "getIPMatch":
					// If there is no data, it means no account found, so trigger login based account
					if (!data) {
						this.createDummyAccount();
						break;
					}
					// No break as data contains the full account information so process it as in getAccountSettings
				case "getAccountSettings":
					if (data) {
						// TODO. We should be able to set the language code for 
						//CopyProxy.languageCode = data.languageCode as String;
						/*
						We will get back the following objects in data
						account
						config
						<db>
							<note>
								<query dbHost="2" method="getRMSettings" rootID="" prefix="Clarity" eKey="" dateStamp="2011-10-17 22:50:42" productCode="9" cacheVersion="1318863042928" />
							</note>
							<note>dbhost=localhost dbname=rack80829 driver=mysql</note>
							<database version="6" />
							<settings loginOption="1" verified="1" selfRegister="0" />
							<decrypt key="undefined" />
							<account expiryDate="2012-12-31 23:59:59" maxStudents="998" groupID="163" rootID="163" licenceType="1" institution="Clarity Language Consultants Ltd" contentLocation="TenseBuster-International" MGSRoot="" licenceStartDate="2009-01-01 00:00:00" checksum="351669aed74a984aa13f8501ecdcadcd7c8f61b3cad49eaf4611a4510abfe85e" languageCode="EN" />
						</db>
						*/
						config.mergeAccountData(data);
						if (config.languageCode == "ZH" && !isPlatformTablet())
							StyleManager.getStyleDeclaration("global").setStyle("fontFamily","SimSun");
						// gh#113 This IP and RU check could easily be done in PHP, in which case LoginProxy would catch it
						// just like accountExpired. But for now leave this here with other config errors.
						var authenticated:Boolean = this.checkAuthentication();
					}
	
					if (!data) {
						sendNotification(CommonNotifications.CONFIG_ERROR, "Unable to read from database"); // at this point copy can't have loaded so this is in English!
						
					} else if (config.anyError()) {
						// gh#21
						// gh#113
						// sendNotification(CommonNotifications.ACCOUNT_LOADED);
						sendNotification(CommonNotifications.CONFIG_ERROR, config.error);
						
					} else {
						// #322
						//sendNotification(CommonNotifications.CONFIG_LOADED);
						//issue:#20
						/* #problem with login Screen: we have to put all language into one file
						var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
						copyProxy.setLanguageCode(config.languageCode);
						*/
						sendNotification(CommonNotifications.ACCOUNT_LOADED);
					}
					break;
				
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
			
			// Performance logging
			//var log:PerformanceLog = new PerformanceLog(PerformanceLog.APP_LOADED, config.appLaunchTime);
			//log.IP = config.ip;
			//sendNotification(CommonNotifications.PERFORMANCE_LOG, log);
		}

        public function onDelegateFault(operation:String, fault:Fault):void {
            var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
            var thisError:BentoError = BentoError.create(fault);

            if (fault.faultCode == 'AMFPHP_AUTHENTICATE_ERROR' || fault.faultString == 'errorLostAuthentication') {
                var authenticationError:BentoError = BentoError.create(fault);
                authenticationError.errorContext = copyProxy.getCopyForId("errorLostAuthentication");
                sendNotification(CommonNotifications.BENTO_ERROR, authenticationError);
            } else {

                switch (operation) {
                    // gh#315
                    case "getIPMatch":
                        if (thisError.errorNumber == copyProxy.getCodeForId("errorNoPrefixOrRoot")) {
                            this.createDummyAccount();
                            break;
                        }

                    case "getAccountSettings":
                        sendNotification(CommonNotifications.CONFIG_ERROR, thisError);
                        break;
                }
                sendNotification(CommonNotifications.TRACE_ERROR, fault.faultString);
            }
			// Performance logging
			//var log:PerformanceLog = new PerformanceLog(PerformanceLog.APP_LOADED, config.appLaunchTime);
			//sendNotification(CommonNotifications.PERFORMANCE_LOG, log);
		}
		
		/**
		 * Moved from config.as. 
		 * Check that the user's IP or referrer match the licence.
		 * Only run if the licence attributes say that you should.
		 */
		public function checkAuthentication():Boolean {
			
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			var ipFault:Boolean = false;
			var ruFault:Boolean = false;
			
			for each (var lA:Object in config.account.licenceAttributes) {
				// gh#886 only check IPrange for tablet
				// gh#1012 Why only check for tablet? Browsers HAVE to be able to check this match...
				//if (lA.licenceKey.toLowerCase() == 'iprange' && isPlatformTablet()) {
				if (lA.licenceKey.toLowerCase() == 'iprange') {
					if (!config.isIPInRange(config.ip, lA.licenceValue)) {
						config.error = copyProxy.getBentoErrorForId("errorIPDoesntMatch", { ip: config.ip }, true );
						ipFault = true;
					} else {
						// If you are successful, then this is all you need
						// trace("your ip, " + config.ip + ", is in the listed range.");
						config.error = new BentoError();
						return true;
					}
				}
				
				if (lA.licenceKey.toLowerCase() == 'rurange') {
					if (!config.isRUInRange(config.referrer, lA.licenceValue)) {
						if (!config.referrer)
							config.referrer = 'an unknown site';
						config.error = copyProxy.getBentoErrorForId("errorRUDoesntMatch", { referrer: config.referrer }, true );
						ruFault = true;
					} else {
						// trace("your referrer, " + config.referrer + ", is in the listed range.");
						config.error = new BentoError();
						return true;
					}
				}
			}
			
			if (ipFault && ruFault)
				config.error = copyProxy.getBentoErrorForId("errorIPandRUDontMatch", { referrer: config.referrer, ip: config.ip }, true );
			
			return false;
			
		}
	}
}
