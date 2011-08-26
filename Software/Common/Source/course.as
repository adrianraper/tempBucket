ProgressObject = function() {
	//this.score = null;
	//this.dateStamp = null;
	//this.correct = null;
	//this.wrong = null;
	//this.skipped = null;
	this.record = new Array();
	
	// v6.3 To allow for Teacher log in, nED should be an array based on userID
	this.numExercisesDone = new Array();
	//this.numExercisesDone = 0;
	
	// v6.4.2.8 Also save everyone's average score (and I want my average scores too)
	this.averageScore = new Array();
	
	// v6.4.2 This doesn't appear to be used anywhere, I guess it is typed wrongly
	//this.numOfExercises = 0;
	this.numExercises = 0;
}
ScaffoldObject = function() { 
	this.caption = "";
	this.id = -1;
	this.action = null;
	this.unit = null;
	// v6.5.5.0 Subunits
	this.group = null;
	this.fileName = "";
	// 6.0.2.0 the default is NOT to have random but to include it in the menu
	//this.enabledFlag = Number(_global.ORCHID.enabledFlag.menuOn + _global.ORCHID.enabledFlag.randomOn + _global.ORCHID.enabledFlag.navigateOn);
	this.enabledFlag = Number(_global.ORCHID.enabledFlag.menuOn + _global.ORCHID.enabledFlag.navigateOn);
	// v6.5.5.8 Clear Pronunciation has extra menu display attributes
	this.image1 = null;
	this.image2 = null;
	this.example = null;
	this.relatedID = null;
	// v6.5.6 EditedContent might add a groupname
	this.groupName = null;
	this.progress = new ProgressObject();
}

// v6.5.4.3 Yiu, store everything from the T_HiddenContent
// v6.5.4.5. make it like the scaffold
// 6.5.4.7 Deprecated
/*
HiddenContentObject = function(){
	//this.m_nExerciseID	= objXmlNode.attributes.exerciseID;
	//this.m_nEnabledFlag	= objXmlNode.attributes.enabledFlag;
	this.unitID = null;
	this.exerciseID = null;
	this.enabledFlag = Number(_global.ORCHID.enabledFlag.menuOn + _global.ORCHID.enabledFlag.navigateOn);
}
*/
// It is now difficult to see why we have a course object that simply contains a scaffold object
// as the progress object is now fragmented Within scaffold
CourseObject = function(courseID) {
	this.scaffold = {};
	this.useQuestionBanks = false;
	// EGU - use a special place to list test scores
	this.testList = new Array();

	// v6.5.4.3 Yiu, store everything from the T_HiddenContent
	// v6.5.4.5 Not a good place as this is just for one course
	// or maybe this just refers to hiddenContent for THIS course once I have selected it!
	// Maybe it should simply be part of user
	// 6.5.4.7 Deprecated
	//this.hiddenContent = new Array();

	//this.progress = {};
	//this.currentExercise = null;
	//myTrace("made a new course object");
	//v6.3.5 Need to know the courseID now for session table. It is NOT read from menu.XML
	this.id = courseID;
	// v6.5.5.3 And the course name from the course.xml rather than from the menu.XML
	//this.name = "";
	//myTrace("courseObject.id=" + this.id);
}
// I don't think this is all a method of the course object - but maybe it is
CourseObject.prototype.loadProgress = function() {
	// read the scores for this user from a db and then merge them into the scaffold
	//myTrace("course object loadProgress for " + this.scaffold.caption);
	// 6.0.5.0 the session object doesn't exist, so look for courseName in the course/scaffold
	// Ahh, perhaps it still does!
	//var myScores = new ScoreRecordsetObject({courseName:this.scaffold.caption});
	// v6.3.5 Session uses courseID not courseName
	//myTrace("set courseName and ID in scoreRecordSet to " + _global.ORCHID.session.courseID);
	var myScores = new ScoreRecordsetObject({courseName:_global.ORCHID.session.courseName, 
											courseID:_global.ORCHID.session.courseID});
	myScores.master = this;
	myScores.onReturnCode = function(arrayLength) {
		// interleaf the records from this array into the course object
		myTrace("got " + arrayLength + " score records from the db, course id=" + this.master.id);
		//AR: why use the scaffoldObject of the courseObject and not a course level method?
		// v6.4.2.8 Add another call to get everyone's progress, so callback another method on me
		// v6.4.2.8 I am struggling with scope, I can get to loadAllProgress, but have lost real this.
		// So try to do all the inserting in one go and merge it from the sql. Yes, that is fine
		this.master.insertProgressToScaffold(this.scores, this.master.onLoadProgress);
		//this.master.insertProgressToScaffold(this.scores, this.master.loadAllProgress);
		// now that the progress records are plainly put into the scaffold, do the summary calculations
		// trigger the callback for this object once all the data is loaded
		// v6.2 Move this into the ACK process for insertProgresToScaffold
		//this.master.onLoadProgress();
	}
	//myTrace("loadProgress");
	myScores.readDB();
}
// v6.4.2.8 Also pick up the progress for everyone. Not used.
CourseObject.prototype.loadAllProgress = function() {
	var myScores = new ScoreRecordsetObject({courseName:_global.ORCHID.session.courseName, 
											courseID:_global.ORCHID.session.courseID});
	myScores.master = this;
	myScores.onReturnCode = function(arrayLength) {
		// interleaf the records from this array into the course object
		myTrace("got " + arrayLength + " all score records from the db, course id=" + this.master.id);
		// v6.4.2.8 Add another call to get everyone's progress, so callback another method on me
		myTrace("try to go to " + this.master.insertProgressToScaffold);
		myTrace("but really skip to the call back " + this.master.onLoadProgress);
		this.master.onLoadProgress();
		//this.master.insertProgressToScaffold(this.scores, this.master.onLoadProgress);
	}
	myTrace("loadAllProgress for courseID = " + this.id);
	myScores.readAllDB();
}

//load progress records from a array to the progress items in the scaffold
//the array item should look like this
//recordArray[i].itemID
//recordArray[i].score
//recordArray[i].dateStamp
//recordArray[i].correct
//recordArray[i].wrong
//recordArray[i].skipped
//recordArray[i].unit
// v6.3 Then for the "teacher" progress function, also add [i].userID
CourseObject.prototype.insertProgressToScaffold = function(recordArray, callBack) {
	// this becomes a very slow process when the user has done lots of the scaffold
	// due to some very horrible looping
	// So start by splitting it with ACK technique so you can put up a progress bar
	// and never worry about the Flash loop warning
	//myTrace("start a tlc for this.scaffold.caption=" + this.scaffold.caption);
	//this.speedStartTime = new Date().getTime();
	myTrace("insertProgressToScaffold, record array length=" + recordArray.length);
	// v6.4.2.4 Resetting progress bar proportions
	//_global.ORCHID.tlc = {timeLimit:1000, maxLoop:recordArray.length, i:0, proportion:100, startProportion:0, callback:callBack};
	_global.ORCHID.tlc = {timeLimit:1000, maxLoop:recordArray.length, i:0, 
						//proportion:80, startProportion:20, 
						callback:callBack};
	var tlc = _global.ORCHID.tlc;
	tlc.controller = _global.ORCHID.root.tlcController;
	var startProportion = tlc.controller.getPercentage();
	if (startProportion == undefined || startProportion <0) startProportion = 0;
	var remainingProportion = 100 - startProportion;
	tlc.startProportion = startProportion;
	tlc.proportion = remainingProportion;
	//myTrace("insertProgToScaff tlc.controller=" + tlc.controller + " start=" + startProportion + " of " + remainingProportion);
	/*
	if (typeof tlc.controller == "movieclip") {
		//myTrace("controller already exists as it should course.as:81");
	} else {		
		myTrace("controller doesn't exist - it should! course.as:83");
		// v6.3.4 following code should be redundant
		var myController = _root.createEmptyMovieClip("tlcController", _global.ORCHID.loadingDepth);
		myController.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + "onEnterFrame.swf");
		// v6.3.1 Pickup progress bar location from buttons swf
		if (_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar != undefined) {
			myController._x =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._x;
			myController._y =_global.ORCHID.root.buttonsHolder.ExerciseScreen.progressBar._y;
		} else {
			myController._x = myController._y = 5;
		}
		tlc.controller = myController;
	}
	*/
	//myTrace("call startEnterFrame");
	// this is the data that is the core of the loop
	tlc.recordArray = recordArray;
	tlc.scaffold = this.scaffold;
	
	// define the resumeLoop method
	tlc.resumeLoop = function(firstTime) {
		//myTrace("resumeLoop course.as:106");
		var startTime = getTimer();
		var i = this.i;
		var max = this.maxLoop;
		var timeLimit = this.timeLimit;
		while (getTimer()-startTime <= timeLimit && i<max && !firstTime) {
			//mytrace("insert record for item=" + this.recordArray[i].itemID + " testUnits=" + this.recordArray[i].testUnits);
			// v6.5.5.0 Allow single inserts to be differentiated - here we are loading from the database
			this.scaffold.insertProgressRecord(this.recordArray[i], false);
			i++;
		}
		//trace("finished this bit of time");
		if (i < max) {
			//trace("not finished loop yet");
			this.controller.incPercentage((i/max) * this.proportion); // this part of the process is x% of the time consuming bit
			//myTrace("iPR progress bar inc % by " + Number((i/max) * this.proportion));
			this.i = i;
		} else if (i >= max || max == undefined) {
			//trace("finished loop");
			this.i = max+1; // just in case this is run beyond the limit
			//myTrace("iPR progress bar set % to " + Number(this.startProportion + this.proportion));
			this.controller.setPercentage(this.proportion + this.startProportion);
			//var stopTime = new Date().getTime();
			delete this.resumeLoop;
			this.controller.stopEnterFrame();
			//myTrace("% at end of course is " + this.controller.getPercentage());
			this.callBack();
			if (this.controller.getPercentage() >= 100) {
				this.controller.setEnabled(false);
			}
		}		
	}
	//tlc.controller.setLabel("load progress");
	tlc.controller.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadScores", "labels"));
	tlc.controller.setEnabled(true);
	tlc.controller.startEnterFrame();
	tlc.resumeLoop(true);
}

