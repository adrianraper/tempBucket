import Classes.md5Class;

class Classes.licenceClass {
	var path:String;
	var error:String;
	
	var productType:String;
	var product:String;
	var branding:String;
	var database:String;
	var scripting:String;
	var version:Number;
	var serialNumber:String;
	var accessControl:String;
	var registrationDate:String;
	// v6.4.3 Pass rootID for login
	var centralRoot:Number;
	var expiry:String;
	// v6.5.5.3 To stop early entry
	var startDate:String;
	var licences:Number;
	
	var encryption:String; // v0.15.1
	//var productionServer:String;	// v0.15.1
	var control:Object; // v6.4.3
	
	var md5:md5Class;
	
	var loadVarsText:LoadVars;
	
	function licenceClass() {
		loadVarsText = new LoadVars();
		loadVarsText.master = this;
		
		productType = "Light";
		version = 1;
		serialNumber = "";
		accessControl = "";
		registrationDate = "";
		// v6.4.3 Pass rootID for login
		centralRoot = 1;
		licences=0;
		expiry="";
		
		encryption = "";	// v0.15.1
		control = new Object;	// v6.4.3
		md5 = new md5Class();
		
		error = "";
	}
	
	function loadLicence() : Void {
		loadVarsText.onData = function(raw) {
			if (raw=="" || raw==undefined) {
				// Can you try to read .txt at this point?
				//_global.myTrace("error reading licence " + this.master.path);
				if (this.master.path.indexOf(".ini")>0) {
					_global.myTrace("try .txt version as .ini missing or empty");
					this.master.path = this.master.path.substr(0, this.master.path.indexOf(".ini"))+".txt";
					//_global.myTrace("load licence at path: "+this.master.path);
					this.master.loadLicence();
					delete this;
					return; 
				}
				// error
				this.master.error = "licenceError";
			} else {
				// v6.3.3 Use a function to read each item to make it easier to
				// change the reading method. In this case, we know want to read
				// to # rather than search for charCode(13) which might not exist
				// on Linux.
				var getLicenceItem = function(thisItem) {
					//_global.myTrace("digging for " + thisItem);
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
							//_global.myTrace("start at " + itemStart + " use hashEnd at " + hashEnd);
							var itemEnd = hashEnd;
						} else {
							//_global.myTrace("start at " + itemStart + " use lineEnd at " + lineEnd);
							var itemEnd = lineEnd;
						}
						// v6.4.3 The following returns empty string for items that have a name but no value in the licence
						// but parts of the code only test to see if they are undefined. Copy from Orchid.
						//return raw.substr(itemStart, itemEnd - itemStart);
						var foundItem = raw.substr(itemStart, itemEnd - itemStart);
						if (foundItem == "") {
							return undefined;
						} else {
							return foundItem;
						}
					} else {
						return undefined;
					}
				}
				
				this.master.productType = getLicenceItem("Product type");
				//_global.myTrace("licence.productType="+this.master.productType);
				// Product type (expecting Author Plus Online)
				this.master.product = getLicenceItem("Product");
				// Product branding (expecting Clarity/TenseBuster/LowerInt or CUP/GIU/EGU)
				this.master.branding = getLicenceItem("Branding");
				
				// v6.4.2.5 Licenced to
				this.master.institution = getLicenceItem("Institution name");
				
				var db = getLicenceItem("Database");
				if (db.toUpperCase().indexOf("SQLSERVER")>-1||db.toUpperCase().indexOf("ACCESS")>-1||db.toUpperCase().indexOf("MYSQL")>-1||db.toUpperCase().indexOf("LSO")>-1) {
					this.master.database = db;
				} else {
					this.master.database = _global.NNW._database;
				}
				//_global.myTrace("licence.database="+this.master.database);
				
				var sc = getLicenceItem("Scripting");
				if (sc.toUpperCase().indexOf("ASP")>-1||sc.toUpperCase().indexOf("PHP")>-1||sc.toUpperCase().indexOf("ACTIONSCRIPT")>-1) {
					this.master.scripting = sc;
				} else {
					this.master.scripting = _global.NNW._scripting;
				}
				//_global.myTrace("licence.scripting="+this.master.scripting);
				
				var tempVersion = getLicenceItem("Licence file version");
				if (tempVersion != undefined) {
					this.master.version = Number(tempVersion);
				} else {
					this.master.version = 0;
				}
				//_global.myTrace("licence.version=" + this.master.version);
				
				this.master.serialNumber = getLicenceItem("Serial number");
				//_global.myTrace("licence.serialNumber=" + this.master.serialNumber);
				
				this.master.accessControl = getLicenceItem("Access control");
				//_global.myTrace("licence.accessControl=" + this.master.accessControl);
				
				this.master.registrationDate = getLicenceItem("Registration date");
				//_global.myTrace("licence.registrationDate=" + this.master.registrationDate);
				
				// v0.15.1, DL: use encrpytion on password
				this.master.encryption = getLicenceItem("Encryption");
				//_global.myTrace("licence.encryption="+this.master.encryption);
				
				// v0.15.1, DL: use Production server to check server
				// v6.4.3 Check control aspects of the licence - hmmm, not necessarily want to share all of these with Orchid
				// For instance, students might have to run from a particular IP, but teachers not. For now, just do teacher expiry, number and host server
				this.master.control.server = getLicenceItem("Host server");
				//_global.myTrace("licence.hostServer="+this.master.control.server);

				// v6.3.4 IP range
				this.master.control.IPrange = new Array();
				this.master.control.IPrange = getLicenceItem("IP range").split(".");
				//if (this.master.control.IPrange != undefined) {
				//	myTrace("licence.control.IPrange=" + this.master.control.IPrange); 
				//}
				// v6.4.1.5 referrer URL range
				this.master.control.RURange = new Array();
				this.master.control.RURange = getLicenceItem("Referrer URL").split(".");;
		
				// v6.4.3 Need to read rootID from licence
				var tempRoot = getLicenceItem("Central root");
				if (tempRoot != undefined) {
					this.master.centralRoot = Number(tempRoot);
				} else {
					this.master.centralRoot = 1; // default
				}			
				//_global.myTrace("licence.root=" + this.master.centralRoot);

				// v6.4.3 Need to read the number of authors allowed under this licence
				// Principally, all we care about is > 1 at the moment
				this.master.expiry = getLicenceItem("Teacher expiry");
				var tempLicences= getLicenceItem("Maximum teacher");
				if (tempLicences != undefined) {
					this.master.licences = Number(tempLicences);
				} else {
					this.master.licences = 0; // default
				}			

				// v6.3.5 Print the stuff that was set in the licence
				for (var i in this.master) {
					if ((typeof this.master[i]) == "object") {
						for (var j in this.master[i]) {
							if ((typeof this.master[i][j]) == "string") {
								if (this.master[i][j] != "" && this.master[i][j] != undefined) {
									_global.myTrace("licence." + i + "." + j + "=" + this.master[i][j]);
								}
							}
						}
					} else if ((typeof this.master[i]) == "string") {
						if (this.master[i] != "" && this.master[i] != undefined) {
							_global.myTrace("licence." + i + "=" + this.master[i]);
						}
					}
				}
				// v6.4.3 validate the licence
				var checkSumString = "CheckSum="
				var checkSumLineStart = raw.lastIndexOf(checkSumString);
				//_global.myTrace("checkSumStart=" + checkSumLineStart);
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
					//_global.myTrace("product sent to checksum=" + this.master.product);
					//myTrace("fullText=" + realText);
					var checkSum = this.master.md5.clarityMD5(realText, this.master.product);
					//_global.myTrace("got back" + checkSum);
					// to remove extra new line get from the licence file
					checkSumValue = _global.replace(checkSumValue, chr(10), "");
					checkSumValue = _global.replace(checkSumValue, chr(13), "");
					if (checkSum != checkSumValue) {
						// the licence file is altered, so get control to take some action
						_global.myTrace("licence.checksum=    " + checkSumValue);
						_global.myTrace("calculated.checksum= " + checkSum);
						this.master.valid = false
						//var errObj = {literal:"licenceAltered"};
						this.master.error = "licenceAltered";
					} else {
						//_global.myTrace("good.checksum= " + checkSum);
						// the licence file is valid, so let control know this
						this.master.valid = true
					}
				} else {
					_global.myTrace("no checksum!");
					// the licence file is altered, so get control to take some action
					// (the checksum has been deleted!)
					this.master.valid = false
					//var errObj = {literal:"licenceAltered"};
					this.master.error = "licenceAltered";
				}
				
