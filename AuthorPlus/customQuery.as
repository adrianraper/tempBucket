// This movie is loaded into customQueryHolder in queryNS of the queryProjector
// Let yourself refer back for common functions
this.queryNS = _parent.queryNS;
this.dbClose = _parent.dbClose;
this.dbConnect = _parent.dbConnect;
this.querySendAndLoad = _parent.querySendAndLoad;

sendCustomQuery = function(queryXML, resultXML) {
	myTrace("sendCustomQuery, queryNS.db=" + queryNS.databaseType);
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
	//myTrace("2-query for " + this.queryNS.thisQuery.method);
	if (typeof this[this.queryNS.thisQuery.method] == "function") {
		this[this.queryNS.thisQuery.method]();
	} else {
		myTrace("called projector customQuery with non-method: " + this.queryNS.thisQuery.method);
		queryNS.thisQuery.buildString += "<error>non-method</error>";
		returnQuery();
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
getGeneralStats = function() {
	//myTrace("3,getGeneralStats");
	// First find the stats for records that have a score - should just take highest if same exercise done several times
	// Actually, why not just have one SQL call to get all stats, then split by score when processing the returned rows?
	queryNS.thisQuery.fieldNames = "F_ExerciseID, MAX(F_Score) AS maxScore, COUNT(*) AS Cnt, MAX(F_ScoreCorrect) AS Total";
	var queryString = "SELECT " + queryNS.thisQuery.fieldNames + " FROM T_Score, T_Session" +
					" WHERE T_Score.F_UserID=" + queryNS.thisQuery.userID + 
					//" AND F_Score>=0 " +
					" AND T_Score.F_SessionID = T_Session.F_SessionID " +
					" AND T_Session.F_CourseID=" + queryNS.thisQuery.courseID + 
					// Using special convention that exercises with ID less than 100 are not counted for general scoring in a course.
					" AND T_Score.F_ExerciseID>100 " +
					" GROUP BY F_ExerciseID" +
					";";

	// reaction to the data - expects a string, formatted as XML
	var resultsAction = function(myResults) {
		// function for common results processing
		var processResults = function(rowObject) {
			queryNS.thisQuery.buildString += "<stats total='" + rowObject.totalCorrect + "' average='" + rowObject.avgScored + "' counted='" + rowObject.countScored + 
										"' viewed='" + rowObject.countUnScored + "' duplicatesCounted='"  + dupScored + "' duplicatesViewed='" + dupUnScored + "'/>"
			returnQuery();
		}
		if (queryNS.databaseType == "access") {
			//myTrace("in resultsAction with " + myResults);
			var myXML = new XML();
			myXML.ignoreWhite = true;
			myXML.parseXML(myResults);
			// check to see that the returned dataset is not empty
			if (myXML.childNodes[0].childNodes[0] == undefined){			
				//myTrace("no scores returned from db");
				var rowObject={totalCorrect:0, avgScored:0, countScored:0, countUnScored:0, dupScored:0, dupUnScored:0};
				processResults(rowObject);
			} else {
				// Put the nodes into an object
				var totalScore=0
				var duplicates=0
				var countScored = 0
				var countUnScored = 0
				var totalCorrect = 0
				var duplicatesCounted = 0
				var duplicatesViewed = 0
				var avgScored=0;
				var dupScored=0;
				var dupUnScored=0;
				var numScores = myXML.childNodes[0].childNodes.length;
				for (var i=0; i<numScores; i++) {
					var scoreNode = queryNS.FSPXMLtoObject(myXML.childNodes[0].childNodes[i]);
					myTrace("this score=" + scoreNode.maxScore);
					// Now split the way you add up this score based on whether it was viewed or scored
					if (Number(scoreNode.maxScore) < 0 ) {
						countUnScored++;
						duplicatesViewed+= Number(scoreNode.Cnt);
					} else {
						countScored++;
						totalScore += Number(scoreNode.maxScore);
						totalCorrect += Number(scoreNode.Total);
						duplicatesCounted += Number(scoreNode.Cnt);
					}
				}
				dupUnScored = duplicatesViewed - countUnScored;
				avgScored = totalScore / countScored;
				dupScored = duplicatesCounted - countScored;
				var rowObject = {totalCorrect:totalCorrect, avgScored:avgScored, countScored:countScored, countUnScored:countUnScored, dupScored:dupScored, dupUnScored:dupUnScored};;
				processResults(rowObject);
			}
		} else {
			if (myResults == "") {
				var rowObject={avgScored:0, countScored:0, dupScored:0, totalScore:0, totalCorrect:0};
				processResults(rowObject);
			} else {
				// Put the nodes into an object
				// Copy from above once working
				var rowObject = queryNS.MDMDelimittedtoObject(rows[0]);
				processResults(rowObject);
			}
		}
	}	
	querySendAndLoad(queryString, resultsAction, false);
}