// this method will read an XML object to create a scaffold for this course
CourseObject.prototype.loadScaffold = function(xmlObj) {
	// Whilst this is a fairly slow process (a couple of seconds for EGU)
	// it is done with iteration rather than a loop, so very difficult to apply
	// ACK technicque - therefore just leave it as is.
	
	//v6.3.6 To make it easy, save the APP signature from the menu
	_global.ORCHID.session.version = new versionNumber(this.version);
	myTrace("menu.xml written by APP version=" + _global.ORCHID.session.version.toString());
	
	// v6.5.4.3 Yiu, move the lines of code up - 
	// AR do you know this yet? I guess you do
	//myTrace("courseID=" + this.id);
	_global.ORCHID.session.courseID = this.id;
	this.xmlObj = xmlObj;
	// v6.5.5.7 We need to read editedContent from the db.
	this.mergeEditedContentToXML();
	// v6.5.4.5 We need to read hiddenContent from the db, so call the query and keep going when it is done.
	// v6.5.4.7 We've already got the data now, just do the merge
	//this.queryHiddenContent();
	this.mergeHiddenContentToXML();
	
	// Now you can go ahead with the rest of the processing
	this.buildScaffold();
}	
// v6.5.4.5 This function is called once the hiddenContent query has returned
CourseObject.prototype.buildScaffold = function() {
	myTrace("back to buildScaffold");
	var temp = this.xmlObj.readToStructure();
	this.scaffold = temp;
	// once the scaffold is created, count up the exercises in it
	//myTrace("now count the exercises");
	this.scaffold.numExercisesSummary();
	// quick check to set a value for any question banks
	// and store it at the course level
	this.useQuestionBanks = this.scaffold.useQuestionBanks();
	myTrace("this course has question banks = " + this.useQuestionBanks);
	// trigger the callback
	// 6.0.5.0 need to add the course name to the session object for convenience
	// v6.5.5.3 Get the course name from the course.xml rather than from the menu.XML
	//myTrace("ignore course name from menu of " + this.scaffold.caption);
	//_global.ORCHID.session.courseName = this.scaffold.caption;
	// v6.3.5 Let's also save the courseID as well

	// v6.5.4.3 Yiu, move the lines of code up
	//_global.ORCHID.session.courseID = this.id;
	
	this.onLoadScaffold();
	//var stopTime = new Date().getTime();
	//myTrace("onLoadScaffold took " + Number(stopTime - startTime)); // EGU=8625, 2828
}

// v6.5.4.5
CourseObject.prototype.mergeHiddenContentToXML= function() {
	// v6.5.4.5 Trouble is that this will not work for deeper menus (MyCanada)
	// No, the deeper menus are all in course.xml, by now you are in menu.xml. So give this a chance
	var xmlObj = this.xmlObj;
	var bAllBrotherNodesHidden:Boolean;

	// v6.5.4.7 What I need to do is test each exercise node against the hiddenContent. Will this loop do that?
	var productUID = _global.ORCHID.root.licenceHolder.licenceNS.productCode;
	var courseUID = _global.ORCHID.session.courseID;
	myTrace("go through the hidden content (" + _global.ORCHID.user.hiddenContent.length + " items) to block any exercises");
	// Might as well do a quick check to see if teh hiddenContent array is empty to skip the loop
	if ( _global.ORCHID.user.hiddenContent.length>0) {
		for (var v1 = 0; v1 < xmlObj.firstChild.childNodes.length; v1++) {
			bAllBrotherNodesHidden = true;
			nCurNodeForFirstLoop = xmlObj.firstChild.childNodes[v1];
			// v6.5.4.7 Oh dear - should we be using unitID or ID for hte unit node to identify it? RM uses unitID for the hiddenContent, not sure that is right
			//var unitUID = nCurNodeForFirstLoop.attributes["id"];
			var unitUID = nCurNodeForFirstLoop.attributes["unit"]; 
			//myTrace("check xml.caption=" + nCurNodeForFirstLoop.caption)
			for (var v2 = 0; v2 < nCurNodeForFirstLoop.childNodes.length; v2++) {
				nCurNodeForSecondLoop = nCurNodeForFirstLoop.childNodes[v2]; 
				// v6.5.4.7 Use our new recursive function (from common)
				//nTempResultOfEnabledFlag = this.getHiddenContentEnabledFlag(nCurNodeForSecondLoop.attributes["id"]);
				var exerciseUID = nCurNodeForSecondLoop.attributes["id"];
				nUID = _global.ORCHID.root.objectHolder.buildUID(productUID, courseUID, unitUID, exerciseUID);
				nTempResultOfEnabledFlag = _global.ORCHID.root.objectHolder.getEnabledFlagForUID(nUID, _global.ORCHID.user.hiddenContent);
				//myTrace("course.as.mergeHidden check UID=" + nUID + " got eF=" + nTempResultOfEnabledFlag);
				nCurNodeForSecondLoop.attributes["enabledFlag"] |= nTempResultOfEnabledFlag;
				//myTrace("check xml.caption=" + nCurNodeForSecondLoop.caption + " eF=" + nTempResultOfEnabledFlag)
				if (nCurNodeForSecondLoop.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.disabled) {
					++nExerciseDisabled;
				} else {
					//myTrace("at least one visible ex in this unit");
					bAllBrotherNodesHidden	= false;
				}
			}
	
			if (bAllBrotherNodesHidden) {
				//nCurNodeForFirstLoop.attributes["enabledFlag"] |= const_nFlagNumForDisable;
				//myTrace("ok, hide the unit");
				nCurNodeForFirstLoop.attributes["enabledFlag"] |= _global.ORCHID.enabledFlag.disabled;
			}
		}
	}
	//_global.myTrace("There are " + nExerciseDisabled + " exercises hidden.");
}

