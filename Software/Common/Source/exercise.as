exerciseNS.displayExercise = function(exerciseNum) {
	//myTrace("in display exercise " + exerciseNum);
	// If you are running in a browser that you had to scroll, try to go back to the top now
	this.startTime = new Date().getTime();
	fscommand("scrolltop", "");
	this.exerciseNum = exerciseNum;
	var CurrentExercise = _global.ORCHID.LoadedExercises[this.exerciseNum];
	//trace(">> start display at " + Number(getTimer() - _global.ORCHID.startTime));

	//convert the styles listed in the xml file to a list of global textFormat objects
	_global.ORCHID.root.objectHolder.setExerciseStyles(); 

	//display the title information from the exercise object
	var thisText = CurrentExercise.title.text;
	//trace("title is " + thisText.paragraph.length);
	var paneType = "scroll pane";
	var paneName = "Title_SP";
	var substList = new Array();
	//substList[0] = {tag:"#ya#", text:stdAnswer};
	//trace("call to ppots that does not require tlc")
	//myTrace("show title (proportion=" + _global.ORCHID.tlc.proportion + ")");
	// v6.3.4 Move specific tlc settings to here
	// v6.3.5 I am increasingly concerned that calling ppots twice in a row
	// without waiting for a callback is causing problems as both are using
	// the same global tlc (even if you are not doing tlc looping). So try
	// adding in a callback for every region no matter how big. (This will also
	// completely avoid the problem of non scrolls that don't finish quickly.
	// V6.4.2.4 This should start at 25% coming from loading and parsing of the XML. But display.as overwrites anyway.
	//myTrace("exercise.title, current % is " + _global.ORCHID.tlc.controller.getPercentage());
	_global.ORCHID.tlc = {proportion:5, 
							//startProportion:0,
							callBack:this.afterTitleCallback};
	//myTrace("ppots title with proportion=0");
	_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, paneType, paneName, substList);
	//myTrace("call ppots for title from this=" + this.moduleName);
	//trace("done title");
	
}
exerciseNS.afterTitleCallback = function() {
	// v6.3.5 Keep going with the next region
	//myTrace("in title callback, exerciseNum=" + exerciseNS.exerciseNum);
	//myTrace("this=" + exerciseNS.moduleName);
	var CurrentExercise = _global.ORCHID.LoadedExercises[exerciseNS.exerciseNum];
	// display example region (if there is one)
	if (CurrentExercise.regions & _global.ORCHID.regionMode.example) {
		var thisText = CurrentExercise.example.text;
		//trace("title is " + thisText.paragraph.length);
		var paneType = "scroll pane";
		var paneName = "Example_SP";
		var substList = new Array();
		//substList[0] = {tag:"#ya#", text:stdAnswer};
		//trace("call to ppots that does not require tlc")
		_global.ORCHID.tlc = {proportion:5, 
							//startProportion:5,
							callBack:exerciseNS.afterExampleCallback};
		//myTrace("ppots example with proportion=0");
		_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, paneType, paneName, substList);
	} else {
		exerciseNS.afterExampleCallback();
	}
}
exerciseNS.afterExampleCallback = function() {
	// v6.3.5 Keep going with the next region
	//myTrace("in example callback");
	var CurrentExercise = _global.ORCHID.LoadedExercises[exerciseNS.exerciseNum];
	if (CurrentExercise.regions & _global.ORCHID.regionMode.noScroll) {
		var thisText = CurrentExercise.noScroll.text;
		//trace("title is " + thisText.paragraph.length);
		var paneType = "scroll pane";
		var paneName = "NoScroll_SP";
		var substList = new Array();
		//substList[0] = {tag:"#ya#", text:stdAnswer};
		//myTrace("noScroll.title, current % is " + _global.ORCHID.tlc.controller.getPercentage());
		_global.ORCHID.tlc = {proportion:5, 
							//startProportion:10,
							callBack:exerciseNS.afterNoScrollCallback};
		//myTrace("ppots no scroll with proportion=0");
		_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, paneType, paneName, substList);
	} else {
		exerciseNS.afterNoScrollCallback();
	}
}
exerciseNS.afterNoScrollCallback = function() {
	// v6.3.5 Keep going with the next region
	//myTrace("in noScroll callback");
	var CurrentExercise = _global.ORCHID.LoadedExercises[exerciseNS.exerciseNum];
	//handle split screen reading text
	// v6.3.4 Split screen done through settings
	//if(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.SplitWindow) {
	//myTrace("exercise.swf splitScreen=" + _global.ORCHID.LoadedExercises[0].settings.misc.splitScreen);
	if(_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen) {
		// v6.3.4 move reading text to <texts> node
		//var thisText = _global.ORCHID.LoadedExercises[1].body.text;
		// get the texts id from the media thing
		//myTrace("texts[0].id=" + _global.ORCHID.LoadedExercises[0].texts[0].id);
		var textArrayIDX = _global.ORCHID.root.objectHolder.lookupArrayItem(_global.ORCHID.LoadedExercises[0].texts, 
											_global.ORCHID.LoadedExercises[0].readingText.id, "ID");
		var thisText = _global.ORCHID.LoadedExercises[0].texts[textArrayIDX].text;
		//myTrace("reading text id=" + _global.ORCHID.LoadedExercises[0].readingText.id + " idx=" + textArrayIDX);
		//myTrace("reading text=" + thisText.paragraph[0].plainText);
		var paneType = "ex.fla: scroll pane";
		var paneName = "ReadingText_SP";
		var substList = new Array();
		//myTrace("exercise.readingText, current % is " + _global.ORCHID.tlc.controller.getPercentage());
		_global.ORCHID.tlc = {proportion:25,
							//startProportion:15,
							callBack:exerciseNS.afterSplitScreenCallback}
		//myTrace("ppots reading text with proportion=50");
		_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, paneType, paneName, substList);
	} else {
		exerciseNS.afterSplitScreenCallback();
	}
}
exerciseNS.afterSplitScreenCallback = function() {
	// v6.3.5 Keep going with the next region
	//myTrace("in split screen callback");
	var CurrentExercise = _global.ORCHID.LoadedExercises[exerciseNS.exerciseNum];
	//display the main text information in the exercise object
	// initialise exercise variables
	// v6.3.6 Merge exercise into main
	_global.ORCHID.root.mainHolder.dropZoneList = new Array();
	var thisText = CurrentExercise.body.text;
	var paneType = "scroll pane";
	var paneName = "Exercise_SP";
	var substList = new Array();
	substList[0] = {tag:"#q", text:"#"};
	// v6.4.2.4 Several options mean you don't know what % is left in the progress bar, so calculate it
	var remainingProportion = 100 - _global.ORCHID.tlc.controller.getPercentage();
	//myTrace("exercise.body, current % is " + _global.ORCHID.tlc.controller.getPercentage() + " remaining=" + remainingProportion + "%");
	//_global.ORCHID.tlc = {proportion:60,
	//					startProportion:40,
	_global.ORCHID.tlc = {proportion:remainingProportion,
						callBack:exerciseNS.completeDisplayCallback};
	//myTrace("ppots exercise with proportion=75");
	_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, paneType, paneName, substList);
}
// callback to recognise that ppots for the exercise has finished
exerciseNS.completeDisplayCallback = function() {
	var stopTime = new Date().getTime();
	//myTrace("exercise display took " + (stopTime - this.startTime));
	//trace(">> set up the exercise at " + Number(getTimer() - _global.ORCHID.startTime));
	
	// display the exercise name information from the exercise object
	// Note: clearly this should NOT happen here but somewhere in a presenter part of MVP
	// or on the interface scripts, indeed anywhere OTHER than here please!
	//var mySep = "&nbsp;>&nbsp;";
	var fullName = "";
	var thisUnit = _global.ORCHID.session.currentItem.unit;
	//trace("this unit=" + thisUnit);
	// v6.4.2.7 -16 seems to be the unit and id actually!
	// unit = -1 means it is a random exercise
	//if (thisUnit != -1) {
	if (thisUnit != -16) {
		var thisItemID = _global.ORCHID.session.currentItem.ID;
		var namePath = _global.ORCHID.course.scaffold.getParentCaptions(thisItemID);
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			var mySep = "<br>";
		} else {
			var mySep = " &gt; ";
		}
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BC/IELTS") >= 0) {
			//myTrace("BC so add coursename=" + namePath[0]);
			fullName = namePath[0] + mySep;
		}
		fullName += namePath[1] + mySep + namePath[2];
		if (namePath[3] != undefined) {
			fullName += mySep + namePath[3];
		}
	} else {
		//var thisItemID = -1;
		var thisItemID = _global.ORCHID.session.currentItem.ID;
		//myTrace("name from test " + thisItemID);
		fullname = _global.ORCHID.session.currentItem.caption;
	}
	//myTrace("I want caption=" + fullName);
	// v6.4.3 I want to add the MGS name to the end of the breadcrumbs so that you can see it was edited
	// but only when I am running TB or SSS etc. Not in Author Plus courses
	// v6.5 You also only want to show if you are actually running in MGS, not just based on the eFlag
	// v6.5.6 No longer, it is totally flag based now. Not sure about AP
	myTrace("exercise.eF + " + _global.ORCHID.session.currentItem.enabledFlag + " true=" + (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited));
	//myTrace("edit group name is " + _global.ORCHID.session.currentItem.groupName);
	
	//if ((_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited) &&
	//	(_global.ORCHID.commandLine.MGSRoot != undefined) && 
	//	(_global.ORCHID.root.licenceHolder.licenceNS.product.toLowerCase().indexOf("author plus")<0))	{
	if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited) {
		myTrace("add edited groupname=" + _global.ORCHID.session.currentItem.groupName);
		//fullName += _global.ORCHID.literalModelObj.getLiteral("editedBy", "labels") + _global.ORCHID.user.MGSName;
		var substList = [{tag:"[x]", text:_global.ORCHID.session.currentItem.groupName}];
		//myTrace("subst=" + substTags(_global.ORCHID.literalModelObj.getLiteral("editedBy", "labels"), substList));
		fullName += _global.ORCHID.root.objectHolder.substTags(_global.ORCHID.literalModelObj.getLiteral("editedBy", "labels"), substList);
	}
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.exDetails.setLabel(fullName);
	//trace("path for item " + thisItemID + " has " + namePath.length + " items = " + namePath.toString());
	// EGU - Just use the last two items in the name path (unit and exercise)
	//for (var i =0;i<namePath.length; i++) {
	//	fullName+=namePath[i] + mySep;
	//}
	// get rid of the last >
	// EGU no need
	//fullName = fullName.substr(0,fullName.length-mySep.length);
	
	// v6.2 the exdetails are now part of the screen design
	/*
	//trace("unit is " + thisUnit);
	var myX = 25; 
	var myY = 0; 
	var myW = 750;
	var myH = 15; // these are faked here for now (w=750)
	// CUP/GIU change these settings
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		myX=209; myY=0; myW=550; myH=10;
	}
	var myDepth = _global.ORCHID.TitleDepth-2;
	// pull in a MC from linkage that has two text fields in it to hold our stuff
	var myDetails = _root.exerciseHolder.attachMovie("ExerciseDetails", "ExDetails", myDepth++);
	myDetails._x = myX;
	myDetails._y = myY;
	myDetails.exerciseCaption.autosize = "left";
	myDetails.exerciseCaption.htmlText = fullName;
	//trace("ExDetails: " + myDetails.UnitName.text + " " + myPane.ExName.text);	
	*/
	
	// 6.0.4.0, store the time that the user start to do the exercise
	// so that we can calculate the duration when inserting the score record to database
	_global.ORCHID.session.currentExStartTime = new Date().getTime();

	// set the buttons that you want to see
	// 6.0.2.0 remove connection
	//_root.buttonsHolder.myConnection.setState("exercise");
	//_root.buttonsHolder.buttonsNS.setState("exercise");
	_global.ORCHID.viewObj.clearAllScreens();
	_global.ORCHID.viewObj.displayScreen("ExerciseScreen");
	
	// TIMING: now you can ditch the progress bar as it is not used anymore
	//_global.ORCHID.tlc.controller.removeMovieClip();
	//delete _global.ORCHID.tlc;
	// v6.3.4 Just stop the controller's functions (although it should have happened anyway)
	var tlcController = _global.ORCHID.tlc.controller;
	tlcController.stopEnterFrame();
	tlcController.setEnabled(false);

	//v6.3.4 Handle timed exercises
	if (_global.ORCHID.LoadedExercises[0].settings.misc.timed > 0) {
		//var myController = _root.buttonsHolder.ExerciseScreen.createEmptyMovieClip("timedController", _root.buttonsHolder.buttonsNS.depth++);
		//myController = _global.ORCHID.tlc.controller;
		//tlc.controller = _global.ORCHID.root.tlcController;
		var timerBar = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exTimer.timerBar;
		//myTrace("add a timer as " + timerBar);
		//timerBar.setEnabled(true);
		timerBar.duration = _global.ORCHID.LoadedExercises[0].settings.misc.timed * 1000;
		// v6.5.6.3 I might want different labels for single screen timers and subunit timers - so do this call later
		if (_global.ORCHID.session.subunit) {
			timerBar.setLabel(_global.ORCHID.literalModelObj.getLiteral("timeLeftSubUnit", "labels"));
		} else {
			timerBar.setLabel(_global.ORCHID.literalModelObj.getLiteral("timeLeft", "labels"));
		}
		
		timerBar.countDown = function() {
			// v6.5.5.0 Don't pick up start time from exercise in case this is part of a subunit
			//var usedUp = new Date().getTime() - _global.ORCHID.session.currentExStartTime;
			var usedUp = new Date().getTime() - this.startTime;
			var timeLeft = this.duration - usedUp;
			//myTrace("countDown=" + timeLeft + " in " + this);
			if (timeLeft <= 0) {
				clearInterval(this.countDownInt);
				// v6.5.5.0 If this is not the last exercise in a subunit, you will not just jump to the next
				// as you will need to go to the one after the last subunit
				if (_global.ORCHID.session.subunit) {
					// OK, it might be complicated as we are in a subunit
					myTrace("timer finished, in a subunit");
					if (_global.ORCHID.session.subunit.status.indexOf("last")>=0) {
						// It's OK, this is the last exercise so just plod on anyway
						myTrace("but it is the last exercise anyway");
					} else {
						// Fine, we have run out of time for this whole subunit, so jump to the 
						// exercise that has a different subunit.
						// do-while because we know that the nextItem we currently have has the same subunit
						var testNextItem = _global.ORCHID.session.nextItem;
						myTrace("current nextItem=" + testNextItem.caption + ".group=" + testNextItem.group);
						do {
							testNextItem = _global.ORCHID.course.scaffold.getNextItemID(testNextItem.ID);
							myTrace("test nextItem=" + testNextItem.caption + ".group=" + testNextItem.group + ".id=" + testNextItem.id);
						} while (testNextItem.group == _global.ORCHID.session.currentItem.group);
						// We have found the start of the next group (or an exercise not in a group), so make this the nextItem
						_global.ORCHID.session.nextItem=testNextItem;
						// Also clear the subunit object to make sure we start afresh
						_global.ORCHID.session.subunit.status+="last";
					}
				}
				// v6.4.1.3 If this doesn't have a marking button, use moveExercise
				if (!_global.ORCHID.LoadedExercises[0].settings.buttons.marking) {
					_global.ORCHID.viewObj.moveExercise(undefined, "forward");
				} else {
					_global.ORCHID.viewObj.cmdMarking();
				}

				//delete _root.timedController;
				delete this.countdown;
				this.setEnabled(false);
			} else if (timeLeft > 30000) {
				this.setPercentage(Math.floor(100 * usedUp / this.duration));
				var rounded = Math.round(timeLeft/30000); // divide by 30 secs
				if (rounded == 2) {
					this.setCaption(_global.ORCHID.literalModelObj.getLiteral("oneMinute", "labels"));
				} else {					
					this.setCaption(_global.ORCHID.root.objectHolder.findReplace(_global.ORCHID.literalModelObj.getLiteral("minutes", "labels"), "[x]", rounded/2));
					//myTrace("caption=" + _global.ORCHID.root.objectHolder.findReplace(_global.ORCHID.literalModelObj.getLiteral("minutes", "labels"), "[x]", rounded/2));
				}
			} else {
				//myTrace("set %=" + Math.floor(100 * usedUp / this.duration));
				this.setPercentage(Math.floor(100 * usedUp / this.duration));
				this.setCaption(_global.ORCHID.root.objectHolder.findReplace(_global.ORCHID.literalModelObj.getLiteral("seconds", "labels"), "[x]", Math.floor(timeLeft/1000)));
			}
		}
		//myController.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.movie + "onEnterFrame.swf", initObj);
		//myController.attachMovie("progressBar", "progressBar", 0, initObj);
		//timerBar.enableLabel(true);
		//timerBar.setLabel("Timed exercise");
		
		// v6.5.5.0 (FB2) If exercise is part of a continuing subunit, don't clear the timer
		myTrace("this ex is subunit.status=" + _global.ORCHID.session.subunit.status);
		if (_global.ORCHID.session.subunit.status == "continue" || _global.ORCHID.session.subunit.status == "last") {
			//myTrace("existing timerInt=" + timerBar.countDownInt);
		} else {
			myTrace("start the timer at 0");
			timerBar.setPercentage(0);
			// v6.5.5.0 Set the start time
			timerBar.startTime = _global.ORCHID.session.currentExStartTime;
			timerBar.countDownInt = setInterval(timerBar, "countDown", 1000);
			//myTrace("new timerInt=" + timerBar.countDownInt);
		}
	}
}
exerciseNS.markExercise = function() {
	myTrace("markExercise:call mainMarking");
	_global.ORCHID.root.objectHolder.mainMarking();
}
exerciseNS.displayAllFeedback = function(setting) {
	myTrace("displayAllFeedback");
	_global.ORCHID.LoadedExercises[0].feedbackSeen = true;
	//trace("for " + _global.ORCHID.LoadedExercises[0].name + " set .feedbackSeen to " + _global.ORCHID.LoadedExercises[0].feedbackSeen);
	_global.ORCHID.root.objectHolder.delayedFeedback(setting);
}
exerciseNS.clearExercise = function(exerciseNum) {
	myTrace("exerciseNS.clearExercise");
	// Note: can you go through all MC that are attached to the exerciseHolder?
	// v6.3.4 They are now all attached to buttonsHolder
	//_root.buttonsHolder.ExerciseScreen.Title_SP.removeMovieClip();
	// CUP noScroll code
	//_root.buttonsHolder.ExerciseScreen.NoScroll_SP.removeMovieClip();
	//_root.buttonsHolder.ExerciseScreen.Example_SP.removeMovieClip();
	//_root.buttonsHolder.ExerciseScreen.Exercise_SP.removeMovieClip();
	//_root.buttonsHolder.ExerciseScreen.Feedback_SP.removeMovieClip();
	//_root.buttonsHolder.ExerciseScreen.Stats_SP.removeMovieClip();
	//_root.buttonsHolder.ExerciseScreen.Hint_SP.removeMovieClip();
	//_root.buttonsHolder.ExerciseScreen.ReadingText_SP.removeMovieClip();
	// v6.3.5 Really need a better way to hide and remove stuff created in the exercise
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController._visible = false;
	// v6.4.2.7 Clear out stuff that has been linked to the controller.
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.incorrectClicks = 0; 
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.guessList_cb.removeAll();
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.word_i.text = "";
	
	// immediately clear out the exercise title (it tends to get in the way
	// of the progress bar) v6.3.6 This was wrong ExerciseScreen.ExerciseScreen
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.exDetails.setLabel("");
	// v6.3.6 navMsgBox is only on the messageScreen, not ExerciseScreen
	//_root.buttonsHolder.ExerciseScreen.navMsgBox.removeMovieClip();
	_global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox.removeMovieClip();
	// v6.4.1 clear out any media screens still showing
	_global.ORCHID.root.buttonsHolder.MessageScreen.media_SP.removeMovieClip();
	
	// v6.5.6.6 Specifically clear the shrink/expand buttons used in CP2 so they don't hang around.
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.shrinkExample_pb.setEnabled(false);
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.expandExample_pb.setEnabled(false);
	
	//remove reading all the scroll panes
	for (var i in _global.ORCHID.root.buttonsHolder.ExerciseScreen) {
		if (_global.ORCHID.root.buttonsHolder.ExerciseScreen[i]._name != undefined &&
			_global.ORCHID.root.buttonsHolder.ExerciseScreen[i]._name.indexOf("_SP") >= 0) {
			myTrace("remove " + _global.ORCHID.root.buttonsHolder.ExerciseScreen[i]._name);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen[i].removeMovieClip();
		}
	}
	//_global.ORCHID.LoadedExercises[exerciseNum] = undefined;
	//trace("exercise.clearEx: request jukebox.clearAll");
	_global.ORCHID.root.jukeboxHolder.myJukeBox.clearAll();
	_global.ORCHID.root.jukeboxHolder.resourcesList.removeMovieClip();
	// v6.4.2.5 Also init the jukebox.
	_global.ORCHID.root.jukeboxHolder.myJukeBox.initProperties();
	// v6.5.5.6 And the video list
	_global.ORCHID.root.jukeboxHolder.videoList = new Array(); 
	// v6.4.2.5 just in case the mouse got lost!!
	Mouse.show();

	// v6.4.2.4 Also clear any streamer you added directly to the exercise screen
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.streamer.removeMovieClip();
	
	// v6.3.6 Merge exercise into main
	_global.ORCHID.root.mainHolder.dropZoneList = new Array();
	// in pPOTS you need to call twf.addDropsForHittest
	// then once you start dragging you need a clipevent or setInterval
	// to run through a test against all covers in this list and if
	// you hit one use twf and field to setFieldBackground on or off.
	// v6.2 Get rid of any typing or select box
	// v6.3.6 Merge exercise into main
	// (but should this gapHolder be on buttons?)
	//_root.exerciseHolder.gapHolder.removeMovieClip();
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.gapHolder.removeMovieClip();
	
	// v6.2 remove the old play from the recorder when you go to a new exercise
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.exRecorder_mc.reset();
	// v6.3.5 Remove the countdown controller if you were in that type of exercise
	// This is now (properly) done in the screens module
	//_root.buttonsHolder.ExerciseScreen.cdController.removeMovieClip();
	
	//v6.4.1 Clear the timer, if there was one left running
	// v6.5.5.0 No - we may want to keep it going for subunits.
	if (_global.ORCHID.session.subunit == undefined) {
		clearInterval(_global.ORCHID.root.buttonsHolder.ExerciseScreen.exTimer.timerBar.countDownInt);
	}
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.exTimer._visible = false;

	// v6.4.2.8 Remove buttons now so they don't overlap
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.exFeedback_pb.setEnabled(false);
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.navStartAgain_pb.setEnabled(false);

	// v6.2 Clear out any click limit you were accumulating
	//myTrace("clear out session.currentItem settings");
	_global.ORCHID.session.currentItem.clicks = 0;
	// v6.3.2 and knowledge that you had done anything
	_global.ORCHID.session.currentItem.scoreDirty = false;
	_global.ORCHID.session.currentItem.marked = false;
	_global.ORCHID.session.currentItem.afterMarking = false;	
	
	// v6.5.5.6 For the recorder compare function
	_global.ORCHID.session.currentItem.lastAudioFile = undefined;
	// v6.5.5.8 And to release the always on top if it was set
	_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdReleaseAlwaysOnTop");
	// v6.5.5.8 Check that the recorder is still running if it was before
	myTrace("clearing the ex so check the recorder");
	_global.ORCHID.root.controlNS.retestClarityRecorder();

	
}
exerciseNS.printExercise = function() {
	//Note: if the fieldCovers (or anything else) uses an _alpha transparency, you must use
	//printAsBitmap otherwise the _alpha is set to 100%, but the quality of text is poor
	//printAsBitmap(_root.exerciseHolder.Exercise_SP, "bmax");	
	//print(_root.exerciseHolder.Exercise_SP, "bmax");
	//Note: you should also really attach the Title_SP to the top of the Exercise_SP 
	// before printing somehow
	// So build up a new MC that holds the title + exercise and (temporarily) 
	// switches off the fieldcovers
	var scrollPane = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP;
	var content = scrollPane.tmp_mc;
	
	// v6.2 Using Flash 7 printing
	_global.ORCHID.root.printingHolder.printForMe(_global.ORCHID.root.buttonsHolder.ExerciseScreen);
	return;
/*	
	//_level0.exerciseHolder.Exercise_SP.tmp_mc.ExerciseBox8.FC4015
	for (var i in content) {
		//trace(base[i]._name);
		if (content[i]._name.indexOf("ExerciseBox") == 0) {
			for (var j in content[i]) {
				if (content[i][j]._name.indexOf("FC") == 0) {
					//trace(base[i][j]._name);
					content[i][j]._visible = false;
				}
			}
		}
	}
	// if you print exerciseHolder - you get feedback and title as well, but
	// if the exercise scrolls you do not get the bottom stuff. Exercise_SP
	// also does not scroll. .tmp_mc is blank - I don't know why.
	//var printEx = base.duplicateMovieClip("copyForPrintEx", _global.ORCHID.PrintDepth);
	//trace("just created " + printEx + " as a duplicate");
	//for (var i in printEx) {
	//	trace(printEx[i]._name + " is part of print thing");
	//}
	// how about just removing the scroll?
	_root.exerciseHolder.origScrollPaneHeight = scrollPane.getPaneHeight();
	_root.exerciseHolder.origScrollPaneWidth = scrollPane.getPaneWidth();
	//trace("scrollPane w, h=" + _root.exerciseHolder.origScrollPaneWidth + ", " + _root.exerciseHolder.origScrollPaneHeight);
	//trace("content height=" + content._height);
	scrollPane.setSize(_root.exerciseHolder.origScrollPaneWidth, content._height);
	scrollPane.refreshPane();	
	print(_root.exerciseHolder, "bmax");
	// how to know when you come back from the printing as that is when you want
	// to switch on the fields again. Perhaps you could just wait for a click on
	// the movie?
	_root.exerciseHolder.onMouseDown = function() {
		// set scroll pane back to the original (this is not going to look great!)
		// maybe you need to use a message box or some otherway of knowing when printing is done
		this.Exercise_SP.setSize(_root.exerciseHolder.origScrollPaneWidth, _root.exerciseHolder.origScrollPaneHeight);
		var content = this.Exercise_SP.tmp_mc;
		for (var i in content) {
			//trace(base[i]._name);
			if (content[i]._name.indexOf("ExerciseBox") == 0) {
				for (var j in content[i]) {
					//trace(base[i][j]._name);
					if (content[i][j]._name.indexOf("FC") == 0) {
						content[i][j]._visible = true;
					}
				}
			}
		}
		delete this.onMouseDown;
	}
*/
}
