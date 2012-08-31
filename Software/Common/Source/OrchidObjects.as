// SCITE randomly adds the following corrupt characters ﻿ which you have to remove in a Hex Editor
// *****
// Program settings object
// *****
// v6.4.2.9 By Yiu on 13-12-07 Included md5.as for password encryption
#include "md5.as"
// will load from a [file] and trigger a callback once loaded
// 6.0.5.0 now reads from database (and perhaps later it can also get a user's personal preferences
// from somewhere)
ProgramSettingsObject = function() {
//	this.fileName = fileName;
	// v6.5.4.5 Some default settings
	this.databaseVersion=1;
	
	// v6.5.4.6 Default for password change (can be altered by button on login screen)
	this.requestPasswordChange = false;
}
ProgramSettingsObject.prototype.load = function() {

	// v6.5.4.6 Group doesn't always equal root for new users anymore, but it is still the default
	// v6.5.6 Though we might set a different default group for SCORM users - NAS wants this
	// perhaps it will come from licence settings in the account? Yes.
	this.defaultGroupID=_global.ORCHID.root.licenceHolder.licenceNS.central.root;
	
	// 6.0.5.0 the settings are now taken from the db (assumed under RM control)
	// make a new db query
	// v6.3.6 Merge database to main
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	
	// put the query into an XML object
	//myTrace("use root=" + _global.ORCHID.root.licenceHolder.licenceNS.central.root);
	// v6.3.5 Piggyback the encryption key request to this query
	//myTrace("use eKey=" + _global.ORCHID.commandLine.encryptKey);
	// v6.4.3 We will convert eKey to a long integer, so make sure it is valid since we don't check it anywhere
	if (isNaN(Number(_global.ORCHID.commandLine.encryptKey))) {
		_global.ORCHID.commandLine.encryptKey = 0;
	}

	// v6.5.4.3 Yiu, added product code and today into the query string for checking account expiry
	// v6.5.4.5 AR don't need expiry date passed in
	var dateToday:Date;
	var strTodayInDateFormat:String;
	var nProductCode:Number;
	//var nStudentExpiryDateFromLicenceIni:String
	dateToday = new Date();
	strTodayInDateFormat = dateFormat(dateToday);
	nProductCode = _global.ORCHID.root.licenceHolder.licenceNS.productCode;
	//nStudentExpiryDateFromLicenceIni	= _global.ORCHID.root.licenceHolder.licenceNS.expiry

	// v6.5.5.1 If you haven't read the licence you don't know the root - this might have been passed to you, or the prefix will have been
	thisDB.queryString = '<query method="getRMSettings" ' + 
					'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
					'prefix="' + _global.ORCHID.commandLine.prefix + '" ' +
					'eKey="' + _global.ORCHID.commandLine.encryptKey + '" ' +
					'dateStamp="' + strTodayInDateFormat + '" ' + 
					'productCode="' + nProductCode + '" ' + 
					//'studentExpiryDateFromLicenceIni="' + nStudentExpiryDateFromLicenceIni + '" ' + 
					'cacheVersion="' + new Date().getTime() + '"/>';
/*
					'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
					'eKey="' + _global.ORCHID.commandLine.encryptKey + '" ' +
					'cacheVersion="' + new Date().getTime() + '"/>';
 */
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		myTrace("back to getRMSettings from db with " + this.toString());
		//var callBackModule = _global.ORCHID.root.loginHolder.loginNS;
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone

		// v6.5.5.1 For measuring performance
		_global.ORCHID.timeHolder.firstQueryComplete = new Date().getTime();
		//myTrace("timer:firstQueryComplete=" + _global.ORCHID.timeHolder.firstQueryComplete);
		
		// v6.5.4.3 Yiu, expire check, if the account expired?
		// v6.5.4.5 If there is an expiry date in the accounts table, it is used
		var bErrorReceived:Boolean;
		bErrorReceived = false;
		var dbAccountsUsed:Boolean
		dbAccountsUsed = false;

		//myTrace("return node=" + this.toString());
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				// v6.5.4.3 Yiu, will have if there is no error, account expiry
				if (tN.attributes.code == "207") {
					//_global.ORCHID.user.storeErrorToDB(tN.attributes.code, undefined);
					_global.ORCHID.storeErrorToDB(tN.attributes.code, undefined);
					bErrorReceived = true;
					errObj = {literal:"AccountExpired", detail:"Sorry, your account has expired. Please contact your administrator for more information."};
					_global.ORCHID.root.controlNS.sendError(errObj);
				// v6.5.5.2 Accounts have start dates too
				} else if (tN.attributes.code == "212") {
					_global.ORCHID.storeErrorToDB(tN.attributes.code, undefined);
					bErrorReceived = true;
					errObj = {literal:"AccountNotStarted", detail:"Sorry, your account has not started yet. Please contact your administrator for more information."};
					_global.ORCHID.root.controlNS.sendError(errObj);
				// v6.5.5.2 Stop if the terms and conditions is still being displayed
				} else if (tN.attributes.code == "213") {
					_global.ORCHID.storeErrorToDB(tN.attributes.code, undefined);
					bErrorReceived = true;
					errObj = {literal:"TermsConditions", detail:"Sorry, your account has not been activated yet. Please contact your administrator for more information."};
					_global.ORCHID.root.controlNS.sendError(errObj);
				// v6.5.5.5 Stop if the licence is corrupt as reported by php
				} else if (tN.attributes.code == "214") {
					_global.ORCHID.storeErrorToDB(tN.attributes.code, undefined);
					bErrorReceived = true;
					errObj = { literal:"licenceAltered" };
					// Save the institution name so you can display it on screen
					_global.ORCHID.root.licenceHolder.licenceNS.institution = tN.attributes.institution;
					_global.ORCHID.root.controlNS.sendError(errObj);
				// v6.5.5.6 Stop if the account has been suspended for non-payment
				} else if (tN.attributes.code == "215") {
					//myTrace("accountSuspendedNonPayment error");
					_global.ORCHID.storeErrorToDB(tN.attributes.code, undefined);
					bErrorReceived = true;
					errObj = { literal:"accountSuspendedNonPayment" };
					var resellerName = tN.attributes.reseller;
					myTrace("reseller=" + resellerName);
					errObj.detail = "Sorry, this account has been suspended for non-payment.";
					if (resellerName!=undefined && resellerName!="") {
						errObj.detail += " Please contact " + resellerName + " to clarify the situation.";
					}
					// Save the institution name so you can display it on screen
					_global.ORCHID.root.licenceHolder.licenceNS.institution = tN.attributes.institution;
					_global.ORCHID.root.controlNS.sendError(errObj);
				} else {
					// V6.5.5.5 Can I write the failure to the database (or filesystem) to help with debugging?
					_global.ORCHID.root.mainHolder.logNS.sendLog(_global.ORCHID.commandLine.toString(), 601);
					myTrace("writing error for: " + _global.ORCHID.commandLine.toString());
					bErrorReceived = true;
					errObj = {literal:"NoAccount", detail:"Sorry, we can't find your account. Please check the web address you typed carefully, or contact us at support@clarityenglish.com."};
					_global.ORCHID.root.controlNS.sendError(errObj);
				}
				// End v6.5.4.3 Yiu, will have if there is no error, account expiry
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
			// we are expecting to get back a settings node
			} else if (tN.nodeName == "settings") {
				// parse the returned XML to get user details
				this.master.loginOption = tN.attributes.loginOption;
				this.master.verified = Boolean(Number(tN.attributes.verified));
				this.master.selfRegister = tN.attributes.selfRegister;
				myTrace("RM settings: login=" + this.master.loginOption + " verified=" + this.master.verified + " selfReg=" + this.master.selfRegister);
				
			// v6.3.5 And also a decrypt node
			} else if (tN.nodeName == "decrypt") {
				// parse the returned XML to get decryption details
				if (tN.attributes.key == "undefined") {
					_global.ORCHID.root.licenceHolder.licenceNS.control.decryptKey = undefined;
				} else {
					_global.ORCHID.root.licenceHolder.licenceNS.control.decryptKey = tN.attributes.key;
				}
				//myTrace("decrypt settings: key=" + _global.ORCHID.root.licenceHolder.licenceNS.control.decryptKey);
				
			// v6.5.4.5 And now an accounts node - which contains all licence information too
			} else if (tN.nodeName == "account") {
				dbAccountsUsed = true;
				
				// This will overwrite any information that comes from the licence
				// v6.5.5.1 Most important is to pick up the root if we didn't already know it
				if (_global.ORCHID.root.licenceHolder.licenceNS.central.root==undefined) {
					myTrace("we don't know the root, so read it as " + tN.attributes.rootID);
					_global.ORCHID.root.licenceHolder.licenceNS.central.root = tN.attributes.rootID;
				}
				
				// get default from the licence
				_global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate = _global.ORCHID.root.licenceHolder.licenceNS.registrationDate;

				// v6.5.5.1 Do we know who owns the licence?
				if (_global.ORCHID.root.licenceHolder.licenceNS.institution==undefined) {
					_global.ORCHID.root.licenceHolder.licenceNS.institution = tN.attributes.institution;
				}
				// parse the returned XML to get account details
				this.master.expiryDate = tN.attributes.expiryDate;
				this.master.maxStudents = Number(tN.attributes.maxStudents);
				//this.master.registrationDate = Number(tN.attributes.licenceStartDate);
				// v6.5.5.0 Also - what to do if other things in the database are different from the file? Such as licenceType
				// The database should always be considered to be correct - but this does raise issues for self-hosting.
				
				// what to do if this number is not the same as the licence file? I think we should use the one from the database.
				if (this.master.maxStudents>0 && this.master.maxStudents != _global.ORCHID.root.licenceHolder.licenceNS.licences) {
					myTrace("overwriting ("+ _global.ORCHID.root.licenceHolder.licenceNS.licences + ") licences from licence file with (" + this.master.maxStudents + ") from the T_Accounts table");
					_global.ORCHID.root.licenceHolder.licenceNS.licences = this.master.maxStudents;
				}
				// v6.5.5.2 And what type of licence is it? Would be ideal if we joined on T_LicenceType to get boolean for 'concurrent'
				// v6.5.5.5 Tidy up. Old licences had the string, but in the database we have the number. So switch all testing to the number.
				// 1=LT, 2=AA, 3=network, 4=single, 5=individual
				//switch (Number(tN.attributes.licencing)) {
				//	case 2:
				//	case 4:
				//		var licenceType = "concurrent";
				//		break;
				//	default:
				//		var licenceType = "tracking";
				//}
				// v6.5.5.5 For security
				// v6.5.5.5 Change the name
				//_global.ORCHID.root.licenceHolder.licenceNS.licenceType = tN.attributes.licencing; // this is the number type
				_global.ORCHID.root.licenceHolder.licenceNS.licenceType = tN.attributes.licenceType;
				_global.ORCHID.root.licenceHolder.licenceNS.checksum = tN.attributes.checksum;
				//if (_global.ORCHID.root.licenceHolder.licenceNS.licencing!=licenceType) {
				if (_global.ORCHID.root.licenceHolder.licenceNS.licencing) {
					myTrace("overwriting ("+ _global.ORCHID.root.licenceHolder.licenceNS.licencing + ") licence type from licence file with (" + licenceType + ") from the T_Accounts table");
					//_global.ORCHID.root.licenceHolder.licenceNS.licencing = licenceType;
				}
				// v6.5.5.2 And if it is an AA licence, lets go all anonymous. You can override this with a specific action in the licence if you need.
				// (Assuming that the licence node comes back after the account node!)
				myTrace("licence action is set to " + _global.ORCHID.root.licenceHolder.licenceNS.action + ", licencing is " + tN.attributes.licencing);
				//if (tN.attributes.licencing==2 && _global.ORCHID.root.licenceHolder.licenceNS.action==undefined) {
				if (tN.attributes.licenceType==2 && _global.ORCHID.root.licenceHolder.licenceNS.action==undefined) {
					myTrace("setting action to anonymous");
					_global.ORCHID.root.licenceHolder.licenceNS.action = "anonymous";
				}
				
				// v6.5.4.6 And a licence start date - for non-transferable licences
				// v6.5.4.7 You need to change this round. Even if you do have a licenceStartDate set, a perpetual licence always uses a rolling year for counting purposes.
				//if (tN.attributes.licenceStartDate==undefined || tN.attributes.licenceStartDate==null || tN.attributes.licenceStartDate=="") {
				myTrace("account, expiryDate=" + this.master.expiryDate + " licenceStartDate=" + tN.attributes.licenceStartDate);
				// If the expiry date is perpetual (2049), set start date to a year ago today
				// Licence clearance date processing should avoid this calculations - but no need to take anything out here
				var aYearAgo = new Date();
				aYearAgo.setUTCFullYear(aYearAgo.getUTCFullYear() -1);
				if (this.master.expiryDate>='2030') {
					_global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate = dateFormat(aYearAgo);
				} else {
					if (tN.attributes.licenceStartDate==undefined || tN.attributes.licenceStartDate==null || tN.attributes.licenceStartDate=="") {
						// otherwise it just means that the licence start date is not set for some reason
						// so save it as today as this will have least impact
						// v6.5.5.0 Surely we should set it as 1 year ago as above!
						//_global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate = dateFormat(new Date());
						_global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate = dateFormat(aYearAgo);
					} else {
						_global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate = tN.attributes.licenceStartDate;
					}
				}
				myTrace("account, licenceStartDate=" + _global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate);
				myTrace("licence.branding=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
				
				// v6.5.4.6 And a default group to add new students to
				if (tN.attributes.groupID.length>0) {
					this.master.defaultGroupID = tN.attributes.groupID;
				}
				
				// None of these are used yet, and may conflict with the info from location that we already have
				// v6.5.5.6 We do now want to get contentLocation and languageCode from the database.
				// languageCode is the KEY field, his will be something like EN, NAMEN, INDEN, or can be used for version types like 'original', 'rerecorded'
				// But dbProgress will have picked up the paths for us so we don't really need the languageCode at all at the moment.
				this.master.languageCode = tN.attributes.languageCode;
				// Or maybe I could use it for literals if I haven't specifically set them in location or commandLine
				if (_global.ORCHID.commandLine.language == undefined) {
					_global.ORCHID.commandLine.language = this.master.languageCode;
					// v6.5.5.6 This will be a bit ridiculous is the languageCode is 'rerecorded' but it won't matter as it won't be found in the literals
					// And maybe you need to remove the language selector if it was earlier enabled.
					myTrace("hiding the language selector");
					_global.ORCHID.root.buttonsHolder.LoginScreen.literal_cb.setEnabled(false);
					// and reset the save languages
					_global.ORCHID.literalModelObj.langList = _global.ORCHID.literalModelObj.getLiteralLanguageList();
					_global.ORCHID.literalModelObj.setLiteralLanguage(_global.ORCHID.commandLine.language);
				}
				
				// If the accounts table has F_ContentLocation filled in, it overrides the default
				if (tN.attributes.contentLocation!=undefined && tN.attributes.contentLocation!="") {
					myTrace("got contentLocation from account of " + tN.attributes.contentLocation);
					
					// Build the content path by putting this on the end.
					// Whilst we can assume that the content path that came from commandLine or location has been adapted to NOT include the title
					// it would be nice to try and cope if it accidentally still did. Except that this could be dangerous long term.
					// One option is to use &contentRoot=../Content for new location files. Then if you find an old one you won't touch it.
					// I think I'd prefer to find all location files and update them.
					//if (_global.ORCHID.paths.content.toLowerCase().indexOf("tensebuster"))
					_global.ORCHID.paths.content+=_global.ORCHID.functions.addSlash(tN.attributes.contentLocation);
				} else {
					myTrace("no contentLocation from db (" + tN.attributes.contentLocation + ") - bad");
				}
				myTrace("so paths.content=" + _global.ORCHID.paths.content);
				// v6.5.5.6 Default sharedMedia and streamingMedia to this content root (with respective subFolder). If I have already read from location, I'll just keep that
				// v6.5.6.5 It is necessary to do the same thing with streamingMedia (and I suppose shared) that we do for content regarding language versions
				// Can you think of a good way to work out if the streamingMedia path in the configuration file is a root or a full path?
				// How about using a placeholder?
				// streamingMedia=rtmp://streaming.clarityenglish.com:1935/cfx/st/[version]/streamingMedia
				if (_global.ORCHID.commandLine.sharedMedia == undefined) {
					_global.ORCHID.paths.sharedMedia = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.content) + _global.ORCHID.functions.addSlash("sharedMedia");
					myTrace("default paths.sharedMedia =" + _global.ORCHID.paths.sharedMedia);
				// Replace the place holder with the language version content path
				} else if (_global.ORCHID.commandLine.sharedMedia.indexOf("[version]")>0) {
					_global.ORCHID.commandLine.sharedMedia=findReplace(_global.ORCHID.commandLine.sharedMedia,"[version]",tN.attributes.contentLocation);
				}
				if (_global.ORCHID.commandLine.streamingMedia == undefined) {
					_global.ORCHID.paths.streamingMedia=_global.ORCHID.functions.addSlash(_global.ORCHID.paths.content) + _global.ORCHID.functions.addSlash("streamingMedia");
					myTrace("default paths.streamingMedia =" + _global.ORCHID.paths.streamingMedia);
				// Replace the place holder with the language version content path
				} else if (_global.ORCHID.commandLine.streamingMedia.indexOf("[version]")>0) {
					_global.ORCHID.paths.streamingMedia=findReplace(_global.ORCHID.commandLine.streamingMedia,"[version]",tN.attributes.contentLocation);
				}
				myTrace("end up with streamingMedia=" + _global.ORCHID.paths.streamingMedia);
				// I'm still not going to touch the MGS root - hoping to drop it altogether
				this.master.MGSRoot = tN.attributes.MGSRoot;
				//myTrace("account settings: key=" + tN.toString());
				
			// v6.5.5.1 If the T_LicenceAttributes is used, it will send back key value pairs
			// that we can just add to the licence object.
			} else if (tN.nodeName == "licence") {
				for (var specialKey in tN.attributes) {
					// In general we want to override the licence file if we have read the database.
					//if (_global.ORCHID.root.licenceHolder.licenceNS[specialKey] == undefined) {
						// there are some attributes that need special treatment
						switch (specialKey) {
							case "validCourses": 
							case "customisation":
								_global.ORCHID.root.licenceHolder.licenceNS[specialKey] = tN.attributes[specialKey].split(",");
								break;
							case "IPrange": 
							case "RUrange": 
								if (_global.ORCHID.root.licenceHolder.licenceNS.control==undefined) {
									_global.ORCHID.root.licenceHolder.licenceNS.control = new Object();
								}
								_global.ORCHID.root.licenceHolder.licenceNS.control[specialKey] = tN.attributes[specialKey].split(",");
								break;
							// These will only happen on self-hosting
							case "licenceServer.IP":
								if (_global.ORCHID.root.licenceHolder.licenceNS.licenceServer==undefined) {
									_global.ORCHID.root.licenceHolder.licenceNS.licenceServer = new Object();
								}
								_global.ORCHID.root.licenceHolder.licenceNS.licenceServer.IP = tN.attributes[specialKey];
								break;
							case "licenceServer.name":
								if (_global.ORCHID.root.licenceHolder.licenceNS.licenceServer==undefined) {
									_global.ORCHID.root.licenceHolder.licenceNS.licenceServer = new Object();
								}
								_global.ORCHID.root.licenceHolder.licenceNS.licenceServer.name = tN.attributes[specialKey];
								break;
							// v6.5.6.5 Allow licence to override brandMovies
							case "brandMovies":
								_global.ORCHID.paths.brandMovies = tN.attributes[specialKey];
								break;
							// v6.5.5.5 Allow forced literal language from here too (particularly useful for Author Plus)
							case "language":
								_global.ORCHID.commandLine.language = tN.attributes[specialKey];
								// Since you have already loaded literals, you (might) need to reset the language
								if (_global.ORCHID.commandLine.language.indexOf("*") >0) {
									var thisLang = _global.ORCHID.commandLine.language.split("*")[0];
									// And maybe you need to remove the language selector if it was earlier enabled.
									myTrace("hiding the language selector");
									_global.ORCHID.root.buttonsHolder.LoginScreen.literal_cb.setEnabled(false);
								} else {
									var thisLang = _global.ORCHID.commandLine.language.split(",")[0];
								}
								_global.ORCHID.literalModelObj.langList = _global.ORCHID.literalModelObj.getLiteralLanguageList();
								_global.ORCHID.literalModelObj.setLiteralLanguage(thisLang);
								break;
							// covering any other keypairs that you haven't documented
							// v6.5.6 For SCORM default group
							// defaultGroup
							// groupedRoots (allows several accounts to share a licence)
							default:
								_global.ORCHID.root.licenceHolder.licenceNS[specialKey] = tN.attributes[specialKey];
						}
					//}
					myTrace("special licence key from db: " + specialKey + "=" + tN.attributes[specialKey]); // + " (" + _global.ORCHID.root.licenceHolder.licenceNS[specialKey] + ")");
				}
				
			// v6.5.4.5 And finally a database version that we might use to block certain calls
			} else if (tN.nodeName == "database") {
				this.master.databaseVersion = tN.attributes.version;
				myTrace("database version=" + tN.attributes.version);
				
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// v6.5.5.5 Just for testing
		//myTrace("commandLine=" + _global.ORCHID.commandLine.toString());
		// v6.4.3 Check that the database connection is closed now that you are logged in
		myTrace("try to call dbClose");
		_global.ORCHID.root.queryHolder.dbClose();

		// v6.5.6.5 Allow brand movies to have prefix in it. If it does, substitute it here.
		// You've waited this long because brandMovies might come from licenceAttributes or location.txt
		var prefixString = "#prefix#";
		if (_global.ORCHID.paths.brandMovies.indexOf(prefixString)>=0) {
			_global.ORCHID.paths.brandMovies = _global.ORCHID.functions.addSlash(findReplace(_global.ORCHID.paths.brandMovies,prefixString,_global.ORCHID.commandLine.prefix));
			myTrace("replacing prefix in brandMovies to be " + _global.ORCHID.paths.brandMovies);
		}		
		
		// a successful call will have ...
		// v6.5.4.3 Yiu, will have if there is no error, account expiry
		if(!bErrorReceived) {
			
			// v6.5.5.5 Now we want to validate this information.
			// But skip this if we read an old style licence AND there was no account info from getRMSettings
			//myTrace("accounts used=" + dbAccountsUsed);
			if (dbAccountsUsed==false) {
				//myTrace("onLoad");
				// This goes back to controlFrame3.readProgramSettings
				this.master.onLoad();
			} else {
				// Build the string of data that was protected
				//$account->name.$account->selfHostDomain.$title-> expiryDate.$title-> maxStudents.$title->licenceType.$account->id.$title->productCode;
				var protectedString = _global.ORCHID.root.licenceHolder.licenceNS.institution + 
								_global.ORCHID.root.licenceHolder.licenceNS.control.server +
								this.master.expiryDate+
								this.master.maxStudents+
								_global.ORCHID.root.licenceHolder.licenceNS.licenceType + 
								_global.ORCHID.root.licenceHolder.licenceNS.central.root+
								_global.ORCHID.root.licenceHolder.licenceNS.productCode;
				//myTrace("oo.protectedString=" + protectedString + " and checksum=" + _global.ORCHID.root.licenceHolder.licenceNS.checksum);
				// Check it out - and go on if all is OK
				_global.ORCHID.root.displayListHolder.displayListNS.checkDisplay(protectedString, _global.ORCHID.root.licenceHolder.licenceNS.checksum);			
			}			
		}
	}
	thisDB.runQuery();
}
// 	//trace("in PSO.load with " + this.fileName);
// 	loadVarsText = new LoadVars();
// 	loadVarsText.caller = this;
// 	loadVarsText.load(this.fileName);
// 	//Note: it is not clear why we don't use onLoad + decode() with a URL encoded ini file!
// 	loadVarsText.onData = function(rawText) {
// 		//trace("got: " + rawText);
// 		getTag = function(rawText, tag) {
// 			var startNumber = rawText.indexOf(tag) + tag.length;
// 			if (startNumber < tag.length) return;
// 			var endNumber = rawText.indexOf("\r", startNumber);
// 			if (endNumber < startNumber) endNumber = rawText.length;
// 			return rawText.substring(startNumber, endNumber);
// 		}
// 		this.caller.dbMethod = getTag(rawText, "dbMethod=");
// 		this.caller.language = getTag(rawText, "language=");
// 		this.caller.registrationFlag = getTag(rawText, "registration=");
// 		// This is being done in the wrong place!!
// 		// OK now this is meaningless as there is a course chooser
// 		//this.caller.courseName = getTag(rawText, "courseName=");
// 		//trace("read that course=" + this.caller.courseName);
// 		this.caller.emailTo = getTag(rawText, "emailTo=");
// 		this.caller.onLoad();
// 	}

