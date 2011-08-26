// v6.5.5.2 For talking to javascript based recorder
//import flash.external.*;
//var isAvailable:Boolean = ExternalInterface.available;

// v6.4.3 This causes a problem - since you should either be using _global.ORCHID or just this.
//_global.View = function() {
View = function() {
	myTrace("create new view object");
	//this.container = container;
	this.depth = 1;
	this.screens = new Array();
}

// v6.5.1 Yiu Stop the recorder
View.prototype.stopRecording	= function()
{
	// v6.5.4.1 case sensitive - not commented anywhere else in this file, just done
	//_global.ORCHID.root.buttonsHolder.exerciseScreen.stop_pb.onRelease();
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.stop_pb.onRelease();
}

// v6.5.1 Yiu check if something recorded
View.prototype.isSomethingRecorded	= function()
{
	var bSomethingRecorded:Boolean;
	//_global.myTrace("____ startTime: " + _global.ORCHID.root.buttonsHolder.ExerciseScreen.record_pb.startTime);
	bSomethingRecorded	= !((_global.ORCHID.root.buttonsHolder.ExerciseScreen.record_pb.startTime == 0) || (_global.ORCHID.root.buttonsHolder.ExerciseScreen.record_pb.startTime == undefined));
	return bSomethingRecorded;
}

//display a movieclip in the screens array
View.prototype.displayScreen = function(screenName) {
	myTrace("view.displayScreen("+screenName+")");
	switch(screenName) {
		case "CourseListScreen":
			// v6.3.4 switch progress to buttons holder
			//_global.ORCHID.root.progressHolder.navMsgBox.removeMovieClip();
			_global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox.removeMovieClip(); 
			// v6.3.6 Merge exercise into main
			_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
			// v6.3.4 scope of clear menu function
			// v6.3.6 Merge menu to main
			myTrace("courseListScreen clearMenu");
			_global.ORCHID.root.mainHolder.menuNS.clearMenu();
			// the slight confusion over screen display is due to the first time not wanting to lose
			// the existing base+intro - and then later on wanting to clear out later screens and
			// get back to base+intro. It would be more efficent if you KNEW that you had come from Exit+Restart
			// and then could do the following two lines only then.
			// But this results in a double audio sting with the standard Clarity APO customIntro
			if (_global.ORCHID.root.buttonsHolder.IntroScreen._visible == false) {
				myTrace("intro screen not visible, so redisplay it")
				this.clearAllScreens();
				this.displayScreen("IntroScreen");
			} else {
				myTrace("intro screen already displayed, don't redo");
			}
			// v6.3.4 If any progress bar is visible, remove it as distracting for user action
			//myTrace("tlc.controller=" + _global.ORCHID.tlc.controller);
			_global.ORCHID.root.tlcController.setEnabled(false);
			break;
		case "LoginScreen":
			// v6.3.4 If any progress bar is visible, remove it as distracting for user action
			//myTrace("tlc.controller=" + _global.ORCHID.tlc.controller);
			_global.ORCHID.root.tlcController.setEnabled(false);
			break;
		case "MenuScreen":
			if(_global.ORCHID.root.buttonsHolder.MessageScreen.score_SP != undefined) {
				_global.ORCHID.root.buttonsHolder.MessageScreen.score_SP.removeMovieClip();
			}
			// v6.3.6 Merge exercise into main
			_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
			// v6.3.4 Handmade menus might not need all of this, so move all of it to menu where you can do what you want
			// v6.3.6 Merge menu to main
			_global.ORCHID.root.mainHolder.menuNS.displayMainMenu();
			/*
			var progressItems = _global.ORCHID.course.scaffold.getItemsByID(_global.ORCHID.course.scaffold.id);
			// v6.2.1 CUP You only need to prime the menu once, so to save time don't need
			// to get items again, but just do the first time primer
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				if (_global.ORCHID.root.menuHolder.menu.myItem0 == undefined) {
					//trace("going to setup menu the first time");
					var menuItems = _global.ORCHID.menuXML.getMenuItemByID(_global.ORCHID.course.scaffold.id);
					_global.ORCHID.root.menuHolder.menuSetup(menuItems);
					// this should be the end of reading from the menu object - so delete it
					delete _global.ORCHID.menuXML;
					//var rc = delete _global.ORCHID.menuXML;
					//trace("delete of menuXML=" + rc);
				}
			} else {
				var menuItems = _global.ORCHID.menuXML.getMenuItemByID(_global.ORCHID.course.scaffold.id);
				_global.ORCHID.root.menuHolder.addMenuEventListener(_global.ORCHID.root.controlNS);
			}
			// v6.2 move the menu settings file into the course level - I hope that this will actually
			// disappear - but if not at least it should use APO defaults if a specific menu.txt file does not exist
			_global.ORCHID.root.menuHolder.displayMainMenu(menuItems, _global.ORCHID.paths.root + _global.ORCHID.paths.subCourse+"menu.txt", progressItems);
			*/

			this.clearAllScreens();
			break;
		case "ExerciseScreen":
			if (_global.ORCHID.root.buttonsHolder.MessageScreen.score_SP != undefined) {
				_global.ORCHID.root.buttonsHolder.MessageScreen.score_SP.removeMovieClip();
			}
			//trace("clear menu screen please");
			//this.clearScreen("MenuScreen");
			break;
	}
	for (var i in this.screens) {
		if (this.screens[i]._name == screenName) {
			this.screens[i].display();
			break;
		}
	}
}

//clear a movieclip in the screens array
View.prototype.clearScreen = function(screenName) {
	for (var i in this.screens) {
		//trace("trying to clear screen=" + screenName + " compare against " + this.screens[i]._name);
		if (this.screens[i]._name == screenName) {
			// v6.3.5 But CLEAR only gets rid of drawing API content! Not anything else
			// so what should you be doing? How about invisibling it? No, that gets confused with enabling
			this.screens[i].clear();
			//this.screens[i]._visible = false;
			break;
		}
	}
}

//clear all movieclip in the screens array
View.prototype.clearAllScreens = function() {
	//myTrace("clearAllScreens");
	for (var i in this.screens) {
		//trace("clear screen=" + this.screens[i]);
		// once baseScreen is displayed, it will not be cleared.
		if (this.screens[i]._name != "BaseScreen") {
			// v6.3.5 But CLEAR only gets rid of drawing API content! Not anything else
			// so what should you be doing? How about invisibling it?
			this.screens[i].clear();
			//this.screens[i]._visible = false;
		}
	}
}
// v6.3.5 Used only when you know you will do all sorts of resetting before using screens again
// Probably only used on exit, actually
View.prototype.hideAllScreens = function() {
	myTrace("hideAllScreens");
	for (var i in this.screens) {
		if (this.screens[i]._name != "BaseScreen") {
			this.screens[i]._visible = false;
		}
	}
	// v6.3.6 And the jukebox as it is (currently) a rogue element on its own level
	_global.ORCHID.root.jukeboxHolder._visible = false;
	// and stop anything playing, clearMedia just does .s sound, clearAll does everything
	_global.ORCHID.root.jukeboxHolder.myJukeBox.clearAll();
}

//initialize all movieclip in the screens array
View.prototype.initAllScreens = function() {
	for(var i in this.screens) {
		this.screens[i].init();
	}
}

//set the interface language of each screens in screens array
View.prototype.setLiterals = function() {
	myTrace("view.setLiterals");
	for(var i in this.screens) {
		this.screens[i].setLiterals();
	}
}

//Set the colour of GlassTile button in all the screens
//The input parameter is an object containing Colour, ROColour, MDColour, TextColour, ShadowColour
View.prototype.setButtonColour = function(colourObj) {
	
	var myColour = colourObj.Colour;
	var myROColour = colourObj.ROColour;
	var myMDColour = colourObj.MDColour;
	var myTextColour = colourObj.TextColour;
	var myShadowColour = colourObj.ShadowColour;
	
	for(var i in this.screens) {
		for(var j in this.screens[i]) {
			if(this.screens[i][j]._name.indexOf("_pb") > 0 ) {
				this.screens[i][j].setColour(myColour);
				this.screens[i][j].setRollOverColour(myROColour, myMDColour);
				this.screens[i][j].setTextColour(myTextColour, MyShadowColour);
			}
		}
	}
}

// XXXX
// This function copied completely from backup of 18 Nov
// function to display message box
View.prototype.displayMsgBox = function(msgType, goTo, marking) {
	// v6.3.6 Problem: After a while (lots of ctrl-clicking, changing of literal lang and I don't know what)
	// the buttons suddenly stop giving you a puw. This turns out to be because the _global.ORCHID.root.buttonsHolder.MessageScreen
	// has disappeared. But why I don't know. There is a strangeness in that scoreSP was being forced at MsgBoxDepth
	// whilst all other puw were at depth++. And messageScreen itself is at MsgBoxDepth (but on a different mc of course).
	// It's as if the .removeMovieClip of puw was suddenly working at a higher level.
	//myTrace("displayMsgBox " + msgType + " go to " + goTo + " marking=" + marking);
	//myTrace("displayMsgBox " + msgType + " msgScreen=" + _global.ORCHID.root.buttonsHolder.MessageScreen);
	// v6.3.2 Add marking parameter to do with navigation
	// v6.3.4 switch progress to buttons holder
	//_global.ORCHID.root.progressHolder.navMsgBox.removeMovieClip();
	//myTrace("try to remove " + _global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox);
	_global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox.removeMovieClip();
	//_global.ORCHID.root.buttonsHolder.createEmptyMovieClip("messageScreen", _global.ORCHID.MsgBoxDepth);

	this.dummyHandler = function(component) {
	}
	myTrace("msgType=" + msgType);
	switch (msgType) {
		case "seeFeedback":
			// EGU don't even think about asking this question
			// do the 'no' answer straight away
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				if (goTo == "menu") {
					// v6.4.2.4 More than that - if you started in a unit or an exercise you don't want to go to the menu either.
					myTrace("startingPoint=" + _global.ORCHID.commandLine.startingPoint);
					if (_global.ORCHID.commandLine.scorm ||
						(_global.ORCHID.commandLine.startingPoint!=undefined && 
						(_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0 ||
						_global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0))) {
						// v6.4.2.4 Have a different exit function in case you want to tell them anything
						//_global.ORCHID.viewObj.cmdExit();
						_global.ORCHID.viewObj.cmdComplete();
					} else {
						_global.ORCHID.viewObj.displayScreen("MenuScreen");
					}
				} else {
					// v6.3.6 Merge exercise into main
					_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
					// v6.3.6 Merge creation into main
					//_global.ORCHID.root.creationHolder.creationNS.createExercise(goTo);
					_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
				}
			} else {
				//myTrace("seeFeedback for APO");
				//v6.2 use generic AP msg box
				/*
				var initObj = {_x:240, _y:250, borderSpacer:6, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
				// v6.3.4 switch progress to buttons holder
				//var myMsgBox = _global.ORCHID.root.progressHolder.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				myTrace("msgBox=" + myMsgBox);
				myMsgBox.setContentBorder(false);
				myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("feedback", "labels")); 
				myMsgBox.setScrolling(false);
				myMsgBox.setSize(350, 150);
				
				// set up the content to go in the pane
				myMsgBox.setScrollContent("blob");
				var contentHolder = myMsgBox.getScrollContent();
				var contentSize = myMsgBox.getContentSize();
				*/
				// v6.4.3 Extract to a common function
				this.commonMsgBox(msgType, goTo, marking)
				/*
				// v6.3.5 Use better CE pop up window
				// v6.4.2.7 CUP merge
				//var initObj = {_x:200, _y:100, borderSpacer:6};
				var initObj = {_x:200, _y:100, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};				
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				//myTrace("window version=" + myMsgBox.getVersion());
				myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("feedback", "labels")); 
				myMsgBox.setCloseButton(false);
				myMsgBox.setResizeButton(false);
				// message boxes have a yellow content fill (do they? shouldn't you actually be simply
				// saying this is a message box, and let the style sheet from buttons choose the colour?)
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

				var styleObj = {contentFillColour:myBackgroundColour}
				myMsgBox.setStyles(styleObj);
						
				// set up actions for the pane buttons (if any)
				myObj = new Object();
				//v6.4.1 Causing a navigation bug as no exID was being passed
				// the scope when inside the function seems to be the same as outside!
				//myMsgBox.goto = goto;
				//myObj.goto = goto;
				// Add buttons to hold the two options that you can do
				myOBj.onNo = function(scope) {
					//myTrace("onNo with goto=" + goto)
					if (goTo == "menu") {
						// v6.4.2.4 More than that - if you started in a unit or an exercise you don't want to go to the menu either.
						myTrace("startingPoint=" + _global.ORCHID.commandLine.startingPoint);
						if (_global.ORCHID.commandLine.scorm ||
							(_global.ORCHID.commandLine.startingPoint!=undefined && 
							(_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0 ||
							_global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0))) {
							// v6.4.2.4 Have a different exit function in case you want to tell them anything
							//_global.ORCHID.viewObj.cmdExit();
							_global.ORCHID.viewObj.cmdComplete();
						} else {
							_global.ORCHID.viewObj.displayScreen("MenuScreen");
						}
					} else {
						// v6.3.6 Merge exercise into main
						_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
						// v6.3.6 Merge creation into main
						//_global.ORCHID.root.creationHolder.creationNS.createExercise(pane.goTo);
						_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
					}
				}
				myObj.onYes = function() {
					//myTrace("onYes");
					// v6.3.6 Merge exercise into main
					_global.ORCHID.root.mainHolder.exerciseNS.displayAllFeedback();
				}
				myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:myObj.onYes},
								{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:myObj.onNo}]);
				myMsgBox.setKeys([{key:[KEY.ESCAPE, "N".charCodeAt(0)], setReleaseAction:myObj.onNo},
								{key:[KEY.ENTER, "Y".charCodeAt(0)], setReleaseAction:myObj.onYes}]);
				myMsgBox.setCloseHandler(myObj.onNo);				
				myMsgBox.setSize(275, 120);
				
				var contentHolder = myMsgBox.getContent();
				var contentSize = myMsgBox.getContentSize();
				contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,6,contentSize.width,50);
				var clt = contentHolder.list_txt
				clt.autoSize = false;
				clt.html = false;
				clt.wordWrap = true;
				clt.multiline = true;
				clt.selectable = false;
				clt.text = _global.ORCHID.literalModelObj.getLiteral("seeFeedback", "messages");
				var thisTF = _global.ORCHID.BasicText;
				thisTF.size = 11;
				thisTF.leading = 0;
				thisTF.leftMargin = 6;
				clt.setTextFormat(thisTF);
								
				myMsgBox.setEnabled(true);
				*/
			}
			/*
			//EGU use draggable pane instead of msgBox
			var initObj = {_x: 240, _y: 250};
			var myMsgBox = _global.ORCHID.root.exerciseHolder.attachMovie("APDraggablePaneSymbol", "navMsgBox", _global.ORCHID.FeedbackDepth, initObj);
			myMsgBox.setPaneTitle("Are you sure?");
			myMsgBox.setBoxType("half");
			myMsgBox.setScrollContent("blob");
			var contentHolder = myMsgBox.getScrollContent();
			contentHolder.createTextField("list_txt", _global.ORCHID.root.exerciseHolder.exerciseNS.depth++, 0,0,300,50);
			var clt = contentHolder.list_txt
			clt.autoSize = false;
			clt.html = false;
			clt.wordWrap = true;
			clt.multiline = true;
			clt.text = _global.ORCHID.literalModelObj.getLiteral("seeFeedback", "messages");
			var thisTF = _global.ORCHID.BasicText;
			thisTF.size = 11;
			clt.setTextFormat(thisTF);
			
			// Add buttons to hold the options that you can do
			onNo = function() {
				if(goTo == "menu") {
					_global.ORCHID.viewObj.displayScreen("MenuScreen");
					_global.ORCHID.root.exerciseHolder.navMsgBox.removeMovieClip();
				} else {
					_global.ORCHID.root.exerciseHolder.exerciseNS.clearExercise(0);
					_global.ORCHID.root.creationHolder.creationNS.createExercise(goTo);
					_global.ORCHID.root.exerciseHolder.navMsgBox.removeMovieClip();
				}
			}
			onYes = function() {
				_global.ORCHID.root.exerciseHolder.navMsgBox.removeMovieClip();
				_global.ORCHID.root.exerciseHolder.exerciseNS.displayFeedback();
			}
			//myTrace("ask for button=" + _global.ORCHID.literalModelObj.getLiteral("yes", "buttons"));
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:onYes},
							{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:onNo}]);
			onClose = function(component) {
				myMsgBox.removeMovieClip();
				return true;
			}
			myMsgBox.setCloseHandler(onClose);
			*/
			break;
		// v6.4.2.4 Subsumed into lower clause (home, exit, menu all ask the same question)
		/*
		case "goMenu":
			// EGU - don't even think of asking this question
			// use this 'yes' answer straight away
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				if (marking) {
					mainMarking(true);
				}
				_global.ORCHID.viewObj.displayScreen("MenuScreen");
			} else {
				// v6.3.5 Use better CE pop up window
				// Model code follows after all commenting out of old code
				//v6.2 use generic AP msg box
				//var initObj = {_x:240, _y:250, borderSpacer:6, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
				// v6.3.4 switch progress to buttons holder
				//var myMsgBox = _global.ORCHID.root.progressHolder.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				//if (_global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox != undefined){
				//	var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox;
				//} else {
				//var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				//}
				//myMsgBox.setContentBorder(false);
				//myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
				//myMsgBox.setScrolling(false);
				//myMsgBox.setSize(350, 150);
				//myMsgBox.setScrollContent("blob");
				//var contentHolder = myMsgBox.getScrollContent();
				
				// v6.3.5 Use better CE pop up window
				var initObj = {_x:200, _y:100, borderSpacer:6};
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				//myTrace("window version=" + myMsgBox.getVersion());
				//myTrace("msgScreen=" + _global.ORCHID.root.buttonsHolder.MessageScreen);
				//myTrace("msgBox=" + myMsgBox);
				myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
				myMsgBox.setCloseButton(false);
				myMsgBox.setResizeButton(false);
				// message boxes have a yellow content fill (do they? shouldn't you actually be simply
				// saying this is a message box, and let the style sheet from buttons choose the colour?)
				//var styleObj = {contentFillColour:0xFFCC00}
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

				var styleObj = {contentFillColour:myBackgroundColour}
				myMsgBox.setStyles(styleObj);
				
				// set up actions for the pane buttons (if any)
				myObj = new Object();
				// Add buttons to hold the two options that you can do
				myOBj.onNo = function() {
					//_global.ORCHID.root.progressHolder.navMsgBox.removeMovieClip();
				}
				myObj.onYes = function() {
					// v6.3.2 Add in marking if they do decide to go on
					if (marking) {
						mainMarking(true);
					}
					_global.ORCHID.viewObj.displayScreen("MenuScreen");
					//_global.ORCHID.root.progressHolder.navMsgBox.removeMovieClip();
				}
				myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:myObj.onYes},
								{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:myObj.onNo}]);
				myMsgBox.setKeys([{key:[KEY.ESCAPE, "N".charCodeAt(0)], setReleaseAction:myObj.onNo},
								{key:[KEY.ENTER, "Y".charCodeAt(0)], setReleaseAction:myObj.onYes}]);
				myMsgBox.setCloseHandler(myObj.onNo);
				myMsgBox.setSize(275, 120);
				
				// set up the content to go in the pane
				var contentHolder = myMsgBox.getContent();
				var contentSize = myMsgBox.getContentSize();
				contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,6,contentSize.width,50);
				var clt = contentHolder.list_txt
				clt.autoSize = false;
				clt.html = false;
				clt.wordWrap = true;
				clt.multiline = true;
				clt.selectable = false;
				clt.text = _global.ORCHID.literalModelObj.getLiteral("goMenu", "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
				var thisTF = _global.ORCHID.BasicText;
				thisTF.leading = 0;
				thisTF.leftMargin = 6;
				thisTF.size = 11;
				clt.setTextFormat(thisTF);
						
				myMsgBox.setEnabled(true);
			}
			break;
		*/
		// v6.4.2.4 Allow home button on exercise screen, which might trigger the question if the exercise is dirty.
		case "goHome":
		case "goExit":
		case "goMenu":
			// EGU - don't even think of asking this question
			// use this 'yes' answer straight away
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				if (marking) {
					mainMarking(true);
				}
				// OK, they are going on, so pretend this exercise is NOT dirty anymore
				_global.ORCHID.session.currentItem.scoreDirty = false;
				if (msgType=="goHome") {
					_global.ORCHID.viewObj.cmdCourseList();
				} else if (msgType == "goExit") {
					_global.ORCHID.viewObj.cmdExit();
				} else {
					_global.ORCHID.viewObj.displayScreen("MenuScreen");
				}
			} else {
				
				// v6.4.3 Extract to a common function
				this.commonMsgBox(msgType, goTo, marking)
				/*
				// v6.3.5 Use better CE pop up window
				// v6.4.2.7 CUP merge
				//var initObj = {_x:200, _y:100, borderSpacer:6};
				var initObj = {_x:200, _y:100, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};				
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
				myMsgBox.setCloseButton(false);
				myMsgBox.setResizeButton(false);
				// message boxes have a yellow content fill (do they? shouldn't you actually be simply
				// saying this is a message box, and let the style sheet from buttons choose the colour?)
				//var styleObj = {contentFillColour:0xFFCC00}
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

				var styleObj = {contentFillColour:myBackgroundColour}
				myMsgBox.setStyles(styleObj);
				
				// set up actions for the pane buttons (if any)
				myObj = new Object();
				// Add buttons to hold the two options that you can do
				myOBj.onNo = function() {
					//_global.ORCHID.root.progressHolder.navMsgBox.removeMovieClip();
					// v6.4.2.4 Reenable the forward button
					//myTrace("no, so reenable forward button");
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.navForward_pb.setEnabled(true);
				}
				myObj.onYes = function() {
					// v6.3.2 Add in marking if they do decide to go on
					if (marking) {
						mainMarking(true);
					}
					// OK, they are going on, so pretend this exercise is NOT dirty anymore
					_global.ORCHID.session.currentItem.scoreDirty = false;
					if (msgType=="goHome") {
						_global.ORCHID.viewObj.cmdCourseList();
					} else if (msgType == "goExit") {
						_global.ORCHID.viewObj.cmdExit();
					} else {
						_global.ORCHID.viewObj.displayScreen("MenuScreen");
					}
					//_global.ORCHID.root.progressHolder.navMsgBox.removeMovieClip();
				}
				myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:myObj.onYes},
								{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:myObj.onNo}]);
				myMsgBox.setKeys([{key:[KEY.ESCAPE, "N".charCodeAt(0)], setReleaseAction:myObj.onNo},
								{key:[KEY.ENTER, "Y".charCodeAt(0)], setReleaseAction:myObj.onYes}]);
				myMsgBox.setCloseHandler(myObj.onNo);
				// v6.4.2.7 CUP merge
				var thisWidth = 275; 
				var thisHeight = 50;
				//myMsgBox.setSize(275, 120);
				
				// set up the content to go in the pane
				var contentHolder = myMsgBox.getContent();
				//var contentSize = myMsgBox.getContentSize();
				//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,6,contentSize.width,50);
				contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,6,thisWidth,thisHeight);
				var clt = contentHolder.list_txt
				clt.autoSize = false;
				clt.html = false;
				clt.wordWrap = true;
				clt.multiline = true;
				clt.selectable = false;
				if (msgType=="goHome") {
					clt.text = _global.ORCHID.literalModelObj.getLiteral("goHome", "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
				} else if (msgType == "goExit") {
					clt.text = _global.ORCHID.literalModelObj.getLiteral("goExit", "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
				} else {
					clt.text = _global.ORCHID.literalModelObj.getLiteral("goMenu", "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
				}
				var thisTF = _global.ORCHID.BasicText;
				thisTF.leading = 0;
				thisTF.leftMargin = 6;
				thisTF.size = 11;
				clt.setTextFormat(thisTF);
						
				// v6.4.2.7 CUP merge
				//myMsgBox.setContentSize(clt.textWidth, clt.textHeight)
				myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
				myMsgBox.setEnabled(true);
				*/
			}
			break;
			
		// v6.4.2.4 New questioning at the end of a unit/ex if you are not going to a menu
		case "goComplete":
			// EGU - don't even think of asking this question
			// use this 'yes' answer straight away
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				_global.ORCHID.viewObj.cmdExit();
			} else {
				// v6.4.3 Extract to a common function
				this.commonMsgBox(msgType, goTo, marking)
				/*
				// v6.3.5 Use better CE pop up window
				// v6.4.2.7 CUP merge
				//var initObj = {_x:200, _y:100, borderSpacer:6};
				var initObj = {_x:200, _y:100, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};				
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("exit", "buttons")); 
				myMsgBox.setCloseButton(false);
				myMsgBox.setResizeButton(false);
				// message boxes have a yellow content fill (do they? shouldn't you actually be simply
				// saying this is a message box, and let the style sheet from buttons choose the colour?)
				//var styleObj = {contentFillColour:0xFFCC00}
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
	
				var styleObj = {contentFillColour:myBackgroundColour}
				myMsgBox.setStyles(styleObj);
				
				// set up actions for the pane buttons (if any)
				myObj = new Object();
				// Add buttons to hold the two options that you can do
				myOBj.onNo = function() {
					//_global.ORCHID.root.progressHolder.navMsgBox.removeMovieClip();
				}
				myObj.onYes = function() {
					_global.ORCHID.viewObj.cmdExit();
				}
				myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:myObj.onYes},
								{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:myObj.onNo}]);
				myMsgBox.setKeys([{key:[KEY.ESCAPE, "N".charCodeAt(0)], setReleaseAction:myObj.onNo},
								{key:[KEY.ENTER, "Y".charCodeAt(0)], setReleaseAction:myObj.onYes}]);
				myMsgBox.setCloseHandler(myObj.onNo);
				// v6.4.2.7 CUP merge
				//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//	//myMsgBox.setSize(400, 150);
				//	var thisWidth = 370; 
				//	var thisHeight = 50;
				//} else {
					//myMsgBox.setSize(275, 120);
					var thisWidth = 275; 
					var thisHeight = 50;
				//}
				//myMsgBox.setSize(275, 120);
				
				// set up the content to go in the pane
				var contentHolder = myMsgBox.getContent();
				//var contentSize = myMsgBox.getContentSize();
				//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,6,contentSize.width,50);
				contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,6,thisWidth,thisHeight);
				var clt = contentHolder.list_txt
				clt.autoSize = false;
				clt.html = false;
				clt.wordWrap = true;
				clt.multiline = true;
				clt.selectable = false;
				clt.text = _global.ORCHID.literalModelObj.getLiteral("goComplete", "messages");
				var thisTF = _global.ORCHID.BasicText;
				thisTF.leading = 0;
				thisTF.leftMargin = 6;
				thisTF.size = 11;
				clt.setTextFormat(thisTF);
						
				// v6.4.2.7 CUP merge
				//myMsgBox.setContentSize(clt.textWidth, clt.textHeight)
				myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
				myMsgBox.setEnabled(true);
				*/
			}
			break;
			
		case "goNext":
			// Don't even think of asking for CUP
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				// v6.3.2 Add in marking if they do decide to go on
				if (marking) {
					// v6.3.4 If you don't click marking, then don't do marking, just record
					// participation in the exercise. Sure? Does this allow them to play too
					// much with an instant marking one?
					//mainMarking(true);
					justMarking();
				}
				// v6.3.6 Merge exercise into main
				_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
				// v6.3.6 Merge creation into main
				//_global.ORCHID.root.creationHolder.creationNS.createExercise(goTo);
				_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
			} else {
				/*
				var initObj = {_x:240, _y:250, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
				//v6.2 use generic AP msg box
				// v6.3.4 switch progress to buttons holder
				//var myMsgBox = _global.ORCHID.root.progressHolder.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				myMsgBox.setContentBorder(false);
				myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
				myMsgBox.setScrolling(false);
				myMsgBox.setSize(350, 150);
				
				// set up the content to go in the pane
				myMsgBox.setScrollContent("blob");
				var contentHolder = myMsgBox.getScrollContent();
				var contentSize = myMsgBox.getContentSize();
				*/
				// v6.4.3 Extract to a common function
				this.commonMsgBox(msgType, goTo, marking)
				/*
				// v6.3.5 Use better CE pop up window
				// v6.4.2.7 CUP merge
				//var initObj = {_x:200, _y:100, borderSpacer:6};
				var initObj = {_x:200, _y:100, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};				
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				//myTrace("window version=" + myMsgBox.getVersion());
				myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
				myMsgBox.setCloseButton(false);
				myMsgBox.setResizeButton(false);
				// message boxes have a yellow content fill (do they? shouldn't you actually be simply
				// saying this is a message box, and let the style sheet from buttons choose the colour?)
				// v6.3.6 A slightly better approach is to use the title colour. But it would still be 
				// better to let a style sheet of some sort control buttons completely.
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

				var styleObj = {contentFillColour:myBackgroundColour}
				myMsgBox.setStyles(styleObj);

				// set up actions for the pane buttons (if any)
				myObj = new Object();
				//myOBj.goTo = goTo;
				// Add buttons to hold the two options that you can do
				myOBj.onNo = function(scope) {
					// v6.4.2.4 Reenable the forward button
					//myTrace("no, so reenable forward button");
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.navForward_pb.setEnabled(true);
				}
				myObj.onYes = function(scope) {
					// v6.3.2 Add in marking if they do decide to go on
					// v6.4.2.4 Not sure about this. You have just asked if they want to lose their data and they said yes. So why then record it???
					if (marking) {
						// v6.3.4 If you don't click marking, then don't do marking, just record
						// participation in the exercise. Sure? Does this allow them to play too
						// much with an instant marking one?
						//mainMarking(true);
						justMarking();
					}
					//trace("please go forward to " + goTo.id);
					// v6.3.6 Merge exercise into main
					_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
					// v6.3.6 Merge creation into main
					//_global.ORCHID.root.creationHolder.creationNS.createExercise(goTo);
					_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
				}
				myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:myObj.onYes},
								{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:myObj.onNo}]);
				myMsgBox.setKeys([{key:[KEY.ESCAPE, "N".charCodeAt(0)], setReleaseAction:myObj.onNo},
								{key:[KEY.ENTER, "Y".charCodeAt(0)], setReleaseAction:myObj.onYes}]);
				myMsgBox.setCloseHandler(myObj.onNo);
				// v6.4.2.7 CUP merge
				//myMsgBox.setSize(275, 120);
				//var thisWidth = 275; 
				var thisWidth = 300; 
				//var thisHeight = 50;
				var thisHeight = 25;
								
				var contentHolder = myMsgBox.getContent();
				// v6.4.2.7 CUP merge
				//var contentSize = myMsgBox.getContentSize();
				//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,0,contentSize.width,50);
				contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 6,6,thisWidth,thisHeight);
				var clt = contentHolder.list_txt
				//clt.autoSize = false;
				clt.autoSize = true;
				clt.html = false;
				clt.wordWrap = true;
				clt.multiline = true;
				clt.selectable = false;
				clt.text = _global.ORCHID.literalModelObj.getLiteral("goNext", "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
				var thisTF = _global.ORCHID.BasicText;
				thisTF.size = 11;
				thisTF.leftMargin = 6;
				clt.setTextFormat(thisTF);
				// v6.4.2.7 CUP merge
				myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
						
				myMsgBox.setEnabled(true);
				*/
			}							
			break;
		case "goPrevious":
			// Don't even think of asking for CUP
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				// v6.3.2 Add in marking if they do decide to go on
				if (marking) {
					// v6.3.4 If you don't click marking, then don't do marking, just record
					// participation in the exercise. Sure? Does this allow them to play too
					// much with an instant marking one?
					//mainMarking(true);
					justMarking();
				}
				// v6.3.6 Merge exercise into main
				_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
				// v6.3.6 Merge creation into main
				//_global.ORCHID.root.creationHolder.creationNS.createExercise(goTo);
				_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
			} else {
				/*
				var initObj = {_x:240, _y:250, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
				//v6.2 use generic AP msg box
				// v6.3.4 switch progress to buttons holder
				//var myMsgBox = _global.ORCHID.root.progressHolder.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				myMsgBox.setContentBorder(false);
				myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
				myMsgBox.setScrolling(false);
				myMsgBox.setSize(350, 150);
				
				// set up the content to go in the pane
				myMsgBox.setScrollContent("blob");
				var contentHolder = myMsgBox.getScrollContent();
				var contentSize = myMsgBox.getContentSize();
				*/
				// v6.4.3 Extract to a common function
				this.commonMsgBox(msgType, goTo, marking)
				/*
				var initObj = {_x:200, _y:100, borderSpacer:6};
				var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
				//myTrace("window version=" + myMsgBox.getVersion());
				myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
				myMsgBox.setCloseButton(false);
				myMsgBox.setResizeButton(false);
				// message boxes have a yellow content fill (do they? shouldn't you actually be simply
				// saying this is a message box, and let the style sheet from buttons choose the colour?)
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

				var styleObj = {contentFillColour:myBackgroundColour}
				myMsgBox.setStyles(styleObj);

				// set up actions for the pane buttons (if any)
				myObj = new Object();
				// Add buttons to hold the two options that you can do
				myOBj.onNo = function() {
					// v6.4.2.4 Reenable the backward button
					//myTrace("no, so reenable backward button");
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.navBack_pb.setEnabled(true);
				}
				myObj.onYes = function() {
					// v6.3.2 Add in marking if they do decide to go on
					if (marking) {
						// v6.3.4 If you don't click marking, then don't do marking, just record
						// participation in the exercise. Sure? Does this allow them to play too
						// much with an instant marking one?
						//mainMarking(true);
						justMarking();
					}
					//trace("please go backward to " + goTo.id);
					// v6.3.6 Merge exercise into main
					_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
					// v6.3.6 Merge creation into main
					//_global.ORCHID.root.creationHolder.creationNS.createExercise(goTo);
					_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
				}
				myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:myObj.onYes}, 
								{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:myObj.onNo}]);
				myMsgBox.setKeys([{key:[KEY.ESCAPE, "N".charCodeAt(0)], setReleaseAction:myObj.onNo},
								{key:[KEY.ENTER, "Y".charCodeAt(0)], setReleaseAction:myObj.onYes}]);
				myMsgBox.setCloseHandler(myObj.onNo);
				/*
				// v6.4.2.8 Change size
				//myMsgBox.setSize(275, 120);
				myMsgBox.setSize(300, 250);

				var contentHolder = myMsgBox.getContent();
				var contentSize = myMsgBox.getContentSize();
				contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 6,6,contentSize.width,50);
				var clt = contentHolder.list_txt
				clt.autoSize = false;
				clt.html = false;
				clt.wordWrap = true;
				clt.multiline = true;
				clt.selectable = false;
				clt.text = _global.ORCHID.literalModelObj.getLiteral("goPrevious", "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
				var thisTF = _global.ORCHID.BasicText;
				thisTF.size = 11;
				thisTF.leftMargin = 6;
				clt.setTextFormat(thisTF);
				// v6.4.2.8 Add in resizing to contents.
				myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
						
				myMsgBox.setEnabled(true);
				// v6.4.2.7 CUP merge
				//myMsgBox.setSize(275, 120);
				//var thisWidth = 275; 
				var thisWidth = 300; 
				//var thisHeight = 50;
				var thisHeight = 25;
								
				var contentHolder = myMsgBox.getContent();
				// v6.4.2.7 CUP merge
				//var contentSize = myMsgBox.getContentSize();
				//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,0,contentSize.width,50);
				contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 6,6,thisWidth,thisHeight);
				var clt = contentHolder.list_txt
				//clt.autoSize = false;
				clt.autoSize = true;
				clt.html = false;
				clt.wordWrap = true;
				clt.multiline = true;
				clt.selectable = false;
				clt.text = _global.ORCHID.literalModelObj.getLiteral("goPrevious", "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
				var thisTF = _global.ORCHID.BasicText;
				thisTF.size = 11;
				thisTF.leftMargin = 6;
				clt.setTextFormat(thisTF);
				// v6.4.2.7 CUP merge
				myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
						
				myMsgBox.setEnabled(true);
				*/
			}
			break;

		// EGU 1.1 This will not be done with a msgBox any more for CUP
		/*
		case "dictionary":
			var initObj = {_x:240, _y:250, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
			//v6.2 use generic AP msg box
			var myMsgBox = _global.ORCHID.root.progressHolder.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			//var myMsgBox = _global.ORCHID.root.exerciseHolder.attachMovie("APDraggablePaneSymbol", "navMsgBox", _global.ORCHID.FeedbackDepth, initObj);
			myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("dictionary", "labels"));
			myMsgBox.setContentBorder(false);
			myMsgBox.setScrolling(false);
			myMsgBox.setSize(420, 150);
			
			// set up the content to go in the pane
			myMsgBox.setScrollContent("blob");
			var contentHolder = myMsgBox.getScrollContent();
			var contentSize = myMsgBox.getContentSize();
			contentHolder.createTextField("list_txt", _global.ORCHID.root.progressHolder.progressNS.depth++, 0,0,contentSize.width,50);
			var clt = contentHolder.list_txt
			clt.autoSize = false;
			clt.html = false;
			clt.wordWrap = true;
			clt.multiline = true;
			clt.selectable = false;
			clt.text = _global.ORCHID.literalModelObj.getLiteral("ctrl-click", "messages");
			var thisTF = _global.ORCHID.BasicText;
			thisTF.size = 11;
			clt.setTextFormat(thisTF);
					
			// set up actions for the pane buttons (if any)
			myObj = new Object();
			myObj.onOK = function() {
			}
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("ok", "buttons"), setReleaseAction:myObj.onOK}]);
			// see displayYourScore for setKeys comment
			//myMsgBox.setKeys([{key:[KEY.ESCAPE, KEY.ENTER, "O".charCodeAt(0)], setReleaseAction:myObj.onOK}]);
			myMsgBox.setCloseHandler(myObj.onOK);
			break;
		*/
		// v6.2 For a limit on target spotting
		case "clickLimit":
		case "hintText":
			/*
			var initObj = {_x:240, _y:250, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
			//v6.2 use generic AP msg box
			// v6.3.4 switch progress to buttons holder
			//var myMsgBox = _global.ORCHID.root.progressHolder.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("clickLimit", "labels"));
			//myMsgBox.setPaneTitle("Click on ten mistakes");
			myMsgBox.setContentBorder(false);
			myMsgBox.setScrolling(false);
			myMsgBox.setSize(420, 150);
			
			// set up the content to go in the pane
			myMsgBox.setScrollContent("blob");
			var contentHolder = myMsgBox.getScrollContent();
			var contentSize = myMsgBox.getContentSize();
			*/
			// v6.4.3 Extract to a common function
			this.commonMsgBox(msgType, goTo, marking) 
			/*
			// v6.4.2.7 CUP merge
			//var initObj = {_x:200, _y:100, borderSpacer:6};
			var initObj = {_x:200, _y:100, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};				
			var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			//myTrace("window version=" + myMsgBox.getVersion());
			myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("clickLimit", "labels")); 
			myMsgBox.setCloseButton(false);
			myMsgBox.setResizeButton(false);
			// message boxes have a yellow content fill (do they? shouldn't you actually be simply
			// saying this is a message box, and let the style sheet from buttons choose the colour?)
			var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
			var cT = colourObj.getTransform();
			myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

			var styleObj = {contentFillColour:myBackgroundColour}
			myMsgBox.setStyles(styleObj);

			// set up actions for the pane buttons (if any)
			myObj = new Object();
			myObj.onOK = function() {
			}
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("ok", "buttons"), setReleaseAction:myObj.onOK}]);
			// see displayYourScore for setKeys comment
			//myMsgBox.setKeys([{key:[KEY.ESCAPE, KEY.ENTER, "O".charCodeAt(0)], setReleaseAction:myObj.onOK}]);
			myMsgBox.setCloseHandler(myObj.onOK);
			//myMsgBox.setSize(275, 120);
			// v6.4.2.7 CUP merge
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myMsgBox.setSize(400, 150);
				var thisWidth = 370; 
				var thisHeight = 50;
			} else {
				//myMsgBox.setSize(275, 120);
				var thisWidth = 275; 
				var thisHeight = 50;
			}
			//myMsgBox.setSize(thisWidth, thisHeight);
			
			var contentHolder = myMsgBox.getContent();
			// v6.4.2.7 CUP merge
			//var contentSize = myMsgBox.getContentSize();
			//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,0,contentSize.width,50);
			contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 6,6,thisWidth,thisHeight);
			var clt = contentHolder.list_txt
			clt.autoSize = false;
			clt.html = false;
			clt.wordWrap = true;
			clt.multiline = true;
			clt.selectable = false; 
			var substList = [{tag:"[x]", text:goTo}];
			clt.text = substTags(_global.ORCHID.literalModelObj.getLiteral("clickLimitWarning", "messages"), substList);
			//clt.text = "You cannot click on eleven mistakes. You can only click on ten mistakes. If you think your choice is not a mistake, click it again. Then you can click on another mistake.";
			//clt.text = "You have already clicked on " + goTo + " underlined words or phrases, and this is the limit. Click on one of them again to clear it and get another go.";
			var thisTF = _global.ORCHID.BasicText;
			thisTF.size = 11;
			thisTF.leftMargin = 6;
			clt.setTextFormat(thisTF);
					
			// v6.4.2.7 CUP merge
			//myMsgBox.setContentSize(clt.textWidth, clt.textHeight)
			myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
			myMsgBox.setEnabled(true);
			*/
			break;
		// warning message if Flash won't let you print
		case "noPrint":
		case "noRecorder":
			/*
			var initObj = {_x:240, _y:250, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
			//v6.2 use generic AP msg box
			// v6.3.4 switch progress to buttons holder
			//var myMsgBox = _global.ORCHID.root.progressHolder.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("warning", "labels"));
			myMsgBox.setContentBorder(false);
			myMsgBox.setScrolling(false);
			myMsgBox.setSize(350, 150);
			
			// set up the content to go in the pane
			myMsgBox.setScrollContent("blob");
			var contentHolder = myMsgBox.getScrollContent();
			var contentSize = myMsgBox.getContentSize();
			*/
			// v6.4.3 Extract to a common function
			this.commonMsgBox(msgType, goTo, marking)
			/*
			// v6.4.2.7 CUP merge
			//var initObj = {_x:200, _y:100, borderSpacer:6};
			var initObj = {_x:200, _y:100, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};				
			var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			//myTrace("window version=" + myMsgBox.getVersion());
			myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("warning", "labels")); 
			myMsgBox.setCloseButton(false);
			myMsgBox.setResizeButton(false);
			// message boxes have a yellow content fill (do they? shouldn't you actually be simply
			// saying this is a message box, and let the style sheet from buttons choose the colour?)
			var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
			var cT = colourObj.getTransform();
			myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

			var styleObj = {contentFillColour:myBackgroundColour}
			myMsgBox.setStyles(styleObj);

			// set up actions for the pane buttons (if any)
			//myObj = new Object();
			myMsgBox.onOK = function() {
				//trace("clicked on OK for the pane with this=" + this);
			}
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("ok", "buttons"), setReleaseAction:myMsgBox.onOK}]);
			//myMsgBox.setKeys([{key:[KEY.ESCAPE, KEY.ENTER, "O".charCodeAt(0)], setReleaseAction:myMsgBox.onOK}]);
			myMsgBox.setCloseHandler(myMsgBox.onOK);
			// v6.4.2.7 CUP merge
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myMsgBox.setSize(400, 150);
				var thisWidth = 370; 
				var thisHeight = 50;
			} else {
				//myMsgBox.setSize(275, 120);
				var thisWidth = 275; 
				var thisHeight = 120;
			}
			
			var contentHolder = myMsgBox.getContent();
			// v6.4.2.7 CUP merge
			//var contentSize = myMsgBox.getContentSize();
			//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 6,6,contentSize.width,contentSize.height-30);
			contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 6,6,thisWidth,thisHeight);
			var clt = contentHolder.list_txt
			clt.autoSize = true;
			clt.html = false;
			clt.wordWrap = true;
			clt.multiline = true;
			clt.selectable = false;
			if (msgType == "noPrint") {
				//clt.text = "Sorry, your Flash player cannot print. Please upgrade to at least version 7.";
				clt.text = _global.ORCHID.literalModelObj.getLiteral("cannotPrint", "messages");
			} else if (msgType == "noRecorder") {
				clt.html = true;
				var supportLink = "<u><a href='http://www.clarity.com.hk/technical-support/ClarityRecorder.htm' target='_blank'>www.ClaritySupport.com</a></u>";
				var substList = [{tag:"[x]", text:supportLink}];
				clt.htmlText = substTags(_global.ORCHID.literalModelObj.getLiteral("cannotRecord", "messages"), substList);
			} else {
				myTrace("unexpected msgType=" + msgType);
				// if an unexpected call, do nothing??
				return;
			}
			var thisTF = _global.ORCHID.BasicText;
			thisTF.leftMargin = 6;
			thisTF.size = 11;
			//thisTF.indent = 0;
			clt.setTextFormat(thisTF);
			//myTrace("make box height=" + clt.textHeight)
			// v6.3.5 Let autosize for height do its work - do this in the other msg boxes as well please
			// v6.4.2.7 CUP merge
			//myMsgBox.setContentSize(clt.textWidth, clt.textHeight)
			myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);					
			myMsgBox.setEnabled(true);
			break;
			*/
		case "goTest":
			/*
			var initObj = {_x:240, _y:250, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
			// v6.3.4 switch progress to buttons holder
			//var myMsgBox = _global.ORCHID.root.progressHolder.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APMsgBoxSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			//var myMsgBox = _global.ORCHID.root.exerciseHolder.attachMovie("APDraggablePaneSymbol", "navMsgBox", _global.ORCHID.FeedbackDepth, initObj);
			myMsgBox.setContentBorder(false);
			myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
			myMsgBox.setScrolling(false);
			myMsgBox.setSize(350, 150);
			
			// set up the content to go in the pane
			myMsgBox.setScrollContent("blob");
			var contentHolder = myMsgBox.getScrollContent();
			var contentSize = myMsgBox.getContentSize();
			*/
			// v6.4.3 Extract to a common function
			this.commonMsgBox(msgType, goTo, marking)
			/*
			// v6.4.2.7 CUP merge
			//var initObj = {_x:200, _y:100, borderSpacer:6};
			var initObj = {_x:200, _y:100, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};				
			var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
			//myTrace("window version=" + myMsgBox.getVersion());
			myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
			myMsgBox.setCloseButton(false);
			myMsgBox.setResizeButton(false);
			// message boxes have a yellow content fill (do they? shouldn't you actually be simply
			// saying this is a message box, and let the style sheet from buttons choose the colour?)
			var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
			var cT = colourObj.getTransform();
			myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

			var styleObj = {contentFillColour:myBackgroundColour}
			myMsgBox.setStyles(styleObj);

			// set up actions for the pane buttons (if any)
			myObj = new Object();
			//myOBj.goTo = goTo;
			// Add buttons to hold the two options that you can do
			myOBj.onNo = function(scope) {
			}
			myObj.onYes = function(scope) {
				// v6.3.2 Add in marking if they do decide to go on
				if (marking) {
					// v6.3.4 If you don't click marking, then don't do marking, just record
					// participation in the exercise. Sure? Does this allow them to play too
					// much with an instant marking one?
					//mainMarking(true);
					justMarking();
				}
				//trace("please go forward to make a test");
				_global.ORCHID.viewObj.cmdTest();
			}
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:myObj.onNo},
							{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:myObj.onYes}]);
			myMsgBox.setKeys([{key:[KEY.ESCAPE, "N".charCodeAt(0)], setReleaseAction:myObj.onNo},
							{key:[KEY.ENTER, "Y".charCodeAt(0)], setReleaseAction:myObj.onYes}]);
			myMsgBox.setCloseHandler(myObj.onNo);
			// v6.4.2.7 CUP merge
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myMsgBox.setSize(400, 150);
				var thisWidth = 370; 
				var thisHeight = 50;
			} else {
				//myMsgBox.setSize(275, 120);
				var thisWidth = 275; 
				var thisHeight = 50;
			}
							
			var contentHolder = myMsgBox.getContent();
			// v6.4.2.7 CUP merge
			//var contentSize = myMsgBox.getContentSize();
			//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,0,contentSize.width,50);
			contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 6,6,thisWidth,thisHeight);
			var clt = contentHolder.list_txt
			clt.autoSize = false;
			clt.html = false;
			clt.wordWrap = true;
			clt.multiline = true;
			clt.selectable = false;
			clt.text = _global.ORCHID.literalModelObj.getLiteral("goTest", "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
			var thisTF = _global.ORCHID.BasicText;
			thisTF.size = 11;
			clt.setTextFormat(thisTF);
					
			// v6.4.2.7 CUP merge
			//myMsgBox.setContentSize(clt.textWidth, clt.textHeight)
			myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
			myMsgBox.setEnabled(true);
			*/
			break;
	}
}
// v6.4.3 Extract the common stuff for message box from the above
View.prototype.commonMsgBox = function(msgType, goTo, marking) {
	//var initObj = {_x:200, _y:100, borderSpacer:6};
	//myTrace("commonMsgBox with " + msgType + " goTo.scope=" + goTo.scope+ " marking=" + marking);
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		var initObj = {_x:260, _y:140, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};	
	} else {
		var initObj = {_x:200, _y:100, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};	
	}
	
	var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "navMsgBox", _global.ORCHID.MsgBoxDepth, initObj);
	//myTrace("window version=" + myMsgBox.getVersion());
	switch (msgType) {
		case "clickLimit":
			myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral(msgType, "labels")); 
			break;
		case "hintText":
			myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("glossary", "labels"));
			break;
		case "noPrint":
		case "noRecorder":
			myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("warning", "labels")); 
			break;
		default:
			myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("confirmAction", "labels")); 
	}
	myMsgBox.setCloseButton(false);
	myMsgBox.setResizeButton(false);
	// message boxes have a yellow content fill (do they? shouldn't you actually be simply
	// saying this is a message box, and let the style sheet from buttons choose the colour?)
	// v6.3.6 A slightly better approach is to use the title colour. But it would still be 
	// better to let a style sheet of some sort control buttons completely.
	var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
	var cT = colourObj.getTransform();
	myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;

	var styleObj = {contentFillColour:myBackgroundColour}
	myMsgBox.setStyles(styleObj);

	// set up actions for the pane buttons (if any)
	myObj = new Object();
	myMsgBox.msgType = msgType;
	myMsgBox.goTo = goTo;
	myMsgBox.marking = marking;
	//myOBj.goTo = goTo;
	// Add buttons to hold the two options that you can do
	myOBj.onNo = function(scope) {
		//myTrace("no, so do stuff for " + this.msgType + " scope:" + scope.msgType);
		myTrace("onNo, for " + msgType + "scope.marking=" + scope.marking + " goTo=" + scope.goTo);
		switch (scope.msgType) {
			case "goNext":
			case "goHome":
			case "goExit":
			case "goMenu":
				// v6.4.2.4 Reenable the forward button
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.navForward_pb.setEnabled(true);
				break;
			case "goPrevious":
				// v6.4.2.4 Reenable the backward button
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.navBack_pb.setEnabled(true);
				break;
			case "seeFeedback":
				if (scope.goTo == "menu") {
					// v6.4.2.4 More than that - if you started in a unit or an exercise you don't want to go to the menu either.
					myTrace("startingPoint=" + _global.ORCHID.commandLine.startingPoint);
					if (_global.ORCHID.commandLine.scorm ||
						(_global.ORCHID.commandLine.startingPoint!=undefined && 
						(_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0 ||
						_global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0))) {
						// v6.4.2.4 Have a different exit function in case you want to tell them anything
						//_global.ORCHID.viewObj.cmdExit();
						myTrace("goComplete please");
						_global.ORCHID.viewObj.cmdComplete();
					} else {
						_global.ORCHID.viewObj.displayScreen("MenuScreen");
					}
				} else {
					// v6.3.6 Merge exercise into main
					_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
					// v6.3.6 Merge creation into main
					//_global.ORCHID.root.creationHolder.creationNS.createExercise(pane.goTo);
					_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
				}
				break;
			case "goComplete":
			case "goTest":
				break;
			default:
		}
	}
	myObj.onYes = function (scope) {
		// v6.3.2 Add in marking if they do decide to go on
		// v6.4.2.4 Not sure about this. You have just asked if they want to lose their data and they said yes. So why then record it???
		//if (marking) {
		//myTrace("onYes, for " + msgType + "scope.marking=" + scope.marking + " goTo=" + scope.goTo);
		switch (scope.msgType) {
			case "goNext":
			case "goPrevious":
				if (scope.marking) {
					// v6.3.4 If you don't click marking, then don't do marking, just record
					// participation in the exercise. Sure? Does this allow them to play too
					// much with an instant marking one?
					//mainMarking(true);
					justMarking();
				}
				//trace("please go forward to " + goTo.id);
				// v6.3.6 Merge exercise into main
				_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
				// v6.3.6 Merge creation into main
				//_global.ORCHID.root.creationHolder.creationNS.createExercise(goTo);
				_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
				break;
			case "seeFeedback":
				_global.ORCHID.root.mainHolder.exerciseNS.displayAllFeedback();
				break;
			case "goHome":
			case "goExit":
			case "goMenu":
				// v6.3.2 Add in marking if they do decide to go on
				if (scope.marking) {
					mainMarking(true);
				}
				// OK, they are going on, so pretend this exercise is NOT dirty anymore
				_global.ORCHID.session.currentItem.scoreDirty = false;
				if (msgType=="goHome") {
					_global.ORCHID.viewObj.cmdCourseList();
				} else if (msgType == "goExit") {
					_global.ORCHID.viewObj.cmdExit();
				} else {
					_global.ORCHID.viewObj.displayScreen("MenuScreen");
				}
				//_global.ORCHID.root.progressHolder.navMsgBox.removeMovieClip();
				break;
			case "goComplete":
				myTrace("onYes, so go to cmdExit");
				// v6.5.5.3 Set the exercise to clean no matter what, otherwise you can get into a loop.
				_global.ORCHID.session.currentItem.scoreDirty = false;
				_global.ORCHID.viewObj.cmdExit();
				break;
			case "goTest":
				// v6.3.2 Add in marking if they do decide to go on
				if (scope.marking) {
					// v6.3.4 If you don't click marking, then don't do marking, just record
					// participation in the exercise. Sure? Does this allow them to play too
					// much with an instant marking one?
					//mainMarking(true);
					justMarking();
				}
				//trace("please go forward to make a test");
				_global.ORCHID.viewObj.cmdTest();
				break;
		}
	}
	myObj.onOK = function() {
		switch (scope.msgType) {
			case "hintText":
				// now you can fire the glossary again
				// v6.3.6 Merge glossary into main
				_global.ORCHID.root.mainHolder.glossaryNS.open = false;
				break;
		}
	}
	switch (msgType) {
		case "clickLimit":
		case "noPrint":
		case "noRecorder":
		case "hintText":
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("ok", "buttons"), setReleaseAction:myObj.onOK}]);
			myMsgBox.setCloseHandler(myObj.onOK);
			break;
		default:
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("yes", "buttons"), setReleaseAction:myObj.onYes},
							{caption:_global.ORCHID.literalModelObj.getLiteral("no", "buttons"), setReleaseAction:myObj.onNo}]);
			myMsgBox.setKeys([{key:[KEY.ESCAPE, "N".charCodeAt(0)], setReleaseAction:myObj.onNo},
							{key:[KEY.ENTER, "Y".charCodeAt(0)], setReleaseAction:myObj.onYes}]);
			myMsgBox.setCloseHandler(myObj.onNo);
	}
	// v6.4.2.7 CUP merge
	//myMsgBox.setSize(275, 120);
	//var thisWidth = 275; 
	var thisWidth = 300; 
	//var thisHeight = 50;
	var thisHeight = 25;
					
	var contentHolder = myMsgBox.getContent();
	// v6.4.2.7 CUP merge
	//var contentSize = myMsgBox.getContentSize();
	//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,0,contentSize.width,50);
	contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 6,6,thisWidth,thisHeight);
	var clt = contentHolder.list_txt
	//clt.autoSize = false;
	clt.autoSize = true;
	clt.html = false;
	clt.wordWrap = true;
	clt.multiline = true;
	clt.selectable = false;
	switch (msgType) {
		case "goNext":
		case "goPrevious":
		case "goHome":
		case "goExit":
		case "goMenu":
		case "goTest":
			clt.text = _global.ORCHID.literalModelObj.getLiteral(msgType, "messages") + "\n" + _global.ORCHID.literalModelObj.getLiteral("loseWork", "messages");
			break;
		case "seeFeedback":
		case "goComplete":
		case "goTest":
			clt.text = _global.ORCHID.literalModelObj.getLiteral(msgType, "messages");
			break;
		case "clickLimit":
			var substList = [{tag:"[x]", text:scope.goTo}];
			clt.text = substTags(_global.ORCHID.literalModelObj.getLiteral("clickLimitWarning", "messages"), substList);
			break;
		case "noPrint":
			clt.text = _global.ORCHID.literalModelObj.getLiteral("cannotPrint", "messages");
			break;
		case "noRecorder":
			clt.html = true;
			var supportLink = "<u><a href='http://www.clarity.com.hk/technical-support/ClarityRecorder.htm' target='_blank'>www.ClaritySupport.com</a></u>";
			var substList = [{tag:"[x]", text:supportLink}];
			clt.htmlText = substTags(_global.ORCHID.literalModelObj.getLiteral("cannotRecord", "messages"), substList);
			break;
		case "hintText":
			// v6.5
			clt.html = true;
			var supportLink = "<u><a href='http://dictionary.cambridge.org' target='_blank'>click here</a></u>";
			//var substList = [{tag:"[newline]", text:newline}];
			var substList = [{tag:"[newline]", text:newline},{tag:"[x]", text:supportLink}];
			clt.htmlText = substTags(_global.ORCHID.literalModelObj.getLiteral("ctrl-click", "messages"), substList);
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				// EGU 1.1 Show dictionary logos for cross-marketing
				var imageHolder1 = myMsgBox.createEmptyMovieClip("imageHolder1",  thisDepth++);
				imageHolder1._x = 385; 
				imageHolder1._y = 60;
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {			
					// v6.4.2.7 Changed paths
					//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + "CLDcover.jpg");
					//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CLDcover.jpg");
					var thisImageFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CLDcover.jpg";
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
					//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + "CALDcover.jpg");
					var thisImageFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CALDcover.jpg";
				}
				//myTrace("show branding " + thisImageFile);
				var myBranding1 = imageHolder1.loadMovie(thisImageFile);
			}

	};
	var thisTF = _global.ORCHID.BasicText;
	thisTF.size = 11;
	thisTF.leftMargin = 0;
	clt.setTextFormat(thisTF);
	myMsgBox.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);			
	myMsgBox.setEnabled(true);
	// v6.5.4.3 AR this was not necessary for fixing Bug 1223, so remove it
	//myMsgBox.initTextFieldForDictionaryCheck();	// v6.5.4.2 Yiu, trying to fully initialize the textWithFields, Bug ID 1223
}
//v6.4.2.4 A new function that is called when you have complete something but are not going to a menu.
// Could ask if you want to hang around (check your progress, go back etc).
View.prototype.cmdComplete = function() {
	// v6.5.1 If you are in SCORM you don't want to ask them about exiting - just do it.
	// In fact, not sure why it would ever be useful to ask this...
	// v6.5.5.5 So don't!
	//if (_global.ORCHID.commandLine.scorm) {
		_global.ORCHID.viewObj.cmdExit();
	//} else {
	//	_global.ORCHID.viewObj.displayMsgBox("goComplete", null, false);
	//}
}

