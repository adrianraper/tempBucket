// ActionScript Document

// Overall function to parse the XML object into the Exercise Object - should just be called once per exercise
// index represents xml to be process
// 0: exercise content
// 1: reading text
// 2: rule text
// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
// 3: related text
function populateExerciseFromXML(XMLSource, callBack, index) {
	mytrace("populateExerciseFromXML for [" + index +"]");
	
	//var startTime = new Date();
	//var me = _global.ORCHID.LoadedExercises[0]; // only use 1 exercise object at present
	// _global.ORCHID.LoadedExercises[0] stores the exercise object
	// v6.3.4 move reading text to <texts> node
	// _global.ORCHID.LoadedExercises[1] stores the exercise object for reading text if any
	// _global.ORCHID.LoadedExercises[2] stores the exercise object for rule text if any
	// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
	// _global.ORCHID.LoadedExercises[3] stores the exercise object for related text if any
	if (index != undefined) {
		var me = _global.ORCHID.LoadedExercises[index];
	} else {
		index = 0;
		var me = _global.ORCHID.LoadedExercises[0];
	}
	// 6.0.4.0, As there may be 3 items in LoadedExercises array,
	// I use a global variable to store the index of LoadedExercises item which is being processed.
	// So onEnterFrame knows which function to call back.
	_global.ORCHID.exerciseInProcess = index;

	XMLSource.stripWhite();
	XMLSource.ignoreWhite = true;
	//var exerciseTag = new XML();
	//var exercise = new Object;
	var exerciseTag = XMLSource.firstChild;
	//trace(exerciseTag.myToString());
	if (exerciseTag.nodeName.toLowerCase() == "exercise") {
		me.title = new Object();
		// CUP noScroll and example code
		me.noScroll = new Object();
		me.example = new Object();
		me.body = new Object();
		me.feedback = new Array();
		me.hint = new Array();
		// v6.3.4 new object for related texts
		me.texts = new Array();
		me.style = new Array();
		me.id = exerciseTag.attributes.id; // not used anymore
		// added for tests by AR - why wasn't it done already?
		// could it be that the name is normally extracted from the scaffold?
		//v6.4.2.1 All attributes might have been escaped
		me.name = unescape(exerciseTag.attributes.name);
		//trace("set me.name=" + me.name);
		// v6.3.4 First read the old style exercise mode and convert it to settings object
		me.settings = new Object();
		me.settings = defaultSettings();
		// v6.3.3 This mode is replaced with a separate settings node
		if (exerciseTag.attributes.mode != undefined) {
			// but still read the attribute in case this is an old style exercise
			// v6.3.4 To avoid confusion, exercise that have a settings node should NOT have a mode attribute
			me.settings = convertXMLSettings(Number(exerciseTag.attributes.mode), index);
		}
		//myTrace("line 53 splitScreen=" + me.settings.misc.splitScreen);
		//trace("set exercise mode to " + me.mode);
		me.regions = 0;
		// v6.3.5 APL writes the exercise type, simply save it (I prefer to use the settings node)
		// v6.3.6 Probably settings.exercise ISN'T the right place, but never mind too much eh?
		me.settings.exercise.type = exerciseTag.attributes.type;
		//myTrace("exercise.type = " + me.settings.exercise.type);
		
		// v6.3.6 From APP onwards, there is also a version number.
		me.settings.exercise.version = new versionNumber(exerciseTag.attributes.version);
		//myTrace("exercise.xml written by APP version=" + me.settings.exercise.version.toString());
		
		// save the XML into the exercise to allow the timeLimited funtion to get at it

		// v6.3.4 Swap in a (better?) tlc
		// set up the timeLimitCallback object
		//me.tlc = new Object();
		// next define a function to update a progress bar in the above controller
		// why can't this be done direct on the controller movie?
		//me.tlc.updateProgressBar = function(pc){
		//	//trace("call updateProgressBar");
		//	_global.ORCHID.root.tlcController.setPercentage(Math.floor(pc*100));
		//}
		
		// ******
		// Create the tlc settings
		// ******
		_global.ORCHID.tlc = {timeLimit:1000, 		// How long to spend in one iteration? (don't go near 15 seconds!)
						maxLoop:exerciseTag.childNodes.length, 	// The end of your loop
						i:0,			// The start of your loop
						proportion:25, 	// If this is multi-step process, what % is spent on this step?
						startProportion:0,	// What is the starting % for this step?
						callback:callBack}; // What function to call when you are finished?
		var tlc = _global.ORCHID.tlc;
	
		// first see if the controllerMC is already there
		// FAKE to cover up for the earlier lapses - remove later
		tlc.controller = _global.ORCHID.root.tlcController;
		/*
		if (typeof tlc.controller == "movieclip") {
			//myTrace("controller already exists as it should course.as:81");
		} else {		
			myTrace("controller doesn't exist - it should! XMLtoObject.as:85");
			// v6.3.4 following code should be redundant
			var myController = _global.ORCHID.root.createEmptyMovieClip("tlcController", _global.ORCHID.loadingDepth);
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
		//tlc.updateProgressBar = function(pc){
		//	//myTrace("set % to +" + pc);
		//	this.controller.setPercentage(this.startProportion + Math.floor(pc));
		//}
		//myTrace("call startEnterFrame");
		// ******
		// this is the data that is the core of the loop, you need to save as part of the tlc object
		// so that it is available in the loop and callback
		// ******
		tlc.childNodes = exerciseTag.childNodes;
		
		// and a callback to whatever called this function to let it know we have finished
		//tlc.callback = callBack;
		
		// then define the resumeLoop method
		//myTrace("tlc loop max=" + tlc.maxLoop);
		tlc.resumeLoop = function(firstTime) {
			//myTrace("resumeLoop XMLtoObject.as:107");
			var startTime = getTimer();
			var i = tlc.i;
			var max = tlc.maxLoop;
			var timeLimit = tlc.timeLimit;
			var myNodes = tlc.childNodes;
			while (getTimer()-startTime <= timeLimit && i<max && !firstTime) {
				//myTrace("this node=" + myNodes[i].nodeName);
				// this loop through the XML structure assumes you don't care about order of nodes
				if (myNodes[i].nodeName.toLowerCase() == "body") {
					//myTrace("processing main body");
					me.body.text = getXMLContentAndFields(myNodes[i], "body", index);
					//trace(">> get body at " + Number(getTimer() - _global.ORCHID.startTime));
					// CUP noScroll code, switch on this region for this exercise
					me.regions |= _global.ORCHID.regionMode.body;
				}
				if (myNodes[i].nodeName.toLowerCase() == "title") {
					me.title.text = getXMLContentAndFields(myNodes[i], "title", index);
					//myTrace("title=" + me.title.text.paragraph[0].plainText);
					//trace(">> get title at " + Number(getTimer() - _global.ORCHID.startTime));
					// CUP noScroll code, switch on this region for this exercise
					me.regions |= _global.ORCHID.regionMode.title;
					//trace(me + ".regions=" + me.regions + "(" + _global.ORCHID.regionMode.title + ")");
				}
				// CUP noScroll code
				if (myNodes[i].nodeName.toLowerCase() == "noscroll") {
					me.noScroll.text = getXMLContentAndFields(myNodes[i], "noScroll", index);
					//trace("noScroll=" + me.noScroll.text.paragraph[0].plainText);
					// CUP noScroll code, switch on this region for this exercise
					me.regions |= _global.ORCHID.regionMode.noScroll;
					myTrace("this exercise has noScroll region");
					//trace(me + ".regions=" + me.regions + "(" + _global.ORCHID.regionMode.noScroll + ")");
				}
				// CUP example code
				if (myNodes[i].nodeName.toLowerCase() == "example") {
					me.example.text = getXMLContentAndFields(myNodes[i], "example", index);
					//trace("example=" + me.example.text.paragraph[0].plainText);
					// CUP noScroll code, switch on this region for this exercise
					me.regions |= _global.ORCHID.regionMode.example;
					myTrace("this exercise has example region");
					//trace(me + ".regions=" + me.regions);
				}
				
				if (myNodes[i].nodeName.toLowerCase() == "feedback") {
					var myFeedback = new Object();
					myFeedback.id = myNodes[i].attributes.id;
					//trace("about to read fb from XML for id " + myFeedback.id);
					myFeedback.text = getXMLContentAndFields(myNodes[i], "feedback", index);
					dummy = me.feedback.push(myFeedback);
					//trace("read xml feedback["+(dummy-1)+"]="+me.feedback[dummy-1].text.paragraph[0].plainText);
					//trace(">> get feedback at " + Number(getTimer() - _global.ORCHID.startTime));
				}			
				if (myNodes[i].nodeName.toLowerCase() == "hint") {
					var myHint = new Object();
					myHint.id = myNodes[i].attributes.id;
					//trace("about to read hint from XML for id " + myHint.id);
					myHint.text = getXMLContentAndFields(myNodes[i], "hint", index);
					dummy = me.hint.push(myHint);
					//trace("read xml hint["+(dummy-1)+"]="+me.hint[dummy-1].text.paragraph[0].plainText);
				}			
				// v6.3.4 new type for holding related text (tips, reading text etc)
				if (myNodes[i].nodeName.toLowerCase() == "texts") {
					var myTexts = new Object();
					myTexts.id = myNodes[i].attributes.id;
					// v6.5.5.8 get the nice name for the related text
					myTexts.name = myNodes[i].attributes.name;
					myTrace("processing a related text, id=" + myTexts.id + " name=" + myTexts.name);
					//trace("about to read hint from XML for id " + myHint.id);
					myTexts.text = getXMLContentAndFields(myNodes[i], "texts", index);
					dummy = me.texts.push(myTexts);
					//myTrace("read xml texts["+(dummy-1)+"]="+me.texts[dummy-1].text.paragraph[0].plainText);
					// v6.4.2.4 Can you drag from a reading text?
					me.regions |= _global.ORCHID.regionMode.readingText;
				}			
				if (myNodes[i].nodeName.toLowerCase() == "template") {
					//trace("adding styles using " + myNodes[i]);
					me.style = getXMLStyles(myNodes[i]);
					//me.fontTable = getXMLFonts(myNodes[i]);
					//trace(">> get template at " + Number(getTimer() - _global.ORCHID.startTime));
				}			
				// v6.3.3 Use a new settings node to replace the mode attribute in the exercise node
				if (myNodes[i].nodeName.toLowerCase() == "settings") {
					// so if this settings node exists, override anything that you found from converting
					// an old style exercise mode (which would have been better not to be there)
					//me.settings = defaultSettings();
					// then read the "read" settings from the node
					me.settings = getXMLSettings(myNodes[i], index);
					//myTrace("setting oldGroup=" + me.settings.feedback.oldGroupBased)
					//myTrace("not call split=" + _global.ORCHID.LoadedExercises[0].settings.misc.splitScreen);
				}			
				i++;
			}
			//trace("finished this bit of time");
			if (i < max) {
				//myTrace("not finished XML loop yet");
				tlc.i = i;
				//this.updateProgressBar((i/max) * this.proportion);
				myTrace("XML progress bar inc by % " + Number((i/max) * this.proportion));
				this.controller.incPercentage((i/max) * this.proportion);
			} else if (i >= max || max == undefined) {
				//myTrace("finished loop");
				this.i = max+1; // just in case this is run beyond the limit
				//this.updateProgressBar(this.proportion); // this part of the process is 50% of the time consuming bit
				// v6.4.2.4 debug
				myTrace("XML progress bar set % to " + Number(this.startProportion + this.proportion));
				this.controller.setPercentage(this.startProportion + this.proportion);
				delete this.resumeLoop;
				//myTrace("XMLObject stopEnterFrame");
				this.controller.stopEnterFrame();
				//myTrace("% at end of XMLObject is " + this.controller.getPercentage());
				this.callBack();
				if (this.controller.getPercentage() >= 100) {
					this.controller.setEnabled(false);
				}
			}
			
		}
		//tlc.controller.setLabel("load exercise");
		tlc.controller.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadContent", "labels"));
		tlc.controller.setEnabled(true);
		tlc.controller.startEnterFrame();

		// finally start off the looping (with a firstTime flag)
		if (tlc.proportion > 0) {
			tlc.resumeLoop(true);
		} else {
			tlc.startProportion = tlc.controller.getPercentage();
			tlc.resumeLoop();
		}
	}
	//var stopTime = new Date();
	//trace("populateXML took " + (Number(stopTime.getTime()) - Number(startTime.getTime())));

	// Note: you might want to broadcast an event at this point
	//myTrace("line 224 splitScreen=" + me.settings.misc.splitScreen);
	return true;
}

// this will trigger once the XML is loaded and start the processing stage (if successful)
// function XMLLoadedCallback(success) {
// 	//trace("XMLloadedCallback=" + success);
// 	if (success) {
// 		_parent.processExerciseXML(this);
// 	} else {
// 		trace("Sorry, the XML load failed with code " + this.status);
// 	}
// }

// This will read the XML element it is given and return the ID attribute
function getXMLid(XMLSource) {
	return XMLSource.attributes.id;
}

// This will set all defaults before you start
function defaultSettings() {
	var AllSettings = new Object();

	AllSettings.marking = new Object();
	AllSettings.marking.delayed = true;
	AllSettings.marking.instant = false;
	AllSettings.marking.overwriteAnswers = false;
	AllSettings.marking.noScore = false;
	AllSettings.marking.test = false; // used to show that this exercise runs in testing mode

	AllSettings.feedback = new Object();
	AllSettings.feedback.scoreBased = false;
	AllSettings.feedback.neutral = false;
	AllSettings.feedback.wrongOnly = true;
	AllSettings.feedback.groupBased = false; // v6.3.4 Oh how I wish this was true, it should be
	AllSettings.feedback.showQuestionNo = false;	// v6.5.4.2 Yiu, option for showing question number in feedback box, Bug ID: 1208

	AllSettings.buttons = new Object();
	AllSettings.buttons.marking = true;
	AllSettings.buttons.feedback = true;
	AllSettings.buttons.rule = false;
	// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
	AllSettings.buttons.related = false;
	AllSettings.buttons.readingText = true;
	AllSettings.buttons.media = true;
	AllSettings.buttons.showAnswers = true;
	AllSettings.buttons.chooseInstant = false;
	AllSettings.buttons.recording = true;
	// v6.5 Let all buttons be switched off if the exercise says so
	AllSettings.buttons.menu = true;
	AllSettings.buttons.backward = true;
	AllSettings.buttons.forward = true;
	AllSettings.buttons.progress = true;
	AllSettings.buttons.scratchPad = true;
	AllSettings.buttons.hints = true;
	AllSettings.buttons.print = true;
	
	AllSettings.exercise = new Object();
	AllSettings.exercise.sameLengthGaps = false;
	AllSettings.exercise.proofReading = false;
	AllSettings.exercise.hiddenTargets = false;
	AllSettings.exercise.dragTimes = 32768; // this means many! - I thought 0 was for many?! No it isn't.
	AllSettings.exercise.correctMistakes = false;
	AllSettings.exercise.multiPart = false; // a multiple choice with many correct answers is OR not AND
	AllSettings.exercise.splitGaps = false;
	//AllSettings.exercise.countDown = false; // v6.3.5 New exercise type - can't coexist with other fields
									// you know, this might not be a setting, but maybe should be picked
									// up from the field types in the exercise
	AllSettings.exercise.matchCapitals = false; // setting for countdown, assumes capitalisation is not significant
	AllSettings.exercise.preview = false; // setting for countdown, assumes not to preview the text
	AllSettings.exercise.type = undefined; // v6.3.5 Will be passed for single type exercises from APL
	AllSettings.exercise.version = undefined; // v6.3.6 Will be passed from APP - shows which version wrote the XML
	//v6.4.2.4 Let questions start from other than 1
	AllSettings.exercise.questionStart = 1;
	//v6.4.3 Grouping exercises
	AllSettings.exercise.grouping = false;
	//v6.5.5.0 Save detailed answers for item analysis or portfolio
	AllSettings.exercise.saveDetails = false;
	// v6.5.5.8 Allow an exercise to use the small feedback window
	AllSettings.exercise.smallFeedbackWindow = false;
	
	AllSettings.misc = new Object();
	AllSettings.misc.splitScreen = false;
	AllSettings.misc.timed = 0; // this means not timed
	AllSettings.misc.soundEffects = true; // oops and clap
	// v6.5.5.0
	//AllSettings.misc.subunit = false; // to allow grouping of several exercises (share a timer for instance)
	
	return AllSettings;
}
// This will read the old exercise mode value and turn it into a new style settings node
function convertXMLSettings(mode, index) {
	//myTrace("use old style mode=" + mode);
	//var AllSettings = defaultSettings();
	var AllSettings = _global.ORCHID.LoadedExercises[index].settings;
	
	if (mode & 1) {
		AllSettings.marking.delayed = false;
		AllSettings.marking.instant = true;
	}
	if (mode & 512) {
		AllSettings.buttons.chooseInstant = true;
	}
	if (mode & 128) {
		AllSettings.feedback.neutral = true;
	}
	if (!(mode & 16)) {
		AllSettings.feedback.scoreBased = true;
	}
	if (!(mode & 32)) {
		AllSettings.feedback.wrongOnly = false;
	}
	if (mode & 2) {
		AllSettings.feedback.groupBased = false;
	} else {
		// v6.3.4 getting round problem that old files were wrong
		myTrace("old group based");
		AllSettings.feedback.oldGroupBased = true;
		AllSettings.feedback.groupBased = true;
	}
	if (mode & 1024) {
		AllSettings.exercise.hiddenTargets = true;
	}
	if (mode & 2048) {
		AllSettings.exercise.proofReading = true;
	}
	if (mode & 8192) {
		AllSettings.marking.overwriteAnswers = true;
	}
	if (mode & 16384) {
		AllSettings.misc.splitScreen = true;
	}
	if (mode & 4) {
		AllSettings.buttons.rule = true;
	}
	if (mode & 64) {
		AllSettings.buttons.feedback = false;
	}
	if (mode & 8) {
		AllSettings.buttons.marking = false;
	}
	if (mode & 65536) {
		AllSettings.exercise.dragTimes = 1;
	}
	// Based on particular licences you might have different defaults for some exericse modes
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
		// v6.4.2.7 EGU always uses only drag once and has no dragTimes setting
		AllSettings.exercise.dragTimes=1;
		myTrace("convert XMLSettings, dragTimes=1");
		// They also want to see all feedback, not just wrong ones
		AllSettings.feedback.wrongOnly = false;
		// Also recording button is always on
		AllSettings.buttons.recording = true;
	}
	return AllSettings;
}

// This will read the XML settings node and return an object
function getXMLSettings(XMLSource, index) {
	//myTrace("in getXMLStyles");
	XMLSource.ignoreWhite = true;
	// Use a function to preset defaults so that it doesn't matter if a node doesn't exist in the XML
	//v6.3.4 This is now done in main function
	//var AllSettings = defaultSettings();
	var AllSettings = _global.ORCHID.LoadedExercises[index].settings;
	var myNodes = XMLSource.childNodes;
	for (var i=0;i<myNodes.length;i++) {
		//myTrace("settings node is " + myNodes[i].nodeName);
		if (myNodes[i].nodeName.toLowerCase() == "marking") {
			var thisSetting = myNodes[i].attributes.instant; // default is delayed marking
			if (thisSetting == "true") {
				// use two settings to make the code more readable
				AllSettings.marking.instant = true;
				AllSettings.marking.delayed = false;
			}
			thisSetting = myNodes[i].attributes.overwriteAnswers; // default is NOT to overwrite the answers
			if (thisSetting == "true"){
				myTrace("use overwriteAnswers");
				AllSettings.marking.overwriteAnswers = true;
			}
			thisSetting = myNodes[i].attributes.noScore; // default is to write the score
			if (thisSetting == "true"){
				AllSettings.marking.noScore = true;
			}
			// v6.3.5 Add basic testing ability
			thisSetting = myNodes[i].attributes.test; // default is not testing mode
			if (thisSetting == "true"){
				AllSettings.marking.test = true;
			}
		}
		if (myNodes[i].nodeName.toLowerCase() == "feedback") {
			var thisSetting = myNodes[i].attributes.scoreBased; // default is question based feedback
			if (thisSetting == "true"){
				AllSettings.feedback.scoreBased = true;
			}
			thisSetting = myNodes[i].attributes.neutral; // default is false
			if (thisSetting == "true"){
				AllSettings.feedback.neutral = true;
			}
			thisSetting = myNodes[i].attributes.wrongOnly; // default is to just show feedback for wrong fields
			if (thisSetting == "false"){
				AllSettings.feedback.wrongOnly = false;
			}
			thisSetting = myNodes[i].attributes.groupBased; // v6.3.4 default is to show feedback by field NOT by group
			if (thisSetting == "true"){
				AllSettings.feedback.groupBased = true;
			}
			// v6.5.4.2 Yiu, option for showing question number in feedback box, Bug ID: 1208	
			thisSetting	= myNodes[i].attributes.showQuestionNo;
			if(thisSetting == "true"){
				AllSettings.feedback.showQuestionNo	= true;
			}
			// end v6.5.4.2 Yiu, option for showing question number in feedback box, Bug ID: 1208	
			
		}
		if (myNodes[i].nodeName.toLowerCase() == "buttons") {
			var thisSetting = myNodes[i].attributes.marking; // default is to show marking button
			if (thisSetting == "false"){
				AllSettings.buttons.marking = false;
			}
			thisSetting = myNodes[i].attributes.feedback; // default is to show feedback button
			if (thisSetting == "false"){
				AllSettings.buttons.feedback = false;
			}
			thisSetting = myNodes[i].attributes.rule; // default is NOT to show rule button
			if (thisSetting == "true"){
				AllSettings.buttons.rule = true;
			}
			// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
			// Or it might be that it is an exercise level attribute.
			thisSetting = myNodes[i].attributes.related; // default is NOT to show related button
			if (thisSetting == "true"){
				myTrace("exercise has a related button");
				AllSettings.buttons.related = true;
			}
			thisSetting = myNodes[i].attributes.readingText; // default is to show reading text button (if there IS a reading text that is)
			if (thisSetting == "false"){
				AllSettings.buttons.readingText = false;
			}
			thisSetting = myNodes[i].attributes.media; // default is to show media button
			if (thisSetting == "false"){
				AllSettings.buttons.media = false;
			}
			thisSetting = myNodes[i].attributes.showAnswers; // default is to show 'show answers' button
			if (thisSetting == "false"){
				AllSettings.buttons.showAnswers = false;
			}
			thisSetting = myNodes[i].attributes.chooseInstant; // default is NOT to show instant/delayed button
			if (thisSetting == "true"){
				myTrace("chooseInstant set to true");
				AllSettings.buttons.chooseInstant = true;
			}
			// v6.5 This ought to cover all recording buttons, whether ClarityRecorder is on or off
			thisSetting = myNodes[i].attributes.recording; // default is YES to show recording button(s)
			if (thisSetting == "false"){
				myTrace("set recording button false");
				AllSettings.buttons.recording  = false;
			}
			// v6.5 Allow all buttons to be switched off
			thisSetting = myNodes[i].attributes.menu; // default is to show this button
			if (thisSetting == "false"){
				AllSettings.buttons.menu = false;
			}
			thisSetting = myNodes[i].attributes.backward; // default is to show this button
			if (thisSetting == "false"){
				AllSettings.buttons.backward = false;
			}
			thisSetting = myNodes[i].attributes.forward; // default is to show this button
			if (thisSetting == "false"){
				AllSettings.buttons.forward = false;
			}
			thisSetting = myNodes[i].attributes.progress; // default is to show this button
			if (thisSetting == "false"){
				AllSettings.buttons.progress = false;
			}
			thisSetting = myNodes[i].attributes.scratchPad; // default is to show this button
			if (thisSetting == "false"){
				AllSettings.buttons.scratchPad = false;
			}
			thisSetting = myNodes[i].attributes.print; // default is to show this button
			if (thisSetting == "false"){
				AllSettings.buttons.print = false;
			}
			thisSetting = myNodes[i].attributes.hints; // default is to show this button
			if (thisSetting == "false"){
				AllSettings.buttons.hints = false;
			}
		}
		if (myNodes[i].nodeName.toLowerCase() == "exercise") {
			//myTrace("exercise=" + myNodes[i].nodeName.toString());
			var thisSetting = myNodes[i].attributes.sameLengthGaps; // default is different lengths
			// v6.3.5 If used with countDown, this will be a number stating the number of gaps to use
			// if used with gapfill (or others), it will be boolean meaning make all as long as the longest
			// If this gets too nasty, make it just boolean and use another setting for the actual number
			if (thisSetting == "true"){
				AllSettings.exercise.sameLengthGaps = true;
			} else if (thisSetting == undefined || isNaN(Number(thisSetting))){
				AllSettings.exercise.sameLengthGaps = false;
			} else {
				AllSettings.exercise.sameLengthGaps = Number(thisSetting);
			}
			var thisSetting = myNodes[i].attributes.splitGaps; // default is keep on one line
			if (thisSetting == "true"){
				AllSettings.exercise.splitGaps = true;
			}
			var thisSetting = myNodes[i].attributes.proofReading; // default is NOT proof reading
			if (thisSetting == "true"){
				AllSettings.exercise.proofReading = true;
				AllSettings.exercise.hiddenTargets = true; // proofReading implies hidden targets
			}
			var thisSetting = myNodes[i].attributes.hiddenTargets; // default is NOT hidden targets
			if (thisSetting == "true"){
				AllSettings.exercise.hiddenTargets = true;
			}
			var thisSetting = myNodes[i].attributes.dragTimes; // default is many times
			// v6.4.2.7 The CUP exercises want dragTimes=1, but all the XML was created before we did this
			// so the default for these should be =1
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 			
				// v6.4.2.7 0 does NOT mean many. In FieldReaction I test for <=1 to disable!!
				//if (thisSetting == "0"){
				if (Number(thisSetting) > 1){
					AllSettings.exercise.dragTimes = Number(thisSetting);
				} else {
					//myTrace("ex.no setting so set dragTimes=1");
					AllSettings.exercise.dragTimes = 1;
				}
			} else {
				// v6.4.2.7 0 does NOT mean many. In FieldReaction I test for <=1 to disable!!
				// So this condition is ridiculous. It doesn't matter because the default (no setting) is covered in the initSettings to 32768
				if (thisSetting == "0"){
					AllSettings.exercise.dragTimes = 0;
				} else if (thisSetting == "1"){
					AllSettings.exercise.dragTimes = 1;
				}
			}
			//myTrace("ex setting=" + thisSetting + " finally=" + AllSettings.exercise.dragTimes);
			// the following can only be true for proofReading exercises
			var thisSetting = myNodes[i].attributes.correctMistakes; // default is NOT to correct found mistakes
			if (thisSetting == "true"){
				AllSettings.exercise.correctMistakes = true;
			}
			// the following can only be true for multiple choice exercises (I think)
			var thisSetting = myNodes[i].attributes.multiPart; // default is OR marking if several correct options
			if (thisSetting == "true"){
				AllSettings.exercise.multiPart = true;
			}
			// v6.3.5 Used to show that the whole exercise is a countDown, maybe later this
			// will be removed and you will search a para to see if it is a countDown
			//var thisSetting = myNodes[i].attributes.countDown; // default is not
			//if (thisSetting == "true"){
			//	AllSettings.exercise.countDown = true;
			//}			
			var thisSetting = myNodes[i].attributes.matchCapitals; // default is not
			if (thisSetting == "true"){
				AllSettings.exercise.matchCapitals = true;
			}
			// for countdown, you can use any character instead of _ 
			var thisSetting = myNodes[i].attributes.replaceChar; // default is undefined
			// v6.3.5 Maybe you should limit how long this can be! (undefined is the expected answer)
			AllSettings.exercise.replaceChar = thisSetting;
			
			// v6.3.5 for countdown (only at present) you can preview the main text
			var thisSetting = myNodes[i].attributes.preview; // default is not
			if (thisSetting == "true"){
				//myTrace("preview this exercise")
				AllSettings.exercise.preview = true;
			}
			// v6.4.2.4 Let questions start from other than 1
			var thisSetting = myNodes[i].attributes.questionStart; // default is 1
			if (thisSetting == undefined || isNaN(Number(thisSetting))){
				// leave the default alone
			} else {
				AllSettings.exercise.questionStart = Number(thisSetting);
			}
			//v6.4.3 Grouping exercises
			var thisSetting = myNodes[i].attributes.grouping; // default is false
			if (thisSetting == "true"){
				AllSettings.exercise.grouping = true;
			}
			//v6.5.5.0 Save detailed answers for item analysis or portfolio
			thisSetting = myNodes[i].attributes.saveDetails; // default is false
			if (thisSetting == "true"){
				AllSettings.exercise.saveDetails = true; 
			}
			//v6.5.5.8 Use the small feedback window in this exercise
			thisSetting = myNodes[i].attributes.smallFeedbackWindow;
			//myTrace("smallFBWIn in xml=" + thisSetting);
			if (thisSetting == "true"){
				AllSettings.exercise.smallFeedbackWindow = true;
			}
		}
		if (myNodes[i].nodeName.toLowerCase() == "misc") {
			var thisSetting = myNodes[i].attributes.timed; // default is not timed
			if (thisSetting == undefined || isNaN(Number(thisSetting))){
				AllSettings.misc.timed = 0;
			} else {
				AllSettings.misc.timed = Number(thisSetting);
			}
			thisSetting = myNodes[i].attributes.splitScreen; // default is not split screen
			if (thisSetting == "true"){
				AllSettings.misc.splitScreen = true;
			}
			thisSetting = myNodes[i].attributes.soundEffects; // default is on
			if (thisSetting == "false"){
				AllSettings.misc.soundEffects = false;
			}
			// v6.5.5.0 For grouping exercises into subunits
			//thisSetting = myNodes[i].attributes.subunit; // default is false
			//if (thisSetting == "true"){
			//	AllSettings.misc.subunit = true;
			//}
		}
	}
	// Although you could do this with the AP settings, the default was switched off, so to make it easy...
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/RO") >= 0) { 
		AllSettings.feedback.wrongOnly = true;
		myTrace("set wrongOnly feedback");
	}
	// v6.4.2.8 Start by getting the rule button up for TB. Now it can be set by APP, so no need to override.
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) { 
	//	AllSettings.buttons.rule = true;
	//}
	// Based on particular licences you might have different defaults for some exericse modes
	// Note that this is duplicated in convertXMLMode as CUP exercises don't have settings node, so will never come here.
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
		// EGU always uses only drag once.
		// v6.4.2.7 Now built above in case they ever adding a setting for many times - no, useless as no exercise settings
		// NO NO, AGU does have exercise settings and might want dragTimes=0
		// So, the initSettings make it 32768. Then convertXMLSettings, if used, will set it to 1. This function
		// will have set it to 0 or 1. But if you still have it set to the initial, then change it to 1 as the default.
		// Why not just make the default for CUP to be 1?
		if (AllSettings.exercise.dragTimes==32768) {
			AllSettings.exercise.dragTimes=1;
		};
		// They also want to see all feedback, not just wrong ones
		AllSettings.feedback.wrongOnly = false;
		// Also recording button is always on
		AllSettings.buttons.recording = true;
	}
	// Tense Buster does not ever want the media button to be visible.
	// And perhaps Study Skills Success too!
	// v6.3.4 This might be unnecessary as these interfaces would simply not have a media button!
	// Indeed it might be better left to the interfaces to work this out.
	//if (	_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/TB") >= 0 ||
	//	_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/RO") >= 0 ||
	//	_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/SSS") >= 0) {
	//	AllSettings.buttons.media = false;
	//}
	return AllSettings;
}

// This will read the XML template element and return an array: style[]
// style: name, properties
function getXMLStyles(XMLSource) {
	//trace("in getXMLStyles");
	XMLSource.ignoreWhite = true;
	var AllStyles = new Array();
	var myNodes = XMLSource.childNodes;
	for (var i in myNodes) {
	    if (myNodes[i].nodeName.toLowerCase() == "style") {
			var myStyle = new Object;
			myStyle = myNodes[i].attributes; 
			//trace("font from style "+myStyle.name+" is "+myStyle.font);
			dummy = AllStyles.push(myStyle);
		}
	}
	return AllStyles;
}
// This will read the XML and return an object: paragraph[] + field[] + group[]
// paragraphs: (id,) style, coordinates, xxx
// fields: id, mode, type, answer[], filename, coordinates, xxx
function getXMLContentAndFields(XMLSource, textType, index) {
	//myTrace("text is from " + textType);
	XMLSource.ignoreWhite = true;
	//var me = _global.ORCHID.LoadedExercises[0]; // only use 1 exercise object at present
	if (index != undefined) {
		me = _global.ORCHID.LoadedExercises[index];
	} else {
		me = _global.ORCHID.LoadedExercises[0];
	}
	var ExText = new Object; // build this up to return it
	ExText.field = new Array();
	ExText.group = new Array();
	ExText.media = new Array();
	ExText.paragraph = new Array();
	// v6.4.3 For new grouping exercise type.
	ExText.section = new Array();

	// you MUST read any field information first, so loop through all nodes until you find them
	var myNodes = XMLSource.childNodes;
	for (var i=0;i<myNodes.length;i++) {
		//myTrace("node is " + myNodes[i].nodeName);
		if (myNodes[i].nodeName.toLowerCase() == "field") {
			var myField = new Object();
			myField.answer = new Array();
			myField.id = myNodes[i].attributes.id; 
			myField.mode = Number(myNodes[i].attributes.mode);
			myField.type = myNodes[i].attributes.type;
			myField.group = myNodes[i].attributes.group; 
			// v6.4.3 New grouping exercise type - usually not used
			myField.section = myNodes[i].attributes.section; 
			// v6.4.2.8 Random tests can set the taborder to avoid playing with field ids
			myField.tabOrder = myNodes[i].attributes.tabOrder; 
			myField.info = new Object();
			var myCoordinates = new Object();
			myCoordinates.x = myNodes[i].attributes.x;
			myCoordinates.y = myNodes[i].attributes.y;
			myCoordinates.width = myNodes[i].attributes.width;
			myCoordinates.height = myNodes[i].attributes.height;
			myField.coordinates = myCoordinates;
			// v6.3.4 New url field has extra information to read from the xml nodeName
			if (myField.type == "i:url") {
				myField.info.url = myNodes[i].attributes.url; 
				// v6.3.4 If the url is not complete (no protocol), getURL appends my root
				// Need to work a nice way to add http:// to such a case. For now, make the author do it.
				// v6.3.4 workround for incorrect group information
				myField.group = 0; 
			}
			//trace("read field "+myField.id+"-"+myField.coordinates.width);

			// v6.3.4 Move attempt from group to field
			var myAttempt = new Object(); // initialise the space used for recording std interaction
			myAttempt.score = undefined;
			myAttempt.finalAnswer = undefined;
			
			// v6.5.4.2 Yiu, fixing 1210
			myAttempt.firstAnswer = undefined;
			myField.attempt = myAttempt;

			// find answer node
			if (myNodes[i].hasChildNodes) {
				var myFieldNodes = myNodes[i].childNodes;
				for (var j=0;j<myFieldNodes.length;j++) {
					if (myFieldNodes[j].nodeName.toLowerCase() == "answer") {
						var myAnswer = new Object;
						// v6.3.4 Overwrite for neutral marking
						if (me.settings.feedback.neutral == true) {
							myAnswer.correct = "neutral"; 
						} else {
							myAnswer.correct = myFieldNodes[j].attributes.correct; 
						}
						var specialFB = myFieldNodes[j].attributes.feedback;
						//trace(myField.mode+"&"+_global.fieldMode.GroupFeedback);
						// If feedback is score based, you don't need to associate anything with each field
						// v6.3.4 Move to settings from mode
						//if (me.mode & _global.ORCHID.exMode.QuestionFeedback) {
						//myTrace("answer=" + myAnswer.correct + " fb.scoreBased=" + me.settings.feedback.scoreBased)
						if (me.settings.feedback.scoreBased == false) {
							// otherwise find a fb id to go with each field
							if (specialFB != undefined) { // does this answer use special feedback?
								myAnswer.feedback = specialFB; 
								//trace("for field "+myField.id+" used special fb "+specialFB);
							} else { // if not, then the feedback ID depends on field type
								// only use group feedback if group ID is set and the mode agrees
								//Note: This will be an exercise level mode from Author Plus?? or will it??
								//if ((myField.mode & _global.ORCHID.fieldMode.GroupFeedback) && (myField.group != undefined)) {
								//NOTE: I have just changed this from myField.mode to me.mode as surely it is exercise level now!
								//no, no, maybe not. Yes, yes, don't leave it confused.
								// v6.3.4 Move to settings from mode
								//if (!(me.mode & _global.ORCHID.exMode.IndividualFeedback) && (myField.group != undefined)) {								
								if (me.settings.feedback.groupBased && (myField.group != undefined)) {								
									//myTrace("use group fb for field " + myField.id + " groupID=" + myField.group);
									// for grouped fields, the feedback ID is the group ID
									myAnswer.feedback = myField.group; 
									//myTrace("using group feedback for field " + myField.id + "=" + myField.group);
								} else {
									//myTrace("use individual fb for field " + myField.id + " =" + myField.id);
									// for individual fields, just use the field ID as the feedback ID
									myAnswer.feedback = myField.id; 
								}
							}
						}
						// only the default answer can contain formatting
						//trace("this answer=" + myFieldNodes[j].firstChild.nodeValue + " (unescape=" + unescape(myFieldNodes[j].firstChild.nodeValue) + ".");
						//if (j == 0) {
							// 6.0.4.0, the % in the field cannot be displayed if we use unescape()
							// So I take it out
							//myAnswer.value = unescape(myFieldNodes[j].firstChild.nodeValue);
							//myAnswer.value = myFieldNodes[j].firstChild.nodeValue;
							//thisLen = removeTags(myAnswer.value).length;
						//} else {
							// 6.0.4.0, the % in the field cannot be displayed if we use unescape()
							// So I take it out
							//myAnswer.value = removeTags(unescape(myFieldNodes[j].firstChild.nodeValue));
							//myAnswer.value = removeTags(myFieldNodes[j].firstChild.nodeValue);
							//thisLen = myAnswer.value.length;
						//}
						// to be really good you want to find the real screen space occupied by this gap
						// BUT you don't know the textFormat of the characters at this point, so the best
						// you can do is to use an 'average' character repeated x times
						// UNLESS you get authoring to tell you what the TF of the first character is!
						// (we can use .origTextFormat)
						// and we still have to assume that the answer with most characters is the longest
						// v6.3 Now we find the TF of the first field character when working out the gap length
						// so do the longestAnswer calcuation there.
						//if (thisLen > myField.info.longestAnswer.length) {
						//	//myField.info.gapChars = thisLen;
						//	myField.info.longestAnswer = myAnswer.value;
						//}
						//trace("for answer "+myField.id+","+myAnswer.value+" use fb="+myAnswer.feedback);
						// v6.3.5 APL is sometimes (accidentally) adding a CR to the end of an answer. can I safely
						// remove all whitespace here? Any reason for keeping it? I think I might need spaces
						// as an authored padding.
						var keepSpaces = true;
						myAnswer.value = removeWhiteSpace(myFieldNodes[j].firstChild.nodeValue, keepSpaces);
						// v6.4.2.4 If there are any other attributes listed in the node, save them in the Object
						for (var attr in myFieldNodes[j].attributes) {
							if (attr == "correct" || attr == "feedback") {
								// these are covered above
							}  else {
								// unexpected ones
								//myTrace("unexpected answer attr of " + attr + "=" + myFieldNodes[j].attributes[attr]);
								myAnswer[attr] = myFieldNodes[j].attributes[attr];
							}
						}; 
						myField.answer.push(myAnswer);
						//trace("read answer "+myAnswer.value+" with "+myAnswer.correct);
						//myTrace("for answer "+myField.id+","+myAnswer.value+" use fb="+myAnswer.feedback);						
					}
				// Note: media handling might change later
				// Yes, it has now been taken out of the field tag to be its own tag
				}
			}
			// add an extra space to the field width to give gaps breathing space
			//myField.info.gapWidth++;
			// this will be handled in the insertFieldText function
			dummy = ExText.field.push(myField);
			
		// in the same loop check out all media items - they are independent of field so will not clash
		} else if (myNodes[i].nodeName.toLowerCase() == "media") {
			var myMedia = new Object();
			//v6.4.2.1 All attributes might have been escaped
			myMedia.filename = unescape(myNodes[i].attributes.filename); 
			myMedia.path = unescape(myNodes[i].attributes.path);
			// v6.3.4 Add in hyperlinks
			myMedia.url = unescape(myNodes[i].attributes.url); 
			// v6.4.1 Add in parameters for video
			myMedia.duration = myNodes[i].attributes.duration; 
			myMedia.anchor = myNodes[i].attributes.anchor; // v6.4.2 also used for anchored paragraph numbers/questions
			// v6.4.2 Add in parameter for question based media to anchor to
			//myMedia.question = myNodes[i].attributes.question; // see above
			// v6.4.1 Add in parameters for stretching, with default set to boolean true
			myMedia.stretch = !(myNodes[i].attributes.stretch == "false"); 
			//if (myMedia.question!=undefined) myTrace("read question=" + myMedia.question);
			//myMedia.filename.control = myNodes[j].attributes.control;
			myMedia.id = myNodes[i].attributes.id;
			myMedia.name = unescape(myNodes[i].attributes.name); 
			myMedia.type = myNodes[i].attributes.type;
			// v6.4.2.1 Audio is ALWAYS in popup mode
			// v6.4.3 New audio type to stop streaming m:staticAudio
			//if (myMedia.type.substr(2) == "audio" || myMedia.type.substr(2) == "streamingAudio") {
			if (myMedia.type.substr(2).toLowerCase().indexOf("audio") >=0) {
				myMedia.mode = Number(myNodes[i].attributes.mode) + _global.ORCHID.mediaMode.PopUp;
			} else {
				myMedia.mode = Number(myNodes[i].attributes.mode);
			}
			//myTrace("media type=" + myMedia.type.substr(2) + " so mode=" + myMedia.mode);
			myMedia.fieldID = myNodes[i].attributes.fieldID; 
			// v6.4.2.4 Media can also have a 'number of times to be played' attribute, playTimes
			//myMedia.playTimes = myNodes[i].attributes.playTimes; 
			if (myNodes[i].attributes.playTimes==undefined || myNodes[i].attributes.playTimes<=0) {
				myMedia.playTimes =  0;
			} else {
				myMedia.playTimes = myNodes[i].attributes.playTimes;
			}
			//myTrace("playTimes = " + myMedia.playTimes);
			
			// 6.0.3.0 The new anchored type of media gets its coordinates from the first para
			// in the question which its id points to. Nothing needs to be done here as everything
			// is later keyed on the first letter of .type
			//var qPos = myMedia.type.indexOf("q");
			//if (qPos >= 0) {
			//	trace("media id " + myMedia.id + " is type " + myMedia.type);
			// //	myMedia.anchorQuestion = myMedia.id;
			//}
			// v6.3.5 Media might be marked as coming from a shared location
			// but the default is to come from the course folder
			if (myNodes[i].attributes.location != undefined) {
				myMedia.location = myNodes[i].attributes.location;
			} else {
				myMedia.location = "course";
			}
			var myCoordinates = new Object();
			myCoordinates.x = myNodes[i].attributes.x;
			myCoordinates.y = myNodes[i].attributes.y;
			myCoordinates.width = myNodes[i].attributes.width;
			myCoordinates.height = myNodes[i].attributes.height;
			myMedia.coordinates = myCoordinates;
			//myTrace("from XML question="+myMedia.question);
			dummy = ExText.media.push(myMedia);
			//myTrace("from ExText="+ExText.media[dummy-1].question);
			// v6.3.4 Check to see if any of the media fields point to a special related text - the reading text							
			//_global.ORCHID.LoadedExercises[0].readingText = {id:me.id, name:me.name};
			if (myMedia.type == "m:text" && myMedia.mode & _global.ORCHID.mediaMode.ReadingText) {
				_global.ORCHID.LoadedExercises[0].readingText = {id:myMedia.id, name:myMedia.name};
				myTrace("reading text name=" + _global.ORCHID.LoadedExercises[0].readingText.name);
			}

		}
	}
	
	// Now that you have all fields, you can add whatever groups are necessary
	// v6.3.4 Warning. If you have an exercise that has pop-ups for some but no all questions, then
	// since these are the first fields that you go through in ExText.field array, you will end up with
	// the ExText.group array NOT being in the order of questions. This will throw out feedback order.
	// Therefore you need to find a way to go through the 'real' fields first or (better) for feedback
	// to be displayed NOT by group IDX but by group ID. See delayedFeedback in Feedback.as
	for (var i in ExText.field) {
		//myTrace("checking group for field "+ExText.field[i].ID+ " (group "+ExText.field[i].group+")");
		// only check up on interactive fields, media items aren't grouped
		if (ExText.field[i].type.indexOf("i:") >= 0) {
			// if there is no group ID (I think this shouldn't really be allowed to happen)
			// just use the field ID. This could lead to duplication of group ID in exercises
			// that mix groups and single interactive fields
			if (ExText.field[i].group == undefined) {
				ExText.field[i].group = ExText.field[i].ID;
			}
			// I could check to see if group>0 which would let me exclude i:drag, or should
			// drags actually be something else, not i:? (at present drags have group=0)
			var groupArrayIDX = lookupArrayItem(ExText.group, ExText.field[i].group, "ID");
			//trace("field " + ExText.field[i].ID + " is in groupIdx "+groupArrayIDX);
			// if this group ID doesn't exist yet, create a new group item to hold it and its mates
			if (groupArrayIDX < 0) {
				var myGroup = new Object();
				// Whilst each field holds feedback ID, we also save the ONE that we will
				// use with groupBased feedback for each group (based on the first correct answer)
				myGroup.correctFbID = undefined;
				// v6.3.4 Change name of popup object
				//myGroup.popupFieldID = undefined;
				myGroup.popup = new Object();
				myGroup.popup.fieldID = undefined;
				myGroup.popup.useField = undefined;
				myGroup.popup.useFields = []; // for multipart questions
				// v6.3.4 Move attempt from group to field (see earlier field creation loop)
				//var myAttempt = new Object(); // initialise the space used for recording std interaction
				//myAttempt.score = undefined;
				//myAttempt.finalAnswer = undefined;
				//myGroup.attempt = myAttempt;
				//ExText.field[i].attempt = myAttempt;
				// v6.3.4 Emergency patch up for drag fields having group=1
				if (ExText.field[i].type == "i:drag") {
					//myTrace("set drag group to 0");
					myGroup.ID = 0;
				} else {
					myGroup.ID = ExText.field[i].group;
				}
				//trace("added group ID=" + myGroup.ID);
				// v6.2 In order to allow deselection of targets, I want a field that lets me know
				// that a group only contains one field.
				myGroup.singleField = true;
				// v6.4.2 For surveys - check to see if the correct value is a number - assumes multipart doesn't matter
				if (Number(ExText.field[i].answer[0].correct) > 0) {
					// If it is, then for each group you simply want to know the max number for all fields
					if (Number(ExText.field[i].answer[0].correct) > myGroup.maxScore) {
						myGroup.maxScore = Number(ExText.field[i].answer[0].correct);
						//myTrace("group " + ExText.field[i].group + " maxScore=" + myGroup.maxScore);
					}
				// v6.3.4 for compound answers I want to know the max score in a group
				// this should only catch out targets not other types. If you are not using
				// multiPart scoring, then the maxScore is always 1.
				} else if (ExText.field[i].answer[0].correct=="true" || me.settings.exercise.multiPart == false) {
					myGroup.maxScore = 1;
				} else {
					myGroup.maxScore = 0;
				}
				//myTrace("field " + ExText.field[i].ID + ", first in group " + myGroup.ID + " maxScore=" + myGroup.maxScore);
				myGroup.fieldsInGroup = new Array();
				groupArrayIDX = ExText.group.push(myGroup)-1;
			} else {
				// v6.2 So this is the second (or more) field in this group, so switch off the binary field
				//myTrace("group " + myGroup.id + " is not single field and oldGroup=" + me.settings.feedback.oldGroupBased);
				ExText.group[groupArrayIDX].singleField = false;
				// v6.3.4 For group based feedback workround (old xml files) now is when you need to override
				// the default groupBased=false;
				//if (me.settings.feedback.oldGroupBased) {
				//	//myTrace("multi field in group so make it groupBased");
				//	me.settings.feedback.groupBased = true;
				//}
				// v6.3.4 Compound scoring. If a group has more than one field (and is not a simple mc)
				// you need to work out the score that you need to get on the individual fields to give yourself
				// a point for the group. It is assumed that you only EVER get 1 point for getting a group 100% correct.
				// We also assume that all fields in a group are the same type
				// This will catch groups of drags and highlights, but it doesn't matter as they should not get marked.
				if (ExText.field[i].type == "i:target" && me.settings.exercise.multiPart==false) {
					//myTrace("extra field in group, but doesn't add to maxScore, as type=" + ExText.field[i].type + " or settings=" + me.settings.exercise.multiPart);
					// v6.4.2 For surveys - check to see if the correct value is a number
					if (Number(ExText.field[i].answer[0].correct) > 0) {
						// If it is, then for each group you simply want to know the max number for all fields
						if (Number(ExText.field[i].answer[0].correct) > myGroup.maxScore) {
							myGroup.maxScore = Number(ExText.field[i].answer[0].correct);
							myTrace("group " + ExText.field[i].group + " maxScore=" + myGroup.maxScore);
						}
					}
				} else {
					// of course, only add to maxScore if this field is correct (only applies to targets)
					// it would be nice, but probably unnecessary to loop through all answers to find any correct ones
					if (ExText.field[i].answer[0].correct=="true") {
						//myTrace("add extra point to maxScore");
						ExText.group[groupArrayIDX].maxScore++;
					} else {
						//myTrace("don't add point as this answer=" + ExText.field[i].answer[0].correct);
					}
				}
				//myTrace("field " + ExText.field[i].ID + ", extra in group " + ExText.group[groupArrayIDX].ID + " maxScore=" + ExText.group[groupArrayIDX].maxScore);
			}
			//v6.3.4 Add each field IDX to the group so it is easy to merge scores and feedback
			ExText.group[groupArrayIDX].fieldsInGroup.push(i);
			
			//myTrace("for field "+ i+" the group index is "+ groupArrayIDX + " with ID " + ExText.group[groupArrayIDX].ID);
			// what is the (first) correct answer in this group for feedback purposes?
			// when we want to pop-up the answers I will need to know the text as well
			if (ExText.group[groupArrayIDX].correctFbID == undefined) {
				// v6.3.4 targetGap has answer[0] as false and answer[1] as the main correct one
				// In general, search to see if there is ANY correct answer for this field
				//if (ExText.field[i].type == "i:targetGap") {
				//	var answerIdx = 1;
				//} else {
				//	var answerIdx = 0;
				//}
				for (var j=0; j<ExText.field[i].answer.length; j++) {
					if (ExText.field[i].answer[j].correct == "true" || ExText.field[i].answer[j].correct == "neutral") {
						// v6.3.4 Group based will use groupID, individual based will use answer[i].feedback
						// but you still need to be in this IF as drags and things have non-valid groups (but answer=false)
						// I think these have been correctly set already, so just need one setting here
						//if (me.settings.feedback.groupBased) {
						//	ExText.group[groupArrayIDX].correctFbID = ExText.group[groupArrayIDX].ID;
						//} else {
						//trace("but field=" + ExText.field[i].ID + " is " + "so add fbID="+ExText.field[i].answer[answerIdx].feedback);
						ExText.group[groupArrayIDX].correctFbID = ExText.field[i].answer[j].feedback;
						//}
						break; // found a correct answer, so skip out
						//myTrace("set group " + ExText.group[groupArrayIDX].ID + " feedback to " + ExText.group[groupArrayIDX].correctFbID);
					}
				}
				//myTrace("group ID=" + ExText.group[groupArrayIDX].ID + " has .correctFB=" + ExText.group[groupArrayIDX].correctFbID);
			}
			// is there a popup field for this group? If so, hold the ID here to save time searching for it later
			// since you are only allowed 1 pop-up per group, just overwrite here - too bad
			if (ExText.field[i].type.indexOf("popup") >= 0) {
				//myTrace("group " + groupArrayIDX + " has popup field " + ExText.field[i].ID);
				ExText.group[groupArrayIDX].popup.fieldID = ExText.field[i].ID;
			}
		}
	}
	// v6.3.4 Try sorting the group array so that it is ordered by ID
	// Note that after using .sort, if you do for (var i in ExText.group) you will still get the old
	// order, but if you do for (var i=0; i<ExText.group.length; i++) it will be correct.
	// This could cause some confusion as I use both, but it shouldn't matter I don't think.
	//ExText.group.sort(groupOrdering);
	
	// debug only
	//for (var i=0; i<ExText.group.length; i++) {
	//	myTrace("group " + ExText.group[i].ID + " has pop-up field " + ExText.group[i].popup.fieldID);
	//}
	
	// v6.2 Red herrings will not have set correctFbID as no fields in the group are correct.
	// This will cause fb display to think there is no fb, so set the correctFbID to the fieldID
	// v6.2 Count them so that you can know how many clicks to allow (if limited) in target spotting
	// Note, this might cause some other types of targets (hyperlinks) to go wrong cf targets in free practice
	var redHerrings=0;
	for (var i in ExText.field) {
		var groupArrayIDX = lookupArrayItem(ExText.group, ExText.field[i].group, "ID");
		if (ExText.group[groupArrayIDX].correctFbID == undefined) {
			ExText.group[groupArrayIDX].correctFbID = ExText.field[i].answer[0].feedback;
			//trace("setting fake correctFb for group " + groupArrayIDX);
			redHerrings++;
		}
	}
	// This process is called for lots of xml defined text - only care about one set of red-herrrings though
	if (redHerrings>0) {
		_global.ORCHID.session.currentItem.clickLimit = ExText.group.length - redHerrings;
		//trace("set the click limit to be " + _global.ORCHID.session.currentItem.clickLimit);
	}

	// v6.4.3 Repeat for sections (new grouping exercise type)
	for (var i in ExText.field) {
		// only check up on interactive fields that are part of sections, media items aren't grouped
		if (ExText.field[i].type.indexOf("i:") >= 0 && ExText.field[i].section <> undefined) {
			// Have we already got this section?
			var sectionArrayIDX = lookupArrayItem(ExText.section, ExText.field[i].section, "ID");
			// if this section ID doesn't exist yet, create a new group item to hold it and its mates
			if (sectionArrayIDX < 0) {
				var mySection = new Object();
				mySection.fieldsInSection = new Array();
				mySection.ID = ExText.field[i].section;
				sectionArrayIDX = ExText.section.push(mySection)-1;
			} else {
			// So this is the second (or more) field in this section, so...
			}
			// Use an object that lets you see if a field in the section has been used for marking
			var thisField = {ID:ExText.field[i].id, idx:i, correct:false, usedInMarking:false, usedInInserting:false};
			ExText.section[sectionArrayIDX].fieldsInSection.push(thisField);
		}
	}
			
	// Now you can loop through again to find the paragraphs and use the field information to build the text.
	// There is a QUESTION wrapper used around paragraphs that make up questions that
	// can be used when gathering items from question banks. Since we are not doing that here
	// just need to replace any special fields #q with the question number and then send all paragraphs
	// in the question to the paragraph builder.
	// If the paragraph tag is at the top, send it to the paragraph builder
	var thereAreQuestions = 0;
	//v6.4.2.4 Let question numbering start from other than 1
	var questionDelta = me.settings.exercise.questionStart-1;
	var paraNum = 0; // count the paragraphs as they come in, counting within text block
	for (var i=0;i<myNodes.length;i++) {
		//myTrace("node is " + myNodes[i].toString().substr(0,32));
		if (myNodes[i].nodeName.toLowerCase() == "question") {
			thereAreQuestions++;
			// 6.0.3.0 Are there any media files that are anchored to this question?
			// if so, you will need to save the coordinates of the first paragraph and
			// reset the media coordinates relative to these.
			var mediaAnchor = new Array();
			for (var m in ExText.media) {
				// v6.4.2 In 6.4.1.5 APP outputs question based audio with id=question number
				// But if I also want to add question based images, it will clash to have them both
				// with the same ID. So I should use unique IDs and have an anchor attribute. For
				// now if it is not there, use the ID (which will apply to all APP generated exercises)
				//myTrace(ExText.media[m].id + " before question=" + ExText.media[m].anchor);
				if (ExText.media[m].type.indexOf("q:") >= 0 && ExText.media[m].anchor == undefined) ExText.media[m].anchor = ExText.media[m].id;
				//myTrace(ExText.media[m].id + " now question=" + ExText.media[m].question);
				if (ExText.media[m].type.indexOf("q:") >= 0 && ExText.media[m].anchor == thereAreQuestions) {
					//myTrace("media id=" + ExText.media[m].id + ", idx=" + m + " needs to be anchored to question " + thereAreQuestions);
					mediaAnchor.push(m);
					// and get out of the loop NO, not if you might have more than one media per question
					//break;
				}
			}
			//trace("found question "+thereAreQuestions);
			// go into the question node checking each paragraph nodes
			var myParaNodes = myNodes[i].childNodes;
			for (var j=0;j<myParaNodes.length;j++) {
				if (myParaNodes[j].nodeName.toLowerCase() == "paragraph") {
					// 6.0.3.0 record the first paragraph in this question as the anchor for the media
					// if it was anchored to this question
					if (j==0 && mediaAnchor.length > 0) {
						//trace("OK, anchor " + mediaAnchor + " to para " + paraNum);
						for (var k=0;k<mediaAnchor.length;k++) {
							ExText.media[mediaAnchor[k]].anchorPara = paraNum;
							//v6.4.2 for anchored images with mode=pushTextRight this might be the 
							// right place to add an increment to each x for paragraph in this question
							if (ExText.media[mediaAnchor[k]].mode & _global.ORCHID.mediaMode.PushTextRight) {
								// what happens if the media has no coordinates? Well, can't cope with that so
								// simply assume it is 100 and add stretch to the properties
								if (ExText.media[mediaAnchor[k]].coordinates.width < 1) {
									ExText.media[mediaAnchor[k]].coordinates.width =100;
									ExText.media[mediaAnchor[k]].stretch = true;
								}
								var delta = parseInt(ExText.media[mediaAnchor[k]].coordinates.height) + 0; // add a little horizontal buffer
								//myTrace("push right by " + delta);
								for (var g=0;g<myParaNodes.length;g++) {
									//myTrace(myParaNodes[g].nodeName + "=" + g);
									if (myParaNodes[g].nodeName.toLowerCase() == "paragraph") {
										//myTrace("start x=" + myParaNodes[g].attributes.x);
										if (myParaNodes[g].attributes.x >= ExText.media[mediaAnchor[k]].coordinates.x) {
											myParaNodes[g].attributes.x = parseInt(myParaNodes[g].attributes.x) + delta;
											//myTrace("push right to " + myParaNodes[g].attributes.x);
										}
									}
								}
								//myTrace("media x=" + ExText.media[mediaAnchor[k]].coordinates.x);
							}
						}
					}
					//trace("found para IN question "+thereAreQuestions);
					// change any #q in this section to the question number
					var originalText = myParaNodes[j].firstChild.nodeValue;
					// you could use substList for the below
					//v6.4.2.4 Let an exercises question numbering start from a particular point
					var changedText = findReplace(originalText,"#q",thereAreQuestions+questionDelta);
					// How can you relate feedback to a question number? The only link is that as you go through
					// the text of a question, you will find some fields in it. Each of those fields will reference a 
					// group (hopefully all fields in one question share the same group), so you could save the
					// question number with the group. Then when you are looking up feedback for that group,
					// you will be able to do a #q subst. This method means that if a group is represented in a later
					// question, it will be overwritten, but that is just too bad! (So don't put question wrappers
					// round things like drags).
					var myStart = changedText.indexOf("[");
					while (myStart >= 0) {
						myEnd = changedText.indexOf("]", myStart);
						thisField = changedText.substring(myStart+1, myEnd);
						//trace("field=" + thisField);
						var fieldArrayIDX = lookupArrayItem(ExText.field, thisField, "ID");
						thisGroup = ExText.field[fieldArrayIDX].group;
						var groupArrayIDX = lookupArrayItem(ExText.group, thisGroup, "ID");
						// v6.5.5.- Surely this should also have questionDelta added? I don't know this, but it seems likely
						//ExText.group[groupArrayIDX].questionNumber = thereAreQuestions;
						ExText.group[groupArrayIDX].questionNumber = Number(thereAreQuestions)+Number(questionDelta);
						//trace("in question " + thereAreQuestions + " found field=" + thisField + " and group=" + thisGroup);
						myStart = changedText.indexOf("[", myEnd);
					}
					myParaNodes[j].firstChild.nodeValue = changedText;
					dummy = ExText.paragraph.push(paraXMLtoExercise(myParaNodes[j], paraNum, ExText.field, textType));
					paraNum++;
				}
			}
		} else if (myNodes[i].nodeName.toLowerCase() == "paragraph") {
			// v6.4.2 Are there any media files anchored to this paragraph?
			//myTrace("anchor check, para id=" + myNodes[i].attributes.id);
			for (var m in ExText.media) {
				// v6.4.2 Add an id to the paragraph and an anchor to the media node (they match)
				if (ExText.media[m].type.indexOf("a:") >= 0 && ExText.media[m].anchor == myNodes[i].attributes.id) {
					//myTrace("media id=" + ExText.media[m].id + " anchored to para " + myNodes[i].attributes.id + " num=" + paraNum);
					ExText.media[m].anchorPara = paraNum;
					//v6.4.2 for anchored images with mode=pushTextRight this might be the 
					// right place to add an increment to each x for THIS paragraph (only)
					// If you are in splitscreen mode, then you should probably check the paragraph
					// width as well as you are likely to push it too far over.
					if (ExText.media[m].mode & _global.ORCHID.mediaMode.PushTextRight) {
						// what happens if the media has no coordinates? Well, can't cope with that so
						// simply assume it is 100 and add stretch to the properties
						if (ExText.media[m].coordinates.width < 1) {
							ExText.media[m].coordinates.width =100;
							ExText.media[m].stretch = true;
						}
						var delta = parseInt(ExText.media[m].coordinates.height) + 0; // add a little horizontal buffer
						//myTrace("push right by " + delta);
						if (myNodes[i].attributes.x >= ExText.media[m].coordinates.x) {
							myNodes[i].attributes.x = parseInt(myNodes[i].attributes.x) + delta;
							//myTrace("push right to " + myNodes[i].attributes.x);
						}
						//myTrace("media x=" + ExText.media[m].coordinates.x);
					}
				}
			}
			//trace("found para out of question");
			//myTrace(myNodes[i].value);
			// back to regular code
			dummy = ExText.paragraph.push(paraXMLtoExercise(myNodes[i], paraNum, ExText.field, textType));
			paraNum++;
		}
	}
	// v6.3.3 Since the rest of the code is field dependent, you can jump out quick for sections that don't
	// have fields
	if (ExText.field.length == 0) return ExText;
	
	// v6.3.3 For AGU we need to set all gaps to be the same length. One option is to do it here
	// with a general replacement of the gaps that you have already put in. Use settings to direct.
	if (me.settings.exercise.sameLengthGaps) {
		var longestGap=0;
		for (var i=0;i<ExText.field.length;i++){
			//myTrace("field " + i + " gap=" + ExText.field[i].info.gapChars + " answer=" + ExText.field[i].answer[0].value)
			if (ExText.field[i].info.gapChars > longestGap) longestGap=ExText.field[i].info.gapChars;
		}
		// v6.3.5 Since you need to replace presetGap as well as gap, set up a quickie inline function
		makeSameLength = function(thisText, marker) {
			// what will you search for? This should probably do drops as well.
			var markerStart = marker + '">';
			var markerEnd = "</a>";
			// find the start of each gap
			var gapStop=0;
			var gapStart=thisText.indexOf(markerStart, gapStop);
			var build="";
			while (gapStart>=0) {
				build+= thisText.substring(gapStop, gapStart+markerStart.length);
				gapStop=thisText.indexOf(markerEnd, gapStart);
				//trace("start at " + gapStart + " stop at " + gapStop);
				if (gapStop>gapStart && gapStart>0) {
					//thisText = thisText.substr(0,gapStart+markerStart.length) + makeString("&nbsp;", longestGap) + thisText.substr(gapStop);
					//trace("part1=" + thisText.substr(0,gapStart+markerStart.length));
					//trace("part2=" + thisText.substr(gapStop));				
					build+= makeString("&nbsp;", longestGap);
				}
				gapStart=thisText.indexOf(markerStart, gapStop);
			}
			build+=thisText.substring(gapStop, thisText.length);
			return build;
		}
		if (longestGap>0) {
			//myTrace("replace all gaps to be " + longestGap + " blanks long");
			// replace the spaces that are used to display the gap with longer ones
			var build;
			for (var i=0; i<ExText.paragraph.length;i++){
				var thisText = ExText.paragraph[i].plainText;
				//trace(build);				
				build = makeSameLength(thisText, 'i:gap');
				//build = makeSameLength(build, 'i:presetGap');
				build = makeSameLength(build, 'i:targetGap');
				ExText.paragraph[i].plainText = build;
			}
			// replace the numbers you hold for gap lengths
			for (var i=0;i<ExText.field.length;i++){
				//myTrace("field " + i + " gap=" + ExText.field[i].info.gapChars + " answer=" + ExText.field[i].answer[0].value)
				ExText.field[i].info.gapChars = longestGap;
			}
		} else {
			// v6.4.2 If you used sameLengthGaps with countdown, you will come here as no real gaps
			// Having a short gap is a problem as paragraphs don't move down properly when the words
			// are being added in. Short term fix is to increase minimum gap size
			myTrace("same length gaps, but longest=0");
			if (me.settings.exercise.sameLengthGaps < 4) me.settings.exercise.sameLengthGaps = 4;
		}
	}
	return ExText;
};

// this is a key function as it takes the XML information for 1 paragraph plus a ref to any
// fields that might be needed in this paragraph and returns an object ready for processing
paraXMLtoExercise = function(XMLNode, paraNum, Foundfields, textType) {
	//trace(">> paraXMLtoExercise start at " + Number(getTimer() - _global.ORCHID.startTime));
	//trace("pXtE node is " + XMLNode.myToString());
	//trace("pXtE fields are " + foundFields.myToString());
	var myPara = new Object;
	myPara.id = paraNum // now base it on position in array // myNodes[i].attributes.id;
	myPara.style = XMLNode.attributes.style;
	//trace("para has style " + myPara.style);
	//trace("from XML = " + myNodes[i].attributes.tabs.toString());
	if (XMLNode.attributes.tabs != "") {
		myPara.tabArray = new Array(); 
		myPara.tabArray = XMLNode.attributes.tabs.split(",");
		//for (var j in myPara.tabArray) { mytrace("added tab "+j+" at " +myPara.tabArray[j]); }
		//trace("XML tabs at " + myPara.tabArray.toString());
	}
	var myCoordinates = new Object;
	myCoordinates.x = XMLNode.attributes.x;
	myCoordinates.y = XMLNode.attributes.y;
	//if (textType == "feedback" || textType == "hint") {
	//	//trace("dealing with feedback type paragraphs");
	//	myCoordinates.width = 360;
	//} else {
		//trace("dealing with normal paragraphs");
		myCoordinates.width = XMLNode.attributes.width;
	//}
	myCoordinates.height = XMLNode.attributes.height;
	//trace("read coords x="+myCoordinates.x+" y="+myCoordinates.y+" width="+myCoordinates.width+" height="+myCoordinates.height);
	myPara.coordinates = myCoordinates;
	//trace("read raw "+ XMLNode.firstChild.nodeValue.substr(0,128)); //.charCodeAt(0,1)+rawText.charCodeAt(1,1));
	//var rawText = unescape(XMLNode.firstChild.nodeValue); // still need to process this, first to link to the fields
	// Note: cannot use unesacpe as + % etc are removed. But is there any UTF stuff it was needed for?
	var rawText = XMLNode.firstChild.nodeValue; 
	//trace("read unescaped "+ rawText.substr(0,128)); //.charCodeAt(0,1)+rawText.charCodeAt(1,1));
	// run through the text, at each rtf code or field, process to get charPos and plain text
	//var RTFCommands = new Array;
	//var RTFitem = new Object; // command (fs, 28)
	//var RTFSplit = new Object;
	//var Fields = new Array;
	//var fieldItem = new Object; 
	//var fieldSplit = new Object;
	//var myText = new Object; // text object + fields array
	//myTrace("raw=" + rawText);
	var plainText = new String(""); //builds up from raw text char by char
	var NextPos = 0;
	
	//AM: Rewrite the following loop to speed up.
	//The function of the loop is to process the fields and replaces the line breaks.
	//It is too slow to handle the characters one by one.
	/*for (var j=0;j<=rawText.length;j++){
		// Is this the start of an Orchid field? (held in the XML as [1])
		// Note: I think this should change to something like <a href="field:1">
		if (rawText.substr(j,1) == "[") {
			NextPos = rawText.indexOf("]",j+1);
			if (NextPos>j) {
				// use a temp object that looks like a field object to retrieve info
				//var myField = new Object;
				myFieldID = rawText.substr(j+1, NextPos-j-1);
				//myField.paraNum = paraNum; // myPara.id // can't use i as XML has blank nodes
				//trace("["+myField.id+"] in "+myField.paraBlock);
				//myField.charPos = plainText.length;
				// the field information (answer) is used to decide what text will initially replace the placeholder
				myFieldText = insertFieldText(myFieldID, foundFields); // 
				//trace("got field(" + myFieldID + ") " + myFieldText);
				// since field text can contain RTF, expand rawText with field contents 
				rawText = rawText.substring(0,j) + myFieldText + rawText.substring(NextPos+1,rawText.length);
				// and jump back 1 to cover this expansion
				j--;; 
			};
		}
		// XML introduces spurious line breaks. Ignore them
		else if (rawText.charCodeAt(j) == 10 || rawText.charCodeAt(j) == 13) {
		} else {
		// not a control character found so write text up to now
			plainText += rawText.substr(j,1);
		};
	};*/
	/*
	// v6.2 Now replaced with below code to allow for two versions of the string
	
	//This is the new fast code for the above loop
	var j = rawText.indexOf("[", 0);
	var fieldArrayIDX=0;
	while(j >= 0) {
		NextPos = rawText.indexOf("]", j + 1);
		if (NextPos > j) {
			myFieldID = rawText.substr(j + 1, NextPos - j - 1);
			fieldArrayIDX = lookupArrayItem(Foundfields, myFieldID, "id");
			myFieldText = insertFieldText(fieldArrayIDX, Foundfields);
			rawText = rawText.substring(0,j) + myFieldText + rawText.substring(NextPos+1,rawText.length);
			// also store the paraNum in the field array so you can link fields and twFs
			Foundfields[fieldArrayIDX].paraNum = paraNum;
			//trace("field " + myFieldID + " is in para " + paraNum);
			// AM: space between tags are ignored by flash.
			// eg. <a href="asfunction:fieldClick,17|i:drag">ddd</a> <a href="asfunction:fieldClick,18|i:drag">ddd</a>
			// So we change "</a> " to be "</a>&nbsp;"
			if (rawText.substring(j + myFieldText.length, j + myFieldText.length + 1) == " ") {
				rawText = rawText.substring(0, j + myFieldText.length) + "&nbsp;" + rawText.substring(j + myFieldText.length + 1, rawText.length);
			}
			j = j + myFieldText.length;
			j = rawText.indexOf("[", j + 1);
		} else {
			j = rawText.indexOf("[", j + 1);
		}
	}
	*/
	// The following code can build two text versions at once, one that contains spaces for
	// answers supplied by the student (used to showTheAnswers)
	// real code
	var j = rawText.indexOf("[", 0);
	var fieldArrayIDX=0;
	if (j<0) {
		// There are no fields in this text, so do nothing
		var buildText = rawText;
		var buildAnswerText = undefined;
	} else {
		// v6.3 You HAVE to find the TF of each gap otherwise you cannot find the correct number
		// of spaces to use as a substitution. So how about I put the paragraph in a temporary
		// textField, then use some kind of getTF?
		// This is good, except that the tab stops for this paragraph are NOT held in the htmlText.
		// This means that we don't know them at this point, but we save the TF and later on (in drop
		// events) we use it, and for drops that are the first thing in a paragraph we will end up removing
		// any tabs that are set.
		// v6.3.6 Merge exercise into main but also create this TF on buttons not exercise
		//_global.ORCHID.root.exerciseHolder.createTextField("tfFinder", _global.ORCHID.root.exerciseHolder.ExerciseNS.depth++, 0, -0, 300, 300);
		//var tfFinder = _global.ORCHID.root.exerciseHolder.tfFinder;
		_global.ORCHID.root.buttonsHolder.createTextField("tfFinder", _global.ORCHID.root.buttonsHolder.ButtonsNS.depth++, 0, 0, 300, 300);
		var tfFinder = _global.ORCHID.root.buttonsHolder.tfFinder;
		tfFinder._visible = false;
		tfFinder.html = true;
		tfFinder.wordWrap = true;
		tfFinder.multiline = true;
		tfFinder._xscale = 100;
		tfFinder._yscale = 100;
		tfFinder.autoSize = true;
		tfFinder.htmlText = rawText;
		// v6.3 for format finding
		var thisTF = new TextFormat();
		var charInTFFinder = 0;
		//myTrace("raw=" + rawText);
		//myTrace("tfFinder.text=" + tFFinder.text);
		
		// v6.5.4.1 AR Also convert a tab at the beginning of the line followed by a field
		if (j>0 && rawText.substr(j-1, 1).charCodeAt(0) == 9) {
			var buildText = rawText.substr(0,j-1) + "<tab>";
			var buildAnswerText = rawText.substr(0,j-1) + "<tab>";
		} else {
			var buildText = rawText.substr(0,j);
			var buildAnswerText = rawText.substr(0,j);
		}
		while (j >= 0) {
			k = rawText.indexOf("]", j + 1);
			// did you find a closing brace?
			if (k > j) {			
				myFieldID = rawText.substring(j + 1, k);
				fieldArrayIDX = lookupArrayItem(Foundfields, myFieldID, "id");
				// also store the paraNum in the field array so you can link fields and twFs
				Foundfields[fieldArrayIDX].paraNum = paraNum;
				//trace("fieldText=" + myFieldText);
				// v6.3 Find this field in the tFFinder textfield and get that location's TF
				//myTrace("search " + "[" + myFieldID + "]" + " in " + tFFinder.text);
				charInTFFinder = tFFinder.text.indexOf("[" + myFieldID + "]");
				thisTF = tFFinder.getTextFormat(charInTFFinder);
				// v6.3 Add in the tab stops - see above comment
				thisTF.tabStops = myPara.tabArray;
				//myTrace("use tabs=" + thisTF.tabStops);
				// save it for later use
				FoundFields[fieldArrayIDX].origTextFormat = thisTF;
				//myTrace("found field " + "[" + myFieldID + "]" + " at " + charInTFFinder + " with tabs=" + thisTF.tabStops);
				// v6.3.4 Drop fields should always be underlined
				if (FoundFields[fieldArrayIDX].type == "i:drop") {
					FoundFields[fieldArrayIDX].origTextFormat.underline = true;
					//myTrace("found field " + "[" + myFieldID + "]" + " TF.underline=" + thisTF.underline);
				}
				// thisTF = new TextFormat("Verdana", 10);
				// work out the text that you want to appear where the field is
				buildText += insertFieldText(fieldArrayIDX, Foundfields, thisTF);
				// find the text that you want to appear where the field is when the answers are displayed
				buildAnswerText += insertNonGapText(fieldArrayIDX, Foundfields);
				// if there is a space after the closing brace, turn it into a &nbsp;
				if (rawText.substr(k+1, 1) == " ") {
					// xxxx
					buildText += "&nbsp;"
					buildAnswerText += "&nbsp;"
					//buildText += " ";
					//buildAnswerText += " ";
					k++;
				}
				// v6.5.4.1 AR Try repeating this with tabs too - seems to work nicely. Otherwise you lose them between targets
				if (rawText.substr(k+1, 1).charCodeAt(0) == 9) {
					buildText += "<tab>"
					buildAnswerText += "<tab>"
					k++;
				}
			} else {
				// if not, just ignore the opening brace, clearly it is not part of a field
				k = j;
			}
			// move to the char after the field to find the next opening brace
			j = rawText.indexOf("[", k);
			if (j > k) {
				// if you find another, copy up to it
				//trace("from one to next=" + rawText.substring(k,j) + "#");
				buildText += rawText.substring(k+1,j);
				buildAnswerText += rawText.substring(k+1,j);
			} else {
				// otherwise copy to the end
				//trace("copy to end=" + rawText.substr(k) + "#");
				buildText += rawText.substr(k+1);
				buildAnswerText += rawText.substr(k+1);
			}
			//myTrace("build=" + buildText);
			//myTrace("buildA=" + buildAnswerText);
		}
		// v6.3.6 Move this to buttons from exercise
		//_global.ORCHID.root.ExerciseHolder.tfFinder.removeTextField();
		_global.ORCHID.root.buttonsHolder.tfFinder.removeTextField();
		delete tfFinder;
	}

	// save the resulting strings in the return object
	var plainText = findReplace(buildText, chr(10), "");
	plainText = findReplace(plainText, chr(13), "");
	myPara.plainText = plainText;
	if (buildAnswerText != undefined) {
		var gapText = findReplace(buildAnswerText, chr(10), "");
		gapText = findReplace(gapText, chr(13), "");
		myPara.gapText = gapText;
	} else {
		myPara.gapText = myPara.plainText;
	}
	//myTrace("plainText=" + plainText);
	//trace(">> paraXMLtoExercise finish at " + Number(getTimer() - _global.ORCHID.startTime));
	return myPara;
}

// Having read a field ID from the text, this will build the <a> tag + the initial display text
// so that the paragraph text can be completed
// v6.2 - you cannot pass the TF as you don't know it!!
// v6.3 So find it out!
function insertFieldText(fieldIDX, Fields, TF) {
	//myTrace("inserting field " + fieldIDX);
	//var i = lookupArrayItem(Fields, fieldID, "id");
	//trace("answer is ["+Fields[fieldIDX].answer[0].value + "]");
	var aTagHeader = "<a href=\"asfunction:fieldClick,"+Fields[fieldIDX].id+"|" + Fields[fieldIDX].type +"\">";
	var aTagFooter = "</a>";
	// what is returned will depend on the type of field
	var extraSpace = 0;
	switch (Fields[fieldIDX].type) {
		case "i:target":
		case "i:popup":
		case "i:drag":
		case "i:highlight":
		// v6.3.4 New drop type - requires first answer to be shown
		case "i:dropInsert":
		// v6.3.4 Add in hyperlinks
		case "i:url":
		// v6.4.3 And for text pop-ups
		case "i:text":
		// v6.3.5 And countdown "avoiders"
		case "i:countDown":
		// these fields initially display the first and only answer, formatted as per authoring
			return aTagHeader + Fields[fieldIDX].answer[0].value + aTagFooter;
			break;			
		case "i:dropdown":
			// This will insert a drop-down list at this point
			//Note: just put in a gap for now, but a special symbol would be nice
			//extraSpace = 2;
			// do not break from this case statement as we want to share the gapfill width calculation
			// v6.3.3 Dropdown: we MIGHT need the gap to be wider so as not to lose letters under the select box
			// IF there are more options than items in the list box. 5 is hardcoded in createSelectBox in FieldReaction.as
			if (Fields[fieldIDX].answer.length > 5) {
				extraSpace = 16; // pixels for the scroll bar width
			}
		case "i:targetGap":
		//case "i:presetGap":
		case "i:gap":
			// To measure the correct number of space used to make a gap,
			// I create a temporary text field and put the longest answer there.
			// After that, I clear and fill the text field with space character until its width
			// is larger than the text field with the longest answer.
			// This method is only accurate when we can get the correct textFormat (TF) of the gap.
			// v6.3.6 Merge exercise into main but also create this TF on buttons not exercise
			//_global.ORCHID.root.exerciseHolder.createTextField ("fieldTest", _global.ORCHID.testDepth, 0 , 0 , 10 , 10);
			//var myTestGap = _global.ORCHID.root.exerciseHolder.fieldTest;
			_global.ORCHID.root.buttonsHolder.createTextField ("fieldTest", _global.ORCHID.testDepth, 0 , 0 , 10 , 10);
			var myTestGap = _global.ORCHID.root.buttonsHolder.fieldTest;
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
			// v6.3 This WILL be passed to this function now
			// TF = new TextFormat("Verdana", 10);
			// v6.3 Another complication is that longestAnswer can't be found by just counting characters
			// otherwise "gap fill" is longer than "dropdown" - which it isn't in any font! So this should really
			// loop for each answer comparing real lengths. THEN you can save longestAnswer and gapChars.
			// v6.3.4 New detail - if the correct answer is made up of certain characters, the extra SPACE
			// at the end once you have found the number of spaces that matches might be too little to let
			// the cursor do its job. This means that typing the correct answer does not fit during typing
			// though it does once displayed. What is the minimum by which the length of the box should
			// exceed the length of the answer?
			// One approach might be to add the extraSpace here. This will often force an extra space. Whilst
			// this will work, I wonder if I can instead just make the editing box a fraction longer instead since
			// the actual gap is the perfect length already. Yes, it appears you can. Done in createTypingBox.
			//extraSpace += 4;
			// v6.5 On a Mac this doesn't quite make the dropdown box, or gap, wide enough. Fixed by updating Mac Flash Player to 9.0.124.0
			
			myTestGap.setNewTextFormat(TF);
			var currentLongest = 0;
			for (var j in Fields[fieldIDX].answer) {
				myTestGap.text = Fields[fieldIDX].answer[j].value;
				//myTrace("this answer is " + myTestGap.text + " _width " + myTestGap._width +  " textWidth " + myTestGap.textWidth);
				var fieldWidth = myTestGap._width + extraSpace; // v6.3.3 see note for dropdown width
				if (fieldWidth > currentLongest) {
					Fields[fieldIDX].info.longestAnswer = myTestGap.text;
					currentLongest = fieldWidth;
					myTestGap.text = "";
					var i = 0;
					while(myTestGap._width <= fieldWidth) {
						myTestGap.text = myTestGap.text + " ";
						i++;
					}
					// v6.2 Since you are counting, why not save how many spaces in this format are needed?
					Fields[fieldIDX].info.gapChars = i;
				}
			}
			//myTrace("longest answer is " + Fields[fieldIDX].info.longestAnswer + " _width " + currentLongest + " spaces=" + Fields[fieldIDX].info.gapChars);
			// v6.3.6 Move TF to buttons
			//_global.ORCHID.root.exerciseHolder.fieldTest.removeTextField();
			_global.ORCHID.root.buttonsHolder.fieldTest.removeTextField();
			delete myTestGap;
			//myTrace("so the longest is " + Fields[fieldIDX].info.longestAnswer + " at " + currentLongest + " in font " + TF.font + " " + TF.size);
			//mytrace(Fields[fieldIDX].info.gapChars + " spaces to make width=" + myTestGap._width + " (" + Fields[fieldIDX].info.longestAnswer + ")");
			//myTestGap.removeTextField();
			//trace("inserting a select field, answer="+Fields[fieldIDX].answer[0].value);
			//return aTagHeader + Fields[fieldIDX].answer[0].value + aTagFooter;
			//var extraSpace = 1;
			// v6.3.4 Special type of gapfills is also a proof-reading. So the actual field insert is as if it
			// were a i:target;
			//if (_global.ORCHID.LoadedExercises[0].settings.exercise.correctMistakes) {
			// v6.3.5 change behaviour of targetGap/presetGap
			// v6.4.3 Now we might be going back to the original. If targetGap AND proofreading, then initially hide the gap. errorCorrection
			// It makes more sense to use hiddenTargets
			//if (Fields[fieldIDX].type == "i:targetGap" && _global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
			// #errorCorrection problem#
			if (Fields[fieldIDX].type == "i:targetGap" && _global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets) {
				// Try putting spaces into the text (as if it is a real gap) and the text directly into the cover
				// But that gives us the problem that we are putting a gap for the longest answer there - what a giveaway.
				// So I think we do have to treat this just as a target initially. 
				return aTagHeader + Fields[fieldIDX].answer[0].value + aTagFooter;
				//return aTagHeader + makeString("&nbsp;", Fields[fieldIDX].info.gapChars) + aTagFooter;
			} else {
				// AM: return space with underline instead of "_" characters.
				// The field is underline in the exercise xml file.
				// If we display "_" characters, the line may be thicker than normal.
				//return "<u>" + aTagHeader + makeString("&nbsp;", Fields[fieldIDX].info.gapWidth+extraSpace) + aTagFooter + "</u>";
				// QUESTION - is a non html space the same width (in Flash) as an html &nbsp; ?
				return "<u>" + aTagHeader + makeString("&nbsp;", Fields[fieldIDX].info.gapChars) + aTagFooter + "</u>";
			}
			break;
		/*
		case "i:gap":
			// gapfill displays a line (of variable length)
			//trace("gap field " + i + " has gapWidth=" + Fields[fieldIDX].info.gapWidth);
			return aTagHeader + makeString("_", Fields[fieldIDX].info.gapWidth) + aTagFooter;
			break;			
		*/
		case "i:drop":
			// drop displays a symbol of some sort - this should be selectable in authoring
			// it would be nice to use <u>&nbsp;<font="Wingdings">\u2734</font>&nbsp;</u>
			// but Wingdings doesn't work right now!
			// CUP just wants underlining for the drop zone
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
				return "<u>" + aTagHeader + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + aTagFooter + "</u>";
			} else {
				return "<u>" + aTagHeader + "&nbsp;&nbsp;•&nbsp;&nbsp;" + aTagFooter + "</u>";
				//return aTagHeader + "&nbsp;&nbsp;•&nbsp;&nbsp;" + aTagFooter;
			}
			Fields[fieldIDX].info.gapChars = 5;
			break;			
		// Note: media handling will not be mixed up with fields
	};
	return ""; // this field ID was not found!
};
// v6.2 Almost a duplication of the above, except that you just replace fields that 
// do not deal with student input (!gaps, drops, pop-ups, dropdown)
function insertNonGapText(fieldIDX, Fields) {
	var aTagHeader = "<a href=\"asfunction:fieldClick,"+Fields[fieldIDX].id+"|" + Fields[fieldIDX].type +"\">";
	var aTagFooter = "</a>";
	// what is returned will depend on the type of field
	//var extraSpace = 0;
	switch (Fields[fieldIDX].type) {
		case "i:target":
		case "i:drag":
		case "i:highlight":
		// v6.3.4 Add in hyperlinks
		case"i:url":
		// v6.4.3 And text pop-ups
		case"i:text":
		// v6.3.4 New hybrid type for correcting proof reading mistakes
		// is this in the right place? This function is for displaying answers, by which time targetGaps are real gaps?
		//case "i:targetGap":
		//case "i:presetGap":
		// v6.3.4 New type for dropping anywhere in a target
		case "i:insertDrop":
		// v6.3.4 New type for avoiding words in a countDown
		case "i:countDown":
		// these fields display the first and only answer, formatted as per authoring
			return aTagHeader + Fields[fieldIDX].answer[0].value + aTagFooter;
			break;			
		case "i:popup":
		case "i:dropdown":
		case "i:gap":
		case "i:drop":
		// v6.4.2.8 See above note #errorCorrection problem#
		case "i:targetGap":
			return "[" + Fields[fieldIDX].id + "]";
			break;			
	};
	return ""; // this field ID was not found!
};

