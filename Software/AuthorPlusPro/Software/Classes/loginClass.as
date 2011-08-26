import Classes.dbConn;
import Classes.licenceClass;

// v6.5.2.9 By Yiu md5Class is imported for encrypting password
import Classes.md5Class;

class Classes.loginClass {
	
	var control:Object;
	var view:Object;
	var licence:licenceClass; // v0.7.2, DL: check user's licence
	
	function loginClass(c:Object) {
		control = c;
		view = c.view;
		licence = new licenceClass();
	}
	
	// start program
	function startProgram() : Void {
		myTrace("Finish loading all modules, starting the program...");
		//myTrace("username=" + control._username + " preview=" + _global.NNW._preview);
		//myTrace("startProgram:root=" + control._rootID);
		
		// v0.16.0, DL: set Lite/Pro settings
		view.setLiteProSettings(control._lite);
		
		/* if login details is preset, login by the given details */
		if (_global.NNW._passLogin) {
			myTrace("(loginClass) - Login passed: pass login is set to true.");
			onCheckLogin(true);
		// v6.5.5.7 Allow RM to send the username and no password. This gets you in, but will not display any menus as it then
		// waits for localConnection to tell you where to go
		} else if (control._username.length>0 && _global.NNW._preview) {
			// v6.4.3 Also check rootID
			myTrace("(loginClass) - need to check preview details");
			// v6.5.4.6 Send a licenceID too
			control._licenceID = new Date().getTime();
			// v6.5.5.7 If we are previewing, we will send a null password but would still like to login please.
			control._password = "$!null_!$";
			checkLogin(control._username, control._password, control._rootID, control._licenceID);
		} else if (control._username.length>0 && control._password.length>0) {
			// v6.4.3 Also check rootID
			myTrace("(loginClass) - need to check login details");
			// v6.5.4.6 Send a licenceID too
			control._licenceID = new Date().getTime();
			checkLogin(control._username, control._password, control._rootID, control._licenceID);
		} else {
			// show always on top screen
			view.showAlwaysOnTopScreen();
			// if passed code check, no need show scnAuthCode
			if (control._passedCodeCheck) {
				onLoggedIn();	// v0.11.0, DL: load course.xml and things after logged in
			} else {
				view.showPleaseWait(false);
				view.showLoginScreen();
			}
		}
	}
	
	/*// check auth code
	function checkAuthCode() : Void {
		if (control._passedCodeCheck) {
			onLoggedIn();	// v0.11.0, DL: load course.xml and things after logged in
		}
	}*/
	/*function onEnteredCode(code) : Void {
		if (code.length == 3) {
			control._passedCodeCheck = true;
		} else {
			control._passedCodeCheck = false;
		}
		view.toggleAuthCodeTick(control._passedCodeCheck);
	}*/
	
	// check login
	// v6.4.3 Also check rootID
	function checkLogin(username, password, rootID) : Void {
		control._username = username;
		control._password = password;
		if (rootID == undefined) {
			control._rootID = _global.NNW._rootID;
		} else {
			control._rootID = rootID;
		}
		//_global.myTrace("checkLogin:rootID=" + control._rootID);
		if (control._testMode) {
			/*if (username.toUpperCase()=="NNW"&&password.toUpperCase()=="NNW") {
				onCheckLogin(true);
			} else {
				onCheckLogin(false);
			}*/
		/*} else if (username.toUpperCase()=="DEMO"&&password.toUpperCase()=="CLARITY") {
			onCheckLogin(true);*/
		// v6.5.2 AR you should be allowed to have an empty password if you want
		//} else if (username.length>0 && password.length>0) {
		} else if (username.length>0) {
			_global.myTrace("(loginClass) - check with " + username + " " + password);
			var cn = new dbConn();
			
			// ------------ v6.5.2.9 By Yiu 11-12-07 If the "Encryption" in licence file is equals to 2, encrypt the password of checking
			//myTrace("(Yiu)licence.encryption: " + licence.encryption);
			
			var strPasswordSending:String;
			strPasswordSending= password;
			
			if (licence.encryption == 2)
			{
				strPasswordSending= licence.md5.clarityMD5(password, "Clarity");
			}
			
			//myTrace("(Yiu)strPasswordSending: " + strPasswordSending);
			cn.checkLogin(username, strPasswordSending, control._rootID);
			// Commented because of using another variable for storing password
			//cn.checkLogin(username, password, control._rootID);
			// end v6.5.2.9 By Yiu 11-12-07 ------------
			
			delete cn;
		} else {
			//v6.4.4, RL : passes 1 more value to the function for checking MGS purpose
			//onCheckLogin(false);
			onCheckLogin(false, username);
		}
	}
	// v6.4.2.5 AR add userSettings passed back to here
	//function onCheckLogin(pass:Boolean, u:String) : Void {
	function onCheckLogin(pass:Boolean, u:String, s:String) : Void {
		/* show always on top screen */
		view.showAlwaysOnTopScreen();
		if (pass) {
			// v6.4.2.5 AR add userSettings passed back to here - probably not the right object.
			_global.NNW._userSettings = s;
			//v6.4.4, RL :get MGS
			var cn = new dbConn();
			cn.checkMGS(u);
			// move the onLoggedIn() after getMGS
			//onLoggedIn();	// v0.11.0, DL: load course.xml and things after logged in
		} else {
			view.showPleaseWait(false);
			view.showLoginScreen();
			view.showPopup("loginFail");
		}
	}
	