View.prototype.cmdExit = function() {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	// v6.4.2.4 This might also happen from the login screen, when there is no session
	if (_global.ORCHID.session == undefined) {
		myTrace("exit before a session has been created")
		_global.ORCHID.root.controlNS.startExit(false);
	} else {
		// v6.4.2.4 Now this might happen from an exercise screen as well - in which case we have to do more stuff
		var isDirty = (_global.ORCHID.session.currentItem.scoreDirty == true);
		var hasMarking = _global.ORCHID.LoadedExercises[0].settings.buttons.marking;
		// the user has done something and there is a marking button, so going on will lose their work
		if (isDirty && hasMarking) {
			_global.ORCHID.viewObj.displayMsgBox("goExit", null, marking);
			//_global.ORCHID.viewObj.moveExercise(null, "exit");
		} else {
			// they've done something, but no marking button, so simply mark and go on as no other option.
			if (isDirty) {
				justMarking();
			}
			// 6.0.2.0 remove connections
			//_global.ORCHID.root.controller.exit();
			//v6.3.5 Since you might be locked up with SCORM closing for a while, you MUST do something to show
			// the closure is happening immediately, and get rid of buttons that you could click.
			//myTrace("call clearAllScreens=" + this.clearAllScreens)
			_global.ORCHID.viewObj.hideAllScreens();
			
			// v6.3.4 It would be good (for SCORM) to know that you have saved the score for the last exercise
			// before you charge into the exit process.
			myTrace("delayedExit with scoreDirty=" + isDirty);
			this.delayedExit = function() {
				if (!_global.ORCHID.session.currentItem.scoreDirty || this.delayedCount > 10) {
					clearInterval(this.delayedInt);
					myTrace("go to session.exit");
					_global.ORCHID.session.exit();
				} else {
					myTrace("wait a little longer...");
				}
				this.delayedCount++;
			}
			this.delayedCount=0;
			this.delayedInt = setInterval(this, "delayedExit", 250);
			//_global.ORCHID.root.controlNS.startExit();
		}
	}
}
// 6.2 A new function to take you back to the course list (stay logged in)
View.prototype.cmdCourseList = function() {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	// v6.4.2.4 Now this might happen from an exercise screen as well - in which case we have to do more stuff
	var isDirty = (_global.ORCHID.session.currentItem.scoreDirty == true);
	var hasMarking = _global.ORCHID.LoadedExercises[0].settings.buttons.marking;
	// the user has done something and there is a marking button, so going on will lose their work
	if (isDirty && hasMarking) {
		_global.ORCHID.viewObj.displayMsgBox("goHome", null, marking);
	} else {
		// they've done something, but no marking button, so simply mark and go on as no other option.
		if (isDirty) {
			justMarking();
		}
		// close the session
		_global.ORCHID.session.stopSession();
		// clear out progress from memory (new course has different progress)
		_global.ORCHID.progress = {};
		// display the course list screen
		_global.ORCHID.viewObj.displayScreen("CourseListScreen");
	}
}

// exercise based buttons
// later to add Related text and maybe Multimedia
// v6.4.3 I can't run this from the button!! Though I can run cmdDictionaries from it??
// Probably due to mismatch in parameters
//View.prototype.cmdMarking = function(component) {
View.prototype.cmdMarking = function() {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	//myTrace("cmdMarking - switch off instant feedback, or is it too late?")
	//trace("here in cmdMarking");
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert from cmdMarking");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	if (_global.ORCHID.LoadedExercises[0].settings.misc.timed > 0) {
		myTrace("This exercise has a timer and subunit.status=" + _global.ORCHID.session.subunit.status);
		// v6.5.5.0 (FB2) subunits allow a timer to be spread over several exercises in a unit
		// We will kill the timer unless there is a subunit that is not last one (remember can be first+last)
		var killTheTimer = true;
		// Are we working with a subunit?
		if (_global.ORCHID.session.subunit) {
			// Yes, is this exercise the last one?
			if (_global.ORCHID.session.subunit.status.indexOf("last")<0) {
				myTrace("don't kill the timer as you will continue");
				killTheTimer = false;
			}
		}
		if (killTheTimer) {
			myTrace("clear timerInt=" + _global.ORCHID.root.buttonsHolder.ExerciseScreen.exTimer.timerBar.countDownInt);
			clearInterval(_global.ORCHID.root.buttonsHolder.ExerciseScreen.exTimer.timerBar.countDownInt);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.exTimer._visible = false;
		}
	}

	// commented, the orgin code is safe and we cannot recreated the problem
	/*
	// v6.5.4.2 Yiu I force it to run anyway to prevent double submit the exercise answers: bug 1383
	clearInterval(_global.ORCHID.root.buttonsHolder.ExerciseScreen.exTimer.timerBar.countDownInt);
	_global.ORCHID.root.buttonsHolder.exerciseScreen.exTimer._visible = false;	
	this.exMarking_pb.setEnabled(false);
	// End v6.5.4.2 Yiu I force it to run anyway to prevent double submit the exercise answers: bug 1383
	*/
	// end commented, the orgin code is safe and we cannot recreated the problem
	
	//trace("request from marking button " + component.getLabel());
	// 6.0.2.0 remove connection
	//_global.ORCHID.root.exerciseHolder.myConnection.markExercise();
	// v6.3.6 Merge exercise into main
	_global.ORCHID.root.mainHolder.exerciseNS.markExercise();

	// v6.3.5 Need to stop any playing sounds, but without clearing out the jukebox
	// Can I just stopAllSounds?
	// v6.5.5.6 This sort stops a video that is playing in newVideo, after a few seconds. 
	// But it renders it unable to start playing again after marking until you fiddle with the scrub bar.
	// So first of all lets try to specifically stop the new video first. This works, so long as you can find the video player!
	// It is kind of ugly, but can I keep a list of all video objects? It might be useful for pausing anything else if I start a new one too.
	//_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.tmp_mc.extraHolder1002.MediaHolder1002['1002'].jukeboxPlayer.pause();
	for (var i in _global.ORCHID.root.jukeboxHolder.videoList) {
		myTrace("try to stop " + _global.ORCHID.root.jukeboxHolder.videoList[i].player);
		// Sadly pause doesn't seem good enough. It still gets corrupted by stopAllSounds.
		//_global.ORCHID.root.jukeboxHolder.videoList[i].player.pause();
		_global.ORCHID.root.jukeboxHolder.videoList[i].player.stop();
	}
	stopAllSounds();

	// v6.4.2 Don't let marking get double clicked	
	_global.ORCHID.viewObj.setMarking(false);
//	exFeedback_pb.setEnabled(true);
//	_global.ORCHID.root.buttonsHolder.ExerciseScreen.exMarking_pb.setEnabled(false);
//	exInstantFB_pb.setLabel("marking options");
//	exInstantFB_pb.setEnabled(false);
}
View.prototype.cmdFeedback = function(setting) {
	// v6.4.2 Don't let feedback get double clicked	
	myTrace("disable feedback button, called from itself to stop dbl click");
	_global.ORCHID.viewObj.setFeedback(false);
	//trace("request from button " + component.getLabel());
	// 6.0.2.0 remove connection
	//_global.ORCHID.root.exerciseHolder.myConnection.displayFeedback();
	//v6.3.5 Due to scope problems with the duplicate function name, rename this
	// v6.3.6 Merge exercise into main
	_global.ORCHID.root.mainHolder.exerciseNS.displayAllFeedback(setting);
}
// v6.3.5 If the recorder is not setup for use, try again, then show a help button
// if still not working
View.prototype.cmdSetupRecorder = function() { 
	// v6.5.5.8 If control is running in an AIR interface, you can't make a getURL call unless it is in direct response to a user action.
	// As of now we were doing a quick test to see if we could get the recorder going, and if it failed we would then call the badger.
	// It would be better to check the recorder at the start of the exercise and then just do the badger immediately.
	// Moved from below.
	// v6.5.6.5 Special case for Clarity Recorder online - applies to network or online version. Doesn't try the AIR version at all
	if (_global.ORCHID.commandLine.useClarityRecorderOnline) {
		// link to the online page. Get from literals so not hardcoded.
		myTrace("get direct link to online recorder");
		getURL(_global.ORCHID.literalModelObj.getLiteral("ClarityRecorderOnlineURL", "messages"), '_blank');			
	} else if (_global.ORCHID.projector.name == "MDM") {
		//myTrace("mdm browser for " + _global.ORCHID.paths.movie + "..\\..\\Recorder\\ClarityRecorderMDMBadger.html");
		// You have to close this once the recorder opens, or they don't do anything with it...
		//mdm.browser_load("0", 100, 100, 280, 260, _global.ORCHID.paths.movie + "..\\..\\Recorder\\ClarityRecorderMDMLocalBadger.html", true);
		// But this is equally horrible as IE tells you it wants to block active content.
		// How does preview from AP do it? It uses MDM to run another MDM .exe. Blimey.
		//getURL(_global.ORCHID.paths.movie + "..\\..\\Recorder\\ClarityRecorderMDMLocalBadger.html");
		//getURL(_global.ORCHID.paths.movie + "..\\..\\Recorder\\ClarityRecorderMDMLocalBadger.html");
		// So, start a process which is the badger.exe. Pass paths.movie as parameter.
		// Keep track of the process ID so that you can kill it if you are told that the Recorder has started.
		// v6.5.6 An alternative is to simply put the webRecorder into a ZINC exe and run that.
		// It would be attractive for library CDs since there would then be no AIR. You could do this if not online and not already installed the Recorder
		// If you were running a regular client on a network in MDM, you can do the AIR and Clarity Recorder install in start.exe in which case this will not apply.
		// Hmm, of course this is the actionscript for mdm v2.5. But I am running under 2.1 at this point. And my MDM is async. Drat. So do a check in control
		/*
		if (mdm.System.Registry.keyExists("3","SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\com.ClarityEnglish.ClarityRecorder")) {
			var AIRRecorderVersion = mdm.System.Registry.loadString("3","SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\com.ClarityEnglish.ClarityRecorder","DisplayVersion");
		} else {
			var AIRRecorderVersion = 0;
		}
		*/
		var AIRRecorderVersion = _global.ORCHID.projector.recorderRegistry;
		myTrace("AIRRecorderVersion from registry is " + AIRRecorderVersion);
		// v6.5.6.5 Do I mean &&? Network installations don't include the MDMRecorder yet. 
		// But surely it is the best option, even if you actually HAVE recorder installed because it starts immediately, you don't need another dialog.
		// The only drawback is that if you have a later Recorder installed, this would play the one burnt on the CD.
		// For now I will just do this for licence=single which is most likely to be library versions. No, see below.
		if (_global.ORCHID.commandLine.isConnected || AIRRecorderVersion>4) {
		//if (_global.ORCHID.root.licenceHolder.licenceNS.licenceType!=4 && (_global.ORCHID.commandLine.isConnected || AIRRecorderVersion>4)) {
			var badgerApp = _global.ORCHID.paths.movie + "..\\..\\Recorder\\MDMBadger.exe";
			var badgerAppFolder = _global.ORCHID.paths.movie + "..\\..\\Recorder";
			var badgerParameters = " /online=" + _global.ORCHID.commandLine.isConnected.toString();
			myTrace(badgerApp + badgerParameters);
			// v6.5.6.5 need to catch any ZINC exceptions - or is it the Badger program that needs to catch them?
			mdm.exec_adv("Badger",100,100,280,260,"",badgerApp + badgerParameters,badgerAppFolder,2,4); 
			_global.ORCHID.projector.badgerStarted = true;
		} else {
			// You are running through MDM and are not online and the Recorder has not been installed on this computer.
			// So keep it simple and just run the swf rather than try to install the AIR app. So this is a ZINC file.
			// No, not ZINC, surely just a Flash wrapper? No, it is ZINC. But maybe loading html and swf. IE6 might not like that.
			// However, there is a very normal XP computer in the office that won't run MDMRecorder at all (opens, but blank screen)
			// so I think I have to go back to the version that worked for everyone except Brian.
			var badgerApp = _global.ORCHID.paths.movie + "..\\..\\Recorder\\MDMRecorder.exe";
			var badgerAppFolder = _global.ORCHID.paths.movie + "..\\..\\Recorder";
			myTrace(badgerApp);
			mdm.exec_adv("Badger",100,100,800,350,"",badgerApp,badgerAppFolder,2,4); 
		}
	} else {
		// Using the javascript like this fails if you are running in an AIR client instead of the browser.
		// Probably it would be fine. Just due to the security issue of direct user action.
		// Try a direct html call.
		if (_global.ORCHID.commandLine.isConnected==false)  {
			getURL("javascript:openRecorderLocalBadger('" + _global.ORCHID.paths.movie + "')");
			//var badgerFile = "ClarityRecorderLocalBadger.html";
		} else {
			getURL("javascript:openRecorderBadger('" + _global.ORCHID.paths.movie + "')");
			//var badgerFile = "ClarityRecorderBadger.html";
		}
		//getURL("javascript:openWindow('" + _global.ORCHID.paths.movie + "../../Recorder/" + badgerFile + "', 258, 251 ,0 ,0 ,0 ,0 ,0 ,1 ,200 ,200);");
	}
	// I'll still keep going because it might change the interface, in which case the opened window can just be ignored.
			
	_global.ORCHID.viewObj.reopenRecorder(this);
	//myTrace("cmdSetupRecorder from " + this);
	//_global.ORCHID.root.controlNS.testClarityRecorder(this._parent.exRecorder_mc);
	this.delayedWarning = function() {
		myTrace("view.delayedWarning");
		clearInterval(this.delayInt);
		// v6.5.1 Yiu reopen the recorder
		if (_global.ORCHID.projector.lcLoaded) {
			this._parent.play_pb.setVisible(true);
			this._parent.pause_pb.setVisible(true);
			this._parent.stop_pb.setVisible(true);
			this._parent.record_pb.setVisible(true);
			this._parent.recording_pb.setVisible(false);
			this._parent.playing_pb.setVisible(false);
			this._parent.save_pb.setVisible(true);
			this._parent.compare_pb.setVisible(true);
			this._parent.recorderBackground._visible = true;
			
			this._parent.play_pb.setEnabled(false);
			this._parent.pause_pb.setEnabled(false);
			this._parent.stop_pb.setEnabled(false);
			this._parent.record_pb.setEnabled(true);
			this._parent.save_pb.setEnabled(false);
			this._parent.compare_pb.setEnabled(false);
				
			// ahh, now it has been set so try again by faking a button click
			//myTrace("now I can record from " + this);
			this.setEnabled(false); // the setup button
			//this._parent.exRecorder_mc.record_pb.setEnabled(true);
			//this._parent.exRecorder_mc.record_pb.onRelease();
			this._parent.record_pb.setEnabled(true);
			//this._parent.record_pb.onRelease();
		} else {
			this.play_pb.setVisible(false);
			this.pause_pb.setVisible(false);
			this.stop_pb.setVisible(false);
			this.record_pb.setVisible(false);
			this.save_pb.setVisible(false);
			this.compare_pb.setVisible(false);
			this.recording_pb.setVisible(false);
			this.playing_pb.setVisible(false);
			this.recorderBackground._visible = false;
			
			//myTrace("still cannot record");
			delete this.delayedWarning;
			// v6.5.5.7 Use the AIR badge app to install or start the Recorder
			//_global.ORCHID.viewObj.displayMsgBox("noRecorder");
			
			//myTrace("load the badger");
			// I really don't think I can load the badger into this application. It just comes in as a black box, but doesn't even give a parameters error.
			// I suppose it is an AS3 app that just won't load into my AS1.
			// So need to do it as a pop-up window. The only drawback with this is if people have pop-ups blocked. I could do some localConnection checking
			// to see if the window has opened I suppose and then use the old window to direct them to a full URL.
			// I could also try to do it with lightbox function. But for the moment this is effective.
			// But I have just found that the badger doesn't really work with AIR 2. It can do the install, but because publisherID is no longer used
			// it gets all confused about launching. I can write my own script to do the detection, installation or launching.
			// I think I can write that in AS2, which surely I can load from here directly? It might just be neater to do it all in a separate html.
			// v6.5.5.8 It would be much neater to have this picked up from literals or the start page so it can more readily be changed.
			//getURL("javascript:openWindow('" + _global.ORCHID.paths.movie + "../../Recorder/ClarityRecorderBadger.html', 257, 210 ,0 ,0 ,0 ,0 ,0 ,1 ,200 ,200 )");
			// v6.5.5.9 If you are NOT connected to the internet, we need a different badger. Can I detect earlier and then use that here?
			// v6.5.5.9 And if you are running under MDM opening a whole browser is pretty ugly (and the path is wrong)
			// v6.5.5.9 Move to the top of the function - see comment there.
			/*
			// moved code
			*/
			
			//_global.ORCHID.root.buttonsHolder.MessageScreen.navMsgBox.removeMovieClip(); 
			//var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.createEmptyMovieClip("navMsgBox", _global.ORCHID.MsgBoxDepth);
			//myMsgBox.loadMovie(_global.ORCHID.paths.movie + "myBadger.swf?cache=" + new Date().getTime());
					
			// rather than worry about play and stop states, just hide it now that you know you can't
			// use it.
			//this._parent.setEnabled(false);
			//this._parent.record_pb.setEnabled(true);
			//this._parent.play_pb.setEnabled(false);
			//this.stop_pb.setEnabled(false);
		}
	}
	//this.delayInt = setInterval(this, "delayedWarning", 2000);
	this.delayInt = setInterval(this, "delayedWarning", 50);
}
// CUP/GIU for the recorder ocx
View.prototype.cmdRecord = function() {
	myTrace("click record, this=" + this);
	// catch the fact that you can get at the ocx
	// for debugging only
	//_global.ORCHID.projector.lcLoaded = true;
	if (_global.ORCHID.projector.ocxLoaded) {
		//myTrace("ocx recording");
		stopAllSounds();
		// v6.3 If you are running through FSPv2, the usage of ActiveX calls has changed 
		if (_global.ORCHID.projector.version < 2) {
			fscommand("flashstudio.activex_addmethodparam", "\"1\",\"integer\",\"6\"");
			fscommand("flashstudio.activex_runmethod", "\"Action\",\"1\"");
		} else {
		// v6.4.3 Now in ZINC, need to use mdm scripting
			myTrace("record from ZINC " + _global.ORCHID.projector.version);
			// v6.5.5.9 Remove all references to the old ocx
			/*
			_global.ORCHID.projector.variables.ocxID = "0";
			_global.ORCHID.projector.variables.parameterID = "1";
			_global.ORCHID.projector.variables.parameterType = "integer";
			_global.ORCHID.projector.variables.parameterValue = "6";
			_global.ORCHID.projector.variables.doingWhat = "usingOCX";
			mdm.exceptionhandler_enable();
			mdm.activex_addmethodparam(_global.ORCHID.projector.variables.ocxID,
									_global.ORCHID.projector.variables.parameterID,
									_global.ORCHID.projector.variables.parameterType,
									_global.ORCHID.projector.variables.parameterValue);
			_global.ORCHID.projector.variables.methodName = "Action";
			_global.ORCHID.projector.variables.numArgs = "1";
			mdm.activex_runmethod(_global.ORCHID.projector.variables.ocxID,
								_global.ORCHID.projector.variables.methodName,
								_global.ORCHID.projector.variables.numArgs);
			*/
			// During debugging, put this back on so you get full errors from FSP
			// otherwise, always handle exceptions.
			//mdm.exceptionhandler_disable();
		}
	//} else if (_global.ORCHID.projector.nanoGongLoaded) {
	//	ExternalInterface.call("applet.sendGongRequest", "RecordMedia", "audio");
	} else {
		//myTrace("try lc from " + this);
		//v6.3.4 See if you can use the LocalConnection to get at ClarityRecorder
		if (_global.ORCHID.projector.lcLoaded) {
			// make the call to the ClarityRecorder through localConnection
			myTrace("lc recording");
			_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdRecord"); 
		} else {
			//myTrace("lcLoaded=" + _global.ORCHID.projector.lcLoaded + " so don't use it");
			// v6.3.4 You can try checking again in case they have just enabled the recorder
			// Although this check is slightly asynchronous so it will not have an immediate impact
			// You need to use a broadcast from the recorder to do this properly.
			//_global.ORCHID.root.controlNS.testClarityRecorder(this._parent);
			// v6.5.1 Changed by Yiu
			_global.ORCHID.viewObj.reopenRecorder(this);
			/*
			_global.ORCHID.root.controlNS.testClarityRecorder(this._parent);
			this.delayedWarning = function() {
				clearInterval(this.delayInt);
				if (_global.ORCHID.projector.lcLoaded) {
					// ahh, now it has been set so try again by faking a button click
					//myTrace("now I can record");
					this.onRelease();
				} else {
					//myTrace("still cannot record");
					_global.ORCHID.viewObj.displayMsgBox("noRecorder");
					delete this.delayedWarning;
					// rather than worry about play and stop states, just hide it now that you know you can't
					// use it.
					//this._parent.setEnabled(false);
					//this._parent.record_pb.setEnabled(true);
					//this._parent.play_pb.setEnabled(false);
					//this.stop_pb.setEnabled(false);
				}
			}
			this.delayInt = setInterval(this, "delayedWarning", 500);
			*/			
			return;
		}
	}
	// keep track of the time that the record button is DOWN
	this.duration = 0;
	this.startTime = new Date().getTime();
	//myTrace("start recording at " + this.startTime);

	// v6.3.5 Set the onPlayFinished function here so that you can change the buttons once
	// playing is over. This used to be part of the containing exRecorder. But due to debugging
	// I moved all buttons to top level (though it turned out to be onPress etc still hanging around
	// from not clearing up onRollOut in FGraphicButtonSymbol). Now all these functions and vars
	// are attached to the recording button.
	// and for when the ocx knows that it has finished playing a sound...
	this.onPlayFinished = function() {
		myTrace("onPlayFinished in " + this);
		this._parent.stop_pb.onRelease();
	}
	
	// v6.3.4 Now move all code to here from the controller
	//this._parent.stop_pb._x = this._parent.record_pb._x; // bring the stop button to the recorder
	//this._parent.stop_pb._y = this._parent.record_pb._y; // bring the stop button back down
	//myTrace("screen=" + _level0.buttonsHolder.ExerciseScreen);
	this._parent.record_pb.setEnabled(false);
	this._parent.record_pb.setVisible(false);
	this._parent.recording_pb.setVisible(true);
	
	// v6.5.1 Yiu set it to invisible instead of enable
	/* have pause button version
	//this._parent.play_pb.setEnabled(false);
	this._parent.play_pb.setVisible(false);
	this._parent.pause_pb.setVisible(true);
	this._parent.pause_pb.setEnabled(false);
	*/
	
	this._parent.play_pb.setEnabled(false);
	this._parent.playing_pb.setEnabled(false);
	this._parent.pause_pb.setEnabled(false);
	
	this._parent.stop_pb.setEnabled(true);
	// v6.5.1 yiu new buttons for recorder 
	this._parent.save_pb.setEnabled(false);
	this._parent.compare_pb.setEnabled(false);
}
// v6.5.5.6 Called from control in reaction to a localConn event
View.prototype.onPlayFinished = function() {
	myTrace("onPlayFinished");
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.stop_pb.onRelease();
}
View.prototype.onRecordFinished = function() {
	myTrace("onRecordFinished");
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.stop_pb.onRelease();
}