// simply send back plain text from an HTML tagged string
// Note: Not written yet!
function removeTags(rawText){
	// run through the text finding the begin and end of tags and ignoring them
	return rawText;
// 	var plainText = new String(""); 
// 	var NextPos = 0;
// 	for (var j=0;j<=rawText.length;j++){
// 		// Is this the start of an HTML tag?
// 		if (rawText.substr(j,1) == "<"){
// 			// check that this isn't a real \ character
// 			if (rawText.substr(j+1,1) == "\\") {
// 				// it is a real character then so skip over the next one
// 				plainText += "\\";
// 				j++;
// 			}
// 			else {
// 				NextSpacePos = rawText.indexOf(" ",j+1)+1;
// 				if (NextSpacePos < 0) {NextSpacePos = rawText.length};
// 				NextStrokePos = rawText.indexOf("\\",j+1);
// 				if (NextStrokePos < 0) {NextStrokePos = rawText.length};
// 				if (NextSpacePos < NextStrokePos) {NextPos = NextSpacePos}
// 				else {NextPos = NextStrokePos};
// 				// pull out these control characters
// 				if (NextPos>j) {j=NextPos-1};
// 			};
// 		}
// 		// XML introduces spurious line breaks. Ignore them.
// 		else if (rawText.charCodeAt(j) == 10 || rawText.charCodeAt(j) == 13) {
// 		}
// 		else {
// 		// not a control character found so write text up to now
// 			plainText += rawText.substr(j,1);
// 		};
// 	};
// 	return plainText;
};
// v6.3.5 function to remove white space from around a word
removeWhiteSpace = function(phrase, keepSpaces) {
	var build = phrase;
	var charsToRemove = String.fromCharCode(13) + String.fromCharCode(10);
	if (!keepSpaces) charsToRemove += " ";	
	for (var i=0; i<build.length; i++) {
		if (charsToRemove.indexOf(build.charAt(i))<0) {
			build = build.substring(i);
			break;
		}
	}
	var endChar = build.length;
	while (endChar--) {
		if (charsToRemove.indexOf(build.charAt(endChar))<0) {
			build = build.substring(0,endChar+1);
			break;
		}
	}
	return build;
}

