// The overall object!
// All global information is to be held in an ORCHID sub object to avoid any kind 
// of namespace conflict with components.
_global.ORCHID = new Object();

// v6.4.3 Since any movies published for different Flash players will not share the same
//_global space, I need to pass this object through to them.
this.sharedGlobal = _global.ORCHID;

// v6.4.2 And immediately create the rootless object
_global.ORCHID.root = this;
_global.ORCHID.functions = new Object();

// v6.5.5.1 For measuring performance, we need the very first time we can get.
_global.ORCHID.timeHolder = new Object();
_global.ORCHID.timeHolder.query = new Object();
_global.ORCHID.timeHolder.programStart = new Date().getTime();
myTrace("timer:programStart=" + _global.ORCHID.timeHolder.programStart);

// Note: this should probably be nicely inside _global.ORCHID
// under a 'module' section to make it easy to access across modules
// create a namespace for non-temp variables declared in this swf
var controlNS = new Object();
controlNS.depth=1;
// v6.4.2.4 What is this for? And you can't swapDepths to an object!
//controlNS.swapDepths(_root);

controlNS.moduleName = "controlModule";
// set the version number of this section
//controlNS.version = {major:6, minor:0, build:47, patch:0};
// v6.4.2 rootless
this.whoami = "proxy root";
controlNS.whoami = "controlNS";
controlNS.master = this;

// v6.3.3 What information has been passed to you on the command line?
_global.ORCHID.commandLine = new Object();
// v6.4 2 For now, leave these all on root and they will only work if run at the 
// top level. If not, then probably do it through setVars? In fact, maybe the whole
// lot can be done as setVars through html?
// These will all be set to undefined if they don't match the parameters
_global.ORCHID.commandLine.password = this.password;
_global.ORCHID.commandLine.userName = this.username;
if (_global.ORCHID.commandLine.userName) myTrace("command-line userName=" + _global.ORCHID.commandLine.userName);
// v6.4.3 Also use studentID
_global.ORCHID.commandLine.studentID = this.studentID;
if (_global.ORCHID.commandLine.studentID) myTrace("command-line studentID=" + _global.ORCHID.commandLine.studentID);
// v6.5.4.7 And userID for ClarityEnglish.com
_global.ORCHID.commandLine.userID = this.userID;
if (_global.ORCHID.commandLine.userID) myTrace("command-line userID=" + _global.ORCHID.commandLine.userID);

_global.ORCHID.commandLine.action = this.action;
_global.ORCHID.commandLine.course = this.course;
// v6.3.5 new variables for protection
_global.ORCHID.commandLine.entryPass = this.entryPass;
_global.ORCHID.commandLine.encryptKey = this.encryptKey;
// v6.3.5 new variables for APL - this is where the location.ini is for this account
_global.ORCHID.commandLine.userDataPath = this.userdatapath;
// v6.4.2 what is location.ini actually called?
_global.ORCHID.commandLine.location = this.location;

// v6.3.4 Way to show that the program has started from within SCORM LMS
_global.ORCHID.commandLine.scorm = (this.scorm == "true");
// v6.5 And tell it how you will communicate with the start page/LMS
_global.ORCHID.commandLine.scormCommunication = (this.scormCommunication=="" || this.scormCommunication==undefined) ? undefined : this.scormCommunication;
// If you passed this parameter, then make sure that the plain one is also set to true
myTrace("scormCommunication=" + scormCommunication);
if (_global.ORCHID.commandLine.scormCommunication.length>=1) {
	_global.ORCHID.commandLine.scorm=true;
}

// v6.3.5 Add in other direct way to start the program
// startingPoint = "exercise=e102" or "unit=u1" or "menu" // NO NO NO
// startingPoint = "ex:e113" or "unit:123123238123" or "unit:u1"
_global.ORCHID.commandLine.startingPoint = this.startingPoint;
_global.ORCHID.commandLine.courseFile = this.courseFile;

// v6.3.4 Passed if you need to control access through client IP address
_global.ORCHID.commandLine.ip = this.ip;
// v6.3.5 Passed if you need to control access through server IP address
_global.ORCHID.commandLine.server = this.server;
// v6.4.1.5 Passed if you need to control access through referrer URL
_global.ORCHID.commandLine.referrer = this.referrer;

//_global.ORCHID.commandLine.source = _root.source;
//_global.ORCHID.commandLine.content = _root.content;
/*
if (_global.ORCHID.commandLine.userName != undefined) {
	if (_global.ORCHID.commandLine.scorm) {
		myTrace("using SCORM for " + _global.ORCHID.commandLine.userName);
	} else {
		myTrace("preset name " + _global.ORCHID.commandLine.userName);
	}
}
*/
// v6.3.5 If you have been started remotely, other parameters might have come through
// as well that will override anything from location.ini. In particular dbHost and content.
// v6.5.5.5 Expecting this to be a root for content. The specific folder will be added later.
// UNLESS you are NOT getting account data from the db, in which case this must be the full folder.
_global.ORCHID.commandLine.content = this.content;
if (_global.ORCHID.commandLine.content.length>=1) {
	myTrace("content from commandline=" + _global.ORCHID.commandLine.content);
}
// v6.4.2 AP editing CE
// v6.4.1.4 The course.xml will have full path to edited content
//_global.ORCHID.commandLine.editedContent = _root.editedContent;
_global.ORCHID.commandLine.brandMovies = this.brandMovies;
_global.ORCHID.commandLine.interfaceMovies = this.interfaceMovies;
// v6.3.6 Add yet more things that can come through the command line
_global.ORCHID.commandLine.mainMovies = this.mainMovies;
_global.ORCHID.commandLine.licence = this.licence;
_global.ORCHID.commandLine.dbDetails = new Object();
_global.ORCHID.commandLine.dbDetails.dbHost = this.dbHost;
// v6.4.2 For projector use
_global.ORCHID.commandLine.dbDetails.dbPath = this.dbPath;
// v6.3.5 You might be passed a required/suggested interface language
_global.ORCHID.commandLine.language = this.language;

// v6.4.1 The command line can tell you that preview has started you
_global.ORCHID.commandLine.preview = (this.preview == "true");
// v6.4.2 And also that you should look for custom images on the screens
_global.ORCHID.commandLine.customised = (this.customised == "true");

// v6.4.2 For passed scripting/db
_global.ORCHID.commandLine.scripting = this.scripting;
_global.ORCHID.commandLine.database = this.database;

// v6.4.4 For mocking up MGS
_global.ORCHID.commandLine.MGSName = this.MGSName;
myTrace("_global ORCHID MGSName is " + _global.ORCHID.commandLine.MGSName);
// v6.4.2.6 If you pass this with SWFObject getUserQueryParam, then even if not used it will be empty rather than undefined.
_global.ORCHID.commandLine.MGSRoot = (this.MGSRoot=="" || this.MGSRoot==undefined) ? undefined : this.MGSRoot;
myTrace("_global ORCHID MGSRoot is " + _global.ORCHID.commandLine.MGSRoot);
// v6.4.3 You might have loaded control using JSFG, in which case, what is the proxy id?
// What id does the proxy have?
_global.ORCHID.commandLine.flashProxyID = this.lcId;
//myTrace("proxyID=" + _global.ORCHID.commandLine.flashProxyID);

// v6.4.3 Have you started from a protected program?
_global.ORCHID.commandLine.protectionParameter = this.protectionParameter;

// v6.5.4.8 Very special case you want to pass the rootID
_global.ORCHID.commandLine.rootID = (this.rootID=="" || this.rootID==undefined) ? undefined : this.rootID;

// v6.5.5.1 If you pass the prefix it implies that you are within CE.com
_global.ORCHID.commandLine.prefix = (this.prefix=="" || this.prefix==undefined) ? undefined : this.prefix;
_global.ORCHID.commandLine.productCode = (this.productCode=="" || this.productCode==undefined) ? undefined : this.productCode;
myTrace("command-line root=" + _global.ORCHID.commandLine.rootID + " prefix=" + _global.ORCHID.commandLine.prefix);

// v6.5.5.5 Also send instanceID if you have another set of scripts which initially create an instance ID for this user
_global.ORCHID.commandLine.instanceID = this.instanceID;
if (_global.ORCHID.commandLine.instanceID) myTrace("command-line instanceID=" + _global.ORCHID.commandLine.instanceID);

// v6.5.5.9 To help us with badger
_global.ORCHID.commandLine.isConnected = false;

// v6.5.6.2 Purely for testing certificates where you want to go direct, but report on an old session
_global.ORCHID.commandLine.sessionID = (this.sessionID==undefined) ? undefined : this.sessionID;
if (_global.ORCHID.commandLine.sessionID) myTrace("command-line sessionID=" + _global.ORCHID.commandLine.sessionID);

// v6.5.5.5 And if you want to see what this whole command line was?
_global.ORCHID.commandLine.toString = function() {
	var fullString = "";
	for (var i in _global.ORCHID.commandLine) {
		fullString+=i + "=" + _global.ORCHID.commandLine[i] + " ";
	}
	return fullString;
}
//myTrace("first line of code beyond myTrace function");
_global.ORCHID.paths = new Object();