// v6.5.5.7 Clicking an embedded audio will allow you to use the recorder compare
View.prototype.enableRecorderCompare = function(isEnabled) {
	// You can't do 'this' as you haven't been triggered by clicking a button
	//this._parent.compare_pb.setEnabled(isEnabled); 
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.compare_pb.setEnabled(isEnabled); 
}
		
View.prototype.cmdStop = function() {
	//myTrace("click stop, this=" + this);
	// in case you were waiting for play to finish, get rid of that interval as you have manually stopped
	clearInterval(this._parent.record_pb.intID);
	//v6.3.4 Should we use ocx or localConnection for commands?
	if (_global.ORCHID.projector.ocxLoaded) {
		//myTrace("ocx stop");
		// v6.3 If you are running through FSPv2, the usage of ActiveX calls has changed 
		if (_global.ORCHID.projector.version < 2) {
			fscommand("flashstudio.activex_addmethodparam", "\"1\",\"integer\",\"4\"");
			fscommand("flashstudio.activex_runmethod", "\"Action\",\"1\"");
		} else {
		// v6.4.3 Now in ZINC, need to use mdm scripting
			//myTrace("stop from ZINC " + _global.ORCHID.projector.version);
			// v6.5.5.9 Remove all references to the old ocx
			/*
			_global.ORCHID.projector.variables.ocxID = "0";
			_global.ORCHID.projector.variables.parameterID = "1";
			_global.ORCHID.projector.variables.parameterType = "integer";
			_global.ORCHID.projector.variables.parameterValue = "4";
			_global.ORCHID.projector.variables.doingWhat = "usingOCX";
			//mdm.exceptionhandler_enable();
			mdm.activex_addmethodparam(_global.ORCHID.projector.variables.ocxID,
									_global.ORCHID.projector.variables.parameterID,
									_global.ORCHID.projector.variables.parameterType,
									_global.ORCHID.projector.variables.parameterValue);
			_global.ORCHID.projector.variables.methodName = "Action";
			_global.ORCHID.projector.variables.numArgs = "1";
			mdm.activex_runmethod(_global.ORCHID.projector.variables.ocxID,
								_global.ORCHID.projector.variables.methodName,
								_global.ORCHID.projector.variables.numArgs);
			*/
			// During debugging, put this back on so you get full errors from FSP
			// otherwise, always handle exceptions.
			//mdm.exceptionhandler_disable();
		}
	} else {
		if (_global.ORCHID.projector.lcLoaded) {
			// make the call to the ClarityRecorder through localConnection
			//myTrace("lc stop");
			_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdStop");
		} else {
			_global.ORCHID.viewObj.reopenRecorder(this);
		}
	}
	
	// keep track of the time that the record button is DOWN
	if (this._parent.record_pb.duration == 0) {
		this._parent.record_pb.duration = new Date().getTime() - this._parent.record_pb.startTime;
		//myTrace("stop recording, duration=" + this._parent.record_pb.duration);
	}
	// v6.3.4 Now move all code to here from the controller
	this._parent.record_pb.setEnabled(true);
	
	// v6.5.1 Yiu set it to invisible instead of enable
	/* have pause button version
	//this._parent.play_pb.setEnabled(true);
	this._parent.play_pb.setVisible(true);
	this._parent.play_pb.setEnabled(true);
	this._parent.pause_pb.setVisible(false);
	this._parent.pause_pb.setEnabled(false); 
	 * */

	// v6.5.1 Yiu  disable the save button in ocx version
	if (_global.ORCHID.projector.lcLoaded) {	
		this._parent.play_pb.setEnabled(true);			
		this._parent.stop_pb.setEnabled(false);
		this._parent.pause_pb.setEnabled(false);
		this._parent.recording_pb.setVisible(false);
		this._parent.playing_pb.setVisible(false);
		this._parent.record_pb.setVisible(true);
		
		if (_global.ORCHID.projector.isRecorderV2 == true) {
			//myTrace("Clarity Recorder is v2, enable save");
			this._parent.save_pb.setEnabled(true);
			//this._parent.compare_pb.setEnabled(true);
		} else {
			//_global.myTrace("Interface____ b");
			this._parent.save_pb.setEnabled(false);
			//this._parent.compare_pb.setEnabled(false);
		}
		// v6.5.5.6 Compare is purely based on whether an audio file has been played on this screen or not
		//myTrace("lastAudio=" + _global.ORCHID.session.currentItem.lastAudioFile);
		if (_global.ORCHID.session.currentItem.lastAudioFile!=undefined) {
			this._parent.compare_pb.setEnabled(true);
		}
		
	} else if (_global.ORCHID.projector.ocxLoaded){
		this._parent.play_pb.setEnabled(true);			
		this._parent.stop_pb.setEnabled(false);
		this._parent.save_pb.setEnabled(false);
		this._parent.compare_pb.setEnabled(false);
		this._parent.record_pb.setVisible(true);
		this._parent.recording_pb.setVisible(false);
		this._parent.playing_pb.setVisible(false);
	} 
		
	//this._parent.stop_pb._x = this._parent.play_pb._x; // put the stop button in the right place
	//this._parent.stop_pb._y -= 20; // shift the stop button up out of the way
	//_level0.buttonsHolder.ExerciseScreen.record_pb.setEnabled(true);
	//_level0.buttonsHolder.ExerciseScreen.play_pb.setEnabled(true);
	//_level0.buttonsHolder.ExerciseScreen.stop_pb.setEnabled(false);
	//_level0.buttonsHolder.ExerciseScreen.stop_pb._x = _level0.buttonsHolder.ExerciseScreen.play_pb._x; // put the stop button in the right place
	//this._parent.stop_pb._y -= 20; // shift the stop button up out of the way

}

/*	// v6.5.1 Yiu commented the old version for backup
View.prototype.cmdStop = function() {
	//myTrace("click stop, this=" + this);
	// in case you were waiting for play to finish, get rid of that interval as you have manually stopped
	clearInterval(this._parent.record_pb.intID);
	//v6.3.4 Should we use ocx or localConnection for commands?
	if (_global.ORCHID.projector.lcLoaded) {
		// make the call to the ClarityRecorder through localConnection
		//myTrace("lc stop");
		_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdStop");
	} else {
		//myTrace("ocx stop");
		// v6.3 If you are running through FSPv2, the usage of ActiveX calls has changed 
		if (_global.ORCHID.projector.version < 2) {
			fscommand("flashstudio.activex_addmethodparam", "\"1\",\"integer\",\"4\"");
			fscommand("flashstudio.activex_runmethod", "\"Action\",\"1\"");
		} else {
		// v6.4.3 Now in ZINC, need to use mdm scripting
			//myTrace("stop from ZINC " + _global.ORCHID.projector.version);
			_global.ORCHID.projector.variables.ocxID = "0";
			_global.ORCHID.projector.variables.parameterID = "1";
			_global.ORCHID.projector.variables.parameterType = "integer";
			_global.ORCHID.projector.variables.parameterValue = "4";
			_global.ORCHID.projector.variables.doingWhat = "usingOCX";
			//mdm.exceptionhandler_enable();
			mdm.activex_addmethodparam(_global.ORCHID.projector.variables.ocxID,
									_global.ORCHID.projector.variables.parameterID,
									_global.ORCHID.projector.variables.parameterType,
									_global.ORCHID.projector.variables.parameterValue);
			_global.ORCHID.projector.variables.methodName = "Action";
			_global.ORCHID.projector.variables.numArgs = "1";
			mdm.activex_runmethod(_global.ORCHID.projector.variables.ocxID,
								_global.ORCHID.projector.variables.methodName,
								_global.ORCHID.projector.variables.numArgs);
			// During debugging, put this back on so you get full errors from FSP
			// otherwise, always handle exceptions.
			//mdm.exceptionhandler_disable();
		}
	}
	// keep track of the time that the record button is DOWN
	if (this._parent.record_pb.duration == 0) {
		this._parent.record_pb.duration = new Date().getTime() - this._parent.record_pb.startTime;
		//myTrace("stop recording, duration=" + this._parent.record_pb.duration);
	}
	// v6.3.4 Now move all code to here from the controller
	this._parent.record_pb.setEnabled(true);
	this._parent.play_pb.setEnabled(true);
	this._parent.stop_pb.setEnabled(false);
	this._parent.stop_pb._x = this._parent.play_pb._x; // put the stop button in the right place
	//this._parent.stop_pb._y -= 20; // shift the stop button up out of the way
	//_level0.buttonsHolder.ExerciseScreen.record_pb.setEnabled(true);
	//_level0.buttonsHolder.ExerciseScreen.play_pb.setEnabled(true);
	//_level0.buttonsHolder.ExerciseScreen.stop_pb.setEnabled(false);
	//_level0.buttonsHolder.ExerciseScreen.stop_pb._x = _level0.buttonsHolder.ExerciseScreen.play_pb._x; // put the stop button in the right place
	//this._parent.stop_pb._y -= 20; // shift the stop button up out of the way

}  
  
 * */

// v6.5.1 Yiu new code for recorder
View.prototype.cmdSave	= function() {
	//var filename = "ClarityRecorder";
	//var filename = "null";
	var filename = undefined;
	if (_global.ORCHID.projector.lcLoaded) {
		_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdSave", filename);
	} else {
		_global.ORCHID.viewObj.reopenRecorder(this);
		return ;
	}
}

View.prototype.cmdPause = function() {
	if (_global.ORCHID.projector.lcLoaded) {
		this._parent.playing_pb.setVisible(false);
		this._parent.play_pb.setEnabled(true);
		_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdPause");
	}
}
// End v6.5.1 Yiu new code for recorder
// v6.5.5.6 New function for v4 recorder to allow comparison of waveforms
// This is triggered from a button on the Orchid interface. It means, display the last played audio as a model in the Recorder.
// The last recording I made will already be there (if I have made one at all).
// This will also be triggered when the compare waveforms is already open and I want a different model.
View.prototype.cmdCompareWaveforms = function() {
	if (_global.ORCHID.projector.lcLoaded) {
		// How to get the last audio filename clicked?
		// see display.showMediaItem
		var modelFilename = _global.ORCHID.session.currentItem.lastAudioFile;
		//myTrace("compare using model=" + modelFilename);
		// If you haven't played an audio yet, there will be nothing to compare, so just exit. 
		// Ideally the icon wouldn't be active until you HAD played something.
		if (modelFilename==undefined) {
			myTrace("nothing to compare");
			return;
		}
		// The above is a perfectly good relative path. But the recorder might be running anywhere (desktop, another domain etc)
		// so we have to send a full URL. Do I know this at all?
		//_global.ORCHID.paths.root=http://dock/Fixbench/Software/Common/
		//_global.ORCHID.commandLine.userDataPath=/Fixbench/ClearPronunciation
		// controlFrame2 has code to get full path from a relative one, but it doesn't handle absolute web addresses
			if (modelFilename.indexOf("..")>=0) {
				myTrace("get full URL from relative model with udp=" + _global.ORCHID.commandLine.userDataPath);
				// break the path into folders
				var rootFolders = _global.ORCHID.commandLine.userDataPath.split("/");
				var modelFolders = modelFilename.split("/");
				// if the first folder is a parent navigator, drop it and the matching root one
				while (modelFolders[0] == ".." && modelFolders.length>1 && rootFolders.length>1) {
					//trace(contentFolders[0]);
					//myTrace("drop " + rootFolders[rootFolders.length-1]);
					rootFolders.pop();
					modelFolders.shift();
				}
				var builtPath = _global.ORCHID.functions.addSlash(rootFolders.join("/")) + _global.ORCHID.functions.addSlash(modelFolders.join("/"));
			} else if (modelFilename.indexOf("/")==0) {
				myTrace("get full URL from absolute model with root=" + _global.ORCHID.paths.root);
				// So the domain is...
				// the part of paths.root before the first [single] slash. Can it really be that simple?
				var domain =  _global.ORCHID.paths.root.substr(0, _global.ORCHID.paths.root.indexOf("/", _global.ORCHID.paths.root.indexOf("//")+2));
				var builtPath = domain + modelFilename;
			// Any other cases?
			} else {
				var builtPath = modelFilename;
			}
		
		myTrace("built path=" + builtPath);
		_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdCompareTo", builtPath);
	}
}

View.prototype.cmdPlay = function() {
	//myTrace("click play, this=" + this);
	//v6.3.4 Should we use ocx or localConnection for commands?
	if (_global.ORCHID.projector.ocxLoaded) {
		//myTrace("ocx play");
		// EGU - this doesn't seem to stop the sound quickly enough as you still get the
		// wave device warning from SoundSystem.
		stopAllSounds();
		// v6.3 If you are running through FSPv2, the usage of ActiveX calls has changed 
		if (_global.ORCHID.projector.version < 2) {
			fscommand("flashstudio.activex_addmethodparam", "\"1\",\"integer\",\"10\"");
			fscommand("flashstudio.activex_runmethod", "\"Action\",\"1\"");
		} else {
		// v6.4.3 Now in ZINC, need to use mdm scripting
			//myTrace("play from ZINC " + _global.ORCHID.projector.version);
			// v6.5.5.9 Remove all references to the old ocx
			/*
			_global.ORCHID.projector.variables.ocxID = "0";
			_global.ORCHID.projector.variables.parameterID = "1";
			_global.ORCHID.projector.variables.parameterType = "integer";
			_global.ORCHID.projector.variables.parameterValue = "10";
			_global.ORCHID.projector.variables.doingWhat = "usingOCX";
			//mdm.exceptionhandler_enable();
			mdm.activex_addmethodparam(_global.ORCHID.projector.variables.ocxID,
									_global.ORCHID.projector.variables.parameterID,
									_global.ORCHID.projector.variables.parameterType,
									_global.ORCHID.projector.variables.parameterValue);
			_global.ORCHID.projector.variables.methodName = "Action";
			_global.ORCHID.projector.variables.numArgs = "1";
			mdm.activex_runmethod(_global.ORCHID.projector.variables.ocxID,
								_global.ORCHID.projector.variables.methodName,
								_global.ORCHID.projector.variables.numArgs);
			*/
			// During debugging, put this back on so you get full errors from FSP
			// otherwise, always handle exceptions.
			//mdm.exceptionhandler_disable();
		}
		//_global.ORCHID.viewObj.stillPlaying(this._parent);
	} else {
		if (_global.ORCHID.projector.lcLoaded) {
			// make the call to the ClarityRecorder through localConnection
			//myTrace("lc play");
			_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdPlay");
			// the onPlayFinished event is broadcast on teh local connection and passed
			// from there direct to the recorderController. See control.fla for definition
			// Er, not any more. Now we know how long the recorded sound is, so set an interval
			// to kill it after that. This is common to ocx recording as well, so use it for both, see below...
		} else {
			_global.ORCHID.viewObj.reopenRecorder(this);
			return;
		}
	}
	
	// Er, not any more. Now we know how long the recorded sound is, so set an interval
	// to kill it after that. This is common to ocx recording as well, so use it for both, see below...
	// v6.5.5.6 New recorder will send notification once playing is over, so you can ignore the timer.
	if (_global.ORCHID.projector.version < 2) {
		// listen for the localConnection notification
	} else {
		this._parent.record_pb.stopPlaying = function() {
			//myTrace("stop playing in " + this);
			clearInterval(this.intID);
			this.onPlayFinished();
		}
		this._parent.record_pb.intID = setInterval(this._parent.record_pb, "stopPlaying", (this._parent.record_pb.duration + 250));
		//myTrace("start delay of " + (this._parent.duration + 250));
	}
	
	// v6.3.4 Now move all code to here from the controller
	//this._parent.stop_pb._x = this._parent.play_pb._x; // put stop in the right place
	//this._parent.stop_pb._y = this._parent.play_pb._y; // bring the stop button back down
	this._parent.record_pb.setEnabled(false);
	
	// v6.5.1 Yiu set it to invisible instead of enable
	/* have pause button version
	//this._parent.play_pb.setEnabled(false);
	this._parent.play_pb.setVisible(false);
	this._parent.pause_pb.setVisible(true);
	this._parent.pause_pb.setEnabled(true);
	*/
	this._parent.play_pb.setEnabled(false);
	this._parent.playing_pb.setVisible(true);
	this._parent.playing_pb.setEnabled(true);
		
	this._parent.stop_pb.setEnabled(true);
	// v6.5.1 yiu new buttons for recorder 
	this._parent.pause_pb.setEnabled(true);	// disable it forever because the setInterval things above, it timeout me when i pause it, if i have to change it it should be lots of trouble
	this._parent.save_pb.setEnabled(false);
	this._parent.compare_pb.setEnabled(false);
}

View.prototype.reopenRecorder	= function(myViewObj)
{
	myTrace("view.reopenRecorder");
	_global.ORCHID.root.controlNS.testClarityRecorder(this._parent);
	var delayedWarningfunction = function() {
		myTrace("view.delayedWarningFunction");
		clearInterval(this.delayInt);
		if (_global.ORCHID.projector.lcLoaded) {
			this._parent.stop_pb.onRelease();	// v6.5.1 Yiu commented, to stop it instead
		} else {
			_global.myViewObj.displayMsgBox("noRecorder");
			delete this.delayedWarning;
		}
	}
	var delayInt = setInterval(this, "delayedWarningfunction", 3000);
}

/*	// v6.5.1 Yiu old cmdPlay
View.prototype.cmdPlay = function() {
	//myTrace("click play, this=" + this);
	//v6.3.4 Should we use ocx or localConnection for commands?
	if (_global.ORCHID.projector.lcLoaded) {
		// make the call to the ClarityRecorder through localConnection
		//myTrace("lc play");
		_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdPlay");
		// the onPlayFinished event is broadcast on teh local connection and passed
		// from there direct to the recorderController. See control.fla for definition
		// Er, not any more. Now we know how long the recorded sound is, so set an interval
		// to kill it after that. This is common to ocx recording as well, so use it for both, see below...
	} else {
		//myTrace("ocx play");
		// EGU - this doesn't seem to stop the sound quickly enough as you still get the
		// wave device warning from SoundSystem.
		stopAllSounds();
		// v6.3 If you are running through FSPv2, the usage of ActiveX calls has changed 
		if (_global.ORCHID.projector.version < 2) {
			fscommand("flashstudio.activex_addmethodparam", "\"1\",\"integer\",\"10\"");
			fscommand("flashstudio.activex_runmethod", "\"Action\",\"1\"");
		} else {
		// v6.4.3 Now in ZINC, need to use mdm scripting
			//myTrace("play from ZINC " + _global.ORCHID.projector.version);
			_global.ORCHID.projector.variables.ocxID = "0";
			_global.ORCHID.projector.variables.parameterID = "1";
			_global.ORCHID.projector.variables.parameterType = "integer";
			_global.ORCHID.projector.variables.parameterValue = "10";
			_global.ORCHID.projector.variables.doingWhat = "usingOCX";
			//mdm.exceptionhandler_enable();
			mdm.activex_addmethodparam(_global.ORCHID.projector.variables.ocxID,
									_global.ORCHID.projector.variables.parameterID,
									_global.ORCHID.projector.variables.parameterType,
									_global.ORCHID.projector.variables.parameterValue);
			_global.ORCHID.projector.variables.methodName = "Action";
			_global.ORCHID.projector.variables.numArgs = "1";
			mdm.activex_runmethod(_global.ORCHID.projector.variables.ocxID,
								_global.ORCHID.projector.variables.methodName,
								_global.ORCHID.projector.variables.numArgs);
			// During debugging, put this back on so you get full errors from FSP
			// otherwise, always handle exceptions.
			//mdm.exceptionhandler_disable();
		}
		//_global.ORCHID.viewObj.stillPlaying(this._parent);
	}
	// Er, not any more. Now we know how long the recorded sound is, so set an interval
	// to kill it after that. This is common to ocx recording as well, so use it for both, see below...
	this._parent.record_pb.stopPlaying = function() {
		//myTrace("stop playing in " + this);
		clearInterval(this.intID);
		this.onPlayFinished();
	}
	this._parent.record_pb.intID = setInterval(this._parent.record_pb, "stopPlaying", (this._parent.record_pb.duration + 250));
	//myTrace("start delay of " + (this._parent.duration + 250));
	// v6.3.4 Now move all code to here from the controller
	this._parent.stop_pb._x = this._parent.play_pb._x; // put stop in the right place
	//this._parent.stop_pb._y = this._parent.play_pb._y; // bring the stop button back down
	this._parent.record_pb.setEnabled(false);
	this._parent.play_pb.setEnabled(false);
	this._parent.stop_pb.setEnabled(true);
}
  
 * */
  
/* See above comment about stillPlaying
View.prototype.stillPlaying = function(recorderControl) {
	//myTrace("starting to check on playing");
	_global.ORCHID.root.returnCode = undefined;
	OCXCounter=0;
	OCXInt = 0;
	//this.recorderControl = recorderControl;
	getPlaying = function () {
		//myTrace("in getPlaying with returnCode=" + _global.ORCHID.root.returnCode + ".");
		if (_global.ORCHID.root.returnCode != undefined) {
			clearInterval(OCXInt);
			if (_global.ORCHID.root.returnCode) {
				myTrace("still playing in " + recorderControl);
				_global.ORCHID.viewObj.stillPlaying(recorderControl);
			} else {
				myTrace("sound stopped for " + recorderControl);
				recorderControl.onPlayFinished();
			}
		} else if (OCXCounter > 10) {
			clearInterval(OCXInt);
			myTrace("ocx not responding to getProperty");
			// so you might as well pretend/assume that you have stopped
			recorderControl.onPlayFinished();
		} else {
			OCXCounter++;
		}
	}
	//myTrace("issue activexget_property command");
	// v6.3 If you are running through FSPv2, the usage of ActiveX calls has changed 
	if (_global.ORCHID.projector.version < 2) {
		fscommand("flashstudio.activex_getproperty", "\"StillPlaying\",_global.ORCHID.root.returnCode");
	} else {
		FSP_id = "0";
		fscommand("flashstudio.activex_getproperty", "FSP_id,\"StillPlaying\",_root.returnCode");
	}
	OCXInt = setInterval(getPlaying, 500);	
}
*/
// you need to let other modules set these two buttons to be on or off
View.prototype.setMarking = function(enabled) {
	//myTrace("make marking button=" + enabled)
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.exMarking_pb.setEnabled(enabled);
	//v6.4.2 You need to be smarter about whether these are on or off in the first place
	// Only change them if std is choosing
	if (_global.ORCHID.LoadedExercises[0].settings.buttons.chooseInstant) {
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.markingOptions._visible = enabled;
	}
}

// v6.4.2.4 A start again button, shown after marking
View.prototype.setStartAgain = function(enabled) {
	myTrace("setStartAgain.enabled = " + enabled);
	if (enabled) {
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.navStartAgain_pb.setEnabled(enabled);
	} else {
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.navStartAgain_pb.setEnabled(enabled);
	}
}

View.prototype.setFeedback = function(enabled) {
	myTrace("feedback button=" + enabled)
	if (enabled) {
		//trace("mode=" + _global.ORCHID.LoadedExercises[0].mode);
		//v 6.3.3 change mode to settings
		//if (!(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NoFeedbackButton) && (_global.ORCHID.LoadedExercises[0].feedback.length > 0)) {
		if (	_global.ORCHID.LoadedExercises[0].settings.buttons.feedback && 
			(_global.ORCHID.LoadedExercises[0].feedback.length > 0)) {
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.exFeedback_pb.setEnabled(enabled);
		} else {
			myTrace("ask for fb button, but buttons.feedback=" + _global.ORCHID.LoadedExercises[0].settings.buttons.feedback + " and length=" + _global.ORCHID.LoadedExercises[0].feedback.length);
		}
	} else {
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.exFeedback_pb.setEnabled(enabled);
	}
}
// These functions copied  from backup of 18 Nov
// But then edited to include stuff overwritten by scaleUp editing
View.prototype.cmdDelayedMarking = function(component){
	// switch to delayed marking, so take off the instantMarking bit in the mode
	//myTrace("switch to delayed marking");
	// v6.3.3 change mode to settings
	//_global.ORCHID.LoadedExercises[0].mode &= ~_global.ORCHID.exMode.InstantMarking;
	_global.ORCHID.LoadedExercises[0].settings.marking.delayed = true;
	_global.ORCHID.LoadedExercises[0].settings.marking.instant = false;
	// v6.2 this bit redone
	// If you are in a gap when you clicked on this option, you should go straight back to it
	if (_global.ORCHID.session.currentItem.lastGap != undefined) {
		_global.ORCHID.session.currentItem.nextGap = _global.ORCHID.session.currentItem.lastGap;
		//_global.ORCHID.session.currentItem.nextGap.interval = setInterval(makeNextTypingBox, 100);
		makeNextTypingBox();
	}
	//exInstantFB_pb.setLabel("instant");
	//exinstantFB_pb.ic_mc.caption.text = "instant";
	//exInstantFB_pb.setClickHandler("cmdInstantMarking", this);
	//exInstantFB_pb.setReleaseAction(_global.ORCHID.root.buttonsHolder.buttonsNS.cmdInstantMarking);
	//exInstantFB_pb.setLabel("instant"+newline+"marking");
}
View.prototype.cmdInstantMarking = function(component){
	// switch to instant marking, so put on the instantMarking bit in the mode
	//myTrace("switch to instant marking");
	// v6.3.3 change mode to settings
	//_global.ORCHID.LoadedExercises[0].mode |= _global.ORCHID.exMode.InstantMarking;
	_global.ORCHID.LoadedExercises[0].settings.marking.delayed = false;
	_global.ORCHID.LoadedExercises[0].settings.marking.instant = true;
	// v6.2 this bit redone
	// If you are in a gap when you clicked on this option, you should go straight back to it
	if (_global.ORCHID.session.currentItem.lastGap != undefined) {
		_global.ORCHID.session.currentItem.nextGap = _global.ORCHID.session.currentItem.lastGap;
		//_global.ORCHID.session.currentItem.nextGap.interval = setInterval(makeNextTypingBox, 100);
		makeNextTypingBox();
	}
	//exInstantFB_pb.setLabel("delayed");
	//exinstantFB_pb.ic_mc.caption.text = "delayed";
	//exInstantFB_pb.setClickHandler("cmdDelayedMarking", this);
	//exInstantFB_pb.setReleaseAction(_global.ORCHID.root.buttonsHolder.buttonsNS.cmdDelayedMarking);
	//exInstantFB_pb.setLabel("delayed"+newline+"marking");
}
View.prototype.cmdChangeMarking = function(component){
	//myTrace("switch to other marking from " + component);
	// v6.2 this bit redone
	// If you are in a gap when you clicked on this option, you should go straight back to it
	if (_global.ORCHID.session.currentItem.lastGap != undefined) {
		_global.ORCHID.session.currentItem.nextGap = _global.ORCHID.session.currentItem.lastGap;
		//_global.ORCHID.session.currentItem.nextGap.interval = setInterval(makeNextTypingBox, 100);
		makeNextTypingBox();
	}
	// switch between instant and delayed marking
	// a tick (true) means instant marking please
	// v6.3.3 change mode to settings
	if (component.getValue()) {
		//_global.ORCHID.LoadedExercises[0].mode |= _global.ORCHID.exMode.InstantMarking;
		_global.ORCHID.LoadedExercises[0].settings.marking.instant = true;
		_global.ORCHID.LoadedExercises[0].settings.marking.delayed = false;
	} else {
		_global.ORCHID.LoadedExercises[0].settings.marking.instant = false;
		_global.ORCHID.LoadedExercises[0].settings.marking.delayed = true;
		//_global.ORCHID.LoadedExercises[0].mode &= ~_global.ORCHID.exMode.InstantMarking;
	}
}

// this button will list out all resources attached to this exercise in a way
// that the user can select, and it will then 'play' them.
View.prototype.cmdListResources = function(component) {
	// the glass tile doesn't send back any objects, can you copy the "this" functionality from FPushButton?
	// but 'this' seems to be the correct button if I trace it.
	// so wheras we used to have component = _global.ORCHID.root.buttonsHolder.exResource_pb
	// now, 'this' is the same thing
	// so to get the buttons object, you have to do this._parent.buttons I suppose
	//trace("request from button " + this + " parent=" + this._parent);
	var mediaList = _global.ORCHID.root.jukeboxHolder.myJukeBox.mediaList;
	//trace("there are " + mediaList.length + " items in the media list");
	var listHeight = 77; // ditto for number of items
	// check what to do - first just remove the list if it is already showing
	//trace("making resources list in " + this._parent);
	//Note I have attached resourcesList to the jukeBox rather than buttons
	if (_global.ORCHID.root.jukeboxHolder.resourcesList._visible == true) {
		_global.ORCHID.root.jukeboxHolder.resourcesList.removeMovieClip();
	// then only display a list if there is something to go in it
	} else if (mediaList.length == 1) {
		_global.ORCHID.root.jukeboxHolder.myJukeBox.setMedia(mediaList[0], true);
	} else if (mediaList.length > 1) {
		//var initObj = {_x:exResources_pb._x - listWidth, _y:exResources_pb._y};
		//var initObj = {_x:-listWidth, _y:-listHeight};
		var initObj = {_x: _global.ORCHID.root.buttonsHolder.ExerciseScreen.exResources_pb._x - 20 - _global.ORCHID.root.jukeboxHolder._x, _y: _global.ORCHID.root.buttonsHolder.ExerciseScreen.exResources_pb._y + 20 - _global.ORCHID.root.jukeboxHolder._y};
		//var listBox_lb = _global.ORCHID.root.buttonsHolder.attachMovie("FListBoxSymbol", "resourcesList", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj);
		//trace("jb is " + _global.ORCHID.root.jukeBoxHolder);
		var listBox_lb = _global.ORCHID.root.jukeboxHolder.attachMovie("FListBoxSymbol", "resourcesList", _global.ORCHID.root.jukeboxHolder.jukeboxNS.depth++, initObj);
		//trace("listbox depth is " + listBox_lb.getDepth() + " for " + listBox_lb);
		_global.ORCHID.root.jukeboxHolder._visible = true;
		//_global.ORCHID.root.jukeboxHolder.myJukeBox._visible = true;
		_global.ORCHID.root.jukeboxHolder.enabled = true;
		//trace("created media list visible=" + listBox_lb._visible + " jbHolder.visible=" + _global.ORCHID.root.jukeboxHolder._visible);
		listBox_lb.setAutoHideScrollBar(false);
		listBox_lb.setRowCount(3);
		//trace("list box is "+ listBox_lb);
		//Note: can you disable an item in a list box? If so, do that here with showAfterMarking mode
		// otherwise just don't show it at all
		var exMode = _global.ORCHID.LoadedExercises[0].mode;
		// v6.3 Measure the width of the names properly (but assume the TF used in the list box)
		var thisWidth; var maxWidth = 0;
		var thisTF = new TextFormat();
		thisTF.font = "Verdana"; thisTF.size = 13;
		// v6.5 Mac problem
		if (System.capabilities.os.toLowerCase().indexOf("mac")==0) {
			 var textExtentCorrector = 20; // What is this value? web seems to suggest twips, but it is not truly accurate
		} else {
			var textExtentCorrector = 1;
		}
		for (var i=0; i<mediaList.length; i++) {
			// v6.3 To get the appropriate width of each name:
			// v6.5 Note that this would have Mac problems, but I don't think this function is ever used anymore. Better to add in though.
			//var thisWidth = thisTF.getTextExtent(mediaList[i].jbName).width;
			var thisWidth = thisTF.getTextExtent(mediaList[i].jbName).width/textExtentCorrector;
			//myTrace(mediaList[i].jbName + " width=" + thisWidth);
			if (thisWidth > maxWidth) maxWidth = thisWidth;
			//trace(mediaList[i].jbName + " is afterMarking=" + (mediaList[i].jbPlayMode == _global.ORCHID.mediaMode.ShowAfterMarking) + " and markingDone=" + (exMode & _global.ORCHID.exMode.MarkingDone));
			//v6.3.3 move marking status to currentItem
			//if ((mediaList[i].jbPlayMode != _global.ORCHID.mediaMode.ShowAfterMarking) || (exMode & _global.ORCHID.exMode.MarkingDone)) {
			if ((mediaList[i].jbPlayMode != _global.ORCHID.mediaMode.ShowAfterMarking) || _global.ORCHID.session.currentItem.afterMarking) {
				listBox_lb.addItem(mediaList[i].jbName, mediaList[i]);
				//trace("added item to list");
			}
		}
		var widthAdjust = maxWidth + 23;
		// get current width so you can do it right aligned
		listBox_lb._x = initObj._x - (widthAdjust - listBox_lb._width);
		listBox_lb.setWidth(widthAdjust);
		//trace("set clickhandler to " + this._parent.buttonsNS.playResource);
		//Note: you should set the size to let you see all the text and then
		// shift it so that it is right aligned to the left of the resources button
		//listBox_lb.setChangeHandler("playResource", _global.ORCHID.root.buttonsHolder.buttonsNS);
		listBox_lb.setChangeHandler("playResource", _global.ORCHID.viewObj);
		// you should also set a key handler here so that if they do anything else
		// but select from the list box you will disappear yourself.
		// Since you cannot refresh the contents of the drag pane quickly enough
		// when you want to put something in it, you can do it here
		//trace("call clearMedia from cmdListResources");
		//_global.ORCHID.root.jukeboxHolder.myJukeBox.clearMedia();

	}
}
View.prototype.playResource = function(component) {
	// Since you cannot refresh the contents of the drag pane quickly enough
	// when you want to put something in it, you need a pause (minimal) after the clear
	_global.ORCHID.root.jukeboxHolder.myJukeBox.clearMedia();
	var playMedia = function(component) {
		clearInterval(thisInt);
		var thisResource = component.getSelectedItem().data;
		component.removeMovieClip();
		//myTrace("ok, now play " + thisResource.jbURL);
		_global.ORCHID.root.jukeboxHolder.myJukeBox.setMedia(thisResource, true);
	}
	var thisInt = setInterval(playMedia, 100, component);
}