CourseObject.prototype.mergeEditedContentToXML = function(){
	var xmlObj = this.xmlObj;
	var UID = null;
	var productID = null;
	var courseID = null;
	var unitID = null;
	var exerciseID = null;
	var editedArray = _global.ORCHID.user.editedContent;
	myTrace("Do merge edited content to xml");

	for( var i in editedArray ){
		myTrace(editedArray[i]._id + " mode is " + editedArray[i]._modeflag);
		switch (editedArray[i]._modeflag){
		case "0": // Exercise.EDIT_MODE_EDITED
			UID = editedArray[i]._id;
			mappedIds = UID.split(".");
			courseID = mappedIds[1];
			myTrace("courseID is: " + courseID + " and xml attr id is :" + xmlObj.firstChild.attributes["id"]);
			if(courseID == xmlObj.firstChild.attributes["id"]){
				for (var v1 = 0; v1 < xmlObj.firstChild.childNodes.length; v1++) {
					var nCurNodeForFirstLoop = xmlObj.firstChild.childNodes[v1];
					exerciseID = mappedIds[3];
					for (var v2 = 0; v2 < nCurNodeForFirstLoop.childNodes.length; v2++) {
						nCurNodeForSecondLoop = nCurNodeForFirstLoop.childNodes[v2];
						if(exerciseID == nCurNodeForSecondLoop.attributes["id"]){
							nCurNodeForSecondLoop.attributes["fileName"] = editedArray[i]._path + exerciseID + ".xml";
							nCurNodeForSecondLoop.attributes["caption"] = editedArray[i]._caption;
							// v6.5.6 AR I also want to know the groupName so I can use it in branding
							nCurNodeForSecondLoop.attributes["groupName"] = editedArray[i]._groupName;
							var eFg = _global.ORCHID.enabledFlag.edited + _global.ORCHID.enabledFlag.menuOn + _global.ORCHID.enabledFlag.navigateOn;
							nCurNodeForSecondLoop.attributes["enabledFlag"] = eFg;
							break;
						}
					}
				} // end of for (var v1 ...
			} // end of if(courseID ...
			break;
		case "3":
		case "2": // Exercise.EDIT_MODE_INSERTDBEFORE
			UID = editedArray[i]._id;
			mappedIds = UID.split(".");
			courseID = mappedIds[1];
			var relatedExercise:XMLNode;
			var relatedUID = editedArray[i]._relatedid;
			var relatedMappedIds = relatedUID.split(".");
			var relatedCourseID = relatedMappedIds[1];
			var isGet = false;
			//myTrace("2 related course is " + courseID);
			if(relatedCourseID == xmlObj.firstChild.attributes["id"]){
				//myTrace("2 unit is " + unitID);
				for (var v1 = 0; v1 < xmlObj.firstChild.childNodes.length; v1++) {
					var nCurNodeForFirstLoop = xmlObj.firstChild.childNodes[v1];
					//myTrace("2 exericse is " + exerciseID);
					exerciseID = mappedIds[3];
					relatedexerciseID = relatedMappedIds[3];
					for (var v2 = 0; v2 < nCurNodeForFirstLoop.childNodes.length; v2++) {
						var nCurNodeForSecondLoop = nCurNodeForFirstLoop.childNodes[v2];
						if(relatedexerciseID == nCurNodeForSecondLoop.attributes["id"]){
							if(editedArray[i]._modeflag == "3"){
								relatedExercise = nCurNodeForFirstLoop.childNodes[v2 + 1];
							}else{
								relatedExercise = nCurNodeForSecondLoop;
								myTrace("2 related exercise is " + relatedExercise.toString());
							}
							isGet = true;
							break;
						}
					}
					if(isGet){
						var fName = editedArray[i]._path + exerciseID + ".xml";
						var eFg = _global.ORCHID.enabledFlag.edited + _global.ORCHID.enabledFlag.menuOn + _global.ORCHID.enabledFlag.navigateOn;
						var xmlStr = '<item ';
						xmlStr += 'unit="' + relatedMappedIds[2] + '" ';
						xmlStr += 'id="' + exerciseID + '" ';
						xmlStr += 'exerciseID="' + exerciseID + '" ';
						xmlStr += 'caption="' + escape(editedArray[i]._caption) + '" ';
						// v6.5.6 AR I also want to know the groupName so I can use it in branding
						xmlStr += 'groupName="' + escape(editedArray[i]._groupName) + '" ';
						xmlStr += 'fileName="' + fName + '" ';
						xmlStr += 'enabledFlag="' + eFg + '" ';
						xmlStr += '/>';
						myTrace("new XML node is : " + xmlStr);
						var newExercise = new XML(xmlStr);
						if(relatedExercise <> null){
							// It must use child node for inserting.
							//myTrace("nCurNodeForFirstLoop is " + nCurNodeForFirstLoop.toString());
							nCurNodeForFirstLoop.insertBefore(newExercise.firstChild, relatedExercise);
						}else{
							nCurNodeForFirstLoop.appendChild(newExercise.firstChild);
						}
						break;
					}
				} // end of for (var v1 ...
			} // end of if(courseID == ...
			break;
		case "5": // Exericse.EDIT_MODE_MOVEDAFTER
		case "4": // Exericse.EDIT_MODE_MOVEDBEFORE
			UID = editedArray[i]._id;
			mappedIds = UID.split(".");
			courseID = mappedIds[1];
			var relatedExercise:XMLNode;
			var movedExercise:XMLNode;
			var isGetMEx = false;
			var isGetDEx = false;
			myTrace("courseID is: " + courseID + " and xml attr id is :" + xmlObj.firstChild.attributes["id"]);
			// v6.5.5.9 if the exercise is a new one, its course id is not same with the original one.
			// so we can't compare the courseID
			for (var v1 = 0; v1 < xmlObj.firstChild.childNodes.length; v1++) {
				var nCurNodeForFirstLoop = xmlObj.firstChild.childNodes[v1];
				exerciseID = mappedIds[3];
				for (var v2 = 0; v2 < nCurNodeForFirstLoop.childNodes.length; v2++) {
					var nCurNodeForSecondLoop = nCurNodeForFirstLoop.childNodes[v2];
					if(exerciseID == nCurNodeForSecondLoop.attributes["id"]){
						movedExercise = nCurNodeForSecondLoop;
						nCurNodeForSecondLoop.removeNode();
						isGetMEx = true;
						break;
					}
				}
				if(isGetMEx){
					break;
				}
			}
			
			var relatedUID = editedArray[i]._relatedid;
			var relatedMappedIds = relatedUID.split(".");
			var relatedCourseID = relatedMappedIds[1];
			if(relatedCourseID == xmlObj.firstChild.attributes["id"]){
				for (var v1 = 0; v1 < xmlObj.firstChild.childNodes.length; v1++) {
					var nCurNodeForFirstLoop = xmlObj.firstChild.childNodes[v1];
					var relatedexerciseID = relatedMappedIds[3];
					for (var v2 = 0; v2 < nCurNodeForFirstLoop.childNodes.length; v2++) {
						var nCurNodeForSecondLoop = nCurNodeForFirstLoop.childNodes[v2];
						if(relatedexerciseID == nCurNodeForSecondLoop.attributes["id"]){
							if(editedArray[i]._modeflag == "5"){
								relatedExercise = nCurNodeForFirstLoop.childNodes[v2 + 1];								
							}else{
								relatedExercise = nCurNodeForSecondLoop;
							}
							isGetDEx = true;
							break;
						}
					}
					if(isGetDEx){
						movedExercise.attributes["unit"] = relatedMappedIds[2];
						//myTrace("moved exerise is : " + movedExercise.toString());
						if(relatedExercise <> null){
							nCurNodeForFirstLoop.insertBefore(movedExercise, relatedExercise);
						}else{
							nCurNodeForFirstLoop.appendChild(movedExercise);
						}
						break;
					}
				} // end of for (var v1 ...
			} // end of if(courseID == ...
			break;
		}
	}
	this.xmlObj.stripWhite(full);
}

//read the menu XML to scaffold structure
XMLNode.prototype.readToStructure = function() {
	//scaffold = {caption: caption, id: id, action: xmlArray};
	//myTrace("scaffold.readToStructure for " + this.firstChild.toString());
	scaffold = new ScaffoldObject();
	// v6.5.4.5 This is the whole menu.xml and the top level node doesn't have most of this stuff! Never mind
	scaffold.caption = changeFakeHTMLTags(this.firstChild.attributes["caption"]);
	//v6.4.1.4 See comments about 'e' matching and APP versions. Now strip it here if it exists.
	var thisID = this.firstChild.attributes["id"];
	if (thisID.substr(0,1) == "e") {
		thisID = thisID.substr(1)
	}
	scaffold.id = thisID;
	scaffold.unit = this.firstChild.attributes["unit"];
	// v6.4.1 Allow filename rather than action to be used
	//v6.4.2.1 All attributes might have been escaped
	//scaffold.fileName = this.firstChild.attributes["fileName"];
	scaffold.fileName = unescape(this.firstChild.attributes["fileName"]);
	// v6.3.4 for testing, add in testUnits
	// v6.4.3 But don't limit it to special units, use it for 'test' exercises as well
	//if (scaffold.unit < 0) scaffold.testUnits = this.firstChild.attributes["testUnits"];
	scaffold.testUnits = this.firstChild.attributes["testUnits"];
	// if the enabledFlag is not set, leave it at the default
	var enabledFlag = this.firstChild.attributes["enabledFlag"];
	if (enabledFlag != undefined) {
		scaffold.enabledFlag = Number(enabledFlag);
	}
	//trace("setting the enabled flag=" + scaffold.enabledFlag);
	
	scaffold.action = this.firstChild.readToArray();
	return scaffold;
}

// this is used as XML cannot have CDATA in attributes yet I want simple HTML tags in the caption
changeFakeHTMLTags = function(caption) {
	//v6.4.2.1 Also unescape characters
	var build = unescape(caption);
	//myTrace("caption is " + caption + ", escaped=" + build);
	// there must be a nicer way to doing many find and replace than this!
	build = findReplace(build, "[b]", "<b>");
	build = findReplace(build, "[/b]", "</b>");
	build = findReplace(build, "[i]", "<i>");
	// v6.2 CUP kind of specific!!
	// Mind you, not much point doing this as colour are overwritten by the rollOverColor in menu
	// after they get put in. But it does show up in other parts of the program.
	//build = findReplace(build, "[#00719C]", "<font color='#00719C'>");
	//build = findReplace(build, "[/#]", "</font>");
	build = findReplace(build, "[t]", "<tab>");
	build = findReplace(build, "[/i]", "</i>");
	build = findReplace(build, "[u]", "<u>");
	build = findReplace(build, "[/u]", "</u>");
	//trace("changed the caption to " + build);
	return build;
}	