// v6.4.3 Might need a better version of online or not as slashes get mixed up when you run a file within the browser
// v6.5.4.4 For running from a file - WET
//_global.ORCHID.online = (this._url.subStr(0,7) == "http://");
if (_root.mdm_winverstring != undefined) {
	_global.ORCHID.online = false;
} else {
	if ((this._url.subStr(0,7) == "http://") || (this._url.subStr(0,8) == "https://") || (this._url.subStr(0,7) == "file://")) {
		_global.ORCHID.online = true;
	} else {
		_global.ORCHID.online = false;
	}
}
// v6.5.5.9 Of course, this really means running in a browser or not. But we would like a true online, so trigger a request to pick that up
// Try to load the Adobe air.swf, it success then we are online.
// Or you could do it with loadVars and a text file if that is easier?
// It is much easier, but only works on the same domain. Until we add crossdomain.xml.
/*
this.AIRbrowserAPI = this.createEmptyMovieClip("AIRbrowserAPI", controlNS.depth++);
myTrace("AIRbrowserAPI=" + this.AIRbrowserAPI);
this.AIRbrowserAPILoadTest = function(){
	myTrace("AIRbrowserAPILoadTest, count=" + this.AIRbrowserAPILoaderCount + " need to load " + this.AIRbrowserAPI + "," + this.AIRbrowserAPI.getBytesTotal());
	if (this.AIRbrowserAPI.getBytesLoaded() > 4 && this.AIRbrowserAPI.getBytesLoaded() >= this.AIRbrowserAPI.getBytesTotal()) {
		//myTrace("player fully loaded, bytes=" + myVideo.getBytesTotal());
		clearInterval(this.AIRbrowserAPILoaderInt);
		// Nothing to do since the default is to assume you are connected.
		//_global.ORCHID.commandLine.isConnected = true;
	} else if (this.AIRbrowserAPILoaderCount>10){
		myTrace("cannot load adobe.browserAPI, so consider not online");
		clearInterval(this.AIRbrowserAPILoaderInt);
		_global.ORCHID.commandLine.isConnected = false;
		delete this.AIRbrowserAPI;
	} else {
		this.AIRbrowserAPILoaderCount++;
	}
}
this.AIRbrowserAPI.loadMovie("http://airdownload.adobe.com/air/browserapi/air.swf");
this.AIRbrowserAPILoaderInt = setInterval(this, "AIRbrowserAPILoadtest", 500);
*/
var onlineChecker = new LoadVars();
var onlineReference = "http://www.clarityenglish.com/Software/Common/Source/SQLServer/orchidServer.php";
//Security.loadPolicyFile("http://www.clarityenglish.com/Software/Common/Source/crossdomain.xml")
//var onlineReference = "http://claritymain/Software/Common/Source/SQLServer/orchidServer.php";
//Security.loadPolicyFile("http://claritymain/Software/Common/Source/SQLServer/crossdomain.xml")
//var onlineReference = "http://dock.fixbench/Software/Common/Source/SQLServer/orchidServer.php";
onlineChecker.onLoad = function(success) {
	myTrace("online reference load, success=" + success);
	if (success) {
		_global.ORCHID.commandLine.isConnected = true;
	} else {
		_global.ORCHID.commandLine.isConnected = false;
	}
	delete onlineChecker;
}
onlineChecker.load(onlineReference)

if (_global.ORCHID.online) {
	var cacheVersion = "?cacheVersion=" + new Date().getTime();
	var folderSlash = "/";
} else {
	var cacheVersion = ""
	var folderSlash = "\\";
}
// useful function for path processing
// v6.3.1 Remove any ending slash and add your own, based on online or local
//v6.4.2 rootless
_global.ORCHID.functions.addSlash = function(path) {
	while (path.substr(-1,1) == "/" || path.substr(-1,1) == "\\") {
		path = path.substr(0,path.length-1);
	}
	return path + folderSlash;
}

// for testing where you are running from
//myTrace("domain=" + _root.sendConn.domain() + " _url=" + this._url);

// v6.5.5.2 Read ZINC command line parameters. Pointless as this still is not quick enough, so do it in the original place.

