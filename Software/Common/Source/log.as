// v6.5.5.1 Write out log messages.
// Currently we only have the database to store them in
logNS.sendLog = function (message, code) {
	// make a new db query - if the db can take it
	// v6.5.5.5 If you get an account error, you won't have set databaseversion yet. So scrap this check.
	// Yet it is going to fail with network version. So make sure we don't even call this.
	//if (_global.ORCHID.programSettings.databaseVersion>1) {
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		thisDB.queryString = '<query method="writeLog" ' +
						'userID="' + _global.ORCHID.user.userID + '" ' +
						'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
						'sessionID="' + _global.ORCHID.session.sessionID + '" ' +
						'logCode="' + code + '" ' +
						// v6.4.2 Pass local time to the database
						'datestamp="' + dateFormat(new Date()) + '" ' +
						// pass the database version that you read during getRMSettings
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" >' +
						message +
						'</query>';
	
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		thisDB.xmlReceive.onLoad = function(success) {
			// don't make too many assumptions about the format of the returned
			// XML, so look through all nodes to find anything expected
			// and leave unexpected stuff alone
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
	
				// anything we didn't expect?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// Nothing to do on return
		}
		thisDB.runQuery();
	//}
}
// This might not be the place to do it, but it seems neat
_global.ORCHID.timeHolder.toString = function() {
	
	// These two are indications of the download speed and server connection, no database involved yet
	var progsLoaded = Math.floor(_global.ORCHID.timeHolder.programLoaded - _global.ORCHID.timeHolder.programStart);
	var serverTested = Math.floor(_global.ORCHID.timeHolder.serverConnected - _global.ORCHID.timeHolder.startServerTest);
	
	// This is the first key information - how long from start to when account details are loaded.
	var firstQueryComplete = Math.floor(_global.ORCHID.timeHolder.firstQueryComplete  - _global.ORCHID.timeHolder.programStart);
	
	// Next key information is how long it takes to load user information (startUser, getLicenceSlot, getHiddenContent)
	//var fullyLoadedUser = _global.ORCHID.timeHolder.beginMenuLoad  - _global.ORCHID.timeHolder.beginStartUser;
	var fullyLoadedUser = Math.floor(_global.ORCHID.timeHolder.courseLoaded  - _global.ORCHID.timeHolder.beginStartUser);
	
	// Finally, how long to load the course - which is reading course.xml and getting the scores
	var fullyLoadedScores = Math.floor(_global.ORCHID.timeHolder.unitMenuLoaded - _global.ORCHID.timeHolder.beginCourseLoad); 
	
	// If you want to time a specific query, do that here. This is as pure to database speed as we can get.
	var queryStartUser = Math.floor(_global.ORCHID.timeHolder.query.stop_startUser  - _global.ORCHID.timeHolder.query.start_startUser);
	var queryGetLicenceSlot = Math.floor(_global.ORCHID.timeHolder.query.stop_getLicenceSlot  - _global.ORCHID.timeHolder.query.start_getLicenceSlot);
	var queryGetScores = Math.floor(_global.ORCHID.timeHolder.query.stop_getScores  - _global.ORCHID.timeHolder.query.start_getScores);
	
	return "loadProgs=" + progsLoaded + "&serverTested=" + serverTested + 
									"&firstQueryComplete=" + firstQueryComplete + 
									"&fullyLoadedUser=" + fullyLoadedUser + 
									"&fullyLoadedScores=" + fullyLoadedScores + 
									"&queryStartUser=" + queryStartUser + 
									"&queryGetLicenceSlot=" + queryGetLicenceSlot + 
									"&queryGetScores=" + queryGetScores; 
}
logNS.movieLoaded = true;

//_global.ORCHID.timeHolder.beginReadCourse 
//_global.ORCHID.timeHolder.courseLoaded 