// *****
// User object
// 6.0.5.0 try to make this more of a model so you can do database stuff 
// more easily
// *****
// 6.0.5.0 This will go into OrchidIncludes once it is unlocked
#include "EventBroadcaster.as"

UserObject = function() {
	
	// make the user model an event source
	EventBroadcaster.initialize(this);

}
// "load" a user means use a GUI to get the details, then look them up in the database
// and if necessary register them, add a session record and save the information 
UserObject.prototype.load = function() {
	//myTrace("in user load with object " + this.oops);
	// after the GUI has worked, it needs to be able to send this object the onLoad event
	// so you have to save it somewhere on the timeline
	//trace("root here is " + _global.ORCHID.root._name);
	// 6.0.5.0 reduce pointers to the user object
	//_global.ORCHID.root.thisUser = this;
	// Note: is there a worry that if this method is called from another MC that the scope of the
	// frame name will be wrong?
	//6.0.5.0 Aargh - this is horrible! At least you should be calling - loginNS.setState(login)
	// but surely the controller should call this in some other way
	//6.0.4.0, boardcast event to view object instead of calling functions of view object directly
	//as user object is one of the model objects
	//_global.ORCHID.root.loginHolder.gotoAndStop("login");
	//_global.ORCHID.viewObj.displayScreen("LoginScreen");
	this.broadcastMessage("userEvent", "onLoad");
	
	// v6.5.5.5 We may want to find which courses the user has already started at an early stage.
	// call it startedContent and treat it kind of like hiddenContent
	this.startedContent = new Array();
}
// details constructor
UserObject.prototype.setUserDetails = function(myObject) {
	//trace("in setUserDetails with " + myObject.name);
	this.userID = myObject.userID;
	// v6.5.4.5 If this didn't come back from the database (because we are worried about utf-8) then use our current value
	//if (myObject.name <> undefined)  this.name = myObject.name;
	if (myObject.userName <> undefined)  this.name = myObject.userName;
	this.studentID = myObject.studentID;
	this.password = myObject.password;
	//v6.5.4.3 Yiu, added to prevent people use same UserName to login more then one time
	// v6.5.5.0 This is an instance, not a licence
	//if (myObject.licenceID <> undefined)  this.licenceID = myObject.licenceID;
	if (myObject.instanceID <> undefined)  this.instanceID = myObject.instanceID;
	//this.preferences = myObject.preferences;
	this.email = myObject.email;
	// v6.5.4.3 Add groupID to the user object - you might need it sometime
	this.groupID = myObject.groupID;
	this.country = myObject.country;
	this.language = myObject.language;
	this.company = myObject.company;
	// v6.3.6 Added for user type (to see who is a teacher for progress report)
	// v6.4.2.8 Decided that within Orchid, everybody should be treated as if they were a student
	// This means that scores for teachers are recorded (useful for demo etc)
	// and you don't get the horrible list when you look at progress (which doesn't work anymore anyway).
	// The simplest way to effect this is to simply override the type here. But will that confuse you later?
	// v6.5.4.5 Yes, I think it might. Take it out to see what happens.
	// v6.5.5.3 If we don't get back a userType (eg demo), assume it is a student
	//this.userType = myObject.userType;
	if (myObject.userType<>undefined) {
		this.userType = myObject.userType;
	} else {
		this.userType = 0;
	}
	//this.userType = 0;
	// v6.5.4.5 It might be useful to know which group this user is in. Done already!
	//this.groupID = myObject.groupID;
	
	// v6.4.1 If this is an APL account, the ALL users are counted as students otherwise
	// you get the effect that the student is logged in as a teacher (screws up progress)
	if (_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("light") >= 0) {
		this.userType = 0;
	}
	//myTrace("user " + this.name + " is id=" + this.userID);
	// 6.0.6.0 When you first read the user details ALWAYS set the scratch pad
	// to null to make it very clear that you haven't read the saved version yet
	this.scratchPad = null;

}
// v6.4.4 MGS
UserObject.prototype.setUserMGS = function(myObject) {
	this.MGSEnabled = myObject.enabled=="true" ? true : false;
	this.MGSName = myObject.name;
	//myTrace("user: mgsEnabled=" + this.MGSEnabled + " name=" + this.MGSName)
}

// v6.5.2 By Yiu on 13-12-07 Adding a new function for password encryption if the licence allow it
UserObject.prototype.checkIfLicenceForcesEncryption= function() {
	var bResult:Boolean;
	bResult= _global.ORCHID.root.licenceholder.licenceNS.control.encryption == 2;
	//myTrace("(Yiu)in checkIfLicenceAllowEncrypt, encryption= " + bResult);
	return bResult;
}

UserObject.prototype.encryptionIfLicenceForces= function(strOriginPassword){
	var strResultPassword:String;
	strResultPassword= strOriginPassword;
	
	//myTrace("(Yiu)<OrchidObject.as:encrptionIfLicenceAllowed>Origin Password: " + strOriginPassword);
	if(UserObject.prototype.checkIfLicenceForcesEncryption()){
		strResultPassword= clarityMD5(strOriginPassword, "Clarity");
	}
	//myTrace("(Yiu)<OrchidObject.as:encrptionIfLicenceAllowed>The result password: " + strResultPassword);
	return strResultPassword;
}
// End v6.5.2 By Yiu on 13-12-07 Adding a new function for password encryption if the licence allow it

