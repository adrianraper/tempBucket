// EGU - don't use the component (push button) as the means of finding the content
//creationNS.generateTest = function(component) {
creationNS.generateTest = function(contentHolder, numOfQuestions) {
	// v6.4.2.7 If you are running startAgain from a test, you will not have passed anything, just use
	// the ones from last time
	var itemList = [];
	if (contentHolder == undefined) {
		numOfQuestions = _global.ORCHID.session.currentItem.numOfQuestions;
		itemList = _global.ORCHID.session.currentItem.itemList;
		myTrace("use last time " + numOfQuestions + " questions");
	} else {
		myTrace("I will generate the test from " + contentHolder);
		var scaffold = _global.ORCHID.course.scaffold;
		var theseItems = [];
		// EGU
		//var me = component._parent;
		var me = contentHolder;
		//trace("me is " + me);
		for (var i in me) {
			//myTrace("item " + me[i]);
			if (typeof me[i] == "movieclip") {
				if (me[i].getValue()) {
					//myTrace("get exercises under item " + me[i].itemID);
					// get the leaf scaffold items within this unit ID
					theseItems = scaffold.getItemExercises(me[i].itemID);
					for (var j in theseItems) {
						// Check the randomOn of the enabledFlag at the exercise level
						if (theseItems[j].enabledFlag & _global.ORCHID.enabledFlag.randomOn) {
							myTrace(theseItems[j].caption + " has random questions");
							itemList.push(theseItems[j]);
						}
					}
				}
			}
		}
	}	
	//var numOfQuestions = parseInt(me.i_numberQuestions.text);
	// EGU - this is passed now
	//var numOfQuestions = me.numQuestionsSlider.getIntValue();
	//myTrace(numOfQuestions + " questions ");
	if (numOfQuestions > 0 && itemList.length > 0) {
		// 6.0.2.0 remove connection
		//myConnection.createExercise(itemList, numOfQuestions);
		creationNS.createExercise(itemList, numOfQuestions);
		// finally close the window
		//trace("close the pane - " + contentHolder._parent._parent);
		// EGU
		//component._parent._parent._parent.closePane();
		contentHolder._parent._parent.closePane();
	} else {
		myTrace("no questions to make an exercise from...");
	}
}

creationNS.loadUnitNames = function(contentHolder) {
	// AGU - this function is not called as buttons contains a hard-coded test screen
	// v6.5.4.7 Ha! The course.xml often now has the full courseID as the id rather than the old 0. So this no longer works!
	// However I don't think you can assume that it ALWAYS has the courseID, though perhaps it should.
	// So we need to check by 'top item'
	var topID = _global.ORCHID.course.scaffold.id;
	myTrace("for this scaffold, topID=" + topID)
	//var me = this.getItemsByID(0);
	//var me = _global.ORCHID.course.scaffold.getItemsByID(0);
	var me = _global.ORCHID.course.scaffold.getItemsByID(topID); 
	//trace("looking for names in " + _global.ORCHID.course.scaffold.caption + " add to " + contentHolder);
	var myTF = new TextFormat();
	myTF.font = globalStyleFormat.textFont;
	//myTF.size = globalStyleFormat.textSize;
	//myTF.font = "Gadget";
	//v6.4.3 Make it bigger
	//myTF.size = 10;
	//myTF.size = 11;
	myTF.size = 12;
	//myTrace("use TF.font=" + myTF.font);
	// EGU
	//var startY = contentHolder.cmdOK_pb._y + contentHolder.cmdOK_pb._height + 10;
	//var startX = contentHolder.cmdOK_pb._x + 10;
	var column = 0;
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
		//var startY = 0; var startX = 0;
		var startY = 10; var startX = 10;
		var thisX = thisY = 0;
		var breakAt = 0;
		// EGU - different widths
		//var colWidth = 250;
		var colWidth = 195;
	} else {
		//var startY = 40;
		var startY = 90;
		//var startX = 10;
		var startX = 80;
		var thisX = thisY = 0;
		var breakAt = 0; // is this the number of lines in one column?
		// v6.4.2.8 Reduce width for AP based courses
		//var colWidth = 250;
		var colWidth = 200;
	}
	var thisCheckBoxSquare = 0;
	var unitCount =0;
	// 6.0.1.0 fix the width checking of the captions
	contentHolder.createTextField("captionWidth", creationNS.depth++, 0, 40, 10, 10);
	contentHolder.captionWidth.autosize = true;
	contentHolder.captionWidth.wordWrap = false;
	contentHolder.captionWidth.multiline = false;	
	contentHolder.captionWidth.setNewTextFormat(myTF);
	// 6.0.4.0, clear the previous check box before attaching the new ones
	// this is because the pane will not be removed when it closes
	// it will only be made invisible
	for (var i in contentHolder) {
		if(contentHolder[i]._name.indexOf("unitName") == 0) {
			contentHolder[i].removeMovieClip();
		}
	}
	//myTrace("make units for " + me.length + " items, max=" + contentHolder.maxHeight);
	if (me.length<8) {
		var vSpacer = 14;
	} else {
		var vSpacer = 10;
	}
	for (var i=0; i<me.length; i++) {
		// we are only interested in items that can be used for random exercises
		//myTrace(me[i].caption + " has enabledFlag=" + me[i].enabledFlag);
		// v6.5.4.7 It would be nice to block units that are hidden
		//if (me[i].enabledFlag & _global.ORCHID.enabledFlag.randomOn) {
		if ((me[i].enabledFlag & _global.ORCHID.enabledFlag.randomOn) && !(me[i].enabledFlag & _global.ORCHID.enabledFlag.disabled)) {
			thisX = startX + (column * colWidth);
			//thisY = (startY + ((unitCount-breakAt)*(thisCheckBoxSquare + 4)));
			thisY = (startY + ((unitCount-breakAt)*(thisCheckBoxSquare + vSpacer))); 
			if ((thisY+40) > contentHolder.maxHeight) {
				breakAt = unitCount+1;
				column++;
			}
			//myTrace("adding " + me[i].caption + "at x=" + thisX + " y=" + thisY + " -" + i);
			var initObj = {_x:thisX, _y:thisY };
			thisUnit_ch = contentHolder.attachMovie("FCheckBoxSymbol", "unitName" + i,creationNS.depth++, initObj);
			//myTrace("as " + thisUnit_ch);
			if (thisCheckBoxSquare == 0) {
				thisCheckBoxSquare = thisUnit_ch.fcb_states_mc._width;
			}
			thisUnit_ch.setLabel(me[i].caption);
			thisUnit_ch.setStyleProperty("textSize", myTF.size); 
			// 6.0.1.0 measure width of the caption
			//thisCaptionWidth = myTF.getTextExtent(me[i].caption).width + 18; // why doesn't this return the correct length?
			contentHolder.captionWidth.text = me[i].caption;
			thisCaptionWidth = contentHolder.captionWidth.textWidth;
			//myTrace("this text width = " + thisCaptionWidth);
			thisUnit_ch.setSize(thisCaptionWidth + thisCheckBoxSquare + 4);
			thisUnit_ch.itemID = me[i].id;
			unitCount++;
		}
	}
	contentHolder.captionWidth.removeTextField();
	//trace("the pane is " + contentHolder._parent._parent);
	//contentHolder._parent._parent.setContentSize(contentHolder._width+10, contentHolder._height+10);
	// just to hold the demo warning
	// EGU - fixed size
	//contentHolder._parent._parent.setContentSize(contentHolder._width+40, contentHolder._height+10);
}
// v6.3.5 To allow author specified tests to be generated
// This is called with a simple array of scaffold item IDs (maybe units, maybe exercises)
// sentList = ["u1", "e109"]
creationNS.authoredTest = function(sentList, numOfQuestions) {
	myTrace("Generate the test from " + sentList.toString());
	var scaffold = _global.ORCHID.course.scaffold;
	var itemList = [];
	var theseItems = [];
	for (var i in sentList) {
		theseItems = scaffold.getItemExercises(sentList[i]);
		for (var j in theseItems) {
			myTrace(theseItems[j].caption + " has enabledFlag=" + theseItems[j].enabledFlag);
			// Check the randomOn of the enabledFlag at the exercise level
			if (theseItems[j].enabledFlag & _global.ORCHID.enabledFlag.randomOn) {
				itemList.push(theseItems[j]);
			}
		}
	}
	if (numOfQuestions > 0 && itemList.length > 0) {
		creationNS.createExercise(itemList, numOfQuestions);
	} else {
		myTrace("nothing to make an exercise from...");
	}
}

