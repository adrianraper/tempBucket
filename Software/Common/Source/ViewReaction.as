_global.ORCHID.viewObj.userEvent = function(event) {
	myTrace("viewObj: userEvent - " + event);	
	switch(event) {
		case "onLoad":
			myTrace("viewReaction:passed user " + _global.ORCHID.commandLine.userName);
			this.clearScreen("RegisterScreen");
			// v6.4.2 action usually comes from command line or location. But it is possible that it comes from
			// the licence as well. In which case, that overrides all else.
			if (_global.ORCHID.root.licenceHolder.licenceNS.action != undefined) {
				myTrace("force action to be licence based: " + _global.ORCHID.root.licenceHolder.licenceNS.action);
				_global.ORCHID.commandLine.action =_global.ORCHID.root.licenceHolder.licenceNS.action
			}
			// v6.5.4.6 We also need to check that they are allowed to use special actions
			// These include autoRegister and validatedLogin
			var confirmSpecialAction = function (actionName) { 
				// Check whether we actually want this action
				if (_global.ORCHID.commandLine.action == actionName) {
					//myTrace("test for " + actionName + " against commandline=" + _global.ORCHID.commandLine.action + " against licence=" + _global.ORCHID.root.licenceHolder.licenceNS.allowedActions);
					// if we do, is it listed in the licence?
					if (_global.ORCHID.root.licenceHolder.licenceNS.allowedActions.indexOf(actionName)<0) {
						// if not, blank out the action
						_global.ORCHID.commandLine.action = undefined;
					}
				}
			}
			// V6.5.4.6 I think that 'directLink' is too powerful - but I don't know where it is used at present
			//confirmSpecialAction("directLink");
			confirmSpecialAction("validatedLogin"); 
			confirmSpecialAction("autoRegister");
			myTrace("commandLine.action=" + _global.ORCHID.commandLine.action);
			myTrace("licence.allowedActions=" + _global.ORCHID.root.licenceHolder.licenceNS.allowedActions);
			
			// if default username and default password exists in licence file, skip the login screen
			// default username and password in licence file include blank username or password
			// v6.3.6 There is no reason for password to be included if you are doing validatedLogin
			// v6.3.6 Rearrange according to the new order, scorm, then name from start, then from licence
			//if(_global.ORCHID.root.licenceHolder.licenceNS.defaultUserName != undefined && _global.ORCHID.root.licenceHolder.licenceNS.defaultPassword != undefined) {
			if (_global.ORCHID.commandLine.scorm) {
				// v6.5.6 But you may have an ID that would be better to use for the SCORM login
				myTrace("use scorm user " + _global.ORCHID.commandLine.userName + ", " + _global.ORCHID.commandLine.studentID);
				// v6.5.6 For those cases where a SCORM user is already in the database with a password, we don't want any kind of password matching.
				// It hasn't mattered before because users were always added by SCORM so had empty passwords. But HCT has RM users already set.
				//_global.ORCHID.user.startUser(_global.ORCHID.commandLine.userName, "", _global.ORCHID.commandLine.studentID);
				_global.ORCHID.user.startUser(_global.ORCHID.commandLine.userName, null, _global.ORCHID.commandLine.studentID); 
			//v6.5.4.7 Allow userID to be all you need to get in
			// v6.5.5.5 Also allow if allowedActions is set even if commandLine.action is not set (IYJ)
			// v6.5.5.5 Move this to be the first condition we check. 
			} else if (_global.ORCHID.commandLine.userID != undefined &&_global.ORCHID.commandLine.userID != "" &&_global.ORCHID.commandLine.userID > 0 
					&& ((_global.ORCHID.commandLine.action == "validatedLogin" ) || 
						(_global.ORCHID.root.licenceHolder.licenceNS.allowedActions.indexOf("validatedLogin")<0))) {
				myTrace("use passed userID with validatedLogin " + _global.ORCHID.commandLine.userID);
				// v6.5.5.5 Merge startUser and startUserID
				//_global.ORCHID.user.startUserID(_global.ORCHID.commandLine.userID, null);
				_global.ORCHID.user.startUser(null, null, null, _global.ORCHID.commandLine.userID);
			//v6.4.2 Shouldn't this use be protected in some way?
			//v6.4.3 Add directLink action as well (new or existing)
			} else if (_global.ORCHID.commandLine.userName != undefined &&_global.ORCHID.commandLine.userName != "" 
					&& (_global.ORCHID.commandLine.action == "validatedLogin" || 
						_global.ORCHID.commandLine.action == "autoRegister" ||
						_global.ORCHID.commandLine.action == "directLink")) {
				myTrace("use verified user " + _global.ORCHID.commandLine.userName);
				_global.ORCHID.user.startUser(_global.ORCHID.commandLine.userName, null, _global.ORCHID.commandLine.studentID);
			//v6.4.3 Add directLink for studentID
			} else if (_global.ORCHID.commandLine.studentID != undefined &&_global.ORCHID.commandLine.studentID != "" 
					&& (_global.ORCHID.commandLine.action == "validatedLogin" || 
						_global.ORCHID.commandLine.action == "autoRegister" ||
						_global.ORCHID.commandLine.action == "directLink")) {
				myTrace("use verified id " + _global.ORCHID.commandLine.studentID);
				_global.ORCHID.user.startUser(_global.ORCHID.commandLine.userName, null, _global.ORCHID.commandLine.studentID);
			//v6.3.6 Add anonymous entry
			//v6.4.2 Shouldn't this use be protected in some way? Add it to allowedActions in the licence?
			// but there are a lot of location files that already use it I think. Maybe base protection on licence version.
			} else if (_global.ORCHID.commandLine.action == "anonymous") {
				myTrace("use anonymous user, set userID=-1");
				// v6.6.0.2 Send anonymous users with userID = -1
				_global.ORCHID.user.startUser("", "", null, -1);
			// let a user be passed and register them
			} else if (_global.ORCHID.commandLine.userName != undefined && _global.ORCHID.commandLine.action == "newUser") {
				myTrace("add passed user " + _global.ORCHID.commandLine.userName);
				//var registerUser = {name:_global.ORCHID.commandLine.userName, password:_global.ORCHID.commandLine.password, eMail:"anonymous@clarity.com.hk"};
				var registerUser = {name:_global.ORCHID.commandLine.userName, password:_global.ORCHID.commandLine.password, registerMethod:_global.ORCHID.commandLine.action};
				// v6.5.3 We have to check licences first
				//_global.ORCHID.user.addNewUser(registerUser);
				_global.ORCHID.user.addNewUserCheck(registerUser);
			// v6.5.3 Preview doesn't need a password, but it should communicate via lc with authoring to confirm the exercise
			} else if (_global.ORCHID.commandLine.userName != undefined &&_global.ORCHID.commandLine.preview) {
				myTrace("use preview user " + _global.ORCHID.commandLine.userName);
				_global.ORCHID.user.startUser(_global.ORCHID.commandLine.userName, null);
			// v6.5.5.5 You have been passed some student information, but no special login (typically this is CE.com)
			// The first thing to check is userID
			} else if (_global.ORCHID.commandLine.userID != undefined &&_global.ORCHID.commandLine.userID != "" &&_global.ORCHID.commandLine.userID > 0) {
				myTrace("use passed userID " + _global.ORCHID.commandLine.userID);
				_global.ORCHID.user.startUser(null, _global.ORCHID.commandLine.password, null, _global.ORCHID.commandLine.userID);
			// if I have a username from start, then action=login is assumed if it was nothing more active
			//} else if (_global.ORCHID.commandLine.userName != undefined &&_global.ORCHID.commandLine.userName != "" && _global.ORCHID.commandLine.action == "login") {
			} else if (_global.ORCHID.commandLine.userName != undefined &&_global.ORCHID.commandLine.userName != "") {
				myTrace("use passed name " + _global.ORCHID.commandLine.userName);
				_global.ORCHID.user.startUser(_global.ORCHID.commandLine.userName, _global.ORCHID.commandLine.password, _global.ORCHID.commandLine.studentID);
			} else if (_global.ORCHID.commandLine.studentID != undefined &&_global.ORCHID.commandLine.studentID != "") {
				myTrace("use passed student ID " + _global.ORCHID.commandLine.userName);
				_global.ORCHID.user.startUser(_global.ORCHID.commandLine.userName, _global.ORCHID.commandLine.password, _global.ORCHID.commandLine.studentID);
			// v6.4.2.4 If the RM login options don't ask for anything - then skip the login
			} else if (_global.ORCHID.programSettings.loginOption==0) {
				myTrace("nothing is needed to login");
				_global.ORCHID.user.startUser("", "");
			// v6.3.6 Don't force the default password to contain anything as that will be sorted during login
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.defaultUserName != undefined) { // && _global.ORCHID.root.licenceHolder.licenceNS.defaultPassword != undefined) {
				myTrace("use default user " + _global.ORCHID.root.licenceHolder.licenceNS.defaultUserName);
				//myTrace("use password " + _global.ORCHID.root.licenceHolder.licenceNS.defaultPassword);
				// v6.3.5 Also allow user passed this way to be verified
				// v6.3.6 We should only allow validatedLogin with a licence that accepts it, or from a particular server
				// not yet implemented
				myTrace("with action=" + _global.ORCHID.commandLine.action);
				if (_global.ORCHID.commandLine.action == "validatedLogin") {
					_global.ORCHID.user.startUser(_global.ORCHID.root.licenceHolder.licenceNS.defaultUserName, null);
				} else {
					_global.ORCHID.user.startUser(_global.ORCHID.root.licenceHolder.licenceNS.defaultUserName, _global.ORCHID.root.licenceHolder.licenceNS.defaultPassword);
				}
			//v6.4.2.8 Light users
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("light") >= 0) {
				myTrace("light user, so anonymous");
				_global.ORCHID.user.startUser("", "");
			} else {
				//myTrace("displaying login screen");
				this.displayScreen("LoginScreen");
			}
			//this.displayScreen("LiteralScreen");
			break;
		case "onNoSuchUser":
		case "onNoSuchID":
			// v6.3.3 If this is a SCORM user, then automatically add this new user (password="")
			if (_global.ORCHID.commandLine.scorm) {
				//var registerUser = {name:_global.ORCHID.commandLine.userName, password:"", eMail:"scorm"};
				// v6.6.0.2 Only add them if the name is not empty
				if ( _global.ORCHID.commandLine.userName!='' && _global.ORCHID.commandLine.userName!=undefined) {
					myTrace("add new scorm user " + _global.ORCHID.commandLine.userName);
					var registerUser = {name:_global.ORCHID.commandLine.userName, password:"", registerMethod:"scorm"};
					// v6.5.6 We might know studentID too as this comes back from SCORM now
					if (_global.ORCHID.commandLine.studentID!=undefined && _global.ORCHID.commandLine.studentID!="") {
						myTrace("and user SCORM studentID " + _global.ORCHID.commandLine.studentID);
						registerUser.studentID = _global.ORCHID.commandLine.studentID;
					}
					// v6.5.3 We need to count licences before doing this
					//_global.ORCHID.user.addNewUser(registerUser);
					_global.ORCHID.user.addNewUserCheck(registerUser);
				} else {
					myTrace("new scorm user, but name is empty");
					_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("noSuchUser", "messages");
					this.displayScreen("LoginScreen");
				}
			// v6.4.3 Or - if you are coming from a non SCORM LMS / direct linking you might want to accept
			// any user, be they existing or new
			// v6.4.2.7 Check that you have a name before doing this
			// v6.4.2.8 But if it is just ID based, you don't care about name
			//} else if (_global.ORCHID.commandLine.action == "directLink" && 
			} else if (_global.ORCHID.commandLine.action == "directLink" || _global.ORCHID.commandLine.action == "autoRegister") {
				// v6.4.2.8 So copy the ID if the name is blank
				if (_global.ORCHID.commandLine.userName == "" || _global.ORCHID.commandLine.userName == undefined) {
					_global.ORCHID.commandLine.userName = _global.ORCHID.commandLine.studentID;
				} 
				// v6.5.4.6 You should check RM settings to see whether you need the ID or the name
				// v6.4.2.8 Then you can check again (because the ID might have been blank too)
				if (_global.ORCHID.commandLine.userName <> "" &&
					_global.ORCHID.commandLine.userName <> undefined) {
					myTrace("add new user through " +  _global.ORCHID.commandLine.action + " name=" + _global.ORCHID.commandLine.userName);
					//var registerUser = {name:_global.ORCHID.commandLine.userName, studentID:_global.ORCHID.commandLine.studentID, password:""};
					var registerUser = {name:_global.ORCHID.commandLine.userName, 
									studentID:_global.ORCHID.commandLine.studentID, 
									password:"",
									registerMethod:_global.ORCHID.commandLine.action};
					// v6.5.3 We need to count licences before doing this
					//_global.ORCHID.user.addNewUser(registerUser);
					_global.ORCHID.user.addNewUserCheck(registerUser);
				} else {
					// v6.5.4.6 So what to do if no name or password? Display login I think. 
					// It would be best to go to whole next section to get some messages, but display the screen is OK too
					_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("noSuchUser", "messages");
					this.displayScreen("LoginScreen");
				}
			// no special case so...
			} else {
				// v6.3.3 If you were just trying to skip the login, you will need to now display the screen
				// since this user doesn't exist
				if (_global.ORCHID.commandLine.userName != undefined) {
					this.displayScreen("LoginScreen");
					// v6.3.5 Since you are [back] on the screen, hide the progress bar
					// especially as some layouts have it over the status text
					var myController = _global.ORCHID.root.tlcController;
					myController.setEnabled(false);
				}				
				if (_global.ORCHID.programSettings.selfRegister > 0) {
					//_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "noSuchUserTryNew";
					// v6.4.2.4 In the case that self-reg + no password + allow anon, we are going to try have a different message
					if ((_global.ORCHID.programSettings.loginOption & _global.ORCHID.accessControl.ACAllowAnonymous) && !_global.ORCHID.programSettings.verified) {
						_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("confirmNewUser", "messages");
					} else {
						if (event == "onNoSuchID") {
							_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("noSuchIDTryNew", "messages");
						} else {
							_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("noSuchUserTryNew", "messages");
						}
					}
				} else {
					//_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "noSuchUser";
					if (event == "onNoSuchID") {
						_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("noSuchID", "messages");
					} else {
						_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("noSuchUser", "messages");
					}
				}
				Selection.setFocus(_global.ORCHID.root.buttonsHolder.LoginScreen.loginBox.i_name);
				// v6.3 If you come back to this screen, re-enable the buttons
				_global.ORCHID.root.buttonsHolder.LoginScreen.loginBtn.setEnabled(true);
				// v6.3.2 except that new user might not have been enabled in the first place!
				// So you should really redo the screen.display, but for now I will duplicate
				// the code as it is simple
				if (_global.ORCHID.programSettings.selfRegister > 0) {
					myTrace("the new user button is ok");
					_global.ORCHID.root.buttonsHolder.LoginScreen.newUserBtn.setEnabled(true);
				}
				// v6.3.5 Since you are [back] on the screen, hide the progress bar
				// especially as some layouts have it over the status text
				var myController = _global.ORCHID.root.tlcController;
				myController.setEnabled(false);
			}
			// v6.5.4.6 Can I just move this outside the conditional? Or will it screw up the progress bar for the startuser type actions? Probably,
			// v6.3.5 Since you are [back] on the screen, hide the progress bar
			// especially as some layouts have it over the status text
			//var myController = _global.ORCHID.root.tlcController;
			//myController.setEnabled(false);
			break;
		// v6.5.6 Multiple users might be found from some kind of passed data. I would guess this is usually terminal, but this is an option.
		// OrchidObjects should catch terminal cases.
		case "onMultipleUsers":
			this.displayScreen("LoginScreen");
			_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "multipleUsers";
			_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("multipleUsers", "messages");
			_global.ORCHID.root.buttonsHolder.LoginScreen.i_password.text = "";
			_global.ORCHID.root.buttonsHolder.LoginScreen.loginBtn.setEnabled(true);
			var myController = _global.ORCHID.root.tlcController;
			myController.setEnabled(false);
			break;
		// v6.5.4.3 Yiu, user expired event
		case "onUserExpired":
			this.displayScreen("LoginScreen");
			_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "userExpired";
			_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("userExpired", "messages");
			_global.ORCHID.root.buttonsHolder.LoginScreen.i_password.text = "";
			_global.ORCHID.root.buttonsHolder.LoginScreen.loginBtn.setEnabled(true);
			//Selection.setFocus(_global.ORCHID.root.buttonsHolder.LoginScreen.i_password);
			var myController = _global.ORCHID.root.tlcController;
			myController.setEnabled(false);
			break;
		// End v6.5.4.3 Yiu, user expired event

		// v6.5.4.3 Yiu, event of user failed the check of licence allocation
		case "onLicenceAllocationFailed":
		case "onLicenceFull":
			// v6.3.3 If you were trying to skip the login, you will need to now display it the screen
			// v6.4.3 But you might be trying to skip by anonymous as well, so display screen if not displayed
			if (_global.ORCHID.root.buttonsHolder.LoginScreen._visible == false) {				
				this.displayScreen("LoginScreen");
			}
			if (event=="onLicenceAllocationFailed") {
				_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "licenceAllocationFailed";
			} else {
				_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "licenceFull";
			}
			_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus, "messages");
			_global.ORCHID.root.buttonsHolder.LoginScreen.i_password.text = "";
			_global.ORCHID.root.buttonsHolder.LoginScreen.loginBtn.setEnabled(true);
			//Selection.setFocus(_global.ORCHID.root.buttonsHolder.LoginScreen.i_password);
			var myController = _global.ORCHID.root.tlcController;
			myController.setEnabled(false);
			break;
		// End v6.5.4.3 Yiu, event of user failed the check of licence allocation
		case "onWrongPassword":
			// v6.3.3 If you were trying to skip the login, you will need to now display it the screen
			if (_global.ORCHID.commandLine.userName != undefined) {
				myTrace("displaying login screen as you need it");
				this.displayScreen("LoginScreen");
			}				
			_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "wrongPassword";
			// v6.3 It is possible that the password box is not shown (RM says no need for verification), but that
			// the user does have a password set (in which case the call will fail). In this case, override RM and
			// now show the password input box so they can type it. This works for Teacher login if no general verification.
			if (_global.ORCHID.programSettings.verified) {
				_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("wrongPassword", "messages");
			} else {
				// v6.4.2.4 I'm not so sure this is a good idea anymore. It really should be governed by RM settings.
				// Set in OrchidObjects startUser, so will probably not come here with verified=false anymore
				_global.ORCHID.programSettings.verified = true;
				myTrace("ahh, need a password for this user");
				this.displayScreen("LoginScreen");
				_global.ORCHID.root.buttonsHolder.LoginScreen.i_username.text = _global.ORCHID.user.userName;
				_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("typePassword", "messages");
			}
			_global.ORCHID.root.buttonsHolder.LoginScreen.i_password.text = "";
			Selection.setFocus(_global.ORCHID.root.buttonsHolder.LoginScreen.i_password);
			// v6.3 If you come back to this screen, re-enable the buttons
			// v6.3.4 (only if they were enabled though!)
			_global.ORCHID.root.buttonsHolder.LoginScreen.loginBtn.setEnabled(true);
			if (_global.ORCHID.programSettings.selfRegister>0) {
				_global.ORCHID.root.buttonsHolder.LoginScreen.newUserBtn.setEnabled(true);
			}
			// v6.3.5 Since you are [back] on the screen, hide the progress bar
			// especially as some layouts have it over the status text
			var myController = _global.ORCHID.root.tlcController;
			myController.setEnabled(false); 
			break;
		case "onNoLicences":
			// v6.3.3 If you were trying to skip the login, you will need to now display it the screen
			// v6.4.3 But you might be trying to skip by anonymous as well, so display screen if not displayed
			// Or would it be better just to show the error msg box as you do with a corrupt licence file?
			//myTrace("name=" + _global.ORCHID.commandLine.userName);
			//if (_global.ORCHID.commandLine.userName != undefined) {
			if (_global.ORCHID.root.buttonsHolder.LoginScreen._visible == false) {				
				this.displayScreen("LoginScreen");
			}
			
			_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "noLicences";
			_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("noLicences", "messages");
			_global.ORCHID.root.buttonsHolder.RegisterScreen.messageStatus = "noLicences";
			_global.ORCHID.root.buttonsHolder.RegisterScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("noLicences", "messages");
			// Add in a call to record this failure to secure a licence
			// Hasn't this already been done?
			//_global.ORCHID.user.failLicenceSlot();
			// v6.3 If you come back to this screen, re-enable the buttons
			// v6.3.4 (only if they were enabled though!)
			_global.ORCHID.root.buttonsHolder.LoginScreen.loginBtn.setEnabled(true);
			if (_global.ORCHID.programSettings.selfRegister>0) {
				_global.ORCHID.root.buttonsHolder.LoginScreen.newUserBtn.setEnabled(true);
			}
			// v6.3.5 Since you are [back] on the screen, hide the progress bar
			// especially as some layouts have it over the status text
			var myController = _global.ORCHID.root.tlcController;
			myController.setEnabled(false);
			break;
		// v6.3.2 Also stop users being added for total licencing
		case "onNoTotalLicences":
			// v6.3.3 If you were trying to skip the login, you will need to now display it the screen
			if (_global.ORCHID.commandLine.userName != undefined) {
				this.displayScreen("LoginScreen");
			}				
			_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = "noTotalLicences";
			_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus, "messages");
			_global.ORCHID.root.buttonsHolder.RegisterScreen.messageStatus = "noTotalLicences";
			_global.ORCHID.root.buttonsHolder.RegisterScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus, "messages");
			// v6.3 If you come back to this screen, re-enable the buttons
			// v6.3.4 (only if they were enabled though!)
			// v6.5.5.0 Make sure the register screen is hidden in case you were on that
			if (_global.ORCHID.root.buttonsHolder.LoginScreen._visible == false) {				
				this.displayScreen("LoginScreen");
			}
			_global.ORCHID.root.buttonsHolder.LoginScreen.loginBtn.setEnabled(true);
			if (_global.ORCHID.programSettings.selfRegister>0) {
				_global.ORCHID.root.buttonsHolder.LoginScreen.newUserBtn.setEnabled(true);
			}
			// v6.3.5 Since you are [back] on the screen, hide the progress bar
			// especially as some layouts have it over the status text
			var myController = _global.ORCHID.root.tlcController;
			myController.setEnabled(false);
			break;
		case "onUserStart":
			// v6.5.4.6 Add another stage which lets the user change the pasword
			if (_global.ORCHID.programSettings.requestPasswordChange) {
				myTrace("pause onUserStart to do password change");
				_global.ORCHID.viewObj.clearScreen("LoginScreen");
				this.displayScreen("PasswordScreen");
				// v6.3.5 Since you are [back] on the screen, hide the progress bar
				// especially as some layouts have it over the status text
				var myController = _global.ORCHID.root.tlcController;
				myController.setEnabled(false);
			} else {
				// v6.5.4.5 Before we finish loading the user, we need to get courseHiddenContent - then we can broadcast this.
				myTrace("onUserStart = but lets get hiddenContent first");
				_global.ORCHID.user.getCourseEditedContent();
				_global.ORCHID.user.getCourseHiddenContent();
			}
			break;
		case "onPasswordChangeFailed":
			// v6.5.4.6 If the change fails, leave them trying again.
			myTrace("onPasswordChangeFailed");
			_global.ORCHID.root.buttonsHolder.PasswordScreen.messageStatus = "passwordChangeFailed";
			_global.ORCHID.root.buttonsHolder.PasswordScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("passwordChangeFailed", "messages");
			break;
		case "onPasswordChanged":
			// v6.5.4.5 Before we finish loading the user, we need to get courseHiddenContent - then we can broadcast this.
			myTrace("onPasswordChanged so lets get hiddenContent.");
			_global.ORCHID.user.getCourseHiddenContent();
			break;
		case "onHiddenContentLoaded":
			myTrace("back to old user start");
			// ok, so the user is added, now what?
			//6.0.4.0, use view obj to control screen display
			_global.ORCHID.viewObj.clearScreen("LoginScreen");
			_global.ORCHID.viewObj.clearScreen("PasswordScreen");
			_global.ORCHID.viewObj.clearScreen("RegisterScreen");
			// 6.0.5.0 now that the user is logged in, set up the licence holding function
			// v6.3.6 Merge login into main
			_global.ORCHID.root.mainHolder.loginNS.holdLicenceIntID = setInterval(_global.ORCHID.root.mainHolder.loginNS, "holdLicence", _global.ORCHID.root.mainHolder.loginNS.licenceHoldTime);
			myTrace("create licence interval for ID=" + _global.ORCHID.root.mainHolder.loginNS.holdLicenceIntID);
			// v6.3 And if this is a teacher login, get all the users for later reporting use
			// But LSO based licences have no network function so ignore. 
			//myTrace("branding=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
			//myTrace("running with db/scripting=" + _global.ORCHID.root.licenceHolder.licenceNS.db + "/" + _global.ORCHID.root.licenceHolder.licenceNS.scripting);
			//v6.3.6 Need to look at userType to see if this is a teacher now
			//if (_global.ORCHID.user.userID == 1 && _global.ORCHID.root.licenceHolder.licenceNS.db != "LSO") {
			// v6.5.4.5 We no longer want to treat teacher's differently. For instance, there is no progress for all their students.
			//if (_global.ORCHID.user.userType > 0 && _global.ORCHID.root.licenceHolder.licenceNS.db != "LSO") {
			//	// Make a special setting.
			//	_global.ORCHID.user.teacher = true;
			//	myTrace("teacher login so first get all users");
			//	_global.ORCHID.user.getAllUsers();
			//	// when the above call finishes it will trigger the below call to keep going
			//} else {
				// then callback to the place where the user object was first created
				// to say that the user is now loaded
				_global.ORCHID.user.onLoad();
			//}
			break;
		case "onUserAlreadyExists":
			// v6.3.3 If you were trying to skip the login, you will need to now display it the screen
			if (_global.ORCHID.commandLine.userName != undefined && _global.ORCHID.commandLine.userName!="") {
				myTrace("onUserAlreadyExists, username=" + _global.ORCHID.commandLine.userName);
				//v6.3.6 But surely I am on the registration screen at this point.
				//this.displayScreen("LoginScreen");
				//v6.3.6 And therefore clear the registration screen. But it is not clear
				// that I am just on the registration screen. Is it?
				this.displayScreen("RegisterScreen");
			}		
			// v6.4.2 It would be nice to check if id is being typed so can you explain about that as well
			if (_global.ORCHID.root.buttonsHolder.RegisterScreen.i_studentID._visible) {
				var thisMsg = "userOrIDExists";
			} else {
				var thisMsg = "userExists";
			}
			_global.ORCHID.root.buttonsHolder.LoginScreen.messageStatus = thisMsg;
			_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(thisMsg, "messages");
			_global.ORCHID.root.buttonsHolder.RegisterScreen.messageStatus = thisMsg;
			_global.ORCHID.root.buttonsHolder.RegisterScreen.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(thisMsg, "messages");
			// v6.3 If you come back to this screen, re-enable the buttons
			_global.ORCHID.root.buttonsHolder.RegisterScreen.loginBtn.setEnabled(true);
			// v6.4 Something like EGU never goes to registration screen, so stay here, but with buttons back again
			_global.ORCHID.root.buttonsHolder.LoginScreen.loginBtn.setEnabled(true);
			_global.ORCHID.root.buttonsHolder.LoginScreen.newUserBtn.setEnabled(true);
			// v6.3.5 Since you are [back] on the screen, hide the progress bar
			// especially as some layouts have it over the status text
			var myController = _global.ORCHID.root.tlcController;
			myController.setEnabled(false);
			break;
		case "onLoadScratchPad":
			_global.ORCHID.viewObj.displayScratchPad();
			break;
	}
}

