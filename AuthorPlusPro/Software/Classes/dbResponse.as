class Classes.dbResponse extends XML {
	
	var control:Object;
	var queryPurpose:String;
	
	function dbResponse() {
		control = _global.NNW.control;
	}
	
	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function onLoad(success:Boolean) : Void {
		myTrace("(dbResponse) - db response back from query:");
		myTrace(this.firstChild.toString());
		var responseNode = this.firstChild.firstChild;
		if (success) {
			if (responseNode.attributes.error=="true") {
				onQueryFail();
			} else {
				switch (queryPurpose) {
				// v6.5.5.3 Added call to read licence details
				case "getLicenceDetails" :					
					var licence = control.login.licence;
					// v6.5.5.5 Init error checking
					licence.error=false;
					// What are the key things you need to fill in for the licence?
					// Sadly this duplicates much of what is in licenceClass.
					licence.productType = "full";
					licence.institution = responseNode.attributes.name;
					licence.expiry = responseNode.attributes.expiryDate;
					licence.startDate = responseNode.attributes.startDate;
					licence.centralRoot = responseNode.attributes.rootID;
					licence.licences = Number(responseNode.attributes.maxAuthors) + Number(responseNode.attributes.maxTeachers);
					// v6.5.5.6 Also get content path from T_Accounts
					if (responseNode.attributes.contentLocation) {
						_global.NNW.paths.content=_global.addSlash(_global.NNW.paths.content) + _global.addSlash(responseNode.attributes.contentLocation);
						_global.myTrace("content after account checking=" + _global.NNW.paths.content);
					} else {
						_global.myTrace("content needs no change=" + _global.NNW.paths.content);
					}
					
					// Assumes that database and scripting are in the licence. In fact they come from location.
					licence.scripting = control.paths.scripting;
					licence.database = control._database;
					
					// Then do some checking to see if all is well
					if (licence.expiry.indexOf("-") > 0) {
						var dateSections=licence.expiry.split(" ");
						var dayParts=dateSections[0].split("-");
						// If there is no time mentioned, then you should give them until midnight
						if (dateSections[1] == undefined) {
							dateSections[1] = "23:59:59";
						}
						var timeParts=dateSections[1].split(":");
						var expiryDate = new Date(dayParts[0], dayParts[1]-1, dayParts[2], timeParts[0], timeParts[1], timeParts[2]);
						_global.myTrace("parsed expiry=" + expiryDate.toString());
					} else if (licence.expiry.indexOf("/") > 0) {
						var dayParts=licence.expiry.split("/"); // remember the slash is a special character
						var expiryDate = new Date(dayParts[2], dayParts[1]-1, dayParts[0]);
					} else {
						var expiryDate = undefined;
					}
					//myTrace("built up expiryDate=" + expiryDate.toString());
					if (expiryDate == undefined || expiryDate.getTime() < new Date().getTime()) {
						_global.myTrace("licence has expired");
						// the licence has expired
						licence.valid = false;
						//var errObj = {literal:"licenceExpired", detail:licence.expiry.toString()};
						licence.error = "licenceExpired";
					} else {
						_global.myTrace("licence within expiry date");
					}
					// Number of authors
					if (licence.licences < 1) {
						_global.myTrace("no authoring licences");
						// the licence has expired
						licence.valid = false;
						//var errObj = {literal:"licenceExpired", detail:licence.expiry.toString()};
						licence.error = "noLicences";
					} else {
						_global.myTrace("got " + licence.licences + " licences.");
					}					
					_global.myTrace("read db licence for " + licence.institution);
					if (licence.error) {
						control.view.showPopup(licence.error);
					} else {
						control.login.onLicenceLoadedSuccessfully();
					}
					break;
				case "getDecryptKey" :
					_global.NNW._decryptKey = (responseNode.attributes.success=="true") ? responseNode.attributes.key : "";
					// v6.4.2.6 RL change the order of licence load and decrypt key
					//control.login.loadLicence();
					break;
				case "checkLogin" :
					var v = (responseNode.attributes.success=="true") ? true : false;
					var n = (responseNode.attributes.name);
					//myTrace("(dbResponse) - onLoad -> name = "+n);
					/* v0.7.2, DL: if userDataPath is provided, no need to update content path */
					// v6.4.3 Change the name from paths.userPath to paths.content, as that is what it is!
					//if (_global.NNW.userPath=="") {
					//	_global.NNW.paths.userPath = responseNode.attributes.path;
					//v6.4.4, RL: get userSetting
					// v6.4.2.5 But send it back like the name
					var s = (responseNode.attributes.success=="true") ? responseNode.attributes.userSettings : "0";				
					//_global.NNW._userSettings = (responseNode.attributes.success=="true") ? responseNode.attributes.userSettings : "0";				
					// v6.4.2.5 this db call NEVER returns a path, what is this for? When was it added?
					//if (_global.NNW.content=="") {
					//	_global.NNW.paths.content = responseNode.attributes.path;
					//}
					// v0.15.0, DL: get user's full name & email
					if (responseNode.attributes.name!=undefined) {
						control._fullname = responseNode.attributes.name;
					}
					if (responseNode.attributes.email!=undefined) {
						control._emailaddress = responseNode.attributes.email;
					}
					// v6.4.2.6 Use userID rather than name
					//control.login.onCheckLogin(v,n,s);
					var userID = (responseNode.attributes.userID);
					_global.NNW.userID = (responseNode.attributes.userID);
					_global.NNW.groupID = (responseNode.attributes.groupID);
					// v6.5.6 AR I also want to know if this is the administrator since they can see all privacy stuff
					_global.NNW.userType = (responseNode.attributes.userType);
					myTrace("User's group ID is " + _global.NNW.groupID);
					control.login.onCheckLogin(v,userID,s);
					break;
					// v6.4.4, RL: add a case of MGS flag checking
				case "checkMGS" :
					/*
					// v.6.4.4, RL: re-edited: getMGS and CheckMGS are now in 1 go.
					//myTrace("(dbResponse) - onLoad() -> case checkMGS");
					var u = responseNode.attributes.name;
					var v = (responseNode.attributes.success=="true") ? true : false;
					
					// enableMGS will use in elsewhere
					if (responseNode.attributes.enableMGS!=undefined) {
						control._enableMGS = responseNode.attributes.enableMGS;
					}
					
					//myTrace("(dbResponse) - checkMGS = "+responseNode.attributes.enableMGS);
					control.login.onCheckMGS(v,u);
					*/
					var v = (responseNode.attributes.success=="true") ? true : false;
					//if (responseNode.attributes.enableMGS!=undefined) {
						var e = responseNode.attributes.enableMGS;
					//}
					//if (responseNode.attributes.name!=undefined) {
						// v6.4.2.5 You get back attribute name, not MSGName
						//var m = responseNode.attributes.MGSName;
						var m = responseNode.attributes.name; 
					//}
					// v6.4.2.5 Don't send back groupID
					//if (responseNode.attributes.gid!=undefined) {
					//	var g = responseNode.attributes.gid;
					//}
					myTrace("(dbResponse) - getMGS="+m+" enableMGS="+e);
					//control.login.onGetMGS(v,e,g,m);
					control.login.onGetMGS(v,e,m);
				/*
				// v.6.4.4, RL: re-edited: getMGS and CheckMGS are now in 1 go.
				case "getMGS" :
					var v = (responseNode.attributes.success=="true") ? true : false;
					if (responseNode.attributes.enableMGS!=undefined) {
						var e = responseNode.attributes.enableMGS;
					}
					if (responseNode.attributes.MGSName!=undefined) {
						var m = responseNode.attributes.MGSName;
					}
					if (responseNode.attributes.gid!=undefined) {
						var g = responseNode.attributes.gid;
					}
					myTrace("(dbResponse) - getMGS="+m+" enableMGS="+e);
					control.login.onGetMGS(v,e,g,m);
				*/
				}
				
			}
		} else {
			onQueryFail();
		}
	}
	
	function onQueryFail() : Void {
		switch(queryPurpose) {
		case "getDecryptKey" :
			_global.NNW._decryptKey = "";
			control.login.loadLicence();
			break;
		case "checkLogin" :
			control.login.onCheckLogin(false,"N/A");
			break;
		case "checkMGS" :
			control.login.onCheckMGS(false,"N/A");
			break;
		// v6.5.5.3
		case "getLicenceDetails":
			// how do I know the licence object?
			control.view.showPopup("licenceError");
			break;
		}
	}
}