// You need to load all other swfs from the same location as this one
// even if this one was loaded remotely
controlNS.fullPath = this._url;
myTrace("Control is running from: " + controlNS.fullPath,0);
_global.ORCHID.paths.root = controlNS.fullPath.substring(0, controlNS.fullPath.indexOf("control.swf",0));
myTrace("paths.root: " + _global.ORCHID.paths.root,1);
myTrace("and now the passed username=" + this.username);
//myTrace("with preview=" + _global.ORCHID.commandLine.preview); 
// Building up the paths used for loading. The default is set paths
// under the place you are running from. But this might get altered by
// a) RemoteStart, b) FSP (uses a temporary folder from a CD)
// c) using location.ini for particular paths
// You can only run setupPaths after you are sure that paths.root is valid
// And once setupPaths is run (including callback), it will call loadVersionTable
//v6.4.2 rootless
controlNS.setupPaths = function() {
	// this=controlNS
	//myTrace("in setupPaths of this=" + this.whoami);
	// v6.3.1 Allow a licence file name to be passed to the controller
	// v6.3.5 The licence filename should be read in this order:
	// a) from the command line
	// b) from the location.ini
	// c) assume it is licence.ini
	// And then, if not a full path, assume it is in userdatapath
	//if (_global.ORCHID.commandLine.licence == undefined || _global.ORCHID.commandLine.licence == "") {
	//	var licenceFile = "licence.ini";
	//} else {
	//	var licenceFile = _global.ORCHID.commandLine.licence;
	//	myTrace("use licence from commandLine=" + licenceFile);
	//}
	var getLocation = new LoadVars();
	// v6.4.2 rootless
	getLocation.master = this;
	getLocation.onLoad = function(success) {
		if (success) {
			// v6.3.5 Now, if you started remotely, there might already been some
			// variables set from that starting point. Don't overwrite them.
			if (_global.ORCHID.commandLine.mainMovies == undefined &&
				this.mainMovies != undefined) {
				_global.ORCHID.commandLine.mainMovies = this.mainMovies;
			}
			// v6.3.5 There are two types of "branding", the interface (which changes
			// according to product, and possibly within product. And then customer
			// specific stuff which sits on top of (or talks to buttons). We need
			// two different paths for this. Currently brandMovies looks for buttons.swf
			// and then customIntro.swf is searched for by the /brand folder from root.
			// Change to call buttons.swf from interfaceMovies and explicitly pass
			// brandMovies to look for customIntro (referred to from licence file).
			if (_global.ORCHID.commandLine.brandMovies == undefined &&
				this.brandMovies != undefined) {
				_global.ORCHID.commandLine.brandMovies = this.brandMovies;
			}
			if (_global.ORCHID.commandLine.interfaceMovies == undefined &&
				this.interfaceMovies != undefined) {
				_global.ORCHID.commandLine.interfaceMovies = this.interfaceMovies;
			}
			// v6.5.5.5 Expecting this to be a root for content. The specific folder will be added later.
			// UNLESS you are NOT getting account data from the db, in which case this must be the full folder.
			if (_global.ORCHID.commandLine.content == undefined &&
				this.content != undefined) {
					myTrace("content from location=" + this.content);
				_global.ORCHID.commandLine.content = this.content;
			}
			// v6.4.2 AP editing CE
			// v6.4.1.4 The course.xml will have full path to edited content
			//if (_global.ORCHID.commandLine.editedContent == undefined &&
			//	this.editedContent != undefined) {
			//	_global.ORCHID.commandLine.editedContent = this.editedContent;
			//}
			// v6.3.6 Add courseFile (to allow demo and main to share content)
			if (_global.ORCHID.commandLine.courseFile == undefined &&
				this.courseFile != undefined) {
				_global.ORCHID.commandLine.courseFile = this.courseFile;
			}
			//_global.ORCHID.commandLine.dbDetails = new Object();
			if (_global.ORCHID.commandLine.dbDetails.dbHost == undefined &&
				this.dbHost != undefined) {
				// v6.5.5.5 A mistaken name surely!
				//_global.ORCHID.commandLine.dbDetails.host = this.dbHost;
				_global.ORCHID.commandLine.dbDetails.dbHost = this.dbHost;
				myTrace("dbHost from location=" + this.dbHost,1);
			}
			// v6.3.5 The following are not planned to use at all
			/*
			if (this.dbCatalog != undefined) {
				_global.ORCHID.commandLine.dbDetails.catalog = this.dbCatalog;
			}
			if (this.dbPrefix != undefined) {
				_global.ORCHID.commandLine.dbDetails.prefix = this.dbPrefix;
			}
			if (this.dbUser != undefined) {
				_global.ORCHID.commandLine.dbDetails.dbUser = this.dbUser;
			}
			if (this.dbPassword != undefined) {
				_global.ORCHID.commandLine.dbDetails.dbPassword = this.dbPassword;
			}
			*/
			// v6.4.2 For projector use
			if (_global.ORCHID.commandLine.dbDetails.dbPath == undefined &&
				this.dbPath != undefined) {
				_global.ORCHID.commandLine.dbDetails.dbPath = this.dbPath;
			}

			// v6.3.5 for shared media
			if (_global.ORCHID.commandLine.sharedMedia == undefined &&
				this.sharedMedia != undefined) {
				_global.ORCHID.commandLine.sharedMedia = this.sharedMedia;
			}
			// v6.3.5 for streaming media
			if (_global.ORCHID.commandLine.streamingMedia == undefined &&
				this.streamingMedia != undefined) {
				_global.ORCHID.commandLine.streamingMedia = this.streamingMedia;
			}
			// v6.3.5 for help
			if (_global.ORCHID.commandLine.help == undefined &&
				this.help != undefined) {
				//myTrace("help from location=" + this.help);
				_global.ORCHID.commandLine.help = this.help;
			}
			// v6.4.1 for language
			if (_global.ORCHID.commandLine.language == undefined &&
				this.language != undefined) {
				myTrace("language from location=" + this.language,1);
				_global.ORCHID.commandLine.language = this.language;
			}
			// v6.4.2 for action. But location is an unsecure place to put this
			// so maybe it should be able to come from licence as well.
			// v6.4.1.4 Seems useless to have action without username/password
			// But I am sure these are best passed from commandLine anyway.
			if (_global.ORCHID.commandLine.action == undefined &&
				this.action != undefined) {
				myTrace("action from location=" + this.action,1);
				_global.ORCHID.commandLine.action = this.action;
			}
			// v6.4.2 for action. But location is an unsecure place to put this
			// so maybe it should be able to come from licence as well.
			if (_global.ORCHID.commandLine.scripting == undefined &&
				this.scripting != undefined) {
				myTrace("scripting from location=" + this.scripting,1);
				_global.ORCHID.commandLine.scripting = this.scripting;
			}
			if (_global.ORCHID.commandLine.database == undefined &&
				this.database != undefined) {
				myTrace("database from location=" + this.database,1);
				_global.ORCHID.commandLine.database = this.database;
			}
			//v6.4.2 To allow licence to come through location
			if (_global.ORCHID.commandLine.licence == undefined &&
				this.licence != undefined) {
				myTrace("licence from location=" + this.licence,1);
				_global.ORCHID.commandLine.licence = this.licence;
			}

			// v6.4.2 for customised searching - this will switch on customised
			// whether it is on or off from commandline.
			// Due to 404 error catching if you search a jpg that doesn't exist
			//myTrace("commandLine.customised=" + _global.ORCHID.commandLine.customised);
			//myTrace("location.customised=" + this.customised);
			if (_global.ORCHID.commandLine.customised == false &&
				this.customised != undefined) {
				//myTrace("no customised from commandline, so use location customised=" + this.customised);
				_global.ORCHID.commandLine.customised = (this.customised == "true");
			}
			//myTrace("so commandline+location.customised=" + _global.ORCHID.commandLine.customised);
			// v6.4.4 MGS
			if (_global.ORCHID.commandLine.MGSName == undefined &&
				this.MGSName != undefined) {
				//myTrace("MGS name from location=" + this.MGSName,1);
				_global.ORCHID.commandLine.MGSName = this.MGSName;
			}
			if (_global.ORCHID.commandLine.MGSRoot == undefined &&
				this.MGSRoot != undefined) {
				myTrace("MGS root from location=" + this.MGSRoot,1);
				_global.ORCHID.commandLine.MGSRoot = this.MGSRoot;
			}
			// v6.5.5.1 To allow productCode to come through location
			if (_global.ORCHID.commandLine.productCode == undefined &&
				this.productCode!=undefined) {
				myTrace("productCode from location file is " + this.productCode);
				_global.ORCHID.commandLine.productCode = this.productCode;
			}
			// v6.5.6.5 Special case of Clarity Recorder option going directly online
			if (_global.ORCHID.commandLine.useClarityRecorderOnline == undefined &&
				(this.useClarityRecorderOnline==true || this.useClarityRecorderOnline=='true')) {
				myTrace("useClarityRecorderOnline from location file is " + this.useClarityRecorderOnline);
				_global.ORCHID.commandLine.useClarityRecorderOnline = true;
			} else {
				// make sure we default to not use this
				_global.ORCHID.commandLine.useClarityRecorderOnline = false;
			}
			
			//for (var i in _global.ORCHID.commandLine.dbDetails) {
				//myTrace("dbDetails." + i + "=" + _global.ORCHID.commandLine.dbDetails[i]);
			//}
			//myTrace("yes, read it");
		} else {
			// v6.4.2 Some servers block reading .ini files. We could switch to
			// using .txt for the location, but this could cause loads of confusion
			// so can you catch if the location.ini has not been read and try *.txt?
			// v6.5 Too many servers have this problem, so switch the order. *.txt as the default and *.ini as alt
			//if (_global.ORCHID.commandLine.location.indexOf(".ini") > 0) {
			if (_global.ORCHID.commandLine.location.indexOf(".txt") > 0) {
				//myTrace("try .txt version as .ini missing or empty");
				myTrace("try .ini version as .txt missing or empty");
				var thisPath = _global.ORCHID.commandLine.location;
				//_global.ORCHID.commandLine.location = thisPath.substr(0,thisPath.indexOf(".ini")) + ".txt";
				_global.ORCHID.commandLine.location = thisPath.substr(0,thisPath.indexOf(".txt")) + ".ini";
				//v6.4.2 rootless
				this.master.setupPaths(); // try whole thing again
				delete this; // clear up the loadVars object
				return;
			} else {
				myTrace("warning, location file cannot be read, using defaults",1);
			}
		}
		// v6.3.4 So, where should you load main swfs from?
		// Note that ORCHID.commandLine is now the original command line + location if not from cmd
		if (_global.ORCHID.commandLine.mainMovies == undefined) {
			_global.ORCHID.paths.movie = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash("Source");
		} else {
			// v6.3.5 If the mainMovies parameter has been set, why force /Source onto it?
			// v6.4.2.4 If you are running mdm direct from a CD under Win98, all of your paths
			// need to have the root added to them. Normally you wouldn't want to as everything is
			// relative from location.ini. So what about other os, do it or not? Clearly better if all the same.
			// v6.4.2.4 But what about if the path in location is absolute?
			if (_global.ORCHID.projector.name == "MDM") {
				// v6.5.4.4 Force any / to change to \ for projectors
				_global.ORCHID.commandLine.mainMovies = _global.ORCHID.commandLine.mainMovies.split("/").join("\\");
				
				if ((_global.ORCHID.commandLine.mainMovies.indexOf("\\\\") == 0) ||
					(_global.ORCHID.commandLine.mainMovies.indexOf(":\\") == 1)) {
					_global.ORCHID.paths.movie = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.mainMovies) + _global.ORCHID.functions.addSlash("Source");
				} else {
					// v6.5.4.4 Also, if you find a ..\ in the path, get rid of it due to loading problems on some computers
					if (_global.ORCHID.commandLine.mainMovies.indexOf("..")>=0) {
						myTrace("remove .. from mainMovies path");
						// break the path into folders
						var rootFolders = _global.ORCHID.paths.root.split("\\");
						// since we know paths.root ends in a slash, the array starts one too long
						rootFolders.pop(); 
						// do the same for the mainMovies folder
						var mainFolders = _global.ORCHID.commandLine.mainMovies.split("\\");
						// if the first folder is a parent navigator, drop it and the matching root one
						while (mainFolders[0] == ".." && mainFolders.length>1 && rootFolders.length>1) {
							//trace(contentFolders[0]);
							//myTrace("drop " + rootFolders[rootFolders.length-1]);
							rootFolders.pop();
							mainFolders.shift();
						}
						_global.ORCHID.paths.movie = _global.ORCHID.functions.addSlash(rootFolders.join("\\")) + _global.ORCHID.functions.addSlash(mainFolders.join("\\")) + _global.ORCHID.functions.addSlash("Source");
					} else {
						_global.ORCHID.paths.movie = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.mainMovies) + _global.ORCHID.functions.addSlash("Source");
					}
				}
			} else {
				_global.ORCHID.paths.movie = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.mainMovies) + _global.ORCHID.functions.addSlash("Source");
			}
		}
		myTrace("so load main swfs from: " + _global.ORCHID.paths.movie,0);
		// v6.3.5 And new name for interface (buttons.swf)
		// If nothing passed, use the main movie location
		if (_global.ORCHID.commandLine.interfaceMovies == undefined) {
			_global.ORCHID.paths.interfaceMovies = _global.ORCHID.paths.movie;
		} else {
			if (_global.ORCHID.projector.name == "MDM") {
				// v6.5.4.4 Force any / to change to \ for projectors
				_global.ORCHID.commandLine.interfaceMovies = _global.ORCHID.commandLine.interfaceMovies.split("/").join("\\");
				
				if ((_global.ORCHID.commandLine.interfaceMovies.indexOf("\\\\") == 0) ||
					(_global.ORCHID.commandLine.interfaceMovies.indexOf(":\\") == 1)) {
					_global.ORCHID.paths.interfaceMovies = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.interfaceMovies);
				} else {
					// v6.5.4.4 Also, if you find a ..\ in the path, get rid of it due to loading problems on some computers
					if (_global.ORCHID.commandLine.interfaceMovies.indexOf("..")>=0) {
						myTrace("remove .. from interfaceMovies path");
						// break the path into folders
						var rootFolders = _global.ORCHID.paths.root.split("\\");
						// since we know paths.root ends in a slash, the array starts one too long
						rootFolders.pop(); 
						// do the same for the content folder
						var interfaceFolders = _global.ORCHID.commandLine.interfaceMovies.split("\\");
						// if the first folder is a parent navigator, drop it and the matching root one
						while (interfaceFolders[0] == ".." && interfaceFolders.length>1 && rootFolders.length>1) {
							//trace(contentFolders[0]);
							//myTrace("drop " + rootFolders[rootFolders.length-1]);
							rootFolders.pop();
							interfaceFolders.shift();
						}
						_global.ORCHID.paths.interfaceMovies = _global.ORCHID.functions.addSlash(rootFolders.join("\\")) + _global.ORCHID.functions.addSlash(interfaceFolders.join("\\"));
					} else {
						_global.ORCHID.paths.interfaceMovies = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.interfaceMovies);
					}
				}
			} else {
				_global.ORCHID.paths.interfaceMovies = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.interfaceMovies);
			}
			myTrace("and load interface from: " + _global.ORCHID.paths.interfaceMovies,0);
		}
		// v6.3.4 and the branding ones?
		// If nothing passed, use the interface movies location
		if (_global.ORCHID.commandLine.brandMovies == undefined) {
			_global.ORCHID.paths.brandMovies = _global.ORCHID.paths.interfaceMovies;
		} else {
			if (_global.ORCHID.projector.name == "MDM") {
				// v6.5.4.4 Force any / to change to \ for projectors
				_global.ORCHID.commandLine.brandMovies = _global.ORCHID.commandLine.brandMovies.split("/").join("\\");
				
				if ((_global.ORCHID.commandLine.brandMovies.indexOf("\\\\") == 0) ||
					(_global.ORCHID.commandLine.brandMovies.indexOf(":\\") == 1)) {
					_global.ORCHID.paths.brandMovies = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.brandMovies);
				} else {
					// v6.5.4.4 Also, if you find a ..\ in the path, get rid of it due to loading problems on some computers
					if (_global.ORCHID.commandLine.brandMovies.indexOf("..")>=0) {
						myTrace("remove .. from brandMovies path");
						// break the path into folders
						var rootFolders = _global.ORCHID.paths.root.split("\\");
						// since we know paths.root ends in a slash, the array starts one too long
						rootFolders.pop(); 
						// do the same for the content folder
						var brandFolders = _global.ORCHID.commandLine.brandMovies.split("\\");
						// if the first folder is a parent navigator, drop it and the matching root one
						while (brandFolders[0] == ".." && brandFolders.length>1 && rootFolders.length>1) {
							//trace(contentFolders[0]);
							//myTrace("drop " + rootFolders[rootFolders.length-1]);
							rootFolders.pop();
							brandFolders.shift();
						}
						_global.ORCHID.paths.brandMovies = _global.ORCHID.functions.addSlash(rootFolders.join("\\")) + _global.ORCHID.functions.addSlash(brandFolders.join("\\"));
					} else {
						_global.ORCHID.paths.brandMovies = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.brandMovies);
					}
				}
			} else {
				_global.ORCHID.paths.brandMovies = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.brandMovies);
			}
			myTrace("and load brand from: " + _global.ORCHID.paths.brandMovies,0);
		}
		// v6.5.6.5 Allow brand movies to have prefix in it. If it does, substitute it here.
		// It is possible that you don't know the prefix at this point. So better to do it in OrchidObjects
		//var prefixString = "#prefix#";
		//if (_global.ORCHID.paths.brandMovies.indexOf(prefixString)>=0) {
		//	_global.ORCHID.paths.brandMovies = findReplace(_global.ORCHID.paths.brandMovies,prefixString,_global.ORCHID.commandLine.prefix);
		//}
		
		// v6.3.4 Should you load courses from somewhere else?
		if (_global.ORCHID.commandLine.content == undefined) {
			_global.ORCHID.paths.content = _global.ORCHID.paths.root;
		} else {
			// v6.4.2.4 Don't add anything to absolute paths from location.ini
			if (_global.ORCHID.projector.name == "MDM") {
				// v6.5.4.4 Force any / to change to \ for projectors
				_global.ORCHID.commandLine.content = _global.ORCHID.commandLine.content.split("/").join("\\");
				
				if ((_global.ORCHID.commandLine.content.indexOf("\\\\") == 0) ||
					(_global.ORCHID.commandLine.content.indexOf(":\\") == 1)) {
					_global.ORCHID.paths.content = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.content);
				} else {
					// v6.4.2.4 Also, if you find a ..\ in the  path, get rid of it due to video problems (see videoPlayer.as)
					if (_global.ORCHID.commandLine.content.indexOf("..")>=0) {
						myTrace("remove .. from content path");
						// break the path into folders
						var rootFolders = _global.ORCHID.paths.root.split("\\");
						myTrace("rootFolders=" + rootFolders.toString());
						// since we know paths.root ends in a slash, the array starts one too long
						rootFolders.pop(); 
						// do the same for the content folder
						var contentFolders = _global.ORCHID.commandLine.content.split("\\");
						myTrace("contentFolders=" + contentFolders.toString());
						// if the first folder is a parent navigator, drop it and the matching root one
						while (contentFolders[0] == ".." && contentFolders.length>1 && rootFolders.length>1) {
							//trace(contentFolders[0]);
							myTrace("drop " + rootFolders[rootFolders.length-1]);
							rootFolders.pop();
							contentFolders.shift();
						}
						_global.ORCHID.paths.content = _global.ORCHID.functions.addSlash(rootFolders.join("\\")) + _global.ORCHID.functions.addSlash(contentFolders.join("\\"));
					} else {
						_global.ORCHID.paths.content = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.content);
					}
				}
			} else {
				// v6.4.2.4 Also, if you find a ..\ in the path, get rid of it due to video problems
				// and is presumably a Flash security issue - can you get round it? It happens if you are running a file through the browser
				// so NOT using a webserver. Comes up in the CE demo CD.
				if (_global.ORCHID.commandLine.content.indexOf("..")>=0) {
					// break the path into folders
					myTrace("content contains .., so build full path from " + _global.ORCHID.commandLine.content);
					// break the path into folders, in this case the place to build on is the UDP as root will point to the control.swf
					// userDataPath=/D:/Fixbench/RoadToIELTS
					var rootFolders = _global.ORCHID.commandLine.userDataPath.split("/");
					myTrace("rootFolders=" + rootFolders.toString());
					// do the same for the content folder
					var contentFolders = _global.ORCHID.commandLine.content.split("/");
					myTrace("contentFolders=" + contentFolders.toString());
					// if the first folder is a parent navigator, drop it and the matching root one
					while (contentFolders[0] == ".." && contentFolders.length>1 && rootFolders.length>1) {
						//trace(contentFolders[0]);
						myTrace("drop " + rootFolders[rootFolders.length-1]);
						rootFolders.pop();
						contentFolders.shift();
					}
					var builtPath = _global.ORCHID.functions.addSlash(rootFolders.join("/")) + _global.ORCHID.functions.addSlash(contentFolders.join("/"));
					//myTrace("built path=" + builtPath);
					//_global.ORCHID.paths.content = _global.ORCHID.functions.addSlash(rootFolders.join("/")) + _global.ORCHID.functions.addSlash(contentFolders.join("/"));
					_global.ORCHID.paths.content = builtPath;
				} else {
					_global.ORCHID.paths.content = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.content);
				}
			}
		}
		myTrace("and load content from: " + _global.ORCHID.paths.content,0);
		// v6.5.6.0 If this content is at a different domain, need to allow it to call back to me
		// If you want you could base this on the content path to allow for everything to call back
		// Or you could hardcode good domains. This would mean that you need to update control.swf each time
		// you add a new CDN or something.
		// http://claritymain/Content/
		// /Content/
		// http://d1evmpzy97k5y8.cloudfront.net/
		/*
		if (_global.ORCHID.paths.content.substr(0,7)=='http://') {
			var contentDomain = _global.ORCHID.paths.content.substr(0, _global.ORCHID.paths.content.indexOf("/",7));
		} else {
			var contentDomain = _global.ORCHID.paths.content.split("/").slice(0,-2).join("/");
		}
		*/
		if (_global.ORCHID.paths.content.substr(0,7)=='http://') {
			var domainEnd = _global.ORCHID.paths.content.indexOf("/",7);
			if (domainEnd<=0) domainEnd=_global.ORCHID.paths.content.length;
			var contentDomain = _global.ORCHID.paths.content.substr(0, domainEnd);
			//System.security.allowDomain("http://claritymain, http://www.ClarityEnglish.com");
			//System.security.allowDomain("http://claritymain, http://www.ClarityEnglish.com");
			System.security.allowDomain(contentDomain);
			myTrace("allowDomain from " + contentDomain);
		}
		
		if (_global.ORCHID.commandLine.MGSName != undefined) {
			myTrace("and use MGSName: " + _global.ORCHID.commandLine.MGSName,0);
		}
		if (_global.ORCHID.commandLine.MGSRoot != undefined) {
			myTrace("and use MGSRoot: " + _global.ORCHID.commandLine.MGSRoot,0);
		}
		// v6.4.2.4 MGS. course.xml will be picked up from the MGS + Title
		// eg: /SAY1AC/TenseBuster.
		// But you don't know where that is until you have logged in so it might
		// be better to move this code until after login...
		/*
		// v6.4.2 AP editing of CE
		// v6.4.1.4 The course.xml will have full path to edited content
		//if (_global.ORCHID.commandLine.editedContent == undefined) {
		//	_global.ORCHID.paths.editedContent = _global.ORCHID.paths.content;
		//} else {
		//	_global.ORCHID.paths.editedContent = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.editedContent);
		//	myTrace("plus edited content from: " + _global.ORCHID.paths.editedContent,1);
		//}
		// v6.3.6 And what controls the courses?
		if (_global.ORCHID.commandLine.courseFile == undefined) {
			_global.ORCHID.paths.courseFile = _global.ORCHID.paths.content + "course.xml";
		} else {
			// is the courseFile a file name or a full path?
			if ((_global.ORCHID.commandLine.courseFile.indexOf("/") < 0) && 
				(_global.ORCHID.commandLine.courseFile.indexOf("\\") < 0)) {
				_global.ORCHID.paths.courseFile = _global.ORCHID.paths.content + _global.ORCHID.commandLine.courseFile;
			} else {
				if (_global.ORCHID.projector.name == "MDM") {
					_global.ORCHID.paths.courseFile = _global.ORCHID.paths.root + _global.ORCHID.commandLine.courseFile;
				} else {
					_global.ORCHID.paths.courseFile = _global.ORCHID.commandLine.courseFile;
				}
			}
			// was the filetype forgotten?
			if (_global.ORCHID.paths.courseFile.indexOf(".") <0) {
				_global.ORCHID.paths.courseFile += ".xml";
			}
			myTrace("and course index is: " + _global.ORCHID.paths.courseFile,0);
		}
		*/
		// v6.3.5 And the shared media path is where?
		if (_global.ORCHID.commandLine.sharedMedia == undefined) {
			_global.ORCHID.paths.sharedMedia = undefined;
		} else {
			if (_global.ORCHID.projector.name == "MDM") {
				// v6.5.4.4 Force any / to change to \ for projectors
				_global.ORCHID.commandLine.sharedMedia = _global.ORCHID.commandLine.sharedMedia.split("/").join("\\");
				
				if ((_global.ORCHID.commandLine.sharedMedia.indexOf("\\\\") == 0) ||
					(_global.ORCHID.commandLine.sharedMedia.indexOf(":\\") == 1)) {
					_global.ORCHID.paths.sharedMedia = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.sharedMedia);
				} else {
					// v6.5.4.4 Also, if you find a ..\ in the path, get rid of it due to loading problems on some computers
					if (_global.ORCHID.commandLine.sharedMedia.indexOf("..")>=0) {
						myTrace("remove .. from sharedMedia path");
						// break the path into folders
						var rootFolders = _global.ORCHID.paths.root.split("\\");
						// since we know paths.root ends in a slash, the array starts one too long
						rootFolders.pop(); 
						// do the same for the content folder
						var sharedFolders = _global.ORCHID.commandLine.sharedMedia.split("\\");
						// if the first folder is a parent navigator, drop it and the matching root one
						while (sharedFolders[0] == ".." && sharedFolders.length>1 && rootFolders.length>1) {
							//trace(contentFolders[0]);
							//myTrace("drop " + rootFolders[rootFolders.length-1]);
							rootFolders.pop();
							sharedFolders.shift();
						}
						_global.ORCHID.paths.sharedMedia = _global.ORCHID.functions.addSlash(rootFolders.join("\\")) + _global.ORCHID.functions.addSlash(sharedFolders.join("\\"));
					} else {
						_global.ORCHID.paths.sharedMedia = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.sharedMedia);
					}
				}
			} else {
				_global.ORCHID.paths.sharedMedia = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.sharedMedia);
			}
			myTrace("and shared media from: " + _global.ORCHID.paths.sharedMedia,0);
		}
		// v6.3.5 And the streaming media path is where?
		if (_global.ORCHID.commandLine.streamingMedia == undefined) {
			_global.ORCHID.paths.streamingMedia = undefined;
		} else {
			if (_global.ORCHID.projector.name == "MDM") {
				// v6.5.4.4 Force any / to change to \ for projectors
				_global.ORCHID.commandLine.streamingMedia = _global.ORCHID.commandLine.streamingMedia.split("/").join("\\");
				
				if ((_global.ORCHID.commandLine.streamingMedia.indexOf("\\\\") == 0) ||
					(_global.ORCHID.commandLine.streamingMedia.indexOf(":\\") == 1)) {
					_global.ORCHID.paths.streamingMedia = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.streamingMedia);
				} else {
					// v6.5.4.4 Also, if you find a ..\ in the path, get rid of it due to loading problems on some computers
					if (_global.ORCHID.commandLine.streamingMedia.indexOf("..")>=0) {
						myTrace("remove .. from streamingMedia path");
						// break the path into folders
						var rootFolders = _global.ORCHID.paths.root.split("\\");
						// since we know paths.root ends in a slash, the array starts one too long
						rootFolders.pop(); 
						// do the same for the content folder
						var sharedFolders = _global.ORCHID.commandLine.streamingMedia.split("\\");
						// if the first folder is a parent navigator, drop it and the matching root one
						while (sharedFolders[0] == ".." && sharedFolders.length>1 && rootFolders.length>1) {
							//trace(contentFolders[0]);
							//myTrace("drop " + rootFolders[rootFolders.length-1]);
							rootFolders.pop();
							sharedFolders.shift();
						}
						_global.ORCHID.paths.streamingMedia = _global.ORCHID.functions.addSlash(rootFolders.join("\\")) + _global.ORCHID.functions.addSlash(sharedFolders.join("\\"));
					} else {
						_global.ORCHID.paths.streamingMedia = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.streamingMedia);
					}
				}
			} else {
				// v6.4.2.4 Also, if you find a ..\ in the path, get rid of it due to video problems
				// and is presumably a Flash security issue - can you get round it? It happens if you are running a file through the browser
				// so NOT using a webserver. Comes up in the CE demo CD.
				if (_global.ORCHID.commandLine.streamingMedia.indexOf("..")>=0) {
					// break the path into folders
					myTrace("streamingMedia contains .., so build full path from " + _global.ORCHID.commandLine.streamingMedia);
					// break the path into folders, in this case the place to build on is the UDP as root will point to the control.swf
					// userDataPath=/D:/Fixbench/RoadToIELTS
					var rootFolders = _global.ORCHID.commandLine.userDataPath.split("/");
					//myTrace("rootFolders=" + rootFolders.toString());
					// do the same for the content folder
					var mediaFolders = _global.ORCHID.commandLine.streamingMedia.split("/");
					//myTrace("mediaFolders=" + mediaFolders.toString());
					// if the first folder is a parent navigator, drop it and the matching root one
					while (mediaFolders[0] == ".." && mediaFolders.length>1 && rootFolders.length>1) {
						//trace(contentFolders[0]);
						//myTrace("drop " + rootFolders[rootFolders.length-1]);
						rootFolders.pop();
						mediaFolders.shift();
					}
					var builtPath = _global.ORCHID.functions.addSlash(rootFolders.join("/")) + _global.ORCHID.functions.addSlash(mediaFolders.join("/"));
					//myTrace("built path=" + builtPath);
					//_global.ORCHID.paths.content = _global.ORCHID.functions.addSlash(rootFolders.join("/")) + _global.ORCHID.functions.addSlash(contentFolders.join("/"));
					_global.ORCHID.paths.streamingMedia = builtPath;
				} else {
					_global.ORCHID.paths.streamingMedia = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.streamingMedia);
				}
			}
			myTrace("and streaming media from: " + _global.ORCHID.paths.streamingMedia,0);
		}
		
		// 6.0.5.0 added a new path, although this is not yet passed to the webserver programs
		// v6.3 Remember that Linux is case sensitive
		// v6.3.1 How to take or at least override these paths after reading from the licence file?
		//_global.ORCHID.paths.student = "Student" + folderSlash;
		// v6.4.2 This is now fully changeable from command and location (and is not appended with root)
		// Only relevant for projector use
		if (_global.ORCHID.commandLine.dbDetails.dbPath == undefined) {
			_global.ORCHID.paths.dbPath = _global.ORCHID.paths.movie;
		} else {
			if (_global.ORCHID.projector.name == "MDM") {
				// v6.5.4.4 Force any / to change to \ for projectors
				_global.ORCHID.commandLine.dbDetails.dbPath = _global.ORCHID.commandLine.dbDetails.dbPath.split("/").join("\\");
				
				if ((_global.ORCHID.commandLine.dbDetails.dbPath.indexOf("\\\\") == 0) ||
					(_global.ORCHID.commandLine.dbDetails.dbPath.indexOf(":\\") == 1)) {
					_global.ORCHID.paths.dbPath = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.dbDetails.dbPath);
				} else {
					// v6.5.4.4 Also, if you find a ..\ in the path, get rid of it due to loading problems on some computers
					if (_global.ORCHID.commandLine.dbDetails.dbPath.indexOf("..")>=0) {
						myTrace("remove .. from dbPath path");
						// break the path into folders
						var rootFolders = _global.ORCHID.paths.root.split("\\");
						// since we know paths.root ends in a slash, the array starts one too long
						rootFolders.pop(); 
						// do the same for the content folder
						var dbFolders = _global.ORCHID.commandLine.dbDetails.dbPath.split("\\");
						// if the first folder is a parent navigator, drop it and the matching root one
						while (dbFolders[0] == ".." && dbFolders.length>1 && rootFolders.length>1) {
							//trace(contentFolders[0]);
							//myTrace("drop " + rootFolders[rootFolders.length-1]);
							rootFolders.pop();
							dbFolders.shift();
						}
						_global.ORCHID.paths.dbPath = _global.ORCHID.functions.addSlash(rootFolders.join("\\")) + _global.ORCHID.functions.addSlash(dbFolders.join("\\"));
					} else {
						_global.ORCHID.paths.dbPath = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.dbDetails.dbPath);
					}
				}
			} else {
				_global.ORCHID.paths.dbPath = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.dbDetails.dbPath);
			}
			myTrace("and database from: " + _global.ORCHID.paths.dbPath,1);
		}
		
		// v6.3.6 Not used anymore
		//_global.ORCHID.paths.brand = "Brand" + folderSlash;
		// The following settings are made in view.as after the course.xml is read
		//_global.ORCHID.paths.course = "";
		//_global.ORCHID.paths.subCourse = "";
		//_global.ORCHID.paths.exercises = "Exercises" + folderSlash;
		//_global.ORCHID.paths.media = "Media" + folderSlash;

		//v6.4.2 Now see if you have been passed a licence, or whether to assume the default name
		// v6.5.4.5 Don't change the original as I may want to know if I have been specifically passed a licence from now on
		if (_global.ORCHID.commandLine.licence == undefined || _global.ORCHID.commandLine.licence == "") {
			// v6.5 Switching to *.txt first then *.ini
			//_global.ORCHID.commandLine.licence = "licence.ini";
			//_global.ORCHID.commandLine.licence = "licence.txt";
			var licenceFileName = "licence.txt";
		} else {
			var licenceFileName = _global.ORCHID.commandLine.licence;
		}
		// v6.3.5 Licence might be a full path, or just a file name
		// So make it into a full path one way or another
		if ((licenceFileName.indexOf("/") < 0) && (licenceFileName.indexOf("\\") < 0)) {
			if (_global.ORCHID.commandLine.userDataPath == undefined) {
				_global.ORCHID.paths.licence = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.root) + licenceFileName;
			} else {
				_global.ORCHID.paths.licence = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.userDataPath) + licenceFileName;
			}
		} else {
			myTrace("licence passed as a full path");
			// v6.3.6 This was missing!
			if (_global.ORCHID.projector.name == "MDM") {
				// v6.5.4.4 Force any / to change to \ for projectors
				_licenceFileName = licenceFileName.licence.split("/").join("\\");
				
				if ((licenceFileName.indexOf("\\\\") == 0) ||
					(licenceFileName.indexOf(":\\") == 1)) {
					// v6.5.4.1 has add slash been added to the wrong line? Anyway, it should not be on this first one
					//_global.ORCHID.paths.licence = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.licence);
					_global.ORCHID.paths.licence = licenceFileName;
				} else {
					//_global.ORCHID.paths.licence = _global.ORCHID.paths.root + _global.ORCHID.commandLine.licence;
					_global.ORCHID.paths.licence = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.root) + licenceFileName;
				}
			} else {
				_global.ORCHID.paths.licence = licenceFileName;
			}
		}
		myTrace("use licence=" + _global.ORCHID.paths.licence,0);
		// the key stage in going forward is running loadVersionTable
		//myTrace("now loadVersionTable");
		// v6.4.2 rootless
		controlNS.loadVersionTable();
	}
	// v6.3.5 The userdatapath (place where location.ini can be found) might
	// be passed to you. But for ClarityEnglish we don't want this. The location.ini
	// in the userDataPath is used by remoteStart only. Here we want the shared one
	// to be read - which will be in root. For launch, udp will no longer be passed.
	// v6.3.5 Override this. CE will now pass udp and this is where location is.
	// v6.4.2 location.ini might be called something else
	if (_global.ORCHID.commandLine.location == undefined) {
		// v6.5 Switching to *.txt first then *.ini
		//_global.ORCHID.commandLine.location = "location.ini"
		_global.ORCHID.commandLine.location = "location.txt"
	}
	if (_global.ORCHID.commandLine.userDataPath == undefined) {
	// v6.4.2 rootless
		var locationFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.root) + _global.ORCHID.commandLine.location
	} else {
		var locationFile = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.userDataPath) + _global.ORCHID.commandLine.location
	}
	myTrace("try to read " + locationFile);
	getLocation.load(locationFile + cacheVersion);
}