// read exericse xml to scaffold object.
XMLNode.prototype.readToArray = function() {
	var xmlArray = new Array();
	var currnode = this;
	for(var i = 0; i < currnode.childNodes.length; i++) {
		// v6.4.3: If there is a filename, this is an exercise, otherwise it is a unit
		if (currnode.childNodes[i].attributes["fileName"] != null && currnode.childNodes[i].attributes["fileName"] != "") {
			var exerciseItem = new ScaffoldObject();
			exerciseItem.caption = changeFakeHTMLTags(currnode.childNodes[i].attributes["caption"]);
			exerciseItem.id = currnode.childNodes[i].attributes["id"];
			// v6.4.3 Just to tidy up, drop the action attribute and simply say that if there is a filename, this is an exercise, otherwise it is a unit
			exerciseItem.action = "exercise";
			//v6.4.2.1 All attributes might have been escaped
			exerciseItem.fileName = unescape(currnode.childNodes[i].attributes["fileName"]);
			exerciseItem.unit = unescape(currnode.childNodes[i].attributes["unit"]);
			// v6.3.4 for testing, add in testUnits
			// v6.4.3 But don't limit it to special units, use it for 'test' exercises as well
			//if (temp1.unit < 0) temp1.testUnits = currnode.childNodes[i].attributes["testUnits"];
			exerciseItem.testUnits = currnode.childNodes[i].attributes["testUnits"];
			// v6.5.5.8 Clear Pronunciation has extra attributes in menu.xml for displaying stuff on the menus.
			exerciseItem.example = currnode.childNodes[i].attributes["example"];
			// v6.5.5.8 Clear Pronunciation also allows exercises to have relatedID for bringing in different files
			exerciseItem.relatedID = currnode.childNodes[i].attributes["relatedID"];
			var enabledFlag = currnode.childNodes[i].attributes["enabledFlag"];
			// v6.5.5.0 Allow subunits that can share stuff, like a timer. Why do it differently?
			exerciseItem.group = currnode.childNodes[i].attributes["group"];
			if (enabledFlag != undefined) {
				exerciseItem.enabledFlag = Number(enabledFlag);
			}
			// v6.5.6 We might have added new attributes to the XML for edited exercises
			//myTrace(exerciseItem.caption + " from group " + currnode.childNodes[i].attributes["groupName"]);
			if (currnode.childNodes[i].attributes["groupName"] != undefined) {
				myTrace("adding ex with groupName=" + unescape(currnode.childNodes[i].attributes["groupName"]));
				exerciseItem.groupName = unescape(currnode.childNodes[i].attributes["groupName"]);
			}
			xmlArray.push(exerciseItem);
		} else {
			var unitItem = new ScaffoldObject();
			//v6.4.2.1 All attributes might have been escaped
			unitItem.alt = unescape(currnode.childNodes[i].attributes["alt"]);
			unitItem.caption = changeFakeHTMLTags(currnode.childNodes[i].attributes["caption"]);
			//unitItem.id = currnode.childNodes[i].attributes["id"].toString();
			unitItem.id = currnode.childNodes[i].attributes["id"];
			unitItem.unit = unescape(currnode.childNodes[i].attributes["unit"]);
			unitItem.fileName = unescape(currnode.childNodes[i].attributes["fileName"]);
			unitItem.testUnits = currnode.childNodes[i].attributes["testUnits"];
			unitItem.action = currnode.childNodes[i].readToArray();
			
			// v6.5.5.8 Clear Pronunciation has extra attributes in menu.xml for displaying stuff on the menus.
			unitItem.image1 = currnode.childNodes[i].attributes["image1"];
			unitItem.image2 = currnode.childNodes[i].attributes["image2"];
			
			// v6.5.5.6 Should this be listed here too? Seems not to matter. Allow subunits that can share stuff, like a timer
			var enabledFlag = currnode.childNodes[i].attributes["enabledFlag"];
			if (enabledFlag != undefined) {
				unitItem.enabledFlag = Number(enabledFlag);
			}
			xmlArray.push(unitItem);
		}
	}
	return xmlArray;
}

//get root (main menu) items
XMLNode.prototype.getRootItems = function() {
	// this might not be used??
	var items;
	items = new Array();
	for(var i = 0; i < this.childNodes.length; i++) {
		if(this.childNodes[i].nodeName == "item") {
			items.push( { caption: changeFakeHTMLTags(this.childNodes[i].attributes["caption"]),
							//v6.4.2.1 All attributes might have been escaped
							id: this.childNodes[i].attributes["id"],
							picture: unescape(this.childNodes[i].attributes["picture"]),
							action: this.childNodes[i].attributes["action"],
							fileName: unescape(this.childNodes[i].attributes["fileName"]),
							x: this.childNodes[i].attributes["x"],
							y: this.childNodes[i].attributes["y"],
							width: this.childNodes[i].attributes["width"],
							height: this.childNodes[i].attributes["height"]} );
		}
	}
	return items;
}

//function used by getMenuItemByID
XMLNode.prototype.getItemNodeByID = function(id) {
	var returnnode;
	if(this.nodeName == "item" && this.attributes["id"] == id) {
		return this;
	} else if(this.hasChildNodes()) {
		for(var i = 0; i < this.childNodes.length; i++) {
			returnnode = this.childNodes[i].getItemNodeByID(id);
			if(returnnode != null) {
				return returnnode;
			}
		}
	} else {
		return null;
	}
}

//return an array of menu items for displaying menu
XMLNode.prototype.getMenuItemByID = function(id) {
	var returnnode;
	var items;
	returnnode = this.getItemNodeByID(id);
	if(returnnode.hasChildNodes()) {
		items = new Array();
		for(var i = 0; i < returnnode.childNodes.length; i++) {
			//trace("in getMenuItemByID on loop " + i );
			if(returnnode.childNodes[i].nodeName == "item" && ((returnnode.childNodes[i].attributes["enabledFlag"] & _global.ORCHID.enabledflag.menuOn) || returnnode.childNodes[i].attributes["enabledFlag"] == null)) {
				items.push( { caption: changeFakeHTMLTags(returnnode.childNodes[i].attributes["caption"]),
								//v6.4.2.1 All attributes might have been escaped
								id: returnnode.childNodes[i].attributes["id"],
								unit: returnnode.childNodes[i].attributes["unit"],
								picture: unescape(returnnode.childNodes[i].attributes["picture"]),
								action: returnnode.childNodes[i].attributes["action"],
								fileName: unescape(returnnode.childNodes[i].attributes["fileName"]),
								alt: unescape(returnnode.childNodes[i].attributes["alt"]),
								x: returnnode.childNodes[i].attributes["x"],
								y: returnnode.childNodes[i].attributes["y"],
								width: returnnode.childNodes[i].attributes["width"],
								height: returnnode.childNodes[i].attributes["height"],
								enabledFlag: returnnode.childNodes[i].attributes["enabledFlag"],
								// v6.5.5.8 Clear Pronunciation has extra details
								example: returnnode.childNodes[i].attributes["example"],
								relatedID: returnnode.childNodes[i].attributes["relatedID"],
								captionPosition: returnnode.childNodes[i].attributes["captionPosition"]} );
			}
		}
		return items;
	} else {
		return null;
	}
}

//return the item object of input id
ScaffoldObject.prototype.getObjectByID = function(itemID) {
	var returnstr;
	if(this.id == itemID) {
		//myTrace("scaffold, matched " + itemID);
		return this;
	//} else if(this.action.toString().subString(0, 15) == "[object Object]") {
	} else if(typeof this.action == "object") {
		for(var i = 0; i < this.action.length; i++) {
			returnstr = this.action[i].getObjectByID(itemID);
			if(returnstr != null) {
				return returnstr;
			}
		}
	} else {
		return null;
	}
}

// v6.3.4 Used to get unit captions for random exercises
//return the item object according to the unitID
ScaffoldObject.prototype.getObjectByUnitID = function(unitID) {
	var returnstr;
	if(this.unit == unitID && (typeof this.action == "object")) {
		return this;
	} else if(typeof this.action == "object") {
		for(var i = 0; i < this.action.length; i++) {
			returnstr = this.action[i].getObjectByUnitID(unitID);
			if(returnstr != null) {
				return returnstr;
			}
		}
	} else {
		return null;
	}
}

//return the item object according to the input exerciseID (action)
//Note: this should never be used now that exerciseID has been replaced by itemID in progress
ScaffoldObject.prototype.getObjectByExerciseID = function(itemID) {
	trace("unexpectedly in getObjectByExerciseID");
	var returnstr;
	if(this.id == itemID) {
		return this;
	} else if(typeof this.action == "object") {
		for(var i = 0; i < this.action.length; i++) {
			returnstr = this.action[i].getObjectByExerciseID(itemID);
			if(returnstr != null) {
				return returnstr;
			}
		}
	} else {
		return null;
	}
}

//return an array containing information of items under item of input id
ScaffoldObject.prototype.getItemsByID = function(id) {
	//trace("getItemsByID " + id);
	var tempaction;
	items = new Array();
	var struct = this.getObjectByID(id);
	//trace("struct is " + struct);
	//if(struct.action.toString().subString(0, 15) == "[object Object]") {
	if(typeof struct.action == "object") {
		//trace("action is object");
		for(var i = 0; i < struct.action.length; i++) {
			//trace("for loop");
			//if(struct.action[i].action.toString().subString(0, 15) == "[object Object]") {
			if(typeof struct.action[i].action == "object") {
				tempaction = null;

			} else {
				tempaction = struct.action[i].action;
			}
			//trace("push");
			//myTrace("group=" + struct.action[i].groupName);
			items.push( { caption: changeFakeHTMLTags(struct.action[i].caption),
							id: struct.action[i].id,
							action: tempaction,
							unit: struct.action[i].unit,
							testUnits: struct.action[i].testUnits,
							enabledFlag: struct.action[i].enabledFlag,
							fileName: struct.action[i].fileName,
							// v6.5.5.6 Need to add group in here
							group: struct.action[i].group,
							// v6.5.6 And groupName too?
							//groupName: struct.action[i].groupName,
							score: struct.action[i].progress.record[0].score,
							dateStamp: struct.action[i].progress.record[0].dateStamp,
							correct: struct.action[i].progress.record[0].correct,
							wrong: struct.action[i].progress.record[0].wrong,
							skipped: struct.action[i].progress.record[0].skipped,
							numExercisesDone: struct.action[i].progress.numExercisesDone,
							numExercises: struct.action[i].progress.numExercises } )
		}
		return items;
	} else {
		return null;
	}
}

//return a array containing all item's id and action in proper sequence
//if the action of the item does not exist, the action in the array will be set as null
ScaffoldObject.prototype.getItemList = function() {
	var itemList = new Array();
	var returnlist;
	//if(!(this.action.toString().subString(0, 15) == "[object Object]")) {
	if(!(typeof this.action == "object")) {
		// v6.5.5.0 Add in groups (subunits) - and why no caption??
		itemList.push( {id: this.id, action: this.action, enabledFlag: this.enabledFlag, unit: this.unit, group: this.group, caption: this.caption, fileName:this.fileName} );
	} else {
		// v6.5.5.0 Why no caption?
		itemList.push( {id: this.id, action: null, enabledFlag: this.enabledFlag, unit: this.unit, fileName:this.fileName} );
		for(var i = 0; i < this.action.length; i++) {
			returnlist = this.action[i].getItemList();
			if(returnlist.length > 0) {
				itemList = itemList.concat(returnlist);
			}
		}
	}
	return itemList;
}

