// v6.4.3 revert to mdm script 1 until you can compile this script into a F8 MovieClip

// v6.4.3 Can you connect to MySQL from here?
queryNS.databaseType = _global.ORCHID.root.licenceHolder.licenceNS.db.toLowerCase();

// this function will connect to a database and use a callback to let you
// know that you can keep going
// The name of the database MUST have been set by the calling module
// in FSPdbFileName.
//queryNS.dbConnect = function(filename, scope, callback_param) {
// v6.4.3 mdm script 2 - revert to 1
dbConnect = function(filename, scope, callback_param) {
//dbConnect = function(filename) {
	
	_global.ORCHID.projector.variables.doingWhat == "dbCriticalCall";
	// v6.4.3 Don't need callbacks anymore - revert to 1	
	_global.ORCHID.projector.callbacks.scope = scope;
	_global.ORCHID.projector.callbacks.callBackFunction = callback_param;
	//myTrace("set callback function=" + callback_param);
	_global.ORCHID.projector.callbacks.dbConnected = function(value) {
		//myTrace("dbConnected with " + value);
		if (value == "true") {
			var success = true;
			//myTrace("callbacks.dbConnected:database connected through FSP");
		} else {
			var success = false;
			//myTrace("callbacks.dbConnected:database not connected");
			//fscommand("flashstudio.dberror_details","FSPdbReturnCode"); 
			_global.ORCHID.projector.variables.doingWhat = "dbCriticalCall";
			// But this does not get picked up, you get loadOCX, which behaves differently
			// Really need to send something else with exception handling.
			//mdm.dberror_details(_global.ORCHID.projector.callbacks.dbErrors);
			// v6.4.3 Allow MySQL
			if (queryNS.databaseType == "access") {
				mdm.dberror_details(_global.ORCHID.projector.callbacks.dbErrorDetails);
			} else {
				mdm.mysqlgetlasterror(_global.ORCHID.projector.callbacks.dbErrorDetails); 
			}
			//mdm.dberror(_global.ORCHID.projector.callbacks.dbErrors);
		}
		// v6.3 Set up a flag that shows you are currently connected
		_global.ORCHID.projector.dbConnected = success;
		// callback (seems most convoluted!!)
		var callBackFunc = _global.ORCHID.projector.callbacks.scope[_global.ORCHID.projector.callbacks.callBackFunction];
		callBackFunc(_global.ORCHID.projector.callbacks.scope, success);
	}
	_global.ORCHID.projector.callbacks.dbErrors = function(status) {
		if (status = "true") {
			mdm.dberror_details(_global.ORCHID.projector.callbacks.dbErrorDetails);
		} else {
			myTrace("odd - get connection error, but no mdm info!");
			_global.ORCHID.projector.callbacks.dbErrorDetails("unknown error");
		}
	}
	_global.ORCHID.projector.callbacks.dbErrorDetails = function(value) {
		myTrace("dbError=" + value);
		var errObj = {literal:"dbError", detail:value};
		_global.ORCHID.root.controlNS.sendError(errObj);
		stop();
	}	
	// remember that FSP has to have had its variables set in _root
	//_root.FSPdbFileName = "d:\\Workbench\\Orchid\\Student\\Score.mdb";
	//myTrace("flashstudio.connecttodb_abs." + _root.FSPdbFileName);
	//fscommand("flashstudio.connecttodb_abs", "FSPdbFileName");
	//fscommand("flashstudio.connecttodb_abs", "\"d:\\Workbench\\Orchid\\Student\\Score.mdb\"");
	// v6.3.5 ZINC
	//_root.FSPdbReturnCode = "";
	//fscommand("flashstudio.dbsuccess", "FSPdbReturnCode");
	//_global.ORCHID.FSP.dbConnectIntID = setInterval(callBackObj, "connectCallBack", 250);
	//myTrace("mdm.connecttodb_abs, callback obj=" + 	_global.ORCHID.projector.callbacks.testName);
	// v6.3.5 Move to ZINC
	// v6.4.2.3 Add password protection for the database.
	// Can it be set somewhere else and (if set) used here? In order to avoid changing as little
	// other code as possible (and hiding it), we could assume that you are running network version
	// and it is passed as a parameter from ZINC. I don't think is seeable by anyone.
	// But since that is a poor solution for maintainance you might as well hard-code it here as
	// that means you only need this one file to do all programs (Orchid). And it doesn't make any
	// difference if an unprotected database is used.
	//mdm.exceptionhandler_enable();	
	//var usePassword = _root.dbPassword;
	//if (usePassword != undefined) {
	//myTrace("use dbPassword");
	myTrace("ssh, connect to db:" + filename + " through " + queryNS.databaseType);
	// v6.4.3 It would be good to find out if it is better to test for connection before trying to connect
	// or whether to just go ahead and try. Depends if the test actually talks to the db or just looks at 
	// a local process I suppose.
	//if (mdm.Database.MSAccess.success()) {
	//	myTrace("already connected");
	//} else {
	// v6.4.3 revert to 1
	// v6.4.3 Allow MySQL
	if (queryNS.databaseType == "access") {
		if (_global.ORCHID.projector.version < 2.5) {
			myTrace("connecting to Access database with password");
			mdm.connecttodb_abs(filename, "ClarityDB"); 
		} else {
			mdm.Database.MSAccess.connectAbs(filename, "ClarityDB");
		}
	} else {
		// Note - you really ought to be reading this from dbDetails-MySQL like file - or at least from location.ini
		// You could read it from dbPath. But you would only want to do this once, during dbInterface, not on each connect		
		//var host = "swds2"; 
		//var port = ""; // If left empty, this will default to 3306 
		//var compression = "true"; // Set to false to disable transfer compression 
		//var username = "network"; 
		//var password = "ClarityDB"; // Note that this user has to have an old style password if MySQL 5 is used.
		//var password = ""; // If no password is used
		// MySQL> SET PASSWORD FOR 'network'@'%' = OLD_PASSWORD('ClarityDB');
		//var dbname = "score"; 
		// Pick up the details you read earlier
		//mdm.mysqlconnect(host,port,compression,username,password,dbname,"success"); 
		//myTrace("connect to " +  queryNS.dbDetails.dbname + " using " + queryNS.dbDetails.username + "@" + queryNS.dbDetails.dbHost);
		mdm.mysqlconnect(queryNS.dbDetails.dbHost,queryNS.dbDetails.port,queryNS.dbDetails.compression,queryNS.dbDetails.username,queryNS.dbDetails.password,queryNS.dbDetails.dbname,"success"); 
	}
	// v6.4.3 mdm script 2 - are we connected?
	// v6.4.3 revert to 1
	// v6.4.3 Allow MySQL
	if (queryNS.databaseType == "access") {
		if (_global.ORCHID.projector.version < 2.5) {
			mdm.dbsuccess(_global.ORCHID.projector.callbacks.dbConnected); 
		} else {
			if (mdm.Database.MSAccess.success()) {
				// v6.3 Set up a flag that shows you are currently connected
				_global.ORCHID.projector.dbConnected = success;
				return true;
			} else {
				if (mdm.Database.MSAccess.error() == false){
					var errorDetails = mdm.Database.MSAccess.errorDetails;
				} else {
					var errorDetails = "cannot connect, reason unknown";
				}
				myTrace("dbError=" + errorDetails);		
				var errObj = {literal:"dbError", detail:errorDetails};
				_global.ORCHID.root.controlNS.sendError(errObj);
				stop();
			}
		}
	} else {			
		mdm.mysqlisconnected(_global.ORCHID.projector.callbacks.dbConnected); 
	}
			
}
// v6.3.5 move to ZINC
dbClose = function() {
	myTrace("close db connection");
	//fscommand("flashstudio.closedb");
	// v6.4.3 mdm script 2 - revert to 1
	if (queryNS.databaseType == "access") {
		if (_global.ORCHID.projector.version < 2.5) {
			mdm.closedb(); 
		} else {
			if (mdm.Database.MSAccess.success()) {
				mdm.Database.MSAccess.close();
			}
		}
	} else {
		mdm.mysqlclose(); 
	}
	_global.ORCHID.projector.dbConnected = false;
}
// v6.3.5 Move to ZINC
// getRMSettings has been done as a model, but other stuff still works with the old
// code, so do it gradually
// v6.4.2 Connection database not used anymore, all in score. So change that stuff.
// It is assumed that rootID=1 for networks
// v6.4.1.5 Search for @c@ and @q@, also protect quote marks in strings (coursename etc).