// This function searches an XML node for all occurences of a particular sub node
// It returns an array of strings, each of which represents an XMLNode
getNodes = function(XMLNode, nodeName) {
	var delimiter = chr(30); // which character is this?
	var gnString = getNodesString(XMLNode, nodeName, delimiter);
	var gnArray = gnString.split(delimiter);
	removeLast = gnArray.pop(); // the above technique creates a spurious array item at the end
	return gnArray;
}
getNodesString = function (XMLNode, nodeName, delimiter) {
	if (XMLNode.nodeName.toLowerCase() eq nodeName) { // we have hit
		return XMLNode.toString()+delimiter; // send back the node, but with an attached record separator
	} else if (XMLNode.hasChildNodes) {
		var build = "";
		var myLength = XMLNode.childNodes.length;
		for (var i=0;i<myLength;i++) {
			build+=(getNodesString(XMLNode.childNodes[i], nodeName, delimiter));
		}
		return build;
	} else {
		return;
	}
}

// Remove white space from an XML object. If you have read from a file there will be a lot
// of empty nodes from line breaks etc.
// This function acts on the original object.
// Arg: full, boolean signifying if white space (not space bar) is removed from within a node
XMLNode.prototype.stripWhite = function(full) {
	// internal function to see if a string contains ONLY white space
	function removeWhite(str, full){
		var xStr = "";
		var strLength = str.length;
		// the simple route is just to return null if this node is JUST white space
		if (full ne true) {
			var justWhite = true;
			for (var i=0; i<strLength; i++) {
				if (str.charCodeAt(i) >= 32) {
					justWhite = false;
					return (str);
				}
			}
			return "";
		} 
		// when you are passed a string, pull out all white spaces (apart from spaces)
		for (var i=0; i<strLength; i++) {
			if (str.charCodeAt(i) > 31) {
				xStr += str.substr(i,1);
			}
		}
		// if you are left with JUST spaces, treat it as an empty node
		var justSpaces = true;
		var strLength = str.length;
		for (var i=0; i<strLength; i++) {
			if (str.charCodeAt(i) ne 32) {
				justSpaces = false;
				break;
			}
		}
		if (justSpaces) xStr="";
		return (xStr);
	}
	if (this.nodeType eq 1){ // element node handling
		var chLength = this.childNodes.length;
		for (var i=0;i<chLength;i++){
			this.childNodes[i].stripWhite(full);
		}
	} else {
		if (this.nodeType eq 3) { // text node handling
		//trace("deep is still " + deep);
			this.nodeValue = removeWhite(this.nodeValue, full);
			if (this.nodeValue eq ""){
				this.nextSibling.stripWhite(full);
				this.removeNode();
			}
		}
	}
}

