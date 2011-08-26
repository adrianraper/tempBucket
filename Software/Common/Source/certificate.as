//
// Remember that this file is just a copy, the real one is on claritystorage!
//
//v6.5.6 To allow the certificate.swf to be on a remote domain
#include "\\Claritystorage\Qmultimedia\Programs\Software\ClearPronunciation\Source\sharedGlobal.as"

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
	Coverage is 100%, min score is 0%
GENERAL - 
TENSE BUSTER - 
	Coverage is 90%, min score is 0%
TENSE BUSTER - 
BC ILA -
	There is no coverage restriction because you only get to the certificate at the end of one of the tests
	Their is no pass or fail, simply a level. The level needs a CEF description.
	Would it be simpler to simply pick up records from the scaffold rather than do another db query?
	I need to	a) find which unit I am in - this is the test I have taken
			b) find the total score correct for all exercises in this unit
			c) convert to a CEF
BC ILA -
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
var totalToDo;
//var mustComplete;
//var mustScore;
var percentComplete;

// v6.5.5.8 Can I add a generic footer?
this.formatCommonFooter = function() {
	// v6.5 Can you pick this up from literals file?
	var footerText = _global.ORCHID.literalModelObj.getLiteral("certificateFooter", "messages");
	if (footerText==undefined || footerText=="") {
		footerText = this.footer_txt.text;
	}
	myTrace("cert footer text=" + footerText);
	// What might you use in a common footer?
	//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
	var substList = [	{tag:"[date]", text:formatDate(new Date())},
					{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
					{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
	this.footer_txt.htmlText = substTags(footerText, substList);
	myTrace("changes to =" + substTags(footerText, substList));
}

// This function checks coverage to see if they have completed enough of the test to see a summary
this.checkCoverage = function() {
	// Check that they have a real name. There should be a better literal than this.
	if (_global.ORCHID.user.name == "_orchid") {
		this.certificateName = "---";
	} else {
		this.certificateName = _global.ORCHID.user.name;
	}
	
	myTrace("check coverage for " + _global.ORCHID.root.licenceHolder.licenceNS.branding + " + " + this.certificateName);
	// BULATS - there is no specific exercise that I need to check, I just care about the number done
	// so use getStats to get this information. But first create a callBack which will work on the stats
	this.coverageCallBack = function() {
		myTrace("Your total score=" + this.total + ", average score=" + this.average + "% from " + this.counted + " marked exercises.");
		myTrace("And you viewed " + this.viewed + " more from a total of " + _global.ORCHID.course.scaffold.progress.numExercises);		
		var totalDone = Number(this.counted) + Number(this.viewed);
		//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
		if (	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) ||
			(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ro") >= 0) ||
			(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ap") >= 0) ||
			(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ar") >= 0) ||
			(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sss") >= 0) ||
			(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/iyj") >= 0) ||
			(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ces") >= 0) ||
			(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/bw") >= 0)) {
			// TENSE BUSTER
			// Ignore the certificate. 
			// v6.5.4.4 Except that because we give it a unique ID we can ignore it in the SQL call (only get id>100)
			//totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 1;
			totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
			percentComplete = Math.round((100 * totalDone) / totalToDo);
			// See if the criteria are set in the certificate swf
			if (Number(this.mustComplete)>= 0) {
			} else {
				mustComplete = 90;
			}
			if (Number(this.mustScore)>= 0) {
			} else {
				mustScore = 0;
			}
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BULATS") >= 0) {
			// BULATS
			// There are two non-marked exercises in the Before and After section
			totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 2;
			percentComplete = Math.round((100 * totalDone) / totalToDo);
			mustComplete = 100;
			mustScore = 0;
			// BULATS
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("bc/ila") >= 0) {
			// BC ILA test
			// No coverage condition
			totalToDo = 0;
			percentComplete = 100;
			mustComplete = 100;
			mustScore = 0;
			// BC ILA
		} else {
			// GENERAL
			// Assume there is only one certificate to ignore
			// v6.5.4.4 Except that because we give it a unique ID we can ignore it in the SQL call (only get id>100)
			//totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 1;
			totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
			percentComplete = Math.round((100 * totalDone) / totalToDo);
			mustComplete = 100;
			mustScore = 0;
			// GENERAL
		}
		myTrace("your coverage is " + percentComplete + " and you have to do  " + mustComplete);		
		myTrace("your average is " + this.average + " and you have to get  " + mustScore);		
		myTrace("your userID is " + _global.ORCHID.user.userID);		
		// v6.5 Make sure it is valid
		//if (percentComplete < mustComplete) {
		if (_global.ORCHID.user.userID<=0) {
			this.anonymousCoverage();
		} else if (mustComplete==undefined || percentComplete<=0 || mustComplete<=0 || percentComplete < mustComplete) {
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
	// v6.5.5.1 BC Placement test needs more specific information which is all in the scaffold. So do it very differently.
	// The Clarity test needs info from the scaffold AND the database (detailed answers), so that is different again
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("bc/ila") >= 0) {
		this.getSpecificStatsFromScaffold();
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/placementtest") >= 0) {
		// remember to call getSpecificStatsFromScaffold at the end of this call.
		myTrace("go to specifics");
		this.getSpecifcStats(this.specificStatsCallBack);
	} else {
		this.getGeneralStats(this.coverageCallBack);
	}
}
// Function to get specific stats from the database. This is probably something that you can't get from the scaffold.
this.getSpecificStats = function(callBack) {
	myTrace("getSpecificStats");
	if (callBack == undefined) {
		this.callBack = this.specificStatsCallBack;
	} else {
		this.callBack = callBack;
	}
	// Clarity placement test
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/placementtest") >= 0) {
		this.total=0;
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		
		// purely for testing certificates
		if (_global.ORCHID.commandLine.sessionID) {
			myTrace("using special sessionID for certificate testing");
			mySessionID = _global.ORCHID.commandLine.sessionID;
		} else {
			mySessionID = _global.ORCHID.session.sessionID;
		}
		// put the query into an XML object
		thisDB.queryString = '<query method="getSpecificStats" ' + 
						'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
						'userID="' + _global.ORCHID.user.userID + '" ' +
						//'courseID="' + _global.ORCHID.session.courseID + '" ' +
						'sessionID="' + mySessionID + '" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' + 
						// also saved in _global.ORCHID.session.courseID
						'cacheVersion="' + new Date().getTime() + '"/>';
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		thisDB.xmlReceive.onLoad = function(success) {
			myTrace("getSpecificStats success=" + success);
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
	
				// we are expecting to get back a node for each exercise done, with question details if available
				} else if (tN.nodeName == "score") {
					myTrace("specific score: " + tN.toString());
					// We want to get the number correct from the [three] sections - one exercise each.
					// It is OK to be very specific here about exerciseIDs
					if (	(tN.attributes.id == '1193901049551') || // this is the vocab exercise
						(tN.attributes.id == '1193901049561') || // this is the listening exercise
						(tN.attributes.id == '1193901049540')) { // this is the grammar exercise
						myTrace("adding " + tN.attributes.score + " for section " + tN.attributes.id);
						this.master.total+=parseInt(tN.attributes.score);
					}
					// Then we want to get the actual answers from the self-assesment and assign specific points to each - q4 gets 4 points, q7 gets 7 etc
				} else if (tN.nodeName == "detail") {
					myTrace("specific detail: " + tN.toString());
					// We want to get the number correct from the [three] sections - one exercise each.
					// It is OK to be very specific here about exerciseIDs and itemIDs
					var thisQuestionNumber = parseInt(tN.attributes.id.split('.')[1]);
					var thisExerciseID = tN.attributes.id.split('.')[0];
					if (thisExerciseID == '1292227313781' && tN.attributes.score=='1') {
						myTrace("adding " + thisQuestionNumber + " for question");
						this.master.total+=thisQuestionNumber;
					}
					
				// anything unexpected?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
				// Then add them up and work out a descriptor
				//this.master.average = Math.round(tN.attributes.average);
			}
			// a successful call will have ?
			this.master.callBack();
		}
		thisDB.runQuery();
	}
}
// Return from getting specific stats
this.specificStatsCallBack = function() {
	// Set any global variables that are used in the certificate with relevant data
	myTrace("Your total score=" + this.total);
	this.passTest();
}

// This function gets specific stats from the scaffold for a particular test
// Note - it seems that the most recent results are not in the scaffold? Or at least not in the same way.
this.getSpecificStatsFromScaffold = function() {
	// Clarity placement test - actually you won't use this as get everything from the db
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/placementtest") >= 0) {
		// We want to get the number correct from the [three] sections - one exercise each.
		// Then we want to get the actual answers from the self-assesment and assign specific points to each
		// Then add them up and work out a descriptor
	// BC ILA
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("bc/ila") >= 0) {
		myTrace("specific stats for ILA");
		// OK, what test have you just completed? It is the unit that this cert is running in.
		var thisUnit = _global.ORCHID.session.currentItem.unit;
		myTrace("unit=" + thisUnit);
		
		// And what were all the scores for the exercises in this unit? Just the last ones.
		var scaffold = _global.ORCHID.course.scaffold;
		var itemsInUnit = scaffold.getObjectByUnitID(thisUnit);
		myTrace("unit caption=" + itemsInUnit.caption + " with exercises=" + itemsInUnit.action.length);
		// But I actually want to break down the exercises into Grammar, Reading and Vocabulary - which are set with group="x"
		// Mind you, i am principally using the group attribute for shared timers, so best not base it on that.
		// In this case it is OK to base it on caption.
		var totalScore = 0;
		var grammarScore = 0;
		var readingScore = 0;
		var vocabScore = 0;
		for (var j in itemsInUnit.action) {
			var thisEx = itemsInUnit.action[j];
			var allRecords = thisEx.progress.record;
			//myTrace("ex caption=" + thisEx.caption + " has " + allRecords.length + " progress records");
			// Note. I think that an exercise you did in this session will be at the end, but once records
			// are read from the database they are sorted so that the most recent is first. Hmmm.
			// OK, fixed in course.as by using a 'singleInsert' to insertProgressRecord to differentiate between db loading and individual adding
			// so we now add new records to the beginning. Check progress display is still fine.
			//var lastProgressRecord = allRecords[allRecords.length-1];
			var lastProgressRecord = allRecords[0];
			myTrace("ex " + thisEx.id + ":" + thisEx.caption + " score=" + lastProgressRecord.score + " scoreCorrect=" + lastProgressRecord.correct);
			// what is the score for each of these?
			totalScore+=Number(lastProgressRecord.correct);
			if (thisEx.caption.toLowerCase().indexOf("grammar")>=0) {
				grammarScore+=Number(lastProgressRecord.correct);
			} else if (thisEx.caption.toLowerCase().indexOf("reading")>=0) {
				readingScore+=Number(lastProgressRecord.correct);
			} else if (thisEx.caption.toLowerCase().indexOf("vocab")>=0) {
				vocabScore+=Number(lastProgressRecord.correct);
			}
		} 
		myTrace("totals grammar=" + grammarScore + " reading=" + readingScore + " vocabulary=" + vocabScore);
		// Put it in the right place to be picked up in the passTest routine
		this.totalScore = totalScore;
		this.grammarScore = grammarScore;
		this.readingScore = readingScore;
		this.vocabScore = vocabScore;
		this.unitCaption = itemsInUnit.caption;
	}
	// once you have figured out the details, display the cert
	this.passTest();
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
	// v6.4.2.8 Merge to main query
	//thisDB.runCustomQuery();
	thisDB.runQuery();
}
// This is where you show them they have not got enough coverage yet
this.failCoverage = function() {
	myTrace("fail coverage");
	var totalDone = Number(this.counted) + Number(this.viewed);
	// Don't count the certificate in the number of exercises
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 2;
	//var percentComplete = Math.round((100 * totalDone) / totalToDo);
	//failCoverageGraphics.coverageStatus_txt.text = "You have only completed " + percentComplete + "% of the course."
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/TB") >= 0) {
		var failCoverageText = failCoverageGraphics.coverageStatus_txt.text;
		//myTrace("original text = " + failCoverageText);
		var substList = [{tag:"[totalDone]", text:totalDone},
						{tag:"[totalToDo]", text:totalToDo},
						{tag:"[percentComplete]", text:percentComplete},
						{tag:"[averageScore]", text:this.average}];
		failCoverageGraphics.coverageStatus_txt.text = substTags(failCoverageText, substList);
		var headerText = failCoverageGraphics.header_txt.text;
		//myTrace("original text = " + headerText);
		var substList = [{tag:"[name]", text:this.certificateName},
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		failCoverageGraphics.header_txt.text = substTags(headerText, substList);
	//} else {
	//	failCoverageGraphics.coverageStatus_txt.text = "You have completed " + totalDone + " of the " + totalToDo + " sections."
	//}
	failCoverageGraphics._visible = true;
}
// For when this user hasn't logged in
this.anonymousCoverage = function() {
	myTrace("anonymous coverage");
	var totalDone = Number(this.counted) + Number(this.viewed);
	// Don't count the certificate in the number of exercises
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 2;
	//var percentComplete = Math.round((100 * totalDone) / totalToDo);
	//failCoverageGraphics.coverageStatus_txt.text = "You have only completed " + percentComplete + "% of the course."
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/TB") >= 0) {
		var anonCoverageText = anonCoverageGraphics.coverageStatus_txt.text;
		//myTrace("original text = " + anonCoverageText);
		var substList = [{tag:"[totalDone]", text:totalDone},
						{tag:"[totalToDo]", text:totalToDo},
						{tag:"[percentComplete]", text:percentComplete},
						{tag:"[averageScore]", text:this.average}];
		anonCoverageGraphics.coverageStatus_txt.text = substTags(anonCoverageText, substList);
		var headerText = failCoverageGraphics.header_txt.text;
		//myTrace("original text = " + headerText);
		var substList = [{tag:"[name]", text:"---"},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		anonCoverageGraphics.header_txt.text = substTags(headerText, substList);
	//} else {
	//	failCoverageGraphics.coverageStatus_txt.text = "You have completed " + totalDone + " of the " + totalToDo + " sections."
	//}
	anonCoverageGraphics._visible = true;
}
// This is where you show them their result if they passed
this.passTest = function() {
	myTrace("pass test");
	//passTestGraphics.certName_txt.text = _global.ORCHID.user.name;
	//passTestGraphics.certDate_txt.text = formatDate(new Date());
	var totalDone = Number(this.counted) + Number(this.viewed);
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
	// There are two non-marked exercises in the Before and After section
	//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 2;
	//var percentComplete = Math.round((100 * totalDone) / totalToDo);
	//passTestGraphics.certCourse_txt.text = _global.ORCHID.course.scaffold.caption;
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BULATS") >= 0) {
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
		
	// Clarity Placement Test
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/placementtest") >= 0) {
		if (this.total>100) {
			var descriptor="Advanced";
		} else if (this.total>80) {
			var descriptor="Upper Intermediate";
		} else if (this.total>60) {
			var descriptor="Intermediate";
		} else if (this.total>40) {
			var descriptor="Lower Intermediate";
		} else {
			var descriptor="Elementary";
		}
		passTestGraphics.passStatus_txt.text = "Please try " + descriptor + " as you got " + this.total;
		var headerText = passTestGraphics.header_txt.text;
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		var substList = [{tag:"[name]", text:this.certificateName},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
						{tag:"[unit]", text:this.unitCaption},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		passTestGraphics.header_txt.text = substTags(headerText, substList);
		
	// British Council Placement Test
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("bc/ila") >= 0) {
		// First we need to know which test they took
		if (this.unitCaption.toLowerCase().indexOf("test a")>=0) {
			// Then we work out their CEF for each section
			if (this.grammarScore<5) var grammarCEF = "A0";
			if (this.grammarScore>=5 && this.grammarScore<=11) var grammarCEF = "A1";
			if (this.grammarScore>11) var grammarCEF = "A2";
			
			if (this.vocabScore<11) var vocabCEF = "A0";
			if (this.vocabScore>=11 && this.vocabScore<=20) var vocabCEF = "A1";
			if (this.vocabScore>20) var vocabCEF = "A2";
			
			if (this.readingScore<4) var readingCEF = "A0";
			if (this.readingScore>=4 && this.reading<=8) var readingCEF = "A1";
			if (this.readingScore>8) var readingCEF = "A2";
			
			// Finally we need to combine them, but I don't know how. Make a guess that is based on total score
			if (this.totalScore<20) var overallCEF = "A0";
			if (this.totalScore>=20 && this.totalScore<=39) var overallCEF = "A1";
			if (this.totalScore>39) var overallCEF = "A2";
			
		} else if (this.unitCaption.toLowerCase().indexOf("test b")>=0) {
			// Then we work out their CEF for each section
			if (this.grammarScore<8) var grammarCEF = "A2";
			if (this.grammarScore>=8 && this.grammarScore<=17) var grammarCEF = "B1";
			if (this.grammarScore>17) var grammarCEF = "B2";
			
			if (this.vocabScore<10) var vocabCEF = "A2";
			if (this.vocabScore>=10 && this.vocabScore<=18) var vocabCEF = "B1";
			if (this.vocabScore>18) var vocabCEF = "B2";
			
			if (this.readingScore<5) var readingCEF = "A2";
			if (this.readingScore>=5 && this.reading<=11) var readingCEF = "B1";
			if (this.readingScore>11) var readingCEF = "B2";
			
			// Finally we need to combine them, but I don't know how. Make a guess that is based on total score
			if (this.totalScore<23) var overallCEF = "A2";
			if (this.totalScore>=23 && this.totalScore<=46) var overallCEF = "B1";
			if (this.totalScore>46) var overallCEF = "B2";
			
		} else if (this.unitCaption.toLowerCase().indexOf("test c")>=0) {
			// Then we work out their CEF for each section
			if (this.grammarScore<8) var grammarCEF = "B2";
			if (this.grammarScore>=8 && this.grammarScore<=14) var grammarCEF = "C1";
			if (this.grammarScore>14) var grammarCEF = "C2";
			
			if (this.vocabScore<8) var vocabCEF = "B2";
			if (this.vocabScore>=8 && this.vocabScore<=15) var vocabCEF = "C1";
			if (this.vocabScore>15) var vocabCEF = "C2";
			
			if (this.readingScore<5) var readingCEF = "B2";
			if (this.readingScore>=5 && this.reading<=11) var readingCEF = "C1";
			if (this.readingScore>11) var readingCEF = "C2";
			
			// Finally we need to combine them, but I don't know how. Make a guess that is based on total score
			if (this.totalScore<21) var overallCEF = "B2";
			if (this.totalScore>=21 && this.totalScore<=40) var overallCEF = "C1";
			if (this.totalScore>40) var overallCEF = "C2";
			
		}
		if (overallCEF=="A0") {
			var CEFDetail = "<b>CEF A0 (Breakthrough): Basic user</b><br>" +
	"Can understand and use familiar everyday expressions and very basic phrases aimed at the satisfaction of needs of a concrete type.<br>Can introduce him/herself and others and can ask and answer questions about personal details such as where he/she lives, people he/she knows and things he/she has.<br>Can interact in a simple way provided the other person talks slowly and clearly and is prepared to help.";
		} else if (overallCEF=="A1") {
			var CEFDetail = "<b>CEF A1 (Breakthrough): Basic user</b><br>" +
	"Can understand and use familiar everyday expressions and very basic phrases aimed at the satisfaction of needs of a concrete type. Can introduce him/herself and others and can ask and answer questions about personal details such as where he/she lives, people he/she knows and things he/she has. Can interact in a simple way provided the other person talks slowly and clearly and is prepared to help.";
		} else if (overallCEF=="A2") {
			var CEFDetail = "<b>CEF A2 (Waystage): Basic user</b><br>" +
	"Can understand sentences and frequently used expressions related to areas of most immediate relevance (e.g. very basic personal and family information, shopping, local geography, employment). Can communicate in simple and routine tasks requiring a simple and direct exchange of information on familiar and routine matters. Can describe in simple terms aspects of his/her background, immediate environment and matters in areas of immediate need.";
		} else if (overallCEF=="B1") {
			var CEFDetail = "<b>CEF B1 (Threshold): Independent User</b><br>" +
	"Can understand the main points of clear standard input on familiar matters regularly encountered in work, school, leisure, etc. Can deal with most situations likely to arise whilst travelling in an area where the language is spoken. Can produce simple connected text on topics which are familiar or of personal interest. Can describe experiences and events, dreams, hopes & ambitions and briefly give reasons and explanations for opinions and plans.";
		} else if (overallCEF=="B2") {
			var CEFDetail = "<b>CEF B2 (Vantage): Independent User</b><br>" +
	"Can understand the main ideas of complex text on both concrete and abstract topics, including technical discussions in his/her field of specialisation. Can interact with a degree of fluency and spontaneity that makes regular interaction with native speakers quite possible without strain for either party. Can produce clear, detailed text on a wide range of subjects and explain a viewpoint on a topical issue giving the advantages and disadvantages of various options.";
		} else if (overallCEF=="C1") {
			var CEFDetail = "<b>CEF C1 (Effective Operational Proficiency): Proficient User</b><br>" +
	"Can understand a wide range of demanding, longer texts, and recognise implicit meaning. Can express him/herself fluently and spontaneously without much obvious searching for expressions. Can use language flexibly and effectively for social, academic and professional purposes. Can produce clear, well-structured, detailed text on complex subjects, showing controlled use of organisational patterns, connectors and cohesive devices.";
		} else if (overallCEF=="C2") {
			var CEFDetail = "<b>CEF C2 (Mastery): Proficient User</b><br>" +
	"Can understand with ease virtually everything heard or read. Can summarise information from different spoken and written sources, reconstructing arguments and accounts in a coherent presentation. Can express him/herself spontaneously, very fluently and precisely, differentiating finer shades of meaning even in the most complex situations.";
		}
		// Put all this onto the cert
		var headerText = passTestGraphics.header_txt.text;
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		var substList = [{tag:"[name]", text:this.certificateName},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
						{tag:"[unit]", text:this.unitCaption},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		passTestGraphics.header_txt.text = substTags(headerText, substList);
						
		passTestGraphics.passStatus_txt.htmlText = "This test indicates that your level is";
		passTestGraphics.passStatus_txt.htmlText += CEFDetail;
		passTestGraphics.passStatus_txt.htmlText += "<br>Grammar CEF=" + grammarCEF;
		passTestGraphics.passStatus_txt.htmlText += "Vocabulary CEF=" + vocabCEF;
		passTestGraphics.passStatus_txt.htmlText += "Reading CEF=" + readingCEF;
		// disclaimer				
		passTestGraphics.passStatus_txt.htmlText += "<br>After the oral test, a teacher will explain your overall level and advise you of the best course available.  Please be aware that test scores are only to be used for placement into British Council courses and not for any other reason.";
		passTestGraphics.passStatus_txt.htmlText += "<br>We would be grateful if you can <u><a href='http://www.zoomerang.com/Survey/survey-intro.zgi?p=WEB229HGXGXKHS' target='_blank'>click here and take a survey for us</a></u>. Thanks!";

		// v6.5 Can you pick this up from literals file?
		var footerText = _global.ORCHID.literalModelObj.getLiteral("certificateFooter", "messages");
		if (footerText==undefined || footerText=="") {
			footerText = passTestGraphics.footer_txt.text;
		}
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		var substList = [{tag:"[name]", text:this.certificateName},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		passTestGraphics.footer_txt.text = substTags(footerText, substList);
		
	} else {
		var headerText = passTestGraphics.header_txt.text;
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		var substList = [{tag:"[name]", text:this.certificateName},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
						{tag:"[unit]", text:this.unitCaption},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		passTestGraphics.header_txt.text = substTags(headerText, substList);
						
		var passCourseText = passTestGraphics.passStatus_txt.text;
		//myTrace("original text = " + passCourseText);
		var substList = [{tag:"[totalDone]", text:totalDone},
						{tag:"[totalToDo]", text:totalToDo},
						{tag:"[percentComplete]", text:percentComplete},
						{tag:"[totalCorrect]", text:this.total},
						{tag:"[averageScore]", text:this.average}];
		passTestGraphics.passStatus_txt.text = substTags(passCourseText, substList);

		// v6.5 Can you pick this up from literals file?
		var footerText = _global.ORCHID.literalModelObj.getLiteral("certificateFooter", "messages");
		if (footerText==undefined || footerText=="") {
			footerText = passTestGraphics.footer_txt.text;
		}
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		var substList = [{tag:"[name]", text:this.certificateName},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		passTestGraphics.footer_txt.text = substTags(footerText, substList);
						
	}
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
	// v6.4.2.8 Merge to main query
	//thisDB.runCustomQuery();
	thisDB.runQuery();
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
	// v6.4.2.8 Merge to main query
	//thisDB.runCustomQuery();
	thisDB.runQuery();
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
substTags = function(thisText, substList) {
	// just in case you come here with null stuff
	if (substList == null || substList == undefined) return thisText;
	
	// Add in common things
	substList.push({tag:"[newline]", text:"<br>"});
	substList.push({tag:"[tab]", text:"<tab>"});
	// make sure you don't change the original text
	// Note: See ASDG for guidance on pass by reference vs pass by value and how to make copies
	var buildText = thisText;
	// if substList is empty, you will just send back text unadulterated, but still a copy NOT the original
	for (var i in substList) {		
		//trace("looking to replace " + substList[i].tag + " with " + substList[i].text + " in " + buildText);
		buildText = _global.ORCHID.root.objectHolder.findReplace(buildText, substList[i].tag, substList[i].text, 0);
	}
	return buildText;
}
// assume three basic graphic sets (all over the background)
// 1) fail to get the coverage you need
// 2) get coverage, but fail the test
// 3) get coverage, and pass the test
failCoverageGraphics._visible = false;
anonCoverageGraphics._visible = false;
failTestGraphics._visible = false;
passTestGraphics._visible = false;

// trigger the specific information collection as soon as the movie runs
//myTrace("457:cert.as");
this.formatCommonFooter();
this.checkCoverage();