	//v6.4.4, RL: After check MGS go to get the MGS path.
	//v6.4.4, RL re-edited: checkMGS and getMGS are now in 1 go.
	/*
	function onCheckMGS(pass:Boolean, u:String) : Void {
		if(pass) {
			var cn = new dbConn();
			cn.getMGS(u);
			delete cn;
		} else {
			myTrace ("(loginClass) - checkMGS error.");
		}
	}
	*/

	// v6.4.2.5 New function to add the MGS into a content folder
	function addMGStoPath(originalFolderName:String, MGSName:String):String {
		if (control._enableMGS == false) {
			newFolderName = originalFolderName;
		} else {
			if (MGSName==undefined) MGSName = _global.NNW.paths.rawMGSName;
			var newFolderName:String;
			var thisMGSParts = originalFolderName.split("Content");
			if (thisMGSParts.length>1) {
				// if paths contains "Content":
				// rootpart/Content/Spaces/MGS/restpart
				// v2.4 AR We might have passed MGSRoot from the command line or read it from location.ini
				if (_global.NNW._MGSRoot == undefined) {
					newFolderName = thisMGSParts[0]+_global.addSlash("Content")+_global.addSlash("Spaces")+MGSName+thisMGSParts.slice(1).join(_global.addSlash("Content"));
				} else {
					newFolderName = _global.addSlash(_global.NNW._MGSRoot)+MGSName+thisMGSParts.slice(1).join(_global.addSlash("Content"));
				}
			} else {
				//if not: add MGS to the end
				//rootpart/Spaces/MGS
				// v2.4 AR We might have passed MGSRoot from the command line or read it from location.ini
				if (_global.NNW._MGSRoot == undefined) {
					newFolderName = _global.addSlash(thisMGSParts[0])+_global.addSlash("Spaces")+_global.addSlash(MGSName);
				} else {
					newFolderName = _global.addSlash(_global.NNW._MGSRoot)+MGSName;
				}
			}
		}
		_global.myTrace("login.addMGStoPath, original=" + originalFolderName + " MGS=" + MGSName + " final=" + newFolderName);
		return newFolderName;		
	}
	// v6.4.2.5 g was a groupID, not used
	//function onGetMGS(pass:Boolean, e:String, g:String, n:String) : Void {
	function onGetMGS(pass:Boolean, e:String, n:String) : Void {
		if (pass) {
			if (_global.NNW.paths.userApp==undefined) {_global.NNW.paths.userApp = "AuthorPlus";}
			//myTrace ("(login) - userApp= "+_global.NNW.paths.userApp);
			//myTrace ("(login) - contentPath= "+_global.NNW.paths.content);
			var thisMGSRoot = _global.NNW.paths.content;
			if (e=="0") {
			// v6.4.4, RL: since no MGS, the original path will become MGS path
				control._enableMGS = false;
				//var thisMGSRoot = _global.NNW.paths.content;
				// V6.4.2.5 This is the path used in other places, just set it to point to the original
				_global.NNW.paths.MGSPath = thisMGSRoot;
			} else if (e=="1"){
			// v6.4.4, RL: setup the MGS path
				control._enableMGS = true;
				// v6.4.2.5 Save the raw MGS name so you can insert it into other paths (clarity programs)
				_global.NNW.paths.rawMGSName = n;
				_global.NNW.paths.MGSPath = addMGStoPath(thisMGSRoot);
				
				/* v6.4.4,RL: MGS path remade @ 5Feb07
				var tmpArray = new Array();
				tmpArray = _global.NNW.paths.content.split("Content");
				_global.NNW.paths.MGSPath = tmpArray[0] + "Content/" + n + tmpArray[1];
				myTrace ("(login) - MGSPath= "+_global.NNW.paths.MGSPath);
				*/
				//_global.NNW.paths.MGSPath = "/Content/" + _global.addSlash(n) + _global.NNW.paths.userApp;
			} else { //error
				view.showPleaseWait(false);
				view.showLoginScreen();
				view.showPopup("loginFail");				
			}
			onLoggedIn(); // v6.4.4, RL: start loading things and course.xml
			//myTrace("(loginClass) - onGetMGS - MGSPath enable = "+control._enableMGS);
		} else {
			myTrace ("(loginClass) - getMGS error.");
			view.showPleaseWait(false);
			view.showLoginScreen();
			view.showPopup("loginFail");
		}
	}