//List of methods that the creation module will react to when called by the controller
// 6.0.4.0, This is now handled by view object
/*creationNS.selectUnitsForTest = function() {
	// BAD BAD, since going to a frame you are already on will not trigger code
	// on that frame, do a fake go somewhere else first
	// see how buttons.fla handles frames as states
	gotoAndStop(2);
	gotoAndStop("test");
}*/
//v6.4.3 Test features. Create Exercise will be sent one scaffold item only - which will either be a template or a regular
// exercise. If a template, use TGM to get the XML, otherwise read from file. Then pass the XML to processExercise
// v6.4.2.8 This is not true! We still want to let the student build a test from the menu screen taking questions from x units.
//creationNS.createExercise = function(scaffoldItemArray, numOfQuestions, randomMode) {

// v6.5.5.1 Since I am doing this later, no need to do this continue lark

creationNS.createExercise = function(scaffoldItemArray, numOfQuestions) {
/*
	this.scaffoldItemArray = scaffoldItemArray;
	this.numOfQuestions = numOfQuestions;
	
	// v6.5.4.5 Before loading or building an exercise, check that the licence ID is still valid
	// Asynch so trigger rest of function after this complete
	// v6.5.5.0 Change the name to instance
	// v6.5.5.1 Can I change this to after the exercise has been read? Its just that we are probably still saving the score
	// and queries can't be run at the same time so we would have to wait, which is a shame since loading the ex has no db implications.
	//_global.ORCHID.user.compareLicenceIDWithDB();
	//_global.ORCHID.user.compareInstanceIDWithDB();
	this.continueCreateExercise();
}
creationNS.continueCreateExercise = function() {
	
	var scaffoldItemArray = this.scaffoldItemArray;
	var numOfQuestions = this.numOfQuestions;
*/
	
	// this will build the XML object that is an exercise
	// Simply read the XML from the file. Once you've got it, either pass it for processing to TGM or
	// send directly off to processExercise.
	
	//v6.4.3 Remove old code
	// v6.4.2.8 Put it back again! Maybe all I need to do is to read the qbank ids from menu.xml and then build 
	// up a temporary template XML and simply hand over to that processing section.
	if (typeof scaffoldItemArray[0] == "object") { // which also covers arrays
		validExerciseIDs = new Array();
		validUnitIDs = new Array();
		// just want one occurence, so use an object
		var tempUnitIDs = new Object();		
		//myTrace("creationNS.createExercise for an array of exercises, num=" + numOfQuestions);
		for (var i = 0; i < scaffoldItemArray.length; i++) {
			//myTrace("203.reading caption=" + scaffoldItemArray[i].caption + " id=" + scaffoldItemArray[i].id + " eF=" + scaffoldItemArray[i].enabledFlag);
			validExerciseIDs.push(scaffoldItemArray[i].id);
			tempUnitIDs[scaffoldItemArray[i].unit] = true;
		}
		// turn it into an array for ease of use in the rest of the program
		for (var i in tempUnitIDs) {
			if (tempUnitIDs[i] = true) {
				validUnitIDs.push(i);
			}
		}
		
		// v6.4.2.8 Copy back in to correctly set up the scaffold for 'unit' tests
		// the rest of this is for setting the caption and stuff for the exercise
		// as it doesn't have its own scaffold item (like a real exercise would)
		var randomScaffoldItem = new _global.ORCHID.root.objectHolder.ScaffoldObject();
		//unit = -16 means it is a random exercise
		randomScaffoldItem.unit = -16;
		randomScaffoldItem.action = null;
		randomScaffoldItem.enabledFlag = 0;

		var caption = new Array();
		for (i = 0; i < validUnitIDs.length; i++) {
			// v6.3.4 Look up unit not id
			var item = _global.ORCHID.course.scaffold.getObjectByUnitID(validUnitIDs[i]);
			//myTrace("look up the caption for unit " + validUnitIDs[i] + " it is " + item.caption);
			caption.push(item.caption);
		}
		// v6.3.4 Oops, found a non-literal
		//randomScaffoldItem.caption = "Test from units " + caption.join("; ");
		randomScaffoldItem.caption = _global.ORCHID.literalModelObj.getLiteral("testUnits", "labels") + " " + caption.join("; ");

		randomScaffoldItem.id = -16;
		randomScaffoldItem.testUnits = validUnitIDs.join();
		//myTrace("random itemID=" + randomScaffoldItem.id + " from units " + randomScaffoldItem.testUnits);
		_global.ORCHID.session.currentItem = randomScaffoldItem;
		// v6.4.2.7 We need to store the numOfQuestions and the units list so that you can create the test again.
		_global.ORCHID.session.currentItem.numOfQuestions = numOfQuestions;
		_global.ORCHID.session.currentItem.itemList = scaffoldItemArray;
		// v6.2 And clear out next and back holders
		_global.ORCHID.session.nextItem = undefined;
		_global.ORCHID.session.previousItem = undefined;

		// temporarily pick up the template from Spaces or not based on the first item you find
		// this probably means you have to have a duplicate in both folders
		//myTrace("this ex enabledFlag=" + scaffoldItemArray[0].enabledFlag + " num=" + _global.ORCHID.session.currentItem.numOfQuestions);
		if (scaffoldItemArray[0].enabledFlag & _global.ORCHID.enabledFlag.edited){
			//myTrace("which & with " + _global.ORCHID.enabledFlag.edited);
			var fileName = _global.ORCHID.paths.editedExercises + "RandomTestTemplate.xml";
		} else {
			var fileName = _global.ORCHID.paths.exercises + "RandomTestTemplate.xml";
		}
		//myTrace("load file=" + fileName);
		var ExerciseStructure = new XML();
		ExerciseStructure.validExerciseIDs = validExerciseIDs;
		ExerciseStructure.numOfQuestions = numOfQuestions;
		
		ExerciseStructure.ignoreWhite = true;
		// create one callback function to process the data once the XML is read from the file
		// and put into the XML structure
		ExerciseStructure.onLoad = function(success) {
			if (success) {
				//myTrace("load template xml successfully");
				// Then add in the qbanks that I want to read
				//<questionBank id="1192013075645" />
				//<questionBank id="1192013075812" />
				for (var i in this.firstChild.childNodes) {
					//myTrace("look at " + this.firstChild.childNodes[i].toString());
					if (this.firstChild.childNodes[i].nodeName == "body") {
						for (var j in this.validExerciseIDs) {
							var newQBNode = this.createElement("questionBank");
							newQBNode.attributes.id = this.validExerciseIDs[j];
							this.firstChild.childNodes[i].appendChild(newQBNode);
							//myTrace("added qb=" + newQBNode.attributes.id);
						}
					} else if (this.firstChild.childNodes[i].nodeName == "settings") {
						//<misc questions="10" />
						for (var j in this.firstChild.childNodes[i].childNodes) {
							if (this.firstChild.childNodes[i].childNodes[j].nodeName == "misc") {
								// No idea why this doesn't work!
								//this.firstChild.childNodes[i].childNodes[j].attributes.questions = _global.ORCHID.session.currentItem.numOfQuestions;
								this.firstChild.childNodes[i].childNodes[j].attributes.questions = this.numOfQuestions;
								//myTrace("added questions=" + this.firstChild.childNodes[i].childNodes[j].attributes.questions);
								//myTrace("added questions=" + this.numOfQuestions);
								break;
							}
						}
					}
				}
				// tidy up a little
				this.validExerciseIDs = undefined;
				this.numOfQuestions = undefined;
				
				//myTrace("final XML = " + this.toString());
				// send the XML that you have read and the callback (as TGM is asynchronous)
				_global.ORCHID.root.mainHolder.testNS.testGenerator(this, creationNS.processExerciseXML);
			} else {
				myTrace("Sorry, the XML load failed with code " + this.status);
			}
		}
		if (_global.ORCHID.online){
			var cacheVersion = "?version=" + new Date().getTime();
		} else{
			var cacheVersion = ""
		}
		//myTrace("load exercise: " + fileName + cacheVersion);
		ExerciseStructure.load(fileName + cacheVersion);
		
	/*
	}			
	if (typeof scaffoldItemArray[0] == "object") { // which also covers arrays
		// read all the exercises in the list and pull out questions at random
		// then build an XML structure that contains them, along with standard stuff
		// for styles, title etc
		validExerciseIDs = new Array();
		validUnitIDs = new Array();
		// just want one occurence, so use an object
		var tempUnitIDs = new Object();
		if (scaffoldItemArray.action == null) {
			for (var i = 0; i < scaffoldItemArray.length; i++) {
				// v6.4.2.7 Use filename not action (but we also really want to send enabledFlag)
				//validExerciseIDs.push(scaffoldItemArray[i].action);
				validExerciseIDs.push(scaffoldItemArray[i]);
				// EGU - I actually want the parent of this item
				//trace("createEx: add parent=" + scaffoldItemArray[i].unit);
				//validUnitIDs.push(scaffoldItemArray[i].unit);
				tempUnitIDs[scaffoldItemArray[i].unit] = true;
				myTrace("203.reading caption=" + scaffoldItemArray[i].caption + " id=" + scaffoldItemArray[i].id + " eF=" + scaffoldItemArray[i].enabledFlag);
			}
		} else {
			//trace("getting action and unit2");
			// v6.4.2.7 Use filename not action (but we also really want to send enabledFlag)
			//validExerciseIDs.push(scaffoldItemArray.action);
			validExerciseIDs.push(scaffoldItemArray);
			//trace("createEx: add parent=" + scaffoldItemArray[i].unit);
			// EGU
			//validUnitIDs.push(scaffoldItemArray.unit);
			tempUnitIDs[scaffoldItemArray.unit] = true;
			myTrace("214.reading caption=" + scaffoldItemArray.caption);
		}
		// turn it into an array for ease of use in the rest of the program
		for (var i in tempUnitIDs) {
			if (tempUnitIDs[i] = true) {
				validUnitIDs.push(i);
			}
		}
		// v6.2 Can I mix up the order of the units and exercises at this point
		// so that I don't get all questions from one unit together?
		//trace("valid exercises were " + validExerciseIds.toString());
		_global.ORCHID.root.objectHolder.shuffle(validExerciseIDs);
		//trace("valid exercises are " + validExerciseIds.toString());
		// v6.2 If you have more exercises than you do questions, just send the
		// first x exercises from this shuffled list as they will be the ones
		// that are used anyway.
		if (validExerciseIDs.length > numOfQuestions) {
			validExerciseIDs = validExerciseIDs.slice(0, numOfQuestions);
		}		
		//trace("get "+numOfQuestions+" questions from " + validExerciseIDs.toString());
		_global.ORCHID.randomFieldIDStart = 1;
		_global.ORCHID.randomGroupIDStart = 1;
		// Now build the exercise from the questions
		_global.ORCHID.root.objectHolder.getRandomExercise(validExerciseIDs, validUnitIDs, numOfQuestions);
		// the rest of this is for setting the caption and stuff for the exercise
		// as it doesn't have its own scaffold item (like a real exercise would)
		var randomScaffoldItem = new _global.ORCHID.root.objectHolder.ScaffoldObject();
		//unit = -1 means it is a random exercise
		//randomScaffoldItem.id will be e1,e2,e3...
		//where e1, e2, e3... are the id of exercises used to make that random exercise
		randomScaffoldItem.unit = -16;
		randomScaffoldItem.action = null;
		randomScaffoldItem.enabledFlag = 0;
		var caption = new Array();
		for (i = 0; i < validUnitIDs.length; i++) {
			// v6.3.4 Look up unit not id
			var item = _global.ORCHID.course.scaffold.getObjectByUnitID(validUnitIDs[i]);
			myTrace("look up the caption for unit " + validUnitIDs[i] + " it is " + item.caption);
			caption.push(item.caption);
		}
		// v6.3.4 Oops, found a non-literal
		//randomScaffoldItem.caption = "Test from units " + caption.join("; ");
		randomScaffoldItem.caption = _global.ORCHID.literalModelObj.getLiteral("testUnits", "labels") + " " + caption.join("; ");
		
		//randomScaffoldItem.id = tempID;
		// EGU - what do we really want the random itemID to be?
		// perhaps just the item IDs of the selected items (language areas)
		// This is only saved to the score and the progress. "[18,34]"
		// v6.3.4 Switch to strings for test unitIDs
		//randomScaffoldItem.id = "[" + validUnitIDs.join() + "]";
		randomScaffoldItem.id = -16;
		randomScaffoldItem.testUnits = validUnitIDs.join();
		//for (var i in validUnitIDs) {
		//	//myTrace("add " + Math.pow(2,validUnitIDs[i]));
		//	randomScaffoldItem.id += Math.pow(2,validUnitIDs[i]);
		//};
		myTrace("random itemID=" + randomScaffoldItem.id + " from units " + randomScaffoldItem.testUnits);
		//randomScaffoldItem.caption = "Present and Past, Present perfect and past";
		_global.ORCHID.session.currentItem = randomScaffoldItem;
		// v6.4.2.7 We need to store the numOfQuestions and the units list so that you can create the test again.
		_global.ORCHID.session.currentItem.numOfQuestions = numOfQuestions;
		_global.ORCHID.session.currentItem.itemList = scaffoldItemArray;
		// v6.2 And clear out next and back holders
		_global.ORCHID.session.nextItem = undefined;
		_global.ORCHID.session.previousItem = undefined;
	*/		
	} else {
	
		// so there is just 1 exercise ID
		// v6.2 At this point, can I also quickly get the previous and next exercises?
		//trace("old next=" + _global.ORCHID.session.nextItem.id + " old previous=" + _global.ORCHID.session.previousItem.id);
		// v6.5.5 Content paths. What if I don't do this now, but do it at the end?
		// Actually, I don't think there is any difference, certainly not for coping with a conditional 'exercise'
		// Note the implications for bookmarks in scorm.as. So keep this here for now though it is duplication.
		//myTrace("building an exercise for id=" + scaffoldItemArray.ID + " section/group=" + scaffoldItemArray.group);
		//myTrace("caption=" + scaffoldItemArray.caption + " groupName=" + scaffoldItemArray.groupname);
		_global.ORCHID.session.nextItem = _global.ORCHID.course.scaffold.getNextItemID(scaffoldItemArray.ID);
		//myTrace("the next exercise.group is " + _global.ORCHID.session.nextItem.group);
		//_global.ORCHID.session.nextItem = undefined; 
		_global.ORCHID.session.previousItem = _global.ORCHID.course.scaffold.getPreviousItemID(scaffoldItemArray.ID);
		//trace("new next=" + _global.ORCHID.session.nextItem.id + " new previous=" + _global.ORCHID.session.previousItem.id);
		//trace("got next id=" + _global.ORCHID.session.nextItem.id);
		
		// save the item information in the session object for quick retrieval
		//trace("save the item ID=" + this.itemID);
		// v6.5.5.0 (FB2) subunit - is this is exercise in a different subunit from the last?
		var lastSubunit = _global.ORCHID.session.currentItem.group;
		//myTrace("the last exercise.group was " + _global.ORCHID.session.currentItem.group);
		_global.ORCHID.session.currentItem = scaffoldItemArray;
		//myTrace("this exercise.group is " + _global.ORCHID.session.currentItem.group);
		if (_global.ORCHID.session.currentItem.group == null) {
			// no subunit for this exercise (the usual case)
			_global.ORCHID.session.subunit = undefined;
		} else {
			// we know that this exercise is part of a subunit. 
			// Now we want to know if it is the first in a series, so need to check if we already have a subunit object running 
			// that isn't showing itself to be the last one.
			if (_global.ORCHID.session.subunit.status.indexOf("last")>=0 || _global.ORCHID.session.subunit == undefined) {
				// It is the first, so initialise
				_global.ORCHID.session.subunit = new Object();
				_global.ORCHID.session.subunit.id=_global.ORCHID.session.currentItem.group;
				_global.ORCHID.session.subunit.status="first";
			} else {
				// If it isn't the first, assume it is ongoing
				_global.ORCHID.session.subunit.status="continue";
			}
			// We also need to check to see if this is the last in a series
			// (this should cover the last exercise OK because nextItem.group will be undefined)
			if (_global.ORCHID.session.currentItem.group != _global.ORCHID.session.nextItem.group) {
				// It is the last as the next one has a different id (which might be null)
				// What about cases where this is first and last?
				if (_global.ORCHID.session.subunit.status=="first") {
					_global.ORCHID.session.subunit.status+="+last";
				} else {
					// overwrite the status to show it is the last
					_global.ORCHID.session.subunit.status="last";
				}
			}		
			myTrace("this exercise is subunit " + _global.ORCHID.session.currentItem.group + ", status=" + _global.ORCHID.session.subunit.status);
		}
		
		// use a function to turn exerciseIDs from the menu into source 
		//trace("just one exercise which is " + scaffoldItemArray.action);
		//var fileName = _global.ORCHID.paths.root + _global.ORCHID.paths.exercises + scaffoldItemArray.action + ".xml";
		//v6.4.1 NOTE that we should NOT be using the action to get the filename when we have the filename itself!
		//var fileName = _global.ORCHID.paths.exercises + scaffoldItemArray.action + ".xml";
		// v6.5.4.4 I want to drop the whole action thing soon! So stop this pointless warning.
		//if (scaffoldItemArray.filename != scaffoldItemArray.action + ".xml") {
			//myTrace("Warning: " + scaffoldItemArray.filename + " != action in menu.xml",1);
		//}
		//v6.4.2 AP editing ce
		myTrace("this ex enabledFlag=" + scaffoldItemArray.enabledFlag);
		if (scaffoldItemArray.enabledFlag & _global.ORCHID.enabledFlag.edited){
			//myTrace("which & with " + _global.ORCHID.enabledFlag.edited);
			var fileName = _global.ORCHID.paths.editedExercises + scaffoldItemArray.filename;
		} else {
			var productUID = _global.ORCHID.root.licenceHolder.licenceNS.productCode;
			var courseUID = _global.ORCHID.session.courseID;
			var unitUID = scaffoldItemArray.unit;
			var exerciseUID = scaffoldItemArray.id;
			//var nUID = _global.ORCHID.root.objectHolder.buildUID(productUID, courseUID, unitUID, exerciseUID);
			//var nTempPath = global.ORCHID.root.objectHolder.getEditedContentPathForUID(nUID, _global.ORCHID.user.editedContent)._path;
			//myTrace("nUID is " + nUID);
			//if (nTempPath <> null){
			//	var fileName = _global.ORCHID.paths.movie + "../../.." + nTempPath + exerciseUID + ".xml";
			//}else{
				var fileName = _global.ORCHID.paths.exercises + scaffoldItemArray.filename;
			//}
		}
		myTrace("load file=" + fileName);
		
		//myTrace("current item: id=" + _global.ORCHID.session.currentItem.ID + " .marked=" + _global.ORCHID.session.currentItem.marked);
		// timing
		_global.ORCHID.startTime = getTimer();
		var ExerciseStructure = new XML();
		ExerciseStructure.ignoreWhite = true;
		// create one callback function to process the data once the XML is read from the file
		// and put into the XML structure
		ExerciseStructure.onLoad = function(success) {
			if (success) {
				// v6.5.4.4 After loading a new exercise just check that we are running the right userID for this licence ID
				// Is this quite the right place to do that? Wouldn't it be better before you load?
				//_global.ORCHID.user.compareLicenceIDWithDB();
				myTrace("load exercise xml successfully, it is " + this.firstChild.attributes["type"]);
				// start the reading from the XML structure into the internal exercise structure
				//trace(">> loaded the XML file at " + Number(getTimer() - _global.ORCHID.startTime));
				// 6.0.2.0 remove connection
				//myConnection.processExerciseXML(this);
				//v6.4.3 Test features - if this is a template - send to TGM first
				if (this.firstChild.attributes["type"].toLowerCase() == "randomtest") {
					// v6.4.3 If my template has score based feedback, then I want to copy that to the XML that I generate.
					// This also applies to any media that is not question based (which it wouldn't be coming from the template)
					// All will be done in the testGenerator
					
					// send the XML that you have read and the callback (as TGM is asynchronous)
					_global.ORCHID.root.mainHolder.testNS.testGenerator(this, creationNS.processExerciseXML);
				// v6.5.5 Another special type of exercise is a navigation type
				} else if (this.firstChild.attributes["type"].toLowerCase() == "navigation") {
					
					// Call a new function to load interpret this XML and it will end up setting a nextItem and calling moveExercise.
					// We don't expect to come back here.
					myTrace("loaded navigation exercise");
					creationNS.navigationPath(this);
				} else {
					creationNS.processExerciseXML(this);
				}
			} else {
				myTrace("Sorry, the XML load failed with code " + this.status);
			}
		}
		if (_global.ORCHID.online){
			var cacheVersion = "?version=" + new Date().getTime();
		} else{
			var cacheVersion = ""
		}
		//myTrace("load exercise: " + fileName + cacheVersion);
		ExerciseStructure.load(fileName + cacheVersion);
	}
}
// v6.5.5.0 Content paths. Handle navigation 'exercises'.
creationNS.navigationPath = function(navigationXML){
	// Start reading the navigation Object
	navigationXML.stripWhite();
	navigationXML.ignoreWhite = true;
	//myTrace("whole=" + navigationXML.firstChild.toString());
	// Loop through all the rule tags until you find a condition that matches - remember that this will reverse the nodes from the file
	var conditionExercises = new Array();
	for (var node in navigationXML.firstChild.childNodes) {
		var tN = navigationXML.firstChild.childNodes[node];
		//myTrace("node=" + tN.toString());
		// It would make sense to get the score for all exerciseIDs mentioned in all rules at once.
		// Later on we could also get averages for units and percent completes too.
		if (tN.nodeName == "rule") {
			//myTrace("rule=" + tN.toString());
			// Read the result first so you can save it
			for (var node in tN.childNodes) {
				var cN = tN.childNodes[node];
				if (cN.nodeName == "result") {
					//myTrace("result=" + cN.toString());
					var thisResultNode = cN;
				}
			}
			// Read the condition
			for (var node in tN.childNodes) {
				var cN = tN.childNodes[node];
				if (cN.nodeName == "condition") {
					myTrace("condition=" + cN.toString());
					// One type of condition is where we simply look at the results for one other exercise - check that here
					if (cN.attributes.exerciseID) {
						// what is the test?
						var gtScoreTest = cN.attributes.greaterThanScore;
						var ltScoreTest = cN.attributes.lessThanScore;
						var gtCorrectTest = cN.attributes.greaterThanCorrect;
						var ltCorrectTest = cN.attributes.lessThanCorrect;
						var useRecord = cN.attributes.useRecord;
						// is there already a result for this in the scaffold?
						// Surely you should get this later, now is the time simply for understanding the condition
						//var scaffoldItem = _global.ORCHID.course.scaffold.getObjectByID(cN.attributes.exerciseID);
						//conditionExercises.push({id:cN.attributes.exerciseID, item:scaffoldItem, 
						conditionExercises.push({id:cN.attributes.exerciseID, 
											gtScoreTest:gtScoreTest, ltScoreTest:ltScoreTest, 
											gtCorrectTest:gtCorrectTest, ltCorrectTest:ltCorrectTest, 
											result:thisResultNode, useRecord:useRecord});
					} else if (cN.attributes.always == "true") {
						//myTrace("set default result");
						var defaultResult = thisResultNode;
					}
				}
			}
		}
	}
	// Query the database to get the data to match against the conditions.
	// Hold on. In the most likely navigation, we will simply be checking the score in an exercise we have just done, so it will be in the scaffold already!
	// I am not going to write any more condition processing until we need it. Will we need to check coverage for instance, or avg score for a unit?
	// Order is important, so we will reverse again
	//for (var i=0;i<conditionExercises.length; i++) {
	for (var i in conditionExercises) {
		var thisCon = conditionExercises[i];
		//myTrace("check condition, exerciseID=" + thisCon.id + " record=" + thisCon.useRecord);
		// See if we can find a scaffold item for this exercise
		var scaffoldItem = _global.ORCHID.course.scaffold.getObjectByID(thisCon.id);
		myTrace("found scaffoldItem " + scaffoldItem.caption);
		if (scaffoldItem) {
			//for (var j=0; j<scaffoldItem.progress.record.length; j++) {
			//	myTrace("idx=" + j + " correct=" + scaffoldItem.progress.record[j].correct);
			//}
			// which score do we take if there are more than one? first, last, best?
			if (thisCon.useRecord.toLowerCase().indexOf("best")>=0) {
				var useScore = 0;
				var useCorrect = 0;
				for (var j in thisCon.item.progress.record) {
					if (scaffoldItem.progress.record[j].score>useScore) useScore = scaffoldItem.progress.record[j].score;
					if (scaffoldItem.item.progress.record[j].Correct>useCorrect) useCorrect =scaffoldItem.progress.record[j].correct;
				}
			} else if (thisCon.useRecord.toLowerCase().indexOf("first")>=0) {
				myTrace("use the first item, which is idx=" + scaffoldItem.progress.record.length);
				var useScore = scaffoldItem.progress.record[scaffoldItem.progress.record.length-1].score;
				var useCorrect = scaffoldItem.progress.record[scaffoldItem.progress.record.length-1].correct;
			} else {
				myTrace("use the most recent item");
				var useScore = scaffoldItem.progress.record[0].score;
				var useCorrect = scaffoldItem.progress.record[0].correct;
			}
			myTrace("your score=" + useScore + " correct=" + useCorrect);
			// OK, compare our score/progress against the condition then
			if (thisCon.gtScoreTest && (Number(useScore)>Number(thisCon.gtScoreTest))) {
				//myTrace("this condition >" + Number(thisCon.gtScoreTest) + " against score=" + Number(useScore));
				myTrace("matched greaterThanScore");
				// it matched. Pick up the target from the result node, and act on it
				//myTrace("matched, so go to " + thisCon.result.attributes.exerciseID);
				//var targetExercise = thisCon.result.attributes.exerciseID;
				var targetExercise = thisCon.result;
				break;
			} else if (thisCon.ltScoreTest && (Number(useScore)<Number(thisCon.ltScoreTest))) {
				myTrace("matched lessThanScore");
				// it matched. Pick up the target from the result node, and act on it
				var targetExercise = thisCon.result;
				break;
			} else if (thisCon.gtCorrectTest && (Number(useCorrect)>Number(thisCon.gtCorrectTest))) {
				myTrace("matched greaterThanCorrect");
				//myTrace("this condition >" + Number(thisCon.gtCorrectTest) + " against score=" + Number(useCorrect));
				// it matched. Pick up the target from the result node, and act on it
				//myTrace("matched, so go to " + thisCon.result.attributes.exerciseID);
				var targetExercise = thisCon.result;
				break;
			} else if (thisCon.ltCorrectTest && (Number(useCorrect)<Number(thisCon.ltCorrectTest))) {
				myTrace("matched lessThanCorrect");
				// it matched. Pick up the target from the result node, and act on it
				var targetExercise = thisCon.result;
				break;
			}
		} else {
			// OK, now we really will have to go and query the database...
			myTrace("this condition doesn't match the scaffold");
		}
	}
	if (targetExercise==undefined) {
		// use the default
		myTrace("using default target=" + defaultResult.attributes.exerciseID);
		//targetExercise = defaultResult.attributes.exerciseID;
		targetExercise = defaultResult;
	}
	
	// Head for the target exercise, if we found one.
	if (targetExercise.attributes.exerciseID>0) {
		myTrace("attempting to head for exercise " + targetExercise.attributes.caption);
		this.clearExercise(0);
		//_global.ORCHID.session.nextItem = _global.ORCHID.course.scaffold.getObjectByID(1242806825156);
		this.createExercise(_global.ORCHID.course.scaffold.getObjectByID(targetExercise.attributes.exerciseID));
	} else {
		// Something unexpected, so best is just to head for the exit (or the menu??).
		_global.ORCHID.viewObj.cmdComplete();		
	}
}
creationNS.processExerciseXML = function(ExerciseXML){
	myTrace("processExerciseXML 6.5.5.1");
	if (ExerciseXML == null) {
		ExerciseXML = _global.ORCHID.randomExerciseXML;
	}
	//trace("XML=" + ExerciseXML.toString());
	var CurrentExercise = new _global.ORCHID.root.objectHolder.ExerciseObject();
	// for now, always clear out the array as we have hard-coded [0] into many places
	// and can only cope with 1 exercise anyway
	// _global.ORCHID.LoadedExercises[0] stores the exercise object for the current exercise
	// _global.ORCHID.LoadedExercises[1] stores the exercise object for the reading text if any
	// _global.ORCHID.LoadedExercises[2] stores the exercise object for the rule text if any
	var numLoaded = _global.ORCHID.LoadedExercises.length;
	for(i = 0; i < numLoaded; i++) {
		var temp = _global.ORCHID.LoadedExercises.pop();
		delete temp;
	}
	_global.ORCHID.LoadedExercises = [];
	// add this exercise object to the global holder
	var CountLE = _global.ORCHID.LoadedExercises.push(CurrentExercise)-1;
	//trace("this exercise is number " + CountLE);
	//this function will be called by raw XML
	CurrentExercise.rawXML = ExerciseXML;
	// the parsing of the XML into the exercise object is triggered by reading the exerciseID
	// so this will call populateExerciseFromXML
	// No, due to callbacks, lets force the populate call
	
	myCallBack = function() {
		myTrace("callback after processExerciseXML");
		// v6.5.5.1 Can we add in the instanceID check here instead of earlier?
		_global.ORCHID.user.compareInstanceIDWithDB();
	}
	// passing 0 into populateFromXML means processing an exercise xml
	// It seems that you have to use this myCallBack extra function otherwise you end up in the compareInstance 
	// function with the wrong scope.
	CurrentExercise.populateFromXML(myCallBack, 0);
	//CurrentExercise.populateFromXML(_global.ORCHID.user.compareInstanceIDWithDB, 0);
}
// v6.5.5.1 Trigger from compareInstanceID instead
creationNS.continueProcessExerciseXML = function() {
	myTrace("back to process exercise XML");
	var CurrentExercise = _global.ORCHID.LoadedExercises[0];
	//myTrace("after XML read splitScreen=" + _global.ORCHID.LoadedExercises[0].settings.misc.splitScreen);
	// although exID is not used anymore, this call still triggers the XML interpretation
	//var tempExID = CurrentExercise.getExerciseID();
	//myTrace(">> parsed the XML file at " + Number(getTimer() - _global.ORCHID.startTime));
	// all we want to do here is just get the exercise object populated
	// then call the exercise module to display it
	//trace("the structure for " + tempExID + " has been created");
	//var me = CurrentExercise.body.text.field;
	//for (var i in me) {
	//	trace("field " + i + " is " + me[i].answer[0].value);
	//}
	//Note: calling displayExercise through the localConnection seems to give a problem
	// if the number of questions in the random test is 6 or so! Yet it works
	// if the number is 1 or 2!
	// So, try connecting directly, and that seems to work
	//sender = new LocalConnection();
	//sender.send("controlConnection", "displayExercise", countLE);
	//trace("send message to controlConnection, countLE is " + countLE);
	//trace("message to controlConnection sent");
	//delete sender;
	// Note: why is one of these done with connection and one with direct call?
	// We have to clear the menu ourselves if we are not using the controller
	// 6.0.2.0 remove use of connections
	//sender = new LocalConnection();
	//sender.send("menuModule", "clearMenu");
	//delete sender;
	//_root.menuHolder.menuNS.clearMenu(); 
	// 6.0.2.0 remove use of connections
	//_root.exerciseHolder.myConnection.displayExercise(_global.ORCHID.LoadedExercises.length-1);
	//_root.exerciseHolder.exerciseNS.displayExercise(_global.ORCHID.LoadedExercises.length-1);
	
	// 6.0.4.0, get the rule/summary xml
	// EGU doesn't use rules, so for speed lets not do this call
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	} else {
		var thisItem = _global.ORCHID.menuXML.getItemNodeByID(_global.ORCHID.session.currentItem.id);
		var ruleID = thisItem.parentNode.attributes["ruleID"];
		//myTrace("menu.rule=" + ruleID);
		var ruleItem = _global.ORCHID.menuXML.getItemNodeByID(ruleID);
		if(ruleItem != undefined || ruleItem != null) {
			// v6.4.2.8 We use filename not action anymore
			//CurrentExercise.rule = thisItem.attributes["action"] + ".xml";
			CurrentExercise.rule = ruleItem.attributes["fileName"];
			CurrentExercise.ruleEnabledFlag = ruleItem.attributes["enabledFlag"];
			//myTrace("we want to have a rule with this exercise - " + CurrentExercise.rule + " eF=" + CurrentExercise.ruleEnabledFlag);
		}
		// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
		// Or it might be that it is an exercise level attribute. Try the exercise first, then the unit.
		myTrace("exercise has relatedID=" + thisItem.attributes["relatedID"]);
		var relatedID = thisItem.attributes["relatedID"];
		if (relatedID!=undefined) {
			var thisRelatedItem = _global.ORCHID.menuXML.getItemNodeByID(relatedID);
			if(thisRelatedItem != undefined || thisRelatedItem != null) {
				// v6.4.2.8 We use filename not action anymore
				//CurrentExercise.rule = thisItem.attributes["action"] + ".xml";
				CurrentExercise.related = thisRelatedItem.attributes["fileName"];
				CurrentExercise.relatedEnabledFlag = thisRelatedItem.attributes["enabledFlag"];
				myTrace("we want to have a related with this exercise - " + CurrentExercise.related + " eF=" + CurrentExercise.relatedEnabledFlag);
			}
		} else {
			var relatedID = thisItem.parentNode.attributes["relatedID"];
			//myTrace("menu.related=" + relatedID);
			if (relatedID!=undefined) {
				var thisRelatedItem = _global.ORCHID.menuXML.getItemNodeByID(relatedID);
				if(thisRelatedItem != undefined || thisRelatedItem != null) {
					// v6.4.2.8 We use filename not action anymore
					//CurrentExercise.rule = thisItem.attributes["action"] + ".xml";
					CurrentExercise.related = thisRelatedItem.attributes["fileName"];
					CurrentExercise.relatedEnabledFlag = thisRelatedItem.attributes["enabledFlag"];
					myTrace("we want to have a related with this exercise - " + CurrentExercise.related + " eF=" + CurrentExercise.relatedEnabledFlag);
				}
			}
		}
	}
	//myTrace("ruleID = " + ruleID + ", rule = " + CurrentExercise.rule);
	
	displayExercise = function() {
		//myTrace("creation.as:now display the exercise");
		// this is where you should remove the menu to get a clean switch
		// v6.3.6 Merge menu to main
		// v6.4.2.7 CUP menu merge
		// Shouldn't this be to menuNS?
		//_global.ORCHID.root.mainHolder.clearMenu();
		myTrace("creation.call displayEx");
		_global.ORCHID.root.mainHolder.menuNS.clearMenu();
		// v6.3.4 This should be done at the end of exerciseNS.displayExercise, not here
		//_global.ORCHID.viewObj.clearAllScreens();
		//_global.ORCHID.viewObj.displayScreen("ExerciseScreen");
		// v6.3.6 Merge exercise into main
		//_root.exerciseHolder.exerciseNS.displayExercise(0);
		_global.ORCHID.root.mainHolder.exerciseNS.displayExercise(0);
	}
	processReadingTextXML = function(ReadingTextXML) {
		var CurrentText = new _global.ORCHID.root.objectHolder.ExerciseObject();
		//_global.ORCHID.LoadedExercises[1] is used for storing reading text object
		_global.ORCHID.LoadedExercises[1] = CurrentText;
		CurrentText.rawXML = ReadingTextXML;
		myCallBack = function() {
			displayExercise();
		}
		// passing 1 into populateFromXML means processing a reading text xml
		CurrentText.populateFromXML(myCallBack, 1);
	}
	// v6.3.4 Use settings not mode
	// v6.3.4 Reading text
	// is now in the <texts> node, so the XML has already been processed with the 
	// main body. Therefore all you need to do is display exercise
	//if(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.SplitWindow) {
	//if (_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen) {
		//trace("split screen");
		//var currentEx = _global.ORCHID.LoadedExercises[0];
		/*
		for (var i in currentEx.body.text.media) {
			// v6.3.4 There may be many m:text nodes. Only mode=1 is used for reading text
			if (currentEx.body.text.media[i].type == "m:text" &&
				currentEx.body.text.media[i].mode == 8) {
				var readingTextFile = currentEx.body.text.media[i].filename;
				//myTrace("Reading text is " + readingTextFile);
				break;
			}
		}
		ReadingText = new XML();
		ReadingText.ignoreWhite = true;
		ReadingText.onLoad = function(success) {
			if (success) {
				processReadingTextXML(this);
				myTrace("load reading text xml successfully");
			} else {
				myTrace("fail to load reading text xml with code: " + this.status);
				displayExercise();
			}
		}
		// reading text xml is in exercises folder
		// v6.3.4 Anti-cache on the reading text too
		if(_global.ORCHID.online){
		   var cacheVersion = "?version=" + new Date().getTime();
		}else{
		   var cacheVersion = ""
		}
		//myTrace("load exercise: " + fileName + cacheVersion);
		ReadingText.load(_global.ORCHID.paths.root + _global.ORCHID.paths.exercises + readingTextFile + cacheVersion);
		*/
	//} else {
	//	displayExercise();
	//}
	displayExercise();
}