// globally based buttons
View.prototype.cmdProgress = function(component) {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	//myTrace("request from button " + component.getLabel());
	// 6.0.2.0 remove connection
	//_global.ORCHID.root.progressHolder.myConnection.displayProgress();
	//_global.ORCHID.root.progressHolder.progressNS.displayProgress();
	
	//myTrace("in cmdProgress");
	// v6.3.5 Move to CEPopupWindow
	//_global.ORCHID.viewObj.displayScreen("ProgressScreen");
	
	// Note that this function does formatting as well as reading of the scaffold
	// probably not a good idea
	// So now this will do some preparation work
	var progressList = _global.ORCHID.course.scaffold.getUserProgress();
	
	// v6.4.2.8 First build an XML object of the progress
	var myProgressDetails = new XML();
	myProgressDetails = _global.ORCHID.course.scaffold.getNonRandomProgressDetails(0);
	//myTrace("my progress xml = " + myProgressDetails.toString());
	var everyoneProgressDetails = new XML();
	everyoneProgressDetails = _global.ORCHID.course.scaffold.getNonRandomProgressDetails(2);
	//myTrace("all progress xml = " + everyoneProgressDetails.toString());

	// v6.4.3 Add separate module for displaying progress
	// Use a nominal check so that if they don't have Flash 9 they still see the old list
	var myPlayerVersionNum = new versionNumber(_global.ORCHID.projector.flashVersion);
	var mediaDepth = Number(_global.ORCHID.mediaRelatedDepth) + Number(me.id);
	// v6.5. For the moment just do it for Tense Buster until we are happier with the interface
	// v6.5.4.3 use for all now - it will default to AP colours if not specifically set
	//if (	myPlayerVersionNum.atLeast("9.0") &&
	// v6.5.4.3 Allow an old progress (due to F6 and F8 security issues) - variable set in controlFrame3 when progressHolder unloaded
	//if (myPlayerVersionNum.atLeast("9.0")) {
	if (myPlayerVersionNum.atLeast("9.0") && _global.ORCHID.root.progressHarness==false) {
		//false &&   // use this line to FORCE the old style for production purposes
		/*
		((_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) || 
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ar") >= 0) || 
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/bw") >= 0) || 
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sss") >= 0) || 
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("bc/pep") >= 0) || 
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("futureperfect/cccs") >= 0) || 
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ap") >= 0))) {
		*/
		//myTrace("new progress reporting");
		// v6.4.2.8 Create the window
		// v6.2 Put the course name in the progress title?
		var courseName = _global.ORCHID.course.scaffold.caption;
		//if (_global.ORCHID.user.name == "_orchid" || _global.ORCHID.user.name == "") {
		// v6.4.2.7 Not all CUP is anonymous
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		//	var progressTitle = findReplace(_global.ORCHID.literalModelObj.getLiteral("progressAnon", "labels"), "[x]", courseName);
		// v6.3.5 Use the anonymous name if it is a special name, no name or a Light version (which are always anonymous)
		//} else if (_global.ORCHID.user.name == "_orchid" || 
		if (_global.ORCHID.user.name == "_orchid" || 
				_global.ORCHID.user.name == "" ||
				_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("light") >= 0) {
			//myTrace("use progressAnon");
			var progressTitle = findReplace(_global.ORCHID.literalModelObj.getLiteral("progressAnon", "labels"), "[x]", courseName);
		} else {
			//myTrace("use progressTitle");
			var progressTitle = findReplace(findReplace(_global.ORCHID.literalModelObj.getLiteral("progressTitle", "labels"), "[y]", _global.ORCHID.user.name), "[x]", courseName);
		}
		// create the window
		// v6.4.3 Now much bigger
		//var initObj = { _x:180, _y:160, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
		// v6.5.6.4 New SSS needs progress to start lower than the jukebox so it doesn't underlay it
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			var initObj = { _x:45, _y:60, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
		} else {
			var initObj = { _x:45, _y:41, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
		}
		if (_global.ORCHID.root.buttonsHolder.MessageScreen.progress_SP == undefined) {
			var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "progress_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
		} else {
			// if the window already exists, simply make sure it is displayed.
			_global.ORCHID.root.buttonsHolder.MessageScreen.progress_SP._visible = true; 
			return;
		}
		myPane.setTitle(progressTitle);
		// v6.5 temp hold the title here
		myPane.thisTitle = progressTitle;
		myPane.setContentBorder(false);
		myPane.setCloseButton(true);
		myPane.setResizeButton(false);
		myPane.setMinSize(500, 250);
		// v6.5.6.4 New SSS needs progress to start lower than the jukebox so it doesn't underlay it
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			var maxHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 80;
			// v6.4.2.7 base screen height on the fla (this one is as big as you can get it)
		} else {
			var maxHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 60;
		}
		//myTrace("prog window max height=" + maxHeight);
		myPane.setMaxSize(670, maxHeight);
		var contentHolder = myPane.getContent();
		// set up actions for the pane buttons (if any)
		myPane.onClose = function() {
			//myTrace("try to close progressScreen");
			//_global.ORCHID.viewObj.clearScreen("ProgressScreen");
		}
		// set up what to do on resizing
		//myPane.onResize = function(dims) {
		//	var contentHolder = this.getContent();
		//}
		myPane.onPrint = function(pane) {
			var contentHolder = pane.getContent();
			var myProgress = contentHolder["progressHolder"];
			//myTrace("prog is " + myProgress);
			//if (pane.getTitle()==undefined) 
			myTrace("send print cmd with " + pane.getTitle());
			myProgress.printPage(pane.getTitle());
		}
		// v6.5.6.4 For new SSS I want to add all the buttons to the bottom
		myPane.onScores = function(pane) {
			var contentHolder = pane.getContent();
			var myProgress = contentHolder["progressHolder"];
			myTrace("send scores cmd to progress");
			myProgress.displayScores();
		}
		myPane.onCompare = function(pane) {
			var contentHolder = pane.getContent();
			var myProgress = contentHolder["progressHolder"];
			myTrace("send compare cmd to progress");
			myProgress.displayCompare();
		}
		myPane.onAnalysis = function(pane) {
			var contentHolder = pane.getContent();
			var myProgress = contentHolder["progressHolder"];
			myTrace("send analysis cmd to progress");
			myProgress.displayAnalysis();
		}
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9")>=0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2")>=0) { 
			myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myPane.onPrint, noClose:true},
							{caption:_global.ORCHID.literalModelObj.getLiteral("progress_global_title1", "messages"), setReleaseAction:myPane.onScores, noClose:true, tabStyle:true},
							{caption:_global.ORCHID.literalModelObj.getLiteral("progress_global_title2", "messages"), setReleaseAction:myPane.onCompare, noClose:true},
							{caption:_global.ORCHID.literalModelObj.getLiteral("progress_global_title3", "messages"), setReleaseAction:myPane.onAnalysis, noClose:true}]);
			//myTrace("added lots of buttons to progress");
			myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myPane.onClose},
						{key:["P".charCodeAt(0)], setReleaseAction:myPane.onPrint},
						{key:["S".charCodeAt(0)], setReleaseAction:myPane.onScores},
						{key:["C".charCodeAt(0)], setReleaseAction:myPane.onCompare},
						{key:["A".charCodeAt(0)], setReleaseAction:myPane.onAnalysis}]);
		} else {
			myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myPane.onPrint, noClose:true}]);
			myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myPane.onClose},
						{key:["P".charCodeAt(0)], setReleaseAction:myPane.onPrint}]);
		}
		myPane.setCloseHandler(myPane.onClose);
		myPane.setResizeHandler(myPane.onResize);
		//myPane.setPaneMaximumSize(500, 550);
		// and get the scroll bar right by using resize routine
		myPane.setContentSize(670,580);
		//myPane.onResize(myPane.getContentSize());
		myPane.setEnabled(true);
		
		// Then load the progress player (copied from videoPlayer)
		var myProgress = contentHolder.createEmptyMovieClip("progressHolder", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
		//myTrace(_global.ORCHID.root.buttonsHolder.buttonsNS.depth + "-add progress to " + myProgress);

		// v6.5 Case sensitive
		//contentHolder.pPlayerMC = _global.ORCHID.paths.movie + "Progress.swf";
		contentHolder.pPlayerMC = _global.ORCHID.paths.movie + "progress.swf";
		contentHolder.myXML = myProgressDetails;
		contentHolder.everyoneXML = everyoneProgressDetails;
					
		// create some little asynch number to load up the parameters once the swf is loaded
		contentHolder.contentSize = myPane.getContentSize();
		contentHolder.progressSetup = function() {
			//myTrace("progressSetup");
			var myProgress = this["progressHolder"];
			//myTrace("send data to progress.swf");
			//myTrace("width=" + this.contentSize.width + " height=" + this.contentSize.height);
			//myTrace("myXML=" + this.myXML.toString());
			//myTrace("everyoneXML=" + this.everyoneXML.toString());
			// v6.5.5.6 In order for progress to sort correctly, we need to include unit number in the XML for the unit nodes
			myProgress.initApp(this.myXML, this.everyoneXML, this.contentSize.width, this.contentSize.height);
		}
		// v6.4.2.4 You need to know once the .swf is loaded.
		// I don't think this first method is used, but duplicate from videoPlayer anyway
		contentHolder.progressLoader = function(){
			var myProgress = this["progressHolder"];
			myTrace("checking " + myProgress + " count=" + this.progressLoaderCount + " bytes loaded=" + myProgress.getBytesLoaded());
			if (myProgress.getBytesLoaded() > 4 && myProgress.getBytesLoaded() >= myProgress.getBytesTotal()) {
				myTrace("player fully loaded, bytes=" + myProgress.getBytesTotal());
				clearInterval(this.progressLoaderInt);
				this.progressSetup();
			} else if (this.progressLoaderCount>10){
				// how to show that the video cannot load? Should be impossible since you loaded it in the first loading
				// set in control.swf. But strange things happen.
				myTrace("cannot load file " + this.pPlayerMC,1);
				clearInterval(this.progressLoaderInt);
				// why would I try to set it up anyway - just in case the bytes count is crap??
				//this.videoSetup();
			} else {
				this.progressLoaderCount++;
			}
		}
		contentHolder.progressLoaderInt = setInterval(contentHolder, "progressLoader", 500);
		// This event fired from within the loaded .swf
		contentHolder.progressLoadedEvent = function(){
			// clear the interval running the above check
			myTrace("progressLoadedEvent");
			clearInterval(this.progressLoaderInt);
			this.progressSetup();
		}
		// v6.4.2.4 Move this to after the functions are defined
		_global.myTrace("loading progress.swf to " + myProgress);
		myProgress.loadMovie(contentHolder.pPlayerMC); // + cacheVersion);
	} else {
		myTrace("old progress reporting");
	// v6.5 The old progress list
	//if (true) {
		// Remove the code that used to format and display the progress to a separate progress.swf
		// (this duplicates a lot of the below code for creating the PUW)
		_global.ORCHID.viewObj.displayProgressList(progressList);
		//myTrace("progress build=" + progressList);
	}
}
// A temporary function containing the old code.
View.prototype.displayProgressList = function(progressList) {
	
	// v6.3.5 Move to CEPopupwindow
	var initObj = { _x:180, _y:160, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	/*
	// CUP/GIU (change from FDraggable to APDraggable)
	// v6.3.3 Move the interface to buttons from progress movies and build the pane at design time
 	//if (!_global.ORCHID.root.buttonsHolder.progressScreen.progress_SP.isDragPane()) {
 	//	var myPane = _global.ORCHID.root.buttonsHolder.progressScreen.attachMovie("APDraggablePaneSymbol", "progress_SP", _global.ORCHID.root.progressHolder.progressNS.fixedDepth, initObj); 
 	//}

	var myPane = _global.ORCHID.root.buttonsHolder.ProgressScreen.progress_SP;
	myPane._x = initObj._x; 
	myPane._y = initObj._y;
	myPane.branding=initObj.branding; // you will have to do better than this
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		myPane.setContentBorder(false);
	}
	*/
	// v6.2 Put the course name in the progress title?
	var courseName = _global.ORCHID.course.scaffold.caption;
	//if (_global.ORCHID.user.name == "_orchid" || _global.ORCHID.user.name == "") {
	// v6.4.2.7 Not all CUP is anonymous
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	var progressTitle = findReplace(_global.ORCHID.literalModelObj.getLiteral("progressAnon", "labels"), "[x]", courseName);
	// v6.3.5 Use the anonymous name if it is a special name, no name or a Light version (which are always anonymous)
	//} else if (_global.ORCHID.user.name == "_orchid" || 
	if (_global.ORCHID.user.name == "_orchid" || 
			_global.ORCHID.user.name == "" ||
			_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("light") >= 0) {
		//myTrace("use progressAnon");
		var progressTitle = findReplace(_global.ORCHID.literalModelObj.getLiteral("progressAnon", "labels"), "[x]", courseName);
	} else {
		//myTrace("use progressTitle");
		var progressTitle = findReplace(findReplace(_global.ORCHID.literalModelObj.getLiteral("progressTitle", "labels"), "[y]", _global.ORCHID.user.name), "[x]", courseName);
	}
	// create the window
 	if (_global.ORCHID.root.buttonsHolder.MessageScreen.progress_SP == undefined) {
		var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "progress_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
	} else {
		// if the window already exists, simply make sure it is displayed.
		_global.ORCHID.root.buttonsHolder.MessageScreen.progress_SP._visible = true; 
		return;
	}
	myPane.setTitle(progressTitle);
	myPane.setContentBorder(false);
	myPane.setCloseButton(true);
	myPane.setResizeButton(true);
	myPane.setMinSize(500, 250);
	// v6.4.2.7 There is no need for the progress window to get so wide
	//myPane.setMaxSize(700, 550);
	// v6.4.2.7 base screen height on the fla
	var maxHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 100;
	myPane.setMaxSize(550, maxHeight);
	var contentHolder = myPane.getContent();

	//CUP/GIU cobble together the content
	//myPane.setScrolling(false);

	// make a header that doesn't scroll
	// v6.3.4 Started using screens from design time
	if (contentHolder.header_txt == undefined) {
	//contentHolder.createTextField("header_txt", _global.ORCHID.root.progressHolder.progressNS.depth++, 0,0,490,18);
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			var headerX = 5;
			var headerY = 2;
		} else {
			var headerX = 0;
			var headerY = 0;
		}
		contentHolder.createTextField("header_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, headerX,headerY,490,18);
	}
	var headerTF = new TextFormat();
	//_global.ORCHID.root.progressHolder.progressNS.headerTF = new TextFormat();
	headerTF.font = "Verdana";
	headerTF.size = 11;
	contentHolder.header_txt.html = true;

	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		headerTF.tabStops = [140,215,390];
		contentHolder.header_txt.htmlText = "Unit<tab>Score<tab>Date<tab>Time";
		//myTrace("add Separator " + myPane.getVersion());
		myPane.setSeparator(66);
	} else {
		// v6.2 Problem with the score and time headings - they really needs a right aligned tab.
		// Is it worth calculating the width and resetting the tab accordingly?
		// v6.3.5 Yes, I think it is
		// v6.5 Mac problem
		if (System.capabilities.os.toLowerCase().indexOf("mac")==0) {
			 var textExtentCorrector = 20; // What is this value? web seems to suggest twips, but it is not truly accurate
		} else {
			var textExtentCorrector = 1;
		}
		var scoreLabel = _global.ORCHID.literalModelObj.getLiteral("progressScore", "labels");
		//var scoreLabelWidth = headerTF.getTextExtent(scoreLabel).width;
		var scoreLabelWidth = headerTF.getTextExtent(scoreLabel).width/textExtentCorrector;
		var scoreLabelTab = 270 -  scoreLabelWidth;
		var timeLabel = _global.ORCHID.literalModelObj.getLiteral("progressTime", "labels");
		//var timeLabelWidth = headerTF.getTextExtent(timeLabel).width;
		var timeLabelWidth = headerTF.getTextExtent(timeLabel).width/textExtentCorrector;
		var timeLabelTab = 462 -  timeLabelWidth;
		headerTF.tabStops = [10,scoreLabelTab,286,timeLabelTab];
		contentHolder.header_txt.htmlText = "<tab>" + _global.ORCHID.literalModelObj.getLiteral("progressExercise", "labels") + 
								"<tab>" + scoreLabel +
								"<tab>" + _global.ORCHID.literalModelObj.getLiteral("progressDate", "labels") +
								"<tab>" + timeLabel;
		myPane.setSeparator(71);
	}
	contentHolder.header_txt.setTextFormat(headerTF);
	// v6.2 try using a simple text field with scroller to get better scrolling
	// v6.3.4 Started using screens from design time
	if (contentHolder.list_txt == undefined) {
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			var contentX = 5;
			var contentY = 21;
		} else {
			var contentX = 0;
			var contentY = 19;
		}
		//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, contentX,contentY,460,138);
		//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, contentX,contentY,460,200);
		// v6.4.2.7 base height on the fla
		var textHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 300;
		contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, contentX,contentY,460,textHeight);
	}
	with (contentHolder.list_txt) {
		//autoSize = "left";
		html = true;
		// v6.4.2.8 Can this help with getting test captions all displayed?
		//wordWrap = false;
		wordWrap = true;
		multiline = true;
		autosize=false;
		border=false;
	}
	var myScroll = contentHolder.attachMovie("FScrollBarSymbol", "progress_sb", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	myScroll.setScrollTarget(contentHolder.list_txt);

//	} else {
/*		contentHolder.createTextField("list_txt", _root.progressHolder.progressNS.depth++, 0,25,400,200);
		with (contentHolder.list_txt) {
			autoSize = true;
			//trace("font=" + _global.ORCHID.BasicText.font);
			html = true;
			wordWrap = false;
			multiline = true;
			//setNewTextFormat(_global.ORCHID.BasicText);
			// EGU uses this in the pane title
			//var userName = (_global.ORCHID.user.name == "_orchid" || _global.ORCHID.user.name == "")? "you": _global.ORCHID.user.name;
			//htmlText = findReplace(_global.ORCHID.literalModelObj.getLiteral("progressFor", "labels"), "[x]", userName) + newline;
			//htmlText = "Progress for " + ((_global.ORCHID.user.name == "_orchid")? "you": _global.ORCHID.user.name) + newline;
			//border = true;
		}
	}
*/
	//trace("created contentHolder=" + contentHolder.list_txt);
	var detailTF = new TextFormat();
	detailTF.font = "Verdana";
	detailTF.size = 11;
	// CUP/GIU - use another tab as one more level
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// v6.2 and yet another to show the exercise duration
		detailTF.tabStops = [30,140,215,400];
	} else {
		detailTF.tabStops = [10,20,246,286,416];
	}
	// v6.2 Since you do some formatting in course.as, why not do it all there?
	// It will save all these loads of pointless findReplaces.
	/*
	// the recordset from the progress db is stored (badly) on the timeline
	// use the (badly) stored progress string
	var findReplace = _global.ORCHID.root.objectHolder.findReplace;
	_root.progressHolder.progressNS.build = findReplace(progressList, "<h1>", "<u>");
	_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "</h1>", "</u>");
	// h2 = topic names
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "<h2>", "<b><font color='#00719C'>");
		_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "</h2>", "</font></b>");
	} else {
		_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "<h2>", "<u>");
		_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "</h2>", "</u>");
	}
	// EGU - have a line break before each new "unit" scores
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "<h3>", "<br>");
		_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "<h4>", "");
		_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "</h4>", "<br>");
	} else {
		_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "<h3>", "");
	}
	_root.progressHolder.progressNS.build = findReplace(_root.progressHolder.progressNS.build, "</h3>", "");
	*/
	contentHolder.list_txt.htmlText = progressList;
	//contentHolder.list_txt.text="Testing for EGU";
	contentHolder.list_txt.setTextFormat(detailTF);
	//myTrace("showing " + progressList);
	//myPane.refreshScrollContent(); // was attached to _root
	// functions used by several of the following displays

	// set up actions for the pane buttons (if any)
	myPane.onClose = function() {
		//myTrace("try to close progressScreen");
		//_global.ORCHID.viewObj.clearScreen("ProgressScreen");
	}
	myPane.onPrint = function(pane) {
		//myTrace("try to print progress");
		if (_global.ORCHID.projector.FlashVersion.major < 7) {
			_global.ORCHID.viewObj.displayMsgBox("noPrint");
		} else {
			// v6.3.5 CEPopupwindow
			//var contentHolder = this._parent.getScrollContent();
			//myTrace("print=" + pane);
			var contentHolder = pane.getContent();
			//myTrace("progress print " + contentHolder.list_txt);
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				var thisHeader = "Completed exercises";
				// v6.4.2.7 Use literal for CUP as well
				//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
				//	var thisFooter = "Printed from Advanced Grammar in Use CD-ROM © Cambridge University Press 2005";
				//} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
				//	var thisFooter = "Printed from English Grammar in Use CD-ROM © Cambridge University Press 2004";
				//} else {
				//	var thisFooter = "Printed from Essential Grammar in Use CD-ROM © Cambridge University Press 2006";
				//}
				var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}];
				var thisFooter = substTags(_global.ORCHID.literalModelObj.getLiteral("printedFromAPO", "labels"), substList);
			} else {
				if (_global.ORCHID.user.name == "_orchid" || 
					_global.ORCHID.user.name == "" ||
					_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("light") >= 0) {
					var thisHeader = findReplace(_global.ORCHID.literalModelObj.getLiteral("progressAnon", "labels"), "[x]", _global.ORCHID.course.scaffold.caption);
				} else {
					var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}, 
								{tag:"[y]", text:_global.ORCHID.user.name}];
					var thisHeader = substTags(_global.ORCHID.literalModelObj.getLiteral("progressTitle", "labels"), substList);
				}				
				//var thisFooter = "Printed from " + _global.ORCHID.course.scaffold.caption;
				var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}];
				var thisFooter = substTags(_global.ORCHID.literalModelObj.getLiteral("printedFromAPO", "labels"), substList);
			}
			//v6.3.5 Print the headers as well
			// v6.5 I need to make the box much wider otherwise I get horrible line breaking. It starts at 460
			//myTrace("current width=" + contentHolder.list_txt._width);
			contentHolder.list_txt._width=contentHolder.list_txt._width*2;
			myTrace("new print width=" + contentHolder.list_txt._width);
			_global.ORCHID.root.printingHolder.printForMe(contentHolder.list_txt, thisHeader, thisFooter);	
			//_global.ORCHID.root.printingHolder.printForMe(contentHolder, thisHeader, thisFooter);	
		}
	}
	// set up what to do on resizing
	myPane.onResize = function(dims) {
		// v6.3.5 Change for CEPopupWindow
		//if (!justStarting) {
			//trace("resize pane to " + w + ", " + h);
		//	var contentHolder = this.getScrollContent();
		var contentHolder = this.getContent();
		// v6.4.2.7 CUP merge
		//contentHolder.list_txt._width = dims.width-20; // for scroll bar
		//contentHolder.list_txt._height = dims.height-24; // for header
		contentHolder.list_txt._width = dims.width-20-(1.5*contentHolder.list_txt._x); // 20 for the scroll bar + left and right margin
		contentHolder.list_txt._height = dims.height-(contentHolder.list_txt._y); // top and bottom margin 
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			// take off a bit more as the box has a big radius
			contentHolder.list_txt._width-=5;
			contentHolder.list_txt._height-=5;
		} else {
			contentHolder.list_txt._height-=5;
		}
		//trace("resize " +contentHolder +" to width=" + w);
		contentHolder.progress_sb.setSize(contentHolder.list_txt._height);
		contentHolder.progress_sb._x = contentHolder.list_txt._width + contentHolder.list_txt._x;
		contentHolder.progress_sb._y = contentHolder.list_txt._y;
			//clt._width = w;
		//}
	}
	myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myPane.onPrint, noClose:true}]);
	myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myPane.onClose},
				{key:["P".charCodeAt(0)], setReleaseAction:myPane.onPrint}]);
	myPane.setCloseHandler(myPane.onClose);
	myPane.setResizeHandler(myPane.onResize);
	//myPane.setPaneMaximumSize(500, 550);
	//prime the sizing
	myPane.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
	// and get the scroll bar right by using resize routine
	myPane.onResize(myPane.getContentSize());
	myPane.setEnabled(true);
}

// View.prototype.cmdHelp = function(component) {
View.prototype.cmdHelp = function(anchor) {
	myTrace("cmdHelp with anchor=");
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	myTrace("help: commandLine=" + _global.ORCHID.commandLine.help); 
	
	// v6.3.5 Help might have been preset from location.ini (or commandLine)
	if (_global.ORCHID.commandLine.help != undefined) {
		// this variable MIGHT include a javascript function name used to open the windows
		// v6.4.1 The split character might be # or + either way it should be after the .extenstion
		// First check if there is a + after the . If not, assume #. Doesn't matter if not there.
		// Actually, it turns out that LoadVars uses + as the escape character for a space, so we
		// cannot use it here for this purpose. Switch to # in the location.ini or command parameters
		var extChar = _global.ORCHID.commandLine.help.lastIndexOf(".");
		if (_global.ORCHID.commandLine.help.indexOf("+", extChar) > 0 ) {
			var splitChar = "+";
		} else if (_global.ORCHID.commandLine.help.indexOf("#", extChar) > 0 ) {
			var splitChar = "#";
		} else {
			// Use a character that cannot be there as not allowed
			var splitChar = null;
		}
		var helpOptions = _global.ORCHID.commandLine.help.split(splitChar);
		if (helpOptions.length > 1) {
			var helpDoc = helpOptions.slice(0,helpOptions.length-1).join(splitChar);
			var helpJSFunction = helpOptions[helpOptions.length-1];
		} else {
			var helpDoc = helpOptions[0];
			var helpJSFunction = undefined;
		}
		
		// v6.5.4.4 Check for any relative paths if using projector
		if (_global.ORCHID.projector.name == "MDM") {
			// v6.5.4.4 In the projector, you can't use javascript functions, and they crash IE. So force this to be dropped
			helpJSFunction = undefined;
			
			// v6.5.4.4 Force any / to change to \ for projectors
			helpDoc = helpDoc.split("/").join("\\");
			
			if ((helpDoc.indexOf("\\\\") == 0) || (helpDoc.indexOf(":\\") == 1)) {
				//helpDoc = _global.ORCHID.functions.addSlash(helpDoc);
			} else {
				// v6.4.2.7 For a CD, you don't have userDataPath!
				// v6.5.4.4 Since you are working with a .exe, root is always the same as userDataPath.
				// If not, you would need to change all the stuff in controlFrame2 which assumes .. is relative to root
				//if (_global.ORCHID.commandLine.userDataPath == undefined) {
					var helpRoot = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.root); 
				//} else {
				//	helpRoot = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.userDataPath); 
				//}
				// v6.5.4.4 Also, if you find a .. in the path, get rid of it due to loading problems on some computers
				if (helpDoc.indexOf("..")>=0) {
					myTrace("remove .. from help path");
					// break the path into folders
					var rootFolders = helpRoot.split("\\");
					// since we know paths.root ends in a slash, the array starts one too long
					rootFolders.pop(); 
					// do the same for the content folder
					var helpFolders = helpDoc.split("\\");
					// if the first folder is a parent navigator, drop it and the matching root one
					while (helpFolders[0] == ".." && helpFolders.length>1 && rootFolders.length>1) {
						//trace(contentFolders[0]);
						//myTrace("drop " + rootFolders[rootFolders.length-1]);
						rootFolders.pop();
						helpFolders.shift();
					}
					helpDoc = _global.ORCHID.functions.addSlash(rootFolders.join("\\")) + helpFolders.join("\\");
				} else {
					helpDoc = helpRoot + helpDoc;
				}
			}
		} else {
			// v6.4.2.4 If you are running from a CD, you need the full path. So if you have any relative path, add the root to it
			//myTrace("helpDoc is absolute? indexOf \\=" + helpDoc.indexOf("/"));
			// v6.5.4.4 Old code, so you will not be here if projector, but should still do this stuff in case CD and browser
			if ((helpDoc.indexOf("http:")>=0) || (helpDoc.indexOf("file:")>=0) || (helpDoc.indexOf("\\")==0) || (helpDoc.indexOf("/")==0)) {
			} else {
				// v6.4.2.6 Yes, but the path will be relative to the userDataPath, not to control.swf
				//helpDoc = _global.ORCHID.paths.root + helpDoc;
				// v6.4.2.7 For a CD, you don't have userDataPath!
				if (_global.ORCHID.commandLine.userDataPath == undefined) {
					helpDoc = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.root) + helpDoc; 
				} else {
					helpDoc = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.userDataPath) + helpDoc; 
				}
			}
		}
	} else {
		// If it hasn't been, assume it is default.html in the Help subfolder of the root
		// v6.4.2.4 Use the proper slash function
		//if (_global.ORCHID.online) {
		//	var folderSlash = "/";
		//} else {
		//	var folderSlash = "\\";
		//}
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			//getURL(_global.ORCHID.paths.root + "Help/EGUindex.htm", "_blank");
			//_global.ORCHID.FSPvar = "Help\EGUHelpFile.chm";
			//_root.FSPVar = _global.ORCHID.paths.root + "Help\\EGUHelp.hlp";
			//fscommand("flashstudio.exec", "\"Help\\EGUHelp.hlp\"");
			//myTrace("call for help from " + _root.FSPVar);
			//fscommand("flashstudio.exec", "_root.FSPVar");
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
				var helpFile = "AGU_help.htm";
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
				var helpFile = "EGU_help.htm";
			} else {
				var helpFile = "ESG.htm";
			}
		} else {
			var helpFile = "default.html";
		}
		var helpDoc = _global.ORCHID.paths.root + _global.ORCHID.functions.addSlash("Help") + helpFile;
	}
	// v6.5.5.5 Let special cases pass an anchor to the help
	if (anchor.indexOf("#")==0) {
		helpDoc+=anchor;
	}
	// v6.3.5 There are two techniques to open help - one is in a popup, one is in a new window
	// You can only do the first if the javascript is present in the calling page. For now, to use
	// this you MUST pass the help file as a location.ini variable, see above
	// v6.5.5.5 Increasingly people are complaining that their browser blocks the popup working, often with no warning whatsoever.
	// So it might be best to simpy ignore this function altogether. However, you get blocked with getURL or javascript:openWindow. No difference
	// So leave it.
	if (helpJSFunction == undefined) {
		myTrace("getURL:" + helpDoc);
		getURL(helpDoc, "_blank");
	} else {
		myTrace("javascript:" + helpJSFunction + "('" + helpDoc + "')");
		getURL("javascript:" + helpJSFunction + "('" + helpDoc + "', 800, 585 ,0 ,0 ,0 ,0 ,1 ,1 ,20 ,20 )");
	}
}
//View.prototype.cmdScratchPad = function(component) {
View.prototype.cmdScratchPad = function() {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	//myTrace("request from button " + component.getLabel());
	// 6.0.2.0 remove connection
	//_root.progressHolder.myConnection.displayScratchPad();
	//_root.progressHolder.progressNS.displayScratchPad();
	
	// 6.0.6.0 If the scratchPad attr in user is NULL, then we haven't read from the database yet
	if (_global.ORCHID.user.scratchPad == null) {
		_global.ORCHID.user.getScratchPad(this);
		// the call back from the above call will be to this.displayScratchPad();
	} else {
		// otherwise just display what we have (it might be nothing of course)
		//myTrace("scratch pad already read");
		_global.ORCHID.viewObj.displayScratchPad();
	}
}
// 6.0.6.0 Turn the actual display call into a separate function that is only called
// when you know that the saved scratch pad has been read
View.prototype.displayScratchPad = function() {

	// CUP/GIU (change from FDraggable to APDraggable
	// v6.3.5 And move to CEPopupWindow
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		var initObj = { _x:100, _y:140, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	} else {
		var initObj = { _x:180, _y:160, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	}
	//trace("scratch pad pane at depth=" + _root.progressHolder.progressNS.fixedDepth);
	// v6.3.3 Move the interface to buttons from progress movies
	//if (!_root.progressHolder.scratchPad_SP.isDragPane()) {
	//	var myPane = _root.progressHolder.attachMovie("APDraggablePaneSymbol", "scratchPad_SP", _root.progressHolder.progressNS.fixedDepth, initObj); 
	//}
	/*
 	if (!_global.ORCHID.root.buttonsHolder.MessageScreen.scratchPad_SP.isDragPane()) {
 		var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APDraggablePaneSymbol", "scratchPad_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
 	}
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		myPane.setContentBorder(false);
	} else {
	}
	myPane.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("scratchPad", "labels"));
	myPane.setScrollContent("blob");
	var contentHolder = myPane.getScrollContent();
	myPane.setScrolling(false);
	myPane.setPaneMinimumSize(330, 190);
	*/
	// create the window
 	if (_global.ORCHID.root.buttonsHolder.MessageScreen.scratchPad_SP == undefined) {
		var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "scratchPad_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
	} else {
		// if the window already exists, simply make sure it is displayed.
		_global.ORCHID.root.buttonsHolder.MessageScreen.scratchPad_SP._visible = true; 
		return;
	}
	myPane.setTitle(_global.ORCHID.literalModelObj.getLiteral("scratchPad", "labels"));
	myPane.setContentBorder(false);
	myPane.setCloseButton(true);
	myPane.setResizeButton(true);
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		myPane.setMinSize(430, 253);
		var listWidth = 400; 
		var listHeight = 100;
	} else {
		myPane.setMinSize(330, 190);
		var listWidth = 400; 
		var listHeight = 300;
	}
	// v6.4.2.7 There is no need for the scratch pad window to get so wide
	//myPane.setMaxSize(700, 550);
	// v6.4.2.7 base screen height on the fla
	var maxHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 100;
	myPane.setMaxSize(550, maxHeight);
	var contentHolder = myPane.getContent();

	// v6.2 try using a simple text field with scroller to get better scratch pad typing usability
	// v6.3.3 Move the interface to buttons from progress movies
	//contentHolder.createTextField("list_txt", _root.progressHolder.progressNS.depth++, 0,0,373,138);
	//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 5,5,342,142);
	contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 5,5,listWidth,listHeight);
	with (contentHolder.list_txt) {
		//autoSize = "left";
		html = true;
		wordWrap = true;
		multiline = true;
		type = "input";
		autosize=false;
		border=false;
	}
	// v6.3.3 Move the interface to buttons from progress movies
	var myScroll = contentHolder.attachMovie("FScrollBarSymbol", "scratchPad_sb", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	myScroll.setScrollTarget(contentHolder.list_txt);

	// v6.3 Switch to html data in the scratch pad, NO
	if(_global.ORCHID.user.scratchPad != null) {
		contentHolder.list_txt.text = _global.ORCHID.user.scratchPad;
		//contentHolder.list_txt.setHtmlText(_global.ORCHID.user.scratchPad, _global.ORCHID.BasicText);
	}
	//myTrace("scratchPad : " + _global.ORCHID.user.scratchPad);
	var spTF = _global.ORCHID.BasicText;
	spTF.size = 11;
	contentHolder.list_txt.setTextFormat(spTF);
	contentHolder.list_txt.setNewTextFormat(spTF);
	Selection.setFocus(contentHolder.list_txt);
	Selection.setSelection(contentHolder.list_txt.length, contentHolder.list_txt.length);

	// set up actions for the pane buttons (if any)
	myPane.onEscape = function() {
		// this does nothing, not saving the scratch pad
	}
	myPane.onClose = function(pane) {
		// v6.3.5 CEPopupwindows change
		//myTrace("save your scratch pad (" + contentHolder.list_txt.text.substr(0,48) + "...)");
		var contentHolder = pane.getContent();
		var me = _global.ORCHID.user;
		// v6.3 Switch to html data in the scratch pad. NO
		//me.scratchPad = contentHolder.list_txt.htmlText;
		me.scratchPad = contentHolder.list_txt.text;
		me.onReturnCode = undefined;
		// 6.0.6.0 use a call to setScratchPad (allows for it to be held in a database)
		// me.writeOut();
		me.setScratchPad();
	}
	myPane.onPrint = function(pane) {
		if (_global.ORCHID.projector.FlashVersion.major < 7) {
			_global.ORCHID.viewObj.displayMsgBox("noPrint");
		} else {
			var contentHolder = pane.getContent();
			//trace("scratchpad print " + contentHolder.list_txt);
			// v6.4.2.7 use literal for EGU too
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				var thisHeader = "Your notes";
			//	var thisFooter = "Printed from English Grammar in Use CD-ROM";
			} else {
				var thisHeader = _global.ORCHID.literalModelObj.getLiteral("scratchPad", "labels");
			}
			var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}];
			var thisFooter = substTags(_global.ORCHID.literalModelObj.getLiteral("printedFrom", "labels"), substList);
			_global.ORCHID.root.printingHolder.printForMe(contentHolder.list_txt, thisHeader, thisFooter);
			// v6.2 Since the print button will not close, there is no need to do saving stuff here
			//print(contentHolder, "bmax");
			//myTrace("save your scratch pad (" + contentHolder.list_txt.text.substr(0,48) + "...)");
			//var me = _global.ORCHID.user;
			// //me.scratchPad = contentHolder.list_txt.htmlText;
			//me.scratchPad = contentHolder.list_txt.text;
			//me.onReturnCode = undefined;
			// // 6.0.6.0 use a call to setScratchPad (allows for it to be held in a database)
			// // me.writeOut();
			//me.setScratchPad();
		}
	}
	// set up what to do on resizing
	myPane.onResize = function(dims) {
		// dims is the full size of the white space for the content.
		//myTrace("onResize scratch pad, dims.width=" + dims.width + " height=" + dims.height);
		var contentHolder = this.getContent();
		contentHolder.list_txt._width = dims.width-20-(1.5*contentHolder.list_txt._x); // 20 for the scroll bar + left and right margin
		contentHolder.list_txt._height = dims.height-(2*contentHolder.list_txt._y); // top and bottom margin 
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			// take off a bit more as the box has a big radius
			contentHolder.list_txt._width-=5;
		}
		//trace("resize " +contentHolder +" to width=" + w);
		contentHolder.scratchPad_sb.setSize(contentHolder.list_txt._height);
		contentHolder.scratchPad_sb._x = contentHolder.list_txt._width + contentHolder.list_txt._x;
		contentHolder.scratchPad_sb._y = contentHolder.list_txt._y;
	}
	myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myPane.onPrint, noClose:true}]);
	myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myPane.onEscape}]);
	myPane.setCloseHandler(myPane.onClose);
	myPane.setResizeHandler(myPane.onResize);
	//prime the sizing
	myPane.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
	// and get the scroll bar right by using resize routine
	myPane.onResize(myPane.getContentSize());
	myPane.setEnabled(true);
}

