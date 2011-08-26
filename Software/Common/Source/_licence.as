
//Internal methods
licenceNS.getConfirmLicence = function() {
	//trace("getting the licence");
	// 6.0.5.0 this function hugely changed
	var loadVarsText = new LoadVars();
	//myTrace("load licence file: " + _global.ORCHID.paths.root + "licence.ini");
	// 6.0.5.0 need the licence namespace as an object to attach to 
	//this.traceName = "licenceNS";
	loadVarsText.master = this;
	// 6.0.5.0 read in the licence file as a text file
	// this is the callback once the text has been read
	loadVarsText.onData = function(raw) {
		// v6.3.3 Some servers block reading .ini files. We could switch to
		// using .txt for the licence, but this could cause loads of confusion
		// so can you catch if the licence.ini has not been read and try licence.txt?
		// v6.5 Switching to *.txt first then *.ini
		//myTrace("raw=" + raw);
		if (raw == "" || raw == undefined) {
			//if (_global.ORCHID.paths.licence.indexOf(".ini") > 0) {
			if (_global.ORCHID.paths.licence.indexOf(".txt") > 0) {
				//myTrace("try .txt version as .ini missing or empty");
				myTrace("try .ini version as .txt missing or empty");
				var thisPath = _global.ORCHID.paths.licence;
				//_global.ORCHID.paths.licence = thisPath.substr(0,thisPath.indexOf(".ini")) + ".txt";
				_global.ORCHID.paths.licence = thisPath.substr(0,thisPath.indexOf(".txt")) + ".ini";
				_global.ORCHID.root.licenceHolder.licenceNS.getConfirmLicence();
			} else {
				// Only try once, then report the missing file. No point giving the name
				// as this will have been changed to licence.txt which will be misleading.
				var errObj = {literal:"licenceMissing"};
				_global.ORCHID.root.controlNS.setConfirmLicence(this.master.institution, errObj);
			}
			delete this;
			return;
		}
		// v6.3.3 Use a function to read each item to make it easier to
		// change the reading method. In this case, we know want to read
		// to # rather than search for charCode(13) which might not exist
		// on Linux.
		var getLicenceItem = function(thisItem) {
			//myTrace("digging for " + thisItem);
			// v6.4.2.4 Bug - this code will find product instead of product code=
			// so force the search to include the = sign
			//var itemStart = raw.indexOf(thisItem);
			var itemStart = raw.indexOf(thisItem+"=");
			if (itemStart > 0) {
				itemStart+=thisItem.length+1;
				var hashEnd = raw.indexOf("#", itemStart);
				// Just in case the old style licence is in use on Windows
				if (hashEnd < 0) hashEnd=raw.length;
				var lineEnd = raw.indexOf(String.fromCharCode(13), itemStart);
				if (lineEnd < 0) lineEnd=raw.length;
				if (hashEnd<lineEnd) {
					//myTrace("start at " + itemStart + " use hashEnd at " + hashEnd);
					var itemEnd = hashEnd;
				} else {
					//myTrace("start at " + itemStart + " use lineEnd at " + lineEnd);
					var itemEnd = lineEnd;
				}
				//myTrace("found=" + raw.substr(itemStart, itemEnd - itemStart).trim("both"));
				var foundItem = raw.substr(itemStart, itemEnd - itemStart).trim("both");
				if (foundItem == "") {
					return undefined;
				} else {
					return foundItem;
				}
			} else {
				return undefined;
			}
		}
		//myTrace("licence file content: " + raw);
		// Database=Access #Access#SQLServer#MySQL#

		// for debugging as cache controls seems weird
		//myTrace("licence v6.4.2.4");
		// v6.3.5 Methods now version dependent
		this.master.version = Number(getLicenceItem("Licence file version"));
		myTrace("licence.version=" + this.master.version);
		
		this.master.db = getLicenceItem("Database");
		//myTrace("licence.db=" + this.master.db);
		// Scripting=ASP #ASP#PHP#
		this.master.scripting = getLicenceItem("Scripting");
		//myTrace("licence.scripting=" + this.master.scripting);

		// v6.4.2.7 Add 'action' to the licence
		this.master.action = getLicenceItem("Action");
		//myTrace("licence.action=" + this.master.action);
		// v6.5.4.6 And also allowed actions
		this.master.allowedActions = getLicenceItem("Allowed actions");

		// pull out other parts of the licence file for later use
		this.master.institution = getLicenceItem("Institution name");
		// Student licences
		this.master.licences = getLicenceItem("Maximum student");
		//myTrace("licence.students=" + this.master.licences);
		this.master.expiry = getLicenceItem("Student expiry");
		//myTrace("licence.expiry=" + this.master.expiry.toString());

		// v6.3 Licence type
		this.master.licencing = getLicenceItem("Licencing");
		// set a default in case it is an old licence
		if (this.master.licencing == undefined)	this.master.licencing = "Concurrent";
		//myTrace("licence.licencing=" + this.master.licencing);

		// v6.3.1 Keys used for Central hosting
		this.master.central = new Object();
		this.master.central.key = getLicenceItem("Central key");
		this.master.central.root = getLicenceItem("Central root");
		
		// Product name (expecting Tense Buster or Reactions!)
		this.master.product = getLicenceItem("Product");
		// Product branding (expecting Clarity/TenseBuster/LowerInt or CUP/GIU/EGU)
		this.master.branding = getLicenceItem("Branding");
		// Product type (expecting CD or DEMO or REVIEW or LIGHT)
		this.master.productType = getLicenceItem("Product type");
		
		// v6.4.2.4 Product code (expecting 1001 etc) - used for licence concurrent checking
		// Usually this will not be included in the licence file but will be inferred from the product name
		this.master.productCode = getLicenceItem("Product code");
		if (this.master.productCode==undefined){
			// v6.5.4.4 CE.com has licences with product names such as 'STUDY SKILLS Success ONLINE'. So make the match case insensitive
			//switch (this.master.product) {
			switch (this.master.product.toLowerCase()) {
			case "tense buster":
				//this.master.productCode = 1001;
				this.master.productCode = 9;
				break;
			case "study skills success":
			case "study skills success online":
				//this.master.productCode = 1002;
				this.master.productCode = 3;
				break;
			case "reactions!":
				//this.master.productCode = 1003;
				this.master.productCode = 11;
				break;
			case "business writing":
				//this.master.productCode = 1004;
				this.master.productCode = 10;
				break;
			case "author plus":
				//this.master.productCode = 2002;
				this.master.productCode = 1;
				break;
			// v6.5.4.2 new title
			case "active reading": 
				this.master.productCode = 33;
				break;
			// v6.5.5.2 new titles
			case "clarity english success": 
				this.master.productCode = 37;
				break;
			case "its your job": 
				this.master.productCode = 38;
				break;
			case "clear pronunciation": 
				this.master.productCode = 39;
				break;
				
			// Titles from distributors as partners
			// NAS titles
			case "my canada":
				//this.master.productCode = 2030;
				this.master.productCode = 20;
				break;
			case "l'amour des temps":
				//this.master.productCode = 2040;
				this.master.productCode = 17;
				break;
			// Taiwan (Kima) titles
			case "gept":
				//this.master.productCode = 2100;
				this.master.productCode = 15;
				break;
			case "holistic english":
				//this.master.productCode = 2110;
				this.master.productCode = 16;
				break;
			// Sky - Don Friend
			case "hotel english":
				this.master.productCode = 40;
				break;
				
			// Titles from schools as partners
			// British Council titles
			case "road to ielts":
				if (this.master.branding.toLowerCase().indexOf("general")>=0) {
					//this.master.productCode = 3002;
					this.master.productCode = 13;
				} else {
					//this.master.productCode = 3001;
					this.master.productCode = 12;
				}
				break;
			case "peacekeeper":
				this.master.productCode = 34;
				break;
			case "ila test":
				this.master.productCode = 36;
				break;
				
			// Titles from publishers as partners
			// Summertown titles
			case "bulats":
				//this.master.productCode = 4001;
				this.master.productCode = 14;
				break;
				
			// FuturePerfect titles
			case "call center communication skills":
			case "cccs":
				this.master.productCode = 35;
				break;
				
			// anything else? 
			// Run it under the Author Plus product code for licence purposes
			// v6.5.5.5 No - this will conflict with the database. Assume that this is a specialised product with no row in DMS
			default:
				//this.master.productCode = 2002;
				this.master.productCode = 0;
			}
		}
		//myTrace("licence.product=" + this.master.product);
		
		// Serial number
		this.master.serialNumber = getLicenceItem("Serial number");
		
		// default username
		this.master.defaultUserName = getLicenceItem("Default username");
		// default password
		this.master.defaultPassword = getLicenceItem("Default password");
		// v6.3.6 The old viewreaction code only accepted default user IF default password
		// was not empty, even if you won't use it due to validatedLogin. For temporary
		// fixing, if you read defaultUserName and have undefined password, set it to blank.
		if (this.master.defaultUserName != undefined) {
			if (this.master.defaultPassword == undefined) {
				myTrace("override empty default password");
				this.master.defaultPassword = " ";
			}
		}
		// default courseid
		this.master.defaultCourseID = getLicenceItem("Default courseid");
		
		// v6.5 Allow courseID(s) to be set in the licence
		this.master.validCourses = getLicenceItem("CourseID").split(",");

		// installation date
		this.master.installationDate = getLicenceItem("Installation date");
		//myTrace("licence.installation=" + this.master.installationDate);
		// registration date
		// For APL this is doubles as the activation date
		// v6.3.6 To avoid the problem of clicking on the student link before
		// activation and getting the not registered for too long message, but
		// before you solve that properly in control, simply set the registration
		// date to the installation date if it is APL.
		this.master.registrationDate = getLicenceItem("Registration date");
		//myTrace("check: registrationDate=[" + this.master.registrationDate +"]");
		if (this.master.registrationDate == undefined) {
			myTrace("* program not registered *");
			// v6.4.2.8 Better to base on licence type than branding
			//if (this.master.branding == "Clarity/APL") {
			if (this.master.productType.toLowerCase().indexOf("light")>=0) {
				myTrace("* APL not activated, override date *");
				this.master.registrationDate = this.master.installationDate;
			}
		}
		//myTrace("licence.registration=" + this.master.registrationDate);
		
		// v6.3 server information
		this.master.registrationServer = getLicenceItem("Registration server");
		this.master.verificationServer = getLicenceItem("Verification server");
		//this.master.remoteServer = getLicenceItem("Remote server");
		//if (this.master.registrationServer != undefined) {
		//	myTrace("licence.regServer=" + this.master.registrationServer); 
		//}
		//myTrace("licence.remoteServer=" + this.master.remoteServer);
		
		// v6.3.3 machine information
		this.master.control = new Object();
		this.master.control.hdSerial = getLicenceItem("Computer");

		// v6.3.4 IP range
		this.master.control.IPrange = new Array();
		this.master.control.IPrange = licenceNS.parseIP(getLicenceItem("IP range"));
		//if (this.master.control.IPrange != undefined) {
		//	myTrace("licence.control.IPrange=" + this.master.control.IPrange); 
		//}
		// v6.4.1.5 referrer URL range
		this.master.control.RURange = new Array();
		this.master.control.RURange = licenceNS.parseIP(getLicenceItem("Referrer URL"));

		// v6.3.4 host server for downloads
		this.master.control.server = getLicenceItem("Host server");
		
		// v6.5.4.1 If the licence file has to be held on a particular server
		this.master.control.licenceServer = new Object();
		this.master.control.licenceServer.name = getLicenceItem("Licence server name");
		this.master.control.licenceServer.IP = getLicenceItem("Licence server IP");
		
		// v6.3.5 Access information
		this.master.control.access = getLicenceItem("Access control");
		this.master.control.encryption = getLicenceItem("Encryption");

		// v6.3.4 customisation options
		// 0=Intro, 1=Credits, 2=Menu
		this.master.customisation = getLicenceItem("Customisation").split(",");
		//myTrace("licence.customisation=" + this.master.customisation); 

		// v6.3 exit information
		this.master.exitPage = getLicenceItem("Exit page");

		// v6.4.4 For protection type
		this.master.protection = getLicenceItem("Protection");
		
		// v6.3.5 Print the stuff that was set in the licence
		for (var i in this.master) {
			if ((typeof this.master[i]) == "object") {
				for (var j in this.master[i]) {
					// v6.4.3 IP and RU will be arrays, so see if you can print the toString version
					if ((typeof this.master[i][j].toString()) == "string") {
						if (this.master[i][j] != "" && this.master[i][j] != undefined) {
							myTrace("licence." + i + "." + j + "=" + this.master[i][j].toString());
						}
					}
				}
			} else if ((typeof this.master[i]) == "string") {
				if (this.master[i] != "" && this.master[i] != undefined) {
					myTrace("licence." + i + "=" + this.master[i]);
				}
			}
		}
		// look for the checksum line (when will it change? not in v3.0)
		//if (this.master.version > 3) {
		//	var checkSumString = "##CheckSum="
		//} else {
			var checkSumString = "CheckSum="
		//}
		var checkSumLineStart = raw.lastIndexOf(checkSumString);
		if (checkSumLineStart > 0) {
			// read the value part
			var checkSumValue = raw.substr(checkSumLineStart+checkSumString.length);
			// read the rest of the file
			// the text used to calculate the checksum should include everything before "checksum="
			var realText = raw.substr(0, checkSumLineStart);
			// and pass it to the MD5 algorithm to calculate the checksum
			// v6.3.3 TEMP, since the product name now has a # after it, gencsum uses this
			// but we have stripped it out. This is ONLY for licences checksummed by GenCSum older.
			//var checkSum = clarityMD5(realText, this.master.product+"#");
			//myTrace("product sent to checksum=" + this.master.product);
			//myTrace("fullText=" + realText);
			var checkSum = clarityMD5(realText, this.master.product);
			// to remove extra new line get from the licence file
			checkSumValue = _global.ORCHID.root.objectHolder.findReplace(checkSumValue, chr(10), "");
			checkSumValue = _global.ORCHID.root.objectHolder.findReplace(checkSumValue, chr(13), "");
			if (checkSum != checkSumValue) {
				// the licence file is altered, so get control to take some action
				myTrace("licence.checksum=    " + checkSumValue,2);
				myTrace("calculated.checksum= " + checkSum,2);
				this.master.valid = false
				var errObj = {literal:"licenceAltered"};
			} else {
				//myTrace("good.checksum=    " + checkSum);
				// the licence file is valid, so let control know this
				this.master.valid = true
			}
		} else {
			// the licence file is altered, so get control to take some action
			// (the checksum has been deleted!)
			this.master.valid = false
			var errObj = {literal:"licenceAltered"};
		}
		//myTrace("licenced to " + this.master.institution);
		
		// expiry date processing - might look like 31/12/2004 or might be 2004-12-31 10:19:12
		//myTrace("licence expiry=" + this.master.expiry);
		if (this.master.expiry.indexOf("-") > 0) {
			var dateSections=this.master.expiry.split(" ");
			var dayParts=dateSections[0].split("-");
			// If there is no time mentioned, then you should give them until midnight
			if (dateSections[1] == undefined) {
				dateSections[1] = "23:59:59";
			}
			var timeParts=dateSections[1].split(":");
			var expiryDate = new Date(dayParts[0], dayParts[1]-1, dayParts[2], timeParts[0], timeParts[1], timeParts[2]);
			myTrace("parsed expiry=" + expiryDate.toString());
		} else {
			var dayParts=this.master.expiry.split("/"); // remember the slash is a special character
			var expiryDate = new Date(dayParts[2], dayParts[1]-1, dayParts[0]);
		}
		//myTrace("built up expiryDate=" + expiryDate.toString());
		if (expiryDate.getTime() < new Date().getTime()) {
			myTrace("licence has expired")
			// the licence has expired
			this.master.valid = false
			var errObj = {literal:"licenceExpired", detail:this.master.expiry.toString()};
		} else {
			//myTrace("licence within expiry date");
		}
		
		// v6.5.4.1 If you are using a licence server that matches name to IP, then (for a network) get the IP address now so that MDM doesn't hold you back
		myTrace("licence: check ip address against " + this.master.control.licenceServer.IP + " as mdm=" + _global.ORCHID.projector.name);
		if (this.master.control.licenceServer.IP != undefined && _global.ORCHID.projector.name == "MDM") {
			_global.ORCHID.projector.callbacks.getServerIPAddress = function(value) {
				_global.ORCHID.projector.serverIPAddress = value;
				myTrace("mdm.serverIP=" + _global.ORCHID.projector.serverIPAddress);
				// Do this since asynch means we won't know when doing other licence checks in control3.
				if (_global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.IP!=_global.ORCHID.projector.serverIPAddress) {
					myTrace("licence required IP=" + _global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.IP + " actual IP=" + _global.ORCHID.projector.serverIPAddress,2);
					errObj = {literal:"wrongServer", detail:_global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.IP};
					_global.ORCHID.root.controlNS.sendError(errObj);
				} else {
					myTrace("licence server IP matched on " + _global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.IP);
				}
			}
			var justHostname = this.master.control.licenceServer.name.split("\\")[0];
			myTrace("get the mdm ip address for " + justHostname);
			mdm.net_getipbyhost(justHostname,_global.ORCHID.projector.callbacks.getServerIPAddress); 
		}
		
		// if all is still OK, let control know
		if (this.master.valid) {
			var errObj = undefined
			// v6.5.5.1 We now want to do getRMSettings before we do licence checks
			myTrace("valid licence, go to db.connect");
			_global.ORCHID.root.mainHolder.dbInterfaceNS.connect();
		} else {
			// If we did read a licence and found a mistake, no point going on
			myTrace("invalid licence, go to confirm");
			_global.ORCHID.root.controlNS.setConfirmLicence(this.master.institution, errObj);
		}
		//trace("in licence, setting institution to " + this.master.institution)
		// v6.5.5.1 We now want to do getRMSettings before we do licence checks
		//_global.ORCHID.root.controlNS.setConfirmLicence(this.master.institution, errObj);
		delete this;
	}
	// load the file
	if(_global.ORCHID.online){
	   var cacheVersion = "?version=" + new Date().getTime();
	}else{
	   var cacheVersion = ""
	}
	/*loadASPText = new LoadVars();
	loadASPText.onData = function(raw) {
		myTrace("start calculate asp checkSum at " + getTimer());
		myTrace("ASP content is " + raw);
		var checkSum = clarityMD5(raw, "APO");
		myTrace("ASP checkSum = " + checkSum);
		myTrace("end calculate asp checkSum at " + getTimer());
	}*/
	// v6.3.1 Allow licence file to be passed to control for multi-school version
	// v6.5.4.5 If you pass prefix or root on the command line I will only read a licence if you explicity pass that too
	// otherwise I am going to assume that all the licence information will come from the database
	if ((_global.ORCHID.commandLine.prefix==undefined && _global.ORCHID.commandLine.rootID==undefined) || _global.ORCHID.commandLine.licence!=undefined) {
		//loadVarsText.load(_global.ORCHID.paths.root + "licence.ini" + cacheVersion);
		myTrace("read licence file " + _global.ORCHID.paths.licence);
		// v6.3.5 The paths.licence will already be a full path (or happy to run from here)
		//loadVarsText.load(_global.ORCHID.paths.root + _global.ORCHID.paths.licence + cacheVersion);
		loadVarsText.load(_global.ORCHID.paths.licence + cacheVersion);
	} else {
		myTrace("don't read the licence file, go to dbInt.connect");
		// Load program settings instead
		// But there are some licence settings that would be useful to default, or use if passed from parameters
		_global.ORCHID.root.licenceHolder.licenceNS.central = new Object();
		_global.ORCHID.root.licenceHolder.licenceNS.productType = "full";
		_global.ORCHID.root.licenceHolder.licenceNS.productCode = _global.ORCHID.commandLine.productCode;
		_global.ORCHID.root.licenceHolder.licenceNS.central.root = _global.ORCHID.commandLine.rootID;
		// Set branding based on productCode if you know it - you could overwrite later if the db holds this
		_global.ORCHID.root.licenceHolder.licenceNS.branding = this.setProductBranding(_global.ORCHID.root.licenceHolder.licenceNS.productCode);
		myTrace("licence.branding=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
		
		//_global.ORCHID.root.licenceHolder.licenceNS.registerDate
		_global.ORCHID.root.mainHolder.dbInterfaceNS.connect();
	}
}
licenceNS.setProductBranding = function(productCode) {
	myTrace("set branding for code " + productCode);
	//if (productCode==undefined) productCode=1;
	switch (Number(productCode)) {
	case 2:
		branding = "Clarity/RM";
		break;
	case 3:
		branding = "Clarity/SSS";
		break;
	case 9:
		branding = "Clarity/TB";
		break;
	case 10:
		branding = "Clarity/BW";
		break;
	case 12:
		branding = "BC/IELTS/Academic";
		break;
	case 13:
		branding = "BC/IELTS/General";
		break;
	case 33:
		branding = "Clarity/AR";
		break;
	case 11:
		branding = "Clarity/RO";
		break;
	case 34:
		branding = "BC/PEP";
		break;
	case 36:
		branding = "BC/ILA";
		break;
	case 35:
		branding = "FuturePerfect/CCCS";
		break;
	case 37:
		branding = "Clarity/CES";
		break;
	case 38:
		branding = "Clarity/IYJ";
		break;
	case 39:
		branding = "Clarity/PRO";
		break;
	case 41:
		branding = "Clarity/Test";
		break;
		
	case 20:
		branding = "NAS/MyC";
		break;
	case 17:
		branding = "NAS/LdT";
		break;
	case 15:
		branding = "WinHoe/GEPT";
		break;
	case 16:
		branding = "WinHoe/HolisticEnglish";
		break;
	case 14:
		branding = "Summertown/BULATS";
		break;
	case 40:
		branding = "Sky/Hotel";
		break;
	default:
		branding = "Clarity/AP";
		break;
	}
	return branding;
}

licenceNS.parseIP = function(addrRange) {
	return addrRange.split(",");
}
licenceNS.inIPRange = function(thisIP, targetRange) {
	// change targetRange to be an array of addresses
	for (var t in targetRange) {
		//myTrace("check " + thisIP + " against " + targetRange[t]);
		// first, is there an exact match?
		if (thisIP == targetRange[t]) {
			//myTrace("direct match");
			return true;
		}
		// or is it a simple comma delimitted list with an exact match
		// v6.4.2 This seems pretty silly since we have already split the string on commas!
		var targetList = targetRange[t].split(",");
		for (var i in targetList) {
			if (targetList[i] == thisIP) {
				//myTrace("list match against " + i);
				return true;
			}
		}
		// or does it fall in the range? 
		// assume nnn.nnn.nnn.x-y
		var targetBlocks = targetRange[t].split(".");
		var thisBlocks = thisIP.split(".");
		// how far down do they specify?
		for (var i=0; i<thisBlocks.length; i++) {
			//myTrace("match " + thisBlocks[i] + " against " + targetBlocks[i]);
			if (targetBlocks[i] == thisBlocks[i]) {
			} else if (targetBlocks[i].indexOf("-")>0) {
				var target = targetBlocks[i].split("-");
				var targetStart = Number(target[0]);
				var targetEnd = Number(target[1]);
				var thisDetail = Number(thisBlocks[i]);
				if (targetStart <= thisDetail && thisDetail <= targetEnd) {
					//myTrace("range match " + thisDetail + " between " + targetStart + " and " + targetEnd);
					return true;
				}
			} else {
				//myTrace("no match between " + targetBlocks[i] + " and " + thisBlocks[i]);
				break;
			}
		}
	}
	return false;
}
// v6.4.1.5 referrer URL matching
licenceNS.inRURange = function(thisRU, targetRange) {
	// change targetRange to be an array of addresses
	// v6.4.3 If this RU is empty, then you should not try to match. You won't be here unless you have something specific to match against.
	if (thisRU == "" || thisRU == undefined) return false;
	
	for (var t in targetRange) {
		myTrace("check referrer " + thisRU + " against " + targetRange[t]);
		// first, is there an exact match? Better not be case sensitive.
		if (thisRU.toLowerCase() == targetRange[t].toLowerCase()) {
			myTrace("exact referrer match");
			return true;
		}
		// v6.4.2 Next see if the root of the domain is the same
		// expecting actual to be something like http://server/Orchid/linkThru.html
		// and maybe all we care about is the //server/ part
		// v6.4.3 TPL is giving an actual referrer of http://agent05.tpl.toronto.on.ca/agent/refdbs/referrer.asp?url=http://202.148.158.86/canada/sector3/TenseBuster/TPL_Start.asp? target=_blank titlebar=no
		// to match against http://agent05.tpl.toronto.on.ca/agent/refdbs/referrer.asp
		// So this won't work with the following code split. But why do that anyway, surely just match all of the target against the beginning of
		// the actual. If they match you are because your target will be as general/specific as you want.
		/*
		var targetDomain = targetRange[t].split("/");
		var thisDomain = thisRU.split("/");
		// so if we only care about part of the URL, check each / delimitted part
		var allMatch=false;
		for (var i=0; i<targetDomain.length; i++) {
			//myTrace("match " + targetDomain[i] + " against " + thisDomain[i]);
			if (targetDomain[i].toLowerCase() == thisDomain[i].toLowerCase()) {
				allMatch=true;
			} else {
				//myTrace("found mismatch");
				allMatch=false;
				break;
			}
		}
		if (allMatch) {
			//myTrace("made a match");
			return true;
		}
		*/
		if (thisRU.toLowerCase().indexOf(targetRange[t].toLowerCase())>=0) {
			myTrace("partial referrer match");
			return true;
		}
	}
	return false;
}