// 6.0.5.0 New method for 'starting' a user
// Assume that you have the name/password from the login screen and 
// need to validate this combination and then add a session if ok
// Validation includes password confirmation and licence slot allocation
// but this will be done by the actual database routine
// 6.2.1 Windows version
// Need to separate calls that talk to the licence and score databases.
// Therefore startUser will no longer do the licence validation.
// v6.5.5.5 Allow to login with userID too
UserObject.prototype.startUser = function(myName, myPassword, myStudentID, myUserID) {
	
	// v6.5.5.1 For measuring performance
	myTrace("timeHolder.log.startOfFullyLoadedUser");
	_global.ORCHID.timeHolder.beginStartUser = new Date().getTime();
	
	// v6.3.4 You need to make sure that the progress bar is visible
	var myController = _global.ORCHID.root.tlcController;
	var inputObject = _global.ORCHID.root.controlNS.master;
	// v6.3.1 Pickup progress bar location from buttons swf
	// v6.3.5 Overriden by screen based positioning
	/*
	if (_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar != undefined) {
		myController._x =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._x;
		myController._y =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._y;
		// v6.3.4 If the progress bar is not 100% fonts will be funny, so until you can 
		// set their xscale correctly to 100%, just hide them
		myController._width =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._width;
		myController._height =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._height;
		//if (_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._xscale != 100) {
		//	myTrace("hiding progress bar font as scaling=" + _global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._xscale);
		//	myController.enableLabel(false);
		//}
	} else {
		myController._x = myController._y = 5;
	}
	*/
	//myController.setLabel("check user");
	// v6.4.2.4 Resetting progress amounts
	myController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadUser", "labels"));
	myController.setPercentage(10);
	myController.setEnabled(true);

	// make a new db query
	// v6.3.6 Merge database to main and change NS anme
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	//myTrace("in startUser for name=" + myName + " id=" + myStudentID + " userID=" + myUserID + " password=" + myPassword);
	// v6.5.4.5 Set this name as the user one in case it doesn't come back from the database
	this.name = myName;
	
	// v6.3.4 Pass password as special null if you don't want to check it
	// v6.4.2.4 Or if RM settings say no verified, then never check their password even if set in the database
	//if ((typeof myPassword) == "null") {
	if ((typeof myPassword) == "null" || _global.ORCHID.programSettings.verified==false) {
		myTrace("sending null password");
		myPassword = "$!null_!$";
	} else  {
		// v6.4.3 For extra security we can encrypt the password in the database so it is never sent in plain text over the network
		// Use MD5. We will assume that any passwords sent on the commandLine are encrypted (because what is the point otherwise?)
		// But that means that we have to tell people the MD5 seed so that they can encrypt in the same way. Hmm.
		// Maybe it is just the case that only Clarity can pass them like this.
		myPassword = _global.ORCHID.user.encryptionIfLicenceForces(myPassword);
		myTrace("encrypted password=" + myPassword);
	}
	
	//v6.3.5 If the password was encrypted, it has already been decrypted			
	// put the query into an XML object

	// v6.5.4.2 Yiu, date added in queryString, for expiry check in SQLServer asp files, enhance888
	var dateToday:Date;
	dateToday = new Date();
	var nProductCode:Number;
	nProductCode =_global.ORCHID.root.licenceHolder.licenceNS.productCode; 
	//var bIsNetworkVersion:Boolean;
	//bIsNetworkVersion	=  _global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("concurrent") >= 0;
	//bIsNetworkVersion	=  _global.ORCHID.commandLine.scripting.toLowerCase() == "projector";

	// No longer do licence control in startUser
	//var nMaxStudentFromLicenceIni:Number;
	//nMaxStudentFromLicenceIni	= Number(_global.ORCHID.root.licenceHolder.licenceNS.licences);

	// v6.5.4.5 We will pass a licenceID to be used for total licence same username checking
	// v6.5.4.7 Mac creates this with two decimal points!
	// v6.5.5.0 This is for instances, nothing to do with licences - rename
	//this.licenceID	= Math.round(new Date().getTime());
	// v6.5.5.5 If another script has started this user - then we need to pick up a passed instanceID
	if (_global.ORCHID.commandLine.instanceID!="" && _global.ORCHID.commandLine.instanceID!=undefined) {
		myTrace("use passed instanceID rather than creating a new one");
		this.instanceID = _global.ORCHID.commandLine.instanceID;
	} else {
		this.instanceID = Math.round(new Date().getTime());
	}

	// v6.5.4.5 If you pass a " character as an attribute, you screw the query. So convert anything that could hold one.
	myName = _global.ORCHID.root.objectHolder.safeQuotes(myName);
	myPassword = _global.ORCHID.root.objectHolder.safeQuotes(myPassword);
	myStudentID = _global.ORCHID.root.objectHolder.safeQuotes(myStudentID);
	
	// v6.5.5.5 Allow userID login
	// v6.6.0.2 including anonymous -1 user
	//if (myUserID!=undefined && myUserID>0) {
	if (myUserID!=undefined && myUserID!='') {
		var myLoginOption = _global.ORCHID.accessControl.ACCELogin;
	} else {
		var myLoginOption = _global.ORCHID.programSettings.loginOption;
		myUserID="";
	}
	
	// v6.5.6 If you are running under SCORM and you have groupedRoots set from the licence, then this is really startGlobalUser
	// and it will return a rootID that you might need to use to override the root you came in on.
	if (_global.ORCHID.commandLine.scorm && 
		(_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots!=undefined 
		&& ((_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots.indexOf(",")>0) || _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots=='*'))) {
		// we should try to make sure that the list is well-formed
		if (_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots=='*') {
			rootList='*';
		} else {
			var validRoot=false;
			var rootArray = _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots.split(",");
			for (var i=0; i<rootArray.length; i++) {
				if (!isNaN(parseInt(rootArray[i])) && parseInt(rootArray[i])>=1) {
					validRoot=true;
				} else {
					rootArray[i]=0;
				}
			}
			if (validRoot) {
				var rootList = rootArray.join(",");
			} else {
				var rootList = _global.ORCHID.root.licenceHolder.licenceNS.central.root;
			}
		}
		var myRoot = rootList;
	} else {
		var myRoot = _global.ORCHID.root.licenceHolder.licenceNS.central.root;
	}
	// v6.5.4.6 if there is no licence start date - send today so that it will have no effect
	// This is all now handled at the end of getRMSettings
	//if (_global.ORCHID.root.licenceHolder.licenceNS.registrationDate == undefined ||
	//	_global.ORCHID.root.licenceHolder.licenceNS.registrationDate=="") {	
	//	_global.ORCHID.root.licenceHolder.licenceNS.registrationDate = dateFormat(dateToday);
	//}
	
	thisDB.queryString = '<query method="startUser" ' +
						'rootID="' + myRoot + '" ' +
						'userID="' + myUserID + '" ' +
						'name="' + myName + '" ' +
						'studentID="' + myStudentID + '" ' +
						'password="' + myPassword + '" ' +
						'dateStamp="' + dateFormat(dateToday) + '" ' + 
						'loginOption="' + myLoginOption + '" ' +
						// v6.5.5.0 rename
						//'licenceID="' + this.licenceID + '" ' +
						'instanceID="' + this.instanceID + '" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +	// v6.5.4.3 Yiu, past product code for licence allocation check if needed	
						//'name="' + "Dandeli&#246;n" + '" ' +
						//'name="' + "Dandeliön" + '" ' +
	//					'networkVersion="' + bIsNetworkVersion + '" ' +	// v6.5.4.3 Yiu, if network version no need to check licence allocation
	//					'maxStudent="' + nMaxStudentFromLicenceIni + '" ' +	// v6.5.4.3 Yiu, used to check licence allocation, overwrite by the maxstudent in T_Accounts if it exist 
	// v6.5.4.5 don't need cacheVersion as licenceID is same thing
	//					'cacheVersion="' + new Date().getTime() + '"/>';
						// v6.5.4.6 For non-transferable licences
						// v6.5.5.0 Licence control is not done in StartUser anymore
						// 'licences="' + _global.ORCHID.root.licenceHolder.licenceNS.licences + '" ' +
						//'licenceStartDate="' + _global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate + '" ' +
						// pass the database version that you read during getRMSettings
						// v6.5.5.5 Also send back any course IDs in this product that the user has already started
						// This is initially for LKHT and keyed purely on the productCode.
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
						" />";

	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		// v6.5.5.1 For measuring performance
		_global.ORCHID.timeHolder.query['stop_' + 'startUser'] = new Date().getTime();
		
		myTrace("back to startUser with " + this.toString());
		// v6.3.6 Merge login into main
		var callBackModule = _global.ORCHID.root.mainHolder.loginNS;
		// 6.2.1 Windows version
		//var mySession = {}; // hold session information that we created
		var errReceived = false;
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//myTrace("return node=" + tN.toString());
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				// v6.5.4.5 Undo the name I saved earlier
				//this.master.name == "";
				errReceived = true;
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
				//6.0.4.0, broadcast an event instead of call functions to change the interface directly
				if (tN.attributes.code == "203") {
					//callBackModule.noSuchUser();
					this.master.broadcastMessage("userEvent", "onNoSuchUser");
				} else if (tN.attributes.code == "206") {
					//callBackModule.noSuchUser();
					this.master.broadcastMessage("userEvent", "onNoSuchID");
				} else if (tN.attributes.code == "204") {
					//myTrace("call wrongPassword");
					//callBackModule.wrongPassword();
					// Special case for SCORM and DEMO - where we know this will happen
					if ((_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("demo") >= 0) &&
						_global.ORCHID.commandLine.scorm) {
						myTrace("wrong password, but SCORM to the DEMO so ignore");
						errReceived=false;
					} else {
						this.master.broadcastMessage("userEvent", "onWrongPassword");
					}
				// 6.2.1 Windows version
				//} else if (tN.attributes.code == "201") {
				//	//myTrace("call noLicences in loginNS");
				//	//callBackModule.noLicences();
				//	this.master.broadcastMessage("userEvent", "onNoLicences");
				} else if (tN.attributes.code == "208") {	//v6.5.4.3 Yiu, error message got after check user expiry
					_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
					this.master.broadcastMessage("userEvent", "onUserExpired");
				} else if (tN.attributes.code == "209") {	//v6.5.4.3 Yiu, error message got after user failed in licence allocation check
					_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
					this.master.broadcastMessage("userEvent", "onLicenceAllocationFailed");
				} else if (tN.attributes.code == "211") {	// v6.5.4.7 error message from full licence (tracking)
					_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
					this.master.broadcastMessage("userEvent", "onLicenceFull");
				} else if (tN.attributes.code == "220") {	// v6.5.6 Multiple users with this name/id/password in this root\
					// Special case for SCORM and DEMO - where we know this will happen
					if ((_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("demo") >= 0) &&
						_global.ORCHID.commandLine.scorm) {
						// ignore the error and just keep going with the first user you found
						myTrace("multiple users, but SCORM to the DEMO so ignore");
						errReceived=false;
					} else {
						_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
						if (_global.ORCHID.commandLine.scorm) {
							// v6.5.6 broadcasting a user event is not great as that is usually used to give you a login screen to try again.
							// In this case we want a terminal error. Probably in most cases we want a terminal error.
							myTrace("multiple users is an error");
							errObj = { literal:"multipleUsers" };
							_global.ORCHID.root.controlNS.sendError(errObj);
						} else {
							this.master.broadcastMessage("userEvent", "onMultipleUsers");
						}
					}
				}	
			// we are expecting to get back a user node
			} else if (tN.nodeName == "user") {
				//myTrace("got back userID=" + tN.attributes.userID);
				// parse the returned XML to get user details
				// v6.5.4.7 WZ for China Road to IELTS
				// If the attributes that we get back from the database don't match the user details we got on the command line
				// (and assuming that we are working in autoRegister mode) we should update the database. It is important for 
				// expiryDate (as candidates can postpone their exam) and email (to ensure accurate communication). It is merely nice for name.
				// Note: One thing to note is that we have to return the username from PHP, which we were avoiding so that we didn't have to
				// worry about special characters. Somewhere else we do something to workround that which we could stop now.
				// productCode is quite unique to the Road to IELTS China registration as it is the only way to tell difference between Academic and GT.
				// The main reason is expiryDate. 
				// a) The candidate postpones. So in this case the new expiryDate should be after the old, and the old ought not to have expired yet.
				// b) Candidate fails the exam and then reapplies. We should be treating this as an entirely new candidate (for billing purposes).
				//	The way to do that is to have deleted them as soon as they expired. Then the ID will be new and we simply do addNewUser.
				//	If they are still hanging around in the database we probably can't work out that they are new.
				// Note: Check that dbProgress doesn't send back an error 209 as that probably gets acted on first even though this user node will come back as well.
				// Note: Make sure that calling startUser twice doesn't duplicate licence counting.
				// v6.5.5.5 Is it really correct that we do this for validedLogin? We use that in CE.com and we certainly don't want any updating from that.
				if (_global.ORCHID.commandLine.action == "validatedLogin" || _global.ORCHID.commandLine.action == "autoRegister" ) {
					var bUpdate = 0; // Boolean for updating judgement
					var pUserName = tN.attributes.userName;
					var pEmail = tN.attributes.email;
					var pExpiryDate = tN.attributes.expiryDate;
					// v6.5.4.7 We also only want to update if there is real data involved
					// v6.5.5.5 Do we really want to update case changes in the name? I think not.
					//if((tN.attributes.userName <>  inputObject.userName) && (inputObject.userName.length>0)){
					if((tN.attributes.userName.toLowerCase() <>  inputObject.userName.toLowerCase()) && (inputObject.userName.length>0)){
						bUpdate = 1;
						pUserName = inputObject.userName;
						myTrace("autoReg updating? name was " + tN.attributes.userName + " change to " + inputObject.userName);
					}
					if((tN.attributes.email <> inputObject.email) && (inputObject.email.length>0)){
						bUpdate = 1;
						pEmail = inputObject.email;
						myTrace("email was " + tN.attributes.email + " change to " + inputObject.email);
					}
					if(tN.attributes.expiryDate < inputObject.expiryDate){
						bUpdate = 1;
						pExpiryDate = inputObject.expiryDate;
						myTrace("expiry was " + tN.attributes.expiryDate + " change to " + inputObject.expiryDate);
					}
					
					if ( bUpdate == 1 ){
							// If update the user, stop getLicenceSlot at the first time.
							errReceived = true;
							// Note: inputObject is NOT a user object even if it shares several fields. Maybe you can run setUserDetails first and
							// then you can pass this.master instead which is the real user object. But you don't actually need the full user object, just the userID
							//_global.ORCHID.user.updateUser(inputObject);
							_global.ORCHID.user.updateUser(tN.attributes.userID, pUserName, pEmail, pExpiryDate);
							// The db is not updated yet, but lets just keep going by overriding the data we got
							// Validation?? With NEEA we simply trust everything they tell us - this won't be extendable
							this.master.userName = pUserName;
							this.master.email = pEmail;
							this.master.expiryDate = pExpiryDate;
							// AR: We shouldn't do this immediately, it ought to be called once we get a success return from updateUser.
							// This is calling this same routine again with the new parameters.
							//_global.ORCHID.user.startUser(_global.ORCHID.commandLine.userName, null, _global.ORCHID.commandLine.studentID);
							//this.master.broadcastMessage("userEvent", "onLoad");
					}
				}
				
				// v6.5.6 Check to see if the root that we sent to the call is the same as the one that came back.
				// If not, for now we will simply overwrite it, but it might be that we ought to go back and do getRMSettings again.
				// I'm doing this because this is only used for SCORM and not much is relevant to SCORM from getRMSettings.
				// But there are two things: the groupedRoots used in getLicenceSlot will still be from the default root licence - very probably correct
				// but the institution name is also from the default root and this is probably not right, but equally not a big deal.
				if (tN.attributes.rootID!=undefined && tN.attributes.rootID != _global.ORCHID.root.licenceHolder.licenceNS.central.root) {
					myTrace("startUser found this user in a different root, so change " + _global.ORCHID.root.licenceHolder.licenceNS.central.root  + " to " + tN.attributes.rootID);
					_global.ORCHID.root.licenceHolder.licenceNS.central.root = tN.attributes.rootID;
					_global.ORCHID.commandLine.prefix = undefined;
					// You could just trigger everything to start again now, how much does that slow things down?
					// There are more things already set - like licence stuff. So for now leave this.
					//myTrace("going off to start again");
					//_global.ORCHID.programSettings.load();
					//return;
				}
				
				this.master.setUserDetails(tN.attributes);
				//this.master.userID = tN.attributes.userID;
				//this.master.name = tN.attributes.userName;
				//this.master.studentID = tN.attributes.studentID;
				myTrace("welcome " + this.master.name + " (" + this.master.studentID + ")");
				
				// v6.5.4.4 Is this quite the right place to add this user to the licence table? Synch issues with MGS fields query?
				// No - just do it as part of the startUser query. And part of addUser I suppose
				//	this.master.sendLicenceIDToDB();
				
			// v6.4.4 Also expecting an MGS node 
			} else if (tN.nodeName == "MGS") {
				this.master.setUserMGS(tN.attributes);
				
			// and a licence node
			// 6.2.1 Windows version
			//} else if (tN.nodeName == "licence") {
			//	// parse the returned XML to get licence details
			//	// licence details are saved in the session object
			//	mySession.licenceHost = tN.attributes.host;
			//	mySession.licenceID = tN.attributes.ID;
			//	mySession.licenceNote = tN.attributes.note;
			//	myTrace("your licence is " + mySession.licenceHost+":"+mySession.licenceID + " (" + mySession.licenceNote + ")");

			// 6.0.6.0 Sessions will be added ONLY after choosing a course as they are course specific
			// and a session node
			/*
			} else if (tN.nodeName == "session") {
				// parse the returned XML to get licence details
				// these details are saved in the user and session object
				// the users number of sessions is user information
				this.master.sessionCount = tN.attributes.count;
				//this session id and start time is session information
				mySession.sessionID = tN.attributes.id;
				//mySession.startTime = tN.attributes.startTime;
				myTrace("sessions=" + this.master.sessionCount);
			*/
			// v6.5.5.5.5 You might also get back a list of courseIDs that this user has started within the product
			} else if (tN.nodeName == "courseID") {
				//myTrace("got started course for this user:" + tN.attributes.id);
				this.master.startedContent.push(tN.attributes.id);
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		myTrace("startedContent=" + this.master.startedContent.join(","));
		// a successful call will have set the userID
		// v6.4.2.4 Let a userID of 0 for single, lso licences
		//if ((this.master.userID > 0 || this.master.userID == -1) && !errReceived) {
		if ((this.master.userID > 0 || this.master.userID == -1 || this.master.userID == 0) && !errReceived) {
			// 6.2.1 Windows version
			//_global.ORCHID.session = new SessionObject(mySession);
			//myTrace("successful call");
			//callBackModule.userStarted();
			//6.0.4.0, broadcast an event instead of call functions to change the interface directly
			// 6.2.1 Windows version
			//this.master.broadcastMessage("userEvent", "onUserStart");
			_global.ORCHID.user.getLicenceSlot(this.master);
		}
	}
	thisDB.runQuery();
}
// v6.5.4.7 For ClarityEnglish.com where we have already checked name/password and know the userID
// v6.5.5.5 But we still should check the password. Actually this must all go into the main startUser as it is getting out of sync and is essentially a copy
/*
UserObject.prototype.startUserID = function(myUserID, password) {
	// v6.3.4 You need to make sure that the progress bar is visible
	var myController = _global.ORCHID.root.tlcController;
	//myController.setLabel("check user");
	// v6.4.2.4 Resetting progress amounts
	myController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadUser", "labels"));
	myController.setPercentage(10);
	myController.setEnabled(true);

	// make a new db query
	// v6.3.6 Merge database to main and change NS anme
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	myTrace("in startUserID for " + myUserID);
	
	// v6.5.4.2 Yiu, date added in queryString, for expiry check in SQLServer asp files, enhance888
	var dateToday:Date;
	dateToday = new Date();
	var nProductCode:Number;
	nProductCode =_global.ORCHID.root.licenceHolder.licenceNS.productCode; 

	// v6.5.5.0 It would be better to do licence checking in getLicenceSlot, not wrapped up with StartUser
	var nMaxStudentFromLicenceIni:Number;
	nMaxStudentFromLicenceIni	= Number(_global.ORCHID.root.licenceHolder.licenceNS.licences);

	// v6.5.4.5 We will pass a licenceID to be used for total licence same username checking
	// v6.5.4.7 Mac creates this with two decimal points!
	// v6.5.5.0 This is for instances, nothing to do with licences - rename
	//this.licenceID	= Math.round(new Date().getTime());
	// v6.5.5.5 If another script has started this user - then we need to pick up a passed instanceID
	if (_global.ORCHID.commandLine.instanceID!="" && _global.ORCHID.commandLine.instanceID!=undefined) {
		myTrace("use passed instanceID rather than creating a new one");
		this.instanceID = _global.ORCHID.commandLine.instanceID;
	} else {
		this.instanceID = Math.round(new Date().getTime());
	}
	
	// v6.5.5.5 Are we passing the password or is it null?
	if (password==null) {
		var myPassword="$!null_!$";
	} else {
		var myPassword=password;
	}

	// v6.5.4.7 We call the same startUser, and it works out that we have the userID not the names based on loginOption
	// need to generic password
	thisDB.queryString = '<query method="startUser" ' +
						'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
						'loginOption="' + _global.ORCHID.accessControl.ACCELogin + '" ' +
						'password="' + myPassword + '" ' +
						'userID="' + myUserID + '" ' +
						'dateStamp="' + dateFormat(dateToday) + '" ' + 
						'licences="' + _global.ORCHID.root.licenceHolder.licenceNS.licences + '" ' +
						//'licenceID="' + this.licenceID + '" ' +
						'instanceID="' + this.instanceID + '" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +	// v6.5.4.3 Yiu, past product code for licence allocation check if needed	
						// v6.5.4.6 For non-transferable licences
						'licenceStartDate="' + _global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate + '" ' +
						// pass the database version that you read during getRMSettings
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
						" />";

	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		myTrace("back to startUserID from db with " + this.toString());
		// v6.3.6 Merge login into main
		var callBackModule = _global.ORCHID.root.mainHolder.loginNS;
		// 6.2.1 Windows version
		//var mySession = {}; // hold session information that we created
		var errReceived = false;
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//myTrace("return node=" + tN.toString());
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				// v6.5.4.5 Undo the name I saved earlier
				//this.master.name == "";
				errReceived = true;
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
				//6.0.4.0, broadcast an event instead of call functions to change the interface directly
				if (tN.attributes.code == "203") {
					//callBackModule.noSuchUser();
					this.master.broadcastMessage("userEvent", "onNoSuchUser");
				} else if (tN.attributes.code == "206") {
					//callBackModule.noSuchUser();
					this.master.broadcastMessage("userEvent", "onNoSuchID");
				} else if (tN.attributes.code == "204") {
					//myTrace("call wrongPassword");
					//callBackModule.wrongPassword();
					this.master.broadcastMessage("userEvent", "onWrongPassword");
				// 6.2.1 Windows version
				//} else if (tN.attributes.code == "201") {
				//	//myTrace("call noLicences in loginNS");
				//	//callBackModule.noLicences();
				//	this.master.broadcastMessage("userEvent", "onNoLicences");
				} else if (tN.attributes.code == "208") {	//v6.5.4.3 Yiu, error message got after check user expiry
					_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
					this.master.broadcastMessage("userEvent", "onUserExpired");
				} else if (tN.attributes.code == "209") {	//v6.5.4.3 Yiu, error message got after user failed in licence allocation check
					_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
					this.master.broadcastMessage("userEvent", "onLicenceAllocationFailed");
				} else if (tN.attributes.code == "211") {	// v6.5.4.7 error message from full licence (tracking)
					_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
					this.master.broadcastMessage("userEvent", "onLicenceFull");
				}	
			// we are expecting to get back a user node
			} else if (tN.nodeName == "user") {
				this.master.setUserDetails(tN.attributes);
				myTrace("welcome " + this.master.name + " (" + this.master.studentID + ")");
				
			// v6.4.4 Also expecting an MGS node 
			} else if (tN.nodeName == "MGS") {
				this.master.setUserMGS(tN.attributes);
				
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call will have set the userID
		if ((this.master.userID > 0 || this.master.userID == -1 || this.master.userID == 0) && !errReceived) {
			_global.ORCHID.user.getLicenceSlot(this.master);
		}
	}
	thisDB.runQuery();
}
*/

// v6.5.4.7 WZ for China Road to IELTS
//UserObject.prototype.updateUser = function(userObject) {
UserObject.prototype.updateUser = function(myUserID, myUserName, myEmail, myExpiryDate) {
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	// Note: we shouldn't be updating all fields as they cannot all be set.
	// Remove loginOption, licences, licenceID, licenceStartDate, dateStamp
	// We don't know password and don't want to change that here.
	// I think we know userID don't we? We could use that rather than studentID
	// The dbProgress.php code also thinks that you are passing city and country.
	// v6.5.4.7 Protect anything that could have html entities in it
	// Lets just do the minimum for now
	//myStudentID = _global.ORCHID.root.objectHolder.safeQuotes(_global.ORCHID.root.controlNS.master.studentID);
	myName = _global.ORCHID.root.objectHolder.safeQuotes(myUserName);
	myEmail = _global.ORCHID.root.objectHolder.safeQuotes(myEmail);
	thisDB.queryString = '<query method="updateUser" ' +
						'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
						'userID="' + myUserID + '" ' +
						'name="' + myName + '" ' +
						'email="' + myEmail + '" ' +
						'expiryDate="' + myExpiryDate + '" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
						'dateStamp="' + dateFormat(dateToday) + '" ' + 
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
						" />";

	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		// What would we do if the update failed?
		myTrace("back to updateUser from db with " + this.toString());
		// v6.5.5.0 Surely myUserID is undefined in this scope?
		//_global.ORCHID.user.startUserID(myUserID);
		// v6.5.5.5 removed this function, put it all into startUser
		//_global.ORCHID.user.startUserID(this.master.myUserID);
		_global.ORCHID.user.startUser(null, null, null, this.master.myUserID);
	}
	thisDB.runQuery();
}
// v6.5.4.6 Change password
UserObject.prototype.changePassword = function(myPassword) {
	// v6.3.4 You need to make sure that the progress bar is visible
	var myController = _global.ORCHID.root.tlcController;
	//myController.setLabel("check user");
	// v6.4.2.4 Resetting progress amounts
	myController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadUser", "labels"));
	myController.setPercentage(10);
	myController.setEnabled(true);

	// make a new db query
	// v6.3.6 Merge database to main and change NS anme
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	myTrace("in changePassword for " + this.name + " new password=" + myPassword);
	
	// v6.5.4.5 If you pass a " character as an attribute, you screw the query. So convert anything that could hold one.
	myPassword = _global.ORCHID.root.objectHolder.safeQuotes(myPassword);
	
	thisDB.queryString = '<query method="changePassword" ' +
						'userID="' + this.userID + '" ' +
						'password="' + myPassword + '" ' +
						'cacheVersion="' + new Date().getTime() + '" ' +
						" />";

	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		myTrace("back to changePassword from db with " + this.toString());
		// v6.3.6 Merge login into main
		var callBackModule = _global.ORCHID.root.mainHolder.loginNS;
		var errReceived = false;
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//myTrace("return node=" + tN.toString());
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				// v6.5.4.5 Undo the name I saved earlier
				//this.master.name == "";
				errReceived = true;
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
				//6.0.4.0, broadcast an event instead of call functions to change the interface directly
				if (tN.attributes.code == "205") {
					this.master.broadcastMessage("userEvent", "onPasswordChangeFailed");
					return;
				}	
				
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		var noticeObj = {type:"passwordChanged", detail:_global.ORCHID.literalModelObj.getLiteral("passwordChanged", "messages")};
		_global.ORCHID.root.controlNS.sendNotice(noticeObj);
		this.master.broadcastMessage("userEvent", "onPasswordChanged");
	}
	thisDB.runQuery();
}