	/* v0.7.2, DL: load licence.ini (in user data path) */
	function loadLicence() : Void {
		// if there is a licence file path, check licence
		if (control.paths.licence!="") {
			myTrace("(loginClass) - Loading user's licence...");
			licence.path = control.paths.licence;
			// v6.5.5.1 See if there IS a licence file
			if (licence.path==null) {
				_global.myTrace("no licence file passed, so check db directly");
				getLicenceDetails();
			} else {
				licence.loadLicence();
			}
		// otherwise, skip and start program
		//v6.4.3 You are joking!!
		//} else {
		//	startProgram();
		// v6.5.5.3 Otherwise read the database for T_AccountRoot and T_Accounts
		}
	}
	/* v0.7.2, DL: licence.ini loaded, check if need block access */
	function onLicenceLoaded() : Void {
		if (licence.error!="") {
			// v6.5.5.3 Can I check the database at this point to see if it will help with licence details?
			_global.myTrace("loginClass.onLicenceLoaded fails so check db");
			getLicenceDetails();
			//view.showPopup(licence.error);
		} else {
			// v6.5.5.3 Put this in a separate method so I can call it from the db call too
			this.onLicenceLoadedSuccessfully();
		}
	}
	function onLicenceLoadedSuccessfully() : Void {
		myTrace("(loginClass) - licence loaded successfully.");
		/* v0.10.1, DL: licence checking */
		// v6.4.2.4 AR new types of licence restriction
		control._productRestriction = (licence.productType=="Kit");
		control._lite = (licence.productType=="Light");
		if (!control._lite) {
			control.__maxNoOfCourses = 99;	// v0.16.0, DL: set max. no of courses
			control.__maxNoOfUnits = 99;	// v0.16.0, DL: set max. no of units
			control.__maxNoOfExercises = 99;	// v0.16.0, DL: set max. no of exercises
			control.__maxNoOfQuestions = 99;	// v0.12.0, DL: set max. no of questions
		}
		
		// v6.4.3 Pass through the root ID
		if (licence.centralRoot>0) {
			control._rootID = licence.centralRoot;
		} else {
			control._rootID = 1;
		}
		_global.NNW._rootID = control._rootID;
		//_global.myTrace("onLicenceLoaded:rootID=" + control._rootID);
		
		/* v0.16.0, DL: at this moment there's only control on ASP/SQLServer */
		/* for all other database types just let the user pass */
		// v0.16.1, DL: debug - don't know why database is not equal to "SQLServer"
		// v6.4.1.2, DL: now it supports FSP, but no logging in is required at the moment
		// therefore, if SQLServer/MySQL/Access is assigned, login should be checked
		if (licence.database.toUpperCase().indexOf("SQLSERVER")>-1) {
			_global.NNW._passLogin = false;
			control.paths.sqlServerPath = _global.NNW.paths.sqlServerPath = control.paths.main+"/SQLServer";
		} else if (licence.database.toUpperCase().indexOf("MYSQL")>-1) {
			_global.NNW._passLogin = false;
			control.paths.sqlServerPath = _global.NNW.paths.sqlServerPath = control.paths.main+"/MySQL";
		} else if (licence.database.toUpperCase().indexOf("ACCESS")>-1){
			//_global.NNW._passLogin = false;
			control.paths.sqlServerPath = control.paths.main+"/Access";
		} else {
			// v6.4.3 You can't just let people in like this!!
			//_global.NNW._passLogin = true;
			_global.NNW._passLogin = false;
		}
		
		//v6.4.2.4, RL: move the getDecryptKey from "before the loading licence" to "after"
		if (_global.NNW._encryptKey!="") {
			getDecryptKey();
		}
				
		// v6.4.1.2, DL: set server paths according to scripting
		if (control.__server) {
			if (licence.scripting.toLowerCase()=="php") {
				control.paths.serverPath = control.paths.main+"/PHP";
				control.paths.serverConnPath = control.paths.serverPath+"/serverConn.php";
			} else {
				control.paths.serverPath = control.paths.main+"/ASP";
				control.paths.serverConnPath = control.paths.serverPath+"/serverConn.asp";
			}
		}
		// v6.5.4.7 I need to save this globally for dbConn
		control.paths.scripting = licence.scripting.toLowerCase();
		
		/* v0.7.2, DL: check access control */
		// v6.4.1.2, DL: access control only applies on server version (ASP/PHP)
		if (control.__server && licence.accessControl=="1") {
			var sender = new LoadVars();
			var loader = new LoadVars();
			loader.master = this;
			loader.onLoad = function(success) {
				if (success) {
					//_global.myTrace("decrypted entry pass: " + this.result);
					if (this.result==this.master.licence.serialNumber) {
						_global.myTrace("passed entry pass test. proceed to decrypt password.");
						this.master.decryptPassword();
					} else {
						this.master.view.showPopup("blockAccess");
					}
				} else {
					_global.myTrace("failed to decrypt the entry pass, proceed anyway");
					this.master.decryptPassword();
				}
			}
			sender.x = _global.NNW._entryPass;
			sender.y = _global.NNW._decryptKey;
			
			// v6.4.1.2, DL: I wonder how useful it'll be as CE.com only runs on ASP
			// just to make everything the same i guess
			if (licence.scripting.toLowerCase()=="php") {
				var decryptScriptPage:String = "/function/decryptFromFlash.php";
			} else {
				var decryptScriptPage:String = "/function/decryptFromFlash.asp";
			}
			sender.sendAndLoad(decryptScriptPage, loader, "POST");
		} else {
			myTrace("(loginClass) - no access control. proceed to decrypt password.");
			decryptPassword();
		}
	}
	