// 6.3.5 Stats from teh countDown exercise
View.prototype.cmdCountDownStats = function() {

	// CUP/GIU (change from FDraggable to APDraggable
	// v6.3.5 And then to CEPopupWindow
	var initObj = { _x:180, _y:160, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
 	//if (!_global.ORCHID.root.buttonsHolder.MessageScreen.stats_SP.isDragPane()) {
 	//	var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APDraggablePaneSymbol", "stats_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
 	//}
	/*
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		myPane.setContentBorder(false);
	} else {
	}
	myPane.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("stats", "labels"));
	myPane.setScrollContent("blob");
	var contentHolder = myPane.getScrollContent();
	myPane.setScrolling(false);
	myPane.setPaneMinimumSize(330, 150);
	*/
 	if (_global.ORCHID.root.buttonsHolder.MessageScreen.stats_SP == undefined) {
		var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "stats_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
	} else {
		// if the window already exists, simply make sure it is displayed.
		_global.ORCHID.root.buttonsHolder.MessageScreen.stats_SP._visible = true; 
		return;
	}
	myPane.setTitle(_global.ORCHID.literalModelObj.getLiteral("stats", "labels"));
	myPane.setContentBorder(false);
	myPane.setCloseButton(true);
	myPane.setResizeButton(true);
	myPane.setMinSize(330, 150);
	// v6.4.2.7 There is no need for the window to get so wide
	//myPane.setMaxSize(700, 550);
	// v6.4.2.7 base screen height on the fla
	var maxHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 100;
	myPane.setMaxSize(550, maxHeight);
	var contentHolder = myPane.getContent();

	// make a header that doesn't scroll
	// v6.3.4 Started using screens from design time
	if (contentHolder.header_txt == undefined) {
		contentHolder.createTextField("header_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,0,490,18);
	}
	var headerTF = new TextFormat();
	//_root.progressHolder.progressNS.headerTF = new TextFormat();
	headerTF.font = "Verdana";
	headerTF.size = 11;
	contentHolder.header_txt.html = true;

	// v6.2 Problem with the time heading - it really needs a right aligned tab.
	// Is it worth calculating the width and resetting the tab accordingly?
	headerTF.tabStops = [10,238];
	contentHolder.header_txt.htmlText = "<tab>" + _global.ORCHID.literalModelObj.getLiteral("word", "labels") + 
							"<tab>" + _global.ORCHID.literalModelObj.getLiteral("correct", "labels");
	//myPane.hasSeparator(71);
	
	contentHolder.header_txt.setTextFormat(headerTF);
	// v6.2 try using a simple text field with scroller to get better scrolling
	// v6.3.4 Started using screens from design time
	if (contentHolder.list_txt == undefined) {
		contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,19,460,138);
	}
	with (contentHolder.list_txt) {
		//autoSize = "left";
		html = true;
		wordWrap = false;
		multiline = true;
		autosize=false;
		border=false;
	}
	// v6.3.3 Move the interface to buttons from progress movies
	var myScroll = contentHolder.attachMovie("FScrollBarSymbol", "stats_sb", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	myScroll.setScrollTarget(contentHolder.list_txt);

	// Put the data into the list
	var build="";
	var wordList = _global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.statsList;
	for (var i in wordList) {
		if (wordList[i].guessed) {
			build += "<tab>" + wordList[i].word + "<tab>" + "x";
		} else {
			build += "<tab>" + wordList[i].word
		}
		build += "<br>";
	}
	contentHolder.list_txt.htmlText = build;
	contentHolder.list_txt.setTextFormat(headerTF);

	// set up actions for the pane buttons (if any)
	myPane.onEscape = function() {
		// this does nothing, not saving the scratch pad
	}
	myPane.onClose = function() {
	}
	myPane.onPrint = function() {
		if (_global.ORCHID.projector.FlashVersion.major < 7) {
			_global.ORCHID.viewObj.displayMsgBox("noPrint");
		} else {
			//var contentHolder = this._parent.getScrollContent();
			var contentHolder = this.getContent();
			//trace("scratchpad print " + contentHolder.list_txt);
			// v6.4.2.7 use literal for EGU too
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				var thisHeader = "Your notes";
				//var thisFooter = "Printed from English Grammar in Use CD-ROM";
			} else {
				var thisHeader = _global.ORCHID.literalModelObj.getLiteral("stats", "labels");
			}
			var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}];
			var thisFooter = substTags(_global.ORCHID.literalModelObj.getLiteral("printedFrom", "labels"), substList);
			_global.ORCHID.root.printingHolder.printForMe(contentHolder.list_txt, thisHeader, thisFooter);
			// v6.2 Since the print button will not close, there is no need to do saving stuff here
			//print(contentHolder, "bmax");
			//myTrace("save your scratch pad (" + contentHolder.list_txt.text.substr(0,48) + "...)");
			//var me = _global.ORCHID.user;
			// //me.scratchPad = contentHolder.list_txt.htmlText;
			//me.scratchPad = contentHolder.list_txt.text;
			//me.onReturnCode = undefined;
			// // 6.0.6.0 use a call to setScratchPad (allows for it to be held in a database)
			// // me.writeOut();
			//me.setScratchPad();
		}
	}
	// set up what to do on resizing
	//myPane.onResize = function(w, h, justStarting) {
	myPane.onResize = function(dims) {
		//myTrace("onResize for " + this + " dims.width=" + dims.width);
		var contentHolder = this.getContent();
		contentHolder.list_txt._width = dims.width-20; // 20 for the scroll bar
		contentHolder.list_txt._height = dims.height-24; // for the non-scroll header at the top of content
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			// take off a bit more as the box has a big radius
			contentHolder.list_txt._width-=5;
		}
		//trace("resize " +contentHolder +" to width=" + w);
		contentHolder.stats_sb.setSize(contentHolder.list_txt._height);
		contentHolder.stats_sb._x = contentHolder.list_txt._width + contentHolder.list_txt._x;
		contentHolder.stats_sb._y = contentHolder.list_txt._y;
	}
	myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myPane.onPrint, noClose:true}]);
	myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myPane.onEscape}]);
	myPane.setCloseHandler(myPane.onClose);
	myPane.setResizeHandler(myPane.onResize);
	//prime the sizing
	myPane.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
	// and get the scroll bar right by using resize routine
	myPane.onResize(myPane.getContentSize());
	myPane.setEnabled(true);
}
// EGU - go to the dictionaries website
// No - not any more. Just explain how the glossary function works.
// EGU 1.1 - This now contains more than can fit in the msgBox, so use a full progress box
View.prototype.cmdDictionaries = function() {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	//myTrace("cmdDictionaries");
	// v6.3.6 debugging handle
	/*
	if (Key.isDown(Key.CONTROL)) {
		for (var i in _global.ORCHID.root.buttonsHolder) {
			if ((typeof _global.ORCHID.root.buttonsHolder[i]) == "movieclip") {
				myTrace(_global.ORCHID.root.buttonsHolder[i] + ".depth=" + _global.ORCHID.root.buttonsHolder[i].getDepth())
			}
		}
		return;
	}
	*/	
	//myTrace("explain dictionaries/hint/glossary");
	//_global.ORCHID.viewObj.displayMsgBox("dictionary");
	//myTrace("use text=" + _global.ORCHID.literalModelObj.getLiteral("countdownHint", "messages"));
	// v6.4.2.7 CUP merge
	//var substList = [{tag:"[newline]", text:newline}];
	// v6.4.3 Use the common method
	_global.ORCHID.viewObj.displayMsgBox("hintText");
	/*
	var substList = [{tag:"[newline]", text:newline}];
	var glossaryDetail = substTags(_global.ORCHID.literalModelObj.getLiteral("ctrl-click", "messages"), substList);
	//myTrace("gD=" + glossaryDetail);
	
	// CUP/GIU (change from FDraggable to APDraggable
	// and onto CEPopup
	var initObj = { _x:180, _y:160, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	
	//if (!_global.ORCHID.root.buttonsHolder.MessageScreen.glossary_SP.isDragPane()) {
	//	//var myPane = _root.progressHolder.attachMovie("APDraggablePaneSymbol", "glossary_SP", _root.progressHolder.progressNS.fixedDepth, initObj); 
 	//	var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APDraggablePaneSymbol", "glossary_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
	//}
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	myPane.setContentBorder(false);
	//} else {
	//}
	//myPane.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("glossary", "labels"));
	//myPane.setScrollContent("blob");
	//var contentHolder = myPane.getScrollContent();
	
 	if (_global.ORCHID.root.buttonsHolder.MessageScreen.glossary_SP == undefined) {
		var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "glossary_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
	} else {
		// if the window already exists, simply make sure it is displayed.
		_global.ORCHID.root.buttonsHolder.MessageScreen.glossary_SP._visible = true; 
		return;
	}
	myPane.setTitle(_global.ORCHID.literalModelObj.getLiteral("glossary", "labels"));
	myPane.setContentBorder(false);
	myPane.setCloseButton(true);
	myPane.setResizeButton(false);
	//myPane.setMinSize(390, 250);
	//myPane.setMaxSize(700, 550);
	var contentHolder = myPane.getContent();

	// v6.3 Make sure that the depth counter starts more than the scroll content and the buttons
	//_root.progressHolder.progressNS.depth = contentHolder.getDepth()+10;
	var thisDepth = contentHolder.getDepth()+10;
	//myTrace("contentHolder.depth=" + contentHolder.getDepth() + " progressNS.depth=" + _root.progressHolder.progressNS.depth);
	//myPane.setScrolling(false);
	//myPane.setPaneMinimumSize(450, 200);
	//myPane.setResizable(false);

	// v6.2 try using a simple text field with scroller to get better scratch pad typing usability
	// contentHolder.createTextField("list_txt", _root.progressHolder.progressNS.depth++, 0,0,373,138);
	// EGU 1.1 - include dictionary branding, so reduce width of text block
	//v6.4.1 Give a little margin please (0 to 5)
	// v6.4.2.7 CUP merge rearrange
	//contentHolder.createTextField("list_txt", thisDepth++, 5,5,350,125);	
	contentHolder.createTextField("list_txt", thisDepth++, 5,5,450,100);	
	contentHolder.list_txt.html = false;
	contentHolder.list_txt.wordWrap = true;
	contentHolder.list_txt.multiline = true;
	// v6.4.2.7 CUP merge rearrange
	contentHolder.list_txt.autosize=true;
	//contentHolder.list_txt.autosize=false;
	contentHolder.list_txt.border=false;
	contentHolder.list_txt.selectable=false;
	var glossTF = new TextFormat();
	glossTF.font = "Verdana";
	glossTF.size = 12;
	// v6.4.2.7 CUP merge rearrange
	//glossTF.rightMargin = 6;
	glossTF.rightMargin = 100;
	contentHolder.list_txt.setNewTextFormat(glossTF);
	contentHolder.list_txt.text = glossaryDetail;

	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// EGU 1.1 Show dictionary logos for cross-marketing
		var imageHolder1 = myPane.createEmptyMovieClip("imageHolder1",  thisDepth++);
		imageHolder1._x = 385; 
		imageHolder1._y = 60;
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {			
			// v6.4.2.7 Changed paths
			//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + "CLDcover.jpg");
			//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CLDcover.jpg");
			var thisImageFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CLDcover.jpg";
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
			//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + "CALDcover.jpg");
			var thisImageFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CALDcover.jpg";
		}
		//myTrace("show branding " + thisImageFile);
		var myBranding1 = imageHolder1.loadMovie(thisImageFile);
	}
	
	// set up actions for the pane buttons (if any)
	myPane.onClose = function() {
		// now you can fire the glossary again
		// v6.3.6 Merge glossary into main
		_global.ORCHID.root.mainHolder.glossaryNS.open = false;
	}
	myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("ok", "buttons"), setReleaseAction:myPane.onClose, noClose:false}]);
	myPane.setCloseHandler(myPane.onClose);
	//myTrace("how to hide the resize handle?");
	//prime the sizing
	myPane.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
	// and get the scroll bar right by using resize routine
	myPane.onResize(myPane.getContentSize());
	myPane.setEnabled(true);
	*/
}
// v6.2 Look up a word in the glossary (once it has been loaded)
View.prototype.cmdGlossary = function(word) {

	// if you get more than one call at once (say from two TWFs on top of each other)
	// ignore them
	// v6.3.6 Merge glossary into main
	if (_global.ORCHID.root.mainHolder.glossaryNS.open) {
		//trace("already running, so ignore " + word);
		return;
	}
	// v6.3.6 Merge glossary into main
	_global.ORCHID.root.mainHolder.glossaryNS.open = true;
	var letter = word.substr(0,1).toLowerCase();
	
	// a callback so that you can do things once the glossary data is loaded
	onGlossaryLoaded = function(letter) {
		if (letter == false) {
			// this means the glossary XML could not be loaded
			// v6.3.6 Merge glossary into main
			_global.ORCHID.root.mainHolder.glossaryNS.open = false;
		} else {
			// and stop this happening again
			// v6.3.6 Merge glossary into main
			_global.ORCHID.root.mainHolder.glossaryNS.glossaryStore[letter].dataLoaded = true;
			//myTrace("glossary now loaded for " + letter);
			// v6.3.6 Merge glossary into main
			// v6.4.2.7 CUP merge
			//_global.ORCHID.viewObj.glossaryLookUp(_global.ORCHID.root.mainHolder.word, letter);
			_global.ORCHID.viewObj.glossaryLookUp(_global.ORCHID.root.mainHolder.glossaryNS.word, letter);
		}
	}
	// have we already loaded the glossary data?
	// v6.3.6 Merge glossary into main
	if (_global.ORCHID.root.mainHolder.glossaryNS.glossaryStore[letter].dataLoaded) {
		myTrace("immediate look up for index " + letter);
		this.glossaryLookUp(word, letter);
	//} else if (_global.ORCHID.root.glossaryHolder.glossaryNS.loading) {
	//	// just be patient!
	//	trace("be patient");
	//	return;
	} else {
		// save the search word
		// v6.3.6 Merge glossary into main and add ns
		//_global.ORCHID.root.glossaryHolder.word = word;
		_global.ORCHID.root.mainHolder.glossaryNS.word = word;
		// and stop this happening again
		//_global.ORCHID.root.glossaryHolder.glossaryNS.loading = true;
		var fileName = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.subCourse) + "glossary-" + letter + ".xml";
		//myTrace("load glossary data for the first time from file " + filename);
		//_global.ORCHID.root.glossaryHolder.loadGlossary(letter, _global.ORCHID.paths.root + _global.ORCHID.paths.subCourse + fileName, onGlossaryLoaded);
		// v6.3.6 Merge glossary into main
		// v6.4.2.7 CUP merge, Namespace correctsion
		//_global.ORCHID.root.mainHolder.loadGlossary(letter, _global.ORCHID.paths.subCourse + fileName, onGlossaryLoaded);
		_global.ORCHID.root.mainHolder.glossaryNS.loadGlossary(letter, fileName, onGlossaryLoaded);
	}
}

// called from the above harness type function
View.prototype.glossaryLookUp = function(word, letter) {
	// v6.3.5 Allow glossary with anything - just look up online
	// v6.5.4.3 Get rid of any html characters - you escape it later
	// IN fact, it is the CUP website that doesn't handle apostrophe well.
	//word = findReplace(word, "&apos;", "'");
	myTrace("looking up word " + word + " in index=" + letter);
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP") >= 0) {		
		// first of all, look up the word in the glossary XML
		//var glossaryDetail = "<font size='13' color='#0000FF'><b>" +word+"</b></font><br> is defined as ..." +  
		//	"<br><br>Click to search for <b><a href='http://dictionary.cambridge.org/results.asp?searchword=" + escape(word) + "'>" + word+"</a></b> in the online Cambridge dictionaries.";
		//var glossaryDetail = _global.ORCHID.root.glossaryHolder.lookUp(word, letter) + 
		//	"<br><a href='http://dictionary.cambridge.org/results.asp?searchword=" + escape(word) + "&dict=L'>Click to search for <b><u>" + word+"</u></b> in Cambridge Dictionaries Online.</a>";
		// v6.3.6 Merge glossary into main and add ns
		var glossaryDetail = _global.ORCHID.root.mainHolder.glossaryNS.lookUp(word, letter);
		//myTrace("detail=" + glossaryDetail);
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
			var cupDictionary = "L";
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
			var cupDictionary = "CALD";
		}
		var glossaryFooter = "<a href='http://dictionary.cambridge.org/results.asp?searchword=" + escape(word) + "&dict=" + cupDictionary+ "' target='_blank'>Click to search for <b><u>" + word+"</u></b> in<br>Cambridge Dictionaries Online.</a>";
	
		// CUP/GIU (change from FDraggable to APDraggable
		var initObj = { _x:180, _y:160, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
		// v6.4.2.7 CUP merge
		//if (!_global.ORCHID.root.buttonsHolder.MessageScreen.glossary_SP.isDragPane()) {
			//var myPane = _global.ORCHID.root.progressHolder.attachMovie("APDraggablePaneSymbol", "glossary_SP", _global.ORCHID.root.progressHolder.progressNS.fixedDepth, initObj); 
			//var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APDraggablePaneSymbol", "glossary_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
		//}
		if (_global.ORCHID.root.buttonsHolder.MessageScreen.glossary_SP == undefined) {
			var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "glossary_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
		}
		// CUP merge
		/*
		myPane.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("dictionary", "labels"));
		myPane.setScrollContent("blob");
		var contentHolder = myPane.getScrollContent();
		// v6.3 Make sure that the depth counter starts more than the scroll content and the buttons
		var thisDepth = contentHolder.getDepth()+10;
		//myTrace("contentHolder.depth=" + contentHolder.getDepth() + " progressNS.depth=" + _global.ORCHID.root.progressHolder.progressNS.depth);
		myPane.setScrolling(false);
		myPane.setPaneMinimumSize(390, 250);
		*/
		myPane.setTitle(_global.ORCHID.literalModelObj.getLiteral("dictionary", "labels"));
		myPane.setContentBorder(false);
		myPane.setCloseButton(true);
		myPane.setResizeButton(true);
		myPane.setMinSize(450, 250);
		// v6.4.2.7 There is no need for the window to get so wide
		//myPane.setMaxSize(700, 550);
		// v6.4.2.7 base screen height on the fla
		var maxHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 100;
		myPane.setMaxSize(550, maxHeight);
		var contentHolder = myPane.getContent();

		// v6.4.2.7 CUP merge
		// v6.2 try using a simple text field with scroller to get better scratch pad typing usability
		// contentHolder.createTextField("list_txt", _root.progressHolder.progressNS.depth++, 0,0,373,138);
		// EGU 1.1 - include dictionary branding, so reduce width of text block
		//contentHolder.createTextField("list_txt", thisDepth++, 0,0,350,100);
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			var headerX = 6;
			var headerY = 6;
		} else {
			var headerX = 0;
			var headerY = 0;
		}
		contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, headerX,headerY,450,120);
		with (contentHolder.list_txt) {
			//autoSize = "left";
			html = true;
			wordWrap = true;
			multiline = true;
			autosize=false;
			border=false;
		}
		// EGU 1.1 - have a separate text field for the online click bit
		//myPane.createTextField("online_txt", thisDepth++, 0,0,250,32);
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			var contentX = 16;
			var contentY = 100;
		} else {
			var contentX = 0;
			var contentY = 19;
		}
		myPane.createTextField("online_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, contentX,contentY,250,32);
		with (myPane.online_txt) {
			//autoSize = "left";
			html = true;
			wordWrap = true;
			multiline = true;
			autosize=false;
			border=false;
		}
		var myScroll = contentHolder.attachMovie("FScrollBarSymbol", "glossary_sb", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
		myScroll.setScrollTarget(contentHolder.list_txt);
	
		var glossTF = new TextFormat();
		glossTF.font = "Verdana";
		glossTF.size = 12;
		contentHolder.list_txt.setHtmlText(glossaryDetail, glossTF);
		// EGU 1.1
		// v6.4.2.7
		myPane.online_txt.setHtmlText(glossaryFooter, glossTF);
		//myPane.online_txt._x = 20;
		//myPane.online_txt._y = 209;
	
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			// EGU 1.1 Show dictionary logos for cross-marketing
			var imageHolder1 = myPane.createEmptyMovieClip("imageHolder1",  _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
			imageHolder1._x = 385; 
			imageHolder1._y = 56;
			// CUP merge
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
				var thisImageFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CLDcover.jpg";
				//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + "CLDcover.jpg");
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
				var thisImageFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CALDcover.jpg";
				//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + "CALDcover.jpg");
			} else {
				var thisImageFile = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CEEDcover.jpg";
				//var myBranding1 = imageHolder1.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + "CEEDcover.jpg");
			}
			var myBranding1 = imageHolder1.loadMovie(thisImageFile);
	
			var imageHolder2 = myPane.createEmptyMovieClip("imageHolder2",  _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
			imageHolder2._x = 330; 
			//imageHolder2._y = 165;
			var myBranding2 = imageHolder2.loadMovie(_global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CambridgeDictionariesOnline.jpg");
			var imageHolder3 = myPane.createEmptyMovieClip("imageHolder3",  _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
			//imageHolder3._x = 21; 
			//imageHolder3._y = 16;
			imageHolder3._x = 17; 
			imageHolder3._y = 14;
			var myBranding3 = imageHolder3.loadMovie(_global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies) + "CLDsquare.swf");
		}
		
		// set up actions for the pane buttons (if any)
		myPane.onClose = function(pane) {
			// now you can fire the glossary again
			// v6.3.6 Merge glossary into main
			_global.ORCHID.root.mainHolder.glossaryNS.open = false;
		}
		myPane.onPrint = function(pane) {
			//myTrace("glossary print");
			// v6.2 Is your Flash player good enough to print?
			if (_global.ORCHID.projector.FlashVersion.major < 7) {
				_global.ORCHID.viewObj.displayMsgBox("noPrint");
			} else {
				// hmmm, "this" is the button rather than the pane - I thought it was supposed to not be?!
				// and it isn't in the onResize! Not fair.
				//var contentHolder = this._parent.getScrollContent();
				var contentHolder = pane.getContent();
				//myTrace("glossary print " + contentHolder.list_txt);
				//_root.myTrace("from old code, please print!! " + contentHolder + " instanceOf=" + typeof contentHolder);
				//myTrace("glossary print: brand=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
					var thisHeader = "Glossary";
					if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
						var thisFooter = "Printed from Advanced Grammar in Use © Cambridge University Press 2005";
					} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
						var thisFooter = "Printed from English Grammar in Use © Cambridge University Press 2004";
					} else {
						var thisFooter = "Printed from Essential Grammar in Use © Cambridge University Press 2005";
					}
				} else {
					var thisHeader = "Glossary";
					var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}];
					var thisFooter = substTags(_global.ORCHID.literalModelObj.getLiteral("printedFrom", "labels"), substList);
				}
				//myTrace("glossary should print header=" + contentHolder.list_txt);
				_global.ORCHID.root.printingHolder.printForMe(contentHolder.list_txt, thisHeader, thisFooter);
				//print(contentHolder, "bmax");
			}
		}
		// set up what to do on resizing
		//myPane.onResize = function(w, h, justStarting) {
		myPane.onResize = function(dims, justStarting) {
			var w = dims.width;
			var h = dims.height;
			// the images do not move with the dialog, so invisible them until resize is finished
			if (justStarting) {
				this.imageHolder1._visible = false;
				this.imageHolder2._visible = false;
				myPane.online_txt._visible = false;
			} else {
				// v6.4.2.7 CUP merge
				//var contentHolder = this.getScrollContent();
				var contentHolder = this.getContent();
				//trace("resize " + contentHolder);
				// EGU 1.1 add in the dictionary image, so resize changes
				//contentHolder.list_txt._width = w;
				//contentHolder.list_txt._height = h;
				//contentHolder.list_txt._width = w - 90;
				contentHolder.list_txt._width = w - 112;
				contentHolder.list_txt._height = h - 48;
				//myTrace("resize " +contentHolder +" to width=" + w);
				contentHolder.glossary_sb.setSize(contentHolder.list_txt._height);
				//contentHolder.glossary_sb._x = w + contentHolder.list_txt._x;
				contentHolder.glossary_sb._x = w - 32 + contentHolder.list_txt._x;
				contentHolder.glossary_sb._y = contentHolder.list_txt._y;
				//clt._width = w;
				// EGU 1.1 add in the dictionary image, so resize moves it
				//myTrace("resize to w=" + w + " h=" +h);
				//this.imageHolder1._x = w - 63;
				//this.imageHolder2._x = w - 92;
				this.imageHolder1._x = w - 95;
				this.imageHolder2._x = w - 130;
				//this.imageHolder2._y = h + 29;
				//myPane.online_txt._y = h + 30;
				this.imageHolder2._y = h + 13;
				myPane.online_txt._y = h + 13;
				myPane.online_txt._visible = true;
				this.imageHolder1._visible = true;
				this.imageHolder2._visible = true;
				// v6.4.2.7 Try adding a separator under the definition
				this.setSeparator(h + 10);
			}
		}
		myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myPane.onPrint, noClose:true}]);
		// see displayYourScore for setKeys comment
		//myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myPane.onClose},
		//				{key:[KEY.ENTER, "P".charCodeAt(0)], setReleaseAction:myPane.onPrint, noClose:true}]);
		myPane.setCloseHandler(myPane.onClose);
		myPane.setResizeHandler(myPane.onResize);
		//myPane.setPaneMaximumSize(600, 450);
		//prime the sizing
		// v6.4.2.7 CUP merge
		//var initialSize = myPane.getContentSize();
		//myPane.onResize(initialSize.width, initialSize.height);
		myPane.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height + myPane.online_txt._height);
		myPane.onResize(myPane.getContentSize());
		//myTrace("initialSize.width=" + initialSize.width);
		myPane.setEnabled(true);
	} else {
		//var onlineDictionary = "L";
		//var cupDictionary = "CALD";
		//var thisURL = "http://dictionary.cambridge.org/results.asp?searchword=" + escape(word) + "&dict=" + cupDictionary;
		//v6.3.6 Read the glossary URL from the literals XML
		var substList = [{tag:"[x]", text:escape(word)}];
		// v6.3.6 And has the course author set the dictionary they want? (At the course level)
		if (_global.ORCHID.course.dictionary == undefined) {
			var thisTag = "glossaryURL";
		} else {
			// v6.4.2.4 What if no dictionary is wanted?
			if (_global.ORCHID.course.dictionary == "none") {
				return;
			}
			var thisTag = _global.ORCHID.course.dictionary + "#glossaryURL";
		}
		var thisURL = substTags(_global.ORCHID.literalModelObj.getLiteral(thisTag, "messages"), substList);
		// v6.3.6 Can you keep this in one window? This works, but second time the new window doesn't
		// get the focus, so you think it hasn't done anything. Using a JS function works. For now, just read
		// the same variable as help from location.ini. Later you can use a js function:getScriptVersion()
		// or something to see if the calling page supports the required js.
		// Hijack help code
		if (_global.ORCHID.commandLine.help != undefined) {
			// this variable MIGHT include a javascript function name used to open the windows
			// v6.4.1 The split character might be # or + either way it should be after the .extenstion
			// First check if there is a + after the . If not, assume #. Doesn't matter if not there.
			// Actually, it turns out that LoadVars uses + as the escape character for a space, so we
			// cannot use it here for this purpose. Switch to # in the location.ini or command parameters
			var extChar = _global.ORCHID.commandLine.help.lastIndexOf(".");
			if (_global.ORCHID.commandLine.help.indexOf("+", extChar) > 0 ) {
				var splitChar = "+";
			} else if (_global.ORCHID.commandLine.help.indexOf("#", extChar) > 0 ) {
				var splitChar = "#";
			} else {
				// Use a character that cannot be there as not allowed
				var splitChar = null;
			}
			var helpOptions = _global.ORCHID.commandLine.help.split(splitChar);
			if (helpOptions.length > 1) {
				//var helpDoc = helpOptions.slice(0,helpOptions.length-1).join(splitChar);
				var helpJSFunction = helpOptions[helpOptions.length-1];
			} else {
				//var helpDoc = helpOptions[0];
				var helpJSFunction = undefined;
			}
		}
		// v6.4.3 If the literals have been edited to remove the glossary lookup, do nothing
		if (thisURL != "" || thisURL == undefined) {
			if (helpJSFunction == undefined) {
				myTrace("dictionary=" + thisURL)
				getURL(thisURL, "_blank");
			} else {
				myTrace("dictionary=" + helpJSFunction + "(" + thisURL + ")");
				getURL("javascript:" + helpJSFunction + "('" + thisURL + "', 800, 585 ,0 ,0 ,0 ,0 ,1 ,1 ,20 ,20, 'dictionaryWin' )");
			}
		} else {
			myTrace("no lookup listed in literals");
		}
	}
}
// v6.3.5 A new window that gives countdown hints - since they are very different
View.prototype.cmdCountdownHint = function(word) {
	
	// Build up a text to use as a hint for this word
	//myTrace("hint for countdown word");
	// make the 'anagram'
	var mixedWord = word.split("").sort().join("");
	if (word == mixedWord) {
		mixedWord = word.split("").sort().reverse().join(" ");
	} else {
		mixedWord = word.split("").sort().join(" ");
	}
	var thisHint = "<b>" +mixedWord + "</b>";
	var substList = [{tag:"[x]", text:thisHint}, {tag:"[newline]", text:"<br>"}, {tag:"[tab]", text:"<tab>"}];
	//myTrace("use text=" + _global.ORCHID.literalModelObj.getLiteral("countdownHint", "messages"));
	var hintDetail = substTags(_global.ORCHID.literalModelObj.getLiteral("countdownHint", "messages"), substList);
	var initObj = { _x:180, _y:160, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
 	if (_global.ORCHID.root.buttonsHolder.MessageScreen.hint_SP == undefined) {
		var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "hint_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
	} else {
		// if the window already exists, simply make sure it is displayed.
		_global.ORCHID.root.buttonsHolder.MessageScreen.hint_SP._visible = true; 
		return;
	}
	myPane.setTitle(_global.ORCHID.literalModelObj.getLiteral("hint", "labels"));
	myPane.setContentBorder(false);
	myPane.setCloseButton(true);
	myPane.setResizeButton(false);
	var contentHolder = myPane.getContent();

	//contentHolder.createTextField("list_txt", 0, 0,0,350,125);	
	contentHolder.createTextField("list_txt", 0, 8,8,350,125);	
	contentHolder.list_txt.html = true;
	contentHolder.list_txt.wordWrap = true;
	contentHolder.list_txt.multiline = true;
	contentHolder.list_txt.autosize=true;
	contentHolder.list_txt.border=false;
	var glossTF = new TextFormat();
	glossTF.font = "Verdana";
	glossTF.size = 12;
	glossTF.tabStops = [50];
	//contentHolder.list_txt.setNewTextFormat(glossTF);
	contentHolder.list_txt.setHtmlText(hintDetail, glossTF);
	
	//myTrace("how to hide the resize handle?");
	//prime the sizing
	myPane.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
	// and get the scroll bar right by using resize routine
	myPane.onResize(myPane.getContentSize());
	myPane.setEnabled(true);
	
	// v6.3.5 Asking for a hint costs you dearly!
	// Not sure if this is good to simply mark it as a wrong one. How about half a point - then round up?
	// v6..4.2.7 Change where the incorrect ones are stored
	//_global.ORCHID.LoadedExercises[0].body.text.group[0].incorrectClicks++;
	var cdController = _global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController;
	cdController.incorrectClicks++;

}

// these functions are restored by decompiling objects.swf from 28 Nov (using Flare)
// v6.2 allow for the special example region to shrink and expand
View.prototype.cmdShrink = function (component) {
	// remember the scroll position
	// v6.3.3 move exercise panels to buttons holder
	myTrace("cmdShrink");
	var scrollPos = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getScrollPosition();
	//trace('shrink the example region');
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.expandExample_pb.setEnabled(true);
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.shrinkExample_pb.setEnabled(false);
	// v6.5.6.5 I don't understand why, but when I set the button to disabled, I lose the release action.
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.expandExample_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExpand);
	
	// v6.3.3 move exercise panels to buttons holder
	//_root.exerciseHolder.Example_SP._visible = false;
	//var eRDepth = _root.exerciseHolder.Example_SP.regionDepth;
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.Example_SP._visible = false;
	var eRDepth = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Example_SP.regionDepth;
	//trace('example region depth=' + eRDepth);
	var regions = ['NoScroll_SP', 'Exercise_SP'];
	for (var i in regions) {
		// v6.3.3 move exercise panels to buttons holder
		//if (_root.exerciseHolder[regions[i]]._name != undefined) {
		if (_global.ORCHID.root.buttonsHolder.ExerciseScreen[regions[i]]._name != undefined) {
			//trace('take that off ' + _root.exerciseHolder[regions[i]] + '._y=' + _root.ExerciseHolder[regions[i]]._y);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen[regions[i]]._y -= eRDepth;
		}
	}
	// v6.3.3 move exercise panels to buttons holder
	var myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getPaneWidth();
	var myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getPaneHeight();
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.setSize(myW, myH + eRDepth);
	// and force the scrolling to go to where it was
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.setScrollPosition(scrollPos.x,scrollPos.y);
};
View.prototype.cmdExpand = function (component) {
	myTrace("cmdExpand");
	// v6.3.3 move exercise panels to buttons holder
	//trace('expand the example region');
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.expandExample_pb.setEnabled(false);
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.shrinkExample_pb.setEnabled(true);
	// v6.5.6.5 I don't understand why, but when I set the button to disabled, I lose the release action.
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.shrinkExample_pb.setReleaseAction(_global.ORCHID.viewObj.cmdShrink);

	_global.ORCHID.root.buttonsHolder.ExerciseScreen.Example_SP._visible = true;
	var eRDepth = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Example_SP.regionDepth;
	//trace('example region depth=' + eRDepth);
	var regions = ['NoScroll_SP', 'Exercise_SP'];
	for (var i in regions) {
		if (_global.ORCHID.root.buttonsHolder.ExerciseScreen[regions[i]]._name != undefined) {
			//trace('add that to ' + _root.exerciseHolder[regions[i]] + '._y=' + _root.ExerciseHolder[regions[i]]._y);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen[regions[i]]._y += eRDepth;
		}
	}
	var myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getPaneWidth();
	var myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getPaneHeight();
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.setSize(myW, myH - eRDepth);
};

// navigation based buttons
View.prototype.cmdMenu = function(component) {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	// v6.4.2.4 Now this might happen from an exercise screen as well - in which case we have to do more stuff
	var isDirty = (_global.ORCHID.session.currentItem.scoreDirty == true);
	var hasMarking = _global.ORCHID.LoadedExercises[0].settings.buttons.marking;
	// the user has done something and there is a marking button, so going on will lose their work
	//myTrace("isDirty=" + isDirty + " hasMarking=" + hasMarking);
	if (isDirty && hasMarking) {
		//myTrace("confirm to leave");
		_global.ORCHID.viewObj.displayMsgBox("goMenu", null, marking);
		// v6.4.2.4 You forgot this bit! - don't go on any further here
		return;
	} else if (isDirty) {
		// they've done something, but no marking button, so simply mark and go on as no other option.
		justMarking();
	}
	_global.ORCHID.viewObj.displayScreen("MenuScreen");
	// No need to go through moveExercise - the above will trigger the dialog box if it is needed.
	/*
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	// This can be handled by the more generic moveExercise function
	_global.ORCHID.viewObj.moveExercise();
	*/
}

