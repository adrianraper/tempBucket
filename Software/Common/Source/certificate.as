// Remember that this is just a copy
// Master version is on \\Claritystorage\Qmultimedia\Programs\Software\ClearPronunciation\Source

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
var customised;
var sequenceNumber;

// The only way I can see to pick up if it is CSTDI
if (_global.ORCHID.root.licenceHolder.licenceNS.central.root == 10127 ||
	_global.ORCHID.root.licenceHolder.licenceNS.central.root == 14449) {
	myTrace("certificate for CSTDI");
	customised = "CSTDI";
}

// v6.5.5.8 Can I add a generic footer?
this.formatCommonFooter = function() {
	// v6.5 Can you pick this up from literals file?
	var footerText = _global.ORCHID.literalModelObj.getLiteral("certificateFooter", "messages");
	if (footerText==undefined || footerText=="") {
		footerText = this.footer_txt.text;
	}
	//myTrace("cert footer text=" + footerText);
	// What might you use in a common footer?
	//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
	var substList = [	{tag:"[date]", text:formatDate(new Date())},
					{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
					{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
	this.footer_txt.htmlText = substTags(footerText, substList);
	//myTrace("changes to " + substTags(footerText, substList));
}

// This function checks coverage to see if they have completed enough of the test to see a summary
this.checkCoverage = function() {
	// Check that they have a real name. There should be a better literal than this.
	if (_global.ORCHID.user.name == "_orchid") {
		this.certificateName = "---";
	} else {
		this.certificateName = _global.ORCHID.user.name;
	}
	
	myTrace("5.check coverage for " + _global.ORCHID.root.licenceHolder.licenceNS.branding + " + " + this.certificateName + " root=" + _global.ORCHID.root.licenceHolder.licenceNS.central.root);
	// BULATS - there is no specific exercise that I need to check, I just care about the number done
	// so use getStats to get this information. But first create a callBack which will work on the stats
	// v6.5.6.4 Note that all exercises with an ID less than 100 are excluded as they are assumed to be certificates etc.
	// So if you have exercises that are related texts etc, then these will be counted as viewed. 
	// But what about progress.numExercises - does that include them? No, it correctly doesn't.
	// But something else that is wrong is that the generalStats includes everything in the database for this course, even exercises that have been removed.
	// That is correct for the SQL, but we should find a way to weed it out by merging with the scaffold. Although this is a minor issue for Clarity programs since they rarely drop exercises.
	// It just tends to come up during development when exercises do get in and out, or renamed and rubbish gets left around.
	this.coverageCallBack = function() {
		myTrace("coverageCallBack for " + this.customised);
		myTrace("Your total score=" + this.total + ", average score=" + this.average + "% from " + this.counted + " marked exercises.");
		myTrace("And you viewed " + this.viewed + " more from a total of " + _global.ORCHID.course.scaffold.progress.numExercises);		
		var totalDone = Number(this.counted) + Number(this.viewed);
		//var totalToDo = _global.ORCHID.course.scaffold.progress.numExercises;
		
		// Add CSTDI customisation
		if (this.customised=='CSTDI') {
			// 2 less exercises as certificate and survey not to be included
			totalToDo = _global.ORCHID.course.scaffold.progress.numExercises - 2;
			percentComplete = Math.round((100 * totalDone) / totalToDo);
			switch (_global.ORCHID.root.licenceHolder.licenceNS.productCode) {
				case '10':
					mustComplete = 50;
					mustScore = 0;
					break;
				case '50':
				case '39':
					mustComplete = 70;
					mustScore = 0;
					break;
				default:
					mustComplete = 90;
					mustScore = 0;
					break;
			}
			// To ease certificate testing
			if (this.certificateName.indexof('RAPER, Adrian')>=0)
				mustComplete = 1;
			
			myTrace("this is a CSTDI certificate for " + _global.ORCHID.root.licenceHolder.licenceNS.productCode + ", total ex=" + totalToDo + " your sequence number is " + sequenceNumber);
			
			// IF this was the first time for the certificate, we have now written the sequence number, but we didn't 
			// know the average at that point, so we need to update the record now.
			// Better just to duplicate the call to generalStats in spsecirfiStats. see dbProgress.php
			
		// v6.5.6.5 All Clarity programs are treated the same at the moment
		} else if ((_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity") >= 0)) {
		//if (	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) ||
		//	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ro") >= 0) ||
		//	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ap") >= 0) ||
		//	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ar") >= 0) ||
		//	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) ||
		//	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sss") >= 0) ||
		//	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/iyj") >= 0) ||
		//	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ces") >= 0) ||
		//	(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/bw") >= 0)) {
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
		this.getSpecificStats(this.specificStatsCallBack);
	// CSTDI just needs to pick up a sequence number, and then use normal certificate processing
	} else if (this.customised=="CSTDI") {
		this.getSpecificStats(this.coverageCallBack);
	} else {
		this.getGeneralStats(this.coverageCallBack);
	}
}
// Function to get specific stats from the database. This is probably something that you can't get from the scaffold.
this.getSpecificStats = function(callBack) {
	//myTrace("getSpecificStats");
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
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
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
					if (	(tN.attributes.id == '1193901049551') || // this is the vocab 1 exercise
						(tN.attributes.id == '1193901049552') || // this is the vocab 2 exercise
						(tN.attributes.id == '1193901049561') || // this is the listening 1 exercise
						(tN.attributes.id == '1193901049562') || // this is the listening 2 exercise
						(tN.attributes.id == '1193901049540') || // this is the grammar 1 exercise
						(tN.attributes.id == '1193901049541')) { // this is the grammar 2 exercise
						myTrace("adding " + tN.attributes.score + " for section " + tN.attributes.id);
						this.master.total+=parseInt(tN.attributes.score);
					}
					// Then we want to get the actual answers from the self-assesment and assign specific points to each - q4 gets 4 points, q7 gets 7 etc
				} else if (tN.nodeName == "detail") {
					//myTrace("specific detail: " + tN.toString());
					var thisQuestionNumber = parseInt(tN.attributes.id.split('.')[1]);
					var thisExerciseID = tN.attributes.id.split('.')[0];
					if (thisExerciseID == '1292227313781' && tN.attributes.score=='1') {
						myTrace("adding " + thisQuestionNumber + " for self-assessment");
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
		
	} else if (this.customised=="CSTDI") {
		myTrace("getSpecificStats for CSTDI");
		var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
		// put the query into an XML object
		thisDB.queryString = '<query method="getSpecificStats" ' + 
						'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
						'userID="' + _global.ORCHID.user.userID + '" ' +
						'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' + 
						'courseID="' + _global.ORCHID.session.courseID + '" ' +
						'itemID="' + _global.ORCHID.session.currentItem.ID + '" ' +
						'sessionID="' + _global.ORCHID.session.sessionID + '" ' +
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
						'cacheVersion="' + new Date().getTime() + '"/>';
		thisDB.xmlReceive = new XML();
		thisDB.xmlReceive.master = this;
		thisDB.xmlReceive.onLoad = function(success) {
			myTrace("getSpecificStats cstdi success=" + success);
			for (var node in this.firstChild.childNodes) {
				var tN = this.firstChild.childNodes[node];
				//sendStatus("node=" + tN.toString());
				// is there a an error node?
				if (tN.nodeName == "err") {
					myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
	
				// we are expecting to get back a node with the sequence number to use
				// $node .= "<detail sequenceNumber='$sequenceNumber' />";					
				} else if (tN.nodeName == "detail") {
					myTrace("specific detail: " + tN.toString());
					this.master.sequenceNumber = parseInt(tN.attributes.sequenceNumber);
					
				// anything unexpected?
				} else {
					myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
				}
			}
			// Now go to get general stats
			this.master.getGeneralStats(this.master.callBack);
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
		
		// Purely for testing certificates - 
		if (_global.ORCHID.commandLine.sessionID!=undefined && _global.ORCHID.commandLine.sessionID!="") {
			myTrace("using special sessionID for certificate testing " + _global.ORCHID.commandLine.sessionID);
			// Since we aren't reading the database, just use this ID to force a certain certificate to be displayed.
			switch (_global.ORCHID.commandLine.sessionID) {
				case 'C2':
					totalScore=41; grammarScore=15; vocabScore=16; readingScore=12;
					break;
				case 'C1':
					totalScore=22; grammarScore=9; vocabScore=9; readingScore=6;
					break;
				case 'B2':
					totalScore=47; grammarScore=18; vocabScore=19; readingScore=12;
					break;
				case 'B1':
					totalScore=24; grammarScore=6; vocabScore=11; readingScore=9;
					break;
				case 'A2':
					totalScore=40; grammarScore=12; vocabScore=21; readingScore=9;
					break;
				case 'A1':
					totalScore=21; grammarScore=6; vocabScore=12; readingScore=5;
					break;
				default:
					totalScore = 0; grammarScore = 0;	vocabScore = 0; readingScore = 0; 
			}
		} else {
			myTrace("not using special sessionID for certificate testing");
		}
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
						'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
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
						{tag:"[requiredCoverage]", text:mustComplete},
						{tag:"[averageScore]", text:this.average},
						{tag:"[name]", text:this.certificateName},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		failCoverageGraphics.coverageStatus_txt.text = substTags(failCoverageText, substList);
		var headerText = failCoverageGraphics.header_txt.text;
		//myTrace("original text = " + headerText);
		//var substList = [{tag:"[name]", text:this.certificateName},
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		//				{tag:"[date]", text:formatDate(new Date())},
		//				{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
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
	myTrace("pass test seq=" + sequenceNumber);
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
		// For WACC mexico use a three level test. What would be a good way to do this kind of customisation?
		var numberOfLevels = 3;
		var numberOfLevels = 5;
		if (numberOfLevels==3 ) {
			myTrace("certificate with 3 levels");
			if (this.total>90) {
				var descriptor="Advanced";
			} else if (this.total>45) {
				var descriptor="Intermediate";
			} else {
				var descriptor="Elementary";
			}
		} else {		
			myTrace("certificate with 5 levels");
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
		}
		//passTestGraphics.passStatus_txt.text = "Please try " + descriptor + " (as you got " + this.total + ")";
		passTestGraphics.passStatus_txt.htmlText = "Please try <b>" + descriptor + " level</b> Clarity programs.";
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
		if (this.unitCaption.toLowerCase().indexOf("level test a")>=0) {
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
			
		} else if (this.unitCaption.toLowerCase().indexOf("level test b")>=0) {
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
			
		} else if (this.unitCaption.toLowerCase().indexOf("level test c")>=0) {
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
			// Pick all this up from literals
			//var CEFSummary = "A0 (Breakthrough): Basic user";
			var CEFLevel = _global.ORCHID.literalModelObj.getLiteral("certificateCEFLevelA0", "messages");
			//var CEFDetail = "• Understand and use familiar everyday expressions and very basic phrases<br />• Introduce him/herself and others and can ask and answer questions about personal details such as where he/she lives, people he/she knows and things he/she has.<br />• Interact in a simple way provided the other person talks slowly and clearly and is prepared to help.";
			var CEFLevelDetail = _global.ORCHID.literalModelObj.getLiteral("certificateCEFDetailA0", "messages");
			var BCLevel = "Starter";
		} else if (overallCEF=="A1") {
			var CEFLevel = _global.ORCHID.literalModelObj.getLiteral("certificateCEFLevelA1", "messages");
			var CEFLevelDetail = _global.ORCHID.literalModelObj.getLiteral("certificateCEFDetailA1", "messages");
			var BCLevel = "Elementary";
		} else if (overallCEF=="A2") {
			var CEFLevel = _global.ORCHID.literalModelObj.getLiteral("certificateCEFLevelA2", "messages");
			var CEFLevelDetail = _global.ORCHID.literalModelObj.getLiteral("certificateCEFDetailA2", "messages");
			var BCLevel = "Pre-Intermediate";
		} else if (overallCEF=="B1") {
			var CEFLevel = _global.ORCHID.literalModelObj.getLiteral("certificateCEFLevelB1", "messages");
			var CEFLevelDetail = _global.ORCHID.literalModelObj.getLiteral("certificateCEFDetailB1", "messages");
			var BCLevel = "Intermediate";
		} else if (overallCEF=="B2") {
			var CEFLevel = _global.ORCHID.literalModelObj.getLiteral("certificateCEFLevelB2", "messages");
			var CEFLevelDetail = _global.ORCHID.literalModelObj.getLiteral("certificateCEFDetailB2", "messages");
			var BCLevel = "Upper-Intermediate";
		} else if (overallCEF=="C1") {
			var CEFLevel = _global.ORCHID.literalModelObj.getLiteral("certificateCEFLevelC1", "messages");
			var CEFLevelDetail = _global.ORCHID.literalModelObj.getLiteral("certificateCEFDetailC1", "messages");
			var BCLevel = "Advanced";
		} else if (overallCEF=="C2") {
			var CEFLevel = _global.ORCHID.literalModelObj.getLiteral("certificateCEFLevelC2", "messages");
			var CEFLevelDetail = _global.ORCHID.literalModelObj.getLiteral("certificateCEFDetailC2", "messages");
			var BCLevel = "Advanced-Plus";
		}
		// Then convert the BC level from literals
		var BCLevelWord = _global.ORCHID.literalModelObj.getLiteral("certificateBCLevel-" + BCLevel, "messages")
		//var BCSummary = "";
		var BCSummary = substTags(_global.ORCHID.literalModelObj.getLiteral("certificateBCSummary", "messages"),[{tag:"[BCLevel]", text:BCLevelWord}]);
		//myTrace("BCSummary=" + BCSummary);
		//var BCDetail = ""
		var BCDetail = substTags(_global.ORCHID.literalModelObj.getLiteral("certificateBCContact", "messages"),[]);
		//myTrace("BCDetail=" + BCDetail);
		//var BCDisclaimer = ""		
		// v6.5.6.5 You need to call substTags with at least an empty array to get [newline] action.
		var BCDisclaimer = substTags(_global.ORCHID.literalModelObj.getLiteral("certificateBCDisclaimer", "messages"),[]);
		//myTrace("BCDisclaimer=" + BCDisclaimer);
		
		var CEFSummary = substTags(_global.ORCHID.literalModelObj.getLiteral("certificateCEFSummary", "messages"),[{tag:"[CEFLevel]", text:CEFLevel},
																								{tag:"[grammarCEF]", text:grammarCEF},
																								{tag:"[readingCEF]", text:readingCEF},
																								{tag:"[vocabCEF]", text:vocabCEF}]);
		//myTrace("CEFSummary=" + CEFSummary);
		var CEFDetail = substTags(_global.ORCHID.literalModelObj.getLiteral("certificateCEFDetail", "messages"),[{tag:"[CEFLevelDetail]", text:CEFLevelDetail}]);
		//myTrace("CEFLevelDetail=" + CEFLevelDetail);
		//myTrace("CEFDetail=" + CEFDetail);
		
		// Put all this onto the cert
		//var headerText = passTestGraphics.header_txt.text;
		var headerText = _global.ORCHID.literalModelObj.getLiteral("certificateHeader", "messages");
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		var substList = [{tag:"[name]", text:this.certificateName},
						{tag:"[email]", text:_global.ORCHID.user.email},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
						{tag:"[unit]", text:this.unitCaption},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		passTestGraphics.header_txt.text = substTags(headerText, substList);
						
		// v6.5.6.5 It's not a good way to do it because different accounts or the ILA test want different certificate layouts
		// even if all the above is still common.
		// So either I can split the different sections up onto the .fla (and have one of those per account)
		// or I can somehow get the layout (sort of) from literals - where I am bodging the account to be a language (eninjp)
		var certificateLayout = substTags(_global.ORCHID.literalModelObj.getLiteral("certificateLayout", "messages"),[{tag:"[BCSummary]", text:BCSummary},
																								{tag:"[BCDetail]", text:BCDetail},
																								{tag:"[CEFSummary]", text:CEFSummary},
																								{tag:"[BCDisclaimer]", text:BCDisclaimer},
																								{tag:"[CEFDetail]", text:CEFDetail}]);
		// Do an overall text that will usually be enough
		passTestGraphics.passStatus_txt.htmlText += certificateLayout;
		
		// Then special stuff for one of the BC ILA accounts. If a different cert doesn't have these fields, they will just be ignored.
		passTestGraphics.cef_txt.htmlText = CEFDetail;
		passTestGraphics.disclaimer_txt.htmlText = BCDisclaimer;

		/*
		passTestGraphics.passStatus_txt.htmlText += BCSummary + "<br/><br/>";
		passTestGraphics.passStatus_txt.htmlText += BCDetail  + "<br/><br/>";
		passTestGraphics.passStatus_txt.htmlText += CEFSummary + "<br/><br/>";
		passTestGraphics.passStatus_txt.htmlText += CEFDetail  + "<br/><br/>";
		passTestGraphics.passStatus_txt.htmlText += BCDisclaimer;
		*/
		// disclaimer				
		//passTestGraphics.passStatus_txt.htmlText += "<br>We would be grateful if you can <u><a href='http://www.zoomerang.com/Survey/survey-intro.zgi?p=WEB229HGXGXKHS' target='_blank'>click here and take a survey for us</a></u>. Thanks!";

		// v6.5 Can you pick this up from literals file?
		var footerText = _global.ORCHID.literalModelObj.getLiteral("certificateFooter", "messages");
		if (footerText==undefined || footerText=="") {
			footerText = passTestGraphics.footer_txt.text;
		}
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		var substList = [{tag:"[name]", text:this.certificateName},
						{tag:"[email]", text:_global.ORCHID.user.email},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption}];
		passTestGraphics.footer_txt.text = substTags(footerText, substList);
		
	} else {
		// v6.5.6.4 Use just one subst list so that you can put the fields in any of the text boxes
		var substList = [{tag:"[name]", text:this.certificateName},
						{tag:"[email]", text:_global.ORCHID.user.email},
						{tag:"[date]", text:formatDate(new Date())},
						{tag:"[institution]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution},
						{tag:"[unit]", text:this.unitCaption},
						{tag:"[totalDone]", text:totalDone},
						{tag:"[totalToDo]", text:totalToDo},
						{tag:"[percentComplete]", text:percentComplete},
						{tag:"[totalCorrect]", text:this.total},
						{tag:"[averageScore]", text:this.average},
						{tag:"[sequenceNumber]", text:sequenceNumber},
						{tag:"[course]", text:_global.ORCHID.course.scaffold.caption},
						{tag:"[courseShortName]", text:courseShortName}];
		
		var headerText = passTestGraphics.header_txt.text;
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		passTestGraphics.header_txt.text = substTags(headerText, substList);
						
		var passCourseText = passTestGraphics.passStatus_txt.text;
		//myTrace("original text = " + passCourseText);
		passTestGraphics.passStatus_txt.text = substTags(passCourseText, substList);
		myTrace("pass passStatus=" + passTestGraphics.passStatus_txt.text);

		// v6.5 Can you pick this up from literals file if not set in the fla?
		var footerText = passTestGraphics.footer_txt.text;
		if (footerText==undefined || footerText=="") {
			footerText = _global.ORCHID.literalModelObj.getLiteral("certificateFooter", "messages");
		}
		//var substList = [{tag:"[name]", text:_global.ORCHID.user.name},
		passTestGraphics.footer_txt.text = substTags(footerText, substList);
		myTrace("pass footer=" + passTestGraphics.footer_txt.text);
						
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
//myTrace("call check coverage from end of certificate.as");
this.checkCoverage();