// 6.2.1 Windows version
// This is now a separate call as it acts on the connection table
UserObject.prototype.getLicenceSlot = function(userObject) {
	// v6.3.2 Cope with total and concurrent licences
	// v6.4.2 make case insensitive
	// v6.5.3 How about letting teachers in without taking up a slot? Or rather, give them a slot of their own
	// so that we can count them (at some point)
	//if (_global.ORCHID.root.licenceHolder.licenceNS.licencing.indexOf("Concurrent") >= 0) {
	// v6.5.5.0 Merge all licence type checking
	//if (_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("concurrent") >= 0) {
	//	myTrace("concurrent licence so get slot first (for userid=" + userObject.userID + ")");
	// make a new db query
	// v6.3.6 Merge database to main and change NS anme
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	//myTrace("in getLicenceSlot");
	
	// v6.5.5.0 We really do want userID now for licence slots. Lets worry about APL another way or time
	// v6.3.5 APL users are also measured within a userID (it is the teacher's account)
	// v6.4.2 BUT this is a special case, normally you just do it by root. What is happening now
	// is that every user gets 10 concurrent licences! So code in getLicenceSlot needs to 
	// recognise a special concurrent APL licence.
	// Do it by only sending userID if you want to use it. See above
	// v6.5.5.0 We really do want userID now for licence slots. Lets worry about APL another way or time
	//if (_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("light") >= 0) {
	//	//myTrace("APL, so add userID to concurrent check")
	//	// v6.4.2.6 correction
	//	//var myUserID = this.userID;
	//	var myUserID = userObject.userID;
	//} else {
	//	var myUserID = -1;
	//}
	// v6.5.6 Maybe you want to check licences across a set of accounts?
	//myTrace("groupedRoots=" + _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots);
	if (_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots!=undefined 
		&& ((_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots.indexOf(",")>0) || _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots=='*')) {
		// we should try to make sure that the list is well-formed
		if (_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots=='*') {
			rootList='*';
		} else {
			var validRoot=false;
			var rootArray = _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots.split(",");
			for (var i=0; i<rootArray.length; i++) {
				if (!isNaN(parseInt(rootArray[i])) && parseInt(rootArray[i])>=1) {
					validRoot=true;
				} else {
					rootArray[i]=0;
				}
			}
			if (validRoot) {
				var rootList = rootArray.join(",");
			} else {
				var rootList = _global.ORCHID.root.licenceHolder.licenceNS.central.root;
			}
		}
		var myRoot = rootList;
	} else {
		var myRoot = _global.ORCHID.root.licenceHolder.licenceNS.central.root;
	}
	// put the query into an XML object
	thisDB.queryString = '<query method="getLicenceSlot" ' +
						'licences="' + _global.ORCHID.root.licenceHolder.licenceNS.licences + '" ' +
						// v6.5.5.0 Let the script work out which type of licence you are
						//'licencing="' + _global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase() + '" ' +
						// v6.5.5.5 Change the name (duplicate for a while)
						'licenceType="' + _global.ORCHID.root.licenceHolder.licenceNS.licenceType + '" ' +
						//'licencing="' + _global.ORCHID.root.licenceHolder.licenceNS.licenceType + '" ' +
						// v6.3.3 Concurrent users are also measured within a root
						'rootID="' + myRoot + '" ' +
						'userID="' + userObject.userID + '" ' +
						//'userID="' + myUserID + '" ' +
						'userType="' + userObject.userType + '" ' +
						// v6.5.4.5 I never pass a licenceID to this function
						//'licenceID="' + this.licenceID + '" ' +
						// v6.4.2.4 Send the productCode from the licence so that different products do NOT share the same licence limit
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
						// v6.5.4.6 For non-transferable licences
						'licenceStartDate="' + _global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate + '" ' +
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
						'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		_global.ORCHID.timeHolder.query['stop_' + 'getLicenceSlot'] = new Date().getTime();
		myTrace("back to getLicenceSlot from db with " + this.toString());
		// v6.3.6 Merge login into main
		var callBackModule = _global.ORCHID.root.mainHolder.loginNS;
		var mySession = {}; // hold session information that we created
		var errReceived = false;
		// v6.5.6 See below for errors back from SQL
		mySession.licenceID=-1;
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				errReceived = true;
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")",2)
				//6.0.4.0, broadcast an event instead of call functions to change the interface directly
				// v6.5.7 201 Should be for unexpected errors
				// v6.5.7 212 Should be for anonymous or concurrent tracking licence full.
				// But for now treat the same (please wait...)
				if (tN.attributes.code == "201" || tN.attributes.code == "212") {
					myTrace("call noLicences in getLicenceSlot");
					//callBackModule.noLicences();
					// You need to call this to record the licence failure
					_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
					this.master.broadcastMessage("userEvent", "onNoLicences");
					return;
				// v6.5.5.0 learner tracking sends back this error if the licence is full
				} else if (tN.attributes.code == "211") {	// v6.5.4.7 error message from full licence (tracking)
					_global.ORCHID.storeErrorToDB(tN.attributes.code, tN.attributes.userID);
					this.master.broadcastMessage("userEvent", "onLicenceFull");
					return;
				// v6.3.5 This was missing. But what does return do?
				// v6.4.1 If you get any other error, you are simply going to get a 
				// db cannot be read message, which is wrong.
				} else if (tN.attributes.code == "202") {
					//myTrace("cannot insert licence record");
				}
				
			// and a licence node
			} else if (tN.nodeName == "licence") {
				// parse the returned XML to get licence details
				// licence details are saved in the session object
				// v6.5.5.0 For learner tracking licences most of this information will be null
				mySession.licenceHost = tN.attributes.host;
				mySession.licenceID = tN.attributes.ID;
				mySession.licenceNote = tN.attributes.note;
				myTrace("node: licenceSlot is " + mySession.licenceHost+":"+mySession.licenceID + " (" + mySession.licenceNote + ")");

			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// v6.4.3 Check that the database connection is closed now that you are logged in
		myTrace("try to call dbClose");
		_global.ORCHID.root.queryHolder.dbClose();
		
		// a successful call will have set session details
		// v6.3.5 If you didn't anything back (asp errors), then it used to keep going!
		// So now check good as well as bad returns
		// v6.5.5.0 LicenceID can be 0 - used for Learner Tracking
		// v6.5.6 If SQL crashes you don't err or licence node back, so the program keeps going!
		// Preset licenceID to -1 to avoid this.
		myTrace("mySession.licenceID=" + mySession.licenceID);
		if (!errReceived && mySession.licenceID>=0) {
			_global.ORCHID.session = new SessionObject(mySession);
			//6.0.4.0, broadcast an event instead of call functions to change the interface directly
			this.master.broadcastMessage("userEvent", "onUserStart");
		} else {
			//myTrace("simply cannot get licence info");
			_global.ORCHID.root.controlNS.sendError({literal:"noDBConnection", detail:"(licence table)"});
		}
	}
	//thisDB.runQuery();
	// 6.0.7.0, use runSecureQuery as we will access the connection database when calling getLicenceSlot.
	thisDB.runSecureQuery();
	
	//} else {
		// Total licence control is simply done through database count on number of registered users
		// concurrent users does not matter. So ignore the connection table.
		// v6.5.4.5 Now we want to confirm that you don't have two people with the same name
		// at this point, all we are doing is setting a licenceID for this login
		// Except, why not do this within startUser?
		//this.setLicenceID();
		
		// v6.5.5.0 First, the double login is concerned with instances, not licences. It is handled within StartUser
		// and applies equally to concurrent licences.
		// Secondly, we want to remove the learner tracking licence control from Startuser to here so that it is
		// parallel to concurrent.
		// I would guess that I could use the same getLicenceSlot for both types of licence. Duplicate it here first.

		//// trigger this code once licence ID has been set
		//myTrace(_global.ORCHID.root.licenceHolder.licenceNS.licencing + " licence, so no need for a licence slot");
		//var mySession = {}; // hold session information that we created
		//// v6.5.4.5 But we do have a licence ID for the user now. Might as well save it, can't do any harm??
		////mySession.licenceID = undefined;
		//mySession.licenceID = this.licenceID;
		//mySession.licenceNote = "total";
		//_global.ORCHID.session = new SessionObject(mySession);
		////6.0.4.0, broadcast an event instead of call functions to change the interface directly
		//this.broadcastMessage("userEvent", "onUserStart");
	//}
}
// A new function for recording the information that someone failed to get a licence slot
//v6.4.2 userObject is NOT passed to this function, it is the object!
//UserObject.prototype.failLicenceSlot = function(userObject) {
UserObject.prototype.failLicenceSlot = function() {
	// v6.5.4.3 Yiu, new code for F_ReasonCode
	var nReasonCode;
	nReasonCode = 201; // This is the 'too many concurrent users' failure

	// v6.5.4.5 There is a general licence failure function now
	_global.ORCHID.storeErrorToDB(nReasonCode, this.UserID);
	/*	
	// make a new db query
	// v6.3.6 Merge database to main
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	myTrace("in failLicenceSlot");
	
	// put the query into an XML object
	thisDB.queryString = '<query method="failLicenceSlot" ' +
				// v6.3.3 Concurrent users are also measured within a root
				'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
				// v6.3.5 APL users are also measured within a userID (it is the teacher's account)
				// v6.4.2 userObject is NOT passed to this function, it is the object!
				//'userID="' + userObject.userID + '" ' +
				'userID="' + this.userID + '" ' +
				// v6.4.2.4 Send the productCode from the licence so that different products do NOT share the same licence limit
				'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
				'errorReasonCode="' + nReasonCode + '" ' +
				'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
		}
		// nothing that you need to do
	}
	// 6.0.7.0, use runSecureQuery as we will access the connection database when calling getLicenceSlot.
	thisDB.runSecureQuery();
	*/
}

// 6.0.5.0 New method for adding a new user
// Assume that you have all the name/password/details from the register screen and 
// need to validate this combination and then add a user record and a session if ok.
// Validation includes licence slot allocation
// but this will be done by the actual database routine
// v6.5.3 Modify to allow a count to be done first, then triggering the real add
//UserObject.prototype.addNewUser = function(userObject) {
UserObject.prototype.addNewUserCheck = function(userObject) {
	myTrace("addNewUserCheck, name=" + userObject.name);
	// v6.5.3 Change back to the original, but also keep the same call before you go to registration.
	// This means you will duplicate the call, but I don't think this is a big deal.
	//v6.3.1 Total licences need to check whether you can add a new user or not
	// Frankly it would be better if you could run this check when they click 'new user' button
	// to save them from typing registration details.
	// The 'allowed' parameter is true if this check has already been made
	//UserObject.prototype.addNewUser = function(userObject, allowed) {
	// v6.5.5.0 Learner Tracking licences are counted in a different way. Also change teh name
	// v6.5.5.5 Add network as a licence type that can always add new users
	//if (_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("total") >= 0) {
	//if (	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("total") >= 0 ||
	//	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("network") >= 0 ||
	//	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("tracking") >= 0) {
	// Only LT licence needs to count users
	if (_global.ORCHID.root.licenceHolder.licenceNS.licenceType == 1) {
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		myTrace("count the licences that we have already used");

		// v6.5.6 Maybe you want to check licences across a set of accounts?
		//myTrace("groupedRoots=" + _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots);
		if (_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots!=undefined 
			&& ((_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots.indexOf(",")>0) || _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots=='*')) {
			// we should try to make sure that the list is well-formed
			if (_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots=='*') {
				rootList='*';
			} else {
				var validRoot=false;
				var rootArray = _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots.split(",");
				for (var i=0; i<rootArray.length; i++) {
					if (!isNaN(parseInt(rootArray[i])) && parseInt(rootArray[i])>=1) {
						validRoot=true;
					} else {
						rootArray[i]=0;
					}
				}
				if (validRoot) {
					var rootList = rootArray.join(",");
				} else {
					var rootList = _global.ORCHID.root.licenceHolder.licenceNS.central.root;
				}
			}
			var myRoot = rootList;
		} else {
			var myRoot = _global.ORCHID.root.licenceHolder.licenceNS.central.root;
		}
		
		// v6.5.4.6 We should change this count for non-transferable licences - so allow if titleUserCount
		// let the script work out what to do? Send productCode anyway
		// v6.5.5.0 Change the name - and also change this to secure query
		// v6.5.6 You should take account of groupedRoots in this query, just like getLicenceSlot
		//				'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
		//thisDB.queryString = '<query method="countUsers" ' +
		thisDB.queryString = '<query method="countLicencesUsed" ' +
						'rootID="' + myRoot + '" ' +
						'licences="' + _global.ORCHID.root.licenceHolder.licenceNS.licences + '" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
						// v6.5.5.0 For non-transferable licences
						'licenceStartDate="' + _global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate + '" ' +
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
						'cacheVersion="' + new Date().getTime() + '"/>';
		
		thisDB.xmlReceive = new XML();
		//myTrace("make XML from " + this.debugName);
		thisDB.xmlReceive.master = this;
		thisDB.xmlReceive.userObject = userObject;
		//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
		thisDB.xmlReceive.onLoad = function(success) {
			//myTrace("back to countUsers from asp");
			var errReceived;
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					errReceived = true;
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
					if (tN.attributes.code == '211') {
						_global.ORCHID.user.broadcastMessage("userEvent", "onLicenceFull");
					} else {
						_global.ORCHID.user.broadcastMessage("userEvent", "onNoTotalLicences");
					}
					return;
	
				// we are expecting to get back a number of existing users
				} else if (tN.nodeName == "licence") {
					// v6.5.4.1 AR copy code more directly from view.as
					//this.master.users = tN.attributes.users;
					var numUsers = Number(tN.attributes.users);
					myTrace("there are " + numUsers + " existing users.");
					
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// a successful call will have set users
			// v6.5.4.1 AR copy code more directly from view.as
			//if (this.master.users > 0 && !errReceived) {
			myTrace("licensed for " + _global.ORCHID.root.licenceHolder.licenceNS.licences);
			if (numUsers >= 0 && !errReceived) {
				//if (this.master.users < _global.ORCHID.root.licenceHolder.licenceNS.licences) {
				if (numUsers < _global.ORCHID.root.licenceHolder.licenceNS.licences) {
					myTrace(numUsers + " so cleared to add the new user " + this.userObject.name); 
					// callback to addNewUser 
					_global.ORCHID.user.addNewUser(this.userObject);
				} else {
					myTrace("no new users can be added");
					this.master.broadcastMessage("userEvent", "onNoTotalLicences");
				}
			} else {
				myTrace("no new users can be added");
				this.master.broadcastMessage("userEvent", "onNoTotalLicences");
			}
		}
		// v6.5.5.0 Change the name - and also change this to secure query
		//thisDB.runQuery();
		thisDB.runSecureQuery();
		// since you are still checking, don't go any further now
		// the rest will be done by the callback
		return;
	// v6.5 If this is a concurrent licence, just add the user
	} else {
		myTrace(_global.ORCHID.root.licenceHolder.licenceNS.licenceType + " licence, so no need to count users.");
		// callback to addNewUser 
		_global.ORCHID.user.addNewUser(userObject);
	}
}
// v6.5.3 New function for adding the user once the licence is checked
UserObject.prototype.addNewUser = function(userObject) {
	// make a new db query
	// v6.3.6 Merge database to main
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	// v6.5.4.6 For variables passed on command line
	var controlNS = _global.ORCHID.root.controlNS.master;
	
	// save the passed object
	thisDB.userObject = userObject;
	
	// v6.4.2 Also pass flag showing if this is a user who will NOT login through CE.com
	if (_global.ORCHID.programSettings.loginOption & _global.ORCHID.accessControl.ACNonCELogin) {
		var myUniqueName = 0;
	} else {
		var myUniqueName = 1;
	}
	
	// v6.5.4.5 We will pass a licenceID to be used for total licence same username checking
	// v6.5.4.7 Mac creates this with two decimal points!
	// v6.5.5.0 This is for instances, nothing to do with licences - rename
	//this.licenceID	= Math.round(new Date().getTime());
	// v6.5.5.5 If another script has started this user - then we need to pick up a passed instanceID
	if (_global.ORCHID.commandLine.instanceID!="" && _global.ORCHID.commandLine.instanceID!=undefined) {
		myTrace("use passed instanceID rather than creating a new one");
		this.instanceID = _global.ORCHID.commandLine.instanceID;
	} else {
		this.instanceID = Math.round(new Date().getTime());
	}
	
	// v6.5.2 Yiu/AR Encrypt the password if necessary. Yiu originally did this in view.as as it was picked up from the reigster screen.
	// I prefer it here 
	// a) because the other encryption code is in this module
	// b) not only register screen uses this function. If you pass a user with the appropriate actionCode, this will also be called.
	//	Since the encryption is our own we can assume that anyone who passes a password will not know ours. So even if they
	// 	have already encrypted, it will be fine for us to encrypt again for our own purpose.
	var myPassword = _global.ORCHID.user.encryptionIfLicenceForces(userObject.password);
	
	var myName;
	var myStudentID;
	var myEmail;
	
	// v6.5.4.5 If you pass a " character as an attribute, you screw the query. So convert anything that could hold one.
	// This should be common.
	//function removeQuotes(text) {
	//	return _global.ORCHID.root.objectHolder.findReplace(text, String.fromCharCode(34), "&quot;");
	//}
	myName = _global.ORCHID.root.objectHolder.safeQuotes(userObject.name);
	myStudentID = _global.ORCHID.root.objectHolder.safeQuotes(userObject.studentID);
	myPassword = _global.ORCHID.root.objectHolder.safeQuotes(myPassword);
	// If you don't have email in the object and it was passed on the command line, use that instead
	if (userObject.email==undefined && controlNS.email.length>1) {
		userObject.email = controlNS.email;
	}
	myEmail = _global.ORCHID.root.objectHolder.safeQuotes(userObject.email);
	
	// put the query into an XML object
	thisDB.queryString = '<query method="addNewUser" ' +
						'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
						'name="' +  myName + '" ' +
						//'password="' + userObject.password + '" ' +
						'password="' + myPassword + '" ' +
						'studentID="' + myStudentID + '" ' +
						'loginOption="' + _global.ORCHID.programSettings.loginOption + '" ' +
						// v6.3.5 Also need the licence type
						// v6.4.2.4 Although this is not used and seems kind of irrelevant, you shouldn't addNewUser unless Total anyway
						// v6.5.5.5 change the name
						//'licenceType="' + _global.ORCHID.root.licenceHolder.licenceNS.licencing + '" ' +
						'licenceType="' + _global.ORCHID.root.licenceHolder.licenceNS.licenceType + '" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
						// v6.4.2 Also pass flag showing if this is a user who will login through CE.com
						'uniqueName="' + myUniqueName + '" ' +
						'email="' + myEmail + '" ' +
						//'licenceID="' + this.licenceID + '" ' +
						'instanceID="' + this.instanceID + '" ' +
						// v6.5.4.6 Interesting to know how users get added to the database
						'registerMethod="' + userObject.registerMethod + '" ' +
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
						
						// v6.4.2 Not used
						// 'className="' + userObject.className + '" ' +
						// v6.4.2 Not used
						//'country="' + userObject.country + '" ' +
						//'preferences="' + userObject.preferences + '" ' +
						// 6.2.1 Windows version
						//'licences="' + _global.ORCHID.root.licenceHolder.licenceNS.licences + '" ' +
						// v6.5.4.5 No need for cacheVersion as licenceID is the same
						//'cacheVersion="' + new Date().getTime() + '"/>';
						//'/>';
						' ';
						
	// v6.5.4.6 I also need to pass any other information that came on the command line
	// We will split up the queryString here - clumsy but OK
	// validate the date first
	if (controlNS.expiryDate.length>1) {
		if (isValidDate(controlNS.expiryDate)) {
			myTrace("valid expiryDate from command line=" + controlNS.expiryDate);
			thisDB.queryString+= 'expiryDate="' + controlNS.expiryDate + '" ';
		} else {
			myTrace("invalid expiryDate from command line=" + controlNS.expiryDate);
			// We tried to pass an expiry string, but it was invalid. We should therefore set a default expiry of 3 months from now.
			var threeMonths = 91*24*60*60*1000;
			trace(new Date(new Date().getTime() + threeMonths).toString());
			thisDB.queryString+= 'expiryDate="' + dateFormat(new Date(new Date().getTime() + threeMonths)) + '" ';
		}
	}
	if (controlNS.city.length>1) thisDB.queryString+= 'city="' + controlNS.city + '" ';
	if (controlNS.country.length>1) thisDB.queryString+= 'country="' + controlNS.country + '" ';
	if (controlNS.region.length>1) thisDB.queryString+= 'region="' + controlNS.region + '" ';
	// we will have a default groupID from T_AccountRoot (getRMSettings), but it might have been overwritten by command line
	// What will happen if this groupID is not part of this root? Fail to add new user I suppose.
	// v6.5.4.7 At present the user will simply be added to the root that the group IS part of. So will effectively disappear if you get it wrong.
	// I think I'd need an extra SQL call as it isn't simple to find out which root a group is part of!
	// v6.5.6 Its much more likely to come from licence in db than the command line
	// v6.5.6 Is there a default group that we want to add new users into?
	if (_global.ORCHID.root.licenceHolder.licenceNS["defaultGroup"]) {
		thisDB.queryString+= 'groupID="' + _global.ORCHID.root.licenceHolder.licenceNS["defaultGroup"] + '" ';
	} else if (controlNS.groupID.length>1) {
		thisDB.queryString+= 'groupID="' + controlNS.groupID + '" ';
	} else {
		thisDB.queryString+= 'groupID="' + _global.ORCHID.programSettings.defaultGroupID + '" ';
	}
	thisDB.queryString+= '/>';
	
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		//myTrace("back to addNewUser from asp");
		myTrace("back to addNewUser with " + this.toString());
		// v6.3.6 Merge login into main
		var callBackModule = _global.ORCHID.root.mainHolder.loginNS;
		var errReceived;
		// 6.2.1 Windows version
		//var mySession = {}; // hold session information that we created
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				errReceived = true;
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
				if (tN.attributes.code == "206") {
					//callBackModule.userAlreadyExists();
					//6.0.4.0, broadcast an event instead of call functions to change the interface directly
					this.master.broadcastMessage("userEvent", "onUserAlreadyExists");
				} else if (tN.attributes.code == "201") {
					//callBackModule.noLicences();
					this.master.broadcastMessage("userEvent", "onNoLicences");
				}

			// we are expecting to get back a user node
			} else if (tN.nodeName == "user") {
				// success, so take the details from the passed object
				// The XML back from the database also contains this information, take your pick!
				this.master.setUserDetails(tN.attributes);
				// adding in the userID which is creted by the database
				//this.master.userID = tN.attributes.userID;
				myTrace("welcome " + this.master.name + " (" + this.master.studentID + ")");
				//delete this.master.userObject;
				
				// v6.5.4.4 Is this quite the right place to add this user to the licence table? Synch issues with MGS fields query?
				// v6.5.4.5 I think it will be better done at the same place as getLicenceSlot.
				// v6.5.4.4 block new calls for now
				//if (_global.ORCHID.projector.name != "MDM") {
				//	this.master.sendLicenceIDToDB();
				//}
				
			// v6.4.2.6 Also expecting an MGS node
			} else if (tN.nodeName == "MGS") {
				this.master.setUserMGS(tN.attributes);
				
			// 6.2.1 Windows version
			// and a licence node
			//} else if (tN.nodeName == "licence") {
			//	// parse the returned XML to get licence details
			//	mySession.licenceHost = tN.attributes.host;
			//	mySession.licenceID = tN.attributes.ID;
			//	mySession.licenceNote = tN.attributes.note;
			//	myTrace("your licence is " + mySession.licenceHost+":"+mySession.licenceID + " (" + mySession.licenceNote + ")");

			// 6.0.6.0 Sessions will be added ONLY after choosing a course as they are course specific
			// and a session node
			/*
			} else if (tN.nodeName == "session") {
				// parse the returned XML to get licence details
				// these details are saved in the user and session object
				// the users number of sessions is user information
				this.master.sessionCount = tN.attributes.count;
				//this session id and start time is session information
				mySession.sessionID = tN.attributes.id;
				//mySession.startTime = tN.attributes.startTime;
				//myTrace("sessions=" + this.master.sessionCount);
			*/
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call will have set userID
		if (this.master.userID > 0 && !errReceived) {
			//myTrace("successful call");
			// 6.2.1 Windows version
			//_global.ORCHID.session = new SessionObject(mySession);
			//callBackModule.userStarted()
			//6.0.4.0, broadcast an event instead of call functions to change the interface directly
			// 6.2.1 Windows version
			//this.master.broadcastMessage("userEvent", "onUserStart");
			_global.ORCHID.user.getLicenceSlot(this.master);
		}
	}
	//thisDB.runQuery();
	// 6.0.7.0, use runSecureQuery as we will access the connection database when calling addNewUser.
	// 6.2.1 Windows version
	//myTrace("call runQuery")
	thisDB.runQuery();
}