// Common handling of the query and processing of results
querySendAndLoad = function(queryString, resultsAction, requiresWait) {	
	//myTrace("sendAndLoad");
	if (_global.ORCHID.projector.version < 2.5) {
		_global.ORCHID.projector.variables.doingWhat = "dbCall";
		_global.ORCHID.projector.callbacks.resultsAction = resultsAction;
		if (queryNS.databaseType == "access") {
			//myTrace("query: " + queryString.split(",").join("@c@"));
			mdm.selectfromdb(queryString.split(",").join("@c@")); 
		} else {
			//myTrace("query: " + queryString.split(",").join("@c@"));
			mdm.mysqlquery(queryString.split(",").join("@c@"), "success"); 
		}
		if (requiresWait){
			// Because you are running a select after a recent insert/update/delete, this call may return suspect data
			// So you should run it until you get data that is reasonable
			_global.ORCHID.projector.variables.returnData = "";
			if (queryNS.databaseType == "access") {
				mdm.getxmlfromdb("_global.ORCHID.projector.variables.returnData"); 
			} else {
				mdm.mysqlgetresults("","","_global.ORCHID.projector.variables.returnData"); 
			}
			_global.ORCHID.projector.callbacks.checkData = new Object();
			_global.ORCHID.projector.callbacks.checkData.sqlReturn = function() {
				//myTrace("testing sql return " + _global.ORCHID.projector.variables.returnData);
				if (	(_global.ORCHID.projector.variables.returnData != "") ||
					(_global.ORCHID.projector.callbacks.counter > 10)) {
					clearInterval(_global.ORCHID.projector.callbacks.dbIntID);
					_global.ORCHID.projector.callbacks.resultsAction(_global.ORCHID.projector.variables.returnData);
				} else {
					_global.ORCHID.projector.callbacks.counter++;
				}
			}
			_global.ORCHID.projector.callbacks.counter = 0;
			_global.ORCHID.projector.callbacks.dbIntID = setInterval(_global.ORCHID.projector.callbacks.checkData, "sqlReturn", 250);
		} else {
			_global.ORCHID.projector.callbacks.getXMLData = function(value) {
				myTrace("got data, callBack");
				_global.ORCHID.projector.callbacks.resultsAction(value);
			}
			if (queryNS.databaseType == "access") {
				mdm.getxmlfromdb(_global.ORCHID.projector.callbacks.getXMLData); 
			} else {
				mdm.mysqlgetresults("","",_global.ORCHID.projector.callbacks.getXMLData); 
			}
		}
	} else {
		mdm.Database.MSAccess.select(queryString.split(",").join("@c@")); 
		if (mdm.Database.MSAccess.error() == false){
			var errorDetails = mdm.Database.MSAccess.errorDetails;
			var errObj = {literal:"dbError", detail:errorDetails};
			_global.ORCHID.root.controlNS.sendError(errObj);
			stop();
		} else {
			var myResults = mdm.Database.MSAccess.getXML();
			resultsAction(myResults);
		}
	}
}
// Common handling of the query, with no results
querySendNoLoad = function(queryString) {	
	//myTrace("sendAndLoad");
	if (_global.ORCHID.projector.version < 2.5) {
		_global.ORCHID.projector.variables.doingWhat = "dbCall";
		if (queryNS.databaseType == "access") {
			mdm.rundbquery(queryString.split(",").join("@c@"));
		} else {
			myTrace("query: " + queryString.split(",").join("@c@"));
			mdm.mysqlquery(queryString.split(",").join("@c@"), "success"); 
		}
	} else {
		mdm.Database.MSAccess.select(queryString.split(",").join("@c@")); 
		if (mdm.Database.MSAccess.error() == false){
			var errorDetails = mdm.Database.MSAccess.errorDetails;
			var errObj = {literal:"dbError", detail:errorDetails};
			_global.ORCHID.root.controlNS.sendError(errObj);
			stop();
		} else {
			var myResults = mdm.Database.MSAccess.getXML();
			resultsAction(myResults);
		}
	}
}

// query code for Flash Studio Pro database access
queryNS.FSPXMLtoObject = function(row) {
	var rowObject =	new Object();
	for (var field in row.childNodes) {
		//myTrace(row.childNodes[field].nodeName + "=" + String(row.childNodes[field].firstChild.nodeValue));
		rowObject[row.childNodes[field].nodeName] = String(row.childNodes[field].firstChild.nodeValue);
	}
	return rowObject;	
}
// v6.4 3 Mirror function to parse results in delimitted form. Assume delimitter is ,
// But you will not get back any column names, so you have to create your receiving row object first
// I think that RM has a more sophisticated version of this that strips away things like COUNT(*) As Cnt to just give the name Cnt
queryNS.MDMDelimittedtoObject = function (data) {
	//myTrace("row=" + data);
	var rowObject = new Object();
	var fields = data.split(",");
	var names = queryNS.thisQuery.fieldNames.split(",");
	for (var i in names) {
		//trace(myRow.childNodes[field].nodeName + "=" + myRow.childNodes[field].firstChild.nodeValue);
		//myTrace("field." + names[i] + "=" + String(fields[i]));
		rowObject[names[i]] = String(fields[i]);
	}
	return rowObject;	
}
// MDM information - how to get column names from a table. Assume mdm script 2 I guess
// Included here for reference only
/*
function getColumnsData():Void {
	var query = "SHOW COLUMNS FROM city FROM "+conn.database;
	mdm.mysqlquery(query, function (success) {
							if (success == "true") {
								parseData();
							} else {
								mdm.prompt(success);
							}
						});
	}
function parseData() {
	var fieldDelimiter = "|field|";
	var rowDelimiter = "|row|";
	mdm.mysqlgetresults(fieldDelimiter, rowDelimiter, function (result) {
													mdm.prompt(result);});
}
*/
// a function for making sure real dates are formatted to standard Clarity for writing
// to text fields in the database
queryNS.dateToDBString = function(tN) {
	return tN.getFullYear() + "-" + queryNS.zeroPad(Number(tN.getMonth()) + 1) + "-" + queryNS.zeroPad(tN.getDate()) + " " + queryNS.zeroPad(tN.getHours()) + ":" + queryNS.zeroPad(tN.getMinutes()) + ":" + queryNS.zeroPad(tN.getSeconds());	
}
queryNS.zeroPad = function(num) {
	if (num < 10) {
		return "0" + num;
	} else {
		return String(num);
	}
}
// v6.4.1.5 getting quote marks correctly into the database
queryNS.dequote = function(thisString) {
	return unescape(thisString).split("'").join("\'").split('"').join("@q@"); 
}
// v6.4.1.5 coping with quotes and colons! Taken from MDM forums - Peter Blaze
// All we are trying to cope with is a SQL where course name may have quotes, and I suppose
// colons, and then it is followed by date which WILL have colons.
// The rule seems to be that if you have an odd number of quotes, escape the colon(s).
queryNS.escapeColonChar = function(txt) {
	var countSingleQuotes = txt.split("'").length - 1;
	if (countSingleQuotes/2 != Math.floor(countSingleQuotes/2)) {
		txt = txt.split(":").join("::");
	}
	return txt;
}
//v6.4.1.5 Trying to catch db errors that skip past the general exception handler
queryNS.onSQLErrorHandler = function(error) {
	if (error == "true") {
		if (queryNS.databaseType == "access") {
			mdm.dberror_details(queryNS.onSQLErrorDetails);
		} else {
			mdm.mysqlgetlasterror(queryNS.onSQLErrorDetails); 
		}
	}
}
queryNS.onSQLErrorDetails = function(errors) {
	myTrace("mdm:sqlerror: " + errors);
}
// this is a master function that will take the query as XML,
// work out which db it wants to connect to, make the connection then
// parcel out the rest of the query for processing and then create the XML result
// typical input would be: <query method="getRMSettings" cacheVersion="1063258669375" />
sendQuery = function(queryXML, resultXML) {
	// since we have to have so many callbacks when dealing with the db, save
	// the ultimate one (resultXML) at the module level so you don't need
	// to pass it to everything.
	queryNS.resultXML = resultXML;
	
	//myTrace("in sendQuery, go back to " + queryNS.resultXML.whoami);
	// firstly build a query object and call to connect to a database
	// Note: what is the purpose of a loop here - can the code cope if there
	// are two queries formatted in the XML? I doubt it.
	for (var node in queryXML.childNodes) {
		var tN = queryXML.childNodes[node];
		//myTrace("node=" + tN.toString());
		// read the query node
		this.queryNS.thisQuery = new Object();
		this.queryNS.thisQuery.buildString = "";
		if (tN.nodeName == "query") {
			//myTrace("run query=" + tN.toString());
			// pull out all attributes that have been sent
			for (var attrib in tN.attributes) {
				this.queryNS.thisQuery[attrib] = tN.attributes[attrib];
				//myTrace("adding " + attrib + "=" + this.queryNS.thisQuery[attrib]);
			}
			// there just might be something sent not as an attribute as well!
			if (tN.firstChild.nodeValue != "") {
				//myTrace("sentData=" +tN.firstChild.nodeValue); 
				// Since the contents of this might include all sorts, it needs
				// to be escaped or quoted or something
				// v6.4.3 But this is causing problems with scratch pad - although it is essential for apostrophes
				this.queryNS.thisQuery.sentData = escape(tN.firstChild.nodeValue);
				//this.queryNS.thisQuery.sentData = tN.firstChild.nodeValue;
			}
			// v6.3.4 If no rootID is sent, need to set it to 0 as default
			if (this.queryNS.thisQuery.rootID=="" || this.queryNS.thisQuery.rootID==undefined) {
				this.queryNS.thisQuery.rootID = 0;
			}
			//myTrace("query.rootID=" + this.queryNS.thisQuery.rootID + " query.method=" + this.queryNS.thisQuery.method);
			// Once the query is created, we need to know which db to focus on
			// v6.5.6.5 Since we add new queries, this rather stupid switch goes wrong and queries teh .mdb database!
			/*
			switch (this.queryNS.thisQuery.method.toUpperCase()) {
			case "GETRMSETTINGS":
			case "STARTSESSION":
			case "STOPSESSION":
			case "WRITESCORE":
			case "GETSCORES":
			case "GETSCRATCHPAD":
			case "SETSCRATCHPAD":
			case "STOPUSER":
			case "STARTUSER":
			case "ADDNEWUSER":
			case "GETUSERS":
			//case "GETNEWUSER":
			case "COUNTUSERS":
				// v6.4.2.8 comment then
				//var targetDB = "score";
				//break;
			case "HOLDLICENCE":
			case "DROPLICENCE":
			case "GETLICENCESLOT":
			case "FAILLICENCESLOT":
				// v6.4.2.8 for comparative reporting
			case "GETALLSCORES":
				// v6.4.2.8 calls for certificate
			case "GETGENERALSTATS":
			//case "GETEXERCISESCORE":
			//case "INSERTDETAIL":
			//case "GETSCOREDETAIL":
			//case "COUNTSCOREDETAILS":
				// The only calls that just need the licence table
				// v6.4.2 Move all to score table
				var targetDB = "score";
				break;
			}
			*/
			var targetDB = "score";
			// First of all we need to make the db connection
			// v6.4.3 mdm script 2 - no need for callback - revert to 1
			var thisCallBack = new Object();
			//thisCallBack.myName = "Adrian";
			thisCallBack.master = this;
			thisCallBack.connectedCallBack = function(scope, success) {
				//myTrace("in callback of " + scope.myName + " for type=" + type);
				if (success) {
					myTrace("db connection OK, go on");
					scope.master.makeQueryDetail();
				} else {
					//myTrace("cannot connect to " + _root.FSPdbFileName);
					myTrace("cannot (re)connect to " + scope.master.dbFileName);
				}
			}
			
			// this is a fixed variable that the query will use
			//_root.FSPdbFileName = _global.ORCHID.paths.root + _global.ORCHID.paths.student + targetDB + ".mdb";
			// v6.4.2 Projector running CE programs
			// use better filename
			//this.dbFileName = _global.ORCHID.paths.root + _global.ORCHID.paths.student + targetDB + ".mdb";			
			this.dbFileName = _global.ORCHID.paths.dbPath + targetDB + ".mdb";
			//myTrace("sendQuery:check connection to " + dbFileName);
			// v6.4.3 mdm script 2 - no need for callback - revert to 1
			this.dbConnect(this.dbFileName, thisCallBack, "connectedCallBack");
			//if (this.dbConnect(this.dbFileName)) {
			//	this.makeQueryDetail();
			//}
		}
	}
}
makeQueryDetail = function() {
	// Now parcel out the query creation
	//myTrace("query for " + this.queryNS.thisQuery.method);
	switch (this.queryNS.thisQuery.method.toUpperCase()) {
	case "GETLICENCESLOT":
		getLicenceSlot();
		break;
	case "HOLDLICENCE":
		updateLicenceSlot();
		break;
	case "DROPLICENCE":
		dropLicenceSlot();
		break;
	case "FAILLICENCESLOT":
		failLicenceSlot();
		break;
	case "GETRMSETTINGS":
		getRMSettings();
		break;
	case "STARTUSER":
		// this is called by Orchid when someone tries to log on,
		// first you must check if there is a licence slot, then see if the
		// username and password are OK. If anything goes wrong, send
		// back an error object.
		// Since this is all asynchronous, the getLicenceSlot call is
		// made at the end of the getUser;
		// First see if you can find and verify this user's details
		getUser();
		break;
	case "STOPUSER":
		//myTrace("stop user");
		updateSession();
		//var returnCode = _global.ORCHID.dbInterface.dbSharedObject.flush();
		//myTrace("flush gives " + returnCode);
		break;
	case "ADDNEWUSER":
		// When they click the 'new user' button to log on
		//If anything goes wrong, send back an error object
		//returnCode = getLicenceSlot(myQuery)
		var returnCode = addUser()
		// 6.3.4 insert membership as well (has to be done inside addUser
		//if (returnCode) {
		//	// add a membership for this validated user
		//	returnCode = insertMembership()
		//}	
		break;
	// v6.3 To cope with multiple user reporting
	case "GETUSERS":
		getUsers();
		break;
	// v6.3 To find the details of the guy you just added
	//case "GETNEWUSERS":
	//	getNewUser();
	//	break;
	// v6.3.4 new call for counting registered users
	case "COUNTUSERS":
		countUsers();
		break;
	case "STARTSESSION":
		insertSession();
		break;
	case "STOPSESSION":
		updateSession();
		break;
	case "WRITESCORE":
		// be very careful that these two don't clash in the FSP space!
		// There is a problem with MySQL closing connections - 
		// so trigger updateSession from within insertScore?
		insertScore();
		//updateSession();
		break;
	case "GETSCORES":
		// v6.4.2.8 Comparative reporting needs everything as well
		getScores();
		//var returnCode = getScores();
		// Ahh, this has to be done inside getScores due to synchronicity
		//if (returnCode) {
		//	returnCode = getAllScores();
		//}	
		break;
	case "GETALLSCORES":
		// v6.4.2.8 Comparative reporting needs everything as well
		getAllScores();
		break;
	case "GETSCRATCHPAD":
		getScratchPad();
		break;
	case "SETSCRATCHPAD":
		setScratchPad();
		break;
	case "GETGENERALSTATS":
		// v6.4.2.8 For the certificate
		getGeneralStats();
		// v6.5 This was missing, causing a wrong message to be displayed.
		break;
	default:
		myTrace("called projector query with non-method: " + this.queryNS.thisQuery.method);
	}
}
returnQuery = function() {
	// now send back the result as XML
	//myTrace("return to: " + this.queryNS.resultXML.whoami);
	myTrace("return: " + queryNS.thisQuery.buildString,1);
	this.queryNS.resultXML.parseXML("<db>" + queryNS.thisQuery.buildString + "</db>");
	//var thisTime = new Date().getTime();
	//myTrace("parsed into resultXML at " + (thisTime - _global.ORCHID.startTime));
	this.queryNS.resultXML.loaded = true;
	this.queryNS.resultXML.onLoad(true);
	// v6.4.3 How about dropping the database connection after each query?
	// We already set it up in startQuery.
	// v6.4.3 MySQL doesn't work with this closing strategy - it crashes on about the 3rd call although the traces seem
	// to show that it is connected OK.
	if (queryNS.databaseType == "access") {
		dbClose();
	}
}

