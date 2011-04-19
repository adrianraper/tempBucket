dbInterfaceNS.connect = function() {
	myTrace("dbInt:connect to the database for licence=" + _global.ORCHID.root.licenceHolder.licenceNS.productType);
	this.thisDB = new dbInterfaceObject();

	//myTrace("database=" + _global.ORCHID.root.licenceHolder.licenceNS.db);
	//v6.4.2 Also allow scripting/db to come from commandLine/Location.ini
	if (_global.ORCHID.root.licenceHolder.licenceNS.db == undefined) {
		//myTrace("no database listed in licence, so overwrite from location");
		if (_global.ORCHID.commandLine.database == undefined) {
			myTrace("no database listed in licence or location");
			// set a default - or should you set an error?
			//_global.ORCHID.root.licenceHolder.licenceNS.db = "LSO";
			// v6.4.2 Yes, an error if you please
			var errObj = {literal:"dbMissing", detail:"No database type has been listed. Please check your licence or setup."};
			//v6.4.2 rootless
			_global.ORCHID.root.controlsNS.sendError(errObj);			
			stop();
		} else {
			_global.ORCHID.root.licenceHolder.licenceNS.db = _global.ORCHID.commandLine.database;
		}
	}
	if (_global.ORCHID.root.licenceHolder.licenceNS.scripting == undefined) {
		if (_global.ORCHID.commandLine.scripting == undefined) {
			myTrace("no scripting listed in licence or location");
			// set a default - or should you set an error?
			//_global.ORCHID.root.licenceHolder.licenceNS.scripting = "Actionscript";
			// v6.4.2 Yes, an error if you please
			var errObj = {literal:"dbMissing", detail:"No scripting type has been listed. Please check your licence or setup."};
			//v6.4.2 rootless
			_global.ORCHID.root.controlsNS.sendError(errObj);			
			stop();
		} else {
			_global.ORCHID.root.licenceHolder.licenceNS.scripting = _global.ORCHID.commandLine.scripting;
		}
	} else {
		// v6.5.5.5 make sure that the scripting from licence is also recorded on commandLine
		_global.ORCHID.commandLine.scripting = _global.ORCHID.root.licenceHolder.licenceNS.scripting;
	}
	
	// v6.3.5 APL uses lso as well as SQL db to store data (anonymous results)
	// so for that product, init the LSO then the real db. This should not clash.
	// v6.4.2 If you are using projector with APL, LSO and projector will clash. So don't do 
	// this split processing as it holds no benefits anyway.
	if (_global.ORCHID.root.licenceHolder.licenceNS.productType.indexOf("Light") >= 0 &&
		_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() != "projector") {
		myTrace("Light, so first load lso");
		this.thisDB.onConnect = function() {
			myTrace("back from lso, so now load real one");
			// second time really go back
			this.onConnect = function() {
				//myTrace("back from real one");
				_global.ORCHID.dbInterface = this;
				_global.ORCHID.root.controlNS.dbConnected();
			}
			var dbScript = _global.ORCHID.root.licenceHolder.licenceNS.db.toLowerCase() + "/" + _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
			this.load(dbScript);
		}
		// v6.4.3 The 6.4.2.4 change means that load is no longer interested in the parameter you pass it, it is only looking
		// at the data held in licenceNS.scripting. So this call will NOT get your queryLSO loaded.
		this.thisDB.load("lso/actionscript");
	} else {
		myTrace("not Light, so just do real");		
		//myTrace("immediately db=" + this.thisDB.name);
		this.thisDB.onConnect = function() {
			_global.myTrace("onConnect");
			// 6.0.6.0 Need to know this earlier
			_global.ORCHID.dbInterface = this;
			//myTrace("go back to control with db as " + this.name);
			// 6.0.6.0 Acknowledge that the database is now connected
			// so that the loading process can keep going
			_global.ORCHID.root.controlNS.dbConnected();
		}
		// 6.0.5.0 different databases are set in the licence
		//thisDB.load("sharedObject");_global.ORCHID.root.licenceHolder.licenceNS.scripting
		//myTrace("got: " + _global.ORCHID.root.licenceHolder.licenceNS.institution.toLowerCase());
		var dbScript = _global.ORCHID.root.licenceHolder.licenceNS.db.toLowerCase() + "/" +  _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
		myTrace("licence says use " + dbScript);
		//this.thisDB.load(dbScript);
		this.thisDB.load(dbScript);
	}
}

