/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
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
			// TODO. Examine if these really are the right things to reset for a fresh login
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
			var timeStamp:Date = new Date();
			config.instanceID = timeStamp.getTime().toString();
			
		}
		
		/**
		 * Method to get details sent on the command line, or from the start page
		 * 
		 */
		public function getApplicationParameters():void {
			/**
			 *  Use what is passed from start page or command line
			 */
			config.mergeParameters(FlexGlobals.topLevelApplication.parameters);
			// #336 SCORM
			// The SCORM initialisation might fail and raise an exception. Don't bother going on...
			var rc:Boolean = true;
			if (config.scorm) {
				var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
				rc = scormProxy.initialise();
			}
			
			// Trigger the database call
			if (rc)
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
			config.account.name = 'x';
			config.account.verified = 1;
			config.account.selfRegister = 0;
			config.account.loginOption = config.loginOption;
			// trace("loginOption in ConfigProxy getAccountSettings is "+config.account.loginOption);
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
			
			// Configure the delegate now that you have the gateway path.  If a sessionid is defined in the FlashVars then add it to the gateway.
			var sessionParams:Object = (FlexGlobals.topLevelApplication.parameters.sessionid != undefined) ? { PHPSESSID: FlexGlobals.topLevelApplication.parameters.sessionid } : null;		
			RemoteDelegate.setGateway(config.remoteGateway + "gateway.php", sessionParams);
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
		
		// Then methods to get parts of the configuration data
		public function getMenuFilename():String {
			//return "menu-Academic-LastMinute.xml";
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
		public function getRandomizedTestQuestionTotalNumber():Number {
			return config.randomizedTestQuestionTotalNumber;
		}
		
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
			var verified:Boolean = getAccount() ? ((getAccount().verified == 1) ? true : false) : false;
			
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
				if (config.remoteService.toLowerCase().indexOf("builder") < 0)
					return new LoginEvent(LoginEvent.LOGIN, null, loginOption, verified);
			}
				
			
			// #336 SCORM probably needs to be checked here
			if (config.scorm) {
				//trace("scorm");
				var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
				configUser = new User({ name:scormProxy.scorm.studentName, studentID:scormProxy.scorm.studentID });
				return new LoginEvent(LoginEvent.LOGIN, configUser, loginOption, verified);
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
			
			if (Config.DEVELOPER.name == "DKweb") {
				//return { courseID: "1287130400000" };
				//return { exerciseID: "2287130110007" };
				return { exerciseID: "2287130110005" };
			}
			
			if (Config.DEVELOPER.name == "AR") {
				//return { exerciseID: "1156181253997" }; // Writing>Set 1 task 2>Linking words and phrases (1)
				//return { exerciseID: "1156153794077" }; // Speaking>The speaking test (2)
			}
			
			// #336 SCORM needs to be checked here
			// TODO: This is overriden by the next line so could be removed?
			var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
			if (config.scorm) {
				directStartObject = scormProxy.getBookmark();
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
			
			return directStartObject;
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