View.prototype.moveExercise = function(component, direction) {
	//myTrace("moveExercise: .marked=" + _global.ORCHID.session.currentItem.marked);
	// v6.3.2 If the exercise has not been marked yet, you must record that it has been done
	// That is mostly done here, but if you get the pop-up and then decide to come back here
	// and finish, we don't want it done. So that is left until displayMsgBox to do.
	// Therefore look for this code inside the if stmt.
	//myTrace("moveExercise");
	// check that they are happy to lose any non-marked work in this exercise
	// ask navigation module to send us to the next exercise (or whatever)
	if (direction == "forward") {
		// v6.2 The next item has been found when this exercise was read
		//var nextItem = _global.ORCHID.course.scaffold.getNextItemID(_global.ORCHID.session.currentItem.ID);	
		// v6.5.5.0 Content paths. What happens if I figure out my next item now, rather than before I started?
		// I hope this will let me make the result conditional.
		// All well and good, but if I am using an exercise to do the navigation, then this function will have set the nextItem before
		// I come here. So let's revert to setting it during exercise loading.
		//_global.ORCHID.session.nextItem = _global.ORCHID.course.scaffold.getNextItemID(_global.ORCHID.session.currentItem.ID);
		var nextItem = _global.ORCHID.session.nextItem;
	} else if (direction == "backward") {
		// v6.2 The next item has been found when this exercise was read
		//var nextItem = _global.ORCHID.course.scaffold.getPreviousItemID(_global.ORCHID.session.currentItem.ID);
		var nextItem = _global.ORCHID.session.previousItem;
	} else {
		var nextItem = undefined;
	}
	// 6.0.4.0, AM: use the function _global.ORCHID.viewObj.displayMsgBox() to handle message box display.
	//if (((_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.MarkingButton) != _global.ORCHID.exMode.MarkingButton) 
	// I only want to ask for confirmation if there is a marking button, an undefined score and something in the exercise
	//trace("confirmation: markingButton=" + (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NoMarkingButton) + 
	//" feedbackButton=" + (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NoFeedbackButton));
	// v6.3.2 Actually you want to add a little to this in that if they have not done anything, then I don't want to warn
	// them and I don't want to record their score. Do I save anything to help me work this out?
	// Yes (now), you can use .scoreDirty which is set if singleMarking is ever called
	// This is getting very complex, so set up some simple temp binaries to help
	// 1) Is this an exercise or is it just text only?
	// 2) If it is an exercise, can it be marked?
	// 3) Have they done anything in the exercise?
	// 4) Has it been marked already?
	var isExercise = (_global.ORCHID.LoadedExercises[0].body.text.group.length != 0);
	// v6.3.3 change mode to settings
	//var hasMarking = !(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NoMarkingButton);
	var hasMarking = _global.ORCHID.LoadedExercises[0].settings.buttons.marking;
	var isDirty = (_global.ORCHID.session.currentItem.scoreDirty == true);
	//var beenMarked = (_global.ORCHID.LoadedExercises[0].score != undefined) ||
	var beenMarked = (_global.ORCHID.session.currentItem.marked == true);
	//myTrace("moveExercise: .marked=" + _global.ORCHID.session.currentItem.marked);
	// v6.4.2.8 Another one. This is to test whether you have seen any feedback if instant marking was available.
	var noFeedbackSeen = true;
	for (var i in _global.ORCHID.LoadedExercises[0].feedback) {
		//myTrace("fb[" + i + "].seen=" + _global.ORCHID.LoadedExercises[0].feedback[i].seen);
		if (_global.ORCHID.LoadedExercises[0].feedback[i].seen == true) {
			noFeedbackSeen = false;
			break;
		}
	}
	// For now override this as I don't actually want to implement this yet.
	noFeedbackSeen = false;
	
	// First, if it has been marked, then don't do any other checking
	if (beenMarked == true) {
		//myTrace("marking: been marked already");
	// If it can be marked, (but hasn't been) and something has been done, then you need to 
	// confirm that they really want to go on before marking it. So the marking is done
	// in the displayMsgBox bit IF they are asked and say YES (or are not asked)
	} else if (isExercise && hasMarking && isDirty) {
		//myTrace("marking: will they continue?");
		//mainMarking();
		var marking = true;
		if (nextItem == undefined) {
			// v6.3.3 If you are in SCORM (and this is a unit SCO) getting to the end of a unit means exit please
			// v6.4.2.4 More than that - if you started in a unit or an exercise you don't want to go to the menu either.
			// v6.5.5.5 Are you sure you should be directly exiting here? Isn't this just setting up an "are you sure" msgbox?
			myTrace("startingPoint=" + _global.ORCHID.commandLine.startingPoint);
			if (_global.ORCHID.commandLine.scorm ||
				(_global.ORCHID.commandLine.startingPoint!=undefined && 
				(_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0 ||
				_global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0))) {
				// v6.4.2.4 Have a different exit function in case you want to tell them anything
				//_global.ORCHID.viewObj.cmdExit();
				_global.ORCHID.viewObj.cmdComplete();
			// v6.5.5.5 If this exercise eF is exitAfter, lets do that now too			
			// You could merge with above, but I want to easliy trace for now
			} else if (_global.ORCHID.enabledFlag.exitAfter & _global.ORCHID.session.currentItem.enabledFlag) {
				myTrace("found exercise with eF=exitAfter, so lets go");
				_global.ORCHID.viewObj.cmdComplete();
			} else {
				// v6.4.2.4 Allow the home button on exercise screen too, so need to check for that
				// This should actually not happen anymore, all done directly from the buttons
				if (direction == "home") {
					_global.ORCHID.viewObj.displayMsgBox("goHome", null, marking);
				} else if (direction == "exit") {
					_global.ORCHID.viewObj.displayMsgBox("goExit", null, marking);
				} else {
					_global.ORCHID.viewObj.displayMsgBox("goMenu", null, marking);
				}
			}
		} else {
			if (direction == "forward") {
				_global.ORCHID.viewObj.displayMsgBox("goNext", nextItem, marking);
			} else {
				_global.ORCHID.viewObj.displayMsgBox("goPrevious", nextItem, marking);
			}
		}
		// don't go on any further here
		return;
	// It can be marked, but the student has done nothing, so ignore it
	// This is a questionable/optional choice. It is probably just as valid to
	// ALWAYS do null marking, even if the student just looked
	//} else if (isExercise && hasMarking && !isDirty) {
	//	myTrace("marking: not dirty, so no marking");

	// v6.3.5 if you have done nothing in it, then DON'T do any kind of progress report
	// v6.4.2.8 But surely also doing something that has not shown you the correct answer should also be ignored in that case? After all
	// you have now seen the contents of the exercise. Would it be ideal if we could record the fact that you have seen the exercise
	// (with a null score) but that you have not done marking? So add another condition
	//} else if (isExercise && hasMarking && !isDirty) {
	} else if ((isExercise && hasMarking && !isDirty) || 
		// v6.4.2.8 See above. If we have opened an exercise and clicked or typed some answers, but with no instant marking
		// and no marking. Then we don't really want to record the full score. Can we just record a null score? Meaning looked at it?
		// The progress indicators will then be complicated because we will have a score but how will we know that they haven't 
		// really done it? The progress indicator will have to also see if the exercise has the potential to have been done.
		// For now I am going to set noFeedbackSeen to false so that this bit is never triggered until you work out the implications
		(isExercise && hasMarking && isDirty && noFeedbackSeen)) {
		
		myTrace("still clean in this exercise");
		var marking = false;
		if (nextItem == undefined) {
			// v6.3.3 If you are in SCORM (and this is a unit SCO) getting to the end of a unit means exit please
			// v6.4.2.4 More than that - if you started in a unit or an exercise you don't want to go to the menu either.
			myTrace("startingPoint=" + _global.ORCHID.commandLine.startingPoint);
			if (_global.ORCHID.commandLine.scorm ||
				(_global.ORCHID.commandLine.startingPoint!=undefined && 
				(_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0 ||
				_global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0))) {
				// v6.4.2.4 Have a different exit function in case you want to tell them anything
				//_global.ORCHID.viewObj.cmdExit();
				_global.ORCHID.viewObj.cmdComplete();
			// v6.5.5.5 If this exercise eF is exitAfter, lets do that now too			
			// You could merge with above, but I want to easliy trace for now
			} else if (_global.ORCHID.enabledFlag.exitAfter & _global.ORCHID.session.currentItem.enabledFlag) {
				myTrace("found exercise with eF=exitAfter, so lets go");
				_global.ORCHID.viewObj.cmdComplete();
			} else {
				// v6.4.2.4 surely you should NOT be asking these questions here! this is the whole point of this block
				//_global.ORCHID.viewObj.displayMsgBox("goMenu", null, marking);
				_global.ORCHID.viewObj.displayScreen("MenuScreen");
			}
		} else {
			// v6.4.2.4 surely you should NOT be asking these questions here! this is the whole point of this block
			//myTrace("don't do this!!!");
			/*
			if (direction == "forward") {
				_global.ORCHID.viewObj.displayMsgBox("goNext", nextItem, marking);
			} else {
				_global.ORCHID.viewObj.displayMsgBox("goPrevious", nextItem, marking);
			}*/
			// Must do null marking to show that they looked at this exercise for x duration. I think.
			// v6.4.2.4 DECISION. No, you have done nothing, you shouldn't be recorded as having done anything.
			//justMarking();
			_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
			_global.ORCHID.root.mainHolder.creationNS.createExercise(nextItem);
		}
		// don't go on any further here
		return;
		
	// otherwise we need to do a duration marking whatever
	} else {
		//myTrace("marking: just do null marking");
		justMarking();
	}
		
	/*
	if (!(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NoMarkingButton) 
		&& _global.ORCHID.LoadedExercises[0].score == undefined 
		&& _global.ORCHID.session.currentItem.scoreDirty == true
		&& _global.ORCHID.LoadedExercises[0].body.text.group.length != 0) {
		//trace("get confirmation as marking button + no score");
		if (nextItem == undefined) {
			_global.ORCHID.viewObj.displayMsgBox("goMenu");
		} else {
			if(direction == "forward") {
				_global.ORCHID.viewObj.displayMsgBox("goNext", nextItem);
			} else {
				_global.ORCHID.viewObj.displayMsgBox("goPrevious", nextItem);
			}
		}
	} else {
	*/
	// confirmation about whether to see feedback or not
	// v6.3.2 Can only have feedback after marking
	// v6.4.2.8 I don't want to ask them about feedback if they have already seen it all. This will have happened if
	// a) it is instant marking and they clicked all questions
	// b) after marking they clicked on all the questions to see the individual feedback. In fact, we have already set this up
	//	so that clicking on any field after marking will set feedbackSeen to true and you won't be asked for confirmation.
	// v6.4.2.8 For all the feedback items, if any are not recorded as having been seen, we will keep going with the confirmation.
	// otherwise all has been seen and we can hop out.
	var someNotSeen = false;
	for (var i in _global.ORCHID.LoadedExercises[0].feedback) {
		//myTrace("fb[" + i + "].seen=" + _global.ORCHID.LoadedExercises[0].feedback[i].seen);
		if (_global.ORCHID.LoadedExercises[0].feedback[i].seen <> true) {
			someNotSeen = true;
			break;
		}
	}
	//myTrace("feedback confirmation, someNotSeen=" + someNotSeen);
	if (	beenMarked &&
		someNotSeen &&
		!_global.ORCHID.LoadedExercises[0].feedbackSeen &&
		// v6.3.3 change mode to settings
		//&& !(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NoFeedbackButton) 
		_global.ORCHID.LoadedExercises[0].settings.buttons.feedback &&
		(_global.ORCHID.LoadedExercises[0].feedback.length != 0)) {
			
		//myTrace("get confirmation as feedback button + not seen + some feedback");
		//display message box to ask if the user want to see feedback
		//trace("_global.ORCHID.LoadedExercises[0].feedbackSeen = " + _global.ORCHID.LoadedExercises[0].feedbackSeen);
		// v6.4.2.7 Reenable the forward arrow in case they do want feedback 
		if (direction == "forward") {
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.navForward_pb.setEnabled(true);
		} else {
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.navBack_pb.setEnabled(true);
		}
		if (nextItem == undefined) {
			_global.ORCHID.viewObj.displayMsgBox("seeFeedback", "menu");
		} else {
			if (direction == "forward") {
				//myTrace("seeFeedback, go forward if not");
				_global.ORCHID.viewObj.displayMsgBox("seeFeedback", nextItem);
			} else {
				_global.ORCHID.viewObj.displayMsgBox("seeFeedback", nextItem);
			}
		}
	} else {
		//myTrace("no need for confirmation");
		// did a real item come back from the scaffold?
		//trace("in buttons from scaffold, nextItem=" + nextItem);
		if (nextItem == undefined) {
			// v6.3.3 If you are in SCORM (and this is a unit SCO) getting to the end of a unit means exit please
			// v6.4.2.4 More than that - if you started in a unit or an exercise you don't want to go to the menu either.
			myTrace("startingPoint=" + _global.ORCHID.commandLine.startingPoint);
			if (_global.ORCHID.commandLine.scorm ||
				(_global.ORCHID.commandLine.startingPoint!=undefined && 
				(_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0 ||
				_global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0))) {
				// v6.4.2.4 Have a different exit function in case you want to tell them anything
				//_global.ORCHID.viewObj.cmdExit();
				_global.ORCHID.viewObj.cmdComplete();
			// v6.5.5.5 If this exercise eF is exitAfter, lets do that now too			
			// You could merge with above, but I want to easliy trace for now
			} else if (_global.ORCHID.enabledFlag.exitAfter & _global.ORCHID.session.currentItem.enabledFlag) {
				myTrace("found exercise with eF=exitAfter, so lets go");
				_global.ORCHID.viewObj.cmdComplete();
			} else {
				// go to the menu
				_global.ORCHID.viewObj.displayScreen("MenuScreen");
			}
		} else {
			//trace("about to go forward to item " + nextItem);
			//trace("move to item ID " + nextItem.id + " from " + _global.ORCHID.session.currentItem.ID);
			// clear out the current exercise
			// 6.0.2.0 remove connection
			//_root.exerciseHolder.myConnection.clearExercise(0);
			// v6.3.6 Merge exercise into main
			_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
			// 6.0.2.0 remove connection
			//sender = new LocalConnection();
			//sender.send("controlConnection", "createExercise", nextItem);
			//delete sender;
			//_root.exerciseHolder.exerciseNS.createExercise(nextItem);
			// createExercise is a method in creation module NOT exercise module
			// v6.3.6 Merge creation into main
			//_root.creationHolder.creationNS.createExercise(nextItem);
			_global.ORCHID.root.mainHolder.creationNS.createExercise(nextItem);
		}
	}
	//}
//	this.setState("exercise");
}
View.prototype.cmdForward = function(component) {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	//myTrace("request from button " + this);
	
	// v6.4.2.4 Don't allow this to be double clicked
	//myTrace("click cmdForward");
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.navForward_pb.setEnabled(false);
	
	//_global.ORCHID.root.buttonsHolder.buttonsNS.moveExercise(component, "forward");
	_global.ORCHID.viewObj.moveExercise(component, "forward");
}
View.prototype.cmdBack = function(component) {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	// v6.4.2.4 Don't allow this to be double clicked
	//myTrace("click cmdBackward");
	_global.ORCHID.root.buttonsHolder.ExerciseScreen.navBack_pb.setEnabled(false);

	//_global.ORCHID.root.buttonsHolder.buttonsNS.moveExercise(component, "backward");
	_global.ORCHID.viewObj.moveExercise(component, "backward");
}
// This is a version of the exercise button shown on the exercise screen, and if clicked
// you need to check that they want to quit this exercise. Of course, like the checks on
// next and back this should only come up if they have answered any questions, otherwise
// they won't lose any work as no work has been done.
View.prototype.cmdTestInExercise = function(component) {
	//myTrace("test in exercise");
	// ask the confirmation question, and if YES, call cmdTest
	_global.ORCHID.viewObj.displayMsgBox("goTest");
}

// v6.5.4.3 Add a new button for the certificate
View.prototype.cmdCertificate = function() {
	myTrace("find certificate")
	var goTo = _global.ORCHID.course.scaffold.getObjectByID(51);
	myTrace("it is " + goTo.filename);
	_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
	_global.ORCHID.root.mainHolder.creationNS.createExercise(goTo);
}
	
// menu based controls
View.prototype.cmdTest = function() {
	// Note that [this] refers to the button or whatever that this function was called from!
	//trace("clear screen for the test from this=" + this + " (component=" + component + ")");
	//_global.ORCHID.viewObj.clearScreen("MenuScreen");
	//trace("regular test");
	// v6.2 No longer pretend that the test screen is a full 'screen' set in creation.
	// Instead create it dynamically as a pop-up from progress (like the cmdProgress)
	//_global.ORCHID.viewObj.displayScreen("RandomTestScreen");
	// v6.3.3 Move the interface to buttons from progress movies and build the pane at design time
	//var initObj = { _x:163, _y:140, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	//if (!_root.progressHolder.testMaker_dp.isDragPane()) {
	//	var myPane = _root.progressHolder.attachMovie("APDraggablePaneSymbol", "testMaker_dp", _root.progressHolder.progressNS.fixedDepth, initObj); 
	//}

	//v6.4.2 (bulats) test like progress at first. Hmm, maybe not as that doesn't seem to work easily.
	// v6.4.2.7 CUP merge
	// Try to get rid of the special screen...
	/*
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
		_global.ORCHID.viewObj.displayScreen("TestScreen");
		var myPane = _global.ORCHID.root.buttonsHolder.TestScreen.testMaker_SP;
		myPane._visible = true;
	} else {
	*/
		//myTrace("test screen=" + myPane);
		// create the window
		var initObj = { _x:180, _y:160, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
		if (_global.ORCHID.root.buttonsHolder.MessageScreen.testMaker_SP == undefined) {
			var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "testMaker_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj); 
		} else {
			// if the window already exists, simply make sure it is displayed.
			_global.ORCHID.root.buttonsHolder.MessageScreen.testMaker_SP._visible = true;
			var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.testMaker_SP;
			return;
		}
	//}
	myPane.setTitle(_global.ORCHID.literalModelObj.getLiteral("makeActivity", "labels"));
	myPane.setContentBorder(false);
	myPane.setCloseButton(true);
	myPane.setResizeButton(false);
	// v6.4.2.8 Make it bigger
	// v6.5 Make old EGU code work too. 
	// Note that this doesn't work as EGU uses old style of test generation.
	// So you have to go back to 6.4.2.7 to get tests to work
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/EGU") >= 0) {
		myPane.setMinSize(500, 160);
		//myPane.setMinSize(400, 200);
	} else {
		myPane.setMinSize(300, 300);
	}
	//myPane.setMaxSize(700, 550);
	var contentHolder = myPane.getContent();

	// CUP/GIU (change from FDraggable to APDraggable
	//myPane.setResizable(false);
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// v6.2
		myPane.setContentBorder(false);
		myPane.setSize(454, 254);
		myPane.setScrolling(false);
	}
	//myPane.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("makeActivity", "labels"));

	//myPane.setScrollContent("blob");
	//var contentHolder = myPane.getScrollContent();
	//myTrace("contentHolder=" + contentHolder);
	myPane.onClose = function() {
		//myTrace("try to close testScreen");
		// v6.4.2.7 CUP merge - this is the old code for drag pane, so needs an explicit call
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			//this.closePane();
			//this._visible = false;
		//}
		//_global.ORCHID.viewObj.clearScreen("ProgressScreen");
	}
	//closeHandler = function() {
		//myPane.removeMovieClip();
		//return true;
		// v6.3.3 Move the interface to buttons from progress movies
	//	_global.ORCHID.viewObj.clearScreen("TestScreen");
	//}
	//myPane.setCloseHandler(closeHandler);

	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
		//trace("the testMaker is " + this.testMaker_dp);
		//var goCreate = _global.ORCHID.viewObj.cmdRandomTest;
		// v6.3.4 Add close handling to the button action\
		//v6.4.2 change scope
		//var goCreate = function() {
		myPane.goCreate = function() {
			myTrace(this.numQuestions.numQuestionsText.text + " in goCreate of " + this );
			this.closeHandler();
			_global.ORCHID.viewObj.cmdRandomTest();
		}
		//myPane.setBoxType("full");
		// v6.4.2.7 CUP merge, this is done later as well
		//myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("createTest", "buttons"), setReleaseAction:goCreate}]);
		
		// add numQuestions to the bottom of the window
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
			//var initObj = {_x:190, _y:203, maxHeight:150};
			//var initObj = {_x:190, _y:208, maxHeight:150};
			var initObj = {_x:190, _y:208, maxHeight:160};
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) { 
				initObj.fillColor = 0x40AFD4;
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("ESG") >= 0) { 
				initObj.fillColor = 0xF9DED3;
			} else {
				initObj.fillColor = 0x339966;
			}
		} else {
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("bulats") >= 0) { 
				//v6.4.2 These are specifically set for bulats
				var initObj = {_x:50, _y:35, fillColor:0x99CC00, maxHeight:186};
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) { 
				// v6.4.3 Make it bigger
				//var initObj = {_x:70, _y:35, fillColor:0x990000, maxHeight:140};
				//var initObj = {_x:70, _y:35, fillColor:0x990000, maxHeight:160};
				var initObj = {_x:50, _y:50, fillColor:0x990000, maxHeight:300};
			} else {
				// v6.4.2.8 For general Clarity programs
				// v6.4.2.8 Not so wide so that you can fit in a 'select all' check box.
				var initObj = {_x:70, _y:35, fillColor:0x99CC00, maxHeight:140};
			}
		}
		contentHolder.maxHeight = initObj.maxHeight; // an initial setting used for column breaks
		//myPane.attachMovie("numQuestions","numQuestions", _root.progressHolder.progressNS.depth++, initObj); 
		// depth problems here - try a big one to avoid conflict with buttons
		//myPane.attachMovie("numQuestions","numQuestions", 88, initObj); 
		var myController = myPane.createEmptyMovieClip("numQuestions", 88);
		myController._x = initObj._x;
		myController._y = initObj._y;
		//v6.4.2 Neater slider arrangement for generated tests
		// v6.5 Make old EGU code work too
		// Note that this doesn't work as EGU uses old style of test generation.
		// So you have to go back to 6.4.2.7 to get tests to work
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/EGU") >= 0) {
			myTrace("old slider code")
			myController.createTextField("numQuestionsText", 1, 40,  0, 200, 17);
			myController.createTextField("firstQuestion", 2, -10, 14,  20, 17);
			myController.createTextField("lastQuestion", 3, 212, 15,  20, 17);
			var mySlider = myController.attachMovie("FSliderSymbol", "numQuestionsSlider", 4, {_x:10, _y:16, fillColor:initObj.fillColor});
			mySlider.setSize(200);
		} else {
			// v6.4.2.8 Not so wide so that you can fit in a 'select all' check box.
			//myController.createTextField("numQuestionsText", 1, 40,  0, 200, 17);
			myController.createTextField("numQuestionsText", 1, 10,  0, 150, 17);
			//myController.createTextField("firstQuestion", 2, -10, 14,  20, 17);
			myController.createTextField("firstQuestion", 2, -4, 16,  20, 17);
			//myController.createTextField("lastQuestion", 3, 212, 15,  20, 17);
			myController.createTextField("lastQuestion", 3, 157, 16,  20, 17);
			//var mySlider = myController.attachMovie("FSliderSymbol", "numQuestionsSlider", 4, {_x:10, _y:16, fillColor:initObj.fillColor});
			var mySlider = myController.attachMovie("FSliderSymbol", "numQuestionsSlider", 4, {_x:10, _y:20, fillColor:initObj.fillColor});
			//mySlider.setSize(200);
			mySlider.setSize(145);
			// v6.4.2.8 Add a 'select all' check box - please add it to literals
			//var myCheckBox = myController.attachMovie("FCheckBoxSymbol", "selectAll", 5, {_x:170, _y:16});
			var myCheckBox = myController.attachMovie("FCheckBoxSymbol", "selectAll", 5, {_x:10, _y:43});
			myCheckBox.setSize(200);
			myCheckBox.setLabel("From all topics");
			//myCheckBox.setStyleProperty("textSize", 11); 
			myCheckBox.setStyleProperty("textSize", 12); 
			myController.onSelectAllChange = function() {
				if (this.selectAll.getValue()) {
					//myTrace("selectAllChange with " + this._parent);
					var me = this._parent.getContent();
					//myTrace("selectAllChange with " + me);
					for (var i in me) {
						//myTrace("unit item " + me[i]);
						if(me[i]._name.indexOf("unitName") == 0) {
							me[i].setValue(true);
						}
					}
				} else {
					//myTrace("selectAllChange with " + this._parent);
					var me = this._parent.getContent();
					//myTrace("selectAllChange with " + me);
					for (var i in me) {
						//myTrace("unit item " + me[i]);
						if(me[i]._name.indexOf("unitName") == 0) {
							me[i].setValue(false);
						}
					}
				}
			}
			myCheckBox.setChangeHandler("onSelectAllChange");
		}

	//} else {
		// v6.2 This won't work any more! But who cares because it is a bad way to do it.
		//myPane.setScrollContent("unitSelection"); // (unitSelection_mc);
		//contentHolder.maxHeight = 200; // an initial setting used for column breaks
		//contentHolder.cmdOK_pb.setChangeHandler("cmdRandomTest", _global.ORCHID.viewObj);
	//}
	
	// To set the number of questions controller
	// CUP/GIU - numQuestions is not part of content anymore
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
		var numQHolder = myPane.numQuestions;
	//} else {
		// this line is added as the rest of the code uses numQHolder, which is different for CUP/GIU
		//var numQHolder = contentHolder;
	//}
	//trace("the num Q holder=" + numQHolder);
	var numText = numQHolder.numQuestionsText;
	var firstText = numQHolder.firstQuestion;
	var lastText = numQHolder.lastQuestion;
	numText.autosize = firstText.autosize = lastText.autosize =true;
	numText.border = firstText.border = lastText.border = false;
	// v6.5 Make old EGU code work too
	// Note that this doesn't work as EGU uses old style of test generation.
	// So you have to go back to 6.4.2.7 to get tests to work
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/EGU") >= 0) {
		var myTF = _global.ORCHID.basicText;
	} else {
		var myTF = new TextFormat();
		myTF.font = globalStyleFormat.textFont;
		myTF.size = 12;
	}
	numText.setNewTextFormat(myTF);
	firstText.setNewTextFormat(myTF);
	lastText.setNewTextFormat(myTF);

	numQHolder.onQuestionNumChange = function() {
		//var numQ = this.numQuestionsSlider.getIntValue();
		var numQ = this.numQuestionsSlider.getIntValue();
		//trace("do a num change in " + this.numQuestionsSlider + " to " + numQ);
		if (numQ > 1) {
			//this.numQuestionsText.text = "Use " + numQ + " questions";
			this.numQuestionsText.text = _global.ORCHID.literalModelObj.getLiteral("useQuestions", "labels").split("[x]").join(numQ);
		} else {
			this.numQuestionsText.text = _global.ORCHID.literalModelObj.getLiteral("useOneQuestion", "labels");
		}
	}
	var questionMin = 1; var questionMax = 25; var questionDefault = 10;
	firstText.text = questionMin; lastText.text = questionMax;
	mySlider.setChangeHandler("onQuestionNumChange");
	mySlider.setSliderProperties(questionMin, questionMax);
	mySlider.setTickFrequency(10);
	mySlider.setSnapToTicks(false);
	//v6.4.2 Neater slider for generated tests
	//mySlider.setTickStyle("bottom");
	mySlider.setTickStyle("none");
	mySlider.setValue(questionDefault);
	// prime it for the first display
	numQHolder.onQuestionNumChange();

	// load up the units that you can take questions from
	//myTrace("test maker holder=" + contentHolder);
	//_root.creationHolder.creationNS.traceMe();
	// v6.3.4 Try using a design time test box - just for AGU
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/AGU") >= 0) {
		var unitsInitObj = {_x:18, _y:8};
		var myUnits = contentHolder.attachMovie("testContentHolder", "unitNames", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, unitsInitObj); 
	} else {
		// v6.3.6 Merge creation into main
		//_root.creationHolder.creationNS.loadUnitNames(contentHolder);
		_global.ORCHID.root.mainHolder.creationNS.loadUnitNames(contentHolder);
	}

	//6.4.2 Add regular popupwindow processing
	myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("createTest", "buttons"), setReleaseAction:myPane.goCreate}]);
	myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myPane.onClose}]);
	myPane.setCloseHandler(myPane.onClose);
	//myPane.setResizeHandler(myPane.onResize);
	//myPane.setPaneMaximumSize(500, 550);
	//prime the sizing
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		myPane.setContentSize(400,125);
	} else {
		//myPane.setContentSize(330,120);
		myPane.setContentSize(300,300);
	}
	//myPane.setContentSize(contentHolder.list_txt._width, contentHolder.list_txt._height);
	// and get the scroll bar right by using resize routine
	//myPane.onResize(myPane.getContentSize());
	myPane.setEnabled(true);
}

// printing
View.prototype.cmdPrint = function(component) {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert from cmdMarking");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	// v6.2 Is your Flash player good enough to print?
	//myTrace("your major version of Flash is " + _global.ORCHID.projector.FlashVersion.major);
	if (_global.ORCHID.projector.FlashVersion.major < 7) {
		_global.ORCHID.viewObj.displayMsgBox("noPrint");
	} else {
		//trace("ok, let's make a print pane");
		//_global.ORCHID.root.printingHolder.printForMe(_root.exerciseHolder)
		
		// seeTheAnswers uses the tlc and perhaps doesn't reset it properly
		// therefore do this here so that ppotP can work
		//_global.ORCHID.tlc.proportion = 0;
		
		// v6.2 Brand new function for printing the exercise.
		// We need to create a new MC (invisible) that can be passed to the printing functions
		// v6.3.3 move exercise panels to buttons holder
		//var printPane = _root.ExerciseHolder.createEmptyMovieClip("printPane", _global.ORCHID.printDepth);
		var printPane = _global.ORCHID.root.buttonsHolder.ExerciseScreen.createEmptyMovieClip("printPane", _global.ORCHID.printDepth);
		//trace("top print pane=" + printPane);
		// v6.5.4.3 comment this line to show the printed TWFs on screen for debugging
		printPane._visible = false;
		
		// then attach the following items to it from the data store
		var me = _global.ORCHID.LoadedExercises[0];
	
		// v6.5.2 AR but title is not printing at all now - bring it back to the top - No that doesn't help. No scroll not printing either
		// example region
		if (me.regions & _global.ORCHID.regionMode.example) {
			var thisText = me.example.text;
			var paneType = "scroll pane";
			var paneName = "Example_SP";
			var substList = new Array();
			_global.ORCHID.tlc = {proportion:0, startProportion:0}
			//_global.ORCHID.root.tlcController.setLabel("printing");
			_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadPrinting", "labels"));
			putParagraphsOnThePrinter(printPane, thisText, paneType, paneName, substList);
		}
		// Set the scale of the this part of the pane to 80%. 
		// v6.4.2.4 Why not set the whole pane to 80% in one go at the end?
		printPane[paneName]._xscale = printPane[paneName]._yscale = 80;
		
		// no scroll region
		// v6.3 5 except for countdown, when you don't want to print it
		if (me.regions & _global.ORCHID.regionMode.noScroll && (_global.ORCHID.LoadedExercises[0].settings.exercise.type != "Countdown")) {
			var thisText = me.noScroll.text;
			var paneType = "scroll pane";
			var paneName = "NoScroll_SP";
			var substList = new Array();
			_global.ORCHID.tlc = {proportion:0, startProportion:0}
			//_global.ORCHID.root.tlcController.setLabel("printing");
			_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadPrinting", "labels"));
			putParagraphsOnThePrinter(printPane, thisText, paneType, paneName, substList);
		}
		// Set the scale of the whole pane to 80%
		printPane[paneName]._xscale = printPane[paneName]._yscale = 80;
		
		// the title (try putting this last to allow more time for pictures in the body/examples region to load)
		// title changes after marking
		/*
		if (_global.ORCHID.session.currentItem.afterMarking) {					
			myTrace("getting title text, after marking");
			var originalText = me.title.text;
			var thisText = new Object();
			var newText = new Object();
			newText.coordinates = new Object();
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
				newText.coordinates.x = 0;
				newText.coordinates.y = 10;
				newText.coordinates.width = 506;
				newText.coordinates.height = 0;
				newText.plainText = '<font face="Verdana" size="12" color="#000000"><b>Look at the correct answers.</b></font>';
			} else {
				newText.coordinates.x = 13;
				newText.coordinates.y = 10;
				newText.coordinates.width = 506;
				newText.coordinates.height = 0;
				// v6.3 Proof reading uses a different rubric
				// v6.3.3 change mode to settings
				//if (_global.ORCHID.LoadedExercises[0].mode. & _global.ORCHID.exMode.ProofReading) {
				if (_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
					newText.gapText = '<font face="Verdana" size="13" color="#' + _global.ORCHID.PRCorrectText.rawColor +'"><b>' + 
									_global.ORCHID.literalModelObj.getLiteral("markedRubricProofReading", "labels") +
									'</b></font>';
				} else {
					newText.gapText = '<font face="Verdana" size="13" color="#' + _global.ORCHID.CorrectText.rawColor +'"><b>' + 
									_global.ORCHID.literalModelObj.getLiteral("markedRubric", "labels") +
									'</b></font>';
				}
			}
			newText.style = "normal";
			newText.id = 0;
			thisText.paragraph = new Array(newText);
		} else {
		*/
		//}
		// v6.5.2 AR but title is not printing at all now
		// v6.5.2 AR but title is not printing at all now - bring it back to the top - No that doesn't help. No scroll not printing either
		var thisText = me.title.text;
		var paneType = "scroll pane"; 
		var paneName = "Title_SP";
		var substList = new Array();
		// v6.3.5 When the text is shrunk 80%, the font changes a bit so something that fitted in one line
		// on the screen doesn't on the printer. Can I simply edit the width a bit? This will only work
		// for those AGU exercises where the title is rigorously formatted (most)
		//susbtList.push({tag:'<title><paragraph x="0" y="+0" width="506"', text:'<title><paragraph x="0" y="+0" width="516"'});
		_global.ORCHID.tlc = {proportion:0, startProportion:0};
		//_global.ORCHID.root.tlcController.setLabel("printing");
		_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadPrinting", "labels"));
		putParagraphsOnThePrinter(printPane, thisText, paneType, paneName, substList);
		// Set the scale of the whole pane to 80%
		printPane[paneName]._xscale = printPane[paneName]._yscale = 80;
		
		//v6.3.5 Add in printing of split screen reading text
		if (_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen) {
			// v6.4.2.4 It won't always be the [0] text (SB exam tips)
			//var thisText = me.texts[0].text;
			var textArrayIDX = _global.ORCHID.root.objectHolder.lookupArrayItem(_global.ORCHID.LoadedExercises[0].texts, 
												_global.ORCHID.LoadedExercises[0].readingText.id, "ID");
			var thisText = _global.ORCHID.LoadedExercises[0].texts[textArrayIDX].text;
			var paneType = "scroll pane";
			var paneName = "ReadingText_SP";
			var substList = new Array();
			// v6.3.5 When the text is shrunk 80%, the font changes a bit so something that fitted in one line
			// on the screen doesn't on the printer. Can I simply edit the width a bit? This will only work
			// for those AGU exercises where the title is rigorously formatted (most)
			//susbtList.push({tag:'<title><paragraph x="0" y="+0" width="506"', text:'<title><paragraph x="0" y="+0" width="516"'});
			_global.ORCHID.tlc = {proportion:0, startProportion:0};
			//_global.ORCHID.root.tlcController.setLabel("printing");
			_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadPrinting", "labels"));
			putParagraphsOnThePrinter(printPane, thisText, paneType, paneName, substList);
			// Set the scale of the whole pane to 80%
			printPane[paneName]._xscale = printPane[paneName]._yscale = 80;
		}
		
		// body region		
		var thisText = me.body.text;
		var paneType = "scroll pane";
		var paneName = "Exercise_SP";
		// Now - we need to use the .gapText rather than .plainText and insert the stdAnswers
		// into the gaps. 
		// Loop through finding the fields
		// dig out the student answer and put the two together into substList
		// v6.5.4.3 But if this is a target (including mc) exercise, what should we do to get selected options printed?
		// gapText just ignores targets or anything that doesn't have a student supplied answer.
		var substList = createSubstForGapAnswers(thisText);
		
		// v6.5.4.3 So add a new function to update gapText - will that have any implications with after marking or anything?
		// The function will search through gapText finding all i:target. It'll get the field ID and then getFieldTextFormat from the twf on screen.
		// It'll then copy that formatting to the new text block.
		// No. Now we simply copy from the screen if it is a target based exercise. Done in display.as
		
		// v6.3.5 You need to do this with a tlc I feel
		//_global.ORCHID.tlc = {proportion:0, startProportion:0};
		
		// for testing why title isn't printing
		completeExPrintCallback = function() {
			// finally send it to be printed
			//myTrace("put body on printer nearly over");
			//myTrace("printPane[Exercise_SP]._x=" + printPane["Exercise_SP"]._x);
			//myTrace("printPane[ReadingText_SP]._x=" + printPane["ReadingText_SP"]._x);
			//myTrace("printPane[Title_SP]._x=" + printPane["Title_SP"]._x);
			printPane._x = printPane._y = 0;
			// v6.4.2.7 Random tests get different captions
			if (_global.ORCHID.session.currentItem.unit==-16){
				fullName = _global.ORCHID.session.currentItem.caption;
			} else {
				var namePath = _global.ORCHID.course.scaffold.getParentCaptions( _global.ORCHID.session.currentItem.ID);
				fullName = namePath[namePath.length-2] + "&nbsp;-&nbsp;" + namePath[namePath.length-1];
			}
			
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				var thisHeader = fullName;
				// v6.4.2.7 use literal for EGU too
				//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
				//	var thisFooter = "English Grammar in Use CD-ROM © Cambridge University Press 2004";
				//} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
				//	var thisFooter = "Advanced Grammar in Use CD-ROM © Cambridge University Press 2005";
				//} else {
				//	var thisFooter = "Essential Grammar in Use CD-ROM © Cambridge University Press 2006";
				//}
			} else {
				var thisHeader = fullName;
				//_global.myTrace("header =" + fullName);
				//_global.myTrace("footer =" + thisFooter); 
			}
			var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}];
			var thisFooter = substTags(_global.ORCHID.literalModelObj.getLiteral("printedFrom", "labels"), substList);
			// v6.3.3. Doris found that the pictures weren't printed as they were not loaded yet.
			// Since the pictures come in through the mediaHolder and jukebox, it is rather complex
			// to try and see where you could put onLoaded event. So it is simpler by far just to add
			// in a delay at this point of the actual printing.
			// v6.3.5. Another printing problem is that if you playing audio (long) whilst printing
			// (splitScreen) you crash Flash. Is this a timing problem or something else?
			var delayedPrinting = function() {
				//myTrace("print delay, header=" + thisHeader);
				clearInterval(delayedPrintingInt);
				_global.ORCHID.root.printingHolder.printForMe(printPane, thisHeader, thisFooter);
			}
			var delayedPrintingInt = setInterval(delayedPrinting, 1000);
		}
		_global.ORCHID.tlc = {proportion:100,
							startProportion:0,
							callBack:completeExPrintCallback}
		//_global.ORCHID.root.tlcController.setLabel("printing");
		_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadPrinting", "labels"));
		//myTrace("call ppotP from 2274");
		putParagraphsOnThePrinter(printPane, thisText, paneType, paneName, substList);
		// debugging only
		//for (var iP in thisText) {
			//myTrace("para x=" + thisText[i]._x + ", text=" + thisText[i].plainText);
		//}
		// Set the scale of the whole pane to 80%
		printPane[paneName]._xscale = printPane[paneName]._yscale = 80;				
	}
}
createSubstForGapAnswers = function(textObj) {
	var substArray = new Array();
	var rawText = "";
	var fields = textObj.field;
	var groups = textObj.group;
	// v6.5.4.3 This is all about picking up the student supplied answers for printing.
	// But what about student selected answers? Do I have to find each field and then look to the screen version to find the formatting?
	// But this function is just for replacing gaps. I'd need to do that in a different loop updating gapText before this loop happens (or after)
	// and actually change gapText, which would clearly violate the purpose of this function - so lets have another.
	for (var i in textObj.paragraph) {
		rawText = textObj.paragraph[i].gapText;
		//myTrace("view:checking para " + textObj.paragraph[i].gapText);
		var j = rawText.indexOf("[", 0);
		var fieldArrayIDX=0;
		while (j >= 0) {
			k = rawText.indexOf("]", j + 1);
			// did you find a closing brace?
			if (k > j) {			
				// what is the field ID
				myFieldID = rawText.substring(j + 1, k);
				//trace("found field ID=" + myFieldID);
				// which gives which field idx
				fieldArrayIDX = lookupArrayItem(fields, myFieldID, "id");
				// Depending on marking, you either need their answer, or the correct one XXXX
				// v6.3.3 marking status has moved to currentItem
				//if (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.MarkingDone) {
				if (_global.ORCHID.session.currentItem.afterMarking) {					
					// Need to get the correct answer, direct lookup (if you ignore alternative corrects)
					// v6.3 But this will not insert m/c pop-ups so they will be left blank.
					// v6.3.5 Now the full pop-up is saved, just for helping here
					stdAnswer = fields[fieldArrayIDX].answer[0].value;
					//myTrace("using correct answers in susbt (" + stdAnswer + ")");
				} else {
					// v6.3.5 pop-ups treated specially in printing - we have saved the pop-up contents
					//myTrace("view.4696.stdAnswer=" + stdAnswer);
					//myTrace("view.4696.fieldType=" + fields[fieldArrayIDX].type);
					if (fields[fieldArrayIDX].type == "i:popup") {
						stdAnswer = fields[fieldArrayIDX].answer[0].value;
					} else {
						// Need to get the typed answer, so what is the group?
						myGroupID = fields[fieldArrayIDX].group;
						//trace("so group ID=" + myGroupID);
						// and its index?
						groupArrayIDX = lookupArrayItem(groups, myGroupID, "id");
						// so now look up the student's answer
						//v 6.3.4 Move attempt from group to field
						//stdAnswer = groups[groupArrayIDX].attempt.finalAnswer;
						stdAnswer = fields[fieldArrayIDX].attempt.finalAnswer;
					}
					// v6.3.4 If the field is not filled in with an answer, it might be special, or unanswered
					if (stdAnswer == undefined) {
						// v6.3.5 printing - drops just show as one space. Do I mean i:drop here rather than drag?
						//if (fields[fieldArrayIDX].type == "i:drag" || fields[fieldArrayIDX].type == "i:popup") {
						if (fields[fieldArrayIDX].type == "i:drop" || fields[fieldArrayIDX].type == "i:popup") {
							stdAnswer = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
						} else {
							//stdAnswer = makeString(" ",fields[fieldArrayIDX].info.gapChars);
							stdAnswer = "";
						}
					}
				}
				// v6.3.3 move exercise panels to buttons holder
				//_root.exerciseHolder.createTextField ("fieldTest", _global.ORCHID.testDepth, 0 , 0 , 10 , 10);
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.createTextField ("fieldTest", _global.ORCHID.testDepth, 0 , 0 , 10 , 10);
				var myTestGap = _global.ORCHID.root.buttonsHolder.ExerciseScreen.fieldTest;
				myTestGap._visible = false;
				myTestGap.html = false;
				myTestGap.border = true;
				myTestGap._focusrect = false;
				myTestGap.wordWrap = false;
				myTestGap.multiline = false;
				myTestGap._xscale = 100;
				myTestGap._yscale = 100;
				myTestGap.autoSize = true;
				// v6.2 - preset the text format that will be used through out
				// Note - you really need to pick this up from something like the normal style in the exercise.
				TF = new TextFormat("Verdana", 10);
				myTestGap.setNewTextFormat(TF);
				myTestGap.text = makeString(" ",fields[fieldArrayIDX].info.gapChars); // the size of the empty gap
				var fieldWidth = myTestGap._width;
				myTestGap.text = stdAnswer;
				var spaces = 0;
				while(myTestGap._width <= fieldWidth) {
					myTestGap.text += " ";
					spaces++;
				}
				//myTrace("turned [" + stdAnswer + "]");
				stdAnswer += makeString("&nbsp;",spaces);
				//myTrace("into     [" + stdAnswer + "]");

				// v6.3.4 You need to specially underline all answers
				stdAnswer = "<u>" + stdAnswer + "</u>";
				// and create the susbstitution
				//myTrace("replace " + "["+myFieldID+"]" + " with " + stdAnswer);
				substArray.push({tag:"["+myFieldID+"]", text:stdAnswer});
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.fieldTest.removeTextField();
				delete myTestGap;
			} else {
				// if not, just ignore the opening brace, clearly it is not part of a field
				k = j;
			}
			// move to the char after the field to find the next opening brace
			j = rawText.indexOf("[", k);
		}
	}
	return substArray;
}