// This could end up going to the objectsModule, but it seems a bit different, so leave
// it here for now.
// *****
// DB INTERFACE
// *****
// create an object that controls database access
// 6.0.5.0 this is the master db object, it is called once and sets up/tests
// the connection method. Each call is handled through a separate query object
function dbInterfaceObject() {
	//trace("create dbIntObj");
	//this.name = "Adrian";
}
// v6.4.3 It will be better to keep scripting and database separate since they are starting to merge
dbInterfaceObject.prototype.load = function(dbMethod) {
	// first of all try connecting to a webserver
	// this will automatically cascade through other options
	// for speed, start with the passed method
	//myTrace("db load with " + dbMethod);
	// v6.3.5 For APL, the basic db method will be with an SQL database. But we don't want
	// to write out scores or scratch pad since everyone is anonymous. So use LSO for these
	// functions as this gives the best hint of what you can get with upgrade.
	// The code in xxxx.as will therefore call this object load twice, first with LSO
	// to get that all ready, and then again with SQL variant.
	
	// v6.5.5.1 For measuring performance
	_global.ORCHID.timeHolder.startServerTest = new Date().getTime();
	
	// v6.4.3 Connect by scripting alone
	// v6.4.3 The above change means that load is no longer interested in the parameter you passed it, it is only looking
	// at the data held in licenceNS.scripting. This is a problem for the split query used in APL
	// So allow for that
	if (dbMethod == "lso/actionscript") {
		var thisScripting = "actionscript";
	} else {
		var thisScripting = _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
	}
	//myTrace("load scripting=" + thisScripting);
	//switch (dbMethod) {
	switch (thisScripting) { 
		//case "lso/actionscript": // maybe this should be the default
		case "actionscript": // maybe this should be the default
			// 6.0.6.0 load the functions needed for sharedObject
			_global.ORCHID.root.createEmptyMovieClip("queryHolder", _global.ORCHID.root.controlNS.depth++);
			if (_global.ORCHID.online){
				var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("queryLSO");
			} else{
				var cacheVersion = ""
			}
			myTrace("load " + "queryLSO.swf" + cacheVersion);
			//_root.queryHolder.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + "queryLSO.swf" + cacheVersion);
			_global.ORCHID.root.queryHolder.loadMovie(_global.ORCHID.paths.movie + "queryLSO.swf" + cacheVersion);
			// the write method test will be called from queryLSO (I guess)
			//this.testWriteMethod("lso/actionscript");
			break;
		//case "access/projector":
		case "projector":
			// v6.3.5 Move to ZINC, with callbacks for db stuff
			// You cannot use objects for holding FSP variables
			//myTrace("load the query holder for projector");
			// v6.4.2.4 This now goes wrong as the projector is loaded at the same depth as credits.swf!
			// So in control.fla I will increment controlNS.depth after loading finished.
			myTrace("load projector to depth=" + _global.ORCHID.root.controlNS.depth);
			_global.ORCHID.root.createEmptyMovieClip("queryHolder", _global.ORCHID.root.controlNS.depth++);
			if(_global.ORCHID.online){
				var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("queryProjector");
			}else{
				var cacheVersion = ""
			}
			myTrace("load " + _global.ORCHID.paths.movie + "queryProjector.swf");
			//_root.queryHolder.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + "queryProjector.swf" + cacheVersion);
			_global.ORCHID.root.queryHolder.loadMovie(_global.ORCHID.paths.movie + "queryProjector.swf" + cacheVersion);
			// the write method test will be called from queryProjector (I guess)
			//this.testWriteMethod("access/projector");
			break;
		//case "mysql/php":
		//case "sqlserver/asp":
		default:
			myTrace("webserver scripting");
			this.testWriteMethod(dbMethod);
	}
}
dbInterfaceObject.prototype.getWriteMethod = function() {
	//	trace("in getWM with " + dbConnection);
	return this.dbConnection;
}
dbInterfaceObject.prototype.setWriteMethod = function(method) {
	//myTrace("in setWM with " + method);
	if (method == "lso/actionscript" || 
		method == "access/asp" || method == "sqlserver/asp" || method == "mysql/asp" || 
		// 6.5.4.5 Add in SQLServer with PHP
		//method == "mysql/php" || 
		method == "mysql/php" ||  method == "sqlserver/php" || method == "sql/php" || 
		method == "access/projector" || method == "mysql/projector" ) {
		// v6.4.3 Connect by scripting alone
		//if (method == "lso/actionscript") {
		// v6.4.3 The above change means that load is no longer interested in the parameter you passed it, it is only looking
		// at the data held in licenceNS.scripting. This is a problem for the split query used in APL
		// So allow for that
		if (method == "lso/actionscript") {
			var thisScripting = "actionscript";
		} else {
			var thisScripting = _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
		}
		//myTrace("sWM scripting=" + thisScripting);
		//if (_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "actionscript") {
		if (thisScripting == "actionscript") {
			myTrace("lSO.firstRun= " + this.dbSharedObject.data.firstRun);
			// see if you are reading an existing shared object, or creating a new one
			// v6.3.5 You might need to be more vigourous about this for APL as someone
			// who has used EGU will have the lso, but will not have the blank session
			// record ready for holding progress. No - because this LSO is under clarityenglish.com
			// in the shared objects folder. It is based on domain.
			if (this.dbSharedObject.data.firstRun == undefined) {
				myTrace("first time using LSO on/from computer/domain");
				//_root.queryHolder.init();
				//myTrace("need to init the dbSharedObject data");
				// v6.4.3 This was failing as dateFormat not defined in this module
				this.dbSharedObject.data.firstRun = dateFormat(new Date());
				//myTrace("write firstRun=" + this.dbSharedObject.data.firstRun);
				this.dbSharedObject.data.user = new Array();
				this.dbSharedObject.data.user.push({userID:"0", name:"_orchid", password:""});
				this.dbSharedObject.data.session = new Array();
				// v6.5.4.3 If the licence is for single, then it is not really anonymous (for certificates etc), so we will use userID=1
				// but I don't want to disrupt the 0 user, so just make two.
				var anonName = "_orchid";
				//var anonName = _global.ORCHID.literalModelObj.getLiteral("anonymousName", "labels");
				this.dbSharedObject.data.user.push({userID:"1", name:anonName, password:""});
				
				// v6.3.6 Only do it for APL. But don't use user=0 and course=0, better to use
				// the real ones. However, you won't know these details until later.
				if (_global.ORCHID.root.licenceHolder.licenceNS.productType.indexOf("Light") >= 0) {
					// v6.3.5 If APL is to work with anonymous users, then you need a default
					// session record to write scores to (now courseName = courseID)
					myTrace("APL, so create empty session");
					this.dbSharedObject.data.session.push({userID:"0", courseID:"0", scoreRecords:new Array()});
				}
				////dbSharedObject.data.progress.push({userID:"0", course:{name:"x", scoreDetails:[], sessionDetails:[]}});
				//myTrace("now got default user: " + this.dbSharedObject.data.user[0].name);
			} else{
				// v6.4.1 You might need to force Light users to courseID=0 for people who already have lso
				// from existing code, that had courseName not ID.
				if (_global.ORCHID.root.licenceHolder.licenceNS.productType.indexOf("Light") >= 0) {
					myTrace("lso already exists, but overwrite as Light licence");
					this.dbSharedObject.data.user[0].userID=0;
					this.dbSharedObject.data.user[0].name="_orchid";
					this.dbSharedObject.data.session[0].courseID = 0;
					this.dbSharedObject.data.session[0].userID=0;
					//myTrace("lso already exists, light user=" + this.dbSharedObject.data.user[0].name + " session course=" + this.dbSharedObject.data.session[0].courseID);
				}
				// v6.5.4.4 If this is an old style lso, then we won't have a userID=1. Doesn't seem to matter for progress, but it does for scratchPad
				// v6.5.4.3 If the licence is for single, then it is not really anonymous (for certificates etc), so we will use userID=1
				// but I don't want to disrupt the 0 user, so just make two.
				// Is userID a number or a string????
				//myTrace("lso exists but does it have userID=1?");
				var notGotThisUser = true;
				for (var i in this.dbSharedObject.data.user) {
					//myTrace("got userID=" + this.dbSharedObject.data.user[i].userID);
					if (this.dbSharedObject.data.user[i].userID=="1") {
						notGotThisUser = false;
						break;
					}
				}
				if (notGotThisuser) {
					myTrace("lso exists but doesn't have userID=1");
					var anonName = "_orchid";
					this.dbSharedObject.data.user.push({userID:"1", name:anonName, password:""});
				}
			}
			// v6.4.3 Shouldn't I flush the lso at this point for safety's sake?
			var myCode = this.dbSharedObject.flush();
			//myTrace("lso data saved with " + myCode);

		//} else if (method.indexOf("projector") >= 0) {
		//} else if (_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "projector") {
		} else if (thisScripting == "projector") {
			// This is probably a bit late as testWriteMethod has already been called.
			// v6.3.5 move to ZINC
			//if (_global.ORCHID.projector.name != "FlashStudioPro") {
			if (_global.ORCHID.projector.name != "MDM") {
				myTrace("oops - projector but not zinc!");
			} else {
				//myTrace("init vars for FSP db handling");
				//_global.ORCHID.FSP.db = new Object();
			}
		//} else if (method == "access/asp") {
		//	trace("no need to init the access database");
		//} else if (method == "mysql/php") {
		//	trace("no need to init the MySQL database");
		}
		// v6.5.5.1 For measuring performance
		_global.ORCHID.timeHolder.serverConnected = new Date().getTime();
		
		// v6.4.2 This is the property that some loading methods in control.events are waiting for
		this.dbConnection = method;
		myTrace("Set "+this.name+".dbConnection= "+method);
		this.onConnect(); // callback event to say that the object is ready
		return true;
	} else {
		this.dbConnection = undefined;
		return false;
	}
}
// this will try out various connection methods. it uses a callback function to
// test for the success of each - this will then return to here with another option
// until one succeeds,
dbInterfaceObject.prototype.testWriteMethod = function(type) {
	//myTrace("dbInterfaceObject.testWriteMethod");
	//myTrace("testing connection for " + type);
	//if (type == "access/asp" || type == "sqlserver/asp") {
	// v6.4.3 Use scripting alone
	// v6.4.3 The above change means that load is no longer interested in the parameter you passed it, it is only looking
	// at the data held in licenceNS.scripting. This is a problem for the split query used in APL
	// So allow for that
	if (type == "lso/actionscript") {
		var thisScripting = "actionscript";
	} else {
		var thisScripting = _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
	}
	//myTrace("tWM scripting=" + thisScripting);
	//if (type.indexOf("asp") >= 0) {
	//if (_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "asp") {
	if (thisScripting == "asp") {
		// v6.3 Use sub folders for different database server routines
		var mySub = _global.ORCHID.functions.addSlash(_global.ORCHID.root.licenceHolder.licenceNS.db);
		//var myPage = _global.ORCHID.paths.root + _global.ORCHID.paths.movie + mySub + "OrchidServer.asp";
		var myPage = _global.ORCHID.paths.movie + mySub + "orchidServer.asp";
		var sendLV = new LoadVars();
		var receiveLV = new LoadVars();
		receiveLV.master = this;
		receiveLV.onLoad = function(success) {
			//if (!_global.ORCHID.online) {
			// This patch is just to allow testing in the IDE
			//	myTrace("fake success with webserver test");
			//	success = true;
			//}
			if (success) {
				myTrace("got back status=" + this.status + " for scripting=" + _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase());
				this.master.setWriteMethod(type);
			} else {
				myTrace("failure");
				// v6.3 Note - It is not a good idea to assume that lso/actionscript
				// can be used if access/asp fails. Licencing relies on access even
				// if it wouldn't matter about the score being saved.
				//this.master.testWriteMethod("lso/actionscript");
				this.master.testWriteMethod("fail");
			}
			// after either success or failure, remove this object
			delete this;
		};
		myTrace("check server " + myPage);
		sendLV.sendAndLoad(myPage, receiveLV, "POST");
		
	//} else if (type.indexOf("php") >= 0) {
	//} else if (_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "php") {
	} else if (thisScripting== "php") {		
//	if (type == "mysql/php") {
		// v6.3 Use sub folders for different database server routines
		var mySub = _global.ORCHID.functions.addSlash(_global.ORCHID.root.licenceHolder.licenceNS.db);
		//var myPage = _global.ORCHID.paths.root + _global.ORCHID.paths.movie + mySub + "OrchidServer.php";
		// v6.4.1.4 Capitalisation
		var myPage = _global.ORCHID.paths.movie + mySub + "orchidServer.php";
		testLoadVars = new LoadVars();
		testLoadVars.master = this;
		testLoadVars.onLoad = function(success) {
			// v6.5.5.6 What we are currently expecting back is
			// status=ok&zendEncoded=1&zendEnabled=1
			//myTrace("got back status=" + this.status + "/" + success + " for type=" + type);
			myTrace("got back status=" + this.status + " success=" + success + " type=" + type);
			//if (success) {
			//if (success && this.status=="ok") {
			// For now lets just accept any old response 
			// Because of Julio error where he gets stuck with this trace if running in TB
			// check server /Software/Common/Source/SQLServer/orchidServer.php
			// got back status=/false for type=fail
			// But the orchidServer.php call works perfectly if he just runs it. Does anyone ever usefully fail here?
			if (true) {
				this.master.setWriteMethod(type);
			} else {
				this.master.testWriteMethod("fail");
			}
			// after either success or failure, remove this object
			delete this;
		};
		myTrace("check server " + myPage);
		// v6.5.5.5 For some very bizarre reason, adding this parameter stops the page loading on HCT server!
		// I can do cmd=1, but not cmd=about or db=about.  WTF? Why did I put it in anyway?
		//testLoadVars.load(myPage+"?cmd=about");
		testLoadVars.load(myPage);
	//} else if (type == "lso/actionscript") {
	//} else if (_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "actionscript") {
	} else if (thisScripting == "actionscript") {
		
		// create a persistent object that is used if successful
		// EGU - if running under FSP, then specify where the LSO will be
		// note - you have to be careful about domains for FSP, so just use root slash
		//this.dbSharedObject = SharedObject.getLocal("orchidDB");
		this.dbSharedObject = SharedObject.getLocal("orchidDB", "/");
		//myTrace("found dbSharedObject=" + this.dbSharedObject);
		this.dbSharedObject.myCallBack = this;
		// This event is triggered by a 'pending' from the flush - means that user is thinking about it!
		this.dbSharedObject.onStatus = function(status) {
			if (status.code == "SharedObject.Flush.Failed") {
				myTrace("Sorry, you cannot write out.");
				// after failure
				this.myCallBack.setWriteMethod(null);
				//delete this;
			} else {
				myTrace("testWriteMethod:connected to " + _global.ORCHID.root.licenceHolder.licenceNS.db);
				//var dbMethod = _global.ORCHID.root.licenceHolder.licenceNS.db.toLowerCase() + "/" +  _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
				var dbMethod = "lso/actionscript";
				//this.myCallBack.setWriteMethod("lso/actionscript");
				this.myCallBack.setWriteMethod(dbMethod);
			}
		};
		var myCode = this.dbSharedObject.flush(500000);
		// test it with 500k (which asks for the 1MB setting)
		if (myCode == true) {
			myTrace("lso should be ok!");
			this.setWriteMethod("lso/actionscript");
		} else {
			if (myCode == false) {
				// the user has put the local setting to "never"
				myTrace("Sorry, you cannot write out!");
				this.setWriteMethod(null);
				//delete scoreSharedObject; 
			}
		}
	//} else if (type == "access/projector") {
	//} else if (type.indexOf("projector") >= 0){
	//} else if (_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "projector"){
	} else if (thisScripting == "projector"){
		
		// v6.3 You should connect to the two databases here - and check for success
		// Ahh, but of course you can only have one db open at a time! So there will
		// be lots of opening and closing going on. QueryHolder will try to minimise
		// this though.
		// v6.4 Only 1 database now
		// v6.4.3 mdm script 2 - don't need callbacks - revert to 1
		
		var thisCallBack = new Object();
		thisCallBack.myName = "testWriteMethod";
		thisCallBack.master = this;
		thisCallBack.connectedCallBack = function(scope, success) {
			if (success) {
				myTrace("testWriteMethod:connected to " + scope.master.dbFileName);
				var dbMethod = _global.ORCHID.root.licenceHolder.licenceNS.db.toLowerCase() + "/" +  _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
				scope.master.setWriteMethod(dbMethod);
				// tidy up
				//fscommand("flashstudio.closedb");
				// v6.3 Don't close as we will almost immediately get more stuff from the tables
				//_root.queryHolder.dbClose();
			} else {
				myTrace("testWriteMethod:cannot connect to " + scope.master.dbFileName);
				//myTrace("testWriteMethod:cannot connect to " + scope.master.dbFileName);
				//myTrace("got back=" + _root.FSPdbReturnCode);
				scope.master.setWriteMethod(null);
			}
		}
		
		// this is a fixed variable that the query will use
		// v6.3.5 Move to ZINC
		//_root.FSPdbFileName = _global.ORCHID.paths.root + _global.ORCHID.paths.student + "score.mdb";
		// v6.4.2 Projector running CE programs
		// use better filename
		//this.dbFileName = _global.ORCHID.paths.root + _global.ORCHID.paths.student + "score.mdb";
		
		//v6.4.3 MySQL enabled
		if (_global.ORCHID.root.licenceHolder.licenceNS.db.toLowerCase() == "mysql") {
			_global.ORCHID.root.queryHolder.queryNS.dbDetails = new Object();
			var myDetails = _global.ORCHID.root.queryHolder.queryNS.dbDetails;
			var dbDetailsLV = new LoadVars();
			dbDetailsLV.myDetails = myDetails;
			dbDetailsLV.onLoad = function(success) {
				//_global.myTrace("loaded dbDetails");
				if (success) {
					for (var i in this) {
						myDetails[i] = this[i];
					}
				} 
				// try some defaults - you might not have wanted to write stuff into the text file!
				if (myDetails.host==undefined) myDetails.host = "localhost"; 
				if (myDetails.port==undefined)  myDetails.port = ""; // If left empty, this will default to 3306 
				if (myDetails.compression==undefined)  myDetails.compression = "true"; // Set to false to disable transfer compression 
				if (myDetails.username==undefined)  myDetails.username = "network"; 
				if (myDetails.password==undefined)  myDetails.password = "ClarityDB"; // Note that this user has to have an old style password if MySQL 5 is used.
				// MySQL> SET PASSWORD FOR 'network'@'%' = OLD_PASSWORD('ClarityDB');
				if (myDetails.dbname==undefined)  myDetails.dbname= "score"; 
				_global.ORCHID.root.queryHolder.dbConnect("mysql", thisCallBack, "connectedCallBack");
			} 
			myTrace("load from " + _global.ORCHID.paths.dbPath + "dbDetails-MySQL.txt");
			dbDetailsLV.load(_global.ORCHID.paths.dbPath + "dbDetails-MySQL.txt");
		} else {
			this.dbFileName = _global.ORCHID.paths.dbPath + "score.mdb";	
			_global.ORCHID.root.queryHolder.dbConnect(this.dbFileName, thisCallBack, "connectedCallBack");
		}
		//_root.FSPdbFilename = "d:\\Workbench\\Orchid\\student\\score.mdb";
		// v6.4.3 mdm script 2 - revert to 1
		//myTrace("connect to " + this.dbFileName + " callback to " + thisCallBack.myName);
		/*
		if (_global.ORCHID.root.queryHolder.dbConnect(this.dbFileName)) {
			this.setWriteMethod("access/projector");
			// v6.4.3 Don't hang onto the connection now you know that you can make it
			//myTrace("close from testWriteMethod");
			//_global.ORCHID.root.queryHolder.dbClose();
		} else {
			this.setWriteMethod(null);
		}
		*/

	} else {
		this.setWriteMethod(null);
	}	
}
//dbInterfaceObject.prototype.getDB = function(callback, method, args) {
//	// make the call, this will set run the global callback when it is finished
//	//trace("callback method=" + callback.setDB);
//	this.callback = callback;
//	myConnection[method].apply(myConnection, args);
//}
// functions that let other objects write callbacks and tests for asynchronous database calls
// the original db call should write an onReturnCode function as a callback
// the place that actually runs the database processing should set dbReturnCode = true once 
// the result is found and set dbReturnObject to the result (if there is one)
dbInterfaceObject.prototype.dbInitialise = function(object) {
	this.dbCaller = object;
	this.dbReturnCode = false;
	this.dbReturnObject = new Object();
	this.dbWaitForReturn();
}
dbInterfaceObject.prototype.dbGetReturnCode = function() {
	if (this.dbReturnCode) {
		if (thisIntervalID >=0) clearInterval(thisIntervalID);
		this.dbCaller.onReturnCode(this.dbReturnObject);
	} else {
		myTrace("waiting for db to send back a return code");
	}
}
dbInterfaceObject.prototype.dbWaitForReturn = function() {
	// I do not understand why I need the following line, but it won't even call the
	// correct interval function if it is not here!
	my = this;
	if (this.dbReturnCode) {
		this.dbGetReturnCode();
	} else {
		thisIntervalID = setInterval(this, "dbGetReturnCode", 500);
	}
}
// 6.0.5.0 a new object to run each query to the database
function dbQuery() {
	//myTrace("making a new query");
	this.dbConnection = _global.ORCHID.dbInterface.dbConnection;
}
// v6.3.5 APL writes out progress and scratch pad locally as the user
// is always anonymous. But other data is written to the SQL database. So
// work out which type of call this is and split the work.
dbQuery.prototype.runSplitQuery = function() {
	// v6.4.2 If you are using projector with APL, LSO and projector will clash. So don't do 
	// this split processing as it holds no benefits anyway.
	if (_global.ORCHID.root.licenceHolder.licenceNS.productType.indexOf("Light") >= 0 &&
		_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() != "projector") {
		myTrace("split query to LSO as " + _global.ORCHID.root.licenceHolder.licenceNS.productType,1);
		this.runQueryLSO();
	} else {
		//myTrace("split query to normal not Light");
		this.runQuery()
	}
}
// all queries will be set up in a particular way.
dbQuery.prototype.runQuery = function() {
	// this.queryString holds the query object
	// this.xmlReceive will have been set up as a XML object (with callback)
	// by whatever called this runQuery
	// v6.5.4.5 If you put a " into a name or password - you screw this. So convert manually first. Note that ' is automatically done
	// But you can't do this as you screw up all the attribute quotes! So need to do it when building each string for any thing that could contain a quote!
	//this.queryString = _global.ORCHID.root.objectHolder.findReplace(this.queryString, String.fromCharCode(34), "&quot;");
	//myTrace("thisQueryString: " + this.queryString);
	this.xmlSend = new XML(this.queryString); 
	if (_global.ORCHID.commandLine.dbDetails.dbHost != undefined) {
		this.xmlSend.firstChild.attributes.dbHost = _global.ORCHID.commandLine.dbDetails.dbHost;
	}
	// v6.5.5.1 For measuring performance
	var methodName = this.queryString.substring(this.queryString.indexOf("method=")+8,this.queryString.indexOf(" ", this.queryString.indexOf("method="))-1);
	_global.ORCHID.timeHolder.query['start_' + methodName] = new Date().getTime();
	
	myTrace("Query: " + this.xmlSend.toString().substr(0,300));
	// v6.3.4 If the db details have been picked up from commandLine or location
	// then add them into the querystring. No. Not done this way. Just use dbHost above.
	/*
	if (_global.ORCHID.commandLine.dbDetails.dbUser != undefined) {
		this.xmlSend.firstChild.attributes.dbUser = _global.ORCHID.commandLine.dbDetails.dbUser;
	}
	if (_global.ORCHID.commandLine.dbDetails.dbPassword != undefined) {
		this.xmlSend.firstChild.attributes.dbPass = _global.ORCHID.commandLine.dbDetails.dbPassword;
	}
	if (_global.ORCHID.commandLine.dbDetails.prefix != undefined) {
		this.xmlSend.firstChild.attributes.prefix = _global.ORCHID.commandLine.dbDetails.prefix;
	}
	if (_global.ORCHID.commandLine.dbDetails.catalog != undefined) {
		this.xmlSend.firstChild.attributes.catalog = _global.ORCHID.commandLine.dbDetails.catalog;
	}
	*/
	//myTrace("now query: " + this.xmlSend.toString().substr(0,128));
	// the projector and actionscript use a loaded swf for this function
	// v6.4.3 Base connection on scripting
	//if (this.dbConnection == "lso/actionscript" || this.dbConnection.indexOf("projector") >= 0 ) {
	//myTrace("scripting:" + _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase());
	if (	_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "actionscript" || 
		_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "projector") {
		// 6.0.6.0 enable shared object use
		_global.ORCHID.root.queryHolder.sendQuery(this.xmlSend, this.xmlReceive);
	} else {
		// asp and php use server side files
		var myExt = _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
		var mySub = _global.ORCHID.functions.addSlash(_global.ORCHID.root.licenceHolder.licenceNS.db);
		//this.xmlSend.sendAndLoad(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + 
		this.xmlSend.sendAndLoad(_global.ORCHID.paths.movie + 
								 mySub + "runProgressQuery" + "." + myExt, this.xmlReceive);
		//myTrace("xmlSend " + mySub + "runProgressQuery" + "." + myExt)

	//} else if (this.dbConnection == "access/asp") {
	//	//myTrace("query page=" + _global.ORCHID.paths.root + _global.ORCHID.paths.movie + "runProgressQuery.asp");
	//	this.xmlSend.sendAndLoad(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + "runProgressQuery.asp", this.xmlReceive);

	//} else if (this.dbConnection == "mysql/php") {
	//	//myTrace("query page=" + _global.ORCHID.paths.root + _global.ORCHID.paths.movie + "runProgressQuery.php");
	//	this.xmlSend.sendAndLoad(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + "runProgressQuery.php", this.xmlReceive);
	}
}
// v6.4.2 Allow custom queries (used for certificate) to be run from different files
dbQuery.prototype.runCustomQuery = function() {
	// this.queryString holds the query object
	// this.xmlReceive will have been set up as a XML object (with callback)
	// by whatever called this runCustomQuery
	this.xmlSend = new XML(this.queryString);
	if (_global.ORCHID.commandLine.dbDetails.dbHost != undefined) {
		this.xmlSend.firstChild.attributes.dbHost = _global.ORCHID.commandLine.dbDetails.dbHost;
	}
	myTrace("CustomQuery: " + this.xmlSend.toString().substr(0,128));
	// the projector and actionscript use a loaded swf for this function
	// v6.4.3 Base connection on scripting
	//if (this.dbConnection == "lso/actionscript" || this.dbConnection.indexOf("projector") >= 0 ) {
	if (	_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "actionscript" ||
		_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "projector") {
		// 6.0.6.0 enable shared object use
		// v6.4.2.4 This function will have been loaded into a holder deeper in the main queryHolder
		//_global.ORCHID.root.queryHolder.sendCustomQuery(this.xmlSend, this.xmlReceive);
		myTrace("call customQuery from " + _global.ORCHID.root.queryHolder.customQueryHolder);
		_global.ORCHID.root.queryHolder.customQueryHolder.sendCustomQuery(this.xmlSend, this.xmlReceive); 
	} else {
		// asp and php use server side files
		var myExt = _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
		var mySub = _global.ORCHID.functions.addSlash(_global.ORCHID.root.licenceHolder.licenceNS.db);
		// v6.4.2 Run the custom query from the brand folder
		// v6.4.2.4 BUT, this is very clumsy as you have to double the dbPath type features, and it is confusing since the
		// folder structure doesn't match the common one. So, how about you use regular runProgressQuery, but send
		// the full path to the queryCustom.asp file so that runProgressQuery can load it and then run the custom queries
		// as if they were regular ones. And you would still be able to have multiple different products with the same common.
		// This code only sketched out, not tested (due to complexities of Eval in asp)
		//this.xmlSend.addNode("customQuery=" + _global.ORCHID.paths.brandMovies + mySub + "queryCustom" + "." + myExt);
		//this.xmlSend.sendAndLoad(_global.ORCHID.paths.movie + 
		//						 mySub + "runProgressQuery" + "." + myExt, this.xmlReceive);
		myTrace("load script from " + _global.ORCHID.paths.brandMovies + mySub + "runCustomQuery" + "." + myExt);
		this.xmlSend.sendAndLoad(_global.ORCHID.paths.brandMovies + 
								 mySub + "runCustomQuery" + "." + myExt, this.xmlReceive);
	}
}