// this is for testing purposes to allow easy print outs of XML structures
XMLNode.prototype.myToString = function() {
	function spaceOut() {
		var sStr = "";
		for (var i=0;i<XMLNode.spaces;i++) {
			sStr += " ";
		}
		return (sStr);
	}
	var xStr = "";
	XMLNode.spaces += 4;
	if (this.nodeType eq 1) {
		xStr += spaceOut() +"<"+this.nodeName;
		var attr = this.attributes;
		for (var eachAttr in attr) {
			xStr += " " + eachAttr + "='" + this.attributes[eachAttr] + "'";
		}
		xStr += ">";
		if (this.firstChild.nodeType eq 1) xStr+="\n";
		var chLength = this.childNodes.length;
		for (var i=0;i<chLength;i++) {
			xStr+=this.childNodes[i].myToString();
		}
		if (this.lastChild.nodeType eq 1) xStr+=spaceOut();
		xStr+= "</" + this.nodeName + ">\n";
		XMLNode.spaces -= 4;
	} else {
		xStr += this.nodeValue;
		XMLNode.spaces -= 4;
		if (this.nextSibling.nodeType eq 1) xStr+= "\n";
	}
	return (xStr);
}
XML.prototype.myToString = function() {
	//return this.firstChild.toString();
	var xStr="";
	if(this.xmlDecl ne null) {
		xStr += this.xmlDecl + "\n";
	}
	if (this.docTypeDecl ne null) {
		xStr += "    " + this.docTypeDecl + "\n";
	}
	xStr+=this.firstChild.myToString();
	return (xStr);
}