//myTrace(false);
//myTrace("root is " + _global.ORCHID.paths.root);

// set the version numbers of each module that will be used
// this init is done in versionTable.swf and this gives us a useful result later
//_global.ORCHID.versionTable = new Object;
// read the version control table, always get a fresh one
this.createEmptyMovieClip("versionHolder", controlNS.depth++);
// EGU special - for any application where you are likely to be running under FSP
// from a CD with Win98 + WinME, then you need to move this line INSIDE checkFSP
// and only do it if necessary.
//this.versionHolder.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + "versionTable.swf" + cacheVersion);
// v6.4.2 rootless
controlNS.loadVersionTable = function() {
	myTrace("load version info from " + _global.ORCHID.paths.movie + "versionTable.swf",1);
	// v6.4.2 rootless
	//myTrace("controlNS.loadVersionTable this=" + this.whoami);
	this.master.versionHolder.loadMovie(_global.ORCHID.paths.movie + "versionTable.swf" + cacheVersion);
}
// once this is loaded you can go to the main frame of the movie
// this is a simple callback from the versionTable movie
_global.ORCHID.versionTableLoaded = function() {
	//myTrace("loaded the version table, so start the application");
	//myTrace("version is " + _global.ORCHID.versionTable.overall);
	// v6.3.1 BUG. For Sam in Canada he freezes on 0% progress. myTrace shows that he gets
	// the above line, but does not get the "top of frame 2" line, so therefore the following
	// gotoAndPlay is not running correctly. It doesn't seem that loadVersionTable is run twice
	// or anything. Why does it happen? Is it due to the FSP checking?
	// No, I can also get this when running on the web, even after removing FSP checking.
	// So try setting to a frame number instead of a name (and no need to remove the version movie eh?)
	//_root.gotoAndPlay(2);
	// v6.3.5 Move the frame up a bit
	// v6.3.6 I am getting the above problem again when running in Dokeos. I had edited the 
	// frame number back to a name. Was that really the problem though? YES, it does make an 
	// immediate difference!
	// v6.4.2 rootless
	// this=??
	myTrace("request to play main frame of " + _global.ORCHID.root.whoami);
	_global.ORCHID.root.gotoAndPlay(3);
	//this.versionHolder.removeMovieClip();
}
// v6.3.1 Testing - try not doing any FSP stuff to see if that makes the browser version
// always work. From one report it appears that this does make things work. So assume
// that this interval loop can cause bad stuff to happen.
// See also conditional around first frame mdm code.
// Now, only need to do this check if you are NOT for sure in a browser
// v6.3.1 You should always run control from a browser page that contains a browser parameter
// This way you will know that you are in a browser (and indeed which one).
_global.ORCHID.projector = {name:"unknown"};
_global.ORCHID.projector.ocxLoaded=false;
_global.ORCHID.projector.lcLoaded=false;
_global.ORCHID.projector.isRecorderV2	= false;
// Note that myPlayer and versionToString are written into the first frame of control.fla
_global.ORCHID.projector.FlashVersion=myPlayer;
// v6.4.2 rootless
myTrace("Flash " + this.versionToString(_global.ORCHID.projector.FlashVersion),0); // + " (major=" + _global.ORCHID.projector.FlashVersion.major + ")");

