/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.model.SCORMProxy;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.events.MemoryEvent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Bookmark;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Licence;
	
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
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
	public class LoginProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "LoginProxy";
		public static const LICENCE_UPDATE_DELAY:Number = 60000;
		
		private var _user:User;
		private var _group:Group;
		private var _groupTrees:Array;
		
		// gh#1067
		//private var _memory:Memory;

		private var licenceTimer:Timer;

		public function LoginProxy(data:Object = null) {
			super(NAME, data);
			
			// TODO: We might want to maintain sessions later on, but for the moment always ensure authentication is cleared
			// on each startup.
			//logout();
		}
		
		public function get user():User {
			return _user;
		}
		
		public function get group():Group {
			return _group;
		}
		
		public function get groupTrees():Array {
			return _groupTrees;
		}
		
		// gh#1067
		/*
		public function get memory():Memory {
			return _memory;
		}
		public function set memory(value:Memory):void {
			if (value != _memory)
				_memory = value;
		}
		*/
		
		// #341
		//public function login(key:String, password:String):void {
		public function login(user:User, loginOption:Number, verified:Boolean = true, demoVersion:String = null):void {
			// getAccountSettings will already have established rootID and productCode
			// The parameters you pass are controlled by loginOption
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var loginObj:Object;
			
			// For AA licences you still do the call as this does getLicenceSlot
			
			//var loginOption:uint = configProxy.getAccount().loginOption;
			// gh#41 Test drive choice
			if (user == null) {
		        loginObj = null;
			} else if (loginOption & Config.LOGIN_BY_NAME || loginOption & Config.LOGIN_BY_NAME_AND_ID) {
				loginObj = { username: user.name, password: user.password};
			} else if (loginOption & Config.LOGIN_BY_ID) {
				loginObj = { studentID: user.studentID, password: user.password};
			} else if (loginOption & Config.LOGIN_BY_EMAIL) {
				loginObj = { email: user.email, password: user.password };
			} else {
				// Throw an error as you don't know how to login
				var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
				sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorInvalidLoginOption", { loginOption: loginOption } ));			
			}
			
			if (loginObj && configProxy.getConfig().ip)
				loginObj.ip = configProxy.getConfig().ip;
			
			if (loginObj)
				loginObj.timezoneOffset = new Date().timezoneOffset; // gh#156
			
			// #340
			// Network allows anonymous entry if all fields are blank
			// gh#100 as does CT
			// gh#165
			// gh#886
			if (((configProxy.getLicenceType() == Title.LICENCE_TYPE_NETWORK) || 
				(configProxy.getLicenceType() == Title.LICENCE_TYPE_CT) ||
				(configProxy.getLicenceType() == Title.LICENCE_TYPE_AA && configProxy.getConfig().noLogin == false) ||
				(loginOption & Config.LOGIN_BY_ANONYMOUS)) &&
				(!user.name || user.name=='') &&
				(!user.studentID || user.studentID=='') &&
				(!user.email || user.email==''))
				loginObj = null;
			
			// #307 Add rootID and productCode
			// #341 Add verified to allow no password
			// #361 instanceID
			// #503 If subRoots is set in licenceAttributes, send that instead of the main rootID
			if (configProxy.getConfig().subRoots) {
				var rootID:Array = configProxy.getConfig().subRoots.split(',');
			} else {
				
				// gh#21 you might not know a root, in which case this will return undefined
				//user != null is for webpage TestDrive
				// gh#99 But AA licences give you a null user too! Perhaps we don't need webpage TestDrive
				//if (configProxy.getRootID() && user != null) {
				if (configProxy.getRootID()) {
					rootID = new Array(1);
					rootID[0] = configProxy.getRootID();
					
				// gh#41 An account with no root set and a null user can only mean test drive
				} else if (user == null) {
					// TODO: Test Drive: how to set these settings nicely??
					// and how to offer them a choice of different titles??
					loginOption = Config.LOGIN_BY_ANONYMOUS;
					rootID = new Array(2);
					if (demoVersion == "NAMEN") {
						// for Noth American Demo
						rootID[0] = 13456;
						rootID[1] = 0;
					} else if (demoVersion == "EN") {
						// for international Demo
						rootID[0] = 10103;
						rootID[1] = 0;					
					} else { 
						// for test drive
						rootID[0] = 14031;
						rootID[1] = 0;
					}
					//#gh41
					//configProxy.getConfig().productCode = '52';
					loginObj = null;
				}
			}
			
			// gh#165 This call requires licence!
			configProxy.getConfig().licence.licenceType = configProxy.getLicenceType();
			
			// gh#39 You might not know an exact productCode, in which case we have to send comma delimited list
			// gh#36 Also need dbHost if this is the first call
			var params:Array = [ loginObj, loginOption, verified, configProxy.getInstanceID(), configProxy.getConfig().licence, rootID, configProxy.getProductCode(), configProxy.getConfig().dbHost ];
			new RemoteDelegate("login", params, this).execute();
		}
		
		public function logout():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var params:Array = [ configProxy.getConfig().licence, configProxy.getConfig().sessionID ];
			new RemoteDelegate("logout", params, this).execute();
			
			// Stop the licence update timer
			if (licenceTimer) licenceTimer.stop();
			
			// #336 Logout triggers SCORM termination
			if (configProxy.getConfig().scorm) {
				var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
				scormProxy.terminate();
			}
						
			// Clear the remote shared object, if there is one
			var loginSharedObject:SharedObject = SharedObject.getLocal("login");
			loginSharedObject.clear();
		}
		
		/**
		 * Method to get user's instance ID from the database.
		 * #323 Only applicable to tracking licences
		 *
		 * @return void - Asynchronous call. Will return instanceID and error objects later. 
		 */
		public function checkInstance():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			// #323
			// gh#335 Library Premium uses CT, but it might still be anonymous
			if (user && (Number(user.userID) > 0) &&
						(configProxy.getLicenceType() == Title.LICENCE_TYPE_LT || 
						 configProxy.getLicenceType() == Title.LICENCE_TYPE_CT ||
						 configProxy.getLicenceType() == Title.LICENCE_TYPE_TT)) {
				
				// #319 Instance ID per productCode
				var params:Array = [ user.userID, configProxy.getProductCode() ];
				new RemoteDelegate("getInstanceID", params, this).execute();
			}
		}

		/**
		 * Function to send a user's changed details to the database
		 */
		public function updateUser(userChanges:Object):void {
			// Current user details are already here
			// So the user details you are passed just overwrite the relevant ones
			// Do I need to clone the user in case I end up not managing to make the change?
			var newUserDetails:User = user;
			
			// Get new details from the passed object
			// We could either cycle through all properties or just do expected ones
			if (userChanges.password)
				newUserDetails.password = userChanges.password;
			if (userChanges.examDate)
				newUserDetails.birthday = userChanges.examDate;
			if (userChanges.email)
				newUserDetails.email = userChanges.email;
			
			// #307 pass rootID too
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			var params:Array = [ newUserDetails, configProxy.getRootID() ];
			new RemoteDelegate("updateUser", params, this).execute();
		}
		
		/**
		 * Function to add a new user to the database
		 * #341
		 */
		public function addUser(user:User, loginOption:Number):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			var params:Array = [ user, loginOption, configProxy.getRootID(), configProxy.getConfig().group ];
			new RemoteDelegate("addUser", params, this).execute();
		}

		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void {
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			switch (operation) {
				case "getInstanceID":
					if (data) {
						// Check if the returned instance ID is the same as our current session
						configProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
						
						// To help Alfred trigger the error screen
						if (Config.DEVELOPER.name == "AN") {
							var config:Config = configProxy.getConfig();
							config.instanceID = '123';
						}
						
						// DK: Disabled this for me as its stopping me testing any exercises
						if (data.instanceID != configProxy.getInstanceID() && Config.DEVELOPER.name != "DK") {
							sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorFailedInstanceCheck", { instanceID: data.instanceID, sessionID: configProxy.getInstanceID() } ));
						}
						
					} else {
						sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorGetInstanceId"));
					}
					break;
				
				case "updateLicence":
					break;
				
				case "updateUser":
					sendNotification(BBNotifications.USER_UPDATED, data);	
					break;
				
				case "addUser":
					if (data) {
						// Just go back into login for this user now
						configProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
						login(data as User, configProxy.getAccount().loginOption);
						
					} else {
						sendNotification(CommonNotifications.ADD_USER_FAILED);						
					}
					break;
				
				case "login":
					if (data) {
						// Successful login
						
						// AR Use the loginProxy as a model as well as a service by holding the data that comes back here
						// TODO. Although id and name are properties of manageable and thus user in PHP
						// it seems that it doesn't get set here. It is in manageables[0].inherited data
						// And id and name are the two key pieces of information I need.
						_user = data.group.manageables[0] as User;
						_group = data.group as Group;
						_groupTrees = data.groupTrees;
						
						// Add the licence id you just got to the config
						var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
						configProxy.getConfig().licence.id = (data.licence as Licence).id as Number;
						
						// Store a user config object in a shared object if rememberLogin is turned on #385
						if (configProxy.getConfig().rememberLogin) {
							if (!_user.isAnonymous()) {
								var loginSharedObject:SharedObject = SharedObject.getLocal("login");
								loginSharedObject.data["user"] = new User({ name: _user.name, studentID: _user.studentID, password: _user.password, email: _user.email });
								loginSharedObject.flush();
							}		
						}
						
						// gh#21 If login changed the account 
						// save what we now know about the account in Config
						if (data.account) {
							// #503
							// If login wants to change the rootID it will have sent back a new rootID in data
							log.info("rootID changed from {0} to {1}", configProxy.getConfig().rootID, new Number(data.rootID));
							configProxy.getConfig().rootID = new Number(data.rootID);
							
							//for webpage TestDrive
							if (configProxy.getConfig().paths.menuFilename.indexOf("{productVersion}")<0 || configProxy.getConfig().paths.menuFilename.indexOf("{productCode}")<0 )
								configProxy.getConfig().paths.menuFilename = configProxy.getConfig().configFilename;
							
							configProxy.getConfig().mergeAccountData(data);
							var authenticated:Boolean = configProxy.checkAuthentication();
						}
						
						// gh#1040, gh#1067
						var memory:Object = data.memory;
						
						// Is there a startingPoint set?
						if (memory && memory.directStart) {
							config = configProxy.getConfig();
							var bookmark:Bookmark = new Bookmark(memory.directStart);
							config.courseID = bookmark.course;
							config.startingPoint = bookmark.startingPoint;
						}
								
						// Carry on with the process
						sendNotification(CommonNotifications.LOGGED_IN, data);
						
						// #339 take this away, use the state machine, but session start command has to get data from proxy
						/*
						// Now that you are logged in, trigger the session start command
						var sessionData:Object = { user: _user, account: configProxy.getAccount() };
						sendNotification(BBNotifications.SESSION_START, sessionData);
						*/
						
						// Create a timer that will be fired off every minute to update the licence
						// Only needs to be done for concurrent licence control learners
						if (_user.userType==User.USER_TYPE_STUDENT && 
							(configProxy.getLicenceType() == Title.LICENCE_TYPE_AA || 
							configProxy.getLicenceType() == Title.LICENCE_TYPE_NETWORK || 
							configProxy.getLicenceType() == Title.LICENCE_TYPE_CT)) {
							
							// An error check
							if (configProxy.getConfig().licence.id <= 0)
								sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorCantAllocateLicenceNumber"));
							
							licenceTimer = new Timer(LICENCE_UPDATE_DELAY, 0)
							licenceTimer.addEventListener(TimerEvent.TIMER, licenceTimerHandler);
							licenceTimer.start();
						}
					} else {
						// Invalid login. But a no such user error will go to onDelegateFail not here.
						sendNotification(CommonNotifications.INVALID_LOGIN);
					}
					break;
				
				case "logout":
					sendNotification(CommonNotifications.LOGGED_OUT);
					break;
				
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, fault:Fault):void {
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			switch (operation) {
				case "login":
					// Clear the remote shared object, if there is one so it doesn't keep trying to log back in
					var loginSharedObject:SharedObject = SharedObject.getLocal("login");
					loginSharedObject.clear();
					
					// #445 Any error other than user not found is simply reported
					var thisError:BentoError = BentoError.create(fault);
					if (thisError.errorNumber == copyProxy.getCodeForId("errorNoSuchUser")) {
						
						// #341 For network, if you don't find the user, offer to add them
						// gh#100 and for CT too (so long as selfRegister is set)
						// gh#100 and for LT/TT too surely!
						// gh#837 not allowed self-register in C-Builder
						var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
						if ((configProxy.getLicenceType() == Title.LICENCE_TYPE_NETWORK ||
							configProxy.getLicenceType() == Title.LICENCE_TYPE_CT ||
							configProxy.getLicenceType() == Title.LICENCE_TYPE_LT ||
							configProxy.getLicenceType() == Title.LICENCE_TYPE_TT ||
						    (configProxy.getLicenceType() == Title.LICENCE_TYPE_AA && configProxy.getConfig().noLogin != true)) &&
							configProxy.getAccount().selfRegister > 0 &&
							(FlexGlobals.topLevelApplication.name as String).indexOf("Builder") < 0) {
							sendNotification(CommonNotifications.CONFIRM_NEW_USER);
							
						// For SCORM, if the user doesn't exist, automatically add them
						} else if (configProxy.getConfig().scorm) {
							var scormProxy:SCORMProxy = facade.retrieveProxy(SCORMProxy.NAME) as SCORMProxy;
							var configUser:User = new User({name:scormProxy.scorm.studentName, studentID:scormProxy.scorm.studentID});
							var loginOption:uint = configProxy.getAccount().loginOption;
							var verified:Boolean = (configProxy.getAccount().verified == 1) ? true : false;
	
							var loginEvent:LoginEvent = new LoginEvent(LoginEvent.ADD_USER, configUser, loginOption, verified);
							sendNotification(CommonNotifications.ADD_USER, loginEvent);
							
						} else {
							sendNotification(CommonNotifications.INVALID_LOGIN, BentoError.create(fault, false)); // GH #3
						}
					} else {
						sendNotification(CommonNotifications.INVALID_LOGIN, BentoError.create(fault, false)); // GH #3
					}

					break;
				
				case "addUser":
					sendNotification(CommonNotifications.ADD_USER_FAILED, BentoError.create(fault));
					break;
				case "updateLicence":
					sendNotification(CommonNotifications.BENTO_ERROR, BentoError.create(fault));
					// Stop the licence update timer
					if (licenceTimer) licenceTimer.stop();

					break;
				case "updateUser":
					sendNotification(CommonNotifications.UPDATE_FAILED);
					break;
				case "getInstanceID":
					sendNotification(CommonNotifications.BENTO_ERROR, BentoError.create(fault));
					break;
			}
			
			sendNotification(CommonNotifications.TRACE_ERROR, fault.faultString);
		}
		
		/**
		 * A timer handler that tells the database to update the licence record to show that the user is still active 
		 * @param event
		 * @param TimerEvent
		 * 
		 */
		private function licenceTimerHandler(event:TimerEvent):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			log.info("fire the timer to update licence {0}", configProxy.getConfig().licence.id);
			var params:Array = [ configProxy.getConfig().licence ];
			new RemoteDelegate("updateLicence", params, this).execute();
		}
		
	}
}