// find the captions of all parents of this item
// return an array of each parent caption ["Present and Past","Present Simple (I do)","Exercise 2"]
// if the itemID is invalid, a array of zero length is returned
ScaffoldObject.prototype.getParentCaptions = function(itemID) {
	//trace("get captions for itemID=" + itemID);
	// cope with tests that are not in the scaffold
	if (itemID == -1) {
		return [_global.ORCHID.LoadedExercises[0].name];
		//return ["From unit(s): benchmark"];
	}
	var rtnArray;
	var tempArray;
	
	rtnArray = new Array();
	if(typeof this.action == "object") {
		for(var i = 0; i < this.action.length; i++) {
			if(this.action[i].id == itemID) {
				rtnArray.push(this.caption);
				rtnArray.push(this.action[i].caption);
				return rtnArray;
			}
			tempArray = this.action[i].getParentCaptions(itemID);
			if(tempArray.length != 0) {
				rtnArray.push(this.caption);
				rtnArray = rtnArray.concat(tempArray);
				return rtnArray;
			}
		}
	}
	return rtnArray;
}

//return the action (exercise id) of next item that has a action attribute
//AR changed to return an item object, not just the action
//if the last exercise is reached, return the first exercise.
//if the next exercise cannot be found, return the first exercise.
//if there is no exercise in the scaffold, return -1.
//Note: we need to agree what a failed function call returns, -1 is too close to 'true'
// it could be undefined. 
// v6.3.3 OK, lets run with the undefined idea
// v6.5.5 Content paths.
// There are some items that are actually conditional navigators. Put code to pick them up here?
ScaffoldObject.prototype.getNextItemID = function(itemID) {
	var itemList = this.getItemList();
	found = false;
	for(var i = 0; i < itemList.length; i++) {
		if(itemID == itemList[i].id) {
			found = true;
			var index = i;
			break;
		}
	}
	myTrace("next item based on unit " + itemList[index].unit);
	//Note: you need to use "if(_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag)"
	// to see if the proposed item is allowed to be used for navigation
	if(found) {
		// v6.5.5.5 New ef for exiting after a particular exercise
		if (_global.ORCHID.enabledFlag.exitAfter & itemList[i].enabledFlag) {
			myTrace("getNextItemID sees that this exercise is exitAfter, so nothing to do.");
			return undefined;
		}
		// v6.5.6.4 If you have done direct start to an exercise, you never want to go on
		if (_global.ORCHID.commandLine.startingPoint!=undefined && _global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0) {
			myTrace("getNextItemID sees that this was a directStart exercise, so nothing to go on to.");
			return undefined;
		}
		// we only want to link within a unit
		var thisUnit = itemList[index].unit;
		//trace("nav: next must be in unit=" + thisUnit);
		for(var i = index + 1; i < itemList.length; i++) {
			// since the items in a unit will be held together, break if you leave the unit
			// EGU
			// (but ignore any item that doesn't have an action as it is not an exercise)
			//trace("nav: index=" + i + " unit=" + itemList[i].unit);
			if (itemList[i].unit != thisUnit && itemList[i].unit != undefined) {
				return undefined;
				break;
			}
			// AM: if the action of the item does not exist, the action in itemList is set as null instead of -1
			// v6.4.2.6 AR also stop the navigation if the exercise is disabled
			//if(itemList[i].action <> null && (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag))
			if(itemList[i].action <> null && (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag)
									&& !(_global.ORCHID.enabledFlag.disabled & itemList[i].enabledFlag))
				//return itemList[i].action;
				return itemList[i];
		}
		// You don't want to search beyond the end of the menu
		//for(var i = 0; i < itemList.length; i++) {
		//	if(itemList[i].action <> null && (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag))
		//		//return itemList[i].action;
		//		return itemList[i];
		//}
	}
	// You don't want to search beyond the end of the menu
	//for(var i = 0; i < itemList.length; i++) {
	//	if(itemList[i].action <> null && (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag))
	//		//return itemList[i].action;
	//		return itemList[i];
	//}
	return undefined;
}

//return the action (exercise id) of previous item that has a action attribute
//if the first exercise is reached, return the last exercise.
//if the previous exercise cannot be found, return the first exercise.
//if there is no exercise in the scaffold, return -1.
ScaffoldObject.prototype.getPreviousItemID = function(itemID) {
	var itemList = this.getItemList();
	found = false;
	//Note: you need to use (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag)
	// to see if the proposed item is allowed to be used for navigation
	for(var i = 0; i < itemList.length; i++) {
		if(itemID == itemList[i].id) {
			found = true;
			var index = i;
			break;
		}
	}
	if(found) {
		// v6.5.6.4 If you have done direct start to an exercise, you never want to go back
		if (_global.ORCHID.commandLine.startingPoint!=undefined && _global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0) {
			myTrace("getPreviousItemID sees that this was a directStart exercise, so nothing to go on to.");
			return undefined; 
		}
		// we only want to link within a unit
		var thisUnit = itemList[index].unit;
		for(var i = index - 1; i > -1; i--) {
			// since the items in a unit will be held together, break if you leave the unit
			// EGU
			//if (itemList[i].unit != thisUnit) {
			if (itemList[i].unit != thisUnit && itemList[i].unit != undefined) {
				return undefined;
				break;
			}
			// AM: if the action of the item does not exist, the action in itemList is set as null instead of -1
			// v6.4.2.6 AR also stop the navigation if the exercise is disabled
			//if(itemList[i].action <> null && (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag))
			if(itemList[i].action <> null && (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag)
									&& !(_global.ORCHID.enabledFlag.disabled & itemList[i].enabledFlag))
				return itemList[i];
			//for(var i = itemList.length - 1; i > -1; i--) {
			//	if(itemList[i].action <> null && (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag))
			//		return itemList[i];
			//}
		}
		//for(var i = 0; i < itemList.length; i++) {
		//	if(itemList[i].action <> null && (_global.ORCHID.enabledFlag.navigateOn & itemList[i].enabledFlag))
		//		return itemList[i];
		//}
	}
	return undefined;
}