//v6.4.1 A function used to trigger direct display of an exercise
// Expected to be used by external apps (such as APP Preview)
// v6.4.2 Expanded to include courseID
// v6.4.2 Moved into a function as might be called directly from a browser or after command line
// has been read in ZINC
// v6.4.2 rootless
controlNS.runPreviewMode = function() {
	// this=controlNS
	//myTrace("rootless:runPreviewMode=" + this.whoami);
	if (_global.ORCHID.commandLine.preview) {
		// For checking
		_global.ORCHID.session.validPreview = false;
		myTrace("running preview, commandline.preview=" + _global.ORCHID.commandLine.preview);
		this.receiveConn = new LocalConnection();
		this.receiveConn.master = this;
		this.receiveConn.displayExercise = function(courseID, exID) {
			// v6.4.3 If you are in projector mode, need to bring this window to front
			if (_global.ORCHID.projector.name == "MDM") {
				myTrace("focus to winID=" + _global.ORCHID.projector.winID);
				mdm.setwindowfocus(_global.ORCHID.projector.winID);
			} else {
				// v6.4.1.4 And for browser mode, try window.focus. Works in all my browsers.
				//myTrace("run js:window.focus");
				getURL("javascript:window.focus()");
			}
			myTrace("ValidPreview: request course " + courseID + " and ex " + exID);
			// Lets accept that this really is an author preview, so skip things like hiddenContent.
			_global.ORCHID.session.validPreview = true;
			
			// Is this for the currently displayed course?
			if (courseID == _global.ORCHID.session.courseID) {
				myTrace("stay in current course please");
				// v6.4.1.4 Since the author might have just added this exercise, you might
				// not have a valid ID for the current menu, in which case reload menu
				// Note this might still go wrong if you preview from menu having added
				// a new ex. Not sure how to catch that! OK, simply always reset the menu.
				// This doesn't take long.
				var item = _global.ORCHID.course.scaffold.getObjectByID(exID);
				//myTrace("found item, action=" + item.action + ", item=" + item);
				// is there an exercise ID passed?
				if (exID == undefined || exID == "undefined" || exID <= 0) {
					// if not, just display the menu screen
					//_global.ORCHID.viewObj.displayScreen("MenuScreen");
					_global.ORCHID.commandLine.startingPoint = "menu";
					_global.ORCHID.viewObj.cmdCourseList();
				} else {
					// if ex passed, it might be new
					if (item != null) {
						// no, it was found
						_root.controlNS.directExercise(exID)
					} else {
						// the exercise does not exist in this course, reload
						myTrace("but reload for new exercise");
						_global.ORCHID.commandLine.startingPoint = "ex:" + exID;
						_global.ORCHID.viewObj.cmdCourseList()
					}
				}
			// if no course passed, show the list
			} else if (courseID == undefined || courseID == 'undefined' || courseID == 0) {
				myTrace("preview: undefined course");
				_global.ORCHID.commandLine.course = undefined;
				_global.ORCHID.commandLine.startingPoint = undefined;
				_global.ORCHID.viewObj.cmdCourseList();
			// if not, then restart using SCORM type parameter passing
			} else {
				myTrace("preview: open new course");
				_global.ORCHID.commandLine.course = courseID;
				// NOTE you have to do something here to get into the new course
				// otherwise the exID is going to be invalid.
				// Try using courselistscreen.display as this will re-read course.xml
				//_global.ORCHID.viewObj.displayScreen("CourseListScreen");
				// Or how about the base course reading point?
				// Can you keep going?
				if (exID == undefined || exID == "undefined" || exID <= 0) {
					_global.ORCHID.commandLine.startingPoint = "menu";
				} else {
					_global.ORCHID.commandLine.startingPoint = "ex:" + exID;
				}
				//myTrace("preview from this=" + this.master.whoami);
				//controlNS.readCourse();
				this.master.readCourse();
				//_root.controlNS.startingDirect();
			}
			this.send("OrchidResponse", "onReceiveCommand", true);
		}
		//myTrace("tell conn 'OrchidCommand' ");
		var connectSuccess = this.receiveConn.connect("OrchidCommand");
		//myTrace("preview, so create localConnection, success=" + connectSuccess,1);
	} else {
		//myTrace("no preview");
	}
}