View.prototype.cmdRandomTest = function(component) {
	// v6.2 You might call this from an exercise, so clear out any exercise that is showing
	//_global.ORCHID.viewObj.clearScreen("ExerciseScreen");
	// DO you mean to just hide the screen, or are you looking to actually clear it?
	// v6.3.6 Merge exercise into main
	//myTrace("before clearing question="+_global.ORCHID.session.currentItem.numOfQuestions);
	_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
	//_global.ORCHID.viewObj.clearScreen("MenuScreen");
	// why doesn't the above work properly?? Well, it seems the actual menu items are not on the menu screen!
	//_global.ORCHID.root.menuHolder.clearMenu();
	
	//myTrace("clicked to create a random test");
	// EGU - don't use push button as means of sending content holder reference
	// This is all quite nasty - maybe you should pass the whole window to the function?
	// Or if not, then just an array of selected items? Otherwise the next function has to 
	// know an awful lot about the interface.
	//_global.ORCHID.root.creationHolder.creationNS.generateTest(component);
	// v6.3.4 switch progress to buttons holder
	//var contentHolder = _root.progressHolder.testMaker_dp.getScrollContent();
	//var numOfQuestions = _root.progressHolder.testMaker_dp.numQuestions.numQuestionsSlider.getIntValue();
	//v6.4.2 change scope
	// v6.4.2.7 CUP merge
	// Try making CUP a standard PUW
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/AGU") >= 0) {
		var contentHolder = _global.ORCHID.root.buttonsHolder.MessageScreen.testMaker_SP.getContent().unitNames;
		var numOfQuestions = _global.ORCHID.root.buttonsHolder.MessageScreen.testMaker_SP.numQuestions.numQuestionsSlider.getIntValue();
	} else {
		var contentHolder = _global.ORCHID.root.buttonsHolder.MessageScreen.testMaker_SP.getContent();
		var numOfQuestions = _global.ORCHID.root.buttonsHolder.MessageScreen.testMaker_SP.numQuestions.numQuestionsSlider.getIntValue();
	}
	//_global.ORCHID.root.creationHolder.creationNS.generateTest(component);
	myTrace("randomTest of "+numOfQuestions +" questions from " + contentHolder);
	// v6.3.6 Merge creation into main
	//_global.ORCHID.root.creationHolder.creationNS.generateTest(contentHolder, numOfQuestions);
	_global.ORCHID.root.mainHolder.creationNS.generateTest(contentHolder, numOfQuestions);
	//_root.progressHolder.removeMovieClip();
	// v6.3.5 You need to note in currentItem that this is NOT a regular exercise
	// but not here, I guess something like overwrites this
	//_global.ORCHID.session.currentItem == "test";
}

// display rule text
View.prototype.cmdRule = function(component) {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	// Does this reload the file EVERY time that the button is pressed?
	// It does seem sensible not to load at first since they might not need it,
	// but we certainly wouldn't want to reload each time.
	// See ReadingText example once working.
	//var fileName = _global.ORCHID.paths.root + _global.ORCHID.paths.exercises + _global.ORCHID.LoadedExercises[0].rule;
	if (_global.ORCHID.LoadedExercises[0].ruleEnabledFlag & _global.ORCHID.enabledFlag.edited){
		//myTrace("which & with " + _global.ORCHID.enabledFlag.edited);
		var fileName = _global.ORCHID.paths.editedExercises + _global.ORCHID.LoadedExercises[0].rule;
	} else {
		var fileName = _global.ORCHID.paths.exercises + _global.ORCHID.LoadedExercises[0].rule;
	}
	var RuleXML = new XML();
	RuleXML.ignoreWhite = true;
	RuleXML.onLoad = function(success) {
		processRuleXML = function(RuleTextXML) {
			var CurrentText = new _global.ORCHID.root.objectHolder.ExerciseObject();
			//_global.ORCHID.LoadedExercises[2] is used for storing rule text object
			_global.ORCHID.LoadedExercises[2] = CurrentText;
			CurrentText.rawXML = RuleTextXML;
			myCallBack = function() {
				var substList = new Array();
				var thisText = _global.ORCHID.LoadedExercises[2].body.text
				completeDisplayCallback = function() {
					//_global.ORCHID.tlc.controller.removeMovieClip();
					//delete _global.ORCHID.tlc;
				}
				_global.ORCHID.tlc = {proportion:100,  // what % of the progress bar should this section account for?
					startProportion:0, 
					callBack:completeDisplayCallback}
				_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, "drag pane", "Rule_SP", substList);
			}
			// passing 2 into populateFromXML means processing a rule text xml
			CurrentText.populateFromXML(myCallBack, 2);
		}
		if (success) {
			myTrace("load rule text xml successfully");
			processRuleXML(this);
		} else {
			myTrace("fail to load rule text xml " + this.status);
		}
	}
	myTrace("load rule text: " + fileName);
	RuleXML.load (fileName);
}
// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
// display related text
View.prototype.cmdRelated = function(component) {
	//myTrace("show related text like a rule");
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	if (_global.ORCHID.LoadedExercises[0].relatedEnabledFlag & _global.ORCHID.enabledFlag.edited){
		//myTrace("which & with " + _global.ORCHID.enabledFlag.edited);
		var fileName = _global.ORCHID.paths.editedExercises + _global.ORCHID.LoadedExercises[0].related;
	} else {
		var fileName = _global.ORCHID.paths.exercises + _global.ORCHID.LoadedExercises[0].related;
	}
	//myTrace("related file is " + fileName);
	var RelatedXML = new XML();
	RelatedXML.ignoreWhite = true;
	RelatedXML.onLoad = function(success) {
		processRelatedXML = function(RelatedTextXML) {
			var CurrentText = new _global.ORCHID.root.objectHolder.ExerciseObject();
			//_global.ORCHID.LoadedExercises[3] is used for storing related text object
			_global.ORCHID.LoadedExercises[3] = CurrentText;
			CurrentText.rawXML = RelatedTextXML;
			myCallBack = function() {
				var substList = new Array();
				var thisText = _global.ORCHID.LoadedExercises[3].body.text
				completeDisplayCallback = function() {
					//_global.ORCHID.tlc.controller.removeMovieClip();
					//delete _global.ORCHID.tlc;
				}
				_global.ORCHID.tlc = {proportion:100,  // what % of the progress bar should this section account for?
					startProportion:0, 
					callBack:completeDisplayCallback}
				_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, "drag pane", "Related_SP", substList);
			}
			// passing 3 into populateFromXML means processing a related text xml
			CurrentText.populateFromXML(myCallBack, 3);
		}
		if (success) {
			myTrace("load related text xml successfully");
			processRelatedXML(this);
		} else {
			myTrace("fail to load related text xml " + this.status);
		}
	}
	myTrace("load related text: " + fileName);
	RelatedXML.load (fileName);
}
// v6.3 A special button way to get at reading texts - created for TB.com
// display rule text
// v6.4.3 use this for pop-up text boxes (like targets, but no marking)
// v6.5 But what if you have come from a button component? Can still happen.
View.prototype.cmdReadingText = function(component) {
	//myTrace("view.cmdReadingText for " + component);
	_global.ORCHID.viewObj.displayReadingText();
}
//View.prototype.cmdReadingText = function(textID) {
View.prototype.displayReadingText = function(textID) {
	myTrace("view.displayReadingText for " + textID);
// v6.3.4 move ReadingText into <texts> node
/*
	myTrace("cmdReadingText");
	if (_global.ORCHID.LoadedExercises[1].body.text != undefined) {
		// The reading text should have been read in earlier (to LoadedExercises[1])
		// so this should simply have to display it
		myTrace("readingText already loaded");
		var substList = new Array();
		var thisText = _global.ORCHID.LoadedExercises[1].body.text
		_global.ORCHID.tlc = {proportion:100,	startProportion:0}
		_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, "drag pane", "ReadingText_SP", substList);
	} else {
		var fileName = _global.ORCHID.paths.root + _global.ORCHID.paths.exercises + _global.ORCHID.LoadedExercises[0].readingText.file;
		myTrace("need to load readingText from: " + fileName);
		var ReadingTextXML = new XML();
		ReadingTextXML.ignoreWhite = true;
		ReadingTextXML.onLoad = function(success) {
			processReadingTextXML = function(ReadingTextXML) {
				var niceName = _global.ORCHID.LoadedExercises[0].readingText.name;
				var CurrentText = new _global.ORCHID.root.objectHolder.ExerciseObject();
				//_global.ORCHID.LoadedExercises[1] is used for storing reading text object
				_global.ORCHID.LoadedExercises[1] = CurrentText;
				CurrentText.rawXML = ReadingTextXML;
				myCallBack = function() {
					var substList = new Array();
					var thisText = _global.ORCHID.LoadedExercises[1].body.text
					completeDisplayCallback = function() {
						//_global.ORCHID.tlc.controller.removeMovieClip();
						//delete _global.ORCHID.tlc;
					}
					_global.ORCHID.tlc = {proportion:100,  // what % of the progress bar should this section account for?
						callBack:completeDisplayCallback}
					_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, "drag pane", "ReadingText_SP"+niceName, substList);
				}
				// passing 1 into populateFromXML means processing a reading text xml
				CurrentText.populateFromXML(myCallBack, 1);
			}
			if (success) {
				myTrace("load reading text xml successfully");
				processReadingTextXML(this);
			} else {
				myTrace("fail to load reading text xml " + this.status);
			}
		}
		myTrace("load reading text: " + fileName);
		ReadingTextXML.load (fileName);
	}
*/
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	//myTrace("show a reading text");
	
	var me = _global.ORCHID.LoadedExercises[0];
	// At the end of exerciseNS.display we clear out the tlc. So not straight forward to use it here.
	_global.ORCHID.tlc = {proportion:0, startProportion:0};
	// v6.3.5 Countdown preview will use the regular body as if it were a reading text
	if (me.settings.exercise.type == "Countdown") {
		//myTrace("countdown reading text, so use main text");
		var thisText = me.body.text;
		var onCloseCountdownPreview = function() {
			//myTrace("end of countdown preview")
			var closeCountdownPreview = function() {
				//myTrace("hey, close, so now visible the countdown controller");
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController._visible = true;
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.cdStats_pb.setEnabled(false);
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.word_i.setEnabled(true);
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.cdGuess_lbl.setEnabled(true);
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.cdGuessWord_pb.setEnabled(true);
				// clear out any old stuff
				myTrace("also try to remove old guesses");
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.guessList_cb.removeAll();
				// v6.5 Can you also blitz the media controller since you get problems if you try to basically repeat the display
				// with, I suppose, duplicated fieldIDs. These are copied from exercise.as
				_global.ORCHID.root.jukeboxHolder.myJukeBox.clearAll();
				_global.ORCHID.root.jukeboxHolder.resourcesList.removeMovieClip();
				// v6.4.2.5 Also init the jukebox.
				_global.ORCHID.root.jukeboxHolder.myJukeBox.initProperties();

			}
			_global.ORCHID.root.buttonsHolder.ExerciseScreen["ReadingText_SP"].setCloseHandler(closeCountdownPreview)
		}

		_global.ORCHID.tlc.callback = onCloseCountdownPreview;
		_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadPreview", "labels"));
		var paneName = "ReadingText_SP" + _global.ORCHID.literalModelObj.getLiteral("previewRubric", "labels");
		// v6.4.3 I want to be able to set the box to neatly cover the exercise, can I do that here? Yes.
		var coords = {x:5, 
					y:_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y, 
					width:_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width, 
					// v6.5.4.3 Need to cover the whole exercise screen
					//height:_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height-50};
					height:_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height,
					maxH:_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height
					};
		var substList = new Array();
		_global.myTrace("pane width=" + coords.width + " height=" + coords.height);
	} else {
		// get the texts id from the media thing
		// v6.4.3 I might pass the ID now
		if (textID==undefined) {
			myTrace("no ID passed so use readingText.id of " + me.readingText.id);
			var textArrayIDX = lookupArrayItem(me.texts, me.readingText.id, "ID");
		} else {
			var textArrayIDX = lookupArrayItem(me.texts, textID, "ID");
		}
		//myTrace("found text idx "+textArrayIDX);
		if (me.texts[textArrayIDX].text.paragraph.length>0){
			myTrace("got the reading text");
			var thisText = me.texts[textArrayIDX].text;
			//trace(thisFeedback.toString());
			// v6.4.2.8 And see how wide you need it to be based on the paragraphs in the text
			var thisMaxWidth = 0;
			for (var i in thisText.paragraph) {
				//myTrace("para.width=" + thisText.paragraph[i].coordinates.width);
				if (thisText.paragraph[i].coordinates.width > thisMaxWidth) {
					thisMaxWidth = thisText.paragraph[i].coordinates.width;
					//myTrace("width=" + thisMaxWidth);
				}
			}
			// Then the the min width is 180. 

			// v6.5.5.8 Allow thinner windows
			// v6.5.5.8 And CP wants them over on the right hand side of the screen
			// So you'll have to work out what the width is so you can set the x to still be visible.
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
				_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
				var rightSide = 760;
				var windowX = rightSide - thisMaxWidth - 70;
				var coords={x:windowX, y:154, width:thisMaxWidth, height:340, minW:180};
			// As SSS has icons on the left, shift the fixed position windows right a bit
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
				var coords={x:100, y:140, width:thisMaxWidth, height:300, minW:180};
			} else {
				//var coords={x:16, y:127, width:thisMaxWidth, height:300}
				var coords={x:16, y:127, width:thisMaxWidth, height:300, minW:180};
			}
		} else {
			myTrace("no reading text");
			return false;
		}
		_global.ORCHID.root.tlcController.setLabel("load text...");
		// v6.5.5.8 Pass through the nice name from the texts node
		var paneName = "ReadingText_SP" + me.texts[textArrayIDX].name;
		//var paneName = "ReadingText_SP";
		//var coords = null;
		var substList = new Array();
	}
	//_global.ORCHID.root.tlcController.setLabel("feedback");
	//_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadPreview", "labels"));
	putParagraphsOnTheScreen(thisText, "drag pane", paneName, substList, coords);
}

// v6.5.4.3 Add a popup for the video script. No need to pass anything.
//View.prototype.displayVideoScript = function(textID) {
View.prototype.displayVideoScript = function() {
	myTrace("view.displayVideoScript");
	
	var me = _global.ORCHID.LoadedExercises[0];
	// At the end of exerciseNS.display we clear out the tlc. So not straight forward to use it here.
	_global.ORCHID.tlc = {proportion:0, startProportion:0};
	// get the texts id from the media thing
	// v6.4.3 I might pass the ID now
	//if (textID==undefined) {
		myTrace("use readingText.id of " + me.readingText.id);
		var textArrayIDX = lookupArrayItem(me.texts, me.readingText.id, "ID");
	//} else {
	//	var textArrayIDX = lookupArrayItem(me.texts, textID, "ID");
	//}
	//myTrace("found text idx "+textArrayIDX);
	if (me.texts[textArrayIDX].text.paragraph.length>0){
		myTrace("got the reading text");
		var thisText = me.texts[textArrayIDX].text;
		//trace(thisFeedback.toString());
		// v6.4.2.8 And see how wide you need it to be based on the paragraphs in the text
		var thisMaxWidth = 0;
		for (var i in me.texts[textArrayIDX].text.paragraph) {
			if (me.texts[textArrayIDX].text.paragraph[i].coordinates.width > thisMaxWidth) {
				thisMaxWidth = me.texts[textArrayIDX].text.paragraph[i].coordinates.width;
				myTrace("width=" + thisMaxWidth);
			}
		}
		//var coords={x:16, y:127, width:thisMaxWidth, height:300}
		var coords={x:16, y:160, width:270, height:300, minW:270, minH:300};
	} else {
		myTrace("no reading text");
		return false;
	}
	_global.ORCHID.root.tlcController.setLabel("load text...");
	var paneName = "ReadingText_SP" + me.readingText.name;
	//var coords = null;
	var substList = new Array();
	putParagraphsOnTheScreen(thisText, "drag pane", paneName, substList, coords);
}

// v6.3.4 new command for pop-up texts (SSS tip)
View.prototype.cmdTip = function() {
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	//myTrace("show a tip");
	var me = _global.ORCHID.LoadedExercises[0];
	// get the tip ID from the media thing - SSS, just find the first non-reading text <texts> node
	var thisTextID = 0;
	for (var i in me.body.text.media) {
		if (me.body.text.media[i].type == "m:text" && me.body.text.media[i].mode != _global.ORCHID.mediaMode.ReadingText) {
			myTrace("tip id=" + me.body.text.media[i].id);
			thisTextID = me.body.text.media[i].id;
			break;
		}
	}
	if (thisTextID > 0) {
		var textArrayIDX = lookupArrayItem(me.texts, thisTextID, "ID");
	} else {
		// if nothing was found, simply use the first one - but this should not be the case
		// NO this is not a good idea as you will get ... hmmm. Actually the checking will be done
		// in screen to tell if to display the button or not.
		var textArrayIDX = 0;
	}
	//myTrace("found tip idx "+textArrayIDX);
	if (me.texts[textArrayIDX].text.paragraph.length>0){
		//myTrace("got the tip");
		var thisText = me.texts[textArrayIDX].text;
		//trace(thisFeedback.toString());
	} else {
		myTrace("no such tip");
		var noTextNote = {style:"normal", coordinates:{x:"+0", y:"+0", width:"360"}};
		//noHintNote.plainText = "Sorry, there is no hint for this question.";
		// 6.0.4.0, take the no hint message from literal model
		noTextNote.plainText = '<font face="Verdana" size="12">' + _global.ORCHID.literalModelObj.getLiteral("noHint", "messages") + '</font>';
		var thisText = {paragraph:[noTextNote]};
	}
	// clear out the controller, 
	_global.ORCHID.tlc = {proportion:100, startProportion:0};
	var substList = new Array();
	putParagraphsOnTheScreen(thisText, "drag pane", "Related_SP", substList);
}
// v6.3.4 new command for weblinks
View.prototype.cmdWeblink = function() {
	// v6.5.1 Yiu Force the recorder to stop
	_global.ORCHID.viewObj.stopRecording();
	
	// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
	// so we should do it for it.
	// v6.3.4 No longer - correctly handled by the selection listener
	//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
	//	//trace("doing the last insert");
	//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
	//	_global.ORCHID.session.currentItem.lastGap = undefined;
	//}
	myTrace("show a weblink");
	var me = _global.ORCHID.LoadedExercises[0].body.text;
	for (var i in me.media) {
		// for now just link to the first url you find - or maybe the first with no x coordinate?
		// v6.4.2.7 Use the better attribute
		//var thisMedia = me.media[i].filename;
		//var thisMedia = me.media[i].url;
		if (me.media[i].type == "m:url" && me.media[i].coordinates.x == undefined) {
			var thisMedia = _global.ORCHID.viewObj.checkWeblink(me.media[i].url)
			myTrace("link to=" + thisMedia);
			if (_global.ORCHID.projector.name=="MDM") {
				//myTrace("use mdm.getURL;")
				mdm.geturl(thisMedia); 
			} else {
				getURL(thisMedia, "_blank");
			}
			break;
		}
	}
	// v6.5 It is possible that the media node is in <texts> not body (for split screen). So search there too.
	if (thisMedia == undefined) {
		me = _global.ORCHID.LoadedExercises[0].texts[0].text;
		for (var i in me.media) {
			// for now just link to the first url you find - or maybe the first with no x coordinate?
			// v6.4.2.7 Use the better attribute
			//var thisMedia = me.media[i].filename;
			//var thisMedia = me.media[i].url;
			if (me.media[i].type == "m:url" && me.media[i].coordinates.x == undefined) {
				var thisMedia = _global.ORCHID.viewObj.checkWeblink(me.media[i].url)
				myTrace("link to=" + thisMedia);
				if (_global.ORCHID.projector.name=="MDM") {
					//myTrace("use mdm.getURL;")
					mdm.geturl(thisMedia); 
				} else {
					getURL(thisMedia, "_blank");
				}
				break;
			}
		}
	}
}
// v6.4.2.7 Function to change a weblink from internet to local
View.prototype.checkWeblink = function(thisMedia) {
	// v6.4.3 You may just want to link to a local document - in which forget all this domain nonsense
	// v6.4.2.4 Allow our existing paths to be used here
	// Example: filename=#brandMovies#certificate.swf
	//myTrace("filename=" + me.filename + " brandMovies=" + _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies));
	if (thisMedia.indexOf("#brandMovies#")>=0) {
		myTrace("replacing brandMovies");
		thisMedia = findReplace(thisMedia, "#brandMovies#", _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies));
	} else if (thisMedia.indexOf("#mediaFolder#")>=0) {
		myTrace("replacing mediaFolder");
		if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
			var myFolder = _global.ORCHID.paths.editedMedia;
		} else {
			var myFolder = _global.ORCHID.paths.media;
		}
		thisMedia = findReplace(thisMedia, "#mediaFolder#", _global.ORCHID.functions.addSlash(myFolder));
	} else if (thisMedia.indexOf("#exerciseFolder#")>=0) {
		myTrace("replacing exerciseFolder");
		// v6.4.2.5 Media is always read from MGS (which defaults to content if none)
		//me.filename = findReplace(me.filename, "#contentFolder#", _global.ORCHID.functions.addSlash(_global.ORCHID.paths.content));
		if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
			var myFolder = _global.ORCHID.paths.editedExercises;
		} else {
			var myFolder = _global.ORCHID.paths.exercises;
		}
		thisMedia = findReplace(thisMedia, "#exerciseFolder#", _global.ORCHID.functions.addSlash(myFolder));
	} else if (thisMedia.indexOf("#sharedMedia#")>=0) {
		myTrace("replacing sharedMedia");
		thisMedia = findReplace(thisMedia, "#sharedMedia#", _global.ORCHID.functions.addSlash(_global.ORCHID.paths.sharedMedia));
	} else if (thisMedia.indexOf("#streamingMedia#")>=0) {
		myTrace("replacing streamingMedia");
		// v6.5.5.5 Slight change to steaming media path name
		thisMedia = findReplace(thisMedia, "#streamingMedia#", _global.ORCHID.functions.addSlash(_global.ORCHID.paths.streamingMediaFolder));
	} else {
		// v6.4.2.7 If you are a special CD (like Study Skills Succes or Business Writing), then if you are not
		// connected to the internet you should read the weblink from the CD instead (if you are going through a projector - or actionscript?)
		// We will have already detected an internet connection on startup - so use that (too bad if you connect whilst running)
		// v6.4.2.7, but Vista doesn't tell you correctly if connected - and you don't want to do anything if you are Author Plus
		if (	_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/BW") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/SSS") >= 0) {
			// Just for debugging
			//_global.ORCHID.projector.internetConnection = false;
			//_global.ORCHID.projector.name="MDM";
			// v6.5.5.9 new name that works for non projectors
			//myTrace("network internetConnection=" + _global.ORCHID.projector.internetConnection);
			myTrace("network internetConnection=" + _global.ORCHID.commandLine.isConnected);
			if (	(_global.ORCHID.projector.name=="MDM" && !_global.ORCHID.commandLine.isConnected) ||
				(_global.ORCHID.root.licenceHolder.licenceNS.scripting.toLowerCase() == "actionscript")){
				//myTrace("should we look locally?");
				// OK - so I am in one of the special programs that have their websites on file. 
				// I also know that I am on a network or running actionscript, and I don't think I am internet connected
				// The final test is to confirm that this URL is one of our originals, not an authored exercise
				var stripThisDomain = false;
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/BW") >= 0) {
					if (thisMedia.toLowerCase().indexOf("businesswriting/weblinks")>=0) {
						//myTrace("yes as BW link");
						var stripThisDomain = true;
					}
				}
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/SSS") >= 0) {
					if (thisMedia.toLowerCase().indexOf("studyskillssuccess.com")>=0) {
						//myTrace("yes as SSS link");
						var stripThisDomain = true;
					}
				}
				//myTrace("thisMedia=" + thisMedia);
				// Strip the domain and add something like file:\\website
				if (stripThisDomain && (	thisMedia.toLowerCase().indexOf("http")==0 || 
										thisMedia.toLowerCase().indexOf("www")==0)) {
					//myTrace("yes as begins http or www");
					// find the first dot, then the next slash. Assume that this is the domain and remove it
					var firstDot = thisMedia.indexOf(".");
					var domainSlash = thisMedia.indexOf("/", firstDot);
					// v6.4.2.7 except that we might have more than just the domain to strip
					// www.studyskillssuccess.com/Speaking.html - this is fine
					// But
					// www.ClarityEnglish.com/BusinessWriting/Weblinks/The writing process.html needs to lose the first two folders too
					if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/BW") >= 0) {
						domainSlash = thisMedia.indexOf("/", domainSlash+1);
						domainSlash = thisMedia.indexOf("/", domainSlash+1);
					}
					var remainingURL = thisMedia.substr(domainSlash+1);
					myTrace("strip domain to give " + remainingURL);
					// Note that when you are running under projector, paths.root is the location of the exe. 
					// But running in the browser gives paths.root as location of control.swf. Very different.
					if (_global.ORCHID.projector.name=="MDM") {
						//myTrace("add root " + _global.ORCHID.paths.root);
						// v6.4.2.8 If I pass d:\clarity\weblinks\linkingideas.html?lang=51 then IE doesn't pick it up. What if I use file://d: etc?
						// At this point I know I have a special link, and I am running the projector and I am not going to the internet so it should be safe
						//var addRoot = _global.ORCHID.paths.root;
						var addRoot = "file:\\\\" + _global.ORCHID.paths.root;
					} else {
						// We have to assume that we always pass &userDataPath as a variable to the projector
						// If for some reason it is not defined we will just use the control.swf folder anyway.
						//myTrace("add root " + _global.ORCHID.commandLine.userDataPath);
						var addRoot = _global.ORCHID.commandLine.userDataPath;
					}
					thisMedia = _global.ORCHID.functions.addSlash(addRoot) + _global.ORCHID.functions.addSlash("Weblinks") + remainingURL;
				}
			} else {
				// v6.4.2.4 If you are running from a CD, you need the full path. So if you have any relative path, add the root to it
				// But this screws up web URLs that don't start http: Maybe you should just check for ..  Hmmmm
				if ((thisMedia.indexOf("http:")>=0) || (thisMedia.indexOf("file:")>=0) || (thisMedia.indexOf("\\")==0) || (thisMedia.indexOf("/")==0)) {
				} else {
					thisMedia = _global.ORCHID.paths.root + thisMedia;
				}
			}
			// v6.4.2.8 The BW links to specific downloads are language dependent, but Indian English uses the same XML as InternationalEnglish
			// so override the folder name here. I don't like this much for the hard-coding, but it does seem very specific.
			// v6.4.2.8 But I also need BusinessWriting/Demo/Weblinks
			myTrace("before changing folders, media=" + thisMedia);
			if (thisMedia.toLowerCase().indexOf("businesswriting")>=0 && thisMedia.toLowerCase().indexOf("weblinks")>=0) {
				// v6.4.2.8 lower case means lower case!!
				//if (_global.ORCHID.session.courseID == 52 && thisMedia.toLowerCase().indexOf("/IntlEng/")>0) {
				myTrace("it is bw weblinks");
				if (_global.ORCHID.session.courseID == 52 && thisMedia.indexOf("/IntlEng/")>0) {
					myTrace("it is NAmEng")
					thisMedia = findReplace(thisMedia, "/IntlEng/", "/NAmEng/");
				//} else if (_global.ORCHID.session.courseID == 53 && thisMedia.toLowerCase().indexOf("/IntlEng/")>0) {
				} else if (_global.ORCHID.session.courseID == 53 && thisMedia.indexOf("/IntlEng/")>0) {
					thisMedia = findReplace(thisMedia, "/IntlEng/", "/IndianEng/");
				}
			}
			// v6.4.2.8 Also add the language version (embedded in the courseID) as a parameter to our special weblinks
			// v6.4.2.8 Except that this will also get added to resources, which we don't really want. So add extra clause, that these special weblinks
			// must match. Is this something we generally want to do, pass the course ID to a weblink? Probably not. Should just
			// be for our specific ones. www.ClarityEnglish.com/BusinessWriting/Weblinks/xxx.html
			if (	((thisMedia.toLowerCase().indexOf("businesswriting")>=0 && thisMedia.toLowerCase().indexOf("weblinks")>=0) ||
				thisMedia.toLowerCase().indexOf("studyskillssuccess.com")>=0) && 
				thisMedia.toLowerCase().indexOf(".html")>0) {
					var addedParameter = "?lang=" + _global.ORCHID.session.courseID;
			}
			thisMedia+=addedParameter;
		}
	}
	return thisMedia;	
}

View.prototype.cmdLogin = function() {
	//myTrace("cmdLogin");
	// v6.2 Error - if self-register is 0 then you cannot do anything!
	var loginbox = _global.ORCHID.root.buttonsHolder.LoginScreen;
	var i_name = loginbox.i_name.text;
	var i_studentID = loginbox.i_studentID.text;
	var i_password = loginbox.i_password.text;
	//myTrace("login; name._visible=" + loginbox.i_name._visible + " name=" + i_name);
	//myTrace("login; id._visible=" + loginbox.i_studentID._visible + " id=" + i_studentID);
	// v6.3 Separate test for anonymous login
	//if (_global.ORCHID.programSettings.selfRegister == 0) {
	// So, first of all, are the fields blank?
	if ((loginbox.i_name._visible && (i_name == "")) ||
  	    (loginbox.i_studentID._visible && (i_studentID == ""))) {
		//myTrace("the fields are blank");
		// but if this isn't allowed, send a message
		if (_global.ORCHID.programSettings.loginOption & _global.ORCHID.accessControl.ACAllowAnonymous) {
			//myTrace("but that is OK");
		} else {
			//myTrace("cannot allow anon");
			//_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = "Sorry, the name and/or ID cannot be blank.";
			loginbox.messageStatus = "blankNameID";
			loginbox.message_txt.text = _global.ORCHID.literalModelObj.getLiteral("blankNameID", "messages");
			return;
		}
	}
	// v6.3 You really want to disable the button that called this - or at least make it ineffective
	// so that you cannot call it twice through double clicking or impatience.
	//myTrace("disable " + loginbox.loginBtn);
	// There should be a better way to disable all buttons on a screen
	loginbox.loginBtn.setEnabled(false);
	loginbox.newUserBtn.setEnabled(false);
	// v6.3.5 clear the status text before any processing
	loginbox.message_txt.text = "";
	_global.ORCHID.user.startUser(i_name, i_password, i_studentID);
}

// v6.5.4.6 Add in a function to let the student change their password. It will do all the initial stages of startUser but then direct you to a 
// change password screen once you are in. You can't do it unless your full login (including allocation/licence) succeeds.
View.prototype.cmdPasswordScreen = function() {
	myTrace("cmdPasswordScreen");
	_global.ORCHID.programSettings.requestPasswordChange = true;
	_global.ORCHID.viewObj.cmdLogin();
}
View.prototype.cmdChangePassword = function() {
	myTrace("cmdChangePassword");
	var passwordbox = _global.ORCHID.root.buttonsHolder.PasswordScreen;
	var i_password = passwordbox.i_password.text;
	var i_confirmPassword = passwordbox.i_confirmPassword.text;
	// First, check to see if the two typed passwords are the same. Exactly.
	if (i_password == i_confirmPassword) {
	} else {
		passwordbox.messageStatus = "passwordsDifferent";
		var substList = [{tag:"[newline]", text:newline}];
		passwordbox.message_txt.text = substTags(_global.ORCHID.literalModelObj.getLiteral("passwordsDifferent", "messages"), substList);
		return;
	}
	// Are they allowed to be empty? Yes - this means I don't want to change it anymore!
	if (i_password == "") {
		_global.ORCHID.user.broadcastMessage("userEvent", "onPasswordChanged");
		return;
	} 
	// Should I check to see if this matches any other name/password combo? For now, no.
	
	// otherwise lets actually update it
	_global.ORCHID.user.changePassword(i_password);
}

// v6.3 The user clicks "new user" on the login screen
// If it turns out that RM only wants the information that is already on the login screen then
// there is no need to go to the register screen at all.
// v6.3.2 Add parameter to allow callback from licencing check - will only be true after callback
// v6.5.1 BUG. If this function is set as the target of onRelease in the FGraphicButton, then it will be passed a reference to itself.
// So this appears to be 'allowed' thus we never check the user count.
//View.prototype.cmdNewUser = function (allowed) {
View.prototype.cmdNewUser = function (selfReference, allowed) {
	myTrace("cmdNewUser, allowed=" + allowed);

	// v6.4 You really want to disable the button that called this - or at least make it ineffective
	// so that you cannot call it twice through double clicking or impatience.
	//myTrace("disable " + loginbox.loginBtn);
	// There should be a better way to disable all buttons on a screen
	var loginbox = _global.ORCHID.root.buttonsHolder.LoginScreen;
	loginbox.newUserBtn.setEnabled(false);
	loginbox.loginBtn.setEnabled(false);
	//myTrace("hidden the buttons");

	// v6.5.3 This call has to be duplicated if you are deciding whether to allow a validated user to be added
	// from SCORM or similar directLink. You could put it all in addNewuser, except that would be a pain if you
	// took someone through the registratin screen only to tell them that there is no space. So, for now anyway,
	// do the duplication.
	//v6.3.2 Only allowed to add new users in total licencing after checking the db
	// V6.5.5.0 Update from addNewUserCheck
	// v6.5.5.5 Add network as a licence type that can always add new users
	if (_global.ORCHID.root.licenceHolder.licenceNS.licenceType==3) allowed = true;
	// v6.5.5.5 change names
	//if (_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("total") >= 0) {
	//if (	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("total") >= 0 ||
	//	_global.ORCHID.root.licenceHolder.licenceNS.licencing.toLowerCase().indexOf("tracking") >= 0) {
	if (_global.ORCHID.root.licenceHolder.licenceNS.licenceType==1 || _global.ORCHID.root.licenceHolder.licenceNS.licenceType==3) {
		// v6.5.1 Lets be very specific about it
		//if (allowed == undefined || allowed == false) {
		if (allowed <> true) {
			myTrace("make the total users check");
			// The check hasn't been done, so do it and callback when it has
			// make a new db query
			// v6.3.6 Merge database to main and change NS anme
			var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
			
			// v6.5.6 Maybe you want to check licences across a set of accounts?
			//myTrace("groupedRoots=" + _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots);
			if (_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots!=undefined 
				&& ((_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots.indexOf(",")>0) || _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots=='*')) {
				// we should try to make sure that the list is well-formed
				if (_global.ORCHID.root.licenceHolder.licenceNS.groupedRoots=='*') {
					rootList='*';
				} else {
					var validRoot=false;
					var rootArray = _global.ORCHID.root.licenceHolder.licenceNS.groupedRoots.split(",");
					for (var i=0; i<rootArray.length; i++) {
						if (!isNaN(parseInt(rootArray[i])) && parseInt(rootArray[i])>=1) {
							validRoot=true;
						} else {
							rootArray[i]=0;
						}
					}
					if (validRoot) {
						var rootList = rootArray.join(",");
					} else {
						var rootList = _global.ORCHID.root.licenceHolder.licenceNS.central.root;
					}
				}
				var myRoot = rootList;
			} else {
				var myRoot = _global.ORCHID.root.licenceHolder.licenceNS.central.root;
			}
			// put the query into an XML object
			//				'rootID="' + _global.ORCHID.root.licenceHolder.licenceNS.central.root + '" ' +
			thisDB.queryString = '<query method="countLicencesUsed" ' +
							'rootID="' + myRoot + '" ' +
							'licences="' + _global.ORCHID.root.licenceHolder.licenceNS.licences + '" ' +
							'productCode="' + _global.ORCHID.root.licenceHolder.licenceNS.productCode + '" ' +
							// v6.5.5.0 For non-transferable licences
							'licenceStartDate="' + _global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate + '" ' +
							'databaseVersion="' + _global.ORCHID.programSettings.databaseVersion + '" ' +
							'cacheVersion="' + new Date().getTime() + '"/>';
			
			thisDB.xmlReceive = new XML();
			//myTrace("make XML from " + this.debugName);
			thisDB.xmlReceive.master = this;
			//thisDB.xmlReceive.onData = function(raw) { myTrace(raw); }
			thisDB.xmlReceive.onLoad = function(success) {
				//myTrace("back to countUsers from asp");
				var errReceived = false;
				// don't make too many assumptions about the format of the returned
				// XML, so look through all nodes to find anything expected
				// and leave unexpected stuff alone
				for (var node in this.firstChild.childNodes) {
					var tN = this.firstChild.childNodes[node];
					//sendStatus("node=" + tN.toString());
					// is there a an error node?
					if (tN.nodeName == "err") {
						errReceived = true;
						myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
						myTrace("no new users can be added");
						if (tN.attributes.code == '211') {
							_global.ORCHID.user.broadcastMessage("userEvent", "onLicenceFull");
						} else {
							_global.ORCHID.user.broadcastMessage("userEvent", "onNoTotalLicences");
						}
						return;
					// we are expecting to get back a number of existing users
					} else if (tN.nodeName == "licence") {
						var numUsers = Number(tN.attributes.users);
						myTrace("there are " + numUsers + " existing users.");
						
					// anything we didn't expect?
					} else {
						myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
					}
				}
				// a successful call will have set users
				myTrace("licensed for " + _global.ORCHID.root.licenceHolder.licenceNS.licences);
				if (numUsers > 0 && !errReceived) {
					if (numUsers < Number(_global.ORCHID.root.licenceHolder.licenceNS.licences)) {
						myTrace("cleared to add the new user");
						// callback to cmdNewUser with the allowed parameter set
						// Need to send a dummy self reference (FGraphicButton dependency)
						//_global.ORCHID.viewObj.cmdNewUser(true);
						_global.ORCHID.viewObj.cmdNewUser(undefined, true);
					} else {
						myTrace("no new users can be added");
						_global.ORCHID.user.broadcastMessage("userEvent", "onNoTotalLicences");
					}
				// v6.5.6 What if nothing came back from the query?
				} else {
					myTrace("count licences query failed");
					var errObj = {literal:"noDBConnection"}; // Nice to find a better message
					_global.ORCHID.root.controlNS.sendError(errObj);
				}
			}
			thisDB.runSecureQuery();
			// since you are still checking, don't go any further now
			// the rest will be done by the callback
			return;
		}
		myTrace("total licencing, but you have already allowed new user adding");
	}

	// Get the information that they have typed here:
	var i_name = _global.ORCHID.root.buttonsHolder.LoginScreen.i_name.text;
	var i_studentID = _global.ORCHID.root.buttonsHolder.LoginScreen.i_studentID.text;
	var i_password = _global.ORCHID.root.buttonsHolder.LoginScreen.i_password.text;
	//
	// What information does RM want?
	// v6.5.4.5 The email and password were the wrong way round!!
	var selfRegister = {Name:1, 
				StudentID:2,
				//Password:4,
				// Class:8,
				//Email:16,
				Email:4,
				Password:16,
				Birthday:32,
				Country:64,
				Company:128,
				Custom1:256,
				Custom2:512,
				Custom3:1024}
	var thisSetting = _global.ORCHID.programSettings.selfRegister;
	var missingLoginInfo = false;
	// if you need name and/or ID and either are blank, go on to register screen
	if (thisSetting & selfRegister.Name) {
		if (_global.ORCHID.root.buttonsHolder.LoginScreen.i_name._visible && (i_name == "")) {
			var missingInfo = true;
			myTrace("name not filled in");
		}
	}
	if (thisSetting & selfRegister.StudentID) {
		if (_global.ORCHID.root.buttonsHolder.LoginScreen.i_studentID._visible && (i_studentID == "")) {
			var missingInfo = true;
			myTrace("ID not filled in");
		}
	}
	// If you need any info that the login screen doesn't have, go on to register screen
	if (thisSetting & selfRegister.Class ||thisSetting & selfRegister.Email || thisSetting & selfRegister.Country ||
		thisSetting & selfRegister.Birthday || thisSetting & selfRegister.Company) {
		var missingInfo = true;
		myTrace("RM wants some other information (" + thisSetting + ")");
	}
	// v6.3 if you don't need to go on, just register this user from here!
	if (! missingInfo) {
		// v6.5.4.5 If you are not using name but just id for login, duplicate the id as the name
		myTrace("so call addNewUser directly from here");
		if ((i_name=="") && 
			(_global.ORCHID.programSettings.loginOption & _global.ORCHID.accessControl.ACStudentIDOnly)) {
			i_name = i_studentID;
		}
		// v6.3.5 clear the status text before any processing
		_global.ORCHID.root.buttonsHolder.LoginScreen.message_txt.text = "";
		//var registerUser = {name:i_name, password:i_password, studentID:i_studentID};
		var registerUser = {name:i_name, password:i_password, studentID:i_studentID, registerMethod:"Orchid"};
		_global.ORCHID.user.addNewUser(registerUser);
	} else {	
		myTrace("go to registration screen");
		//loginNS.setState("register");
		_global.ORCHID.root.buttonsHolder.RegisterScreen.i_name.text = i_name;
		_global.ORCHID.root.buttonsHolder.RegisterScreen.i_studentID.text = i_studentID;
		_global.ORCHID.root.buttonsHolder.RegisterScreen.i_password.text = i_password;
		_global.ORCHID.viewObj.clearScreen("LoginScreen");
		_global.ORCHID.viewObj.displayScreen("RegisterScreen");
	}
}