// v6.3 Function for getting all users - for teacher reporting
// v6.5.4.5 Not used anymore
/*
UserObject.prototype.getAllUsers = function() {

	// prepare the common storage
	_global.ORCHID.user.userList = new Array();

	// make a new db query
	// v6.3.6 Merge database to main
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	//myTrace("in getAllUsers");
	
	// v6.5.4.3 Yiu, add today into the query and check the expiry
	var dateToday:Date;
	dateToday= new Date();

	// put the query into an XML object
	thisDB.queryString = 	'<query method="getUsers" ' +
				'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
				'cacheVersion="' + dateToday.getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				errReceived = true;
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// we are expecting to get back a lot of user nodes
			} else if (tN.nodeName == "user") {
				// parse the returned XML to get user details
				// ignore the teacher (and anyone else special)
				// v6.3.6 This is now done with userType rather than special userIDs
				//if (tN.attributes.ID > 1) {
				if (tN.attributes.userType == 0) {
					myTrace("got user id=" + tN.attributes.ID + " name=" + tN.attributes.name);
					_global.ORCHID.user.userList.push({userID:tN.attributes.ID, userName:tN.attributes.name});
				}
				
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call needs to tell the user object that all is now well
		// then callback to the place where the user object was first created
		// to say that the user is now loaded
		_global.ORCHID.user.onLoad();
	}
	thisDB.runQuery();
}
*/
// 6.0.6.0 New method for getting scratch pad
// Assume that you have the userID, only complication in this is to do with MEMO/BLOB datatypes
// and any problems about transferring large data back/forwards to Flash
UserObject.prototype.getScratchPad = function() {

	// make a new db query
	// v6.3.6 Merge database to main
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	//myTrace("in getScratchPad");
	
	// put the query into an XML object (we already know the current user's ID)
	thisDB.queryString = '<query method="getScratchPad" ' +
						'userID="' + this.userID + '" ' +
						'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		//myTrace("back to getScratchPad from asp");
		//myTrace(this.toString());
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
				//6.0.4.0, broadcast an event instead of call functions to change the interface directly
				// 6.0.6.0 can we call this even from another place, such as here?
				if (tN.attributes.code == "203") {
					//callBackModule.noSuchUser();
					this.master.broadcastMessage("userEvent", "onNoSuchUser");
				}

			// we are expecting to get back a scratch pad node
			} else if (tN.nodeName == "scratchPad") {
				// parse the returned XML
				//myTrace("your pad=" + tN.firstChild.nodeValue);
				this.master.scratchPad = tN.firstChild.nodeValue;
				
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call will have ...
		// and will call ...
		this.master.broadcastMessage("userEvent", "onLoadScratchPad");
	}
	// v6.3.5 Use split query to allow for anonymous users in APL
	//thisDB.runQuery();
	thisDB.runSplitQuery();
}
// 6.0.6.0 New method for getting scratch pad
// Assume that you have the userID, only complication in this is to do with MEMO/BLOB datatypes
// and any problems about transferring large data back/forwards to Flash
UserObject.prototype.setScratchPad = function() {

	// make a new db query
	// v6.3.6 Merge database to main
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	//myTrace("in setScratchPad");
	
	// put the query into an XML object (we already know the current user's ID)
	// Since you might be sending heaps of data, we cannot use attributes, so this
	// XML query string is rather different from others
	thisDB.queryString = '<query method="setScratchPad" ' +
						'userID="' + this.userID + '" ' +
						'cacheVersion="' + new Date().getTime() + '">' + 
	// v6.3 Need to use CDATA and convert to html otherwise PHP strips all white space
					this.scratchPad + "</query>";
	//				'<![CDATA[' + this.scratchPad + ']]></query>';
	
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		//myTrace("back to setScratchPad from asp");
		//myTrace('setScratchPad=' + this.toString());
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
				//6.0.4.0, broadcast an event instead of call functions to change the interface directly
				// 6.0.6.0 can we call this even from another place, such as here?
				if (tN.attributes.code == "203") {
					//callBackModule.noSuchUser();
					this.master.broadcastMessage("userEvent", "onNoSuchUser");
				}

			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call will have ...
		// and will call ...
	}
	// v6.3.5 Use split query to allow for anonymous users in APL
	//thisDB.runQuery();
	thisDB.runSplitQuery();
}

// v6.5.4.3 Yiu, send IP Addresss and LicenceIDToDB to prevent people login with same Username / studentID twice
// Except, why not simply do all of this as part of startUser?
/*
UserObject.prototype.sendLicenceIDToDB = function() {
	
	var strLicenceID:String;
	strLicenceID	= new Date().getTime().toString();
	// save the licence id for later use for checking
	this.licenceID	= strLicenceID;

	var thisDB;
	thisDB = new _global.ORCHID.root.mainHolder.dbQuery();

	// No need for a cacheVersion since licenceID will be unique
	thisDB.queryString = '<query method ="setLicenceID" ' +
				'userID		="' + _global.ORCHID.user.userID + '" ' + 
				'licenceID	="' + strLicenceID + '"/>';
				
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		myTrace("back to sendLicenceID with " + this.toString());
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// anything we didn't expect?
			} else {
				//myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// This is code that you can now run
		myTrace("total licence, so start this user");
		var mySession = {}; // hold session information that we created
		mySession.licenceID = undefined;
		mySession.licenceNote = "total";
		_global.ORCHID.session = new SessionObject(mySession);
		//6.0.4.0, broadcast an event instead of call functions to change the interface directly
		this.broadcastMessage("userEvent", "onUserStart");

	}
	thisDB.runSecureQuery()
}
*/

// v6.5.4.3 Yiu, compare licence ID with the DB one, prevent people login twice
// wherever you call this from, it will throw up the error.
// v6.5.5.0 This is not a licence it is an instance - rename
//UserObject.prototype.compareLicenceIDWithDB = function() {
UserObject.prototype.compareInstanceIDWithDB = function() {
	// v6.5.4.5 For anonymous users you can't do this. What about AA instances?
	// v6.5.4.5 Since this is only relevant for dbVersion 2 or more, can we stop the call right here?
	//myTrace("compareInstanceIDWithDB for userID=" + this.userID);
	if (this.userID>0 && _global.ORCHID.programSettings.databaseVersion>1) {
		myTrace("compareInstanceIDWithDB, current=" + this.instanceID);
		var thisDB;
		thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		// v6.6 Need to send productCode as well now as instance allows multiple products
		// v6.6 Also send rootID in case you have any special account processing to take care of
		thisDB.queryString ='<query method="getInstanceID" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
						'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' + 
						'userID ="' + this.userID + '"/>';
					//'instanceID ="' + this.instanceID + '"/>';
					
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		thisDB.xmlReceive.onLoad = function(success) {
			//myTrace("back to getInstanceID with " + this.toString());
			var objTargetNode
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
	
				// we are expecting a instance node
				} else if (tN.nodeName == "instance") {
					if (this.master.instanceID == tN.attributes.id) {
						myTrace("instance ID in db and program match, so you are you!");
						// once you have tested, keep going with the exercise creation
						// v6.5.5.1 Go back to a later stage to allow more time for write score query to run
						//_global.ORCHID.root.mainHolder.creationNS.continueCreateExercise();
						_global.ORCHID.root.mainHolder.creationNS.continueProcessExerciseXML();
					} else {
						// v6.5.4.7 This should trigger a failed session record
						_global.ORCHID.storeErrorToDB('210', this.master.userID);
						errObj = {literal:"InstanceIDNotMatched", detail: "Someone else has just logged in to this program with your name or ID. Only one person can use the same login name at once. Please ask your administrator to help you change your password to protect your account."};
						_global.ORCHID.root.controlNS.sendError(errObj)
					}
					
				// anything we didn't expect?
				} else {
					//myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
		}
		thisDB.runSecureQuery();
		// You could start a timer here that will keep the code going if this query never returns (see AP bug 1444)
		// It would need to kill the above onLoad function at the same time. In the end you must find an architected way to handle multiple queries.
		
	} else {
		myTrace("old database, or anon user so no instance comparison");
		// v6.5.5.1 Go back to a later stage to allow more time for write score query to run
		//_global.ORCHID.root.mainHolder.creationNS.continueCreateExercise();
		_global.ORCHID.root.mainHolder.creationNS.continueProcessExerciseXML();
	}
}

// v6.5.4.5 this is just for course hiding. Unit/Exercise hiding is done in the scaffold
// v6.5.4.7 Now it is kept for all.
UserObject.prototype.getCourseHiddenContent = function(){
	this.hiddenContent = new Array();
	
	// v6.5.4.5 Just until you write a null call in the projector
	// v6.5.4.7 And you never hide content from teachers at all, so skip altogether
	//if(_global.ORCHID.commandLine.scripting.toLowerCase() != "projector") {
	// v6.5.6.2 You also can't have hiddenContent for AA licences as you have no group! Use userID=-1 to test for this as this covers anonymous entry to an LT licence too.
	// if(_global.ORCHID.user.userType==0 && _global.ORCHID.commandLine.scripting.toLowerCase() != "projector") {
	if(_global.ORCHID.user.userType==0 && 
		_global.ORCHID.user.userID>0 &&
		_global.ORCHID.commandLine.scripting.toLowerCase() != "projector") {
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		
		// put the query into an XML object (we already know the current user's ID)
		//thisDB.queryString = '<query method="getCourseHiddenContent" ' +
		// v6.5.4.7 We are going to get all hidden content for this product in one go since we need it all to check the courses
		thisDB.queryString = '<query method="getHiddenContent" ' +
							'groupID="' + this.groupID + '" ' +
							'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
							// pass the database version that you read during getRMSettings
							'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
							'cacheVersion="' + new Date().getTime() + '"/>';
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		thisDB.xmlReceive.onLoad = function(success) {
			//myTrace("back to courseHiddenContent with " + this.toString());
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
	
				// we are expecting to get back UID nodes
				} else if (tN.nodeName == "UID") {
					// add each node to our hiddenContent array (an id and eF)
					//myTrace("hiddenContentUID: " + tN.attributes.id + " (eF=" + tN.attributes.enabledFlag + ")");
					// v6.5.4.7 Make this an associative array instead
					//var hiddenContentObj = new Object();
					//hiddenContentObj.id = tN.attributes.id;
					//hiddenContentObj.enabledFlag = tN.attributes.enabledFlag;
					//this.master.hiddenContent.push(hiddenContentObj);
					this.master.hiddenContent[tN.attributes.id] = tN.attributes.enabledFlag;
					
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// a successful call will have ...
			// and will call ...
			//myTrace("saved hiddenContent.length=" + this.master.hiddenContent.length);
			this.master.broadcastMessage("userEvent", "onHiddenContentLoaded");
		}
		thisDB.runQuery();
	} else {
		this.broadcastMessage("userEvent", "onHiddenContentLoaded");
	}
}
// v6.5.5.7 add by wei
// Get the edited exercise information from DB T_EditedContent table.
UserObject.prototype.getCourseEditedContent = function(){
	this.editedContent = new Array(); // store edited exercise information
	this.editedMenuFileArray = new Array(); // store different groups' menu xml

	// v6.5.6.2 You can't have editedContent for AA licences as you have no group! Use userID=-1 to test for this as this covers anonymous entry to an LT licence too.
	// v6.5.6.4 And for the old network version
	//if(_global.ORCHID.user.userID==-1) {
	if (_global.ORCHID.user.userID==-1 ||
		_global.ORCHID.commandLine.scripting.toLowerCase() == "projector") {
		// Do you have to trigger anything to run?
		return;
	}

	// Define editedContent Object
	// v6.5.6 AR add in group name for branding
	//this.EditedObject = function(uid, relatedid, groupid, modeflag, subFolder){
	this.EditedObject = function(uid, relatedid, groupid, modeflag, subFolder, groupName){
		this._id = uid;
		this._groupid = groupid;
		this._relatedid = relatedid;
		this._modeflag = modeflag;
		var eFolders = _global.ORCHID.commandLine.MGSRoot.split("/");
		// v6.5.6 AR TODO: This is very specific to the CE.com installation.
		// And it is also wrong if the current product is AP and the content location isn't the same as the prefix...
		var eFolder = "../../../../../" + eFolders[eFolders.length-1];
		this._path = eFolder + "/" + _global.ORCHID.commandLine.prefix + "/Courses/" + subFolder + "/Exercises/";
		this._mediaPath = eFolder + "/" + _global.ORCHID.commandLine.prefix + "/Courses/" + subFolder + "/Media/";
		_global.myTrace("Edited content path is " + this._path + " for " + groupName);
		this._caption = "";
		// v6.5.6 I would like to display the group name so users know who did the editing
		this._groupName = groupName;
	}
	
	// get the edited exercise's caption from edited content menu.xml
	this.setCaptions = function(menuXML, groupid){
		var caption:String;
		for(var item in this.editedContent){
			//myTrace("group id = " + groupid + " : item._groupid = " + this.editedContent[item]._groupid);
			if(groupid == this.editedContent[item]._groupid){
				var UID = this.editedContent[item]._id;
				var mappedIds = UID.split(".");
				var exerciseID = mappedIds[3];
				//myTrace("current menu xml is " + menuXML.toString());
				for (var v1 = 0; v1 < menuXML.firstChild.childNodes.length; v1++) {
					//myTrace("setCaption: first loop");
					var nCurNodeForFirstLoop = menuXML.firstChild.childNodes[v1];
					for (var v2 = 0; v2 < nCurNodeForFirstLoop.childNodes.length; v2++) {
						//myTrace("setCaption: second loop");
						var nCurNodeForSecondLoop = nCurNodeForFirstLoop.childNodes[v2];
						//myTrace("setCaption: compare id is " + nCurNodeForSecondLoop.attributes["id"]);
						if(exerciseID == nCurNodeForSecondLoop.attributes["id"]){
							caption = unescape(nCurNodeForSecondLoop.attributes["caption"]);
							myTrace("setCaption: _caption is " + caption);
							break;
						}
					}
					if(caption <> null){
						this.editedContent[item]._caption = caption;
						break;
					}
				}
				//myTrace("setCaption: caption is " + this.editedContent[item]._caption);
			}
		}
	}
	
	// Query edited content from DB, and push them into edited content array.
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	thisDB.queryString = '<query method="getEditedContent" ' +
								'groupID="' + this.groupID + '" ' +
								'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
								'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
								'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		if(success){
			myTrace("Edited content is: \r" + this.toString());
			// The course.xml for edited content is based on prefix which is related with rootid, not related to group id,
			// so we only need load course.xml once.
			// v6.5.6 AR For AP (only) it should be based on the F_ContentLocation on T_Accounts which MIGHT be different.
			// v6.5.6 Now we load the course.xml even if there is no edited content, which is not only silly, but will probably fail as there will be no course.xml.
			if (_global.ORCHID.root.licenceHolder.licenceNS.productCode==1) {
				var eCourseXMLFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.content) + "course.xml";
			} else {
				var eCourseXMLFile = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.MGSRoot) + _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.prefix) + "course.xml";
			}
			var editedCourseXML = new XML();
			editedCourseXML.master = this;
			editedCourseXML.ignoreWhite = true;
			editedCourseXML.onLoad = function(success) {
				if (success) {
					myTrace("Load edited course xml success!");
					//v6.5.6.6 One problem is that a 404 error is considered success in that data has appeared...
					// In that case, this.master seems to still be the getEditedContent response XML.
					for (var node in this.master.firstChild.childNodes) {
						var tN = this.master.firstChild.childNodes[node];
						if (tN.nodeName == "err") {
							myTrace("Error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
						} else if (tN.nodeName == "UID") {
							this.ownGroup = tN.attributes.groupid;
							this.groupName = tN.attributes.groupname;
							this.id = tN.attributes.id;
							this.relatedid = tN.attributes.relatedid;
							this.modeflag = tN.attributes.modeflag;
							this.iteration = tN.attributes.iteration;
							this.subFolder = "";
							// Get sub folder via group id
							for (var node in this.firstChild.childNodes) {
								var tsN = this.firstChild.childNodes[node];
								if ( tsN.attributes.groupID == this.ownGroup
									&& (tsN.attributes.author == "from Results Manager"
										|| tsN.attributes.author == "from%20Results%20Manager")){
									//myTrace("Got subFolder is " + tsN.attributes.subFolder); 
									this.subFolder = tsN.attributes.subFolder;
									break;
								}
							}
							// If the same group menu xml is not load before, then load it.
							if(this.master.master.editedMenuFileArray[this.ownGroup] == null){
								this.master.master.editedMenuFileArray[this.ownGroup] = "loading...";
								// Get the related edited folder menu xml.
								myTrace("this sub folder is " + this.subFolder);
								var eMenuXMLFile = _global.ORCHID.commandLine.MGSRoot + "/" + _global.ORCHID.commandLine.prefix + "/Courses/" + this.subFolder + "/menu.xml";
								myTrace("Try to load group menu file :" + eMenuXMLFile);
								
								// load the edited menu xml to set related exercise's caption. 
								var editedMenuXML = new XML();
								editedMenuXML.master = this;
								editedMenuXML.ignoreWhite = true;
								editedMenuXML.ownGroup = this.ownGroup;
								editedMenuXML.onLoad = function(success){
									if(success){
										myTrace("Load group " + this.ownGroup + " edited menu xml : " + this.toString());
										this.master.master.master.editedMenuFileArray[this.ownGroup] = this;
										this.master.master.master.setCaptions(this, this.ownGroup);
									}else{
										myTrace("load group " + this.ownGroup + " edited menu xml failed!!!");
									}
								}
								editedMenuXML.load(eMenuXMLFile);
							}

							// v6.5.6 AR add group name back from SQL
							//var ed = new this.master.master.EditedObject(this.id, this.relatedid, this.ownGroup, this.modeflag, this.subFolder);
							var ed = new this.master.master.EditedObject(this.id, this.relatedid, this.ownGroup, this.modeflag, this.subFolder, this.groupName);
							this.master.master.editedContent.push(ed);
						} else {
							myTrace("The following node is not parsed" + tN.nodeName + ": " + tN.firstChild.nodeValue)
						}
					}
				}else{
					myTrace("Load edited course xml failed!!!");
				}
			}
			myTrace("Try to load group course xml : " + eCourseXMLFile);
			editedCourseXML.load(eCourseXMLFile);
		}else{
			myTrace("Get edited content failed!!!");
		}
	}
	thisDB.runQuery();
}