//return a array containing the items for each exercise [(action) exercise id] under an item
ScaffoldObject.prototype.getItemExercises = function(id) {
	var item = this.getObjectByID(id);
	var IDList = new Array();
	//if(!(item.action.toString().subString(0, 15) == "[object Object]")) {
	if(!(typeof item.action == "object")) {
		IDList.push(item); // AR try returning whole item object not just .action);
	} else {
		for(var i = 0; i < item.action.length; i++) {
			returnlist = item.action[i].getItemExercises(item.action[i].id);
			if(returnlist.length > 0) {
				IDList = IDList.concat(returnlist);
			}
		}
	}
	return IDList;
}
//insert a progress record from into the scaffold for the appropriate item
//the passed record should look like this
//record.itemID
//record.unit - added for v6.3
//record.score
//record.dateStamp
//record.correct
//record.wrong
//record.skipped
// it returns -1 for failure, 0 for success and exercise already done, 1 for success and new exercise
// v6.2 This does seem to be called rather a lot of times at the beginning! I think it is in a couple of large loops.
// v6.5.5.0 Allow single inserts to be differentiated
//ScaffoldObject.prototype.insertProgressRecord = function(record) {
ScaffoldObject.prototype.insertProgressRecord = function(record, singleInsert) {

	// v6.3 First of all, do a check on the unit to avoid going down the wrong branches
	// v6.3.4 But don't get rid of tests (unitID = -1)
	if (this.unit != undefined && this.unit != record.unit && record.unit>0) {
		//myTrace("for record " + record.itemID + ", " + record.unit + " don't check branch " + this.unit);
		return -1;
	}

	// records held in the database should NOT have "e" held in them (early LSO based ones EGU did)
	// and EGU does not have "e" in the course XML which it should.
	// v6.3.6 remove all worries about 'e' and 'u'. From now on, the XML and database will be the same.
	// However, what about existing data where the XML has 'e' and the database doesn't?
	// We will start with a version number in the menu.XML, and base it on that.
	// For a start, lets ignore old data from the db that did have the 'e'. So we can simply read the db as is.
	// So take out these three lines.
	//if (record.itemID.substr(0,1) == "e") {
	//	record.itemID = record.itemID.substr(1);
	//}
	result = -1;
	//myTrace("inserting progress record id=" + record.itemID);
	// Here you have to compare with the "e" added in as the db holds exerciseID (no "e") and we are using
	// itemID from the exerciseXML
	//v6.3.6 Old xml used 'e', new does not.	
	// complication is that the xml from the db no longer adds in 'e'. But it will still be there if this is

	// v6.4.1.4 Bigger problem as APP does not update all the itemID to remove 'e', yet it sets version number
	// So I can fudge it in APO by dropping the 'e' when I am building the scaffold.
	// This means that when we upgrade a db, we can simply drop the 'e' as well in the itemID
	// column and it should all match up (it is now impossible for the db to hold 'e' in the itemID as it is bigint)
	if (_global.ORCHID.session.version.atLeast("6.4")) {
		// simply match like against like
		var matchItemID = record.itemID;
	} else {
		// v6.3 CUP did not have "e" and "u" in the course.xml file, so treat it differently
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			var matchItemID = record.itemID;
		} else {
			// The 'e' might already be there... (from an exercise you have just done)
			if (record.itemID.substr(0,1) == "e") {
				var matchItemID = record.itemID;
			} else {
				// or not... (from an record read from the db)
				var matchItemID = "e" + record.itemID;
			}
		}
	}
	
	//myTrace("for scaffold item=" + this.id + " and unit=" + this.unit + " check against record unit=" + record.unit + " and item=" + matchItemID);
	// get out if this record is not for a valid item
	if (record.itemID == "" | record.itemID == undefined ) {
		myTrace("bad progress record");
		return -1;
	// v 6.3.4 Old way of doing it (if ever!)
	// special exercise (like test) use itemID=0 and are treated differently
	//} else if (record.itemID == 0) {
	//	this.progress.record.push( { caption: "test from units x, x...", score: record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped ,duration: record.duration} );
	//	// v6.3 IF this is used, it needs to have nED as an array
	//	if (_global.ORCHID.user.teacher) {
	//		var thisUser = record.userID;
	//	} else {
	//		var thisUser = 0;
	//	}
	//	this.progress.numExercisesDone[thisUser]++;
	//	return 1;
		
	// EGU tests actually have item id made of lots of item IDs, comma separated
	// EGU - but there is no place in the scaffold to insert these progress records to!
	// so add them to a special item
	// v6.3.4 Use a new field for test unit IDs
	//} else if (record.itemID.indexOf("[") >=0) {
	} else if (record.unit < 0) {
		myTrace("inserting a test progress record for " + record.testUnits);
		// NOTE: this global list does not allow for teacher results in network version
		var testList = _global.ORCHID.course.testList;
		//var newLength = testList.push( { itemID:record.itemID, score: record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped, duration:record.duration } );
		//var newLength = testList.push( { itemID:record.itemID, testUnits:record.testUnits, score:record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped, duration:record.duration } );
		//v6.3.5 AGU add userID to try and allow teachers' to see proper test results
		var newLength = testList.push( {userID:record.userID, itemID:record.itemID, testUnits:record.testUnits, score:record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped, duration:record.duration } );
		//trace("added another so newLength=" + newLength);
		return 1;
	// is this scaffold item the one we are looking for?
	} else if (this.id == matchItemID) {
		//this.progress.addRecord(record.score, record.dateStamp, record.correct, record.wrong, record.skipped);
		// v6.3 If this is a teacher login, save the userName as well
		// v6.4.2.8 Would be based on userType if we were using that.
		//if (_global.ORCHID.user.teacher) {
		//if (_global.ORCHID.user.userType>0) {
		//	//myTrace("as teacher:save ID=" + record.userID + " for item=" + record.itemID);
		//	//myTrace("teacher:record id=" + this.ID + " testUnits=" + record.testUnits);
		//	this.progress.record.push( { userID: record.userID, score: record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped, duration:record.duration } );
		//	//var thisUser = record.userID;
		//} else {
			// v6.4.3 Add testUnits for 'test' exercises - this will stop progress displaying the score
			//myTrace("progress record id=" + this.ID + " testUnits=" + record.testUnits);
			//this.progress.record.push( { score: record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped, duration:record.duration, testUnits:record.testUnits } );
		// v6.4.2.8 Two types of score record, one has details and is for the individual user, the other
		// has averages and is for everyone. I only want to save the individual ones in the record array. The others are just summarised.
		// v6.5.5.0 When building the scaffold after reading the db, I simply add records in order so that the most recent is at [0]
		// But when I am adding the record this puts it at the end, but I want it at the top as well really.
		// I don't want to do too much checking against existing records dateStamps as this is critical function for speed.
		// Can I pass a 'singleInsert' field that only comes from writeScore?
		if (record.dateStamp <> undefined) {
			//myTrace("insert record for " + this.caption + " userID=" + record.userID + " date=" + record.dateStamp);
			//myTrace("detail record, score=" + record.score);
			if (singleInsert) {
				//myTrace("this record added at the beginning");
				this.progress.record.unshift( { userID: record.userID, score: record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped, duration:record.duration, testUnits:record.testUnits } );
			} else {
				this.progress.record.push( { userID: record.userID, score: record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped, duration:record.duration, testUnits:record.testUnits } );
			}
			//this.progress.record.push( { score: record.score, dateStamp: record.dateStamp, correct: record.correct, wrong: record.wrong, skipped: record.skipped, duration:record.duration, testUnits:record.testUnits } );
			//var thisUser = 0;
		}
		//}
		// for teacher login, nED has to be user based
		// for non-teacher login, use nED(0)
		//myTrace("for exercise " + this.caption + " set nED[" + thisUser + "]=1");
		// v6.4.2.8 If this is my record, put it into nED[0]. If it is someone else's (in my group), put it in [1], otherwise put it in [2]
		// (no need to distinguish between other userID)
		// v6.4.2.8 Is this a summary record or an individual one? I could also repeat - if (record.dateStamp <> undefined) {
		//myTrace(this.caption + " record.userID=" + record.userID + " me=" + _global.ORCHID.user.userID); 
		if (_global.ORCHID.user.userID == record.userID) {
		//if (record.count == undefined) {
			//myTrace("add for me as record.userID=" + record.userID);
			var thisUser = 0;
			if (this.progress.numExercisesDone[thisUser] != 1) {
				this.progress.numExercisesDone[thisUser] = 1; // this does not accumulate as you are at the exercise level
				return 1;
			} else {
				// this exercise has already been done before, so doing it again does not accumulate nED
				return 0;
			}
		} else if (false) {
			// I don't know how to determine if this record came from my group yet
			var thisUser = 1;
		} else {
			//myTrace("add for everyone as record.userID=" + record.userID);
			var thisUser = 2;
		}
		// v6.4.2.8 Do summarising as this is not a detail record. Yes it is! Well, it is an everyone record then.
		// But since I have the special summariseEveryone function, why do this here? Oh, that relies on this!
		//myTrace("summarise " + this.caption + "["+thisUser+ "] count=" + record.count + " average=" + record.score);
		// Coming back from CE.com SQLServer I have a lot of empty fields in .count. In which case, assume count=1
		// You simply won't have a record if the count was supposed to be zero. Then work out why.
		if (isNaN(record.count) || (record.count<=0)) {
			record.count=1;
		}
		this.progress.numExercisesDone[thisUser] = record.count;
		this.progress.averageScore[thisUser] = record.score;
		// We do want to accumulate nED, I think
		return record.count;
		
		// return true;
	// otherwise, dig deeper to try and find the right scaffold item
	} else if (typeof this.action == "object") {
		//myTrace("dig deeper");
		for (var j = 0; j < this.action.length; j++) {
			// v6.5.5.0 Allow single inserts to be differentiated
			//result = this.action[j].insertProgressRecord(record);
			result = this.action[j].insertProgressRecord(record, singleInsert);
			// if this call was successful, stop the recursion
			if (result >= 0) {
				// increment the exercises done in this branch
				//myTrace("add "+result+" to nED for " + this.caption);
				// v6.4.2.8 See comments above
				//if (_global.ORCHID.user.teacher) {
				//	var thisUser = record.userID;
				//} else {
				//	var thisUser = 0;
				//}
				if (_global.ORCHID.user.userID == record.userID) {
				//if (record.count == undefined) {
					var thisUser = 0;
				} else if (false) {
					// I don't know how to determine if this record came from my group yet
					var thisUser = 1;
				} else {
					var thisUser = 2;
				}
				//myTrace("for menu " + this.caption + " set nED[" + thisUser + "]=" + result);
				this.progress.numExercisesDone[thisUser]+= Number(result);
				return result;
			}
		}
		return -1;
	} else {
		// this leaf does not match the item ID
		//myTrace("no match with scaffold itemID " + this.id);
		return -1;
	}
}
//AR: this is really a setter function not a getter!
//ProgressObject.prototype.getRecord = function(score, dateStamp, correct, wrong, skipped) {
// This function adds a progress record into the scaffold
ProgressObject.prototype.addRecord = function(score, dateStamp, correct, wrong, skipped, duration) {
	this.record.push( { score: score, dateStamp: dateStamp, correct: correct, wrong: wrong, skipped: skipped, duration: duration } );
	// Note: for now lets leave out sorting
	//this.record.sortOn("dateStamp");
	//if(score != null) {
	//	this.numExercisesDone = 1;
	//}
	// surely you don't need to set this here, it will have been set once at the beginning
	//this.numOfExercises = 1;
}

// v6.4.2.8 Copy of the old code for just getting details into XML
ScaffoldObject.prototype.getNonRandomProgressDetails = function(userID) {
	var progInfo = new XML();
	if (this.progress.numExercisesDone[userID] > 0) {
		//myTrace("gNRPD["+userID+"]." + this.caption + "=" + this.progress.numExercisesDone[userID]);
		// if this is a scaffold item, create a node and go deeper
		if (typeof this.action == "object") {
			var item = progInfo.createElement("item");
			item.attributes.caption = this.caption;
			item.attributes.count = this.progress.numExercisesDone[userID];
			item.attributes.score = this.progress.averageScore[userID];
			// v6.5.5.6 Add unit number to the XML to allow smart sorting
			item.attributes.unit = this.unit;
			progInfo.appendChild(item);
			for (var j = 0; j < this.action.length; j++) {
				//myTrace("look into " + this.action[j].caption);
				progInfo.firstChild.appendChild(this.action[j].getNonRandomProgressDetails(userID));
			}
		} else {
			if (userID>0) {
				// This is an exercise level record, just take the already summarised info from the scaffold
				var item = progInfo.createElement("item");
				item.attributes.caption = this.caption;
				item.attributes.count = this.progress.numExercisesDone[userID];
				item.attributes.score = this.progress.averageScore[userID];				
				progInfo.appendChild(item);
			} else {
				for (var i in this.progress.record) {
					var item = progInfo.createElement("item");
					// Take all attributes?
					// This would be nice because it means I will automatically get new ones, but then I also get constuctor functions
					// So switch back to specifying exactly what you want
					//item.attributes = this.progress.record[i];
					item.attributes.caption = this.caption;
					item.attributes.duration = this.progress.record[i].duration;
					item.attributes.dateStamp = this.progress.record[i].dateStamp;
					item.attributes.score = this.progress.record[i].score;
					item.attributes.correct = this.progress.record[i].correct;
					item.attributes.wrong = this.progress.record[i].wrong;
					item.attributes.skipped = this.progress.record[i].skipped;
					progInfo.appendChild(item);
				}
			}
		}
	}
	return progInfo;
}