View.prototype.cmdRegister = function() {
	//trace("register this user");
	var regBox = _global.ORCHID.root.buttonsHolder.RegisterScreen;
	var i_name = regBox.i_name.text;
	var i_studentID = regBox.i_studentID.text;
	var i_password = regBox.i_password.text;
	var i_email = regBox.i_email.text;
	var i_country = regBox.i_country.text;
	
	// First of all, are any of the fields blank?
	if ((regBox.i_name._visible && (i_name == "")) ||
	    (regBox.i_studentID._visible && (i_studentID == "")) ||
// You should be allowed to have a blank password I guess?
//	    (regBox.i_password._visible && (i_password == "")) ||
	    (regBox.i_email._visible && (i_email == "")) ||
  	    (regBox.i_country._visible && (i_country == ""))) {
		myTrace("some of the fields are blank");
		regBox.messageStatus = "blankFields";
		regBox.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(regBox.messageStatus, "messages");
		return;
	}
	// v6.5.4.5 If you are not using name but just id, duplicate the id as the name
	if ((_global.ORCHID.root.buttonsHolder.RegisterScreen.i_name.text=="") && 
		(_global.ORCHID.programSettings.loginOption & _global.ORCHID.accessControl.ACStudentIDOnly)) {
		_global.ORCHID.root.buttonsHolder.RegisterScreen.i_name.text = _global.ORCHID.root.buttonsHolder.RegisterScreen.i_studentID.text;
	}
	
	myTrace("all fields OK, so register");
	var registerUser = {name:_global.ORCHID.root.buttonsHolder.RegisterScreen.i_name.text, 
			password:_global.ORCHID.root.buttonsHolder.RegisterScreen.i_password.text, 
			studentID:_global.ORCHID.root.buttonsHolder.RegisterScreen.i_studentID.text, 
			//className:_global.ORCHID.root.buttonsHolder.RegisterScreen.i_className.text, 
			email:_global.ORCHID.root.buttonsHolder.RegisterScreen.i_email.text, 
			country:_global.ORCHID.root.buttonsHolder.RegisterScreen.i_country.text, 
			registerMethod:"Orchid",
			preferences:_global.ORCHID.root.buttonsHolder.RegisterScreen.i_language.text};

	// 6.0.5.0
	regbox.loginBtn.setEnabled(false);
	// v6.3.5 clear the status text before any processing
	regbox.message_txt.text = "";
	_global.ORCHID.user.addNewUser(registerUser);
}

// v6.2 Break this function down so that you can call it directly, rather than only from
// a particular type of component.
View.prototype.selectCourse = function(component) {
	// v6.4.3 Allow std buttons to be clicked and call this, pass themselves as reference and store the course info
	if (component.courseXML <> undefined) {
		//myTrace("component has XML =" + component);
		var courseXMLNode = component.courseXML;
	} else {
		//myTrace("selectCourse: " + component.getSelectedItem().label);
		//myTrace(courseMenu.getSelectedItem().label + " is selected");
		var courseXMLNode = component.getSelectedItem().data;
	}
	//myTrace(" XML = " + courseXMLNode.toString());
	_global.ORCHID.viewObj.selectCourseInner(courseXMLNode);
}
View.prototype.selectCourseInner = function(courseXMLNode) {
	// v6.5.5.1 For measuring performance
	myTrace("timeHolder.log.startOfFullyLoadedScores");
	_global.ORCHID.timeHolder.beginCourseLoad = new Date().getTime();
	
	// v6.5.5.9 Some Turkish accounts are sold on the basis of one student being able to access 2 or 3 levels
	// without wanting to limit which 2 or 3. So lets do a check here.
	if (_global.ORCHID.root.licenceHolder.licenceNS.courseLimit && _global.ORCHID.root.licenceHolder.licenceNS.courseLimit>0) {
		myTrace("course limit=" + _global.ORCHID.root.licenceHolder.licenceNS.courseLimit + " and started=" + _global.ORCHID.user.startedContent.length);
		// first see if you want to start a course that you have done already, in which case no problem.
		var keepGoing = false;
		for (var i in _global.ORCHID.user.startedContent) {
			if (_global.ORCHID.user.startedContent[i]==courseXMLNode.attributes["id"]) {
				keepGoing = true;
				break;
			}
		}
		if (!keepGoing && _global.ORCHID.user.startedContent.length >= _global.ORCHID.root.licenceHolder.licenceNS.courseLimit) {
			// Sorry, you can't start a new course
			var errObj = {literal:"courseLimitReached", detail:_global.ORCHID.root.licenceHolder.licenceNS.courseLimit};
			_global.ORCHID.root.controlNS.sendError(errObj);
			return;
		}
	}
	
	//trace("firstChild = " +  courseXMLNode.firstChild.toString());
	//trace("node=" + courseXMLNode.toString());
	myTrace("loading courseID=" + courseXMLNode.attributes["id"] + " for branding " + _global.ORCHID.root.licenceHolder.licenceNS.branding); 

	// v6.4.2.8 Hijack for BW and SSS which have different language options which should FORCE the use of matching literals
	// Since you will end up with the default if no EN-NA exists, this seems safe even if other languages are used.
	// v6.5.5.6 This is all handled in the database now
	/*
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/BW") >= 0) {
		var thisCourseID = courseXMLNode.attributes["id"];
		if (thisCourseID == '52') {
			//change to N.American literals (which probably only overrides one or two of the default)
			//_global.ORCHID.literalModelObj.setLiteralLanguage("EN-NA");
			if (_global.ORCHID.literalModelObj.getLiteralLanguage()!="NAMEN") {
				myTrace("BW NAmerican course so switch literals");
				_global.ORCHID.literalModelObj.setLiteralLanguage("NAMEN");
			}
		} else {
			// It would be better to simply go back to the default rather than force to English
			if (_global.ORCHID.literalModelObj.getLiteralLanguage()!="EN") {
				myTrace("BW Intl or Indian course so switch literals");
				_global.ORCHID.literalModelObj.setLiteralLanguage("EN");
			}
		}
	}
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/SSS") >= 0) {
		var thisCourseID = courseXMLNode.attributes["id"];
		if (thisCourseID == '42') {
			//change to N.American literals
			//_global.ORCHID.literalModelObj.setLiteralLanguage("EN-NA");
			if (_global.ORCHID.literalModelObj.getLiteralLanguage()!="NAMEN") {
				myTrace("SSS NAmerican course so switch literals");
				_global.ORCHID.literalModelObj.setLiteralLanguage("NAMEN");
			}
		} else {
			if (_global.ORCHID.literalModelObj.getLiteralLanguage()!="EN") {
				myTrace("SSS Intl course so switch literals");
				_global.ORCHID.literalModelObj.setLiteralLanguage("EN");
			}
		}
	}
	*/
	
	//_global.ORCHID.paths.course = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.content + courseXMLNode.attributes["courseFolder"]); // + "/"
	// v6.4.2.5 Course is always read from MGS (which defaults to content if none) NO - this is holding the original to read
	// exercises that HAVE NOT been edited in the MGS.
	var thisCoursePath = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.content + courseXMLNode.attributes["courseFolder"]); // + "/"
	//var thisCoursePath = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.MGS + courseXMLNode.attributes["courseFolder"]); // + "/"
	//myTrace("paths.course=" + _global.ORCHID.paths.course);
	//if _global.ORCHID.paths.course is a relative path,
	//put _global.ORCHID.paths.root in front of it.
	// No, don't - we will always be adding .root whenever we use it later.
	//if (_global.ORCHID.paths.course.indexOf(":") == -1 and _global.ORCHID.paths.course.indexOf("|") == -1) {
		//_global.ORCHID.paths.course = _global.ORCHID.paths.root + _global.ORCHID.paths.course
	//}
	// v6.5.5.1 I want to be able to run exercises and media from different paths (to avoid too much duplication with language versions)
	// so that Intl and Indian English can share one set of content and NAm and ZH can share the other. Each with their own audio.
	// so rename mediaSubPath to mainSubPath and let yourself pick up another attribute for media if it is present.
	var menuXMLFile = courseXMLNode.attributes["scaffold"];
	//var mediaSubPath = courseXMLNode.attributes["subFolder"];
	var mainSubPath = courseXMLNode.attributes["subFolder"];
	if (mainSubPath == "" || mainSubPath == undefined) {
	} else {
		mainSubPath = _global.ORCHID.functions.addSlash(mainSubPath);
	}
	var mediaFolder = courseXMLNode.attributes["mediaFolder"];
	if (mediaFolder == "" || mediaFolder == undefined) {
		mediaFolder = "Media";
	}
	var exerciseFolder = courseXMLNode.attributes["exercisesFolder"];
	if (exerciseFolder == "" || exerciseFolder == undefined) {
		exerciseFolder = "Exercises";
	}
	//myTrace("mainSubPath=" + mainSubPath);
	//v6.4.2 Using APP to edit CE content. There will be an attribute set in the course node if this
	// course has been or can be edited with APP.
	// v6.4.2.5 Course is always read from MGS (which defaults to content if none)
	//if (courseXMLNode.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.edited) {
		//v6.4.4 MGS. When you logged in, you will have picked up the MGS for this user.
		// This is in the form of a path that contains the course.xml that has been customised by the user's teacher.
		// Then based on enabledFlag in that course.xml and menu.xml you will pick up exercises/media from the default
		// content path or the MGS. 
		// Note that when you read MGS from login, it will be generic across all titles. You will have then added the title
		// to it. eg. /SAY1CA/TenseBuster
		var editedCoursePath = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.MGS + courseXMLNode.attributes["courseFolder"]);
		// It should be impossible for this to happen since you have already read course.xml from this path!
		if (_global.ORCHID.paths.MGS == undefined) {
			myTrace("ERROR: no MGS, but course has been edited");
			editedCoursePath = thisCoursePath;
		} else {
			// v6.4.1.4 This should be a full path (it will probably be the default AP course folder)
			// v6.4 2 rootless
			//_global.ORCHID.paths.editedCourse = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.editedContent + editedCourseFolder);
			//_global.ORCHID.paths.editedCourse = _global.ORCHID.functions.addSlash(editedCourseFolder);
			//myTrace("paths.editedCourse=" + editedCoursePath);		
		}
		// So, finally, where do we read our menu from?
		var thisMenuFile = editedCoursePath + mainSubPath + menuXMLFile;
	//} else {
	//	var thisMenuFile = thisCoursePath + mainSubPath + menuXMLFile;
	//}
	myTrace("menu: " + thisMenuFile); // + cacheVersion);
	_global.ORCHID.paths.subCourse = thisCoursePath + mainSubPath; // This is used in the glossary - so not part of MGS
	//_global.ORCHID.paths.media = _global.ORCHID.functions.addSlash(thisCoursePath + mainSubPath + "Media") ;
	_global.ORCHID.paths.media = _global.ORCHID.functions.addSlash(thisCoursePath + mainSubPath + mediaFolder) ;
	_global.ORCHID.paths.exercises = _global.ORCHID.functions.addSlash(thisCoursePath + mainSubPath + exerciseFolder);
	//myTrace("media path is " + _global.ORCHID.paths.media);
	// v6.4.2 AP editing ce
	_global.ORCHID.paths.editedMedia = _global.ORCHID.functions.addSlash(editedCoursePath + mainSubPath + mediaFolder); 
	_global.ORCHID.paths.editedExercises = _global.ORCHID.functions.addSlash(editedCoursePath + mainSubPath + exerciseFolder);
	myTrace("edited media path is " + _global.ORCHID.paths.editedMedia);

	// v6.3.5 Allow for shared media folder to be the same as the main one, and streaming
	// v6.5.5.5 There is a bug here. If you do NOT set streamingMedia (or sharedMedia) in the location file, but set it here
	// then if you change courses, you will NOT refresh the subPath courseID as the streamingMedia path now appears set!
	// v6.5.5.6 Change to default for sharedMedia. Should now default to paths.content.sharedMedia (because then it will be shared, see!)
	if (_global.ORCHID.paths.sharedMedia == undefined) {
		//_global.ORCHID.paths.sharedMedia = _global.ORCHID.paths.media;
		_global.ORCHID.paths.sharedMedia = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.content) + _global.ORCHID.functions.addSlash("sharedMedia");
	} 
	// Actually, I want to have a root folder for streamingMedia, which is parallel to /Content/xxx. Then this issue will not arise.
	if (_global.ORCHID.paths.streamingMedia == undefined) {
		//_global.ORCHID.paths.streamingMediaFolder = _global.ORCHID.paths.media;
		//_global.ORCHID.paths.streamingMediaFolder = _global.ORCHID.paths.media;
		_global.ORCHID.paths.streamingMedia = _global.ORCHID.functions.addSlash(_global.ORCHID.paths.content) + _global.ORCHID.functions.addSlash("streamingMedia");
	// v6.5.5.6 Streaming media always wants the parallel courses structure. So this is not an else.
	//} else {
	}
	// Just replace the content path with the streaming media path if you set it
	// This won't work if your content path is relative and your streaming media path is absolute. Hmmm. Need to totally rebuild.
	//_global.ORCHID.paths.streamingMediaFolder = findReplace(_global.ORCHID.paths.media, _global.ORCHID.paths.content, _global.ORCHID.paths.streamingMedia);
	_global.ORCHID.paths.streamingMediaFolder = _global.ORCHID.functions.addSlash(_global.ORCHID.functions.addSlash(_global.ORCHID.functions.addSlash(_global.ORCHID.paths.streamingMedia) + courseXMLNode.attributes["courseFolder"]) + mainSubPath + mediaFolder);
	myTrace("calculated streaming media folder to " + _global.ORCHID.paths.streamingMediaFolder );
	//}
	_global.ORCHID.viewObj.clearScreen("CourseListScreen"); 
	var thisCourse = new _global.ORCHID.root.objectHolder.CourseObject(courseXMLNode.attributes["id"]);
	// v6.5.5.3 Get the course name from the course.xml rather than from the menu.xml. Helps if they need to differ only at the course level.
	_global.ORCHID.session.courseName = unescape(courseXMLNode.attributes["name"]);
	myTrace("save course name from course of " + _global.ORCHID.session.courseName);
	
	var menuRootItems;
	Menu_onLoad = function(success) {
		if (success) {
			myTrace("menu XML read ");
			menuRootItems = this.firstChild.getRootItems();
			//v6.3.6 APP will write a signature version number into the menu. Use this for some stuff.
			// undefined for earlier menus is fine.
			thisCourse.version = this.firstChild.attributes.version;
			thisCourse.loadScaffold(this);
		} else {
			// v6.3.5 Give a visible response to the user please
			myTrace("menu XML failed!");
			var errObj = {literal:"cannotLoadXML", detail:thisMenuFile};
			_global.ORCHID.root.controlNS.sendError(errObj);
			// v6.5 But this shouldn't be catastrophic, we should simply tell them, then disable the course and stay on the course screen.
		}
	}
	//AM: the menuXML object is stored as a global object so that we can get information from
	//the XML when displaying the menu
	_global.ORCHID.menuXML = new XML();          // creates a new XML Object
	_global.ORCHID.menuXML.ignoreWhite = true;
	_global.ORCHID.menuXML.onLoad = Menu_onLoad;
	//Note: read the scaffold XML object name from the INI file
	// v6.4.2 For AP courses, always get new version of menu.xml
	// v6.4.1.4 Why not just get a fresh menu for everything? It is not a big deal I don't think and
	// once you start allowing editing of TB you will get cache problems with that.
	//if(_global.ORCHID.online && (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AP") >= 0)) {
	//	myTrace("AP, so fresh menu please")
		var cacheVersion = "?version=" + Number(new Date());
	//}else{
	//	var cacheVersion = ""
	//}
	//v6.3.4 Use full paths
	//_global.ORCHID.menuXML.load(_global.ORCHID.paths.root + _global.ORCHID.paths.subCourse + menuXMLFile + cacheVersion);
	_global.ORCHID.menuXML.load(thisMenuFile + cacheVersion);

	thisCourse.onLoadScaffold = function() {
		var returnCode = true;
		//myTrace("the scaffold has been read, menu length=" + menuRootItems.length);
		_global.ORCHID.course = this;
		
		// v6.5.5.3 Overwrite the course name read from menu.xml with the one we got from course.XML
		myTrace("overwrite menu course name of " + _global.ORCHID.course.scaffold.caption + "with " + _global.ORCHID.session.courseName);
		_global.ORCHID.course.scaffold.caption = _global.ORCHID.session.courseName;
		// v6.3.5 The scaffold top level id will have been read from the menu, so need to add in the courseID before it is lost
		//trace("NOW we save it to _glob " + _global.ORCHID.course.testList.length);
		// Note: we were trying to send 'this' back through the connection to the control
		// where it was set to _global, but doing that lost us the functions, although the
		// data in the object was fine. So now just set it to _global here.
		// 6.0.2.0 remove connections
		//sender = new LocalConnection();
		//sender.send("controlConnection", "setCourse", menuRootItems);
		//delete sender;
		_global.ORCHID.root.controlNS.setCourse(menuRootItems);
	}
	
	// v6.3.6 Allow a different dictionary to be used
	// v6.4.2 You might also want different dictionaries to be used based on the literals language or the installation
	// Perhaps the nicest thing would be to have a second choice which lists available dictionaries (like languages)
	// This would imply a settings screen - could also have audio choices on it.
	// v6.5.5.6 Let a dictionary be read from licence attributes for an account, then overridden here if course.xml wants.
	// Currently no title uses this in course.xml as far as I can see.
	if (courseXMLNode.attributes["dictionary"]!=undefined && courseXMLNode.attributes["dictionary"]!="") {
		thisCourse.dictionary = courseXMLNode.attributes["dictionary"];
		myTrace("uses dictionary from course.xml: " + thisCourse.dictionary);
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.dictionary!=undefined) {
		thisCourse.dictionary = _global.ORCHID.root.licenceHolder.licenceNS.dictionary;
		myTrace("uses dictionary from account: " + thisCourse.dictionary);
	}

	// v6.4.2.4 Allow the course to set soundEffects as well as it being done at exercise level. This seems much more
	// likely to me. Default is on.
	thisCourse.soundEffects = (courseXMLNode.attributes["soundEffects"]=="false") ? false : true;
	//myTrace("this course uses soundEffects: " + thisCourse.soundEffects + " xml=" + courseXMLNode.attributes["soundEffects"]);
}

View.prototype.displayYourScore = function(thisScore, tryAgainCallback) {

	//var initObj = { _x:100, _y:100 };
	
	//var initObj = {_x:230, _y:48, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	// First create a message box for the score to go in
	// CUP/GIU
	// v6.3.4 use buttons rather than progress
	//var myMsgBox = _root.progressHolder.attachMovie("APMsgBoxSymbol", "score_SP", _root.progressHolder.progressNS.fixedDepth, initObj);
	//var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("APMsgBoxSymbol", "score_SP", _global.ORCHID.MsgBoxDepth, initObj);
	//trace("create msgbox=" + myMsgBox);
	//var myPane = _root.progressHolder.attachMovie("FDraggablePaneSymbol","score_SP",_root.progressHolder.progressNS.fixedDepth, initObj); 
	// set up how the pane behaves/looks
	//myMsgBox.setModal(true, 25);
	//myMsgBox.setContentBorder(false);
	//myMsgBox.setPaneTitle(_global.ORCHID.literalModelObj.getLiteral("marking", "labels")); 
	//myMsgBox.setScrolling(false);
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	myMsgBox.setSize(350, 150);
	//} else {
	//	myMsgBox.setSize(350, 200);
	//}

	// v6.3.5 Use better CE pop up window
	// v6.5.6.4 I think all could move, but just SSS for now.
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		var initObj = {_x:200, _y:140, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	} else {
		var initObj = {_x:230, _y:48, branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	}
	// v6.3.6 Problem of suddenly buttons not working. Is it due to score clashing with something?
	// It would be more logical for it to be at depth++ like all other windows created on messageScreen.
	//var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "score_SP", _global.ORCHID.MsgBoxDepth, initObj);
	var myMsgBox = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "score_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj);
	
	// Note that I was pulling my hair out trying to find out why the See the answers was sometimes not wide enough. Turns out it was after
	// viewing the certificate and was because certificate.fla contained FGraphicButton - an old version. Hah.
	
	//myTrace("PUW version=" + myMsgBox.getVersion());
	myMsgBox.setTitle(_global.ORCHID.literalModelObj.getLiteral("marking", "labels")); 
	myMsgBox.setCloseButton(false);
	myMsgBox.setResizeButton(false);
						
	// set up actions for the pane buttons (if any)
	myObj = new Object();
	// Add buttons to hold the three options that you can do
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// v6.3.4 CUP does startAgain, always
		myObj.onStartAgain = function() {
			var myPane = this._parent;
			myPane.tryAgainCallback("startAgain", myPane.thisScore)
		}
		myObj.seeTheAnswers = function() {
			//trace("calling seeTheAnswers for this=" + this);
			var myPane = this._parent;
			myPane.tryAgainCallback("seeTheAnswers", myPane.thisScore)
		}
		myObj.feedback = function() {
			var myPane = this._parent;
			myPane.tryAgainCallback("feedback", myPane.thisScore)
		}
		// for those in the know, Enter/escape is a reasonable thing to do here
		// No it isn't, too confusing. What happens to the rubric, marking button etc?
		// Instead make ENTER and ESC go to seeTheAnswers
		//myObj.close = function() {
		//	_global.ORCHID.viewObj.setFeedback(true);
		//}
		myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("startAgain", "buttons"), setReleaseAction:myObj.onStartAgain},
						{caption:_global.ORCHID.literalModelObj.getLiteral("feedback", "buttons"), setReleaseAction:myObj.feedback},
						{caption:_global.ORCHID.literalModelObj.getLiteral("seeTheAnswer", "buttons"), setReleaseAction:myObj.seeTheAnswers}]);
		// setKeys just doesn't work in this way for the msgBox (I think it is fine for the drag pane)
		// so just disable the keys for now
		//myMsgBox.setKeys([{key:["F".charCodeAt(0)], setReleaseAction:myObj.feedback},
		//				{key:["S".charCodeAt(0)], setReleaseAction:myObj.seeTheAnswers},
		//				{key:[KEY.ENTER, KEY.ESCAPE], setReleaseAction:myObj.seeTheAnswers}]);
		//myMsgBox.setCloseHandler(myObj.finish);
	} else {
		myObj.onTryAgain = function() {
			var myPane = this._parent;
			// v6.4.2.4 BC IELTS wants this button to mean start the exercise again.
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BC/IELTS") >= 0) {
				myPane.tryAgainCallback("startAgain", myPane.thisScore);
			} else {
				myPane.tryAgainCallback("tryAgain", myPane.thisScore);
			}
			clearInterval(_global.ORCHID.root.buttonsHolder.buttonsNS.setBigInt);
			clearInterval(_global.ORCHID.root.buttonsHolder.buttonsNS.setLittleInt);
		}
		myObj.seeTheAnswers = function() {
			var myPane = this._parent;
			myPane.tryAgainCallback("seeTheAnswers", myPane.thisScore)
			clearInterval(_global.ORCHID.root.buttonsHolder.buttonsNS.setBigInt);
			clearInterval(_global.ORCHID.root.buttonsHolder.buttonsNS.setLittleInt);
		}
		myObj.finish = function() {
			var myPane = this._parent;
			myPane.tryAgainCallback("finish", myPane.thisScore)
			clearInterval(_global.ORCHID.root.buttonsHolder.buttonsNS.setBigInt);
			clearInterval(_global.ORCHID.root.buttonsHolder.buttonsNS.setLittleInt);
		}
		// v6.4.2.4 BC IELTS wants this button to mean start the exercise again.
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BC/IELTS") >= 0) {
			var thisLiteralName = "startAgain";
		} else {
			var thisLiteralName = "tryAgain";
		}
		myTrace("msgBox.setButtons to  " + _global.ORCHID.literalModelObj.getLiteral("seeTheAnswer", "buttons"));
		// v6.5.5.8 CP switches the buttons alignment, and the easiest way to make it right is to change it here!
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral(thisLiteralName, "buttons"), setReleaseAction:myObj.onTryAgain},
						{caption:_global.ORCHID.literalModelObj.getLiteral("seeTheAnswer", "buttons"), setReleaseAction:myObj.seeTheAnswers},
						{caption:_global.ORCHID.literalModelObj.getLiteral("forward", "buttons"), setReleaseAction:myObj.finish}]);
		} else {
			myMsgBox.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral(thisLiteralName, "buttons"), setReleaseAction:myObj.onTryAgain},
						{caption:_global.ORCHID.literalModelObj.getLiteral("forward", "buttons"), setReleaseAction:myObj.finish},
						{caption:_global.ORCHID.literalModelObj.getLiteral("seeTheAnswer", "buttons"), setReleaseAction:myObj.seeTheAnswers}]);
		}
		// setKeys just doesn't work in this way for the msgBox (I think it is fine for the drag pane)
		// so just disable the keys for now
		//myMsgBox.setKeys([{key:[KEY.ENTER, "S".charCodeAt(0)], setReleaseAction:myObj.seeTheAnswers},
		//				{key:["T".charCodeAt(0)], setReleaseAction:myObj.tryAgain},
		//				{key:[KEY.ESCAPE, "F".charCodeAt(0)], setReleaseAction:myObj.finish}]);
		//myMsgBox.setCloseHandler(myObj.finish);
	}
	// save anything that you want to use with the message box on detecting a click
	// v6.2 This is a BAD way to pass round a callback (and you don't use the score anymore)
	myMsgBox.tryAgainCallback = tryAgainCallback;
	myMsgBox.thisScore = thisScore;
		
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// v6.4.2.7 CUP rearrange
		//myMsgBox.setSize(350, 150);
		myMsgBox.setSize(410, 160);
	// v6.5.5.8 CP PUW is not so deep, so give it a bigger minimum here
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		myMsgBox.setSize(350, 210);
	// v6.5.6.4 New SSS
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		myMsgBox.setSize(450, 310);
	} else {
		myMsgBox.setSize(350, 200);
	}

	// set up the content to go in the pane
	//myMsgBox.setScrollContent("blob");
	//var contentHolder = myMsgBox.getScrollContent();
	//var contentSize = myMsgBox.getContentSize();
	var contentHolder = myMsgBox.getContent();
	var contentSize = myMsgBox.getContentSize();
	// CUP/GIU
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// make a text field to hold the score description
		// v6.4.2.7 CUP rearrange
		//contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 0,0,350,50);
		contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 5,5,350,50);
	// v6.5.6.4 New SSS
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 200,50,250,100);
	} else {
		contentHolder.createTextField("list_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 125,20,190,10);
	}
	var clt = contentHolder.list_txt
	clt.autoSize = true;
	clt.html = true;
	clt.wordWrap = true;
	clt.multiline = true;
	//var scoreText = "<font size='12'>You scored " + thisScore.score+ "% in this exercise.</font>"
	var scoreText = _global.ORCHID.literalModelObj.getLiteral("exerciseResult", "messages");
	scoreText = findReplace(scoreText, "[x]", thisScore.score);
	// CUP/GIU uses different layout in the score setting
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		var keyText = 	"<br>(" + _global.ORCHID.literalModelObj.getLiteral("correct", "labels") + "=" + thisScore.correct + ", " + 
						_global.ORCHID.literalModelObj.getLiteral("wrong", "labels") + "=" + thisScore.wrong + ", "+ 
						_global.ORCHID.literalModelObj.getLiteral("missed", "labels") + "=" + thisScore.skipped + ")";
		var afterText = "<br>What do you want to do now?";
		clt.setHTMLText("<font size='12'>" + scoreText + keyText + afterText + "</font>", _global.ORCHID.basicText);
	// v6.5.6.4 New SSS
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		// Use four different text boxes, one for score, one for right, wrong and skipped
		scoreText = "<font size='12'>" + scoreText + "</font>";
		clt.setHTMLText(scoreText, _global.ORCHID.basicText);
		contentHolder.createTextField("list_correct_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 230,84,100,40);
		contentHolder.createTextField("list_wrong_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 230,114,100,40);
		contentHolder.createTextField("list_skipped_txt", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, 230,144,100,40);
		var correctText = "<font size='12' color='#006600'><b>" + thisScore.correct + " " + _global.ORCHID.literalModelObj.getLiteral("correct", "labels") + "</b></font>";
		contentHolder.list_correct_txt.html = true;
		contentHolder.list_correct_txt.setHTMLText(correctText, _global.ORCHID.basicText);
		var wrongText = "<font size='12' color='#FF0000'><b>" + thisScore.wrong + " " + _global.ORCHID.literalModelObj.getLiteral("wrong", "labels") + "</b></font>";
		contentHolder.list_wrong_txt.html = true;
		contentHolder.list_wrong_txt.setHTMLText(wrongText, _global.ORCHID.basicText);
		var skippedText = "<font size='12' color='#0000FF'><b>" + thisScore.skipped + " " + _global.ORCHID.literalModelObj.getLiteral("missed", "labels") + "</b></font>";
		contentHolder.list_skipped_txt.html = true;
		contentHolder.list_skipped_txt.setHTMLText(skippedText, _global.ORCHID.basicText);
		var correctGraphic = contentHolder.attachMovie("Tick", "correctGraphic", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, {_x:200, _y:90 });
		var wrongGraphic = contentHolder.attachMovie("Cross", "wrongGraphic", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, {_x:206, _y:120 });
		var skippedGraphic = contentHolder.attachMovie("Missed", "skippedGraphic", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, {_x:200, _y:150 });
		
		var pg = contentHolder.attachMovie("scoreWall", "pieChart", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, {_x:40, _y:40 });
		contentHolder.delayDrawPie = function(x, y, z) {
			clearInterval(this.pieInt);
			//myTrace("pie=" + this.pieChart + " x=" + x);
			this.pieChart.drawScoreWheel(x, y, z);
		}
		contentHolder.pieInt = setInterval(contentHolder, "delayDrawPie", 100, thisScore.correct, thisScore.wrong, thisScore.skipped);
		/*
		// v6.5.6.4 This goes in the scoreWall mc in buttons.fla
		// It would be better like this:
		/// Each grid square has an instance name, grid-1 etc
		// Then have a function that simply turns on the grid-square it is told to
		var i=0;
		function setGridOn() {
			i++;
			if (i>pc) {
				// cancel the timer interval
			} else {
				this["grid-" + i]._visible = true;
			}
		}
		// And call that from a timer
		gridInterval = new Timer(50, setGridOn);
		// Maybe need to think about clearing all at the beginning.
		*/
	} else {
		scoreText = "<font size='12'>" + scoreText + "</font><br><br>"; 
		
		//contentHolder.createTextField("key_txt", _root.progress.Holder.progressNS.depth++, 125,40,10,10);
		//var ckt=contentHolder.key_txt
		//ckt.autoSize = true;
		//ckt.html = true;
		//ckt.wordWrap = false;
		//ckt.multiline = true;
		// EGU change formatting of results text
		var keyText = 	"<font size='12'><font color='#009933'>" + _global.ORCHID.literalModelObj.getLiteral("correct", "labels") + " = " + thisScore.correct + "</font><br>" + 
						"<font color='#ff0000'>" + _global.ORCHID.literalModelObj.getLiteral("wrong", "labels") + " = " + thisScore.wrong + "</font><br>"+ 
						"<font color='#0000ff'>" + _global.ORCHID.literalModelObj.getLiteral("missed", "labels") + " = " + thisScore.skipped + "</font></font>";
		clt.setHTMLText(scoreText + keyText, _global.ORCHID.basicText);
		//ckt.setHTMLText(keyText, _global.ORCHID.basicText);
		// add in a pie chart to display the scores
		//contentHolder.drawProgressPieChart = function() {
		var initObj = {_x:10, _y:10 };
		var pg = contentHolder.attachMovie("scoreWheel", "pieChart", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj);
		//myTrace("pg=" + pg);
		// since you are doing all sorts of attach and load etc, delay the actual call so that you 
		// get to the next frame and it will all be loaded. Hmm, yes, yes I know.
		contentHolder.delayDrawPie = function(x, y, z) {
			clearInterval(this.pieInt);
			//myTrace("pie=" + this.pieChart + " x=" + x);
			this.pieChart.drawScoreWheel(x, y, z);
		}
		contentHolder.pieInt = setInterval(contentHolder, "delayDrawPie", 100, thisScore.correct, thisScore.wrong, thisScore.skipped)
		//};
		//contentHolder.drawProgressPieChart();
		/*
		drawProgressPieChart = function() {
			var initObj = {_x:70, _y:80 };
			var pg = contentHolder.attachMovie("multiPieGraph", "pieChart", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, initObj);
			//trace("drawing pie chart " + this.pg);
			var scale = 50;
			var rad = 100;
			pg._xscale = pg._yscale = scale;
			pg.setRadius(rad);
			var totalAnswers = Number(thisScore.correct + thisScore.wrong + thisScore.skipped);
			pg.setValues([thisScore.correct/totalAnswers, thisScore.wrong/totalAnswers, thisScore.skipped/totalAnswers]);
			//pg.setValues([20, 30, 50]);
			//pg.setPercentage(25);
			pg._visible = true;
			clearInterval(_global.ORCHID.root.buttonsHolder.buttonsNS.setBigInt); // from a previous time
			_global.ORCHID.root.buttonsHolder.buttonsNS.setLittleInt = 0;
			_global.ORCHID.root.buttonsHolder.buttonsNS.setBigInt = 0;
			rotate = function(directions) {
				var thisDirection = directions[Math.floor(Math.random() * (directions.length))];
				//trace("in rotate with " + thisDirection);
				clearInterval(_global.ORCHID.root.buttonsHolder.buttonsNS.setLittleInt);
				_global.ORCHID.root.buttonsHolder.buttonsNS.setLittleInt = setInterval(pg, "moveABit", 50, thisDirection);
			}
			var directions = ["up", "down", "left", "right", "in", "out"];
			// cut out interval animation until you are happy closing and opening
			// this window many times
			_global.ORCHID.root.buttonsHolder.buttonsNS.setBigInt = setInterval(rotate, 2000, directions);
		};
		drawProgressPieChart();
		*/
	}

	// finally draw it
	myMsgBox.setEnabled(true);
	// v6.5.4.3 AR this was not necessary for fixing Bug 1223, so remove it
	//myMsgBox.initTextFieldForDictionaryCheck();	// v6.5.4.2 Yiu, try to fully initialize the textWithFields object, Bug ID 1223
}

// v6.4.2.1 Show the licencee name - properly done in screen, setLiterals
//View.prototype.showLicenceName = function() {
//	_global.ORCHID.root.buttonHolder.IntroScreen.setLiterals();
//}

// v6.4.2.4 Can you add a button that lets you start the exercise again?
View.prototype.cmdStartAgain = function() {
	// You cannot start a random test again through createExercise - you have to go further back. Or do you? Yes, I think you do.
	if (_global.ORCHID.session.currentItem.numOfQuestions>0) {
		myTrace("start again please, randomly");
		_global.ORCHID.viewObj.cmdRandomTest();
	} else {
		myTrace("start again please");
		_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
		_global.ORCHID.root.mainHolder.creationNS.createExercise(_global.ORCHID.session.currentItem);
	}
	_global.ORCHID.viewObj.setMarking(true);
}

View.prototype.cmdChangeLanguage = function(component) {
	_global.ORCHID.literalModelObj.currentLiteralIdx = component.getSelectedIndex();
	_global.ORCHID.literalModelObj.setLiteralLanguage(component.getSelectedItem().data);
	myTrace("choose change language to " + component.getSelectedItem().data + ", idx=" + _global.ORCHID.literalModelObj.currentLiteralIdx);
}

// v6.3.5 function to send a word to the countDown twfs
View.prototype.cmdGuessWord = function(component) {
	//myTrace("call cmdGuessWord from " + component);

	// MVC - probably shouldn't talk direct to the interface from here, but...
	var cdController = _global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController;

	// get the word from the interface - trimmed
	var myWord = cdController.word_i.text.trim("both");
	myTrace("the guessed word is " + myWord);

	// Is it worth quickly checking the words they have already guessed first?
	var guessListLen = cdController.guessList_cb.getLength();
	for (var i=0; i<guessListLen;i++) {
		if (cdController.guessList_cb.getItemAt(i).data == myWord) {
			myTrace("you've already guessed that word");
			cdController.guessList_cb.setSelectedIndex(i);
			cdController.word_i.text = "";
			Selection.setFocus(cdController.word_i);
			return;
		}
	}

	if (myWord != "") {
		var myPane = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP;
		var contentHolder = myPane.getScrollContent(); 
		//myTrace("contentHolder=" + contentHolder);
		var guessed = 0;
		for (var i in contentHolder) {
			//myTrace("look in twf(?) " + contentHolder[i]);
			guessed += contentHolder[i].guessCountDownWord(myWord);
		}
		if (guessed <= 0) {
			// if this word is wrong, increment the wrong clicks for later marking
			// v6.4.2.7 You simply don't have 'group' as an array on the body for countdowns. So need somewhere else 
			// to put the incorrectClicks. Since I store the incorrect words on the cdController itself, put the score there as well.
			//myTrace("wrong, so increment " + cdController.incorrectClicks);
			//_global.ORCHID.LoadedExercises[0].body.text.group[0].incorrectClicks++;
			cdController.incorrectClicks++;
		}
		//myTrace(myWord + " appeared " + guessed + " times, total wrong=" + _global.ORCHID.LoadedExercises[0].body.text.group[0].incorrectClicks);
		myTrace(myWord + " appeared " + guessed + " times, total wrong=" + cdController.incorrectClicks);
		cdController.guessList_cb.addItemAt(0, myWord + " (" + guessed + ")", myWord);
	}
	cdController.guessList_cb.setSelectedIndex(0);
	cdController.word_i.text = "";
	Selection.setFocus(cdController.word_i);
}