// 6.0.7.0, all query including licence control will be done by runSecureQuery.
// The difference between runQuery and runSecureQuery is that we check the checkSum
// for the asp file of runSecureQuery. I wish!
dbQuery.prototype.runSecureQuery = function() {
	// this.queryString holds the query object
	// this.xmlReceive will have been set up as a XML object (with callback)
	// by whatever called this runQuery
	var mySub = _global.ORCHID.functions.addSlash(_global.ORCHID.root.licenceHolder.licenceNS.db);
	this.xmlSend = new XML(this.queryString);
	// v6.3.4 If the db details have been picked up from commandLine or location
	// then add them into the querystring. No. Not done this way.
	if (_global.ORCHID.commandLine.dbDetails.dbHost != undefined) {
		this.xmlSend.firstChild.attributes.dbHost = _global.ORCHID.commandLine.dbDetails.dbHost;
	}
	// v6.5.5.1 For measuring performance
	var methodName = this.queryString.substring(this.queryString.indexOf("method=")+8,this.queryString.indexOf(" ", this.queryString.indexOf("method="))-1);
	_global.ORCHID.timeHolder.query['start_' + methodName] = new Date().getTime();
	myTrace("SQuery: " + this.xmlSend.toString().substr(0, 300));
	// the projector and actionscript use a loaded swf for this function
	// v6.4.3 Base connection on scripting
	//if (this.dbConnection == "lso/actionscript" || this.dbConnection.indexOf("projector") >= 0 ) {
	if (	_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "actionscript" ||
		_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "projector") {
		// for shared object use
		_global.ORCHID.root.queryHolder.sendQuery(this.xmlSend, this.xmlReceive);
	} else {
		// asp and php use server side files
		var myExt = _global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase();
		//this.xmlSend.sendAndLoad(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + 
		this.xmlSend.sendAndLoad(_global.ORCHID.paths.movie + 
								 mySub + "runLicenceQuery" + "." + myExt, this.xmlReceive);
	}
}
// v6.3.5 For anonymous use with APL
// this forces this query to be run through LSO, no matter what the licence says
// and forces the userID to be 0 (which you set up when you start LSO)
dbQuery.prototype.runQueryLSO = function() {
	// usually scores are held in a session record, which is keyed on user, session and course
	// so since we do not write out session records for Light, these all need to be overwritten
	var thisUserID = 0;
	var thisSessionID = 0;
	//v6.3.5 Move from courseName to courseID
	//var thisCourseName = "_orchid";
	var thisCourseID = "0";
	var newQueryString = _global.ORCHID.root.objectHolder.findReplace(this.queryString, 'userID="' + _global.ORCHID.user.userID + '"', 'userID="' + thisUserID + '"');
	newQueryString = _global.ORCHID.root.objectHolder.findReplace(newQueryString, 'sessionID="' + _global.ORCHID.session.sessionID + '"', 'sessionID="' + thisSessionID + '"');
	//newQueryString = _global.ORCHID.root.objectHolder.findReplace(newQueryString, 'courseName="' + _global.ORCHID.course.scaffold.caption + '"', 'courseName="' + thisCourseName + '"');
	newQueryString = _global.ORCHID.root.objectHolder.findReplace(newQueryString, 'courseID="' + _global.ORCHID.course.id + '"', 'courseID="' + thisCourseID + '"');
	this.xmlSend = new XML(newQueryString);
	myTrace("LSO Query: " + this.xmlSend.toString());
	_global.ORCHID.root.queryHolder.sendQuery(this.xmlSend, this.xmlReceive);
}
// v6.4.3 These two were missing and are now common - so lso.firstRun was not being saved.
dateFormat = function(thisDate) {
	//var dateString = "2007" + "-" + zeroPad(thisDate.getMonth()+1) + "-" + zeroPad(thisDate.getDate()) + " " + zeroPad(thisDate.getHours()) + ":" + zeroPad(thisDate.getMinutes()) + ":" + zeroPad(thisDate.getSeconds());
	var dateString = thisDate.getFullYear() + "-" + zeroPad(thisDate.getMonth()+1) + "-" + zeroPad(thisDate.getDate()) + " " + zeroPad(thisDate.getHours()) + ":" + zeroPad(thisDate.getMinutes()) + ":" + zeroPad(thisDate.getSeconds());
	return dateString;
}
zeroPad = function(num) {
	if (num < 10) {
		return "0" + num;
	} else {
		return num;
	}
}