// this function will return all records where this user has done something for regular exercise
// it goes through the whole scaffold in a recursive loop
// it formats a string here, not really a good idea, at least we could use styles
// v6.4.2.8 This should build an XML object, that is then sent to a table/chart builder to be displayed as you like
ScaffoldObject.prototype.getNonRandomProgress = function(userID, buildString, depth) {
	//myTrace(this.caption + " has nED[" + userID + "]=" + this.progress.numExercisesDone[userID]);
	// v6.4.2.8 Just for information, see if nED for everyone is OK
	//if (this.progress.numExercisesDone[2] > 0) {
		//myTrace("and nED[2]=" + this.progress.numExercisesDone[2] + " avgSc[2]=" + this.progress.averageScore[2]);
		//myTrace("and avgSc[" + userID + "]=" + this.progress.averageScore[0]);
	//}
	// has the user either done this exercise or an exercise in this scaffold item?
	if (this.progress.numExercisesDone[userID] > 0) {
		// if this is a scaffold item, just record its name in the build string and keep going deeper
		if (typeof this.action == "object") {
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				// we don't want the course name (depth=0) in the progress screen
				if (depth == 1) {
					// v6.1.2 ESG and AGU colouring
					//startTag = "<u><b><font color='#00719C'>"; endTag = "</font></b></u>";
					if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
						var textColour = "#00719C";
					} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("ESG") >= 0) {
						var textColour = "#BE4718";
					} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
						var textColour = "#006633";
					}
					startTag = "<u><b><font color='" + textColour + "'>"; endTag = "</font></b></u>";
				} else {
					// unit names - just want to do word wrapping and line indent (but cannot!)
					startTag = ""; endTag = "";
				}
				if (depth>0) buildString += startTag + this.caption + endTag + "<br>";
			} else {
				// we don't want the course name (depth=0) in the progress screen
				// put it in the window title instead
				startTag = "<h" + (depth) + ">"; 
				endTag = "</h" + (depth) + ">";
				if (depth>0) buildString += makeString("<tab>", depth) + startTag + this.caption + endTag + "<br>";
			}
			depth++;
			var detailLines = false;
			for (var j = 0; j < this.action.length; j++) {
				buildString = this.action[j].getNonRandomProgress(userID, buildString, depth);
				if ((this.action[j].progress.numExercisesDone[userID] > 0) && (typeof this.action[j].action != "object")) {
					detailLines = true;
				}
			}
			// if you have just listed out detail record(s), put out a new line before the next heading
			if (detailLines) {
				buildString += "<br>";
			}
		// otherwise, print the progress detail to the build string
		} else {
			var thisDuration = 0; var thisTotal =0;
			//trace("got a record for " + this.action + " records=" + this.progress.record.length);
			for (var i in this.progress.record) {
				// do I know the name of the exercise for this record?
				//var itemID = this.ID;
				//var exerciseName = this.caption; // xxxx
				//trace("for itemID=" + itemID + " got caption=" + this.caption + " depth=" + depth);
				// v6.3 Cope with multiple users for reporting
				// v6.4.2.8 We will only be putting this student's records into progress from now on
				//if (userID==0 || this.progress.record[i].userID == userID) {
					if (this.progress.record[i].duration < 60) {
						thisDuration = "&lt;1"; 
					} else {
						thisDuration = parseInt(this.progress.record[i].duration / 60);
					}
					if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
						// v6.3.2 Some scores are duration recorders only
						if (this.progress.record[i].score < 0) {
							var thisPct = "---";
						} else {
							thisTotal = parseInt(this.progress.record[i].correct) + parseInt(this.progress.record[i].wrong) + parseInt(this.progress.record[i].skipped);
							var thisPct = this.progress.record[i].correct+"/" + thisTotal;
						}
						// Do special processing for "What will I learn in this section"
						if (depth == 2) {
							buildString += this.caption + "<tab>";
						} else {
							buildString += "<tab>" + this.caption + "<tab>" + thisPct +"<tab>";
						}
						buildString += formatDateForProgress(this.progress.record[i].dateStamp) + "<tab>" + thisDuration + "<br>";
					} else {
						// v6.2 Problem with the long captions heading - it really needs a line of its own
						// Is it worth calculating the width and adding in a <br> if it is going to impinge on the score?
						// v6.3.2 Some scores are duration recorders only
						//myTrace("record.caption=" + this.caption + " .testUnits=" + this.progress.record[i].testUnits);
						if (this.progress.record[i].score < 0) {
							var thisPct = "---";
						// v6.4.3 Also don't display scores from 'test' exercises
						} else if (this.progress.record[i].testUnits == "*") {
							var thisPct = "*";
						} else {
							var thisPct = this.progress.record[i].score + "%";
						}
						buildString += makeString("<tab>", depth) + this.caption + "<tab>" + thisPct+"<tab>";
						buildString += formatDateForProgress(this.progress.record[i].dateStamp) + "<tab>" + thisDuration + "<br>";
					}
				//} else {
				//	myTrace("record discarded as it belongs to userID " + this.progress.record[i].userID);
				//}
			}
		}
		//trace("build=" + buildString);
	}
	return buildString;
}

// this function will return all records where this user has done something for random exercise
// EGU - THIS IS STILL solely tied into LSO!
ScaffoldObject.prototype.getRandomProgress = function(userID) {
	// 6.0.6.0 change the structure slightly (progress to session)
	//var progIdx = _global.ORCHID.session.progressIdx;
	//var myRecords = _global.ORCHID.dbInterface.dbSharedObject.data.progress[progIdx].scoreRecords;
	// EGU - completely different approach
	//var sessionID = _global.ORCHID.session.sessionID;
	//var myRecords = _global.ORCHID.dbInterface.dbSharedObject.data.session[sessionID].scoreRecords;
	var myRecords = _global.ORCHID.course.testList;
	//myTrace("there are " + myRecords.length + " test results");
	if (myRecords.length == 0) return "";
	
	// write out a header
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// v6.1.2 ESG and AGU colouring
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
			var textColour = "#00719C";
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("ESG") >= 0) {
			var textColour = "#BE4718";
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
			var textColour = "#006633";
		}
		var tempProgress = "<u><b><font color='" + textColour + "'>Tests</font></b></u><br>";
	} else {
		var tempProgress = "<u><b>" +_global.ORCHID.literalModelObj.getLiteral("tests", "labels") + "</b></u><br>";
	}
	var thisTotal = 0;
	// v6.3.5 AGU Cope with multiple users for reporting
	var countUsersRecords=0;
	for (var i = 0; i < myRecords.length; i++) {
	// v6.3.5 AGU Cope with multiple users for reporting
		//myTrace("test record, userID=" + myRecords[i].userID);
		if (userID == 0 || myRecords[i].userID == userID) {
			countUsersRecords++;
			//var myIDs = myRecords[i].itemID.toString().split(",");
			// v6.3.4 Switch to a new field for unit numbers rather than string
			//var myIDs = myRecords[i].itemID.split("[")[1].split("]")[0].split(",");; // itemID = "[18, 34]"
			var myIDs = new Array();
			//var thisItemID = myRecords[i].itemID;
			//var flag = 32; // hard code a starting limit
			//while (flag-->0) {
			//	if (Math.pow(2,flag) & thisItemID) {
			//		myIDs.unshift(flag);
			//	}
			//}
			myIDs = myRecords[i].testUnits.split(",");
			myTrace("units in test = " + myIDs.toString());
			var tempCaption = "";
			for (var j = 0; j < myIDs.length; j++) {
				// v6.3.4 get by unit not id
				//var temp = this.getObjectByID(myIDs[j]).caption
				var temp = this.getObjectByUnitID(myIDs[j]).caption
				if (temp != null && temp != undefined && temp != "") {
					if (j != myIDs.length - 1) {
						tempCaption += temp + "; ";
					} else {
						tempCaption += temp;
					}
				}
			}
			//myTrace("caption=" + tempCaption);
			if (myRecords[i].duration < 60) {
				thisDuration = "&lt;1"; 
			} else {
				thisDuration = parseInt(myRecords[i].duration / 60);
			}
			//trace("with caption=" + tempCaption);
			// v6.3.4 temp form of formatting I hope!
			depth=3;
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				thisTotal = parseInt(myRecords[i].correct) + parseInt(myRecords[i].wrong) + parseInt(myRecords[i].skipped);
				tempProgress += tempCaption + "<br><tab><tab>" + myRecords[i].correct+"/" + thisTotal +"<tab>";
				tempProgress += formatDateForProgress(myRecords[i].dateStamp) + "<tab>" + thisDuration + "<br>";
			} else {
				// v6.4.2.8 Don't add in a tab as this will be ugly for long caption names.
				//tempProgress += makeString("<tab>", 1) + tempCaption + "<br>" + makeString("<tab>", depth) + myRecords[i].score+"%"+"<tab>";
				tempProgress += tempCaption + "<br>" + makeString("<tab>", depth) + myRecords[i].score+"%"+"<tab>";
				tempProgress += formatDateForProgress(myRecords[i].dateStamp) + "<tab>" + thisDuration + "<br>";
			}
		}
	}
	// v6.3.5 AGU Cope with multiple users for reporting
	if (countUsersRecords>0) {
		return tempProgress;
	} else {
		return "";
	}
};

