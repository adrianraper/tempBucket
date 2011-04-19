
// Actually the main print button on the exercise screen does this nicely.
/*
this.cmdPrint = function() {
	myTrace("print cert");
	print(this._parent, "bmax");
}
this.certPrint_pb.setReleaseAction(this.cmdPrint);
this.certPrint_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("print", "buttons"));
*/
/*
GENERAL - 
	1) Check on the coverage - has the user done enough to see a summary score. If not, show them what they haven't done yet.
	2) If the coverage is enough, show them their score with details.
GENERAL - 
BULATS -
	Coverage has to be 100% to get the score
	Their is no pass or fail, simply a level. The level needs a description.
	This is for one of five tests, can you show the level for the any of the other five that are complete?
	Can you graphically show details of their score in each section - which may be one or more exercises.
BULATS -
CSTDI - 
	The purpose of this is to get the statistics to work out if you can get a cert.
	You also need to check that the evaluation (exID = 1001) has been completed.
	If the cert is valid, then we record its number in the scoreDetail table to allow
	the next one to pick up a sequential number.
CSTDI -	
*/
// This function checks coverage to see if they have completed enough of the test to see a summary
this.checkCoverage = function() {
	myTrace("check coverage");
	// BULATS - there is no specific exercise that I need to check, I just care about the number done
	// so use getStats to get this information. But first create a callBack which will work on the stats
	this.coverageCallBack = function() {
		myTrace("Your total score=" + this.total + ", average score=" + this.average + "% from " + this.counted + " marked exercises.");
		myTrace("And you viewed " + this.viewed + " more from a total of " + _global.ORCHID.course.scaffold.progress.numExercises);		
		var totalDone = Number(this.counted) + Number(this.viewed);
		//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
		// There are two non-marked exercises in the Before and After section
		var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 2;
		var percentComplete = Math.round((100 * totalDone) / totalToDo);
		var mustComplete = 100;
		var mustScore = 0;
		if (percentComplete < mustComplete) {
			this.failCoverage();
		} else if (this.average < mustScore) {
			this.failTest();
		//} else if (this.evaluationScore < 0 || this.evaluationScore == undefined) {
		//	this.failCoverage();
		} else {
			// OK, ready to build the certificate as you have passed
			this.passTest();
		}
	}
	this.getGeneralStats(this.coverageCallBack);
}
// This function gets general statistics to try and work out how much and well you have done
this.getGeneralStats = function(callBack) {
	myTrace("get general stats");
	if (callBack == undefined) {
		this.callBack = this.coverageTest;
	} else {
		this.callBack = callBack;
	}
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	
	// put the query into an XML object
	thisDB.queryString = '<query method="getGeneralStats" ' + 
					'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
					'userID="' + _global.ORCHID.user.userID + '" ' +
					'courseID="' + _global.ORCHID.course.id + '" ' +
					// also saved in _global.ORCHID.session.courseID
					'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		myTrace("getGeneralStats success=" + success);
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// we are expecting to get back a stats node
			} else if (tN.nodeName == "stats") {
				//myTrace("stats:avg=" + Math.round(tN.attributes.average));
				// parse the returned XML to get user details
				this.master.average = Math.round(tN.attributes.average);
				this.master.total = Math.round(tN.attributes.total);
				this.master.counted = tN.attributes.counted;
				this.master.viewed = tN.attributes.viewed;
				this.master.duplicatesCounted = tN.attributes.duplicatesCounted;
				this.master.duplicatesViewed = tN.attributes.duplicatesViewed;
				
			// anything unexpected?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call will have a defined stats value, so now check the stats
		//if (this.master.average >= 0) {
		this.master.callBack();
		//}
	}
	thisDB.runCustomQuery();
}
// This is where you show them they have not got enough coverage yet
this.failCoverage = function() {
	myTrace("fail coverage");
	var totalDone = Number(this.counted) + Number(this.viewed);
	// Don't count the certificate in the number of exercises
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
		// There are two non-marked exercises in the Before and After section
	var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 2;
	var percentComplete = Math.round((100 * totalDone) / totalToDo);
	//failCoverageGraphics.coverageStatus_txt.text = "You have only completed " + percentComplete + "% of the course."
	failCoverageGraphics.coverageStatus_txt.text = "You have completed " + totalDone + " of the " + totalToDo + " sections."
	failCoverageGraphics._visible = true;
}
// This is where you show them they have not got enough coverage yet
this.passTest = function() {
	myTrace("pass test");
	passTestGraphics.certName_txt.text = _global.ORCHID.user.name;
	passTestGraphics.certDate_txt.text = formatDate(new Date());
	var totalDone = Number(this.counted) + Number(this.viewed);
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
	// There are two non-marked exercises in the Before and After section
	var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 2;
	var percentComplete = Math.round((100 * totalDone) / totalToDo);
	passTestGraphics.certCourse_txt.text = _global.ORCHID.course.scaffold.caption;
	passTestGraphics.certScore_txt.text = "You scored " + this.total + " out of 110, ";
	if (this.total<20) {
		var yourALTELevel = 0;
		var ALTEDetail = "ALTE Level 0 / CEF A1 (Breakthrough User): Beginner level<br>" +
"Very limited command of the language. Candidates at this level may know some phrases but cannot communicate in the language.";
	} else if (this.total<45) {
		var yourALTELevel = 1;
		var ALTEDetail = "ALTE Level 1 / CEF A2 (Waystage User): Elementary level<br>" +
"Very limited command of the language in a range of familiar situations, e.g. you can understand and pass on simple messages. At this level you can use language to deal with simple, straightforward information and begin to express yourself in familiar contexts.";
	} else if (this.total<60) {
		var yourALTELevel = 2;
		var ALTEDetail = "ALTE Level 2 / CEF B1 (Threshold User): Intermediate level<br>" +
"Limited but effective command of the language in familiar situations, e.g. you can take part in a routine meeting on familiar topics, particularly in a exchange of simple factual information. At this level you can express yourself in a limited way and deal in a general way with non-routine information.";
	} else if (this.total<75) {
		var yourALTELevel = 3;
		var ALTEDetail = "ALTE Level 3 / CEF B2 (Independent User): Upper-intermediate level<br>" +
"Generally effective command of the language in a range of familiar situations, e.g. you can make a contribution to meetings on practical matters, but are unlikely to follow a complex argument. At this level you can use language to get familiar things done and to express yourself on a range of topics.";
	} else if (this.total<90) {
		var yourALTELevel = 4;
		var ALTEDetail = "ALTE Level 4 / CEF C1 (Competent User): Advanced level<br>" +
"Good operational command of the language in a range of business and work situations, e.g. you can participate effectively in discussions and meetings. At this level you have the ability to get things done in both familiar and unfamiliar situations with appropriacy and sensitivity.";
	} else {
		var yourALTELevel = 5;
		var ALTEDetail = "ALTE Level 5 / CEF C2 (Good User): Upper advanced level<br>" +
"Fully operational command of the language in most business and work situations, e.g. in the workplace you can argue a case confidently, justifying and making points persuasively. You have moved beyond the level of getting things done; you have the capacity to deal with material which is academic or cognitively demanding, and to use language to good effect. In other words, you have a level of performance which may in certain respects be more advanced than that of an average native speaker.";
	}
	passTestGraphics.certScore_txt.text += "which is an ALTE Level " + yourALTELevel;
	passTestGraphics.certLevelDetail_txt.htmlText = ALTEDetail;
	passTestGraphics._visible = true;
}
// BULATS
/* 
// CSTDI
this.validForCert = function() {
	myTrace("Your average score=" + this.average + "% from " + this.counted + " marked exercises.");
	myTrace("And you viewed " + this.viewed + " more from a total of " + _global.ORCHID.course.scaffold.progress.numExercises);
	// CSTDI Reactions! Rules - you do not see the certificate if you have not completed
	// the evaluation. Found during specific query above - held in this.evaluationScore
	// CSTDI Reactions! Rules - you do not see the certificate if you have completed less
	// than x% of the exercises and got less than x% as your average score.
	// Note that the certificate and evaluation are always ignored from the stats
	// but since the scaffold knows about them, add 2 to the viewed number.
	// NO - this leaves you with 7% if you have done nothing. Better to remove
	// from totalToDo. (And now the survey is removed, so just subtract 1)
	var totalDone = Number(this.counted) + Number(this.viewed);
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
	var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 1;
	var percentComplete = Math.round((100 * totalDone) / totalToDo);
	var mustComplete = 100;
	var mustScore = 70;
	// CSTDI update: no longer require as certificate, simply as progress report
	if (percentComplete < mustComplete) {
		warning_txt.text = "Sorry, you have only completed " + percentComplete + "% of the course."  + newline + 
						"You need to finish the course before getting your certificate."  + newline + newline +
						"You also need to score an average of " + mustScore + "%."  + newline + 
						"(Your current average is " + this.average + "%.)"  + newline + newline +
						"You can use the progress button on the right to see what you have done.";
		passGraphics._visible = false;
	} else if (this.average < mustScore) {
		warning_txt.text = "Sorry, you have only scored " + this.average + "% in this course."  + newline + 
						"You need to raise this to " + mustScore + "% by doing some exercises again."  + newline + newline + 
						"Please use the progress button on the right to see which areas you need to do again to improve your score.";
		passGraphics._visible = false;
	} else if (this.evaluationScore < 0 || this.evaluationScore == undefined) {
		warning_txt.text = "Please complete the evaluation exercise first."  + newline + 
						"Then you will be able to generate your certificate."  + newline + newline + 
						"Please go to the menu and select the evaluation to do this.";
		passGraphics._visible = false;
	} else {
		// OK, ready to build the certificate as you have passed
		this.buildCert();
	}
	passGraphics._visible = false;
	// available stats:
	//"Average score=" + this.average + "%"
	//"Scored exercises=" + this.counted 
	//"Viewed exercises=" + this.viewed 
	//"Duplicates=" + (Number(this.duplicatesViewed) + Number(this.duplicatesCounted))
	//"Total exercises=" + _global.ORCHID.course.scaffold.progress.numExercises
	//"Course=" + _global.ORCHID.course.scaffold.caption
	//"You are " + _global.ORCHID.user.name
	//"Date is " + _global.ORCHID.root.objectHolder.formatDateForProgress(_global.ORCHID.root.objectHolder.dateFormat(new Date()))
}
this.buildCert = function() {
	// First check to see if you have already given this user a certificate number
	// within this course
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	
	// put the query into an XML object
	thisDB.queryString = '<query method="getScoreDetail" ' + 
					'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
					'userID="' + _global.ORCHID.user.userID + '" ' +
					'courseID="' + _global.ORCHID.session.courseID + '" ' +
					'itemID="' + _global.ORCHID.session.currentItem.ID + '" ' +
					'questionID="' + '0' + '" />';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// we are expecting to get back a detail node
			} else if (tN.nodeName == "detail") {
				var certInfo = tN.attributes.detail;
				myTrace("got detail " + certInfo);
				var searchDetail = "certificate=";
				var endDetail = "&";
				var startPoint = Number(certInfo.indexOf(searchDetail))+Number(searchDetail.length);
				var endPoint = (certInfo.indexOf(endDetail, startPoint)<0) ? undefined : certInfo.indexOf(endDetail, startPoint);
				var thisDetail = certInfo.slice(startPoint,endPoint);
				this.master.certNumber = Number(thisDetail);
				this.master.certScore = tN.attributes.score;
				this.master.certSession = tN.attributes.sessionID;
				// there should only be one, but if more, just take the first
				break;
				
			// anything unexpected?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call will have a defined stats value, so show the summary
		// and what are you going to do if it wasn't successful?
		if (this.master.certNumber > 0) {
			myTrace("certNumber=" + this.master.certNumber);
			this.master.showCert();
		} else {
			myTrace("no existing cert");
			this.master.createCertNumber();
		}
	}
	thisDB.runCustomQuery();
}
// This function gets specific results from an exercise
// In this case, I am trying to see if they have completed the evaluation (always exID=1001)
// for this courseID.
this.getSpecific = function() {
	myTrace("have you done the evaluation?");
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();

	// I could instead read from the T_Scoredetail table if I wanted
	// put the query into an XML object
	thisDB.queryString = '<query method="getExerciseScore" ' + 
					'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
					'userID="' + _global.ORCHID.user.userID + '" ' +
					'itemID="' + "1001" + '" ' +
					'courseID="' + _global.ORCHID.session.courseID + '" ' +
					'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// we are expecting to get back a stats node
			} else if (tN.nodeName == "stats") {
				this.master.evaluationScore = tN.attributes.score;
				this.master.evaluationDate = tN.attributes.dateStamp;
				// if there are several, it doesn't matter, all we care is that it has been done.
				break;
				
			// anything unexpected?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		//myTrace("rc=" + this.toString());
		// a successful call will have a defined stats value, so show the summary
		// and what are you going to do if it wasn't successful?
		myTrace("got evaluation score=" + this.master.evaluationScore);
		//if (this.master.evaluationScore != undefined) {
		this.master.getStats();
		//}
	}
	thisDB.runCustomQuery();
}
this.createCertNumber = function() {
	// Run a query to get the max score for people who have 'done' this exercise
	// In other words, they are the ones who have got a certificate.
	myTrace("get sequence number");
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	
	// Don't count within the course, count across all courses for all users
	thisDB.queryString = '<query method="countScoreDetails" ' + 
					'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
					'itemID="' + _global.ORCHID.session.currentItem.ID + '" ' +
					'questionID="' + '0' + '" ' +
					'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// we are expecting to get back a stats node
			} else if (tN.nodeName == "stats") {
				this.master.certNumber = Number(tN.attributes.count)+1;
				
			// anything unexpected?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call will have a defined stats value, so show the summary
		// and what are you going to do if it wasn't successful?
		myTrace("got certificate count=" + this.master.certNumber);
		//if (this.master.evaluationScore != undefined) {
		this.master.addCertDetail();
		//}
	}
	thisDB.runCustomQuery();	
}
this.addCertDetail = function() {
	// Run a query to add this cert to the scoreDetail for this user.
	myTrace("write score detail");
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	
	// put the query into an XML object
	thisDB.queryString = '<query method="insertDetail" ' + 
					'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
					'userID="' + _global.ORCHID.user.userID + '" ' +
					'sessionID="' + _global.ORCHID.session.sessionID + '" ' +
					'itemID="' + _global.ORCHID.session.currentItem.ID + '" ' +
					'datestamp="' + dateFormat(new Date()) + '" ' +
					'questionID="' + '0' + '" ' +
					'score="' + this.average + '">' +
					'certificate=' + this.certNumber + '</query>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")

			// we are expecting to get back a success node
			} else if (tN.nodeName == "insert") {
				// parse the returned XML to get user details
				//myTrace("back with success=" + tN.attributes.success);
				this.master.inserted = (tN.attributes.success == "true");
				
			// anything unexpected?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		// a successful call will have a defined insert value, so show the summary
		// and what are you going to do if it wasn't successful?
		//if (this.master.inserted) {
		this.master.showCert();
		//}
	}
	thisDB.runCustomQuery();	
}
this.showCert = function() {
	// OK, they are now entitled to get the certificate. First of all write this fact to the scoreDetail
	// table. Then count how many other people have got certificates, add one and make this number
	// the score of the scoreDetail record. Return it to be the certificate number.
	passGraphics.warning_txt._visible = false;
	passGraphics.certName_txt.text = _global.ORCHID.user.name;
	passGraphics.certCourse_txt.text = "Reactions! " + _global.ORCHID.course.scaffold.caption;
	//passGraphics.certMustScore_txt.text = mustScore;
	// The date should really be read from the session table having got the session ID
	// from the scoreDetail record (this.certSession)
	passGraphics.certDate_txt.text = this.formatDate(new Date());
	passGraphics.certNumber_txt.text = this.certNumber;		
	passGraphics._visible = true;
}
*/
// utility functions
zeroPad = function(num) {
	if (num < 10) {
		return "0" + num;
	} else {
		return num;
	}
}
function formatDate(thisDate) {
// thisDate is from Flash new Date() format
// target for this function is
//	17 Jul 2003
// convert to YYYY-MM-DD HH:MM:SS
	var dateString = thisDate.getFullYear() + "-" + zeroPad(thisDate.getMonth()+1) + "-" + zeroPad(thisDate.getDate()) + " " + zeroPad(thisDate.getHours()) + ":" + zeroPad(thisDate.getMinutes()) + ":" + zeroPad(thisDate.getSeconds());
	var myDT = dateString.trim("both").split(" ");
	var myD = myDT[0].split("-");
	var myT = myDT[1].split(":");
	
	// remember that months in Flash are 0 based
	var theDate = new Date(myD[0], myD[1]-1, myD[2], myT[0], myT[1], myT[2]);
	// since you might be calling this in a big loop - save it once
	var myMonthsStr = _global.ORCHID.literalModelObj.getLiteral("months", "messages");
	//myTrace(myMonthsStr);
	if (myMonthsStr == undefined) {
		myMonthsStr="Jan, Feb, Mar, Apr, May, June, July, Aug, Sept, Oct, Nov, Dec";
	}
	var myMonths = myMonthsStr.split(", ");
	//myTrace(myMonths.toString());
	// Don't use days anymore - saves space and doesn't lose any info
	//var days=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	return theDate.getDate() + " " + myMonths[theDate.getMonth()] + ", " + theDate.getFullYear();
}

// assume three basic graphic sets (all over the background)
// 1) fail to get the coverage you need
// 2) get coverage, but fail the test
// 3) get coverage, and pass the test
failCoverageGraphics._visible = false;
failTestGraphics._visible = false;
passTestGraphics._visible = false;

// trigger the specific information collection as soon as the movie runs
myTrace("457:cert.as");
this.checkCoverage();