_global.ORCHID.viewObj.literalEvent = function(event, success) {
	//myTrace("viewObj: literalEvent - " + event);
	switch(event) {
		case "onLiteralLoad":
			if(success) {
				myTrace("load literal data successful");
				//v6.3.6 Do this just once, not every time you want a new cb
				_global.ORCHID.literalModelObj.langList = _global.ORCHID.literalModelObj.getLiteralLanguageList();
				// v6.3.5 new language init
				if (_global.ORCHID.literalModelObj.currentLiteralIdx <= 0) {
					_global.ORCHID.literalModelObj.currentLiteralIdx = 0;
				}
				
				var colourObj = new Object();
				colourObj.Colour = 0xFFCC00;
				colourObj.ROColour = 0x99CC00;
				colourObj.MDColour = 0x669933;
				colourObj.TextColour = 0x000066;
				colourObj.ShadowColour = 0xFFFF99;
				this.setButtonColour(colourObj);
				this.initAllScreens();
				this.setLiterals();
				myTrace("loaded literals");
				// v6.3.5 Since you now want the literal selector on most screens
				// it would be better to do this in screen.as I would think 
				/*
				var literalList = _global.ORCHID.literalModelObj.getLiteralLanguageList();
				if (literalList.length > 1) {
					// v6.3.4 I would like to be able to preset the language from SCORM as well
					for (var i = 0; i < literalList.length; i++) {
						_global.ORCHID.root.buttonsHolder.LoginScreen.literal_cb.addItem(_global.ORCHID.literalModelObj.getLiteral("languageName", "labels", literalList[i]), literalList[i]);
					}
				} else {
					// hide the language selector if there is only one option
					_global.ORCHID.root.buttonsHolder.LoginScreen.literal_cb.setEnabled(false);
				}
				*/
			} else {
				myTrace("load literal data failed");
			}
			break;
		case "onLanguageChanged":
			myTrace("change language so call setLiterals again");
			this.setLiterals();
			// v 6.3.3 move exericse panels to buttons holder
			//if(_global.ORCHID.root.exerciseHolder.navMsgBox != undefined) {
			if(_global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox != undefined) {
				_global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox.removeMovieClip();
			}
			if(_global.ORCHID.root.buttonsHolder.MessageScreen.Hint_SP != undefined) {
				_global.ORCHID.root.buttonsHolder.MessageScreen.Hint_SP.removeMovieClip();
			}
			// v6.3.3 move progress screen to buttons holder
			//v6.3.6 Progress screen is no longer used - all done on messageScreen
			//if(_global.ORCHID.root.buttonsHolder.progressScreen.progress_SP != undefined) {
			//	_global.ORCHID.root.buttonsHolder.progressScreen.progress_SP.removeMovieClip();
			//}
			// v6.3.4 move progress screen to buttons holder
			if(_global.ORCHID.root.buttonsHolder.MessageScreen.score_SP != undefined) {
				_global.ORCHID.root.buttonsHolder.MessageScreen.score_SP.removeMovieClip();
			}
			// v6.3.4 move progress screen to buttons holder
			if(_global.ORCHID.root.buttonsHolder.MessageScreen.scratchPad_SP != undefined) {
				_global.ORCHID.root.buttonsHolder.MessageScreen.scratchPad_SP.removeMovieClip();
			}
			break;
	}
}
