// query code for shared object use
/*
init = function() {
	//var db = _root.databaseHolder.databaseNS.thisDB;
	var db = _global.ORCHID.dbInterface;
	myTrace("need to init the dbSharedObject data");				
	db.dbSharedObject.data.firstRun = new Date().toString();
	db.dbSharedObject.data.user = new Array();
	db.dbSharedObject.data.user.push({userID:"0", name:"_orchid", password:""});
	db.dbSharedObject.data.session = new Array();
}
*/
// this is a master function that will take the query as XML, parcel it out for
// processing and then create the XML result
// typical input would be: <query method="getRMSettings" cacheVersion="1063258669375" />
sendQuery = function(queryXML, resultXML) {
	//myTrace("in sendQuery with " + queryXML.toString());
	for (var node in queryXML.childNodes) {
		var tN = queryXML.childNodes[node];
		//myTrace("node=" + tN.toString());
		// read the query node
		var thisQuery = new Object();
		thisQuery.buildString = "";
		if (tN.nodeName == "query") {
			//myTrace("run query=" + tN.toString());
			for (var attrib in tN.attributes) {
				thisQuery[attrib] = tN.attributes[attrib];
			}
			// there just might be something sent not as an attribute as well!
			if (tN.firstChild.nodeValue != "") {
				//myTrace("sentData=" +tN.firstChild.nodeValue); 
				thisQuery.sentData = tN.firstChild.nodeValue;
			}
			switch (thisQuery.method.toUpperCase()) {
			case "GETRMSETTINGS":
				getRMSettings(thisQuery);
				break;
			case "STARTSESSION":
				insertSession(thisQuery);
				break;
			// since there is no licence control, the following calls are the same
			case "STOPSESSION":
			case "STOPUSER":
				//myTrace("lso stop user/session");
				updateSession(thisQuery);
				//var returnCode = _global.ORCHID.dbInterface.dbSharedObject.flush();
				//myTrace("flush gives " + returnCode);
				break;
			case "STARTUSER":
				// this is called by Orchid when someone tries to log on,
				// first you must check if there is a licence slot, then see if the
				// username and password are OK. If anything goes wrong, send
				// back an error object
				// see if you can find this user's details
				var returnCode = getUser(thisQuery);
				// 6.0.6.0 insert session after choosing a course
				//if (returnCode) {
					// add a session for this validated user
				//	returnCode = insertSession(thisQuery);
				//}
				break;
			case "ADDNEWUSER":
				// When they click the 'new user' button to log on
				//If anything goes wrong, send back an error object
				//returnCode = getLicenceSlot(myQuery)
				var returnCode = addUser(thisQuery)
				// 6.0.6.0 insert session after choosing a course
				//if (returnCode) {
				//	// add a session for this validated user
				//	returnCode = insertSession(thisQuery)
				//}	
				break;
			case "WRITESCORE":
				var returnCode = insertScore(thisQuery);
				//myTrace("writeScore returnCode=" + returnCode);
				if (returnCode) {
					updateSession(thisQuery);
				}
				break;
			case "GETSCORES":
				getScores(thisQuery);
				break;
			case "GETSCRATCHPAD":
				getScratchPad(thisQuery);
				break;
			case "SETSCRATCHPAD":
				setScratchPad(thisQuery);
				break;
			// v6.4.2.4 New and null functions
			case "COUNTUSERS":
				countUsers(thisQuery);
				break;
			case "GETGENERALSTATS":
				// v6.4.2.8 For the certificate
				getGeneralStats(thisQuery);
				break;
			// v6.5.6 For calls that are just not relevant to lso, but that you need to return something
			case "GETLICENCESLOT":
				thisQuery.buildString += "<licence ID='0' />";
				break;
			default:
				myTrace("called LSO query with non-method: " + thisQuery.method);
			}
			// now send back the result as XML
			//myTrace("return: " + "<db>" + thisQuery.buildString + "</db>");
			resultXML.parseXML("<db>" + thisQuery.buildString + "</db>");
			resultXML.loaded = true;
			resultXML.onLoad(true);
		}
	}
}
// ************
// v6.4.2.4 I can't think of any circumstance in which we want to use LSO with many named users.
// (unless APL does something complex for split queries?)
// The licence implies that it is single user, run from CD, no database. So surely all we want to do is to
// either record data assuming just one person, or don't record data at all.
// So, if you have action=anonymous, we will not record data (send back userID=-1)
// if Licencing=Single we will send back userID=0, no login.
// (else) if Licencing=Total then keep it as it is with a login (name).