// v6.5.4.3 Yiu, putting things in T_FailSession
_global.ORCHID.storeErrorToDB= function(nErrorReasonCode, nUserID) {
	var bIsNetworkVersion:Boolean;
	//bIsNetworkVersion	=  _global.ORCHID.commandLine.scripting.toLowerCase() == "projector";
	bIsNetworkVersion =  _global.ORCHID.projector.name == "MDM";
	if(bIsNetworkVersion)
		return;
	
	if(nUserID == undefined)
		nUserID = _global.ORCHID.user.userID;
	var dateNow:String;
	dateNow = dateFormat(new Date()); 

	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	thisDB.queryString =	'<query method	="failSession" ' +
				'rootID		="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' + 
				'userID		="' + nUserID + '" ' + 
				'productCode	="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' + 
				'errorReasonCode="' + nErrorReasonCode + '" ' + 
				'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
				'dateStamp	="' + dateNow + '"/>';
				
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		var objTargetNode
		for (var node in this.firstChild.childNodes) {
			objTargetNode = this.firstChild.childNodes[node];
			myTrace("back from failLogin with " + objTargetNode.toString());
			// nothing to do for this return
			//if (objTargetNode.nodeName == "err") {
			//}
		}
	}
	// v6.5.4.5 This goes through the licenceQuery pages
	thisDB.runSecureQuery();
}

// ===========
// 6.0.6.0 NOT USED
// ===========
/*
// look up user details from the database, fill out the structure and return index
// ** this is a sample database read ** //
// Before this method is called, the userObject will have had a onReturnCode function
// defined.
// Then if the call is immediate, we can callback to this from here. But if it is not,
// then we use the global database interface to do this callback for us. All we need to
// do here is initialise it.
UserObject.prototype.readDB = function(myName) {
	// first link to the global database interface object which holds my current connection
	var thisDB = _global.ORCHID.dbInterface;
	// find out what the connection method is as this call knows how to read in different
	// ways
	var dbMethod = thisDB.getWriteMethod();
	//trace("in readDB with " + dbMethod);
	if (dbMethod == "sharedObject") {
		// the shared Object is referenced as a simple object
		var me = thisDB.dbSharedObject.data.user;
		if (me eq null || me eq undefined) {
			// trigger the callback with null to show the call failed
			this.onReturnCode(null); 
		} else {
			for (var i in me) {
				//trace("checking " + me[i].name);
				if (me[i].name eq myName) {
					//trace("found them");
					if (me[i].userID eq undefined) me[i].userID = i;
					//trace("in gUD and found " + me[i].name);
					// trigger the callback direct as this is synchronous
					this.onReturnCode(me[i]);
					return;
				}
			}
			// trigger the callback with a null userID to show the user was not found
			this.onReturnCode({userID:null}); 
			return;
		}
	} else if (thisDB.getWriteMethod() eq "webServer") {
		// other types of db call will use other callback techniques
		// webserver can use LoadVars to do it
	} else if (thisDB.getWriteMethod() eq "flashStudioPro") {
		thisDB.dbInitialise(this);
		// now call database FSCOMMAND
		// then start a function that will check to see when the FSCOMMAND has finished
		myCheck = function() {
			if (someTest) {
				if (thisInterval >= 0) clearInterval(thisIntervalID);			
				thisDB.dbReturnObject = xx;
				thisDB.dbReturnCode = true;
			}
		}
		thisIntervalID = setInterval(myCheck, 500);
	}
}
// write out the current object to the database and return the index number
UserObject.prototype.writeOut = function() {
	// first link to the global database interface object which holds my current connection
	var thisDB = _global.ORCHID.dbInterface;
	// find out what the connection method is as this call knows how to read in different
	// ways
	var dbMethod = thisDB.getWriteMethod();
	//trace("in user writeOut with " + dbMethod);
	if (dbMethod eq "sharedObject") {
		// first see if this user already exists
		var me = thisDB.dbSharedObject.data;
		// assume that if you know the userID then you have read this from the database
		if (this.userID eq null || this.userID eq false || this.userID eq undefined) {
			// add the new record and return the new ID
			var newID = me.user.push(this) - 1;
			me.user[newID].userID = newID;
			this.userID = newID;
			myTrace("add record " + newID + " for " + this.name);
		} else {
			// update the record
			myTrace("update record " + this.userID + " for " + this.name);
			me.user[this.userID] = this;
		}
		// trigger the callback with the ID to show the call succeeded
		this.onReturnCode(this.userID); 
	}
};
// Hmmm, not sure about this - not currently used anyway
UserObject.prototype.readAllUsers = function() {
	//trace("in readAllUsers");
	if (_global.ORCHID.dbInterface.getWriteMethod() eq "sharedObject") {
		var me = dbSharedObject.data.user;
		var allUsers = [];
		for (var i in me) {
		//	myTrace("user=" + me[i].userName);
			allUsers.push(me[i]);
		}
		return allUsers;
	}
};
UserObject.prototype.deleteUser = function(myName) {
	// make sure you also clear out the progress stuff for this user
	// also, how to synch the user[] index and the userID, if at all?
};

// method for writing out the object as a string (mostly used for trace or logs)
UserObject.prototype.toString = function() {
	return this.userID+"="+this.name+" ["+this.password+"] "+this.email;
};
*/

// *****
// SESSION object
// *****
function SessionObject(myObject) {
	// if you pass an object with some properties, set them to the session 
	// before the session is created, data will be in various places
	// we collect it here for easier use and access
	// 6.0.5.0 this should stay in the user object
	//if (myObject.userID eq undefined) {
	//	this.userID = _global.ORCHID.user.userID;
	//	//trace("use global userID=" + this.userID);
	//} else {
	//	this.userID = myObject.userID;
	//}
	// 6.0.5.0 it is quite likely that the course name is not set when you make
	// this object, so you must remember to set it later.
	// v6.3.5 The session database is now saving courseID rather than courseName
	if (myObject.courseName == undefined) {
		//myTrace("create session object with courseName=" + _global.ORCHID.course.scaffold.caption);
		this.courseName = _global.ORCHID.course.scaffold.caption;
	} else {
		this.courseName = myObject.courseName;
	}
	if (myObject.courseID == undefined) {
		//myTrace("create session object with courseID=" + _global.ORCHID.course.id);
		this.courseID = _global.ORCHID.course.id;
	} else {
		this.courseID = myObject.courseID;
	}
	if (myObject.startTime == undefined) {
		this.startTime = new Date();
	} else {
		this.startTime = myObject.startTime;
	}
	if (myObject.licenceHost == undefined) {
		this.licenceHost = "";
	} else {
		this.licenceHost = myObject.licenceHost;
	}
	if (myObject.licenceID == undefined) {
		this.licenceID = "";
	} else {
		this.licenceID = myObject.licenceID;
	}
	if (myObject.licenceNote == undefined) {
		this.licenceNote = "";
	} else {
		this.licenceNote = myObject.licenceNote;
	}
	if (myObject.sessionID == undefined) {
		this.sessionID = -1;
	} else {
		this.sessionID = myObject.sessionID;
	}

	// v6.5.4.3 Yiu, store the startSession time for duration calculation	
	//v6.5.4.5 Not used anymore
	//this.nStartSessionTime	= 0;
}
// this method figures out how to write out the object and does it
// it returns the total number of records for this user
// ===========
// 6.0.6.0 NOT USED
// ===========
/*
SessionObject.prototype.writeOut = function() {
	// first link to the global database interface object which holds my current connection
	var thisDB = _global.ORCHID.dbInterface;
	// find out what the connection method is as this call knows how to read in different
	// ways
	var dbMethod = thisDB.getWriteMethod();
	//trace("in session writeOut with user=" + this.userID + " and course=" + this.courseName);
	if (dbMethod eq "sharedObject") {
		// first see if this user already exists
		var me = thisDB.dbSharedObject.data.progress;
		var progIdx = -1;
		for (var i in me) {
			//trace("session=" + i + " user=" + me[i].userID + " course=" + me[i].courseName);
		}
		for (var i in me) {
			if (me[i].userID eq this.userID && me[i].courseName eq this.courseName) {
				progIdx = i;
				break;
			}
		}
		//trace("session records show progIdx=");
		// if this user has already run a session with this course, just add a new one
		if (progIdx >= 0) {
			var sessionNum = me[progIdx].sessionRecords.push(this);
			myTrace("added a new session " + sessionNum);
		} else {
			// this is a first, so create a new progress group
			var progObj = {userID:this.userID, courseName:this.courseName, sessionRecords:[this], scoreRecords:[]};
			me.push(progObj);
			var sessionNum = 1;
			progIdx = 0;
			myTrace("added a brand new session " + this.toString());
		}
		// store the progress index so that you can get to it quickly as you need to a lot
		this.progressIdx = progIdx;
		this.numOfSessions = sessionNum;
		myTrace("your progress index is " + this.progressIdx + " and sessionNum=" + sessionNum);
		// trigger the callback
		this.onReturnCode(); 
	}
};
*/
// method for writing out the object as a string (mostly used for trace or logs)
SessionObject.prototype.toString = function() {
	return this.userID+", "+this.courseName+" started at "+this.startTime + " (progIdx=" + this.progressIdx + ")";
};
// 6.0.5.0 New method for holding on to the licence slot
SessionObject.prototype.holdLicence = function() {

	//v6.3.1 Total licences don't have slots
	// v6.5.4.6 Or more to the point, concurrent licences do
	// v6.5.5.5 Add network as a licence type
	// v6.5.5.5 Change name
	//if (	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("concurrent") >= 0 ||
	//	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("network") >= 0) {
	if (	_global.ORCHID.root.licenceHolder.licenceNS.licenceType == 2 ||
		_global.ORCHID.root.licenceHolder.licenceNS.licenceType == 3) {

		// make a new db query
		// v6.3.6 Merge database to main
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		//myTrace("in holdLicence for " + this.licenceHost + " (" + this.licenceID + ")");
		
		// put the query into an XML object
		thisDB.queryString = '<query method="holdLicence" ' +
							'licenceID="' + this.licenceID + '" ' +
							'licenceHost="' + this.licenceHost + '" ' +
							'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
							'cacheVersion="' + new Date().getTime() + '"/>';
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
		thisDB.xmlReceive.onLoad = function(success) {
			//myTrace("back to holdLicence from asp");
			//myTrace(this.toString());
			// v6.3.6 Merge login into main
			var callBackModule = _global.ORCHID.root.mainHolder.loginNS;
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
					if (tN.attributes.code == "203") {
						// v6.5.5.1 But I don't have this function! Nothing happens if you lose your licence.
						callBackModule.lostLicence();
					}
	
				// there is probably no need to send anything back
				// and a licence node
				} else if (tN.nodeName == "licence") {
					// parse the returned XML to get licence details
					// licence details are saved in the session object
					//mySession.licenceHost = tN.attributes.host;
					//mySession.licenceID = tN.attributes.ID;
					//mySession.licenceNote = tN.attributes.note;
					myTrace("your licence is " + tN.firstChild.nodeValue + " (" + tN.attributes.ID + ")");
	
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue);
				}
			}
			// there is probably no need to send anything back
			callBackModule.licenceHeld();
		}
		//thisDB.runQuery();
		// 6.0.7.0, use runSecureQuery as we will access the connection database when calling holdLIcence.
		thisDB.runSecureQuery();
	} else {
		// v6.3.6 Merge login into main
		_global.ORCHID.root.mainHolder.loginNS.licenceHeld();
	}
}
// 6.2.1 Windows version - new method for dropping licence at exit
// Surely it would be quicker to include this function in stopUser to save an extra db call?
SessionObject.prototype.dropLicence = function() {

	//v6.3.1 Total licences don't have slots
	// v6.5.5.5 Add network as a licence type
	// v6.5.5.5 Change name
	//if (	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("concurrent") >= 0 ||
	//	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("network") >= 0) {
	if (	_global.ORCHID.root.licenceHolder.licenceNS.licenceType == 2 ||
		_global.ORCHID.root.licenceHolder.licenceNS.licenceType == 3) {
		// make a new db query
		// v6.3.6 Merge database to main
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		myTrace("in dropLicence for " + this.licenceHost + " (" + this.licenceID + ")");
		
		// put the query into an XML object
		thisDB.queryString = '<query method="dropLicence" ' +
							'licenceID="' + this.licenceID + '" ' +
							'licenceHost="' + this.licenceHost + '" ' +
							'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
							'cacheVersion="' + new Date().getTime() + '"/>';
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
		thisDB.xmlReceive.onLoad = function(success) {
			myTrace("back to dropLicence from db with " + this.toString());
			var callBackModule = _global.ORCHID.root.controlNS;
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
					if (tN.attributes.code == "203") {
						callBackModule.lostLicence();
					}
	
				// there is probably no need to send anything back
				// and a licence node
				} else if (tN.nodeName == "licence") {
					myTrace("your licence was " + tN.firstChild.nodeValue + " (" + tN.attributes.ID + ")");
	
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// trigger the event to say that the user has been stopped
			myTrace("ready to go for final stage of exit from " + callBackModule);
			callBackModule.startExit()
		}
		thisDB.runSecureQuery();
	} else {
		_global.ORCHID.root.controlNS.startExit()
	}
}
// 6.0.5.0 New method for clearing up at the end of a run
// 6.2.1 Windows version
// changed as no longer mix up licence and connection functions
SessionObject.prototype.exit = function() {

	// make a new db query
	// v6.3.6 Merge database to main
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	myTrace("in exit for licence " + this.licenceHost + " (" + this.licenceID + ")");

	// v6.5.1 Just in case some audio was still playing away
	_global.ORCHID.root.jukeboxHolder.myJukeBox.clearAll();
	// and it wasn't in the jukebox!
	stopAllSounds();

	// put the query into an XML object
	// v6.5.4.5 No need to do this, just work out in script
	//var nEndSessionTime:Number;
	//nEndSessionTime	= new Date().getTime();
	//var nDurationInSec:Number;
	//nDurationInSec	= this.getSessionDuration(nEndSessionTime);

	thisDB.queryString = '<query method="stopUser" ' +
						'sessionID="' + this.sessionID + '" ' +
						// 6.2.1 Windows version
						// v6.5.5.3 Added information to this call to avoid having to call dropLicence too.
						'licenceID="' + this.licenceID + '" ' +
						'licenceHost="' + this.licenceHost + '" ' +
						// v6.4.2 Pass local time to the database
						'datestamp="' + dateFormat(new Date()) + '" ' +
						//'duration="' + nDurationInSec + '" ' +
						// pass the database version that you read during getRMSettings
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
						'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		myTrace("back to session.exit from stopUser query");
		//myTrace(this.toString());
		var callBackModule = _global.ORCHID.root.controlNS;
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// there is probably no need to send anything back
			// and a licence node
			// 6.2.1 Windows version
			//} else if (tN.nodeName == "licence") {
				// parse the returned XML to get licence details
				// licence details are saved in the session object
				//mySession.licenceHost = tN.attributes.host;
				//mySession.licenceID = tN.attributes.ID;
				//mySession.licenceNote = tN.attributes.note;
				//myTrace("your licence is " + tN.firstChild.nodeValue + " (" + tN.attributes.ID + ")");

			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// let the calling module know that this task is done
		// 6.2.1 Windows version
		//callBackModule.userStopped()
		// If you are running on CE.com, the db calls are updated so that stopUser also does dropLicence stuff
		// but if you are running anywhere else this won't be the case. Base it on databaseVersion
		if (_global.ORCHID.programSettings.databaseVersion>4) {
			myTrace("new code, so stopUser has already done dropLicence");
			_global.ORCHID.root.controlNS.startExit();
		} else {
			_global.ORCHID.session.dropLicence();
		}
	}
	//thisDB.runQuery();
	// 6.2.1 Windows version
	thisDB.runQuery();
}
// 6.0.6.0 New method for inserting a session record - called when a course is chosen
// v6.5.5.5 Start recording session by title rather than course - for now I can leave this like this and get both.
SessionObject.prototype.startSession = function() {
	// v6.3.4 If you have come from SCORM, the default behaviour is to ignore our own progress reporting
	// v6.5.3 I think that I now want it in both if we are running through SCORM, also we have enabled our own progress button
	//if (_global.ORCHID.commandLine.scorm) {
	//	// so all you have to do is report that this bit is finished. Since there are to scores,
	//	// you might be able to skip this bit, but no big deal if you don't.
	//	_global.ORCHID.root.controlNS.setProgress();
	//} else {
		// v6.3 For large score databases 'getScores' is the start of long processing
		// so although you can't use tlc to break the processing (no loops) - you can at
		// least show the progress bar straight away. But if I put this into too close to
		// the call it seems not to get shown anyway. This seems to be a reasonable place.
		//myTrace("show the progress bar");
		// I am not sure that this works at all - due to not really loading the movie until next frame
		/*
		var myController = _global.ORCHID.root.createEmptyMovieClip("tlcController", _global.ORCHID.loadingDepth);
		if(_global.ORCHID.online){
			var cacheVersion = "?version=" + new Date().getTime();
		}else{
			var cacheVersion = ""
		}
		myController.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + "onEnterFrame.swf" + cacheVersion);
		// v6.3.1 Pickup progress bar location from buttons swf
		if (_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar != undefined) {
			myController._x =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._x;
			myController._y =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._y;
		} else {
			myController._x = myController._y = 5;
		}
		//_global.ORCHID.tlc = {timeLimit:1000, maxLoop:10, i:0, proportion:100, startProportion:0};
		//_global.ORCHID.tlc.controller = myController;
		*/
		// v6.3.5 Overriden by screen based positioning
		/*
		if (_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar != undefined) {
			myController._x =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._x;
			myController._y =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._y;
			// v6.3.4 If the progress bar is not 100% fonts will be funny, so until you can 
			// set their xscale correctly to 100%, just hide them
			myController._width =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._width;
			myController._height =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._height;
			//if (_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._xscale != 100) {
			//	myTrace("hiding progress bar font as scaling=" + _global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._xscale);
			//	myController.enableLabel(false);
			//}
		} else {
			myController._x = myController._y = 5;
		}
		*/
		var myController = _global.ORCHID.root.tlcController;
		myController.setPercentage(15);
		//myController.setLabel("getting scores");
		myController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadScores", "labels"));
		myController.setEnabled(true);
		
		// make a new db query
		// v6.3.6 Merge database to main
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		//myTrace("insert session for course " + this.courseName + " for userID=" + _global.ORCHID.user.userID);
		
		// put the query into an XML object
		// v6.3.5 Session table now stores courseID rather than courseName
		// v6.4.2 But continue to pass courseName as it is used for archiving. But, like all strings,
		// we should be making sure that there will be no stringy problems as it goes through
		// XML and scripting and database insertion. So have a hex encoding for any strings that
		// you are going to store that might contain odd characters. This includes unicode and apostrophes.
		// For now, you might want to just use it with courseName, but it will surely happen with userName as well.
		// That will just take an RM change as well.
		// Ahhh, having looked at the reference, it seems escape() should do this perfectly for me!
		// BUT, anything that is escaped is unescaped by php as soon as it gets it, exposing the '
		// so how do I force it to stay escaped?? And is it simply the ' and " that are the problem as they
		// screw up PHP string processing? What about unicode? Use double escaping so that only one is
		// undone by PHP. What will ASP do?
		// v6.5 Finally take out courseName and add in rootID. But I am not 100% sure that RM doesn't still use courseName!
		// For now, we will send both, but the SQL might or might not use. CE.com will, others won't.
		// v6.5.4.5 Time to take out courseName! No it isn't - sadly the network score.mdb requires it!
		var safeCourseName = escape(escape(this.courseName));

		// v6.5.4.3 Yiu. Session records hold start and end times AND duration. Minimum is 15 seconds set when you create the record
		var dateTimeNow;
		dateTimeNow = new Date();
		var nDefaultDuration;
		nDefaultDuration = 15;
		//var nDefaultEndSessionTime;
		//nDefaultEndSessionTime = this.nStartSessionTime + (nDefaultDuration * 1000);
		//dateTimeEnd.setTime(nDefaultEndSessionTime);

		thisDB.queryString = '<query method="startSession" ' +
					'userID="' + _global.ORCHID.user.userID + '" ' +
					'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
					// v6.5.4.5 Time to take out courseName! No it isn't - sadly the network score.mdb requires it!
					'courseName="' + safeCourseName + '" ' +
					'courseID="' + this.courseID + '" ' +
					// v6.5.5.0 Also add productCode to session records to make it easier to check licences
					'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
					// v6.4.2 Pass local time to the database
					'datestamp="' + dateFormat(dateTimeNow) + '" ' +
					// v6.5.4.5 Don't pass two dates, just one date and a duration and let the script fill in the endDate
					//'datestamp2="' + dateFormat(dateTimeEnd) + '" ' +
					'duration="' + nDefaultDuration + '" ' +
					// pass the database version that you read during getRMSettings
					'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
					'cacheVersion="' + new Date().getTime() + '" />';

		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
		thisDB.xmlReceive.onLoad = function(success) {
			// v6.5.5.1 For measuring performance
			_global.ORCHID.timeHolder.query['stop_' + 'startSession'] = new Date().getTime();
			// v6.4.2.4 Rebalancing progress
			var myController = _global.ORCHID.root.tlcController;
			myController.setPercentage(20);
			//myTrace("back to holdLicence from asp");
			//myTrace(this.toString());
			var callBackModule = _global.ORCHID.root.controlNS;
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
	
				// we expect a session node
				} else if (tN.nodeName == "session") {
					// parse the returned XML to get session details
					// these details are saved in the user and session object
					// the users number of sessions is user information
					this.master.sessionCount = tN.attributes.count;
					//this session id and start time is session information
					this.master.sessionID = tN.attributes.id;
					// When you created the session object you set the start time. The query does it as well
					// but of course this is a string not a date Object. It is easier later to have a date object.
					//this.master.startTime = tN.attributes.startTime;
					myTrace("your session ID=" + tN.attributes.id + ", session count=" + tN.attributes.count);
					//myTrace("sessions=" + this.master.sessionCount);
					//myTrace("got back coursename=" + unescape(tN.attributes.coursename));
	
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// once the session is started you can return to control to load the progress
			// v6.4.2 But if no session record was created, there should be a warning that your progress
			// will not be recorded.
			if (Number(this.master.sessionID)<=0) {
				myTrace("warning, session record not created, id=" + this.master.sessionID, 2);
				// this might be OK, for instance if you are running lso and don't allow SharedObject
				// or for some users in a database who just don't case??
				// But it would be better to call a different routine that warned and THEN you let you go on.
				// v6.5.5.6 Now records written for title based sessions
				// and I don't need to call anything, just go ahead
				callbackModule.setProgress();
			} else {
				callbackModule.setProgress();
			}
		}
		thisDB.runQuery();
	//}
}