//AM: I have divide getUserProgress into 2 functions - getRandomProgress and getNonRandomProgress 
ScaffoldObject.prototype.getUserProgress = function() {
	// v6.4.2.8 Before we do this, race through the scaffold to average my scores
	//myTrace("summarise my scores");
	this.summariseInformation(0);
	
	// for some unknown reason, the last two lines of the progress window (with 240 records) can't be
	// reached with the scroll bar, although you can with keys in the text window. This could be a bug
	// in the scroll bar, or something to do with the size of the box? Ahh, after a resize it works, well, based
	// a bit on how you resize. So must be to do with my resize function I guess.
	// v6.3 Need to cope with multiple users if this is a teacher login
	var buildString = ""
	//if (_global.ORCHID.user.userList.length > 0) {
	// v6.4.2.8 Remove the function for teacher login
	//if (_global.ORCHID.user.teacher) {
	//	for (var i in _global.ORCHID.user.userList) {
	//		//myTrace("add scores for " + _global.ORCHID.user.userList[i].userName);
	//		var userID = _global.ORCHID.user.userList[i].userID;
	//		var substList = [{tag:"[x]", text:_global.ORCHID.user.userList[i].userName}];
	//		var thisHeading = substTags(_global.ORCHID.literalModelObj.getLiteral("resultsFor", "labels"), substList);
	//		buildString += "<b>" + thisHeading + "</b><br>";
	//		buildString += this.getNonRandomProgress(userID) + this.getRandomProgress(userID) + "<br>";
	//	}
	//} else {
		// Non-teacher login always just uses nED(0) rather than _global.ORCHID.user.userID
		buildString += this.getNonRandomProgress(0) + this.getRandomProgress(0) + "<br>";
	//}
	return buildString + "<br>";
	//return this.getRandomProgress() + "<br><br>" + this.getNonRandomProgress();
	//return this.getRandomProgress();
};
// this would be in common.as except that I don't have it checked out!
// Now it is!
/*
// replaced all instances in this file of this.formatDateForProgress with just formatDate...
ScaffoldObject.prototype.formatDateForProgress = function(dateString) {
// dateString is always YYYY-MM-DD HH:MM:SS
// target for this function is
//	12:34 Mon 17 Jul 2003
	var myDT = dateString.split(" ");
	var myD = myDT[0].split("-");
	var myT = myDT[1].split(":");
	
	//myTrace("date=" + dateString);	
	// remember that months in Flash are 0 based
	var theDate = new Date(myD[0], myD[1]-1, myD[2], myT[0], myT[1], myT[2]);
	//myTrace(theDate.toString());	
	// These need to be translated! - don't forget
	var months=["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
	var days=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var minutes = theDate.getMinutes();
	if (theDate.getMinutes() < 10) { minutes = "0" + minutes; }
	return theDate.getHours() + ":" + minutes + " - " + days[theDate.getDay()] + " " + theDate.getDate() + " " + months[theDate.getMonth()] + " " + theDate.getFullYear();
}
*/
// method for writing out the object as a string (mostly used for trace or logs)
ProgressObject.prototype.toString = function() {
	// mostly caption is empty, but for exercises that are not fixed parts of the scaffold it won't be
	return this.caption + " " +this.score+"% "+this.dateStamp;
};

// this function just counts and summarises the number of exercises under each item
//v6.4.2 This should not be called from anywhere else as it doesn't clear before counting up. Only
// to be used within the object.
ScaffoldObject.prototype.numExercisesSummary = function() {
	// is this an exercise or a menu item?
	if (typeof this.action == "string") {
		// we don't want to count exercises that are ONLY question banks as you can't do them as such
		//trace("scaffold item has mode=" + this.enabledFlag);
		if (this.enabledFlag & _global.ORCHID.enabledFlag.menuOn || this.enabledFlag & _global.ORCHID.enabledFlag.navigateOn) {
			this.progress.numExercises = 1;
		}
	// otherwise, dig deeper to try and find the exercise items
	} else if (typeof this.action == "object") {
		for (var j = 0; j < this.action.length; j++) {
			// increment the exercises done in this branch
			this.progress.numExercises+= this.action[j].numExercisesSummary();
			//myTrace("increment to " + this.progress.numExercises + " for " + this.caption);
		}
		//trace(this.caption + "=" + this.progress.numExercises)
	}
	//myTrace("counting for " + this.caption + " = " + this.progress.numExercises);
	return this.progress.numExercises;
}
// v6.4.2.8 A new function to traverse the scaffold and summarise the static, everyone information
// at higher levels. Note that we do already know the count, it is just the score that we can only averge correctly now
// Add this function for me as well.
//ScaffoldObject.prototype.summariseEveryoneInformation = function() {
ScaffoldObject.prototype.summariseInformation = function(userID) {
	// First, if this is for this user, we will need to add up the progress records to get averages
	// Is this an exercise or a menu item?
	if (userID==0 && this.progress.numExercisesDone[userID]>0 && (typeof this.action == "string")) {
		// Get the average and the number of exercises done for this item (it is an exercise)
		//myTrace("sI.exercise " + this.caption + " score " + this.progress.record[userID].score);
		var addItUp = 0;
		var countThem=0;
		for (var i in this.progress.record) {
			if (Number(this.progress.record[i].score)>=0) {
				addItUp+=Number(this.progress.record[i].score);
				countThem++;
			}
		}
		var thisInfo = new Object();
		thisInfo.count = countThem;
		if (countThem>0) {
			thisInfo.score = addItUp/countThem;
		} else {
			thisInfo.score = 0;
		}
		// Note you can't update the nED[0] for this record as we never set it above 1
		this.progress.averageScore[userID] = thisInfo.score;
		//myTrace("sI." + this.caption + " score=" + thisInfo.score + " counted=" + countThem);
		return thisInfo;
	// otherwise, dig deeper to try and find the exercise items
	// v6.4.2.8 But no point it nothing has been done
	//} else if (typeof this.action == "object") {
	} else if (this.progress.numExercisesDone[userID]>0 && (typeof this.action == "object")) {
		//myTrace(this.caption + " count=" + this.progress.numExercisesDone[userID] + " avg=" + this.progress.averageScore[userID]);
		var levelCount = 0;
		var levelTotal = 0;
		for (var j = 0; j < this.action.length; j++) {
			// increment the exercises done in this branch
			var itemInfo = new Object;
			itemInfo = this.action[j].summariseInformation(userID);
			// ignore something that hasn't been done, or didn't get a valid score
			if (itemInfo.count>0 && itemInfo.score>=0) {
				levelCount+=Number(itemInfo.count);
				levelTotal+=Number(itemInfo.count)*Number(itemInfo.score);
				//myTrace("increment to " + levelTotal);
			}
		}
		// We can check, because the levelCount and the numExerciseDone ought to be the same at this point
		// except that I don't want to count exercises that had a -1 score (not scored).
		if (levelCount>0) {
			this.progress.averageScore[userID] = levelTotal / levelCount;
		} else {
			this.progress.averageScore[userID] = 0;
		}
		//myTrace("compare, levelCount=" + levelCount + " nED=" + this.progress.numExercisesDone[userID] + " avg=" + this.progress.averageScore[userID]);
	}
	//myTrace("counting for " + this.caption + " = " + this.progress.numExercises);
	var thisInfo = new Object();
	thisInfo.count = this.progress.numExercisesDone[userID];
	thisInfo.score = this.progress.averageScore[userID];
	//myTrace(this.caption + " score=" + thisInfo.score);
	return thisInfo;
}

//return a Date object according to the input string and delimiter
//the input string should be like these dd-mm-yyyy, dd/mm/yyyy, etc
createDate = function(dateString, delimiter) {
	var dateArray = dateString.toString().split(delimiter);
	if(dateArray.length != 3) {
		//trace(dateArray.length);
		return null;
	}
	if(dateArray[1] > 12 || dateArray[1] < 1) {
		return null;
	}
	if(dateArray[0] > 31 || dateArray[0] < 1) {
		return null;
	}
	var returnDate = new Date(dateArray[2], dateArray[1] - 1, dateArray[0]);
	return returnDate;
}

// this function just finds if there are ANY "question banks" in the course
ScaffoldObject.prototype.useQuestionBanks = function() {
	// v6.5.4.7 Ha! The course.xml often now has the full courseID as the id rather than the old 0. So this no longer works!
	// however I don't think you can assume that it ALWAYS has the courseID, though perhaps it should.
	// So we need to check by 'top item'
	var topID = this.id;
	myTrace("for this scaffold, topID=" + topID)
	//var me = this.getItemsByID(0);
	var me = this.getItemsByID(topID);
	for (var i=0; i<me.length; i++) {
		//myTrace("scaffold.caption=" + me[i].caption + ", eF=" + me[i].enabledFlag);
		if (me[i].enabledFlag & _global.ORCHID.enabledFlag.randomOn) {
			myTrace("found a question bank");
			return true;
		}
	}
	return false;
}