				// Run checks on the licence.
				// v6.4.3 Is this one still valid??
				//if (this.master.registrationDate==undefined || this.master.registrationDate=="") {
				//	this.master.error = "unregisteredUser";
				//} else {
				//	this.master.error = "";
				//}

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
					_global.myTrace("parsed expiry=" + expiryDate.toString());
				} else if (this.master.expiry.indexOf("/") > 0) {
					var dayParts=this.master.expiry.split("/"); // remember the slash is a special character
					var expiryDate = new Date(dayParts[2], dayParts[1]-1, dayParts[0]);
				} else {
					var expiryDate = undefined;
				}
				//myTrace("built up expiryDate=" + expiryDate.toString());
				if (expiryDate == undefined || expiryDate.getTime() < new Date().getTime()) {
					_global.myTrace("licence has expired");
					// the licence has expired
					this.master.valid = false;
					//var errObj = {literal:"licenceExpired", detail:this.master.expiry.toString()};
					this.master.error = "licenceExpired";
				} else {
					_global.myTrace("licence within expiry date");
				}
				// Number of authors
				if (this.master.licences < 1) {
					_global.myTrace("no authoring licences");
					// the licence has expired
					this.master.valid = false;
					//var errObj = {literal:"licenceExpired", detail:this.master.expiry.toString()};
					this.master.error = "noLicences";
				} else {
					_global.myTrace("got " + this.master.licences + " licences.");
				}

			}
			delete this;
			_global.NNW.control.login.onLicenceLoaded();
		}
		_global.myTrace("load licence at path: "+path);
		loadVarsText.load(path+"?"+random(99999));
	}

}