// v6.5.4.3 Yiu, duration calculation
// v6.5.4.5 Not used anymore
/*
SessionObject.prototype.getSessionDuration	= function(nEndSessionTime){
	return this.calSecDiffWithMinSec(nEndSessionTime, this.nStartSessionTime);
}

SessionObject.prototype.calSecDiffWithMinSec = function(nMinSec1, nMinSec2){
	return Math.ceil(Math.abs(nMinSec1 - nMinSec2) / 1000);
}
*/
// End v6.5.4.3 Yiu, duration calculation

// 6.0.6.0 New method for stopping a session (user will choose a new course)
SessionObject.prototype.stopSession = function() {

	// v6.3.4 If you have come from SCORM, the default behaviour is to ignore our own progress reporting
	// v6.5.3 I think that I now want it in both if we are running through SCORM, also we have enabled our own progress button
	//if (_global.ORCHID.commandLine.scorm) {
	//	// so all you have to do is report that this bit is finished. 
	//	this.broadcastMessage("userEvent", "onStopSession");
	//} else {
		// make a new db query
		// v6.3.6 Merge database to main
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		// v6.3.5 Session contains courseID not courseName
		myTrace("stop session for " + this.courseName + " id=" + this.courseID);
		
		// put the query into an XML object
		//var safeCourseName = escape(escape(this.courseName));

		// v6.5.4.3 Yiu, duration calculation
		//var nEndSessionTime:Number;
		//nEndSessionTime	= new Date().getTime();
		//var nDurationInSec:Number;
		//nDurationInSec	= this.getSessionDuration(nEndSessionTime);
		// end v6.5.4.3 Yiu, duration calculation

		thisDB.queryString = '<query method="stopSession" ' +
							'sessionID="' + this.sessionID + '" ' +
							//v6.4.2 Don't use course name anymore
							//'courseName="' + safeCourseName + '" ' +
							'courseID="' + this.courseID + '" ' +
							// v6.4.2 Pass local time to the database
							'datestamp="' + dateFormat(new Date()) + '" ' +
							// pass the database version that you read during getRMSettings
							'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
							'cacheVersion="' + new Date().getTime() + '"/>';
							//'sessionDuration="' + nDurationInSec + '"/>';
		
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
		thisDB.xmlReceive.onLoad = function(success) {
			//myTrace(this.toString());
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
	
				// there is probably no need to send anything back
				// and a licence node
				} else if (tN.nodeName == "session") {
					// parse the returned XML to get licence details
					// licence details are saved in the session object
					//mySession.licenceHost = tN.attributes.host;
					//mySession.licenceID = tN.attributes.ID;
					//mySession.licenceNote = tN.attributes.note;
					//myTrace("your licence is " + tN.firstChild.nodeValue + " (" + tN.attributes.ID + ")");
	
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			//6.0.4.0, broadcast an event instead of call functions to change the interface directly
			this.master.broadcastMessage("userEvent", "onStopSession");
		}
		thisDB.runQuery();
	//}
}
// *****
// SCORE object
// *****
function ScoreObject(myObject) {
	// if you pass an object with some properties, set them to the score 
	//this.userID = myObject.userID;
	// if (userID eq undefined) {
	// 	this.userID = _global.ORCHID.user.userID;
	//}
//	this.courseName = myObject.courseName;
//	if (myObject.courseName eq undefined) {
//		this.courseName = _global.ORCHID.user.courseName;
//	}
	this.dateStamp = myObject.dateStamp;
	if (myObject.dateStamp == undefined) {
		// v6.4.2 This seems to add a dynamic date to the displayed progress records for new exercises
		// So try to turn it into something static;
		//this.dateStamp = new Date();
		this.dateStamp = dateFormat(new Date());
	}
	if (myObject.itemID == undefined) {
		this.itemID = _global.ORCHID.session.currentItem.ID; 
	} else {
		this.itemID = myObject.itemID;
	}
	// v6.5.5.0 Must be wrong
	//if (myObject.itemID == undefined) {
	if (myObject.unit == undefined) {
		this.unit = _global.ORCHID.session.currentItem.unit;
	} else {
		this.unit = myObject.unit;
	}
	// v6.3.4 Added field for test
	if (myObject.testUnits == undefined) {
		this.testUnits = _global.ORCHID.session.currentItem.testUnits;
	} else {
		this.testUnits = myObject.testUnits;
	}
	//myTrace("created score record with testUnits=" + this.testUnits);
	if (myObject.duration == undefined) {
		// v6.3.4 Incorrect use of getTimer (mismatched against starting time)
		//this.duration = Math.round((getTimer() - _global.ORCHID.session.currentExStartTime) / 1000);
		this.duration = Math.round((new Date().getTime() - _global.ORCHID.session.currentExStartTime) / 1000);
	} else {
		this.duration = myObject.duration;
	}
	if (this.duration < 0) this.duration = 0;
	this.score = myObject.score;
	this.correct = myObject.correct;
	this.wrong = myObject.wrong;
	this.skipped = myObject.skipped;
}
// method for writing out the object as a string (mostly used for trace or logs)
ScoreObject.prototype.toString = function() {
	return this.score+"% for Item:"+this.itemID+" on "+this.dateStamp;
};
// this method calculates the % from the raw constituents of correct, wrong and skipped
ScoreObject.prototype.calcPercentage = function() {
	// Note: this calculation doesn't take into account the wrong clicks in target spotting I don't think
	var totalQuestions = Number(this.wrong)+Number(this.skipped)+Number(this.correct);
	//trace("total=" + totalQuestions + " correct=" + this.correct);
	if (totalQuestions <=0) {
		this.score = 0;
	} else {
		this.score = Math.round(100*(this.correct/(totalQuestions)));
	}
	//} else {
	//	if (this.correct eq undefined) {
	//		this.score = 0;
	//	}
}
// this method figures out how to write out the object and does it
// it returns the total number of records for this user
ScoreObject.prototype.writeOut = function() {
	// v6.3.3 Also send the score to SCORM
	// v6.3.4 Actually it seems more likely that you would either write the score to the LMS OR to our own database
	// v6.5.3 I think that I now want it in both if we are running through SCORM, also we have enabled our own progress button
	if (_global.ORCHID.commandLine.scorm) {
		//myTrace("send score to scorm module");
		// v6.5.5.5 I also need the scaffold info as I want to write out a nice name. No, can get it from globals
		_global.ORCHID.root.scormHolder.scormNS.setScore(this);
		// v6.3.5 or you could set the bookmark here (not quite right working from mainMarking)
		// V6.5.5 Content paths. Whole bookmark thing will need rethinking.
		if (_global.ORCHID.session.nextItem.ID != undefined) {
			myTrace("in writeOut, set bookmark");
			_global.ORCHID.root.scormHolder.scormNS.setBookmark(_global.ORCHID.session.nextItem.ID);
		} else {
			myTrace("in writeOut, so set bookmark empty");
			//v6.4.2 I think you should still set the bookmark, but to empty. If you leave it
			// until the exit process it might happen after things are closed.
			_global.ORCHID.root.scormHolder.scormNS.setBookmark();
		}
	// v6.5.3 I think that I now want it in both if we are running through SCORM, also we have enabled our own progress button
	//} else {
	}
		// make a new db query
		// v6.3.6 Merge database to main
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		//myTrace("in writeOutScore for " + this.itemID);
		var myUserID = _global.ORCHID.user.userID;
		//myTrace("write out score for user " + myUserID);
		// v6.3.5 Session table contains courseID not courseName
		//var myCourseName = _global.ORCHID.session.courseName;
		var myCourseID = _global.ORCHID.session.courseID;
		var mySessionID = _global.ORCHID.session.sessionID;
		// make sure that the score has been calculated
		if (this.score == undefined || this.score == null) {
			this.calcPercentage();
		}
	
		// put the query into an XML object
		// NOTE: the Orchid itemID for an exercise is "e" + exerciseID. Since we want
		// to keep the score database as unchanged as possible, convert it here.
		// v6.2 NO no, the itemID has already had the 'e' stripped, so chopping a character here is terrible!
		// ...later... BUT it hasn't. Why did you think it had? OK - early LSO based stuff like EGU crossed over
		// from a dedicated exerciseID field in the exerciseXML which stripped the "e" so it got a bit confusing.
		// But now you can assume that any db does NOT hold the "e" - therefore it will be added in when
		// you are matching the scores against the exercise scaffold
		//v6.3.6 Old xml used 'e', new does not.
		if (_global.ORCHID.session.version.atLeast("6.4")) {
			// simply write out what you have
			var thisItemID = this.itemID;
		} else {
			// otherwise strip the itemID of the 'e', if it is there (probably will be)
			if (this.itemID.substr(0,1) == "e") {
				var thisItemID = this.itemID.substr(1);
			} else {
				var thisItemID = this.itemID;
			}
		}

		// v6.5.4.3 Yiu, duration calculation
		// v6.5.4.5 No need, just work it out in the script
		//var nEndSessionTime:Number;
		//nEndSessionTime	= new Date().getTime();
		//var nDurationInSec:Number;
		//nDurationInSec	= _global.ORCHID.session.getSessionDuration(nEndSessionTime);
		// end v6.5.4.3 Yiu, duration calculation

		//myTrace("score write out itemID=" + thisItemID);
		thisDB.queryString = '<query method="writeScore" ' +
							'userID="' + myUserID + '" ' +
							//'itemID="' + this.itemID.substr(1) + '" ' +
							'itemID="' + thisItemID + '" ' +
							// 6.0.6.0 should replace this with sessionID
							//'courseName="' + myCourseName + '" ' +
							// v6.3.4 Add new field for unit IDs used in dynamic test creation
							'testUnits="' + this.testUnits + '" ' +
							'score="' + this.score + '" ' +
							'correct="' + this.correct + '" ' +
							'wrong="' + this.wrong + '" ' +
							'skipped="' + this.skipped + '" ' +
							'sessionID="' + mySessionID + '" ' +
							'unitID="' + this.unit + '" ' +
							// v6.4.2 Pass local time to the database
							'datestamp="' + dateFormat(new Date()) + '" ' +
							'duration="' + this.duration + '" ' +
							// v6.5.5.3 Pass the courseID which we will now also store in T_Score ready for removing it from T_Session
							'courseID="' + myCourseID + '" ' +
							// v6.5.6.6 Pass the productCode which we will save in T_Score
							'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
							//'sessionDuration="' + nDurationInSec + '" ' +
							// pass the database version that you read during getRMSettings
							'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
							'cacheVersion="' + new Date().getTime() + '"/>';
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
		thisDB.xmlReceive.onLoad = function(success) {
			//myTrace("back from writeScore " + this.toString());
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			var status = false;
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
					if (tN.attributes.code == "205") {
					//	where would a good place be for this module?
						cannotWriteScore();
					}
	
				// we are expecting to get back a score node
				} else if (tN.nodeName == "score") {
					// parse the returned XML to get user details
					status = tN.attributes.status;
					
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// v6.4.3 Check that the database connection is closed now that you are logged in
			//myTrace("try to call dbClose");
			_global.ORCHID.root.queryHolder.dbClose();
			
			// a successful call will have a successful return
			if (status == "true") {
				myTrace("score record inserted successfully");
				this.master.onReturnCode(status); 
			}
		}
		// v6.3.5 Anonymous use in APL requires new type of query for scores
		//thisDB.runQuery();
		thisDB.runSplitQuery();
	//}
}	
// 6.0.5.0 rewrite for database access	
// 	myTrace("writing out " + this.toString());
// 	// first link to the global database interface object which holds my current connection
// 	var thisDB = _global.ORCHID.dbInterface;
// 	// find out what the connection method is as this call knows how to read in different
// 	// ways
// 	var dbMethod = thisDB.getWriteMethod();
// 	//trace("in score writeOut user=" + thisUserID + " course=" + thisCourseName + " item=" + this.itemID + " score=" + this.score);
// 	// make sure the percentage has been calculated

// 	if (dbMethod eq "sharedObject") {
// 		// first see if this user/course combination already exists
// 		// IT SHOULD as session will have added it
// 		// and perhaps I could hold in _global.ORCHID.user to save constantly checking this index
// 		var me = thisDB.dbSharedObject.data.progress;
// 		//trace("look up progIdx=" + _global.ORCHID.session.progressIdx);
// 		if (_global.ORCHID.user.progressIdx >= 0) {
// 			var progIdx = _global.ORCHID.session.progressIdx;
// 		} else {
// 			var progIdx = -1;
// 			for (var i in me) {
// 				if (me[i].userID == thisUserID && me[i].courseName == thisCourseName) {
// 					progIdx = i;
// 					_global.ORCHID.session.progressIdx = progIdx;
// 					break;
// 				}
// 			}
// 		}
// 		// This user has already created an object for scores from this course
// 		if (progIdx >= 0) {
// 			var scoreNum = me[progIdx].scoreRecords.push(this);
// 			myTrace("added a new score " + this.toString());
// 		} else {
// 			// Flag an error as it means that there is no session for this user/course
// 			var progObj = {userID:thisUserID, courseName:thisCourseName, sessionRecords:[], scoreRecords:[this]};
// 			me.push(progObj);
// 			var scoreNum = 1;
// 			myTrace("added a brand new score " + this.toString());
// 		}
// 		// trigger the callback with the number of sessions you have run
// 		this.onReturnCode(scoreNum); 
// 	}