	// 6.5.5.3 Read licence details from database
	function getLicenceDetails() : Void {
		var cn = new dbConn();
		cn.getLicenceDetails(_global.NNW._accountPrefix);
		delete cn;
	}
	
	/* v0.7.2, DL: get decrypt key using the encrypt key being passed */
	function getDecryptKey() : Void {
		var cn = new dbConn();
		cn.getDecryptKey();
		delete cn;
	}
	/* v0.7.2, DL: decrypt password using the decrypt key */
	function decryptPassword() : Void {
		if ((licence.version==2 && _global.NNW._decryptKey!="") || (licence.version>2 && licence.encryption=="1"&& _global.NNW._decryptKey!="")) {
			myTrace("(loginClass) - decrypting password...");
			var sender = new LoadVars();
			var loader = new LoadVars();
			loader.master = this;
			loader.onLoad = function(success) {
				if (success) {
					_global.myTrace("(loginClass) - decrypted password: " + this.result);
					this.master.control._password = this.result;
				} else {
					_global.myTrace("(loginClass) - fail to decrypt password.");
				}
				this.master.checkProductionServer();
			}
			sender.x = control._password;
			sender.y = _global.NNW._decryptKey;
			
			// v6.4.1.2, DL: I wonder how useful it'll be as CE.com only runs on ASP
			// just to make everything the same i guess
			if (licence.scripting.toLowerCase()=="php") {
				var decryptScriptPage:String = "/function/decryptFromFlash.php";
			} else {
				var decryptScriptPage:String = "/function/decryptFromFlash.asp";
			}
			sender.sendAndLoad(decryptScriptPage, loader, "POST");
		} else {
			// proceed anyway, let the login process capture wrong password
			myTrace("(loginClass) - no encryption is set by licence. proceed to login.");
			checkProductionServer();
		}
	}
	
	/* v0.15.1, DL: check production server see if server name matches */
	function checkProductionServer() : Void {
		// v6.4.3 Better checking		
		//if (licence.version>2 && licence.productionServer!=undefined) {
		//_global.myTrace("licence.control.server=" + licence.control.server);
		if (licence.version>2 && licence.control.server!=undefined) {
			if (licence.control.server.toLowerCase()==_global.NNW.paths.domain.toLowerCase()) {
				// v6.4.1.2, DL: test server connection only after checked the licence
				//startProgram();
				testServerConnection();
			} else {
				view.showPopup("productionServerNotMatch");
				myTrace("(loginClass) - host server does not match.");
			}
		} else {
			// v6.4.1.2, DL: test server connection only after checked the licence
			//startProgram();
			testServerConnection();
		}
	}
	
	// v6.4.1.2, DL: test server connection by scripting language specified in the licence
	// this function is moved from APControl.swf to here
	function testServerConnection() : Void {
		//_global.myTrace("login.testServer, __server=" + control.__server);
		if (control.__server) {
			var testConn = new XML();
			testConn.master = this;
			testConn.onLoad = function(success) : Void {
				if (success) {
					if (this.firstChild.nodeName=="sR" && this.firstChild.firstChild.attributes.conn=="ok") {
						this.master.myTrace("(loginClass) - Test connection to server: OK");
						this.master.startProgram();
					} else {
						this.master.onConnFail();
					}
				} else {
					this.master.onConnFail();
				}
			}
			testConn.load(control.paths.serverConnPath+"?prog=NNW");
			
		// no need to test server connection for network version
		} else {
			startProgram();
		}
	}
	
	private function onLoggedIn() : Void {
		control.onLoggedIn();
	}
	
	private function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
}