if (this.browser != undefined) {
	myTrace("running in browser=" + this.browser,0);
	_global.ORCHID.projector.name="browser " + this.browser;
	// The browser might be able to talk to the ClarityRecorder through localConnection
	// but we will only try this when we need it
	//controlNS.testClarityRecorder();
	// You are in the browser, so run the regular versionTable loader here
	// v6.3.4 Check paths then do the version table load
	// v6.4.2 rootless
	// this=proxy root
	//myTrace("call setupPaths direct from this=" + this.whoami);
	controlNS.setupPaths();
	//loadVersionTable();
	// v6.3.6 SCORM. Since you might have loaded control through a remote movie
	// it is dangerous for the scormStart.html to use onLoad to run LMSInitialise
	// since it might work whilst the stub is still the movie. Therefore you must
	// call it here.
	if (_global.ORCHID.commandLine.scorm) {
		// v6.4.2.4
		// Now use Flash/Javascript Integration Kit
		// (Although this is not done completely, need to go to 6.4.3 for that)
		// Added into here, using scorm.swf from 6.4.3. That does the LMSInitialise stuff
		/*
		import com.macromedia.javascript.JavaScriptProxy;
		var proxy:JavaScriptProxy = new JavaScriptProxy(_root.lcId, this);
		// a function that javascript calls to set variables
		// This appears clumsy, but means that scorm.swf does not have to change
		this.setVariable = function(varArray) {
			for (var i=0; i<varArray.length; i++) {
				myTrace("control.setVariable " + varArray[i].name + "=" + varArray[i].value);
				if (varArray[i].error != undefined) {
					_root[varArray[i].name] = "error:" + varArray[i].error;
				} else if (varArray[i].value == undefined) {
					_root[varArray[i].name] = " ";
				} else {
					_root[varArray[i].name] = varArray[i].value;
				}
			}
		}
		myTrace("call javascript:LMSInitialize from control+JSFG",1);
		getURL("javascript:LMSInitialize()");
		*/
	}
	// v6.4.2 Check on preview mode (from APP)
	//myTrace("call runPreviewMode");
	controlNS.runPreviewMode();

} else {
	myTrace("running in unknown host, so try FSP checks",0);
	// v6.3.5 FSP move to ZINC
	// now using {mdm}script, callbacks and preset variables
	// Code will become incompatible with older versions of the projector.
	// So what I want to do is 
	// a) establish if I am running in the projector - if not then keep going
	// b) what the app folder is 
	// c) run setuppaths once I know this
	// d) get machine details for licence control
	// e) set up exception handling
	// f) load the recording ocx	
	//myTrace("winverstring=" + _root.mdm_winverstring);
	if (_root.mdm_winverstring != undefined) {
		
		// v6.3.1 now that we know we are running under FSP
		//_global.ORCHID.projector.name = "FlashStudioPro"
		_global.ORCHID.projector.name = "MDM"
		// hard code a version number for FSP so that you can cope with different
		// ocx syntax and features. NOTE: v1 and v2.0 no longer compatible
		//_global.ORCHID.projector.version = 1.9;
		_global.ORCHID.projector.version = 2.1;
		//_global.ORCHID.projector.ocxLoaded = false;
		//v 6.3.5 You will catch an error if the loading fails, so the default is success!
		// v6.5.5.9 No longer.
		//_global.ORCHID.projector.ocxLoaded = true;
		_global.ORCHID.projector.ocxLoaded = false;
		myTrace("running in MDM projector under " + _root.mdm_winverstring,1);

		// Set up the object for callbacks and variables
		_global.ORCHID.projector.callbacks = new Object();
		_global.ORCHID.projector.variables = new Object();
		_global.ORCHID.projector.delays = new Object();
		
		// v6.3.5 Use the preset variable for the application folder.
		//myTrace("app folder is " + _root.mdm_appdir,1);
				
		// v6.3.5 error handling. Remove this line during debugging to get full MDM errors.
		//fscommand("flashstudio.exceptionhandler_enable"); 
		mdm.exceptionhandler_enable();
		_root.onMDMScriptException = function(errorMessage,errorFormType,errorFrameNumber,errorParameter,errorParameterValue) { 
			// v6.4.2.6 Move this to the beginning, it seems to not trigger at the end
			mdm.exceptionhandler_reset(); 
			if (_root.mdm_exception == "error") {
				myTrace(_global.ORCHID.projector.variables.doingWhat + ":error " + 
						errorMessage + ", parameter=" + errorParameterValue,2);
				// react to errors from expected causes that you can handle 
				if (_global.ORCHID.projector.variables.doingWhat == "loadOCX") {
					myTrace("recorder ocx not loaded",1);
					_global.ORCHID.projector.ocxLoaded = false;
				} else if (_global.ORCHID.projector.variables.doingWhat == "dbCriticalCall") {
					myTrace("catastrophic db error",2);
					// stop with a db warning
					var errObj = {literal:"dbError", detail:errorMessage};
					this.controlNS.sendError(errObj);
					stop();
				// v6.4.2.6 Add the callback to the sql query so that it can decide whether to keep going or not
				} else if (_global.ORCHID.projector.variables.doingWhat == "dbCall") {
					myTrace("mdm:database error, keep going, " + _global.ORCHID.projector.variables.doingWhat,1);
					_global.ORCHID.projector.callbacks.resultsAction(false);
				} else {
					myTrace("mdm:error, keep going, " + _global.ORCHID.projector.variables.doingWhat,1);
					}
				// otherwise the error is completely ignored!
			}
			//mdm.exceptionhandler_reset(); 
		} 
		
		// v6.3.5 Machine information for licence control
		_global.ORCHID.projector.callbacks.getIPAddress = function(value) {
			_global.ORCHID.projector.ipAddress = value;
		}
		mdm.getipaddress(_global.ORCHID.projector.callbacks.getIPAddress); 
		_global.ORCHID.projector.machineID = _root.mdm_hdserial;

		// v6.5.6 You might need to know if the AIR Clarity Recorder is installed from registry keys, so ask for that info now and save for later use
		_global.ORCHID.projector.recorderRegistry=0;
		_global.ORCHID.projector.callbacks.getRecorderRegistry = function(value) {
			myTrace("MDM delayed callback for Clarity Recorder registry=" + value + " number=" + parseFloat(value));
			if (parseFloat(value)>=4) {
				_global.ORCHID.projector.recorderRegistry = parseFloat(value);
			}
		}
		// If the key doesn't exist, there will simply be no return.
		mdm.loadfromreg_str("3","SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\com.ClarityEnglish.ClarityRecorder","DisplayVersion",_global.ORCHID.projector.callbacks.getRecorderRegistry);		
		
		// v6.4.2.8 Note that we pause at the end of this frame waiting for this callback to complete. It can easily take
		// the full timeout allotted if it is a laptop that thinks it has internet, but hasn't. The simplest might be to
		// just move this chunk to frame 3 where it can happily take as long as it wants.
		/*
		// v6.4.2.7 Add a check to see if you are connected to the internet at the moment. Will be used later for
		// weblinks (pick up from CD if not connected) etc
		var address = "www.ClarityEnglish.com"; 
		var timeout = "5000"; 
		_global.ORCHID.projector.callbacks.getInternetConnection = function(value) {
			myTrace("internet connection=" + value);
			if (value || value.toLowerCase()=="true") {
				_global.ORCHID.projector.internetConnection = true;
			} else {
				_global.ORCHID.projector.internetConnection = false;
			}
		}
		mdm.checkconnection_ping(address,timeout,_global.ORCHID.projector.callbacks.getInternetConnection); 
		myTrace("checking internet connection");
		*/
		
		// v6.4.3 Also find out what the windowID is (if ZINC) for later preview user
		var findMyWindow = function(winList) {
			myTrace("winList=" + winList);
			var winArray = winList.split(";");
			for (var i in winArray) {
				var winDetails = winArray[i].split(",");
				// How to get the current window title? It appears to always be 
				// first on the returned list, but is this reliable?
				// Also, we should read our apptitle from mdm rather than coding it
				// Or rather, set the title based on the licence, then use that.
				// v6.4.2.4 You can't seem to read the apptitle in ZINC 2.1 plus I haven't
				// read the licence file yet! So it will just have to be hard coded.
				if (winDetails[0] == "Author Plus") {
					_global.ORCHID.projector.winID = winDetails[1];
					myTrace("this winID=" + _global.ORCHID.projector.winID);
					break;
				}
			}
		}
		//myTrace("get windowID");
		mdm.getwindowlist(findMyWindow); 

		// ZINC: a frame to go to and run when the exit button in the projector
		// is clicked. Enable the handler and define the event.
		myTrace("enable mdm exit handler");
		mdm.enableexithandler();   
		// v6.4.2.4 Struggling to exit when running MDM. 
		this.onAppExit = function() { 
			// this is the old way to do it, but once controlNS.startExit is defined
			// this definition will be overwritten
			myTrace("initial onAppExit, just exit");
			// v6.4.2.4 Can't do this as nothing loaded yet. So just exit
			//this.gotoAndPlay("exit");
			mdm.exit();
		} 
		
		// v6.5.5.9 Stop trying to use the ocx if possible. It should only be some kind of backup
		/*
		// v6.3.5 Attach the ocx here (if possible)
		// for debug
		//mdm.exceptionhandler_disable(); 
		_global.ORCHID.projector.variables.xPosition = "0";
		_global.ORCHID.projector.variables.yPosition = "0";
		_global.ORCHID.projector.variables.width = "1";
		_global.ORCHID.projector.variables.height = "1";
		_global.ORCHID.projector.variables.ocxID = "0";
		_global.ORCHID.projector.variables.activexObject = "EGUSoundSystem.AudioRecorder"; 
		//myTrace("load activexload command (under Zinc)");
		// Note, you can only do one 'thing' with the ocx in a 'frame/interval' with the mdm/Flash architecture
		_global.ORCHID.projector.variables.doingWhat = "loadOCX";
		//mdm.exceptionhandler_enable();
		mdm.activex_load(_global.ORCHID.projector.variables.ocxID,
						 _global.ORCHID.projector.variables.xPosition,
						 _global.ORCHID.projector.variables.yPosition,
						 _global.ORCHID.projector.variables.width,
						 _global.ORCHID.projector.variables.height,
						 _global.ORCHID.projector.variables.activexObject); 
		// Can't do this straight away as mdm stuff happens at the end of the frame
		// But I think that ANY kind of delay means that stuff at the end of this frame
		// will happen first and then as soon as you can this interval triggers.
		_global.ORCHID.projector.delays.ocxSetting = function() {
			//myTrace("in ocxSetting, intID=" + _global.ORCHID.projector.delays.intID);
			clearInterval(_global.ORCHID.projector.delays.intID);
			// So fail to load ocx will now have happened if it is going to
			if (_global.ORCHID.projector.ocxLoaded) {			
				myTrace("Clarity Recorder through ocx", 1);
				_global.ORCHID.projector.variables.propertyName = "mode";
				_global.ORCHID.projector.variables.propertyType = "integer";
				_global.ORCHID.projector.variables.propertyValue = "1";
				mdm.activex_setproperty(_global.ORCHID.projector.variables.ocxID,
										_global.ORCHID.projector.variables.propertyName,
										_global.ORCHID.projector.variables.propertyType,
										_global.ORCHID.projector.variables.propertyValue); 
				// You don't really need to check the property since the correct
				// loading is handled by the exception handler (and default of success)
				_global.ORCHID.projector.callbacks.getOCXProperty = function(value) {
					myTrace("ocx callback with mode=" + value);
				}
				mdm.activex_getproperty(_global.ORCHID.projector.variables.ocxID,
										_global.ORCHID.projector.variables.propertyName,
										_global.ORCHID.projector.callbacks.getOCXProperty); 
			}
			// During debugging, put this back on so you get full errors from FSP
			// otherwise, always handle exceptions.
			//mdm.exceptionhandler_disable();
		}
		_global.ORCHID.projector.delays.intID = setInterval(_global.ORCHID.projector.delays.ocxSetting,100);
		*/
		
		// v6.3.5 Finally, call setupPaths to keep going
		// v6.3.3 First see if there is a preset location for remote software
		// (this will have been established before you got here - so far only by an
		// explicit parameter passed from APORemote, nothing to do with FSP)
		if (_root.FSPRemoteServer != undefined && _root.FSPRemoteServer != "") {
			if (_root.FSPRemoteServer.lastIndexOf("/") != (_root.FSPRemoteServer.length-1)) {
				//myTrace("add a / to the remote server path");
				_root.FSPRemoteServer += "/";
			}
			myTrace("RemoteServer: override root to be " + _root.FSPRemoteServer,1);
			_global.ORCHID.paths.root = _root.FSPRemoteServer;
		// if not, then always use FSPExePath for safety sake
		} else {
			myTrace("Zinc appdir: reset root from " + _global.ORCHID.paths.root + " to " + _root.mdm_appdir,1);
			_global.ORCHID.paths.root = _root.mdm_appdir;
		}
		// v6.4.2 You might have passed some parameters on the command line
		// (particularly if you are APP asking for a preview)
		// v6.5.5.1 This all needs to be done much earlier - see top now. No, since mdm.getcmdparameters is asynch. 
		// So do it here and wait.
		var cmd_id = "1"; 
		getCmdValue = function(cmd_value) {				
			var cmd_array = new Array();
			myTrace("ZINC command line got " + cmd_value);
			// get rid of a slash if there is one at the beginning
			if (cmd_value.indexOf("/")==0) {
				cmd_value=cmd_value.substr(1);
			}
			if (cmd_value != undefined) {
				cmd_pairs = cmd_value.split("&");
				for (var i in cmd_pairs) {
					var cmd_pair = cmd_pairs[i].split("=");
					myTrace("cmd: " + cmd_pair[0] + "=" + cmd_pair[1]);
					cmd_array.push({parameter:cmd_pair[0], value:cmd_pair[1]});
				}
			} else {
				myTrace("empty command line");
			}
			for (var i in cmd_array) {
				if (cmd_array[i].parameter == "username") {
					_global.ORCHID.commandLine.username = cmd_array[i].value
					myTrace("username=" + _global.ORCHID.commandLine.username);
				} else if (cmd_array[i].parameter == "password") {
					_global.ORCHID.commandLine.password = cmd_array[i].value
				} else if (cmd_array[i].parameter == "action") {
					_global.ORCHID.commandLine.action = cmd_array[i].value
					myTrace("action=" + _global.ORCHID.commandLine.action);
				} else if (cmd_array[i].parameter == "course") {
					_global.ORCHID.commandLine.course = cmd_array[i].value
					myTrace("course=" + _global.ORCHID.commandLine.course);
				} else if (cmd_array[i].parameter == "preview") {
					_global.ORCHID.commandLine.preview = (cmd_array[i].value == "true");
					myTrace("preview=" + _global.ORCHID.commandLine.preview);
				} else if (cmd_array[i].parameter == "startingPoint") {
					_global.ORCHID.commandLine.startingPoint = cmd_array[i].value
					myTrace("startingPoint=" + _global.ORCHID.commandLine.startingPoint);
				} else if (cmd_array[i].parameter == "courseFile") {
					_global.ORCHID.commandLine.courseFile = cmd_array[i].value
					myTrace("courseFile=" + _global.ORCHID.commandLine.courseFile);
				} else if (cmd_array[i].parameter == "language") {
					_global.ORCHID.commandLine.language = cmd_array[i].value
					myTrace("language=" + _global.ORCHID.commandLine.language);
				// v6.4.3 SecuROM
				} else if (cmd_array[i].parameter == "protectionParameter") {
					_global.ORCHID.commandLine.protectionParameter = cmd_array[i].value
					myTrace("protectionParameter=" + _global.ORCHID.commandLine.protectionParameter);
				// v6.5.5.4 Location from parameters
				} else if (cmd_array[i].parameter == "location") {
					_global.ORCHID.commandLine.location = cmd_array[i].value
					myTrace("location=" + _global.ORCHID.commandLine.location);
				// v6.5.5.4 Content from parameters
				} else if (cmd_array[i].parameter == "content") {
					_global.ORCHID.commandLine.content = cmd_array[i].value
					myTrace("content=" + _global.ORCHID.commandLine.content);
				}
			}
			// See if we are in preview mode (from APP)
			// v6.4.2 rootless
			controlNS.runPreviewMode();
			
			// v6.3.4 Now need to redo the paths as _root has changed.
			// v6.5.5.2 move this inside the function from outside so it waits.
			myTrace("call setupPaths from Zinc processing");
			controlNS.setupPaths();
		}
		mdm.cmdparameters(cmd_id,getCmdValue);		
		
	} else {
		// not in FSP, so MUST be in some kind of unexpected browser
		_global.ORCHID.projector.name="browser";
		myTrace("call setupPaths direct, though not passed browser name.");
		controlNS.setupPaths();
	}
}