//
// The real queries
//
getRMSettings = function() {
	// v6.3.4 Change table from T_Admin to T_GroupStructure
	//var queryString = "SELECT * FROM T_Admin WHERE F_RootID=" + queryNS.thisQuery.rootID + ";"
	//if (queryNS.databaseType == "access") {
	//	var queryString = "SELECT * FROM T_GroupStructure WHERE F_GroupID=" + queryNS.thisQuery.rootID + ";";
	//} else {
	// v6.4.3 Since you don't get field names with MySQL, just ask for what you want
	queryNS.thisQuery.fieldNames = "F_LoginOption,F_Verified,F_SelfRegister";
	var queryString = "SELECT " + queryNS.thisQuery.fieldNames + " FROM T_GroupStructure WHERE F_GroupID=" + queryNS.thisQuery.rootID + ";";
	//}
	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			queryNS.thisQuery.buildString += "<settings loginOption='" + rowObject.F_LoginOption + "' verified='" + rowObject.F_Verified + "' selfRegister='" + rowObject.F_SelfRegister + "' />";
			returnQuery();
		}
		if (queryNS.databaseType == "access") {
			//myTrace("in resultsAction with " + myResults);
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){			
				// the default setting is self-register with name only
				// v6.3.5 I really don't think you should keep going!
				//myTrace("nothing returned from query");
				queryNS.thisQuery.buildString += "<error code='xxx' /><settings loginOption='1' verified='0' selfRegister='1' />"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);			
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				queryNS.thisQuery.buildString += "<error code='xxx' /><settings loginOption='1' verified='0' selfRegister='1' />"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}	
	querySendAndLoad(queryString, resultsAction, false);
}