// ***********
// LSO does not work with Results Manager, so only option is to allow freedom
getRMSettings = function(query) {
	//var buildString = "<" & "?xml version=""1.0"" encoding=""UTF-8""?>";
	// v6.3 Change default to include a password (and anonymous login)
	// v6.4.2.4 Change default to be name, no password, anonymous, new uesr
	if (_global.ORCHID.commandLine.action == "anonymous") {
		//myTrace("anonymous use, so no login");
		query.buildString += "<settings loginOption='0' verified='0' selfRegister='0' />";
	// v6.5.5.5 Change name
	//} else if (_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("single") >= 0) {
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.licenceType==4) {
		query.buildString += "<settings loginOption='0' verified='0' selfRegister='0' />";
		//if (_global.ORCHID.root.licenceHolder.licenceNS.defaultUserName != undefined) {
		//	_global.ORCHID.root.licenceHolder.licenceNS.defaultUserName = "_orchid";
		//	_global.ORCHID.root.licenceHolder.licenceNS.defaultPassword = "";
		//}
		myTrace("single use, so no login");
	} else {
		//myTrace("old lso settings");
		query.buildString += "<settings loginOption='9' verified='0' selfRegister='1' />";
	}
	//myTrace("bS: " + thisQuery.buildString);
}
// LSO does not allow any licence control
getUser = function(query) {
	// read the user record from the db
	var me = _global.ORCHID.dbInterface.dbSharedObject.data.user;
	
	// is this an anonymous user (no problem as RMsettings will have allowed it)
	//v6.3.6 A very rough workround for lso with defaultUserName=_orchid and validatedLogin
	// simply because between versions and licence now doesn't register an empty node
	// Remember that the NS of dbInterface has changed from databaseHolder to mainHolder!
	//myTrace("getUser in lso");		
	if (query.name == "") { // && query.studentID == "") {
	//if (query.name == "" || query.name == "_orchid") { // && query.studentID == "") {
		if (_global.ORCHID.commandLine.action == "anonymous") {
			myTrace("anonymous use, so no progress");
			query.buildString += "<user name='' userID='-1' />";
			return true;
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("single") >= 0) {
			// v6.4.2.4 If you are running lso it probably means direct from CD, or single user.
			// So it would be nice to save the user's progress even if they are anonymous
			// This means you have to create a userID. Lets make it 1
			//query.buildString += "<user name='' userID='-1' />";
			//return true;
			// v6.5.4.3 Whilst we don't want a login, we do want to save progress, which means we need to know 
			// that we have a user set up so we can attach sessions to them.
			// Give a nicer name (for certificate and progress)
			query.name="_orchid";
			//query.name=_global.ORCHID.literalModelObj.getLiteral("anonymousName", "labels");
			var checkOnUser = addUser(query);
			
			myTrace("single user in lso, needed to add=" + checkOnUser + ": " + query.buildString);
			// v6.5.4.3 The above will have set stuff in buildString that we don't want, so refresh it
			//query.buildString += "<user name='_orchid' userID='0' />";
			// v6.5.4.3 If we set userID=0, then we don't get a certificate. So try 1 - does that ruin anything else? What about the name?
			//query.buildString = "<user name='_orchid' userID='0' />";
			// Give a nicer name (for certificate and progress)
			//query.buildString = "<user name='_orchid' userID='1' />";
			query.buildString = "<user name='" + query.name + "' userID='1' />";
			return true;
			// You need to be sure that you have a lso space for this user - only needs to happen once
			// do it below. No - this is done in dbInterface already
		}
	}
	if (me == null || me == undefined) {
		// trigger the callback with null to show the call failed
		//this.onReturnCode(null); 
		// wrong code!
		query.buildString += "<err code='203'>no users at all!</err>";
		return false;
	} else {
		for (var i in me) {
			//myTrace("checking " + me[i].name);
			if (me[i].name == query.name) {
				//myTrace("found " + query.name + " id=" + me[i].userID + " password=" + me[i].password);
				if (me[i].userID != i) {
					me[i].userID = i;
					query.buildString += "<note>user ID doesn't match index</note>";
				}
				// check the password
				if (me[i].password != query.password) {
					query.buildString += "<err code='204'>password does not match</err>";
					return false;
				} else {
				//	this.onReturnCode(me[i]);
					query.buildString += "<user name='" + me[i].name + "' " + 
										"userID='" + me[i].userID + "' " +
										"userSettings='" + me[i].userSettings + "' " +
										"country='" + me[i].country + "' " +
										"email='" + me[i].email + "' " +
										// v6.3.6 Add userType (always 0)
										"userType='0' " +
										// v6.3.4 remove
										//"className='" + me[i].class + "' " + 
										"studentID='" + me[i].studentID + "' />";					
					return true;
				}
			}
		}
		// trigger the callback with a null userID to show the user was not found
		query.buildString += "<err code='203'>no such user</err>";
		//this.onReturnCode({userID:null}); 
		return false;
	}	
}
addUser = function(query) {
	//first, check to see if this user name already exists
	// Note: at some point this needs to be linked to studentID - or whichever field
	// results manager specifies as being unique
	// read the user record from the db
	var me = _global.ORCHID.dbInterface.dbSharedObject.data.user;
	if (me == null || me == undefined) {
		// trigger the callback with null to show the call failed
		// wrong code!
		query.buildString += "<err code='203'>no users at all!</err>";
		return false;
	} else {
		for (var i in me) {
			//myTrace("checking " + me[i].name);
			if (me[i].name == query.name) {
				query.buildString += "<err code='206'>a user with this name already exists</err>";
				return false;
			}
		}
	}
	
	// ok, now we can insert a record for this user
	// Note: you shouldn't write out the whole of the query object
	// just the stuff you want (for instance NOT buildstring)
	var userObj = {name:query.name, userID:query.userID, password:query.password, 
					userSettings:query.userSettings, country:query.country,
					email:query.email, class:query.class, studentID:query.studentID}
	var newID = me.push(userObj) - 1;
	me[newID].userID = newID;
	query.userID = newID;
	query.buildString += "<user name='" + me[newID].name + "' " + 
						"userID='" + me[newID].userID + "' " +
						"userSettings='" + me[newID].userSettings + "' " +
						"country='" + me[newID].country + "' " +
						"email='" + me[newID].email + "' " +
						"className='" + me[newID].class + "' " + 
						"studentID='" + me[newID].studentID + "' />";					
	return true;
}
insertSession = function(query) {
	var me = _global.ORCHID.dbInterface.dbSharedObject.data.session;
	var saveNow = dateFormat(new Date());
	// v6.5.4.3 In case the lso was badly formed, start a new session object
	if (me==undefined) {
		me = _global.ORCHID.dbInterface.dbSharedObject.data.session = new Array();
	}

	// v6.3.5 Session now based on courseID not courseName
	//var progObj = {userID:query.userID, courseName:query.courseName, startTime:saveNow, scoreRecords:[]};
	var progObj = {userID:query.userID, courseID:query.courseID, startTime:saveNow, scoreRecords:[]};
	sessionID = me.push(progObj) - 1;
	for (var i in me) {
		//if (me[i].userID == query.userID && me[i].courseName == query.courseName) {
		if (me[i].userID == query.userID && me[i].courseID == query.courseID) {
			numSessions++;
		}
	}
	//myTrace("your progress index is " + this.progressIdx + " and sessionNum=" + sessionNum);
	query.buildString += "<session id='" + sessionID + "' count='" + numSessions + "' startTime='" + saveNow + "'/>"
}
updateSession = function(query) {
	var me = _global.ORCHID.dbInterface.dbSharedObject.data.session;
	var saveNow = dateFormat(new Date());
	me[query.sessionID].endTime = saveNow;
	//myTrace("current session started " + me[query.sessionID].startTime + " going at " + saveNow);
	// 6.0.6.0 to avoid lose of data due to refresh or crash, flush the lso db
	var returnCode = _global.ORCHID.dbInterface.dbSharedObject.flush();
	if (returnCode != true) {
		query.buildString += "<note>progress cannot be saved (flush failure)</note>";
	} else {
		query.buildString += "<note>session updated</note>";
	}
	//var returnCode = _global.ORCHID.dbInterface.dbSharedObject.flush();
	//myTrace("flush gives " + returnCode);
}
getScores = function(query) {
	var me = _global.ORCHID.dbInterface.dbSharedObject.data.session;
	//myTrace("LSO getScores, session records=" + me.length + " query.user=" + query.userID + " courseID=" + query.courseID);
	for (var i in me) {
		//myTrace("LSO me[i].userID=" + me[i].userID + " .course=" + me[i].courseName);
		// v6.3.5 Session now based on courseID not courseName
		//if (me[i].userID == query.userID && me[i].courseName == query.courseName) {
		if (me[i].userID == query.userID && me[i].courseID == query.courseID) {
			//myTrace("scores starting at " + me[i].startTime);
			for (var score in me[i].scoreRecords) {
				var myScore = me[i].scoreRecords[score];
				// check that it is a valid score record
				if (myScore.exerciseID != "") {
					//myTrace("add score for " + myScore.ExerciseID + "=" + myScore.score + "%");
					scoreNode = "<score dateStamp='" + myScore.dateStamp + "' " +
								"itemID='" + myScore.exerciseID + "' " +
								// v6.3 Add unitID to the score recording
								// userID is not needed as no teacher login with LSO
								// v6.4.2.8 Always send back the userID (even though it is just from the original query)
								"userID='" + query.userID + "' " +
								"unit='" + myScore.unitID + "' " +
								// v6.4.2.7 Also get testUnits and sessionID
								"testUnits='" + myScore.testUnits + "' " +
								"sessionID='" + sessionID + "' " +
								"score='" + myScore.score + "' " +
								"duration='" + myScore.duration + "' " +
								"correct='" + myScore.correct + "' " +
								"wrong='" + myScore.wrong + "' " +
								"skipped='" + myScore.skipped + "' " + "/>";
					query.buildString += scoreNode;
				}
			}
		}
	}
	return true;
}
insertScore = function(query) {
	//myTrace("insert lso score for session=" + query.sessionID + " and unit=" + query.unitID);
	var me = _global.ORCHID.dbInterface.dbSharedObject.data.session[query.sessionID];
	/*
	// v6.3.5 For something like APL where you are only doing scores using LSO, the
	// session object just isn't going to exist
	if (me == undefined) {
		myTrace("adding a session for the first time");
		insertSession(query);
	} else {
	}
	*/
	//myTrace("the session does exist, courseID=" + me.courseID);
	var saveNow = dateFormat(new Date());
	var scoreObj = {dateStamp:saveNow, 
					exerciseID:query.itemID, unitID:query.unitID, 
					score:query.score,
					duration:query.duration, 
					// v6.4.2.7 Also save testUnits and sessionID
					testUnits:query.testUnits,
					sessionID:query.sessionID,
					correct:query.correct, wrong:query.wrong, skipped:query.skipped};
	var scoreTotal = me.scoreRecords.push(scoreObj);
	// check that this was successful
	if (scoreTotal <= 0) {
		query.buildString += "<err code='205'>your progress is not being recorded " & Err.Description & "</err>"
		return false;
	} else {
		query.buildString += "<score status='true' />";
		return true;
	}
}
getScratchPad = function(query) {
	//myTrace("users=" + _global.ORCHID.dbInterface.dbSharedObject.data.user.length);
	// for anonymous entry, use the special setup user (_orchid)
	if (query.userID == -1) {
		var me = _global.ORCHID.dbInterface.dbSharedObject.data.user[0];	
	} else {
		var me = _global.ORCHID.dbInterface.dbSharedObject.data.user[query.userID];
	}
	//myTrace("get " + me.name + "'s scratchpad is " + me.scratchPad);
	// look at the results (expecting 1 record)
	if (me == undefined || me == null) {
		query.buildString += "<err code='203'>no such user</err>";
		return false;
	} else {
		query.buildString += "<scratchPad>" + me.scratchPad + "</scratchPad>"
		return true;
	}
}
setScratchPad = function(query) {
	// for anonymous entry, use the special setup user (_orchid)
	if (query.userID == -1) {
		var me = _global.ORCHID.dbInterface.dbSharedObject.data.user[0];
	} else {
		var me = _global.ORCHID.dbInterface.dbSharedObject.data.user[query.userID];
	}
	//myTrace("save " + me.name + "'s scratchpad as " + query.sentData);
	// look at the results (expecting 1 record)
	if (me == undefined || me == null) {
		query.buildString += "<err code='205'>your scratch pad has not been saved</err>";
		return false;
	} else {
		me.scratchPad = query.sentData;
		query.buildString += "<scratchPad>saved</scratchPad>"
		return true;
	}
}
// v6.4.2.4 New or null functions to stop crashing
// v6.3 New method for counting registered users
countUsers = function() {
	var numUsers = _global.ORCHID.dbInterface.dbSharedObject.data.user.length;
	queryNS.thisQuery.buildString += "<licence users='" + numUsers + "' />";
	return true;
}
// v6.4.2.8 New method for certificates
// This is not properly tested as no real situations seem to have lso with named users. It doesn't crash anyway.
getGeneralStats = function(query) {
	myTrace("getGeneralStats");
	var me = _global.ORCHID.dbInterface.dbSharedObject.data.session;
	myTrace("LSO getScores, session records=" + me.length + " query.user=" + query.userID + " courseID=" + query.courseID);
	var buildingObject = new Object;
	for (var i in me) {
		if (me[i].userID == query.userID && me[i].courseID == query.courseID) {
			for (var score in me[i].scoreRecords) {
				var myScore = me[i].scoreRecords[score];
				// check that it is a valid score record
				if (myScore.exerciseID>=100 && myScore.score>=0) {
					// add each score for this exercise ID together
					if (buildingObject[myScore.exerciseID]==undefined) {
						buildingObject[myScore.exerciseID] = {maxScore:myScore.score, countScored:1, maxCorrect:myScore.correct};
					} else {
						if (myScore.score>buildingObject[myScore.exerciseID].maxScore) {
							buildingObject[myScore.exerciseID].maxScore = myScore.score;
						}
						if (myScore.correct>buildingObject[myScore.exerciseID].maxCorrect) {
							buildingObject[myScore.exerciseID].maxCorrect = myScore.correct;
						}
						buildingObject[myScore.exerciseID].countScored++;
					}
				}					
			}
		}
	}
	// Then add all these records together
	var statsObject = {avgScored:0, countScored:0, dupScored:0, totalScore:0, totalCorrect:0, countUnScored:0, dupUnScored:0};
	var duplicates=0;
	for (var i in buildingObject) {
		myTrace("exid=" + i + " maxScore=" + buildingObject[i].maxScore + " done times=" + buildingObject[i].countScore);
		statsObject.countScored++;
		// v6.5.4.3 Getting long strings instead of numbers
		//statsObject.totalScore+=buildingObject[i].maxScore;
		statsObject.totalScore+=Number(buildingObject[i].maxScore);
		//statsObject.totalCorrect+=buildingObject[i].maxCorrect;
		statsObject.totalCorrect+=Number(buildingObject[i].maxCorrect);
		//duplicates+=buildingObject[i].countScore;
		duplicates+=Number(buildingObject[i].countScore);
	}
	if (statsObject.countScored>0) {
		//statsObject.avgScored = statsObject.totalScore / statsObject.countScored;
		statsObject.avgScored = Math.round(statsObject.totalScore / statsObject.countScored);
	}
	if (duplicates>statsObject.countScored) {
		statsObject.dupScored = duplicates - statsObject.countScored;
	}
	// Now repeat for unscored exercises
	var buildingObject = new Object;
	for (var i in me) {
		if (me[i].userID == query.userID && me[i].courseID == query.courseID) {
			for (var score in me[i].scoreRecords) {
				var myScore = me[i].scoreRecords[score];
				// check that it is a valid score record
				if (myScore.exerciseID>=100 && myScore.score<0) {
					// add each score for this exercise ID together
					if (buildingObject[myScore.exerciseID]==undefined) {
						buildingObject[myScore.exerciseID] = {countScored:1};
					} else {
						buildingObject[myScore.exerciseID].countScored++;
					}
				}					
			}
		}
	}
	// Then add all these records together
	var duplicates=0;
	for (var i in buildingObject) {
		myTrace("exid=" + i + " done times=" + buildingObject[i].countScore);
		statsObject.countUnScored++;
		// v6.5.4.3 Getting long strings instead of numbers
		//duplicates+=buildingObject[i].countScore;
		duplicates+=Number(buildingObject[i].countScore);
	}
	if (duplicates>statsObject.countUnScored) {
		statsObject.dupUnScored = duplicates - statsObject.countUnScored;
	}
	query.buildString += "<stats total='" + statsObject.totalCorrect +  "' average='" + statsObject.avgScored +  
						"' counted='"  + statsObject.countScored + "' viewed='" + statsObject.countUnScored +
						"' duplicatesCounted='"  + statsObject.dupScored + "' duplicatesViewed='" + statsObject.dupUnScored + "'/>";
	return true;
}

// once this module is loaded, call testWriteMethod for shared object
// (which will use the functions you have just loaded above)
//myTrace("loaded lso query swf, so trigger test method");
//myTrace("db=" + _root.databaseHolder.databaseNS.thisDB.name);
//myTrace("call testWriteMethod from " + _root.databaseHolder.databaseNS.thisDB.name);
// v6.3.6 Merge database to main and change NS
//_root.databaseHolder.databaseNS.thisDB.testWriteMethod("lso/actionscript");
//v6.4.2 rootless
_global.ORCHID.root.mainHolder.dbInterfaceNS.thisDB.testWriteMethod("lso/actionscript");

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