// ===========
// 6.0.6.0 NOT USED
// ===========
/*
//Note: Hello, what is this function that it is passed an itemID??
// are you looking to find out the score for a precise menu item?
ScoreObject.prototype.readDB = function(myItemID) {
	// first link to the global database interface object which holds my current connection
	var thisDB = _global.ORCHID.dbInterface;
	// find out what the connection method is as this call knows how to read in different
	// ways
	var dbMethod = thisDB.getWriteMethod();
	//trace("in readDB with " + dbMethod);
	if (dbMethod == "sharedObject") {
		// the shared Object is referenced as a simple object
		var progIdx = _global.ORCHID.session.progressIdx;
		if (progIdx >= 0) {
			var me = thisDB.dbSharedObject.data.progress[progIdx].scoreRecords;
			for (var i in me) {
				if (me[i].itemID == myItemID) {
					this.onReturnCode(me[i]); 
					break;
				}
			}
		} else {
			this.onReturnCode(null); 
		}
	}
}
*/
// *****
// SCORE RECORDSET Object
// *****
ScoreRecordsetObject = function(myObject) {
	this.userID = myObject.userID;
	if (userID == undefined) {
		// 6.0.5.0 no longer using the session object
		//this.userID = _global.ORCHID.session.userID;
		this.userID = _global.ORCHID.user.userID;
	}
	// v6.3.5 Session table uses courseID not courseName
	this.courseName = myObject.courseName;
	if (myObject.courseName == undefined) {
		this.courseName = _global.ORCHID.session.courseName;
	}	
	this.courseID = myObject.courseID;
	if (myObject.courseID == undefined) {
		this.courseID = _global.ORCHID.session.courseID;
	}	
	myTrace("make a new score recordset for courseID " + this.courseID);
	this.scores = [];
}
// 6.0.5.0 updated
ScoreRecordsetObject.prototype.readDB = function() {
	
	// v6.3.3 Under SCORM you will not have any scores, so just go straight back
	// v6.4.2.8 This is a bad place to do this. If you don't want progress reporting under SCORM, then hide the Button
	// don't block it at this low level
	//if (_global.ORCHID.commandLine.scorm) {
	//	this.onReturnCode(0)
	// v6.4.2 How about ignoring the anonymous user? No point giving scores back is there?
	// v6.4.2.8 But doesn't a single user licence mean we are effectively anonymous, but still want to see progress
	// (everything that happens on this computer)?
	//} else if (this.userID == -1) {
	if (this.userID == -1) {
		this.onReturnCode(0)
	} else {
		// 6.0.5.0 the settings are now taken from the db (assumed under RM control)
		// make a new db query
		// v6.3.6 Merge database to main
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		
		// put the query into an XML object
		// v6.3.5 Session table uses courseID not courseName
		// v6.4.2 Don't use coursename any more
		//var safeCourseName = escape(escape(this.courseName));
		thisDB.queryString = '<query method="getScores" ' + 
							'userID="' + this.userID + '" ' +
							// v6.4.2.8 Add user type for a better query (even though we no longer use that)
							'userType="' + _global.ORCHID.user.userType + '" ' +
							// v6.4.2.8 And add the rootID for getting everyone's information (and later the groupID)
							'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
							//'courseName="' + safeCourseName + '" ' +
							'courseID="' + this.courseID + '" ' +
							'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
							'cacheVersion="' + new Date().getTime() + '"/>';
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
		thisDB.xmlReceive.onLoad = function(success) {
			//myTrace("back to getScores from query");
			// v6.5.5.1 For measuring performance
			_global.ORCHID.timeHolder.query['stop_' + 'getScores'] = new Date().getTime();
			//myTrace(this.toString());
			//var callBackModule = _global.ORCHID.root.loginHolder.loginNS;
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")");
	
				// we are expecting to get back a lot of score nodes
				} else if (tN.nodeName == "score") {
					// parse the returned XML to get user details
					//myTrace("tN=" + tN.toString());
					this.master.scores.push(tN.attributes);
					
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// v6.4.3 Check that the database connection is closed now that you are logged in
			myTrace("try to call dbClose");
			_global.ORCHID.root.queryHolder.dbClose();
			
			//myTrace("got back " + this.master.scores.length + " score records");
			// a successful call will have ...
			this.master.onReturnCode(this.master.scores.length)
		}
		// v6.3.5 Split query to allow for anonymous users
		//thisDB.runQuery();
		thisDB.runSplitQuery();
	}
}	
// v6.4.2.8 Extra function to get all scores. Not used.
ScoreRecordsetObject.prototype.readAllDB = function() {
	
	if (this.userID == -1) {
		this.onReturnCode(0)
	} else {
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		
		thisDB.queryString = '<query method="getAllScores" ' + 
							'userID="' + this.userID + '" ' +
							'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
							'courseID="' + this.courseID + '" ' +
							'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
							'cacheVersion="' + new Date().getTime() + '"/>';
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
		thisDB.xmlReceive.onLoad = function(success) {
			myTrace("back to getAllScores from query with this=" + this.toString());
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
	
				// we are expecting to get back a lot of score nodes
				} else if (tN.nodeName == "score") {
					// parse the returned XML to get user details
					this.master.scores.push(tN.attributes);
					
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// v6.4.3 Check that the database connection is closed now that you are logged in
			myTrace("try to call dbClose");
			_global.ORCHID.root.queryHolder.dbClose();
			
			//myTrace("got back " + this.master.scores.length + " score records");
			// a successful call will have ...
			this.master.onReturnCode(this.master.scores.length)
		}
		// v6.3.5 Split query to allow for anonymous users
		//thisDB.runQuery();
		thisDB.runSplitQuery();
	}
}
// 6.0.5.0 read scores from a database instead
// 	//trace("read recordset");
// 	// first link to the global database interface object which holds my current connection
// 	var thisDB = _global.ORCHID.dbInterface;
// 	// find out what the connection method is as this call knows how to read in different
// 	// ways
// 	var dbMethod = thisDB.getWriteMethod();
// 	//trace("in readDB with " + dbMethod);
// 	if (dbMethod == "sharedObject") {
// 		// the shared Object is referenced as a simple object
// 		var progIdx = _global.ORCHID.session.progressIdx;
// 		//trace("reading from progIdx=" + progIdx);
// 		if (progIdx >= 0) {
// 			var me = thisDB.dbSharedObject.data.progress[progIdx].scoreRecords;
// 			//trace("got back " + me.length + " records");
// 		} else {
// 			var me = []; 
// 		}
// 		this.scores = me;
// 		//trace("test: this itemID=" + me.itemID);
// 		this.onReturnCode(me.length); 
// 	}

// *****
// v6.5.5.0 Score detail object
// *****
function ScoreDetailObject(myObject) {
	this.dateStamp = myObject.dateStamp;
	if (myObject.dateStamp == undefined) {
		this.dateStamp = dateFormat(new Date());
	} else {
		this.dateStamp = myObject.dateStamp;
	}
	if (myObject.exerciseID == undefined) {
		this.exerciseID = _global.ORCHID.session.currentItem.ID; 
	} else {
		this.exerciseID = myObject.exerciseID;
	}
	if (myObject.unit == undefined) {
		this.unit = _global.ORCHID.session.currentItem.unit;
	} else {
		this.unit = myObject.unit;
	}
	this.details = myObject.details;
}
// v6.5.5.0 Method to turn the details array into XML nodes (string version thereof)
ScoreDetailObject.prototype.detailsToXML = function() {
	var buildNodes = "";
	for (var i in this.details) {
		if (this.details[i].detail!=undefined) {
			buildNodes += '<item itemID="' + this.details[i].itemID + '" detail="' + this.details[i].detail + '" score="' + this.details[i].score + '" />';
		} else {
			buildNodes += '<item itemID="' + this.details[i].itemID + '" />';
		}
	}
	//myTrace("details are " + buildNodes);
	return buildNodes;
};
// this method figures out how to write out the object and does it
// it returns the total number of records for this user
ScoreDetailObject.prototype.writeOut = function() {
	// make a new db query
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	
	//myTrace("score write out itemID=" + thisItemID);
	// Not sure if it is worth writing out rootID, userID, dateStamp as all can come from T_Session and other joins.
	// But it might make statistics analysis easier
	thisDB.queryString = '<query method="writeScoreDetail" ' +
						'sessionID="' + _global.ORCHID.session.sessionID + '" ' +
						'userID="' + _global.ORCHID.user.userID + '" ' +
						'unitID="' + this.unit + '" ' +
						'exerciseID="' + this.exerciseID + '" ' +
						'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
						'datestamp="' + this.dateStamp + '" ' +
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '">';
	thisDB.queryString += this.detailsToXML();
	thisDB.queryString += "</query>";
	
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
	thisDB.xmlReceive.onLoad = function(success) {
		//myTrace("back from writeScoreDetail " + this.toString());
		// don't make too many assumptions about the format of the returned
		// XML, so look through all nodes to find anything expected
		// and leave unexpected stuff alone
		var status = false;
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// we are expecting to get back an acknowledgement node
			} else if (tN.nodeName == "scoreDetail") {
				// parse the returned XML to get user details
				status = tN.attributes.status;
				var records = tN.attributes.records;
				
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// v6.4.3 Check that the database connection is closed now that you are logged in
		//myTrace("try to call dbClose");
		_global.ORCHID.root.queryHolder.dbClose();
		
		// a successful call will have a successful return
		if (status == "true") {
			//myTrace("score record inserted successfully");
			this.master.onReturnCode(records); 
		}
	}
	thisDB.runQuery();
}	

// *****
// COURSE 
// *****
#include "course.as"

// *****
// EXERCISE Object
// *****
// The Exercise Object contains everything we know about the exercise
function ExerciseObject () {
	//trace("created an exercise object");
};
ExerciseObject.prototype.populateFromXML = function(myCallBack, index) {
	//AM: index indicates which item in _global.ORCHID.LoadedExercises[]
	// it doesn't make sense to wait for a call to data to do this as it is so hard work
	_global.ORCHID.root.objectHolder.populateExerciseFromXML(this.rawXML, myCallBack, index);
}
// It has methods for sending back partial information
// These methods only parse the XML if necessary
ExerciseObject.prototype.getExerciseID = function() {
	//trace("gEI with "+this.id);
	if (this.id == undefined) { 
	// will have to get it from the stored XML data and save it nicely
		returnCode = _global.ORCHID.root.objectHolder.populateExerciseFromXML(this.rawXML);
	}
	else {
	// it has already been set, so just return it
	};
	return this.id;
};
// v6.2 I don't think this section is used any more
ExerciseObject.prototype.getExerciseTitle = function(para) {
	//trace("gETitle with "+this.title.text.paragraph[para].plainText);
	if (this.title.text.paragraph[para].plainText == undefined) {
	// will have to get it from the stored XML data and save it nicely
		returnCode = _global.ORCHID.root.objectHolder.populateExerciseFromXML(this.rawXML);
	}
	else {
	// it has already been set, so just return it
	};
	return this.title.text.paragraph[para].plainText;
};
ExerciseObject.prototype.getExerciseText = function(para){
// This returns the pure text (no formatting codes or fields)
// from the Exercise object for the requested paragraph.
// The XML object is read if necessary
// return: string
//	trace("gET with "+this.text.paragraph[para].plainText);
	if (this.body.text.paragraph[para].plainText == undefined) {
	}
	else {
	// it has already been set, so just return it
	};
	return this.body.text.paragraph[para].plainText;
};
ExerciseObject.prototype.getParagraphStyle = function(para){
// This returns the style name for a paragraph
	return this.body.text.paragraph[para].style;
};
ExerciseObject.prototype.getParagraphTabs = function(para){
// This returns the tabs stops for a paragraph
	//trace("tabs got at " + this.text.paragraph[para].tabArray);
	return this.body.text.paragraph[para].tabArray;
};
ExerciseObject.prototype.getFeedbackText = function(fb, para) {
	//trace("gFT ("+fb+","+para+") with "+this.feedback[fb].text.paragraph[para].plainText);
	return this.feedback[fb].text.paragraph[para].plainText;
};
ExerciseObject.prototype.getTitleRTFTags = function(para){
// This returns the RTF control information 
// from the Exercise object for the requested paragraph.
// The XML object is read if necessary
// return: string
	return this.title.text.paragraph[para].RTFTags;
};
ExerciseObject.prototype.getFeedbackRTFTags = function(fb, para){
// This returns the RTF control information 
// from the Exercise object for the requested paragraph.
// The XML object is read if necessary
// return: string
	return this.feedback[fb].text.paragraph[para].RTFTags;
};
//ExerciseObject.prototype.getRTFTags = function(para){
// This returns the RTF control information 
// from the Exercise object for the requested paragraph.
// The XML object is read if necessary
// return: string
//	if (this.body.text.paragraph[para].RTFTags == undefined) {
//	}
//	else {
//	// it has already been set, so just return it
//	};
//	return this.body.text.paragraph[para].RTFTags;
//};
ExerciseObject.prototype.getExerciseFields = function(){
// This returns an array of fields in the content
// from the Exercise object
// The XML object is read if necessary
// return: array
	if (this.body.text.field[0].id == undefined) {
	}
	else {
	// it has already been set, so just return it
	};
	return this.body.text.field;
};
// this function is used if you need to find field information from the object and you just
// know the fieldID (as happens from some events)
ExerciseObject.prototype.getField = function(thisID) {
	var me = new Array();
	me = this.body.text.field;
	//myTrace("looking for field " + thisID + " len=" + me.length);
	for (var i=0;i<me.length;i++) {
		if (me[i].id == thisID) {
			me[i].region = _global.ORCHID.regionMode.body;
			//trace("got field["+thisID+"]="+me[i].id);
			return me[i];
		};
	};
	// v6.2 perhaps you should also check other regions for field information
	me = this.noScroll.text.field;
	//trace("looking for field " + thisID + " len=" + me.length);
	for (var i=0;i<me.length;i++) {
		if (me[i].id == thisID) {
			me[i].region = _global.ORCHID.regionMode.noScroll;
			//trace("got field["+thisID+"]="+me[i].id);
			return me[i];
		};
	};
	// v6.4.2.4 Can you drag from a reading text?
	me = this.texts[0].text.field;
	for (var i=0;i<me.length;i++) {
		//myTrace("looking for readingText field " + thisID + " len=" + me.length);
		if (me[i].id == thisID) {
			me[i].region = _global.ORCHID.regionMode.readingText;
			//myTrace("got reading text field["+thisID+"]="+me[i].id); 
			return me[i];
		};
	};
	return false; // not found
};
// this function is used if you want to find the field after the one you are 'on'
ExerciseObject.prototype.getNextGap = function(thisID) {
	var me = new Array();
	me = this.body.text.field;
	// find the object index for the field of this ID
	var thisIDX = lookupArrayItem(me, thisID, "id");
	// v6.4.3 It might be more sensible to go to the next group ID - will be the same for gaps after all
	// and will be easier to manage for random stuff. Ahh, except that you don't know what type
	// of fields are in the group. Any chance that you can do it based on x and y coordinates?
	// So revert to fields now and see if you can get those in order from random test
	
	// Or allow the possibility of adding tab order as an attribute to fields that you can then lookup
	nextTabOrder = Number(me[thisIDX].tabOrder) + 1;
	//myTrace("getNextGap, current field.id=" + thisID + " group=" + me[thisIDX].group + " tabOrder=" + me[thisIDX].tabOrder);
	for (var i=0;i<me.length;i++) {
		//myTrace("test type=" + me[i].type + " tabOrder=" + me[i].tabOrder);
		// In fact, just look for the next tabOrder, because if that turns out not to be a gap, we won't want to go any further anyway.
		if (me[i].tabOrder == nextTabOrder) {
			if (me[i].type == "i:gap" || (me[i].type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading)) {
				//myTrace("got gap with tabOrder="+nextTabOrder);
				return me[i];
			} else {
				//myTrace("got other field with tabOrder="+nextTabOrder);
				return false;
			}	
		}
	}
	// v6.5.2 If you are in a randomly generated test and you didn't find the field you were looking for in the above
	// loop, you don't want to go on as it probably means you are at the end. If you start checking on field IDs
	// you will end up going somewhere random. 
	// That is best expressed as seeing if you have tabOrder set at all.
	if (me[thisIDX].tabOrder>0) {
		myTrace("using tabOrder, but got to the end, nothing after " + me[thisIDX].tabOrder);
		return false;
	}
	
	// v6.4.2.8 Put this loop back in as we simply don't have tabOrder as an attribute for regular exercises
	//trace("looking for gap after " + thisID + " (idx=" + thisIDX + ")");
	// go from here to the end
	for (var i=thisIDX+1;i<me.length;i++) {
		//if (me[i].type == "i:gap" || me[i].type == "i:presetGap") {
		// v6.4.3 target gaps in proofReading should NOT go to the next one! Need this elsewhere too?
		//if (me[i].type == "i:gap" || me[i].type == "i:targetGap") {
		// More sense to use hiddenTargets
		//if (me[i].type == "i:gap" || (me[i].type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading)) {
		if (me[i].type == "i:gap" || (me[i].type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets)) {
			//myTrace("got field "+me[i].id);
			return me[i];
		};
	};
	
	// v6.2 CUP does not want to go from the end to the beginning, and perhaps noone does
	/*
	// then if not found go from beginning to here
	for (var i=0;i<thisIDX;i++) {
		if (me[i].type == "i:gap") {
			trace("got field "+me[i].id);
			return me[i];
		};
	};
	*/
	return false; // not found
};
ExerciseObject.prototype.getPreviousGap = function(thisID) {
	var me = new Array();
	me = this.body.text.field;
	var thisIDX = lookupArrayItem(me, thisID, "id");
	// Or allow the possibility of adding tab order as an attribute to fields that you can then lookup
	thisTabOrder = Number(me[thisIDX].tabOrder) - 1;
	//myTrace("getNextGap, current field.id=" + thisID + " group=" + me[thisIDX].group + " tabOrder=" + thisTabOrder);
	for (var i=0;i<me.length;i++) {
		if ((me[i].type == "i:gap" || me[i].type == "i:targetGap")
			&& me[i].tabOrder == thisTabOrder) {
			//myTrace("got field tabOrder="+me[i].tabOrder);
			return me[i];
		}
	}
	// v6.4.2.8 Put this loop back in as we simply don't have tabOrder as an attribute for regular exercises
	for(var i = thisIDX - 1; i >= 0; i--) {
		//if(me[i].type == "i:gap" || me[i].type == "i:presetGap") {
		// v6.4.3 target gaps in proofReading should NOT go to the next one! Need this elsewhere too?
		//if (me[i].type == "i:gap" || me[i].type == "i:targetGap") {
		// More sense to use hiddenTargets
		//if (me[i].type == "i:gap" || (me[i].type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading)) {
		if (me[i].type == "i:gap" || 
			(me[i].type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets)) {
			return me[i];
		}
	}
	
	// v6.2 CUP does not want to go from the beginning to the end, and perhaps noone does
	/*
	for(var i = me.length - 1; i > thisIDX; i--) {
		if(me[i].type == "i:gap") {
			return me[i];
		}
	}
	*/
	return false;
}