getLicenceSlot = function() {	
	myTrace("in getLicenceSlot");
	// check that the number of licence slots is not zero (invalid)
	if (queryNS.thisQuery.licences <= 0) {
		queryNS.thisQuery.buildString += "<err code='201'>your licence is invalid (0 users)</err>";
		returnQuery();
	}
	// Count the licence slots available (this person may already have one [under what circumstances?])
	// v6.4.2 Update the query with rootID
	// v6.4.3 The online versions don't mention licenceID at all - but they do worry a little about userID. I think for APL accounts
	//if (queryNS.thisQuery.licenceID > 0) {
	//	//_root.FSPdbQueryString = "SELECT COUNT(F_LicenceID) AS RowCount FROM T_Session WHERE F_LicenceID=" + queryNS.thisQuery.licenceID + ";"
	//	var queryString = "SELECT COUNT(F_LicenceID) AS " + queryNS.thisQuery.fieldNames + " FROM T_Licences WHERE F_RootID=" + queryNS.thisQuery.rootID + " AND F_LicenceID=" + queryNS.thisQuery.licenceID + ";"
	//} else {
	//_root.FSPdbQueryString = "SELECT COUNT(F_LicenceID) AS RowCount FROM T_Session";
	queryNS.thisQuery.fieldNames = "RowCount";
	// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
	var queryString = "SELECT COUNT(F_LicenceID) AS " + queryNS.thisQuery.fieldNames + " FROM T_Licences " + 
					"WHERE F_RootID=" + queryNS.thisQuery.rootID + 
					" AND F_ProductCode=" + queryNS.thisQuery.productCode + ";";
	//}

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			var liN = rowObject.RowCount;
			//myTrace("current licence slots occupied=" + liN);
			if (Number(liN) < Number(queryNS.thisQuery.licences)) {
				myTrace((queryNS.thisQuery.licences - liN) + " licences available");
				insertLicence();
				//returnQuery();
			} else {
				// There are no free licences, so check to see if any are getting too old
				findOldLicenceSlots(liN);
				//queryNS.thisQuery.buildString += "<err code='201'>no free licences (" + rowObject.Expr1000 + ")</err>"
				//returnQuery();
			}
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){			
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot read licence table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot read licence table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
findOldLicenceSlots = function(liN) {	
	myTrace("findOldLicenceSlots");
	var tN = new Date();
	tN.setTime(tN.getTime() - (10 * 60 * 1000));
	
	queryNS.thisQuery.queryData = new Object();
	queryNS.thisQuery.queryData.formattedDate = queryNS.dateToDBString(tN);
	queryNS.thisQuery.queryData.liN = liN;
	//myTrace("formattedThen=" + formattedThen);
	//queryNS.thisQuery.buildString += "<note>check licences not updated since " + formattedThen + "</note>"
	// Count the licence slots that are too old
	// v6.4.2 Update query with rootID (SQLServer has a better way to do count licences in one call)
	//_root.FSPdbQueryString = "SELECT COUNT(F_LicenceID) AS RowCount FROM T_Session WHERE F_LastUpdateTime<CDATE('" + formattedThen + "');"
	queryNS.thisQuery.fieldNames = "RowCount";
	// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
	var queryString = "SELECT COUNT(F_LicenceID) AS " + queryNS.thisQuery.fieldNames + " FROM T_Licences " + 
					"WHERE F_RootID=" + queryNS.thisQuery.rootID + 
					" AND F_ProductCode=" + queryNS.thisQuery.productCode + 
					" AND F_LastUpdateTime<CDATE('" + queryNS.thisQuery.queryData.formattedDate + "');"
	//myTrace("query=" + queryString);
	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			// There are some old rows, so delete them
			var oRd = rowObject.RowCount;
			if (oRd > 0) {
				myTrace(oRd + " licences to be deleted as too old");
				// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
				queryString = "DELETE * FROM T_Licences " + 
							"WHERE F_ProductCode=" + queryNS.thisQuery.productCode + 
							" AND F_LastUpdateTime<CDATE('" + queryNS.thisQuery.queryData.formattedDate + "');"
				myTrace("query=" + queryString);
				querySendNoLoad(queryString);
				queryNS.thisQuery.buildString += "<warning>" + oRd + " licence(s) released</warning>"
				if ((queryNS.thisQuery.queryData.liN - oRd) < queryNS.thisQuery.licences) {
					//myTrace("now there is space, so insert");
					insertLicence();
				} else {
					//myTrace("still no space, nothing to do");
					queryNS.thisQuery.buildString +=  "<err code='201'>still not enough free licences (" + queryNS.thisQuery.queryData.liN - oRd + ")</err>"
					returnQuery();
				}
			} else {
				// Nothing is too old, so nothing we can do.
				queryNS.thisQuery.buildString +=  "<err code='201'>no free licences (" + queryNS.thisQuery.queryData.liN + ")</err>"
				returnQuery();
			}
			queryNS.thisQuery.queryData = undefined; // tidy up
		}

		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot read licence table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot read licence table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// Look up the number of licence slots that are now too old
insertLicence = function() {
	myTrace("insertLicence");
	var formattedNow = queryNS.dateToDBString(new Date());
	//myTrace("date/time now = " + formattedNow);
	//formattedNow = "29/03/2004 16:20:01"; // 
	//_root.FSPip = "dock";
		 
	// Let access deal with the date/time? No, this will not work as you need to update it later.
	// The ASP version uses NOW function in ASP. Is it just luck that it goes in YYYY-MM-DD HH:MM:SS?
	// I can't find anyformat that lets actionscript/FSP insert a date.
	//_root.FSPdbInsertString = "INSERT INTO T_Session (F_UserIP, F_StartTime, F_LastUpdateTime) " +
	// v6.4.2 Change the var holding the IP address and add rootID
	//_root.FSPdbInsertString = "INSERT INTO T_Licences (F_UserIP, F_StartTime, F_LastUpdateTime) " +
	//	"VALUES ( '" + _global.ORCHID.projector.ipAddress + "', '" + formattedNow + "', '" + formattedNow + "');" ;
	// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
	//var queryString = "INSERT INTO T_Licences (F_UserIP, F_StartTime, F_LastUpdateTime, F_RootID) " +
	//	"VALUES ( '" + _global.ORCHID.projector.ipAddress + "', '" + formattedNow + "', '" + formattedNow + "', " + queryNS.thisQuery.rootID + ");" ;	
	var queryString = "INSERT INTO T_Licences (F_UserIP, F_StartTime, F_LastUpdateTime, F_RootID, F_ProductCode) " +
					"VALUES ( '" + _global.ORCHID.projector.ipAddress + "', '" + formattedNow + "', '" + formattedNow + "', "  +
					queryNS.thisQuery.rootID + ", " + queryNS.thisQuery.productCode + ");" ;	
	querySendNoLoad(queryString);
	
	// v6.4.2 Change the var holding the IP address
	//_root.FSPdbQueryString = "SELECT MAX(F_LicenceID) AS NewLicenceID FROM T_Session " +
	queryNS.thisQuery.fieldNames = "NewLicenceID";
	var selectQueryString = "SELECT MAX(F_LicenceID) AS " + queryNS.thisQuery.fieldNames + " FROM T_Licences " +
				"WHERE (F_UserIP = '" + _global.ORCHID.projector.ipAddress + "');"
	// FSP cannot let you select based on date - or at least I can't see how!
	//"AND F_StartTime = '" + formattedNow + "');"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			// (the MAX function gives back node NewLicenceID
			if (Number(rowObject.NewLicenceID) > 0) {
				//myTrace("inserted licence");
				// v6.4.2 new var for ip address
				queryNS.thisQuery.buildString += "<licence host='" + _global.ORCHID.projector.ipAddress + "' ID='" + rowObject.NewLicenceID + "' />";
				returnQuery();
			}
		}
		if (queryNS.databaseType == "access") {
			//myTrace("insert licence with " + myResults);
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot write to the licence table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot write to the licence table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(selectQueryString, resultsAction, true);
}
dropLicenceSlot = function() {		
	var queryString = "DELETE * FROM T_Licences WHERE F_LicenceID=" + queryNS.thisQuery.licenceID + ";";
	querySendNoLoad(queryString);
	queryNS.thisQuery.buildString += "<licence id='" + queryNS.thisQuery.licenceID + "'>dropped</licence>";
	returnQuery();
}
updateLicenceSlot = function() {		
	var formattedNow = queryNS.dateToDBString(new Date());
	var queryString = "UPDATE T_Licences SET F_LastUpdateTime='" +formattedNow + "' WHERE F_LicenceID=" + queryNS.thisQuery.licenceID + ";"
	querySendNoLoad(queryString);
	queryNS.thisQuery.buildString += "<licence id='" + queryNS.thisQuery.licenceID + "'>updated</licence>";
	returnQuery();
}
// New call that is simply informative of a student who couldn't secure a licence
// v6.5.4.3 Yiu, new code for F_ReasonCode
// v6.5.4.4 But likely not in the database yet!
failLicenceSlot = function() {
	var nReasonCode 
	nReasonCode = 201;

	var formattedNow = queryNS.dateToDBString(new Date());
	// v6.4.2.4 Use productCode to help with separating different titles for concurrent licences
	//var queryString = "INSERT INTO T_FailSession (F_UserIP, F_StartTime, F_RootID) " +
	//	"VALUES ( '" + _global.ORCHID.projector.ipAddress + "', '" + formattedNow + "', " + queryNS.thisQuery.rootID+ ");" ;

	// v6.5.4.3 Yiu, new code for F_ReasonCode
	// v6.5.4.4 But likely not in the database yet!
	var queryString = "INSERT INTO T_FailSession (" + 
				"F_UserIP, F_StartTime, F_RootID, " +
				//"F_UserID, F_ProductCode, F_ReasonCode) " +
				"F_UserID, F_ProductCode) " +
				"VALUES ( '" + 
				_global.ORCHID.projector.ipAddress + "', '" + 
				formattedNow + "', " + 
				queryNS.thisQuery.rootID + ", " + 
				queryNS.thisQuery.userID + ", " + 
				//queryNS.thisQuery.productCode + ", " + 
				queryNS.thisQuery.productCode + ");";
				//nReasonCode + ");" ;	
	querySendNoLoad(queryString);
	queryNS.thisQuery.buildString += "<note>licence failure has been recorded</note>";
	returnQuery();
}
// Functions for logging a student in
getUser = function() {
	//var thisQuery = this.queryNS.thisQuery;

	// is this an anonymous user (no problem as RMsettings will have allowed it)
	// AR v6.4.2.6 Why was studentID removed from the condition - it is essential
	//if (queryNS.thisQuery.name == "") { // && query.studentID == "") {
	if (queryNS.thisQuery.name == "" && queryNS.thisQuery.studentID == "") {
		myTrace("getUser but no name or id, so anonymous");
		queryNS.thisQuery.buildString += "<user name='' userID='-1' />";
		returnQuery();
		// no need to go any further into the query
		return;
	}
	// make the sql statement
	// v6.3.2 with rootID for multiple databases
	//_root.FSPdbQueryString = "SELECT * FROM T_User WHERE F_UserName='" + queryNS.thisQuery.name + "';";
	//_root.FSPdbQueryString = "SELECT T_User.* " +
	// v6.4.2 Allow this to work on studentID as well.
	if (queryNS.thisQuery.name != "") {
		var searchType = "name";
		if (queryNS.thisQuery.studentID != "") {
			var searchType = "both";
		}
	}
	if (searchType == "name") {			
		var whereClause = "WHERE T_User.F_UserName=\"" + queryNS.dequote(queryNS.thisQuery.name) + "\"";
	} else if (searchType == "both") {			
		var whereClause = "WHERE T_User.F_UserName=\"" + queryNS.dequote(queryNS.thisQuery.name) + "\" AND T_User.F_StudentID=\"" + queryNS.dequote(queryNS.thisQuery.studentID) + "\"";
	} else {
		var whereClause = "WHERE T_User.F_StudentID=\"" + queryNS.dequote(queryNS.thisQuery.studentID) + "\"";
	}

	// v6.4.3 This is messy - it works as F_UserID is the only field in both tables. Be careful!
	queryNS.thisQuery.fieldNames = "F_UserID,F_UserName,F_UserSettings,F_Country,F_Email,F_UserType,F_StudentID,F_Password";
	var queryString = "SELECT T_User." + queryNS.thisQuery.fieldNames + " " +
			"FROM T_User, T_Membership " +
			whereClause +
			" AND T_User.F_UserID = T_Membership.F_UserID " +
			" AND T_Membership.F_RootID=" + queryNS.thisQuery.rootID + ";"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			//myTrace("found password=[" + rowObject.F_Password + "] sent password=[" + queryNS.thisQuery.password + "]");
			if (rowObject.F_Password == queryNS.thisQuery.password ||
				// v6.4 2 Don't check anonymous password
				queryNS.thisQuery.password == "$!null_!$") {

				//myTrace("passwords match");
				//v6.4.2.4 No names/id etc in access database are escaped - by webserver version either.
				//queryNS.thisQuery.buildString += "<user name=\"" + escape(rowObject.F_UserName) + "\" " + 
				//						"country='" + escape(rowObject.F_Country) + "' " +
				//						"studentID='" + escape(rowObject.F_StudentID) + "' />";
				queryNS.thisQuery.buildString += "<user name=\"" + rowObject.F_UserName + "\" " + 
										"userID='" + rowObject.F_UserID + "' " +
										"userSettings='" + rowObject.F_UserSettings + "' " +
										"country='" + rowObject.F_Country + "' " +
										"email='" + rowObject.F_Email + "' " +
										//"className='" + rowObject.F_Class + "' " + 
										"userType='" + rowObject.F_UserType + "' " +
										"studentID='" + rowObject.F_StudentID + "' />";
				// v6.4.2.5 We need the userID to get the MGS (well, it is better than the name anyway)
				queryNS.thisQuery.userID = rowObject.F_UserID;
				// v6.4.2.5 Also find the MGS information for this user before you go back
				//returnQuery();
				myTrace("now get MGS");
				getMGS();
			} else {
				queryNS.thisQuery.buildString += "<err code='204'>password does not match</err>";
				returnQuery();
			}
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){			
				// this happens when the select finds no matching users, this is not an error
				queryNS.thisQuery.buildString += "<err code='203'>no such user</err>";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);			
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this happens when the select finds no matching users, this is not an error
				queryNS.thisQuery.buildString += "<err code='203'>no such user</err>";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// v6.4.2.5 MGS - find this through the group
getMGS = function() {

	// v6.4.2.6 If there is no MGS fields in the database, just return false for MGS.
	// This requires change to controlFrame2 which does mdm error handling.
	
	// Form the SQL - first look in the group record for this user
	queryNS.thisQuery.fieldNames = "F_GroupParent,F_EnableMGS,F_MGSName";
	var queryString = "SELECT T_Groupstructure." + queryNS.thisQuery.fieldNames + " " +
			"FROM T_Groupstructure, T_Membership, T_User " +
			" WHERE T_User.F_UserID="+queryNS.thisQuery.userID+
			" AND T_User.F_UserID=T_Membership.F_UserID AND T_Membership.F_GroupID=T_Groupstructure.F_GroupID" +
			" AND T_Membership.F_RootID=" + queryNS.thisQuery.rootID + ";"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			myTrace("getMGS.resultsAction.process enabled=" + rowObject.F_EnableMGS);
			if (rowObject.F_EnableMGS == "1") {
				queryNS.thisQuery.buildString += "<MGS name=\"" + rowObject.F_MGSName + "\" " + 
										"enabled='true' />";
				returnQuery();
			} else {
				// At this point I should check the parent group (recursively) until I hit an MGS or the top
				// but for now I am just going to send back false
				// v6.4.2.5 Now look up the parent to see if that has an MGS
				getMGSOfParent(rowObject.F_GroupParent);
				//queryNS.thisQuery.buildString += "<MGS enabled='false' />";
				//returnQuery();
			}
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){			
				// this should never happen, it means the database doesn't have the MGS fields
				//queryNS.thisQuery.buildString += "<err code='203'>no MGS fields</err>";
				myTrace("getMGS.resultsAction.error no MGS fields in db");
				// v6.4.2.6 Now come back here from MGS field database error, but the error handling hangs around
				// and impacts onto the next calls (licence slot)
				queryNS.thisQuery.buildString += "<MGS enabled='false' />";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);			
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this should never happen, it means the database doesn't have the MGS fields
				//queryNS.thisQuery.buildString += "<err code='203'>no MGS fields</err>";
				queryNS.thisQuery.buildString += "<MGS enabled='false' />";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// v6.4.2.5 MGS - find through the group parent
getMGSOfParent = function(groupID) {

	// Form the SQL - look in the group record for this group
	queryNS.thisQuery.fieldNames = "F_GroupParent,F_EnableMGS,F_MGSName,F_GroupID";
	var queryString = "SELECT " + queryNS.thisQuery.fieldNames + " " +
			"FROM T_Groupstructure " +
			" WHERE F_GroupID="+groupID+";"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			myTrace("enabled=" + rowObject.F_EnableMGS);
			if (rowObject.F_EnableMGS == "1") {
				queryNS.thisQuery.buildString += "<MGS name=\"" + rowObject.F_MGSName + "\" " + 
										"enabled='true' />";
				returnQuery();
			// Check to see if you have got to the top of the group heirarchy. If yes, then no MGS
			} else if (rowObject.F_GroupID == rowObject.F_GroupParent) {
					queryNS.thisQuery.buildString += "<MGS enabled='false' />";
					returnQuery();
			} else {
				// but not at the top, so recurse
				getMGSOfParent(rowObject.F_GroupParent);
			}
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){			
				// this should never happen, it means the database doesn't have groups well sorted
				queryNS.thisQuery.buildString += "<err code='203'>no MGS fields</err>";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);			
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this should never happen, it means the database doesn't have groups well sorted
				queryNS.thisQuery.buildString += "<err code='203'>no MGS fields</err>";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// v6.3.4 Finding details of the new user
getNewUser = function() {
	//var thisQuery = this.queryNS.thisQuery;

	// is this an anonymous user (no problem as RMsettings will have allowed it)
	if (queryNS.thisQuery.name == "") { // && query.studentID == "") {
		queryNS.thisQuery.buildString += "<user name='' userID='-1' />";
		returnQuery();
		// no need to go any further into the query
		return;
	}
	// make the sql statement
	// v6.3.2 with rootID for multiple databases
	//_root.FSPdbQueryString = "SELECT * FROM T_User WHERE F_UserName='" + queryNS.thisQuery.name + "';";
	//myTrace("search for highest userID matching " + queryNS.thisQuery.name);
	queryNS.thisQuery.fieldNames = "uid";
	var queryString = "SELECT MAX(F_UserID) AS " + queryNS.thisQuery.fieldNames + " FROM T_User" +
							" WHERE F_UserName=\"" + queryNS.dequote(queryNS.thisQuery.name) + "\";"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			// add this to the stuff you already know
			//myTrace("got uid=" + rowObject.uid);
			queryNS.thisQuery.userID = rowObject.uid;
			queryNS.thisQuery.buildString += "<user name=\"" + queryNS.thisQuery.name + "\" " + 
										"userID='" + queryNS.thisQuery.userID + "' " +
										//"userSettings='" + queryNS.thisQuery.UserSettings + "' " +
										"country='" + queryNS.thisQuery.country + "' " +
										"email='" + queryNS.thisQuery.email + "' " +
										//"className='" + rowObject.F_Class + "' " + 
										"studentID='" + queryNS.thisQuery.studentID + "' />";
			// now you know the userID you can insert the membership (background)
			insertMembership();
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			if (myXML.childNodes[0].childNodes[0] == undefined){			
				//myTrace("empty dataset returned");
				// this happens when the select finds no matching users, this is not an error
				queryNS.thisQuery.buildString += "<err code='203'>no such user</err>";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				//myTrace("empty dataset returned");
				// this happens when the select finds no matching users, this is not an error
				queryNS.thisQuery.buildString += "<err code='203'>no such user</err>";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
addUser = function(query) {
	// first, check to see if this user name already exists
	// (should be just in this root as duplicate names are OK across roots)
	//myTrace("looking for user=" + queryNS.thisQuery.name + " in root=" + queryNS.thisQuery.rootID);
	queryNS.thisQuery.fieldNames = "RowCount";
	var queryString = "SELECT COUNT(F_UserID) AS " + queryNS.thisQuery.fieldNames + " FROM T_User WHERE F_UserName=\"" + queryNS.dequote(queryNS.thisQuery.name) + "\";";

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			// if there is a result, this user already exists
			if (rowObject.RowCount > 0) {
				queryNS.thisQuery.buildString += "<err code='206'>a user with this name already exists</err>";
				returnQuery();
			} else {
				// otherwise we can insert this user
				// v6.4.2 Add usertype
				//_root.FSPdbInsertString = "INSERT INTO T_User (F_UserName, F_Password, F_StudentID, F_Country, F_Email) " +
				queryString = "INSERT INTO T_User (F_UserName, F_Password, F_StudentID, F_Country, F_Email, F_UserType) " +					 
									"VALUES ( \"" + queryNS.dequote(queryNS.thisQuery.name) + "\", " +
									"\"" + queryNS.dequote(queryNS.thisQuery.password) + "\", " +
									"\"" + queryNS.dequote(queryNS.thisQuery.studentID) + "\", " +
									//"'" + queryNS.thisQuery.className + "', " +
									"\"" + queryNS.dequote(queryNS.thisQuery.country) + "\", " +
									//"'" + queryNS.thisQuery.email + "');"
									"\"" + queryNS.dequote(queryNS.thisQuery.email) + "\", 0);"
				querySendNoLoad(queryString);
				getNewUser();
			}
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){
				// this is an error
				queryNS.thisQuery.buildString += "<err code='211'>cannot read user records</err>";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);	
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this is an error
				queryNS.thisQuery.buildString += "<err code='211'>cannot read user records</err>";
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// v6.3.4 Add membership
insertMembership = function() {
	var queryString = "INSERT INTO T_Membership (F_UserID, F_GroupID, F_RootID) " +
							"VALUES ( " + queryNS.thisQuery.userID + ", " + 
							queryNS.thisQuery.rootID + ", " +
							queryNS.thisQuery.rootID + ");";
	querySendNoLoad(queryString);
	queryNS.thisQuery.buildString += "<note>added membership</note>";
	
	// v6.4.2.5 Also find the MGS information for this user before you go back
	//returnQuery();
	myTrace("now get MGS");
	getMGS();
}

// functions for inserting and updating sessions.
insertSession = function() {
	_global.ORCHID.startTime = new Date().getTime();
	// Count the number of sessions the user has already started
	// This is not critical, but we do like to know it
	// Note: using AS XXX replaces the Expr1000 that access/SQL sends back otherwise
	// v6.4.3 Just do it for by course
	queryNS.thisQuery.fieldNames = "RecordCount";
	var queryString = "SELECT COUNT(*) AS " + queryNS.thisQuery.fieldNames + " FROM T_Session WHERE F_UserID=" + queryNS.thisQuery.userID + 
					" AND F_CourseID=" + queryNS.thisQuery.courseID + ";"
	//myTrace("insertSession query");
	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			//myTrace("insertSession.count=" + Number(rowObject.RecordCount));
			var formattedNow = queryNS.dateToDBString(new Date());
			// v6.4.2 Switch from course name to course ID
			// But we have to do both whilst RM is still in old mode
			//_root.FSPdbInsertString = "INSERT INTO T_Session (F_UserID, F_CourseName, F_StartDateStamp) " +
			//				"VALUES ( " + queryNS.thisQuery.UserID + ", '" + queryNS.thisQuery.CourseName + "', '" + formattedNow + "');" ;
			// It is the colon in the date that when you have a quote in the course name screws up.
			// v6.5 Remove courseName and add in rootID. But not 100% sure RM doesn't still use courseName
			// And since this is irrelevant for network versions, don't actually implement yet until sure that database has the field
			// v6.5.4.4 At some point we need to add  F_Duration to this insert and to the score.mdb too.
			queryString = "INSERT INTO T_Session (F_CourseName, F_UserID, F_CourseID, F_StartDateStamp) " +
			//queryString = "INSERT INTO T_Session (F_CourseName, F_UserID, F_CourseID, F_RootID, F_StartDateStamp) " +
							"VALUES ( \"" + queryNS.dequote(queryNS.thisQuery.courseName) + "\", " + 
										queryNS.thisQuery.userID + ", " + 
										queryNS.thisQuery.courseID + ", " + 
			//							queryNS.thisQuery.rootID + ", " + 
										// v6.5.4.4 make sure that both sides of the date have a quote
										"\"" + formattedNow + "\");" ;
			// v6.3.5 Move to ZINC - does this help with the colon/quote problem? No
			// The MDM boards discuss this problem. Due to : being a SQL char
			// One solution suggested compiled procedures, another doubling the colon. Try it.
			// OK - Peter Blaze from MDM proposed that if you have a quote of some sort, then SQL
			// is going to interpret the : as a modifier. So if the quote is there, escape the :
			// if not, don't. Have to check and see what happens with 2 quotes! Goes wrong. 
			// So the escaping must be based on odd numbers of quotes. It would then be prudent
			// to catch any error just in case they have a really complex course name.
			//myTrace("insertSession.sql=" + queryString);
			queryString = queryNS.escapeColonChar(queryString);
			querySendNoLoad(queryString);
			// Send the session count to the next function for reporting back
			getSessionID(Number(rowObject.RecordCount), formattedNow);	
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot read session table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				//myTrace("got session count, keep going to insert");
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot read session table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// Look up the new sessionID
getSessionID = function(numSessions, startTime) {	
	//myTrace("getSessionID")
	// Find the maximum session ID (this should be the one you just added!)
	// v6.4.1.5 If the INSERT didn't work, this is just going to give you the last session
	// It would be better to give you back nothing and disable progress reporting for this session
	// in total - hopefully with a message. Change the NewSessionID in teh XML bit later as well.
	//_root.FSPdbQueryString = "SELECT MAX(F_SessionID) AS NewSessionID FROM T_Session WHERE F_UserID=" + queryNS.thisQuery.UserID + ";" 
	queryNS.thisQuery.fieldNames = "F_SessionID";
	var queryString = "SELECT " + queryNS.thisQuery.fieldNames + " FROM T_Session WHERE F_UserID=" + queryNS.thisQuery.userID + 
																" AND F_StartDateStamp='" + startTime + "';" 
	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			// The MAX will hold the new sessionID
			//myTrace("your progress index is " + this.progressIdx + " and sessionNum=" + sessionNum);
			//queryNS.thisQuery.buildString += "<session id='" + rowObject.NewSessionID + "' count='" + this.numSessions + "' startTime='" + this.startTime + "'/>"
			queryNS.thisQuery.buildString += "<session id='" + rowObject.F_SessionID + "' count='" + numSessions + "' startTime='" + startTime + "'/>"
			returnQuery();
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot read session table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this is an error
				queryNS.thisQuery.buildString += "<err>Cannot read session table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, true);
}
// Close, or at least update, the session record with the time now
updateSession = function(query) {
	var formattedNow = queryNS.dateToDBString(new Date());
	var queryString = "UPDATE T_Session SET F_EndDateStamp='" + formattedNow + 
						"' WHERE F_SessionID=" + queryNS.thisQuery.sessionID + ";";
	querySendNoLoad(queryString);
	queryNS.thisQuery.buildString += "<session>updated</session>";
	returnQuery();
}

getScores = function() {
	myTrace("getScores");
	//_global.ORCHID.startTime = new Date().getTime();
	// Retrieve all relevant scores from the database
	// Handle the TEACHER login (will it be painfully slow?)
	// v6.3.4 New way of knowing teacher
	// v6.4.2.8 Drop the teacher login
	//if (queryNS.thisQuery.UserID == 1) {
	var scoreTableNames = "F_ExerciseID,F_DateStamp,F_UnitID,F_Score,F_TestUnits,F_Duration,F_ScoreCorrect,F_ScoreWrong,F_ScoreMissed";
	if (_global.ORCHID.user.teacher) {
		// Teachers want to see everybodies score, and know their name
		// v6.4.2 Switch from courseName to courseID
		// v6.4.3 But they only want to know users in their group or subgroups. Complicated!! But at least base it on rootID
		// Actually not complicated. You only need this function if you don't have RM. But if you don't have RM, you can't have a group structure!
		// So here, simply give results for your group. Which you can pick up when you login and save in ORCHID.user.groupID
		// v6.4.3 This SQL fieldNames is duplicated due to the 'AS alias' syntax
		var userTableAlias = "thisUserID";
		queryNS.thisQuery.fieldNames = scoreTableNames + "," + userTableAlias;
		var queryString = "SELECT " + scoreTableNames + ", T_User.F_UserID AS " + userTableAlias + " FROM T_Score, T_Session, T_User" +
						" WHERE ((T_Score.F_SessionID=T_Session.F_SessionID)" +
						" AND (T_Score.F_UserID=T_User.F_UserID) " +
						//" AND (T_Session.F_CourseName='" + queryNS.thisQuery.CourseName + "'))" +
						" AND (T_Session.F_CourseID=" + queryNS.thisQuery.courseID + "))" +
						" ORDER BY T_User.F_UserID;"
	} else {
		queryNS.thisQuery.fieldNames = scoreTableNames;
		var queryString = "SELECT T_Score." + queryNS.thisQuery.fieldNames + " FROM T_Score, T_Session " +
						"WHERE T_Score.F_UserID=" + queryNS.thisQuery.userID + 
						" AND T_Score.F_SessionID=T_Session.F_SessionID" +
						//" AND T_Session.F_CourseName='" + queryNS.thisQuery.courseName + "';"
						" AND T_Session.F_CourseID=" + queryNS.thisQuery.courseID + 
						// v6.4.3 Why was ordering missing?
						" ORDER BY T_Score.F_DateStamp;"
	}
	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			//myTrace("userID=" + rowObject.T_User.F_UserID
			// check that it is a valid score record
			if (rowObject.F_ExerciseID != "") {
				scoreNode = "<score dateStamp='" + rowObject.F_DateStamp + "' " 
				// If it is a teacher looking - then need to save the UserID as well in the XML
				// v6.3.4 New way of knowing teacher
				//if (this.userID == 1) {
				// v6.4.2.8 Always send back the userID (even though it is just from the original query)
				//if (_global.ORCHID.user.teacher) {
					scoreNode += "userID='" + queryNS.thisQuery.userID + "' " 
				//}
				// v6.4.3 send back exerciseID not itemID
				scoreNode += "itemID='" + rowObject.F_ExerciseID + "' " +
				//scoreNode += "exerciseID='" + rowObject.F_ExerciseID + "' " +
							"unit='" + rowObject.F_UnitID + "' " +
							"score='" + rowObject.F_Score + "' " +
							//v6.3.5 AGU Added in testUnits to be saved
							"testUnits='" + rowObject.F_TestUnits + "' " +
							"duration='" + rowObject.F_Duration + "' " +
							"correct='" + rowObject.F_ScoreCorrect + "' " +
							"wrong='" + rowObject.F_ScoreWrong + "' " +
							"skipped='" + rowObject.F_ScoreMissed + "' " + "/>";

				queryNS.thisQuery.buildString += scoreNode;
			}
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			var numScores = myXML.childNodes[0].childNodes.length;
			myTrace("number of scores = " + numScores);
			// check to see that the returned dataset is not empty
			if (numScores == 0){
				queryNS.thisQuery.buildString += "<note>No scores for this user</note>"
				// v6.4.2.8 Now also call to getAllScores for comparative progress reporting
				//returnQuery();
				getAllScores();
			} else {
				// Put the nodes into an object
				var scoreNode = "";
				for (var i=0; i<numScores; i++) {
					var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[i]);
					processResults(rowObject);
				}
				//var thisTime = new Date().getTime();
				//myTrace("parsed into buildString at " + (thisTime - _global.ORCHID.startTime));
				// v6.4.2.8 Now also call to getAllScores for comparative progress reporting
				//returnQuery();
				getAllScores();
			}
		} else {
			if (myResults == "") {
				queryNS.thisQuery.buildString += "<note>No scores for this user</note>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				for (var i=0; i<rows.length; i++) {
					var rowObject = queryNS.MDMDelimittedtoObject(rows[i]);
					processResults(rowObject);
				}
				returnQuery();
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// v6.4.2.8 new function for comparative reporting
getAllScores = function() {
	myTrace("getAllScores");
	// Retrieve all relevant scores from the database
	// v6.4.2.8 Average (and count) for all scores for each exercise. Used for comparison against the individual
	// so exclude this user from the counting - and exclude non-scored exercises
	// Pass the rootID or the groupID to narrow the range
	var scoreTableNames = "F_ExerciseID,F_UnitID,AvgScore,NumberDone";
	queryNS.thisQuery.fieldNames = scoreTableNames;
	// Note that as root is not used, we don't need the membership table to be involved either
	// unless we add the groupID at some point!
	var queryString = "SELECT SC.F_ExerciseID, SC.F_UnitID, AVG(SC.F_Score) AS AvgScore, COUNT(*) AS NumberDone  " +
				"FROM T_Score as SC, T_Session as SE " +
				"WHERE SE.F_UserID<>"  + queryNS.thisQuery.userID + 
				"AND SE.F_CourseID="  + queryNS.thisQuery.courseID + 
				"AND SC.F_Score>=0 " +
				"AND SC.F_SessionID=SE.F_SessionID " +
				"GROUP BY SC.F_ExerciseID, SC.F_UnitID " +
				"ORDER BY SC.F_ExerciseID;"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			var scoreNode = "";
			scoreNode = "<score itemID='" + rowObject.F_ExerciseID + "' " +
							"unit='" + rowObject.F_UnitID + "' " +
							"score='" + rowObject.AvgScore + "' " +
							"count='" + rowObject.NumberDone + "' " + "/>";
			queryNS.thisQuery.buildString += scoreNode;
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			var numScores = myXML.childNodes[0].childNodes.length;
			myTrace("number of scores = " + numScores);
			// check to see that the returned dataset is not empty
			if (numScores == 0){
				queryNS.thisQuery.buildString += "<note>No scores for everyone else</note>"
				returnQuery();
			} else {
				// Put the nodes into an object
				for (var i=0; i<numScores; i++) {
					var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[i]);
					processResults(rowObject);
				}
				//var thisTime = new Date().getTime();
				//myTrace("parsed into buildString at " + (thisTime - _global.ORCHID.startTime));
				returnQuery();
			}
		} else {
			if (myResults == "") {
				queryNS.thisQuery.buildString += "<note>No scores for everyone else</note>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				for (var i=0; i<rows.length; i++) {
					var rowObject = queryNS.MDMDelimittedtoObject(rows[i]);
					processResults(rowObject);
				}
				returnQuery();
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}

insertScore = function(query) {
	var formattedNow = queryNS.dateToDBString(new Date());
	//v6.3.5 AGU Added in testUnits to be saved
	//			queryNS.thisQuery.itemID + ", " + queryNS.thisQuery.sessionID + ", " +
	var queryString = "INSERT INTO T_Score (F_UserID, F_DateStamp, F_UnitID, F_ExerciseID, F_SessionID, " +
				"F_Score, F_ScoreCorrect, F_ScoreWrong, F_ScoreMissed, F_Duration, F_TestUnits) " +
				"VALUES ( " + queryNS.thisQuery.userID + ", " +
				"'" + formattedNow + "', " + queryNS.thisQuery.unitID + ", " +
				queryNS.thisQuery.itemID + ", " + queryNS.thisQuery.sessionID + ", " +
				// v6.4.3 Don't switch field names yet
				//queryNS.thisQuery.exerciseID + ", " + queryNS.thisQuery.sessionID + ", " +
				queryNS.thisQuery.score + ", " + queryNS.thisQuery.correct + ", " + queryNS.thisQuery.wrong + ", " + queryNS.thisQuery.skipped + ", " +
				queryNS.thisQuery.duration + ", " + "'" + queryNS.thisQuery.testUnits + "'" + ");";
	querySendNoLoad(queryString);
	queryNS.thisQuery.buildString += "<score status='true' />";
	// v6.4.2.4 From here, trigger updateSession directly
	//returnQuery();
	updateSession();
}

getScratchPad = function(query) {
	// Read the scratchPad table
	queryNS.thisQuery.fieldNames = "F_ScratchPad";
	var queryString = "SELECT " + queryNS.thisQuery.fieldNames + " FROM T_User WHERE F_UserID=" + queryNS.thisQuery.userID + ";" 
	
	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			//myTrace("from db=" + rowObject.F_ScratchPad);
			//myTrace("unescaped=" + unescape(rowObject.F_ScratchPad));
			//if (queryNS.databaseType == "access") {
				queryNS.thisQuery.buildString += "<scratchPad>" + unescape(rowObject.F_ScratchPad) + "</scratchPad>";
			//} else {
			//	queryNS.thisQuery.buildString += "<scratchPad>" + rowObject.F_ScratchPad + "</scratchPad>";
			//}
			returnQuery();
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){
				// v6.4.2 Except if the userID is the anonymous one, in which case the user 
				// doesn't exist, but we can use this to show that scratch pad is temporary
				if (queryNS.thisQuery.userID == -1) {
					
					//queryNS.thisQuery.buildString += "<scratchPad>The scratch pad cannot be saved in this version.</scratchPad>"
					//queryNS.thisQuery.buildString += "<scratchPad>You have not signed in with a registered name, so you cannot save your Scratch Pad.</scratchPad>"
					queryNS.thisQuery.buildString += "<scratchPad>" + _global.ORCHID.literalModelObj.getLiteral("anonScratchPad", "messages") + "</scratchPad>";
				} else {
					// this is an error
					queryNS.thisQuery.buildString += "<err>No such user</err>"
				}
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// v6.4.2 Except if the userID is the anonymous one, in which case the user 
				// doesn't exist, but we can use this to show that scratch pad is temporary
				if (queryNS.thisQuery.userID == -1) {
					//queryNS.thisQuery.buildString += "<scratchPad>The scratch pad cannot be saved in this version.</scratchPad>"
					queryNS.thisQuery.buildString += "<scratchPad>" + _global.ORCHID.literalModelObj.getLiteral("anonScratchPad", "messages") + "</scratchPad>";
				} else {
					// this is an error
					queryNS.thisQuery.buildString += "<err>No such user</err>"
				}
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
setScratchPad = function() {
	//if (queryNS.databaseType == "access") {
	//	var safeText = escape(queryNS.thisQuery.sentData);
	//} else {
		var safeText = queryNS.thisQuery.sentData;
	//}
	//myTrace("try to add:" + safeText);
	var queryString = "UPDATE T_User SET F_ScratchPad='" + safeText + 
						"' WHERE F_UserID=" + queryNS.thisQuery.userID + ";"
	querySendNoLoad(queryString);
	queryNS.thisQuery.buildString += "<scratchPad>updated</scratchPad>";
	returnQuery();
}

// v6.3 New method for multiple user reporting
getUsers = function(query) {
	// Retrieve all users from the database
	// v6.3.4 for rootID
	// v6.3.5 AGU, Add table qualifier to SELECT T_User.F_UserID, T_User.F_UserName
	queryNS.thisQuery.fieldNames = "F_UserID, F_UserName, F_UserType";
	var queryString = "SELECT T_User." + queryNS.thisQuery.fieldNames + " " +
			"FROM T_User, T_Membership " +
			"WHERE T_User.F_UserID = T_Membership.F_UserID " +
			" AND T_Membership.F_RootID=" + queryNS.thisQuery.rootID + ";"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			// v6.4.3 UserType needs to be sent back
			// v6.4.2.4 Don't escape names for the access database
			//			"name=\"" + escape(rowObject.F_UserName) + "\" " + "/>";
			userNode = "<user ID='" + rowObject.F_UserID + "' " +
						"userType='" + rowObject.F_UserType + "' " +
						"name=\"" + rowObject.F_UserName + "\" " + "/>";
			queryNS.thisQuery.buildString += userNode;
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);

			// v6.4.2.8 Surely I was missing this line?!
			var numUsers = myXML.childNodes[0].childNodes.length;
			
			// check to see that the returned dataset is not empty
			if (numUsers == 0){
				queryNS.thisQuery.buildString += "<note>No users in this database</note>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var userNode = "";
				for (var i=0; i<numUsers; i++) {
					var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[i]);
					processResults(rowObject);
				}
				returnQuery();
			}
		} else {
			if (myResults == "") {
				queryNS.thisQuery.buildString += "<note>No users in this database</note>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				for (var i=0; i<rows.length;i++) {
					var rowObject = queryNS.MDMDelimittedtoObject(rows[i]);
					processResults(rowObject);
				}
				returnQuery();
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// v6.3 New method for counting registered users
countUsers = function() {
	// Retrieve all users from the database
	// v6.3.4 for rootID
	// v6.4.2 Missing table qualifier on F_UserID
	queryNS.thisQuery.fieldNames = "RowCount";
	var queryString = "SELECT COUNT(T_User.F_UserID) AS " + queryNS.thisQuery.fieldNames +
			" FROM T_User, T_Membership" +
			" WHERE T_User.F_UserID = T_Membership.F_UserID" +
			" AND T_Membership.F_RootID=" + queryNS.thisQuery.rootID + ";"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			queryNS.thisQuery.buildString += "<licence users='" + rowObject.RowCount + "' />";
			returnQuery();
		}
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
	
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){			
				// this is an error
				queryNS.thisQuery.buildString += "<err code='208'>Cannot read user table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[0]);
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				// this is an error
				queryNS.thisQuery.buildString += "<err code='208'>Cannot read user table</err>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// v6.4.2.8 New method for certificates
getGeneralStats = function() {
	//myTrace("getGeneralStats");
	queryNS.thisQuery.fieldNames = "F_ExerciseID, maxScore, cntScore, totalScore";
	var queryString = "SELECT F_ExerciseID, MAX( F_Score ) AS maxScore, COUNT( * ) AS cntScore, MAX( F_ScoreCorrect ) AS maxCorrect" +
			" FROM T_Score, T_Session " +
			" WHERE T_Score.F_UserID ="  + queryNS.thisQuery.userID +
			" AND F_Score >=0 " +
			" AND T_Score.F_SessionID = T_Session.F_SessionID " +
			" AND T_Session.F_CourseID=" + queryNS.thisQuery.courseID +
			" AND T_Score.F_ExerciseID>=100" +
			" GROUP BY F_ExerciseID;"

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);

			var statsObject = {avgScored:0, countScored:0, dupScored:0, totalScore:0, totalCorrect:0, countUnScored:0, dupUnScored:0};
			var duplicates=0;
			// check to see that the returned dataset is not empty
			var numRecords = myXML.childNodes[0].childNodes.length;
			myTrace("numGeneralRecords=" + numRecords);
			if (numRecords > 0){
				// Put the nodes into an object
				var userNode = "";
				for (var i=0; i<numRecords; i++) {
					var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[i]);
					//myTrace("this record score=" + rowObject.maxScore + " correct=" + rowObject.maxCorrect + " count=" + rowObject.cntScore);
					statsObject.countScored++;
					statsObject.totalScore += Number(rowObject.maxScore);
					statsObject.totalCorrect += Number(rowObject.maxCorrect);
					duplicates+= Number(rowObject.cntScore);
				}
				//myTrace("all, countScored=" + statsObject.countScored);
				if (statsObject.countScored>0) {
					statsObject.avgScored = statsObject.totalScore / statsObject.countScored;
				}
				if (duplicates>statsObject.countScored) {
					statsObject.dupScored = duplicates - statsObject.countScored;
				}
			}
			// v6.5 You still need to do this even if there are no scored records, otherwise nothing else happens
			// Now get the unscored data
			//myTrace("call to getViewedStats with avgScored=" + statsObject.avgScored);
			getViewedStats(statsObject);
		} else {
			/* Not done yet
			if (myResults == "") {
				queryNS.thisQuery.buildString += "<note>No records in this database</note>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				for (var i=0; i<rows.length;i++) {
					var rowObject = queryNS.MDMDelimittedtoObject(rows[i]);
					processResults(rowObject);
				}
				returnQuery();
			}
			*/
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}
// v6.4.2.8 Extension methods for stats
getViewedStats = function(statsObject) {
	//myTrace("getViewedStats, avgScored=" + statsObject.avgScored);
	queryNS.thisQuery.fieldNames = "F_ExerciseID, maxScore, cntScore";
	var queryString = "SELECT F_ExerciseID, MAX( F_Score ) AS maxScore, COUNT( * ) AS cntScore" +
			" FROM T_Score, T_Session " +
			" WHERE T_Score.F_UserID ="  + queryNS.thisQuery.userID +
			" AND F_Score <0 " +
			" AND T_Score.F_SessionID = T_Session.F_SessionID " +
			" AND T_Session.F_CourseID=" + queryNS.thisQuery.courseID +
			" AND T_Score.F_ExerciseID>=100" +
			" GROUP BY F_ExerciseID;"

	// We need to pass the statsObject (temporary counts) through to the result function - add it to queryNS
	queryNS.thisQuery.statsObject = statsObject;
	
	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		var statsObject = queryNS.thisQuery.statsObject;
		// function for common results processing
		if (queryNS.databaseType == "access") {
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
				
			// check to see that the returned dataset is not empty
			var numRecords = myXML.childNodes[0].childNodes.length;
			myTrace("numViewedRecords=" + numRecords);
			if (numRecords > 0){
				var duplicates = 0;
				statsObject.countUnScored = 0;
				// Put the nodes into an object
				var userNode = "";
				for (var i=0; i<numRecords; i++) {
					var rowObject = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[i]);
					myTrace("this record score=" + rowObject.maxScore + " count=" + rowObject.cntScore);
					statsObject.countUnScored++;
					duplicates+= Number(rowObject.cntScore);
				}
				if (duplicates>statsObject.countUnScored) {
					statsObject.dupUnScored = duplicates - statsObject.countUnScored;
				}
			}
			queryNS.thisQuery.buildString += "<stats total='" + statsObject.totalCorrect +  "' average='" + statsObject.avgScored +  
											"' counted='"  + statsObject.countScored + "' viewed='" + statsObject.countUnScored +
											"' duplicatesCounted='"  + statsObject.dupScored + "' duplicatesViewed='" + statsObject.dupUnScored + "'/>";
			returnQuery();
		} else {
			/* Not done yet
			if (myResults == "") {
				queryNS.thisQuery.buildString += "<note>No records in this database</note>"
				returnQuery();
			} else {
				// Put the nodes into an object
				var rows = myResults.split(";");
				for (var i=0; i<rows.length;i++) {
					var rowObject = queryNS.MDMDelimittedtoObject(rows[i]);
					processResults(rowObject);
				}
				returnQuery();
			}
			*/
		}
	}
	querySendAndLoad(queryString, resultsAction, false);
}


/*
function getGeneralStats (myQuery)
		
	' First find the stats for records that have a score - should just take highest if same exercise done several times
	' See the queryProjector version for a query that does it in one go, viewed and scored.
	Progress.getScoredStats myQuery
	dim avgScored, countScored, dupScored, totalScore, totalCorrect
	dim countUnScored, dupUnScored
	dim duplicates
	if (Progress.rsResult.bof AND Progress.rsResult.eof) then
		avgScored = 0
		countScored = 0
		dupScored = 0
		totalScore = 0
		totalCorrect = 0
	else 
		totalScore=0
		duplicates=0
		countScored = 0
		totalCorrect = 0
		do while not Progress.rsResult.eof
			countScored = countScored + 1
			totalScore = totalScore + Progress.rsResult.fields("maxScore")
			totalCorrect = totalCorrect + Progress.rsResult.fields("totalScore")
			duplicates= duplicates+ Progress.rsResult.fields("cntScore")
			Progress.rsResult.MoveNext
		loop
		avgScored = totalScore / countScored
		dupScored = duplicates - countScored
	end if	
	Progress.CloseRS

	' Then those that are not scored
	Progress.getViewedStats myQuery
	
	if (Progress.rsResult.bof AND Progress.rsResult.eof) then
		countUnScored = 0
		dupUnScored = 0
	else 
		duplicates=0
		countUnScored = 0
		do while not Progress.rsResult.eof
			countUnScored = countUnScored + 1
			duplicates= duplicates+ Progress.rsResult.fields("cntScore")
			Progress.rsResult.MoveNext
		loop
		dupUnScored = duplicates - countUnScored
	end if	
	Progress.CloseRS

	xmlNode = xmlNode & "<stats total='" & totalCorrect &  "' average='" & avgScored &  "' counted='"  & countScored & "' viewed='" & countUnScored &_
			"' duplicatesCounted='"  & dupScored & "' duplicatesViewed='" & dupUnScored & "'/>"
	
	on error goto 0
	getGeneralStats = 0
	
end function
*/
// once this module is loaded, call testWriteMethod for shared object
// (which will use the functions you have just loaded above)
//myTrace("loaded lso query swf, so trigger test method");
//myTrace("db=" + _root.databaseHolder.databaseNS.thisDB.name);
//myTrace("call testWriteMethod from queryProjector");
// v6.3.6 Merge database to main and change NS
//_root.databaseHolder.databaseNS.thisDB.testWriteMethod("access/projector");
_global.ORCHID.root.mainHolder.dbInterfaceNS.thisDB.testWriteMethod("access/projector");

// v6.4.2.4 Is there a customQuery.swf in the brandMovies folder?
// Since we should have plenty of time from this initial loading to when we actually want to call a customQuery
// let's just try to load it here and then when we want we can test.
//this.createEmptyMovieClip("customQueryHolder", queryNS.depth++);
//myTrace("try to load " + _global.ORCHID.paths.brandMovies + "customQuery.swf to " + this.customQueryHolder);
//this.customQueryHolder.loadMovie(_global.ORCHID.paths.brandMovies + "customQuery.swf");
