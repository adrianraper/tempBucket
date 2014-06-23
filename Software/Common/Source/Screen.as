//Methods to control each screen

//screen.init
//Intialize the objects in the screen. Set handler against user input of the objects 

//screen.setLiterals
//Set the interface language to default language

//screen.display
//Set the screen to visible

//screen.clear
//Set the screen to invisible

_global.ORCHID.root.buttonsHolder.BaseScreen.init = function() {
	//myTrace("BaseScreen.init");
	//this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	//this.help_pb.setReleaseAction(_global.ORCHID.viewObj.cmdHelp);
	//this.scratchPad_pb.setReleaseAction(_global.ORCHID.viewObj.cmdScratchPad);
	//this.progress_pb.setReleaseAction(_global.ORCHID.viewObj.cmdProgress);
	this.loaded = true;
	//this.setLiterals();
}

_global.ORCHID.root.buttonsHolder.BaseScreen.setLiterals = function() {
	//trace("BaseScreen.setLiterals");
	//this.navExit_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("exit", "buttons"));
	//this.help_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("help", "buttons"));
	//this.scratchPad_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("scratchPad", "buttons"));
	//this.progress_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("progress", "buttons"));
	//this.exMarking_pb.setReleaseAction(_global.ORCHID.literalModelObj.getLiteral("marking", "buttons"));
}

_global.ORCHID.root.buttonsHolder.BaseScreen.display = function() {
	//trace("BaseScreen.display");
	this._visible = true;
}

_global.ORCHID.root.buttonsHolder.BaseScreen.clear = function() {
	//trace("BaseScreen.clear");
	this._visible = false;
}

//The literal selection box is moved to login screen
//_global.ORCHID.root.buttonsHolder.LiteralScreen.init = function() {
//	this.literal_cb.setChangeHandler("cmdChangeLanguage", _global.ORCHID.viewObj);
//}

//_global.ORCHID.root.buttonsHolder.setLiterals = function() {
//}

//_global.ORCHID.root.buttonsHolder.display = function() {
//	this._visible = true;
//}

//_global.ORCHID.root.buttonsHolder.clear = function() {
//	this._visible = false;
//}

_global.ORCHID.root.buttonsHolder.ExerciseScreen.init = function() {
	// v6.4.2.7 In case the fla doesn't set this variable
	if (_global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight == undefined) {
		_global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight = 509;
	}
	//myTrace("init ExerciseScreen");
	this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	this.navCourseList_pb.setReleaseAction(_global.ORCHID.viewObj.cmdCourseList);
	this.help_pb.setReleaseAction(_global.ORCHID.viewObj.cmdHelp);
	this.exMarking_pb.setReleaseAction(_global.ORCHID.viewObj.cmdMarking); // ar#869
	this.exFeedback_pb.setReleaseAction(_global.ORCHID.viewObj.cmdFeedback);
	// print button should only be here if we are running Flash v7
	this.exPrint_pb.setReleaseAction(_global.ORCHID.viewObj.cmdPrint);
	this.exResources_pb.setReleaseAction(_global.ORCHID.viewObj.cmdListResources);
	this.navForward_pb.setReleaseAction(_global.ORCHID.viewObj.cmdForward);
	this.navBack_pb.setReleaseAction(_global.ORCHID.viewObj.cmdBack);
	this.navMenu_pb.setReleaseAction(_global.ORCHID.viewObj.cmdMenu);
	this.progress_pb.setReleaseAction(_global.ORCHID.viewObj.cmdProgress);
	this.scratchPad_pb.setReleaseAction(function() {myTrace("hint setReleaseAction"); _global.ORCHID.viewObj.cmdScratchPad()});
	// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
	this.exRule_pb.setReleaseAction(_global.ORCHID.viewObj.cmdRule);
	this.exRelated_pb.setReleaseAction(_global.ORCHID.viewObj.cmdRelated);
	this.exReadingText_pb.setReleaseAction(_global.ORCHID.viewObj.cmdReadingText);
	// CUP noScroll code
	this.shrinkExample_pb.setReleaseAction(_global.ORCHID.viewObj.cmdShrink);
	this.expandExample_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExpand);
	//this.hint_pb.setReleaseAction(function() {myTrace("hint setReleaseAction"); _global.ORCHID.viewObj.cmdDictionaries()}); 
	this.hint_pb.setReleaseAction(_global.ORCHID.viewObj.cmdDictionaries); 
	//myTrace("hint button=" + this.hint_pb);
	// v6.4.2.4 Start again button
	this.navStartAgain_pb.setReleaseAction(_global.ORCHID.viewObj.cmdStartAgain);
	
	// v6.2 Trouble is, you might not have established yet if you are in FSP yet!
	// so do a sort of double test in the ocx loading portion as well.
	//this.exRecorder_mc.play_pb.setReleaseAction(_global.ORCHID.viewObj.cmdPlay);
	//this.exRecorder_mc.record_pb.setReleaseAction(_global.ORCHID.viewObj.cmdRecord);
	//this.exRecorder_mc.stop_pb.setReleaseAction(_global.ORCHID.viewObj.cmdStop);
	this.play_pb.setReleaseAction(_global.ORCHID.viewObj.cmdPlay);
	this.record_pb.setReleaseAction(_global.ORCHID.viewObj.cmdRecord);
	this.stop_pb.setReleaseAction(_global.ORCHID.viewObj.cmdStop);
	this.setup_pb.setReleaseAction(_global.ORCHID.viewObj.cmdSetupRecorder);
	// v6.5.1 yiu new buttons for recorder 
	this.pause_pb.setReleaseAction(_global.ORCHID.viewObj.cmdPause);
	this.save_pb.setReleaseAction(_global.ORCHID.viewObj.cmdSave);
	this.compare_pb.setReleaseAction(_global.ORCHID.viewObj.cmdCompareWaveforms);
	
	this.onPlayFinished = function() {
		//myTrace("in onPlayFinished for this=" + this);
		this.stop_pb.onRelease();
	}

	// The CUP project wants to be able to start a test whilst you are in an exercise.
	// You can do this here as APO will not have the button
	this.exTest_pb.setReleaseAction(_global.ORCHID.viewObj.cmdTestInExercise);

	//this.markingOptions.instant_rb.setChangeHandler("cmdInstantMarking", _global.ORCHID.viewObj);
	//this.markingOptions.delayed_rb.setChangeHandler("cmdDelayedMarking", _global.ORCHID.viewObj);
	//myTrace("set the release action on the marking options for brand=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
	// v6.2 WOW, I don't know the branding when this is run! So I will have to do both of these I guess
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		// v6.2 CUP option for 1 check box rather than two radio buttons - carry it on?
		//myTrace("set the release action on the instant cb");
		this.markingOptions.instant_cb.setReleaseAction(_global.ORCHID.viewObj.cmdChangeMarking);
	//} else {
		this.markingOptions.instant_rb.setReleaseAction(_global.ORCHID.viewObj.cmdInstantMarking);
		this.markingOptions.delayed_rb.setReleaseAction(_global.ORCHID.viewObj.cmdDelayedMarking);
	//}
	// v6.3.4 Special buttons, used initially in SSS
	this.exTip_pb.setReleaseAction(_global.ORCHID.viewObj.cmdTip);
	this.exWeblink_pb.setReleaseAction(_global.ORCHID.viewObj.cmdWeblink);

	// v6.3.5 countDown controller is added (generally invisible, of course)
	this.cdController.cdGuessWord_pb.setReleaseAction(_global.ORCHID.viewObj.cmdGuessWord);
	this.cdController.cdStats_pb.setReleaseAction(_global.ORCHID.viewObj.cmdCountdownStats);
	this.cdController.cdStats_pb.setEnabled(false); // not available until after marking
	this.cdController._visible = false;
	
	// Default is to NOT show optional buttons (otherwise they flicker)
	this.exResources_pb.setEnabled(false);
	this.exResources_gf._visible = false;
	// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
	this.exRule_pb.setEnabled(false);
	this.exRelated_pb.setEnabled(false);
	this.exReadingText_pb.setEnabled(false);
	//this.exRecorder_mc._visible = false;
	this.exTip_pb.setEnabled(false);
	this.exTimer._visible = false;

	//v6.3.3 Visual locators for controls need to be hidden
	this.jukeboxPlaceHolder._visible = false;
	this.titlePlaceHolder._visible = false;
	this.exercisePlaceHolder._visible = false;

	// 6.5.4.2 Yiu, save the default exercisePlaceHolder y, width and height
	this.exercisePlaceHolder.const_default_y	= this.exercisePlaceHolder._y; 
	this.exercisePlaceHolder.const_default_width	= this.exercisePlaceHolder._width;
	this.exercisePlaceHolder.const_default_height	= this.exercisePlaceHolder._height;
	// end 6.5.4.2 Yiu, save the default exercisePlaceHolder y, width and height

	this.noScrollPlaceHolder._visible = false;
	
	//v6.4.2.4 Tick and cross holders exist so you can get their dimensions - hide them
	this.tickHolder._visible = false;
	this.crossHolder._visible = false;
	
	this.loaded = true;
	//this.setLiterals();
}

_global.ORCHID.root.buttonsHolder.ExerciseScreen.setLiterals = function() {
	myTrace("ExerciseScreen.setLiterals");
	this.navCourseList_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("courseList", "buttons"));
	this.help_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("help", "buttons"));
	this.exMarking_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("marking", "buttons"));
	this.exFeedback_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("feedback", "buttons"));
	this.exPrint_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("print", "buttons"));
	this.exResources_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("media", "buttons"));
	this.navForward_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("forward", "buttons"));
	this.navBack_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("back", "buttons"));
	this.navMenu_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("menu", "buttons"));
	this.progress_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("progress", "buttons"));
	this.scratchPad_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("scratchPad", "buttons"));
	this.exRelated_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("related", "buttons"));
	// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
	this.exRule_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("rule", "buttons"));
	this.exReadingText_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("text", "buttons"));
	this.exTest_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("test", "buttons"));
	this.navExit_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("exit", "buttons"));

	// v6.3.4 special buttons
	this.exWeblink_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("weblink", "buttons"));
	//this.exTip_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("tip", "buttons"));
	//this.exWeblink_pb.setLabel("Weblink");
	this.exTip_pb.setLabel("IELTS Tie-in");

	// v6.4.3 Careful - the licence may not be loaded yet!
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	// the literal is hardcoded for CUP at present
	//	//this.markingOptions.instant_cb.setLabel(_global.ORCHID.literalModelObj.getLiteral("instant", "buttons"));
	//} else {
		myTrace("set instant marking lit to " + _global.ORCHID.literalModelObj.getLiteral("instant", "buttons"));
		this.markingOptions.instant_rb.setLabel(_global.ORCHID.literalModelObj.getLiteral("instant", "buttons"));
		this.markingOptions.delayed_rb.setLabel(_global.ORCHID.literalModelObj.getLiteral("delayed", "buttons"));
	//	myTrace("it is " + this.markingOptions.instant_rb.getLabel());
		//this.markingOptions.instant_rb.label = _global.ORCHID.literalModelObj.getLiteral("instant", "buttons");
		//this.markingOptions.delayed_rb.label = _global.ORCHID.literalModelObj.getLiteral("delayed", "buttons");
	//}
	// 6.0.4.0, set the text for loading progress in jukebox here.
	// do not set them in the jukebox.swf.
	_global.ORCHID.root.jukeboxHolder.loadProgress.loadStatus.text = _global.ORCHID.literalModelObj.getLiteral("loading", "labels");
	_global.ORCHID.root.jukeboxHolder.errorMsg.text = _global.ORCHID.literalModelObj.getLiteral("loadMediaFail", "labels");
	// v6.3.5 Countdown controller
	//myTrace("set guess word to " + _global.ORCHID.literalModelObj.getLiteral("guessWord", "buttons"));
	this.cdController.cdGuess_lbl.setLabel(_global.ORCHID.literalModelObj.getLiteral("guessWord", "buttons"));
	this.cdController.cdStats_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("stats", "buttons"));
	// v6.4.2 button label
	this.cdController.cdGuessWord_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("guess", "buttons"));
	// v6.3.5 Recording buttons
	//this.exRecorder_mc.play_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("play", "buttons"));
	//this.exRecorder_mc.record_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("record", "buttons"));
	//this.exRecorder_mc.stop_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("stop", "buttons"));
	this.play_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("play", "buttons"));
	this.record_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("record", "buttons"));
	this.recording_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("recording", "buttons"));
	this.playing_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("playing", "buttons"));
	this.stop_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("stop", "buttons"));
	this.setup_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("setupRecorder", "buttons"));
	// v6.5.1 yiu new buttons for recorder 
	this.pause_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("pause", "buttons"));
	this.save_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("save", "buttons"));
	this.compare_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("compareWaveforms", "buttons"));
	this.recorderBackground.caption.text = _global.ORCHID.literalModelObj.getLiteral("recorder", "buttons");
	
	// v6.3.5 hint buttons
	this.hint_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("hint", "buttons"));
	
	// v6.4.2.4 Start again button
	this.navStartAgain_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("startAgain", "buttons"));
}

// v6.5.1 Yiu to reset the button status everytime the recorder reloaded
_global.ORCHID.root.buttonsHolder.ExerciseScreen.resetRecorderBtns = function() {
	if (_global.ORCHID.projector.lcLoaded || _global.ORCHID.projector.ocxLoaded)	{
		myTrace("ExScreen.reset: display recorder buttons");
		// v6.5.5.8 I am suddenly getting a problem as this code correctly executes, but the screen doesn't change
		// I think it might be because I had many Orchid programs open. When I close them all is well.
		// But I should be able to have the Recorder running with multiple programs at the same time, right?
		this.play_pb.setVisible(true);
		this.pause_pb.setVisible(true);
		this.stop_pb.setVisible(true);
		this.record_pb.setVisible(true);
		this.recording_pb.setVisible(false);
		this.playing_pb.setVisible(false);
		this.save_pb.setVisible(true);
		this.compare_pb.setVisible(true);
		this.recorderBackground._visible = true;
		
		this.play_pb.setEnabled(false);
		this.pause_pb.setEnabled(false);
		this.stop_pb.setEnabled(false);
		this.record_pb.setEnabled(true);
		this.save_pb.setEnabled(false);
		this.compare_pb.setEnabled(false);
		
		this.setup_pb.setVisible(false); 
		this.setup_pb.setEnabled(false);
	} else {
		myTrace("ExScreen.reset: hide recorder buttons");
		this.play_pb.setVisible(false);
		this.pause_pb.setVisible(false);
		this.stop_pb.setVisible(false);
		this.record_pb.setVisible(false);
		this.recording_pb.setVisible(false);
		this.playing_pb.setVisible(false);
		this.save_pb.setVisible(false);
		this.compare_pb.setVisible(false);
		this.recorderBackground._visible = false;
		
		this.setup_pb.setVisible(true); 
		this.setup_pb.setEnabled(true);
	}
	// v6.5.5.6 Now it is OK to have pause
	//this.pause_pb.setVisible(false);		// v6.5.1 Yiu disable the pause no matter what until it works fine in future
}

_global.ORCHID.root.buttonsHolder.ExerciseScreen.display = function() {
	//trace("ExerciseScreen.display");
	this._visible = true;
	// make feedback button invisible
	this.exFeedback_pb.setEnabled(false);

	//v6.3.4 Moved into buttons movie
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//} else {
	//	var rbStyleFormat = new FStyleFormat();
	//	rbStyleFormat.textFont = "Verdana";
	//	rbStyleFormat.textSize = 10;
	//	rbStyleFormat.addListener(this.markingOptions.instant_rb, this.markingOptions.delayed_rb);
	//	rbStyleFormat.applyChanges();
	//}

	// This has been moved from screen.init to here as we don't know enough
	// during init to do this successfully.
	//v6.3.4 There is now a setting
	// to allow fake testing from browser for CUP
	//_global.ORCHID.projector.ocxLoaded = true;
	if (_global.ORCHID.LoadedExercises[0].settings.buttons.recording) {
		myTrace("screen.ex.display has recorder");
		//this.exRecorder_mc._visible = true;
		//this.exRecorder_mc.play_pb.setEnabled(false);
		//this.exRecorder_mc.stop_pb.setEnabled(false);
		//this.exRecorder_mc.record_pb.setEnabled(true);
		
		
		// v6.5.1 Yiu set it to invisible instead of enable
		/* have pause button version
		this.play_pb.setEnabled(false);
		//this.play_pb.setVisible(false);
		this.pause_pb.setEnabled(false);
		this.pause_pb.setVisible(false);
		*/
		
		// v6.5.1 yiu new buttons for recorder 
		// v6.5.5.2 AR Try to tidy this up somewhat!		
		// Just run our reset buttons function
		this.resetRecorderBtns();
		/*
		// Do you have any kind of recorder?
		if (_global.ORCHID.projector.lcLoaded || _global.ORCHID.projector.ocxLoaded) {	
			this.play_pb.setVisible(true);
			this.pause_pb.setVisible(true);
			this.stop_pb.setVisible(true);
			this.record_pb.setVisible(true);
			this.save_pb.setVisible(true);
			this.recorderBackground._visible = true;
			
			// v6.5.4.5 Completely lose this as it is usually overwritten by active recorder buttons
			this.setup_pb.setVisible(false);
			this.setup_pb.setEnabled(false);
			
			// Try to make the recording retain after you clicked "Backward" or "Forward"
			if (_global.ORCHID.viewObj.isSomethingRecorded()) {
				this.play_pb.setEnabled(true);
				this.stop_pb.setEnabled(false);
				this.record_pb.setEnabled(true);
				
				if (_global.ORCHID.projector.isRecorderV2 == true) {
					this.save_pb.setEnabled(true);
				} else {
					this.save_pb.setEnabled(false);
				}
			} else {
				this.play_pb.setEnabled(false);
				this.stop_pb.setEnabled(false);
				this.record_pb.setEnabled(true);
				this.save_pb.setEnabled(false);
				// v6.5.4.5 Completely lose this as it is usually overwritten by active recorder buttons
				this.setup_pb.setVisible(true);
				this.setup_pb.setEnabled(true);			
			}
		} else if (_global.ORCHID.projector.ocxLoaded){
			this.play_pb.setVisible(true);
			this.pause_pb.setVisible(true);
			this.stop_pb.setVisible(true);
			this.record_pb.setVisible(true);
			this.save_pb.setVisible(true);
			this.recorderBackground._visible = true;
			
			// Try to make the recording retain after you clicked "Backward" or "Forward"
			if (_global.ORCHID.viewObj.isSomethingRecorded())
			{
				this.play_pb.setEnabled(true);
				this.stop_pb.setEnabled(false);
				this.record_pb.setEnabled(true);
				
				if(_global.ORCHID.projector.isRecorderV2 == true)
					this.save_pb.setEnabled(true);
				else 
					this.save_pb.setEnabled(false);
			} else {
				this.play_pb.setEnabled(false);
				this.stop_pb.setEnabled(false);
				this.record_pb.setEnabled(true);
				this.save_pb.setEnabled(false);
			}
		} else {
			this.play_pb.setVisible(false);
			this.pause_pb.setVisible(false);
			this.stop_pb.setVisible(false);
			this.record_pb.setVisible(false);
			this.save_pb.setVisible(false);
			this.recorderBackground._visible = false;
			// AR Surely you should be setting the setup_pb to true here since you have no recorder?
		}
		this.pause_pb.setVisible(false);		// v6.5.1 Yiu disable the pause no matter what until it works fine in future
		this.recording_pb.setVisible(false); // This is only switched on after you click record
	
		// v6.5.4.5 Completely lose this as it is usually overwritten by active recorder buttons
		//this.setup_pb.setVisible(false);
		//this.setup_pb.setEnabled(false);
		*/
		
		// v6.3.4 See if you have already made the link from recording to ocx or LocalConnection		
		// Do this every time as the record controller might have changed. It won't do anything
		// if it hasn't
		//if (!_global.ORCHID.projector.ocxLoaded && !_global.ORCHID.projector.lcLoaded) {
		//myTrace("ocxLoaded=" + _global.ORCHID.projector.ocxLoaded + " and brand=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
		// AR None of this makes sense - it has all been done above
		/*
		if (!_global.ORCHID.projector.ocxLoaded) {
			// v6.3.5 Cambridge only want recording from FSP
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myTrace("but hide it for CUP as not in OCX");
				//this.exRecorder_mc._visible = false;
			} else {
				//myTrace("going to display record button, so check if lc is ok to use with " + this.exRecorder_mc);
				if (_global.ORCHID.projector.lcLoaded){
					myTrace("display says lcloaded");
					this.setup_pb.setVisible(false);
					this.setup_pb.setEnabled(false);
					//this.exRecorder_mc.record_pb.setEnabled(true);
					this.record_pb.setEnabled(true);
				} else {
					myTrace("display says lc not loaded");
					this.setup_pb.setVisible(false);
					this.setup_pb.setEnabled(true);
					//this.exRecorder_mc.record_pb.setEnabled(false);
					this.record_pb.setEnabled(false);
				}
			}
		}
		*/
	} else {
		//this.exRecorder_mc._visible = false;
	}
	// v6.3.4 It is better to display the record button and then explain why you can't do anything with it
	//	//myTrace("not in FSP (as far as exScreen.ini knows), so no recording");
	//	this.exRecorder_mc._visible = false;
	
	// v6.2 As Diane Cranz insists on using a Windows help file - this can only be shown through FSP
	// and since it uses inetwh32.dll and some roboex32.dll, then you should only show it if these
	// are loaded. The only way of knowing this is by assuming you have to have loaded the ocx
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	if (_global.ORCHID.projector.name != "FlashStudioPro") {
		//if (!_global.ORCHID.projector.ocxLoaded) {
			//myTrace("hide help button on exercise screen");
	//		this.help_pb._visible = false;
	//	}
	//}
	// do you want to show the delayed/instant marking toggle button?
	// only if the exercise mode is student chooses - otherwise it is set by the author
	// v6.3.3 Change mode to settings
	//if (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.ChooseMarking) {
	if (_global.ORCHID.LoadedExercises[0].settings.buttons.chooseInstant) {
		//myTrace("student chooses marking mode");
		//if (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.InstantMarking) {
		if (_global.ORCHID.LoadedExercises[0].settings.marking.instant) {
			//myTrace("with instant marking on to begin with");
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				this.markingOptions.instant_cb.setCheckState(true);
			} else {
				this.markingOptions.instant_rb.setState(true);
			}
		} else {
			//myTrace("with instant marking off to begin with");
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				this.markingOptions.instant_cb.setCheckState(false);
			} else {
				this.markingOptions.delayed_rb.setState(true);
			}
		}
		this.markingOptions._visible = true

	} else {
		//myTrace("student doesn't choose marking mode");
		this.markingOptions._visible = false;
	}
	// do you want to show the resources button?
	// v6.3.3 change mode to settings
	//if (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.ResourcesButton) {
	if (_global.ORCHID.LoadedExercises[0].settings.buttons.media) {
		//trace("show resources button");
		// AM: The graphic for exResources_pb button was changed from graphic to movieClip.
		// So I can make the picture invisible when the exResources_pb button is disabled.
		this.exResources_pb.setEnabled(true);
		this.exResources_gf._visible = true;
	} else {
		//trace("hide resources button");
		this.exResources_pb.setEnabled(false);
		this.exResources_gf._visible = false;
	}
	// just in case the resources list is still showing from a previous exercise
	_global.ORCHID.root.jukeboxHolder.resourcesList.removeMovieClip();
	
	// set the visual position of the jukeBox 
	// v6.3.3 Make this dependent on a placeholder in the buttons graphics
	// The whole jukebox interface ought to be in buttons since it changes for different titles
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	_global.ORCHID.root.jukeboxHolder._x = 104;
	//	_global.ORCHID.root.jukeboxHolder._y = 526;
	//} else {
	//	_global.ORCHID.root.jukeboxHolder._x = 549;
	//	_global.ORCHID.root.jukeboxHolder._y = 485;
	//}
	_global.ORCHID.root.jukeboxHolder._x = this.jukeboxPlaceHolder._x;
	_global.ORCHID.root.jukeboxHolder._y = this.jukeboxPlaceHolder._y;
	//myTrace("set jukebox colour");
	// v6.5.6.4 Leave New SSS alone. Noooo. Whilst we don't want any kind of colour setting for SSS, this
	// function is where we do branding, not just colouring.
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sss") >= 0) {
	//} else {
		var colourObj = new Color( this.jukeboxPlaceHolder.jukeboxColour);
		var cT = colourObj.getTransform();
		// v6.5 Allow other colours too. No, better done direct in jukebox.as
		var backColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
		//var buttonColour = 0x0F157A; // dark blue from AP top bar
		_global.ORCHID.root.jukeboxHolder.myJukeBox.setColour(backColour);
		//_global.ORCHID.root.jukeboxHolder.myJukeBox.setColour(backColour, buttonColour);
	//}
	
	// v6.3.5 At the moment the jukebox can pick up tab focus
	_global.ORCHID.root.jukeboxHolder.tabEnabled = false;
	_global.ORCHID.root.jukeboxHolder.tabChildren = false;
	// v6.5.5.8
	// And it seems that the Recorder buttons can too, though I don't see why they are different from any other buttons
	this.play_pb.tabEnabled = false;
	this.pause_pb.tabEnabled = false;
	this.stop_pb.tabEnabled = false;
	this.record_pb.tabEnabled = false;
	this.recording_pb.tabEnabled = false;
	this.playing_pb.tabEnabled = false;
	this.save_pb.tabEnabled = false;
	this.compare_pb.tabEnabled = false;
	this.recorderBackground.tabEnabled = false;
	this.setup_pb.tabEnabled = false;	

	// do you want the marking button?
	// switch off if the NoMarkingButtonFlag is set (as default is on) OR
	// it is a neutral marking exercise
	// v6.3.3 change mode to settings
	//if (	(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NoMarkingButton) ||
	//	 (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NeutralMarking)){
	//myTrace("show marking button=" + _global.ORCHID.LoadedExercises[0].settings.buttons.marking);
	if (!_global.ORCHID.LoadedExercises[0].settings.buttons.marking ||
		// v6.4.2.7 wrong object name
		//_global.ORCHID.LoadedExercises[0].settings.marking.neutral) {
		_global.ORCHID.LoadedExercises[0].settings.feedback.neutral) {
		this.exMarking_pb.setEnabled(false);			
		// v6.4.2.4 It should be impossible to have marking options and no marking button, but I have seen it happen
		// so to be sure, overwrite it here
		this.markingOptions._visible = false;
	} else {
		this.exMarking_pb.setEnabled(true);
	}
	
	//v6.3.5 Do you want to change the marking button text if it is in testing mode?
	//myTrace("marking named, test=" + _global.ORCHID.LoadedExercises[0].settings.marking.test);
	if (_global.ORCHID.LoadedExercises[0].settings.marking.test) {
		this.exMarking_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("submit", "buttons"));
		// switch off the feedback here, just in case
		_global.ORCHID.LoadedExercises[0].settings.buttons.feedback = false;
	} else {
		this.exMarking_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("marking", "buttons"));
	}
	
	// do you want the rule button
	// v6.3.3 change mode to settings
	//if(_global.ORCHID.LoadedExercises[0].rule != undefined && _global.ORCHID.LoadedExercises[0].rule != ""
	//	&& (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.RuleButton)) {
	if (	_global.ORCHID.LoadedExercises[0].rule != undefined && 
		_global.ORCHID.LoadedExercises[0].rule != "" &&
		_global.ORCHID.LoadedExercises[0].settings.buttons.rule) {
		this.exRule_pb.setEnabled(true);	
	} else {
		this.exRule_pb.setEnabled(false);
	}
	// v6.5.5.8 CP also has a related text (for the learning objectives). Simply duplicate the rule for this.
	if (	_global.ORCHID.LoadedExercises[0].related != undefined && 
		_global.ORCHID.LoadedExercises[0].related != "" &&
		_global.ORCHID.LoadedExercises[0].settings.buttons.related) {
		this.exRelated_pb.setEnabled(true);	
	} else {
		this.exRelated_pb.setEnabled(false);
	}
	
	// do you want the reading text button?
	// v6.3.3 change mode to settings
	//myTrace("exScreen.display, button=" + _global.ORCHID.LoadedExercises[0].settings.buttons.readingText);
	//if(_global.ORCHID.LoadedExercises[0].readingText != undefined) {
	if (	_global.ORCHID.LoadedExercises[0].readingText != undefined &&
		_global.ORCHID.LoadedExercises[0].settings.buttons.readingText) {
		//myTrace("rt button=" + _global.ORCHID.LoadedExercises[0].readingText.name);
		// v6.4.1 Note that if you have a preset button caption of 'reading text' it will make the Button
		// width go to 1 if use FGraphicButton. Why - I don't know. But be careful.
		this.exReadingText_pb.setEnabled(true);	
		this.exReadingText_pb.setLabel(_global.ORCHID.LoadedExercises[0].readingText.name);
	} else {
		this.exReadingText_pb.setEnabled(false);
	}
	// CUP noScroll code
	// Do you want to see the shrinker button for the example region?
	if (_global.ORCHID.LoadedExercises[0].regions & _global.ORCHID.regionMode.example) {
		
		if (_global.ORCHID.LoadedExercises[0].settings.misc.exampleRegionShown==false) {
			myTrace("hide example region on start up");
			_global.ORCHID.viewObj.cmdShrink();
		} else {
			//myTrace("I do want to see a shrink button");
			this.shrinkExample_pb.setEnabled(true);
			// v6.5.6.5 I don't understand why, but when I set the button to disabled, I lose the release action.
			this.shrinkExample_pb.setReleaseAction(_global.ORCHID.viewObj.cmdShrink);
			this.expandExample_pb.setEnabled(false);
		}
		// I also want them to appear on top of the title. You have to be very careful of which depth you choose.
		// I originally choose ExerciseDepth, and the Example_SP never got cleared.
		this.shrinkExample_pb.swapDepths(_global.ORCHID.MsgBoxDepth+1);
		this.expandExample_pb.swapDepths(_global.ORCHID.MsgBoxDepth+2);
	} else {
		//myTrace("There is no example region");
		this.shrinkExample_pb.setEnabled(false);
		this.expandExample_pb.setEnabled(false);
	}
	// Are the next and back buttons valid?
	// CUP doesn't want to see these buttons at either end of a unit
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		if (_global.ORCHID.session.nextItem.id == undefined) {
			this.navForward_pb.setEnabled(false);
		} else {
			this.navForward_pb.setEnabled(true);
		}
		if (_global.ORCHID.session.previousItem.id == undefined) {
			this.navBack_pb.setEnabled(false);
		} else {
			this.navBack_pb.setEnabled(true);
		}
	} else {
		this.navForward_pb.setEnabled(true);
		this.navBack_pb.setEnabled(true);
	}
	// v6.5 Allow all buttons to be hidden based on the exercise settings	
	if (!_global.ORCHID.LoadedExercises[0].settings.buttons.progress) {
		this.progress_pb.setEnabled(false);			
	} else {
		this.progress_pb.setEnabled(true);
	}
	if (!_global.ORCHID.LoadedExercises[0].settings.buttons.print) {
		this.exPrint_pb.setEnabled(false);			
	} else {
		this.exPrint_pb.setEnabled(true);
	}
	if (!_global.ORCHID.LoadedExercises[0].settings.buttons.scratchPad) {
		this.scratchPad_pb.setEnabled(false);			
	} else {
		this.scratchPad_pb.setEnabled(true);
	}
	if (!_global.ORCHID.LoadedExercises[0].settings.buttons.menu) {
		this.navMenu_pb.setEnabled(false);			
	} else {
		this.navMenu_pb.setEnabled(true);
	}
	if (!_global.ORCHID.LoadedExercises[0].settings.buttons.backward) {
		this.navBack_pb.setEnabled(false);			
	} else {
		this.navBack_pb.setEnabled(true);
	}
	if (!_global.ORCHID.LoadedExercises[0].settings.buttons.forward) {
		this.navForward_pb.setEnabled(false);			
	} else {
		// v6.6.0.5 SCORM handling
		// If this is SCORM and we have a marking button, hide the forward button as you don't want to skip exercises that can be marked.
		myTrace("screens, SCORM+marking check. scorm=" + _global.ORCHID.commandLine.scorm + " markingBtn=" + this.exMarking_pb.getEnabled());
		if (_global.ORCHID.commandLine.scorm && this.exMarking_pb.getEnabled()) {
			myTrace("screen, SCORM. SO hide forward button");
			this.navForward_pb.setEnabled(false);
		} else {
			this.navForward_pb.setEnabled(true);
		}
	}
	if (!_global.ORCHID.LoadedExercises[0].settings.buttons.hints) {
		this.hint_pb.setEnabled(false);			
	} else {
		this.hint_pb.setEnabled(true);
	}

	// v6.3.5 Hide the count down controller, it will be displayed later if needed
	if (_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Countdown") {
	//if (_global.ORCHID.LoadedExercises[0].settings.exercise.countDown) {
		// clear out any old stuff
		myTrace(this.cdController.guessList_cb + ".removeAll")
		this.cdController.guessList_cb.removeAll();
		// v6.3.5 Preview is a new option that behaves differently
		if (_global.ORCHID.LoadedExercises[0].settings.exercise.preview) {
			//myTrace("countdown preview");
			_global.ORCHID.viewObj.cmdReadingText();
		} else {
			//myTrace("visible the countdown controller");
			this.cdController._visible = true;
			this.cdController.cdStats_pb.setEnabled(false);
			this.cdController.word_i.setEnabled(true);
			this.cdController.cdGuess_lbl.setEnabled(true);
			this.cdController.cdGuessWord_pb.setEnabled(true);
		}
	} else {
		this.cdController._visible = false;
	}

	// v6.3.3 If you have come from SCORM (or anything else that preset the course), don't offer a restart
	// (let's just hope all courses have an ID>0!)
	if (_global.ORCHID.commandLine.scorm || (_global.ORCHID.commandLine.course>0) || (_global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID>0)) {
		// v6.4.2.6 Let preview see all buttons, even though you start direct
		if (_global.ORCHID.commandLine.preview) {
		} else {
			myTrace("hiding course button");
			this.navCourseList_pb.setEnabled(false);
			// v6.3.3 Also, don't show the menu button if you are going straight into a unit
			if (_global.ORCHID.commandLine.startingPoint != undefined && 
				(_global.ORCHID.commandLine.startingPoint.indexOf("unit")>=0 ||
				_global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0)) {
				myTrace("hiding menu button because startingPoint=" + _global.ORCHID.commandLine.startingPoint);
				this.navMenu_pb.setEnabled(false);
				// v6.5.6.4 And further, if this is an exercise, hide back too (need to keep forwards as it might be the only way to get out after viewing feedback)
				if (_global.ORCHID.commandLine.startingPoint.indexOf("ex:")>=0) {
					myTrace("hiding backwards buttons because startingPoint=" + _global.ORCHID.commandLine.startingPoint);
					//this.navForward_pb.setEnabled(false);
					this.navBack_pb.setEnabled(false);
				}
			} else {
				//myTrace("leaving menu button because startingPoint=" + _global.ORCHID.commandLine.startingPoint);
			}
		}
	}
	// v6.3.4 If you have come from SCORM, the default behaviour is to ignore our own progress reporting
	// v6.5 I still want to let our reporting be used - why not!
	//if (_global.ORCHID.commandLine.scorm) {
	//	this.progress_pb.setEnabled(false);
	//}

	// v6.3.4 Show the tip button if there is one!
	// v6.4.2.7 Also check on the weblink in case we are using a button (SSS)
	//myTrace("texts = " + _global.ORCHID.LoadedExercises[0].texts.length);
	// It is more complex than that!
	var me = _global.ORCHID.LoadedExercises[0];
	// get the tip ID from the media thing - SSS, just find the first non-reading text <texts> node
	var thisTextID = 0;
	var thisWeblinkID = 0;
	for (var i in me.body.text.media) {
		//myTrace("media=" + me.body.text.media[i].name);
		//myTrace("checking on media id=" + me.body.text.media[i].id);
		if (me.body.text.media[i].type == "m:text" && me.body.text.media[i].mode != _global.ORCHID.mediaMode.ReadingText) {
			thisTextID = me.body.text.media[i].id;
			// you can't break since you are searching for two things
			//break;
		} else if (me.body.text.media[i].type == "m:url" && me.body.text.media[i].coordinates.x == undefined) {
			thisWeblinkID = me.body.text.media[i].id;
			//break;
		}
	}
	// v6.5 A split screen with weblinks has them in <texts> node not <body> node
	//myTrace("texts node length=" + me.texts[0].text.length);
	//myTrace("texts media node length=" + me.texts[0].text.media.length);
	for (var i in me.texts[0].text.media) {
		//myTrace("texts media=" + me.texts[0].text.media[i].name);
		//myTrace("checking on media id=" + me.texts.text.media[i].id);
		if (me.texts[0].text.media[i].type == "m:url" && me.texts[0].text.media[i].coordinates.x == undefined) {
			thisWeblinkID = me.texts[0].text.media[i].id;
			break;
		}
	}
	if (thisTextID > 0) {
	//if (_global.ORCHID.LoadedExercises[0].texts.length > 0) {
		this.exTip_pb.setEnabled(true);
	} else {
		this.exTip_pb.setEnabled(false);
	}
	// v6.5 Having found the media ID, why don't we do something with it?
	if (thisWeblinkID > 0) {
		//myTrace("weblink on as id=" + thisWeblinkID);
		this.exWeblink_pb.setEnabled(true);
	} else {
		//myTrace("weblink off as id=" + thisWeblinkID);
		this.exWeblink_pb.setEnabled(false);
	}

	// v6.3.4 Show the timer if there is one
	if (_global.ORCHID.LoadedExercises[0].settings.misc.timed > 0) {
		//myTrace("show the timer " + this.exTimer);
		this.exTimer._visible = true;
	} else {
		this.exTimer._visible = false;
	}
	// v6.3.5 The position of the progress bar changes (can) for each screen.
	// So in the display we will reset the coords (based on a holder called progressBar)
	// If you don't have a holder on this screen, don't move the progress bar
	// v6.4.2.4 Fairly pointless as this is called way after the exercise is completed loading.
	var myController = _global.ORCHID.root.tlcController;
	//myTrace("check on the pBar holder"); 
	if (this.progressBar != undefined) {
		//myTrace("show progress bar, width=" + this.progressBar._width);
		myController._x =this.progressBar._x;
		myController._y =this.progressBar._y;
		myController._width =this.progressBar._width;
		myController._height =this.progressBar._height;
		// sometimes this gets strangely shrunken, but not always. Try forcing the scale of the font
		//myController._xscale = 100;
		myController._yscale = 100;
		//myTrace("make the pBar at x=" + myController._x + "holder invisible");
		this.progressBar._visible = false;
	}

	// v6.3.5 Need a field that can hold the tab focus if gaps get out of hand. Use title?
	this.exDetails.tabEnabled = true;
	//this.exDetails.tabChildren = true;
	this.exDetails._focusrect = false;
	
	// v6.4.2.4 Start again button - not shown until after marking
	this.navStartAgain_pb.setEnabled(false);

	// v6.4.2.8 Not in demo warning, clear it
	_global.ORCHID.root.buttonsHolder.MessageScreen.demoWarning.notInDemo._visible = false;
}

_global.ORCHID.root.buttonsHolder.ExerciseScreen.clear = function() {
	//trace("ExerciseScreen.clear");
	this._visible = false;
}

_global.ORCHID.root.buttonsHolder.MenuScreen.init = function() {
	//myTrace("MenuScreen.init");
	this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	this.navCourseList_pb.setReleaseAction(_global.ORCHID.viewObj.cmdCourseList);
	this.help_pb.setReleaseAction(_global.ORCHID.viewObj.cmdHelp)
	this.scratchPad_pb.setReleaseAction(_global.ORCHID.viewObj.cmdScratchPad);
	this.progress_pb.setReleaseAction(_global.ORCHID.viewObj.cmdProgress);
	this.mnuTest_pb.setReleaseAction(_global.ORCHID.viewObj.cmdTest);
	// v6.5.4.3 certificate button
	this.certificate_pb.setReleaseAction(_global.ORCHID.viewObj.cmdCertificate);
	//let the users clear sub menus by clicking on the menu background
	this.menuBackdrop.useHandCursor = false;
	this.menuBackdrop.onRelease = function() {
		// v6.3.6 Merge menu to main
		_global.ORCHID.root.mainHolder.clearSubMenu();
	}
	// CUP/GIU
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
	this.hint_pb.setReleaseAction(_global.ORCHID.viewObj.cmdDictionaries);
	//}		
	this.loaded = true;
	//this.setLiterals();
	
	// v6.3.5 Extend the use of the language selection
	this.literal_cb.setStyleProperty("textFont", "Verdana, _sans");
	this.literal_cb.setStyleProperty("textSize", 11);
	this.literal_cb.setChangeHandler("cmdChangeLanguage", _global.ORCHID.viewObj);
	
}

_global.ORCHID.root.buttonsHolder.MenuScreen.setLiterals = function() {
	//trace("MenuScreen.setLiterals");
	this.navExit_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("exit", "buttons"));
	this.navCourseList_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("courseList", "buttons"));
	this.help_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("help", "buttons"));
	this.scratchPad_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("scratchPad", "buttons"));
	this.progress_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("progress", "buttons"));
	this.mnuTest_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("test", "buttons"));
	// v6.5.4.3 certificate button
	//myTrace("certificate button lable=" + _global.ORCHID.literalModelObj.getLiteral("certificate", "buttons"));
	this.certificate_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("certificate", "buttons"));
	this.hint_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("hint", "buttons"));
	//v6.4.1 for scrolling of units
	this.unitsScrollDown_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("moreUnits", "buttons"));
	this.unitsScrollUp_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("moreUnits", "buttons"));
	this.unitsScrollDown_pb.setAlt(_global.ORCHID.literalModelObj.getLiteral("moreUnits", "buttons"));
	this.unitsScrollUp_pb.setAlt(_global.ORCHID.literalModelObj.getLiteral("moreUnits", "buttons"));
}

_global.ORCHID.root.buttonsHolder.MenuScreen.display = function() {
	myTrace("screens.as.MenuScreen.display");
	//v6.3.6 Allow customisation on the menu screen as well
	this.loadDefault = function() {
		//myTrace("load the default menu image");
		clearInterval(this.myInt);
		this.defaultImageHolder.attachMovie("defaultMenuImage", "loadDefaultImage", this.buttonsNS.depth++);
	}
	// if the intro screen HAS a custom image holder, try to fill it
	//v6.3.6 If you are using this technique, then the FLA should have a base that does not change
	// Then anything that you are happy to lose should go in defaultImage library Movie
	// as either this OR the customIntro will be displayed. I expect that this is just a simple logo.
	// In Author Plus, it is the Author Plus Online writing and Clarity logo that get replaced.
	// For ease of customer use, assume that this will be a jpg rather than a swf.
	if (this.customImageHolder != undefined && _global.ORCHID.commandLine.customised) {
		// v6.3.6 But the name of the custom image should come from the course.xml so that it can
		// be course specific.
		myTrace("FLA allows it, so load " + _global.ORCHID.paths.brandMovies + "CustomMenu.jpg");
		//this.customImageHolder._x = this.customImageHolder._y = 0;
		// v6.4.2 See comment in CustomIntro loading		
		var customImage = _global.ORCHID.paths.brandMovies + "CustomMenu.jpg";
		var fileExists = new LoadVars();
		fileExists._parent = this;
		fileExists.imageFile = customImage;
		fileExists.onLoad = function(success) {
			//success is true if the file exists, false if it doesnt
			if(success) {
				//the file exists
				//myTrace("it does, load it");
				this._parent.customImageHolder.loadMovie(this.imageFile);
				//delete this;
			} else {
				//myTrace("it doesn't, so load the default");
				this._parent.loadDefault();
				delete this;
			}
		}
		myTrace("check if " + customImage+ " exists");
		fileExists.load(customImage); //initiate the test
	} else {
		//myTrace("FLA has no menu customImageHolder, so load defaultImageHolder");
		// trigger the default image to load immediately, again if a placeholder is in the movie
		if (this.defaultImageHolder != undefined) {
			this.loadDefault();
		}
	}
	// v6.3.4 Add the possibility of customisation for those titles that don't have the customImageHolder
	// the mc name will be held in the licence file
	// v6.3.6 If you are using this technique, then the FLA should have everything it is happy to lose
	// in defaultImage as it will be replaced by the customisation.
	// In Author Plus, it is everything on this screen.
	// Customisation[2] = Menu
	if (_global.ORCHID.root.licenceHolder.licenceNS.customisation[2] != "" && _global.ORCHID.root.licenceHolder.licenceNS.customisation[2] != undefined) {
		myTrace("load image " + _global.ORCHID.paths.brandMovies + _global.ORCHID.root.licenceHolder.licenceNS.customisation[2] + " (licence)");
		//this.defaultImage.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + _global.ORCHID.root.licenceHolder.licenceNS.customisation[0]);
		// v6.3.5 Brand has its own path now
		//this.defaultImage.loadMovie(_global.ORCHID.paths.brandMovies + _global.ORCHID.root.licenceHolder.licenceNS.customisation[2]);
		this.defaultImageHolder.loadMovie(_global.ORCHID.paths.brandMovies + _global.ORCHID.root.licenceHolder.licenceNS.customisation[2]);
	}
	
	//trace("MenuScreen.display");
	this._visible = true;
	if (_global.ORCHID.course.useQuestionBanks) {
		this.mnuTest_pb.setEnabled(true);
		this.mnuTest_gf._visible = true;
		myTrace("show test button");
	} else {
		//myTrace("hide test button");
		this.mnuTest_pb.setEnabled(false);
		this.mnuTest_gf._visible = false;
	}
	// v6.2 As Diane Cranz insists on using a Windows help file - this can only be shown through FSP
	// v6.3.4 Removed as new CUP help file through html
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		//if (_global.ORCHID.projector.name != "FlashStudioPro") {
		//if (!_global.ORCHID.projector.ocxLoaded) {
		//	myTrace("hide help button on menu screen");
		//	this.help_pb._visible = false;
		//}
	//}
	
	// since this is really about interface not buttons, here is a good
	// place to display a menu background movie
	this.courseCaption.text = _global.ORCHID.course.scaffold.caption;

	// v6.5.6 Allow special introduction text to come from literals
	myTrace("specialIntro text field=" + this.specialIntro_txt + " intro=" + _global.ORCHID.literalModelObj.getLiteral("specialIntroduction", "labels"));
	if (this.specialIntro_txt!=undefined) {
		var substList = [{tag:"[newline]", text:newline}];
		this.specialIntro_txt.text = _global.ORCHID.root.objectHolder.substTags(_global.ORCHID.literalModelObj.getLiteral("specialIntroduction", "messages"),substList);
		this.specialIntroHeading.text = _global.ORCHID.literalModelObj.getLiteral("specialIntroduction", "labels");
	}
	
	// v6.3.3 If you have come from SCORM (or anything else that preset the course), don't offer a restart
	// (let's just hope all courses have an ID>0!)
	if (_global.ORCHID.commandLine.scorm || (_global.ORCHID.commandLine.course>0) || (_global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID>0)) {
		this.navCourseList_pb.setEnabled(false);
	}
	
	// v6.3.4 If you have come from SCORM, the default behaviour is to ignore our own progress reporting
	// v6.5.4.3 Not anymore it isn't!
	//if (_global.ORCHID.commandLine.scorm) {
	//	this.progress_pb.setEnabled(false);
	//}

	//v6.3.6 You really only want to do this once.
	// v6.3.6 BUT, you don't know whether to do it on login, course selection or menu screen do you?
	// So clearly the commandLine bit of it should not be tied into the interface component.
	if (this.literal_cb.populated == undefined) {
		// v6.3.5 Since you now want the literal selector on most screens
		// v6.3.6 Just read from xml once
		//var literalList = _global.ORCHID.literalModelObj.getLiteralLanguageList();
		var literalList = _global.ORCHID.literalModelObj.langList;
		if (literalList.length > 1) {
			//myTrace("menuScreen - set languages");
			// v6.3.4 I would like to be able to preset the language from SCORM as well
			// v6.3.5 Or indeed if the course or start up has somehow preset it
			this.literal_cb.removeAll();
			for (var i = 0; i < literalList.length; i++) {
				//v6.4.1 Array now has code and name
				//this.literal_cb.addItem(_global.ORCHID.literalModelObj.getLiteral("languageName", "labels", literalList[i]), literalList[i]);
				//myTrace("menu screen, adding " + literalList[i].name + " to comboBox",1);
				this.literal_cb.addItem(literalList[i].name, literalList[i].code);
			}
			//myTrace("preset lang index to " + _global.ORCHID.literalModelObj.currentLiteralIdx)
			this.literal_cb.setSelectedIndex(_global.ORCHID.literalModelObj.currentLiteralIdx);
		} else {
			//myTrace("menucreen - preset 1 language");
			// hide the language selector if there is only one option
			this.literal_cb.setEnabled(false);
		}
		this.literal_cb.populated = true;
	}
	
	// v6.3.5 The position of the progress bar changes (can) for each screen.
	// So in the display we will reset the coords (based on a holder called progressBar)
	// If you don't have a holder on this screen, don't move the progress bar
	var myController = _global.ORCHID.root.tlcController;
	if (this.progressBar != undefined) {
		//myTrace("show progress bar, width=" + this.progressBar._width);
		myController._x =this.progressBar._x;
		myController._y =this.progressBar._y;
		myController._width =this.progressBar._width;
		myController._height =this.progressBar._height;
		// sometimes this gets strangely shrunken, but not always. Try forcing the scale
		//myController._xscale = 100;
		myController._yscale = 100;
		this.progressBar._visible = false;
	}
	//v6.3.6 For scrolling of units NO NO, you are here AFTER setting this in menu.As
	// so leave well alone
	//myTrace("screens: hide menu scrolling stuff");
	//this.unitsScrollDown_pb.setEnabled(false);
	//this.unitsScrollUp_pb.setEnabled(false);		
	//this.unitsOutline._visible = false;
	
	//v6.4.2.4 Sweet Biscuits. Since the interface changes, slightly based on licence, as soon
	// as you know it, send the licence product name to buttons to see if it wants to do 
	// anything with it.
	//myTrace("send " + _global.ORCHID.root.licenceHolder.licenceNS.product + " to menuScreen");
	this.setProductName(_global.ORCHID.root.licenceHolder.licenceNS.product);
	this.setBranding(_global.ORCHID.root.licenceHolder.licenceNS.branding);
	//v6.4.2.4 Sweet Biscuits. Interface also needs to know about demo.
	this.setProductType(_global.ORCHID.root.licenceHolder.licenceNS.productType);
	
	// v6.5.6.5 CP2 wants different opening menu screen for demo
	if ((_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("demo") >= 0) &&
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0)) {
		this.showMenu(3, true) ;
		//this.cmdMenu3.setTarget('connectedSpeechBtnDemo'); 
	}
	// v6.5.5.5 For Clear Pronunciation we have a customised menu tabbing system.
	// When you return to the menu, you want to display the tab that you left.
	// v6.5.5.8 Yet if you are coming back from an exercise you don't want any kind of scrolling to get there
	// Scrolling is just for when you are playing with the tabs.
	//this.bookmarkMenu();
	this.bookmarkMenuDirect(); 

	// v6.4.2.8 Not in demo warning, clear it
	_global.ORCHID.root.buttonsHolder.MessageScreen.demoWarning.notInDemo._visible = false;

	// v6.5 Allow all buttons to be hidden - based on what though at the menu level?
	
	// v6.5.4.3 certificate button - only show it if there is a certificate in the scaffold
	// v6.5.5.2 Oops. BW Intl has courseID=51 - which clashes. For now just sort this by checking for filename too.
	var goTo = _global.ORCHID.course.scaffold.getObjectByID(51); // 51 is the standard ID for a certificate
	if (goTo==null || goTo.fileName=="" || goTo.fileName==undefined) {
		this.certificate_pb.setEnabled(false);
	} else {
		myTrace("screens.as, got cert=" + goTo.fileName);
	}
}

_global.ORCHID.root.buttonsHolder.MenuScreen.clear = function() {
	//myTrace("MenuScreen.clear");
	this._visible = false;
}

_global.ORCHID.root.buttonsHolder.LoginScreen.init = function() {
	myTrace("LoginScreen.init");
	var myROColour = 0x660099;
	var myMDColour = 0x660033;
	var myTextColour = 0xFFFFFF;
	var myShadowColour = 0x6666FF;
	var myBaseColour = 0x6600CC;
	// set up the OK button
	// v6.3.3 All this interface stuff should NOT be here!
	this.loginBtn.setColour(myBaseColour);
	this.loginBtn.setRollOverColour(myROColour, myMDColour);
	this.loginBtn.setTextColour(myTextColour, myShadowColour);
	this.loginBtn.setReleaseAction(_global.ORCHID.viewObj.cmdLogin);
	//this.loginBtn.setLabel("Log on");
	this.newUserBtn.setColour(myBaseColour);
	this.newUserBtn.setRollOverColour(myROColour, myMDColour);
	this.newUserBtn.setTextColour(myTextColour, myShadowColour);
	this.newUserBtn.setReleaseAction(_global.ORCHID.viewObj.cmdNewUser);
	// v6.5.4.6 password change
	this.passwordChangeBtn.setColour(myBaseColour);
	this.passwordChangeBtn.setRollOverColour(myROColour, myMDColour);
	this.passwordChangeBtn.setTextColour(myTextColour, myShadowColour);
	this.passwordChangeBtn.setReleaseAction(_global.ORCHID.viewObj.cmdPasswordScreen);
	//this.newUserBtn.setLabel("New user");
	this.literal_cb.setStyleProperty("textFont", "Verdana, _sans");
	this.literal_cb.setStyleProperty("textSize", 11);
	this.literal_cb.setChangeHandler("cmdChangeLanguage", _global.ORCHID.viewObj);
	this.i_password.password = true;
	// v6.3 The exit button is there for future use (no need to change buttons.fla)
	// v6.4.2.4 We now want it to always be here
	//this.navExit_pb._visible = false;
	this.navExit_pb._visible = true;
	this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	
	// v6.3.5 The help button was not active
	this.help_pb.setReleaseAction(_global.ORCHID.viewObj.cmdHelp);

	this.loaded = true;
}
_global.ORCHID.root.buttonsHolder.LoginScreen.setLiterals = function() {
	myTrace("LoginScreen.setLiterals");
	this.message_txt.multiline = true;
	this.message_txt.wordWrap = true;
	this.message_txt.autosize = true;
	this.loginBtn.setLabel(_global.ORCHID.literalModelObj.getLiteral("logOn", "buttons"));
	//this.loginBtn.setLabel("A really really long text.");
	this.newUserBtn.setLabel(_global.ORCHID.literalModelObj.getLiteral("newUser", "buttons"));
	// v6.5.4.6 Change password
	this.passwordChangeBtn.setLabel(_global.ORCHID.literalModelObj.getLiteral("changePassword", "buttons"));
	this.name_lbl.text = _global.ORCHID.literalModelObj.getLiteral("name", "labels");
	this.studentID_lbl.text = _global.ORCHID.literalModelObj.getLiteral("studentID", "labels");
	this.password_lbl.text = _global.ORCHID.literalModelObj.getLiteral("password", "labels");
	this.selectLiteral_lbl.text = _global.ORCHID.literalModelObj.getLiteral("selectLiteral", "labels");
	// tricky to do this as the literal used is data dependent
	// v6.4.2.4 You might well be running this after LoginScreen.display - so don't override the message text
	//if (this.messageStatus == "" || this.messageStatus == undefined) {
	//	this.messageStatus = "logOn";
	//}
	//this.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(this.messageStatus, "messages");
	this.help_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("help", "buttons"));
	// v6.3.5 
	this.heading_lbl.text = _global.ORCHID.literalModelObj.getLiteral("loginHeading", "labels");
	// v6.4.2.4 We now want to be able to exit
	this.navExit_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("exit", "buttons"));
}

_global.ORCHID.root.buttonsHolder.LoginScreen.display = function() {

	var me = _global.ORCHID.programSettings;
	var messageLit;

	//myTrace("loginOption is " + me.loginOption + " verified is " + me.verified);
	// v6.2 Better RM integration
	if (me.selfRegister > 0) {
		// v6.4.2.4 In the case that self-reg + no password + allow anon, we are going to try and do without the newUserBtn
		if ((me.loginOption & _global.ORCHID.accessControl.ACAllowAnonymous) && !me.verified) {
			messageLit = "optionalLogOn";
			this.newUserBtn.setEnabled(false);
		} else {
			messageLit = "logOnSelfRegister";
		}
	} else {
		messageLit = "logOn";
		// v6.3 Set the self-register button off
		this.newUserBtn.setEnabled(false);
	}
	this.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(messageLit, "messages");
	//myTrace("text=" + this.message_txt.text);
	// v6.3 New RM setting to allow anonymous, new default will be not to
	//if (_global.ORCHID.programSettings.selfRegister > 0) {
	if (me.loginOption & _global.ORCHID.accessControl.ACAllowAnonymous) {
		// v6.4.2.4 In the case that self-reg + no password + allow anon, we are going to have a with different message
		if (me.selfRegister>0 && !me.verified) {
		} else {
			//this.message_txt.text = "Adrian";
			//this.messageStatus = "logOnAnon";
			this.message_txt.text += " " + _global.ORCHID.literalModelObj.getLiteral("logOnAnon", "messages");
			//myTrace("text=" + this.message_txt.text);
		}
	}
	// v6.5.4.6 Add password change Button
	if (me.loginOption & _global.ORCHID.accessControl.ACAllowChangePassword) {
		myTrace("allow password change");
		this.passwordChangeBtn.setEnabled(true);
	} else {
		this.passwordChangeBtn.setEnabled(false);
	}
	this.messageStatus="";
	this._visible = true;
	if (me.loginOption & _global.ORCHID.accessControl.ACUserNameOnly ||
		me.loginOption & _global.ORCHID.accessControl.ACuserNameAndStudentID) {
		this.i_name._visible = true;
		this.name_lbl._visible = true;
		// using tabIndex REALLY seems to screw things up as the URL 
		// box in the browser comes in as the second tab! Hmm, not due to tabindex I think
		//this.i_name.tabIndex = 1;
		this.i_name.tabEnabled = true;
	} else {
		this.i_name._visible = false;
		this.name_lbl._visible = false;
	}
	if (me.loginOption & _global.ORCHID.accessControl.ACStudentIDOnly ||
		me.loginOption & _global.ORCHID.accessControl.ACuserNameAndStudentID) {
		this.i_studentID._visible = true;
		this.studentID_lbl._visible = true;
		this.i_studentID.tabEnabled = true;
	} else {
		this.i_studentID._visible = false;
		this.studentID_lbl._visible = false;
	}
	/*
	// gh#358 This is what we should do, but none of the interfaces have email on the login screen!
	if (me.loginOption & _global.ORCHID.accessControl.ACEmailOnly) {
		this.i_email._visible = true;
		this.email_lbl._visible = true;
		this.i_email.tabEnabled = true;
	} else {
		this.i_email._visible = false;
		this.email_lbl._visible = false;
	}
	*/
	
	// always allow a password
	// v6.3 NO - this should be RM controlled as well
	if (me.verified) {
		this.i_password._visible = true;
		this.password_lbl._visible = true;
	} else {
		this.i_password._visible = false;
		this.password_lbl._visible = false;
		this.i_password.tabEnabled = false;
	}
	// v6.3 Now sort out the display line up
	var top = this.i_name._y;
	var delta = this.i_studentID._y - top;
	if (delta < this.i_name._height) {
		// v6.3.4 If you have not got name, id._y will be 0 as well, so then base it on height
		delta = this.i_name._height + 2;
		//myTrace("delta=" + delta);
	}
	var thisTab = 1;
	if (this.i_name._visible) {
		this.i_name._y = top;
		//myTrace("put name at y=" + top);
		this.i_name.tabIndex = thisTab++;
		top += delta;
	}
	if (this.i_studentID._visible) {
		this.i_studentID._y = top;
		//myTrace("put id at y=" + top);
		this.i_studentID.tabIndex = thisTab++;
		top += delta;
	}
	if (this.i_password._visible) {
		this.i_password._y = top;
		//myTrace("put password at y=" + top);
		this.i_password.tabIndex = thisTab++;
		top += delta;
	}
	this.name_lbl._y = this.i_name._y;
	this.studentID_lbl._y = this.i_studentID._y;
	this.password_lbl._y = this.i_password._y;
	
	// v6.3.3 Allow for passed names to be displayed (if they are wrong) and you haven't typed anything else in
	if (_global.ORCHID.commandLine.userName != undefined && _global.ORCHID.commandLine.userName != "" &&
		this.i_name.text == "") {
		myTrace("show the passed name as it is wrong (" + _global.ORCHID.commandLine.userName + ")");
		this.i_name.text = _global.ORCHID.commandLine.userName;
	}
	//v6.3.6 You really only want to do this once.
	// v6.3.6 BUT, you don't know whether to do it on login, course selection or menu screen do you?
	// So clearly the commandLine bit of it should not be tied into the interface component.
	if (this.literal_cb.populated == undefined) {
		// v6.3.5 Since you now want the literal selector on most screens
		// v6.3.6 Just read from xml once
		//var literalList = _global.ORCHID.literalModelObj.getLiteralLanguageList();
		var literalList = _global.ORCHID.literalModelObj.langList;
		if (literalList.length > 1) {
			//myTrace("menuScreen - set languages");
			// v6.3.4 I would like to be able to preset the language from SCORM as well
			// v6.3.5 Or indeed if the course or start up has somehow preset it
			this.literal_cb.removeAll();
			for (var i = 0; i < literalList.length; i++) {
				//v6.4.1 Array now has code and name
				//this.literal_cb.addItem(_global.ORCHID.literalModelObj.getLiteral("languageName", "labels", literalList[i]), literalList[i]);
				//myTrace("login screen, adding " + literalList[i].name + " to comboBox",1);
				this.literal_cb.addItem(literalList[i].name, literalList[i].code);
			}
			//myTrace("preset index to " + _global.ORCHID.literalModelObj.currentLiteralIdx)
			this.literal_cb.setSelectedIndex(_global.ORCHID.literalModelObj.currentLiteralIdx);
		} else {
			//myTrace("menucreen - preset 1 language");
			// hide the language selector if there is only one option
			this.literal_cb.setEnabled(false);
		}
		this.literal_cb.populated = true;
	}
	//loginBox.i_name.tabIndex = 3;
	
	//this.message_txt.multiline = true;
	//this.message_txt.wordWrap = true;
	//this.message_txt.autosize = true;
	//this.message_txt.text = "Please type your name and click Log on, or click New user. For anonymous use, just click Log on.";

	//loginBox.i_password.password = true;
	this.tabEnabled = true;
	this.tabChildren = true;
	// v6.3 This is necessary to let the tab work and not give control back to the browser URL
	this._parent.tabChildren = true;
	Selection.setFocus(this.i_name);
	
	this.loginForm = new Object();
	this.loginForm.master = this;
	this.loginForm.onKeyUp = function () {
		var myFocus = eval(Selection.getFocus());
		//myTrace("you clicked " + Key.getAscii() + " on " + myFocus);
		if (Key.getAscii() == Key.ENTER) {
			//myTrace("so try to login and remove the listener from " + this.master);
			// v6.3.5 clear the status text before any processing
			this.master.messageStatus = "";
			_global.ORCHID.viewObj.cmdLogin();
			Key.removeListener(this);
			delete this;
		// v6.3 I am not sure that you need to handle tabs. If you set the tabenabled properties correctly
		// then Flash would work it out itself.
		} else if (Key.getAscii() == Key.TAB) {
			//myTrace("caught a TAB from " + myFocus);
			//myTrace(this + ".tabEnabled=" + myFocus._parent.tabEnabled + " gramps=" + myFocus._parent._parent.tabEnabled);
		//	if (myFocus == this.master.i_name) {
		//		if (this.master.i_password._visible) {
		//			Selection.setFocus(this.master.i_password);
		//		}
		//	}
		}
	}
	//myTrace("add listener as object on " + this.loginForm.master)
	Key.addListener(this.loginForm); // isn't this listening all the time, shouldn't it be called when mouseOver or something?
}

_global.ORCHID.root.buttonsHolder.LoginScreen.clear = function() {
	//trace("LoginScreen.clear");
	this._visible = false;
	this.i_name.text = "";
	this.i_password.text = "";
	this.i_studentID.text = "";
	// used to store the status of message_txt, eg "noSuchUser", "logOn"
	this.messageStatus = "";
	Key.removeListener(this.loginForm);
}

_global.ORCHID.root.buttonsHolder.RegisterScreen.init = function() {
	//trace("RegisterScreen.init");
	var myROColour = 0x660099;
	var myMDColour = 0x660033;
	var myTextColour = 0xFFFFFF;
	var myShadowColour = 0x6666FF;
	var myBaseColour = 0x6600CC;
	// set up the OK button
	this.loginBtn.setColour(myBaseColour);
	this.loginBtn.setRollOverColour(myROColour, myMDColour);
	this.loginBtn.setTextColour(myTextColour, myShadowColour);
	this.loginBtn.setReleaseAction(_global.ORCHID.viewObj.cmdRegister);
	this.i_password.password = true;
	this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	// v6.3 The exit button is there for future use (no need to change buttons.fla)
	// Not that it actually works here anyway?
	// v6.4.2.4 We now want it to always be here
	//this.navExit_pb._visible = false;
	this.navExit_pb._visible = true;
	this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	// v6.3.5 The help button was not active
	this.help_pb.setReleaseAction(_global.ORCHID.viewObj.cmdHelp);
}

_global.ORCHID.root.buttonsHolder.RegisterScreen.setLiterals = function() {
	//trace("RegisterScreen.setLiterals");
	this.loginBtn.setLabel(_global.ORCHID.literalModelObj.getLiteral("logOn", "buttons"));
	this.message_txt.multiline = true;
	this.message_txt.wordWrap = true;
	this.message_txt.autosize = true;
	this.name_lbl.text = _global.ORCHID.literalModelObj.getLiteral("name", "labels");
	this.password_lbl.text = _global.ORCHID.literalModelObj.getLiteral("password", "labels");
	this.email_lbl.text = _global.ORCHID.literalModelObj.getLiteral("email", "labels");
	this.country_lbl.text = _global.ORCHID.literalModelObj.getLiteral("country", "labels");
	this.studentID_lbl.text = _global.ORCHID.literalModelObj.getLiteral("studentID", "labels");
	if (this.messageStatus == "" || this.messageStatus == undefined) {
		this.messageStatus = "newUser";
	}
	this.message_txt.text = _global.ORCHID.literalModelObj.getLiteral(this.messageStatus, "messages");
	this.help_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("help", "buttons"));
	// v6.3.5 
	this.heading_lbl.text = _global.ORCHID.literalModelObj.getLiteral("registrationHeading", "labels");
	// v6.4.2.4 We now want to be able to exit
	this.navExit_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("exit", "buttons"));
}

_global.ORCHID.root.buttonsHolder.RegisterScreen.display = function() {
	//trace("RegisterScreen.display");
	this._visible = true;
	// 6.0.5.0 settings from RM
	var selfRegister = {Name:1, 
			StudentID:2,
			// Currently RM and Orchid have password and email the other way round. Change it here.
			//Password:4,
			//Email:16,
			Email:4,
			Password:16,
			Birthday:32,
			Country:64,
			Company:128,
			Custom1:256,
			Custom2:512,
			Custom3:1024}

	var me = _global.ORCHID.programSettings;
	// always allow a password
	// v6.3 No, this is RM controlled as well
	// V6.4.2.4 It doesn't make sense for password to be a selfRegister option - it is set from the main RM settings screen
	// and held in verified. 
	if (me.verified || me.selfRegister & selfRegister.Password) {
		this.i_password._visible = true;
		this.password_lbl._visible = true;
	} else {
		this.i_password._visible = false;
		this.password_lbl._visible = false;
	}
	if (me.selfRegister & selfRegister.Name) {
		this.i_name._visible = true;
		this.name_lbl._visible = true;
	} else {
		this.i_name._visible = false;
		this.name_lbl._visible = false;
	}
	if (me.selfRegister & selfRegister.StudentID) {
		this.i_studentID._visible = true;
		this.studentID_lbl._visible = true;
	} else {
		this.i_studentID._visible = false;
		this.studentID_lbl._visible = false;
	}
	if (me.selfRegister & selfRegister.Country) {
		this.i_country._visible = true;
		this.country_lbl._visible = true;
	} else {
		this.i_country._visible = false;
		this.country_lbl._visible = false;
	}
	//myTrace("check if ask about email, selfRegister=" + me.selfRegister + " and email=" + selfRegister.Email);
	if (me.selfRegister & selfRegister.Email) {
		this.i_email._visible = true;
		this.email_lbl._visible = true;
	} else {
		this.i_email._visible = false;
		this.email_lbl._visible = false;
	}
	if (me.selfRegister & selfRegister.ClassName) {
		this.i_className._visible = true;
		this.className_lbl._visible = true;
	} else {
		this.i_className._visible = false;
		this.className_lbl._visible = false;
	}
	// v6.3 Now sort out the display line up
	var top = this.i_name._y;
	// v6.5.4.5 This is no good for a second display of the screen because you will have shifted
	// this field up if there is no name.
	var delta = this.i_studentID._y - top;
	if (delta<=4) {
		delta = this.i_password._y - this.i_studentID._y; // bit of a bodge
		myTrace("screens.as shift based on studentID " + delta);
	}
	var thisTab = 1; 
	if (this.i_name._visible) {
		this.i_name._y = top;
		this.i_name.tabIndex = thisTab++;
		top += delta;
	}
	if (this.i_studentID._visible) {
		this.i_studentID._y = top;
		this.i_studentID.tabIndex = thisTab++;
		top += delta;
	}
	if (this.i_password._visible) {
		this.i_password._y = top;
		this.i_password.tabIndex = thisTab++;
		top += delta;
	}
	if (this.i_email._visible) {
		this.i_email._y = top;
		this.i_email.tabIndex = thisTab++;
		top += delta;
	}
	if (this.i_country._visible) {
		this.i_country._y = top;
		this.i_country.tabIndex = thisTab++;
		top += delta;
	}
	this.name_lbl._y = this.i_name._y;
	this.studentID_lbl._y = this.i_studentID._y;
	this.password_lbl._y = this.i_password._y;
	this.email_lbl._y = this.i_email._y;
	this.country_lbl._y = this.i_country._y;

	// v6.3.5 Copied from login section
	this.tabEnabled = true;
	this.tabChildren = true;
	// v6.3 This is necessary to let the tab work and not give control back to the browser URL
	this._parent.tabChildren = true;
}

_global.ORCHID.root.buttonsHolder.RegisterScreen.clear = function() {
	//trace("RegisterScreen.clear");
	this._visible = false;
	this.i_name.text = "";
	this.i_password.text = "";
	this.i_email.text = "";
	this.i_country.text = "";
	//use to store the status of message_txt, eg "userExists", "newUser"
	this.messageStatus = "";
}
// v6.5.4.6 Whole new screen (mini)
_global.ORCHID.root.buttonsHolder.PasswordScreen.init = function() {
	//trace("RegisterScreen.init");
	var myROColour = 0x660099;
	var myMDColour = 0x660033;
	var myTextColour = 0xFFFFFF;
	var myShadowColour = 0x6666FF;
	var myBaseColour = 0x6600CC;
	// set up the OK button
	this.loginBtn.setColour(myBaseColour);
	this.loginBtn.setRollOverColour(myROColour, myMDColour);
	this.loginBtn.setTextColour(myTextColour, myShadowColour);
	this.loginBtn.setReleaseAction(_global.ORCHID.viewObj.cmdChangePassword);
	this.i_password.password = true;
	this.i_confirmPassword.password = true;
	this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	// v6.3 The exit button is there for future use (no need to change buttons.fla)
	// Not that it actually works here anyway?
	// v6.4.2.4 We now want it to always be here
	//this.navExit_pb._visible = false;
	this.navExit_pb._visible = true;
	this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	// v6.3.5 The help button was not active
	this.help_pb.setReleaseAction(_global.ORCHID.viewObj.cmdHelp);
}

_global.ORCHID.root.buttonsHolder.PasswordScreen.setLiterals = function() {
	//trace("RegisterScreen.setLiterals");
	this.loginBtn.setLabel(_global.ORCHID.literalModelObj.getLiteral("logOn", "buttons"));
	this.message_txt.multiline = true;
	this.message_txt.wordWrap = true;
	this.message_txt.autosize = true;
	this.password_lbl.text = _global.ORCHID.literalModelObj.getLiteral("newPassword", "labels");
	this.confirmPassword_lbl.text = _global.ORCHID.literalModelObj.getLiteral("confirmPassword", "labels");
	var substList = [{tag:"[newline]", text:newline}];
	this.message_txt.text = _global.ORCHID.root.objectHolder.substTags(_global.ORCHID.literalModelObj.getLiteral("changePassword", "messages"), substList);
	
	this.help_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("help", "buttons"));
	// v6.3.5 
	this.heading_lbl.text = _global.ORCHID.literalModelObj.getLiteral("changePassword", "labels");
	// v6.4.2.4 We now want to be able to exit
	this.navExit_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("exit", "buttons"));
}

_global.ORCHID.root.buttonsHolder.PasswordScreen.display = function() {
	//trace("RegisterScreen.display");
	this._visible = true;

	// v6.3.5 Copied from login section
	this.tabEnabled = true;
	this.tabChildren = true;
	// v6.3 This is necessary to let the tab work and not give control back to the browser URL
	this._parent.tabChildren = true;
}

_global.ORCHID.root.buttonsHolder.PasswordScreen.clear = function() {
	//trace("RegisterScreen.clear");
	this._visible = false;
	this.i_password.text = "";
	this.i_confirmpassword.text = "";
	//use to store the status of message_txt, eg "userExists", "newUser"
	this.messageStatus = "";
}

_global.ORCHID.root.buttonsHolder.IntroScreen.init = function() {
	//trace("IntroScreen.init");
	this.loaded = true;
}

_global.ORCHID.root.buttonsHolder.IntroScreen.setLiterals = function() {
	myTrace("IntroScreen.setLiterals");
	//v6.4.2.1 Add licencee name to the intro screen - can't do it earlier as literals not loaded.
	// Better to do it once you know, so it doesn't matter if you don't have a course list or login screen
	// Also, there MUST be a space in the literal for the licencee name, if not, ignore the thing from literal.xml as someone is
	// trying to avoid the licence name being seen.
	// v6.4.2.4 But, based on the speed of loading, you might or might not have read the licence file at this point.
	var licenceLiteral = _global.ORCHID.literalModelObj.getLiteral("licencedTo", "labels");
	if (licenceLiteral.indexOf("[x]")<0) {
		licenceLiteral = "Licensed to: [x]";
	}
	var substList = [{tag:"[x]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution}];
	this.licenceCaption.text = _global.ORCHID.root.objectHolder.substTags(licenceLiteral, substList);
	//myTrace("to introScreen: " + this.licenceCaption.text);
}

_global.ORCHID.root.buttonsHolder.IntroScreen.display = function() {
	myTrace("IntroScreen.display");
	this.loadDefault = function() {
		//myTrace("load the default image");
		clearInterval(this.myInt);
		this.defaultImageHolder.attachMovie("defaultIntroImage", "loadDefaultImage", this.buttonsNS.depth++);
	}
	// if the intro screen HAS a custom image holder, try to fill it
	//v6.3.6 If you are using this technique, then the FLA should have a base that does not change
	// Then anything that you are happy to lose should go in defaultImage library Movie
	// as either this OR the customIntro will be displayed. I expect that this is just a simple logo.
	// In Author Plus, it is the Author Plus Online writing and Clarity logo that get replaced.
	// For ease of customer use, assume that this will be a jpg rather than a swf.
		// v6.4.2 Problem due to 404 error takes forever to be generated
		// so temporaily only check for custom stuff if told to from parameters
	//v6.4.2.1 Move so that you only do one or the other - and stuff in the licence seems most important
	// v6.5.6.5 Note that if you send brandMovies through licence attributes, it won't be set yet, so this will look in a different location!
	if (_global.ORCHID.root.licenceHolder.licenceNS.customisation[0] != "" && _global.ORCHID.root.licenceHolder.licenceNS.customisation[0] != undefined) {
		myTrace("load image " + _global.ORCHID.paths.brandMovies + _global.ORCHID.root.licenceHolder.licenceNS.customisation[0] + " (licence)");
		//this.defaultImage.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + _global.ORCHID.root.licenceHolder.licenceNS.customisation[0]);
		// v6.3.5 Brand has its own path now
		//v6.4.2.1 This should be defaultImageHolder
		//this.defaultImage.loadMovie(_global.ORCHID.paths.brandMovies + _global.ORCHID.root.licenceHolder.licenceNS.customisation[0]);
		this.defaultImageHolder.loadMovie(_global.ORCHID.paths.brandMovies + _global.ORCHID.root.licenceHolder.licenceNS.customisation[0]);
	} else if (this.customImageHolder != undefined && _global.ORCHID.commandLine.customised) {
		//myTrace("FLA allows it, so load " + _global.ORCHID.paths.brandMovies + "CustomIntro.jpg");
		//this.customImageHolder._x = this.customImageHolder._y = 0;
		// v6.3.5 Brand has its own path now
		//this.customImageHolder.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + "CustomIntro.swf");	
		// v6.4.2 This causes problems due to delays etc. But even worse on new server, it appears to hang the app
		// for about 4 minutes and then do a restart. most odd, but I am sure it is down to searching in a folder that does
		// exist for a file that doesn't. Ahhh. We have just implemented 404 catching, so I bet a webpage is being
		// sent back! So can Philip stop that 404 responding?
		/*
		this.customImageHolder.loadMovie(_global.ORCHID.paths.brandMovies + "CustomIntro.jpg");	
		this.checkLoading = function() {
			var bytes = this.customImageHolder.getBytesTotal();
			if (bytes == -1 || myLoadingCount >= 12) {
				myTrace("no custom image (CustomIntro.jpg) found");
				clearInterval(this.myLoadingInt);
				// so load the default
				if (this.defaultImageHolder != undefined) {
					this.loadDefault();
				}
			} else if (bytes > 4) {
				clearInterval(this.myLoadingInt);
			} else {
				//myTrace("waiting for custom image");
				this.myLoadingCount++
			}
		}
		this.myLoadingCount = 0;
		this.myLoadingInt = setInterval(this, "checkLoading", 250);
		*/
		var customImage = _global.ORCHID.paths.brandMovies + "CustomIntro.jpg";
		var fileExists = new LoadVars();
		fileExists._parent = this;
		fileExists.imageFile = customImage;
		fileExists.onLoad = function(success) {
			//success is true if the file exists, false if it doesnt
			if (success) {
				//the file exists
				myTrace("it does, load it");
				this._parent.customImageHolder.loadMovie(this.imageFile);
				//delete this;
			} else {
				myTrace("it doesn't, so load the default");
				this._parent.loadDefault();
				delete this;
			}
		}
		myTrace("check if " + customImage+ " exists");
		fileExists.load(customImage); //initiate the test
		// and trigger the default image to load shortly (if you want one)
		// Since the customIntro is on top, this means the default image will probably
		// appear after it, so if it is hidden it will not flash on top first.
		// v6.3.6 I think it would actually fit better if the default image were not loaded if
		// the custom was successfully loaded. So, either find a way to detect that, or put
		// the default as CustomIntro.jpg.
		//if (this.defaultImageHolder != undefined) {
		//	this.myInt = setInterval(this, "loadDefault", 1000);
		//}
	} else {
		//myTrace("FLA has no intro customImageHolder, so load defaultImageHolder");
		// trigger the default image to load immediately, again if a placeholder is in the movie
		if (this.defaultImageHolder != undefined) {
			this.loadDefault();
		}
	}
	// v6.3.4 Add the possibility of customisation for those titles that don't have the customImageHolder
	// the mc name will be held in the licence file
	// v6.3.6 If you are using this technique, then the FLA should have everything it is happy to lose
	// in defaultImage as it will be replaced by the customisation.
	// In Author Plus, it is everything on this screen. 
	// v6.4.2.1 No it isn't - there is NO defaultImage mc on the screen anymore.
	// If the licence has this stuff in it, then surely we shouldn't be trying to do the custom or default settings.
	// So move this as part of the overall if above.
	// Customisation[0] = Intro
	//if (_global.ORCHID.root.licenceHolder.licenceNS.customisation[0] != "" && _global.ORCHID.root.licenceHolder.licenceNS.customisation[0] != undefined) {
	//	myTrace("load custom image " + _global.ORCHID.paths.brandMovies + _global.ORCHID.root.licenceHolder.licenceNS.customisation[0] + " (licence)");
	//	//this.defaultImage.loadMovie(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + _global.ORCHID.root.licenceHolder.licenceNS.customisation[0]);
	//	// v6.3.5 Brand has its own path now
	//	this.defaultImage.loadMovie(_global.ORCHID.paths.brandMovies + _global.ORCHID.root.licenceHolder.licenceNS.customisation[0]);
	//}
	
	// v6.2 You want to either test for a "skip intro", or "continue" click in here
	// and just wait until you get it (something for control). Or it would be good
	// to show a progress bar whilst you were loading the rest of things.
	this._visible = true;
	// v6.3 How about a nice version number?
	this.versionNumber_txt._visible = true;
	var substList = [{tag:"[x]", text:_global.ORCHID.versionTable.makeVersionString(_global.ORCHID.versionTable.overall)}];
	// The literals object might not be loaded by the time you run this function
	//myTrace("version number text=" + _global.ORCHID.literalModelObj.getLiteral("version", "labels"));
	//this.versionNumber_txt.text = substTags(_global.ORCHID.literalModelObj.getLiteral("version", "labels"), substList);
	this.versionNumber_txt.text = "Version " + _global.ORCHID.versionTable.makeVersionString(_global.ORCHID.versionTable.overall);

	// v6.3.5 The position of the progress bar changes (can) for each screen.
	// So in the display we will reset the coords (based on a holder called progressBar)
	// If you don't have a holder on this screen, don't move the progress bar
	var myController = _global.ORCHID.root.tlcController;
	if (this.progressBar != undefined) {
		//myTrace("show progress bar, width=" + this.progressBar._width);
		myController._x =this.progressBar._x;
		myController._y =this.progressBar._y;
		myController._width =this.progressBar._width;
		myController._height =this.progressBar._height;
		// sometimes this gets strangely shrunken, but not always. Try forcing the scale of the font
		//myController._xscale = 100;
		myController._yscale = 100;
		this.progressBar._visible = false;
	}
}

_global.ORCHID.root.buttonsHolder.IntroScreen.clear = function() {
	//trace("IntroScreen.clear");
	this._visible = false;
}


_global.ORCHID.root.buttonsHolder.CourseListScreen.init = function() {
	myTrace("CourseListScreen.init");
	this.navExit_pb.setReleaseAction(_global.ORCHID.viewObj.cmdExit);
	this.courseMenu_lb.setChangeHandler("selectCourse", _global.ORCHID.viewObj);
	// v6.3.5 The help button was not active
	this.help_pb.setReleaseAction(_global.ORCHID.viewObj.cmdHelp);

	// v6.3.5 Extend the use of the language selection
	this.literal_cb.setStyleProperty("textFont", "Verdana, _sans");
	this.literal_cb.setStyleProperty("textSize", 11);
	this.literal_cb.setChangeHandler("cmdChangeLanguage", _global.ORCHID.viewObj);
	
	// v6.4.3 Course tree structure - use a Flash 8 Object
	// Need a good way of making the list menu the default if no other menu system is present, rather than just trying
	// to load the tree. And don't do this more than once, not that I think you try anyway.
	if (this.courseMenu==undefined) {
		this.createEmptyMovieClip("courseMenu", this.buttonsNS.depth++);
		myTrace("try to load " + _global.ORCHID.paths.interfaceMovies + "courseTree.swf");
		this.courseMenu.loadMovie(_global.ORCHID.paths.interfaceMovies + "courseTree.swf");
	} else {
		myTrace("this interface already has a course menu mc");
		this.courseMenu.fromInterface = true;
	}

	// v6.5.4.3 Yiu, shore the course.xml for later use
	this.m_objCourseXML	= NULL;	
	this.m_nNumOfCourse	= 0;
}

_global.ORCHID.root.buttonsHolder.CourseListScreen.setLiterals = function() {
	//trace("CourseListScreen.setLiterals");
	this.navExit_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("exit", "buttons"));
	this.selectCourse_lbl.text = _global.ORCHID.literalModelObj.getLiteral("chooseCourse", "labels");
	this.help_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("help", "buttons"));
}

_global.ORCHID.root.buttonsHolder.CourseListScreen.display = function() {
	//v6.4.2.4 Sweet Biscuits. Since the interface changes, slightly based on licence, as soon
	// as you know it, send the licence product name to buttons to see if it wants to do 
	// anything with it.
	//myTrace("send " + _global.ORCHID.root.licenceHolder.licenceNS.product + " to courseListScreen");
	this.setProductName(_global.ORCHID.root.licenceHolder.licenceNS.product);
	this.setBranding(_global.ORCHID.root.licenceHolder.licenceNS.branding);
	//v6.4.2.4 Sweet Biscuits. Interface also needs to know about demo.
	this.setProductType(_global.ORCHID.root.licenceHolder.licenceNS.productType);

	// v6.4.2.4 In order to tie the licence to particular interface, match the branding from buttons and from licence.
	// The version in buttons might be shorter than the licence one BC/IELTS vs BC/IELTS/Academic
	// Also let a super licence match anything.
	// For something like GEPT, it would make sense to let any licenced product use the AP interface.
	// Could this matter?
	myTrace("matching licence " + _global.ORCHID.root.licenceHolder.licenceNS.branding + " with buttons " + _global.ORCHID.root.buttonsHolder.buttonsNS.branding);
	if (	_global.ORCHID.root.licenceHolder.licenceNS.product == "North North West" || 
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf(_global.ORCHID.root.buttonsHolder.buttonsNS.branding.toLowerCase())>=0)) {
	} else {
		// v6.4.2.4 Temporary avoidance of this check for CE.com
		// v6.5 And for the new Rackspace server
		if (	_global.ORCHID.paths.root.toLowerCase().indexOf("clarityenglish.com")>=0 ) {
			//_global.ORCHID.paths.root.toLowerCase().indexOf("202.148.158.86")>=0 ||
			//_global.ORCHID.paths.root.toLowerCase().indexOf("67.192.58.54")>=0 ||
			//_global.ORCHID.paths.root.toLowerCase().indexOf("clarity02")>=0) {
			myTrace("*** ignore mismatch licence=" + _global.ORCHID.root.licenceHolder.licenceNS.branding + " interface=" + _global.ORCHID.root.buttonsHolder.buttonsNS.branding)
		} else if (_global.ORCHID.root.buttonsHolder.buttonsNS.branding.toLowerCase()=="clarity/ap") {
			myTrace("*** ignore mismatch licence=" + _global.ORCHID.root.licenceHolder.licenceNS.branding + " interface=" + _global.ORCHID.root.buttonsHolder.buttonsNS.branding) 
		} else {
			myTrace("*** mismatch licence=" + _global.ORCHID.root.licenceHolder.licenceNS.branding + " interface=" + _global.ORCHID.root.buttonsHolder.buttonsNS.branding)
			var errObj = {literal:"mismatchLicenceInterface", detail:_global.ORCHID.root.licenceHolder.licenceNS.branding};
			_global.ORCHID.root.controlNS.sendError(errObj);			
			return false;
		}
	}
	//trace("CourseListScreen.display");
	//showCourseMenu = true;
	//myTrace("start of course list screen display");
	var courseXML = new XML();
	var defaultIndex;
	courseXML.ignoreWhite = true;
	courseXML.master = this;
	courseXML.onLoad = function(success) {
		if (success) {
			//myTrace(this.firstChild.childNodes.length + " courses loaded successfully." + this.toString());
			// v6.5.5.7 by WZ, do the privacy check for Author Plus Product.
			// v6.5.6 AR but what about course.xml files that don't have a privacy flag??
			if(_global.ORCHID.root.licenceHolder.licenceNS.productCode == 1){
				for (var i = 0; i < this.firstChild.childNodes.length; i++) {
					var childNode = this.firstChild.childNodes[i];
					var isDelete = true;
					var attr = childNode.attributes;
					if (attr.privacyFlag == "1" && attr.userID == _global.ORCHID.user.userID){
						isDelete = false;
					} else if(attr.privacyFlag == "2" && attr.groupID == _global.ORCHID.user.groupID){
						isDelete = false;
					} else if(attr.privacyFlag == "4"){
						isDelete = false;
					} else if(attr.privacyFlag == undefined){
						myTrace(attr.name + " is an old style course with no privacy attr");
						isDelete = false;
					}
					
					if(isDelete){
						childNode.removeNode();
						i--;
					}
				}
			}

			// v6.5.4.3 Yiu, store for later use, for hiddencontent of course level
			// v6.5.4.5 Removed
			//this.master.m_objCourseXML	= this;
			//this.master.m_nNumOfCourse	= this.firstChild.childNodes.length;
			
			// v6.4.2.8 Get rid of the waiting message (used to be hidden behind course list)
			_global.ORCHID.root.buttonsHolder.IntroScreen.pleaseWait_txt._visible = false;
			
			// v6.5.5.1 For measuring performance
			//myTrace("timeHolder.log.endOfFullyLoadeduser");
			_global.ORCHID.timeHolder.courseLoaded = new Date().getTime();

			// v6.4.2.4 In order to tie the licence to particular content, match the title from the course.xml at this point.
			// Also let a super licence match anything.
			//myTrace("matching licence " + _global.ORCHID.root.licenceHolder.licenceNS.product + " with course.xml " + this.firstChild.attributes["program"]);
			if (	_global.ORCHID.root.licenceHolder.licenceNS.product != "North North West" || 
				(_global.ORCHID.root.licenceHolder.licenceNS.product.toLowerCase() == this.firstChild.attributes["program"].toLowerCase())) {
			} else {
				// v6.5 And for the new Rackspace server
				// v6.4.2.4 Temporary avoidance of this check for CE.com
				if (	_global.ORCHID.paths.root.toLowerCase().indexOf("www.clarityenglish.com")>=0 ||
					_global.ORCHID.paths.root.toLowerCase().indexOf("202.148.158.86")>=0 ||
					_global.ORCHID.paths.root.toLowerCase().indexOf("67.192.58.54")>=0 ||
					_global.ORCHID.paths.root.toLowerCase().indexOf("clarity02")>=0) {
					myTrace("*** ignore mismatch licence=" + _global.ORCHID.root.licenceHolder.licenceNS.product + " content=" + this.firstChild.attributes["program"])
				} else {
					myTrace("*** mismatch licence=" + _global.ORCHID.root.licenceHolder.licenceNS.product + " content=" + this.firstChild.attributes["program"])
					var errObj = {literal:"mismatchLicenceContent", detail:_global.ORCHID.root.licenceHolder.licenceNS.product};
					_global.ORCHID.root.controlNS.sendError(errObj);			
					return false;
				}
			}
			// v6.2 Once you have the data, then immediately check if you want to go to a preset course
			// before you even load it.
			// if defaultCourseID exists in licence file, enter the default course and don't display course menu
			//if (_global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID != undefined && _global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID != "") {
			// v6.3.3 A preset course can come from the licence file, start parameters or from scorm
			// v6.3.6 Change the preference to scorm, start, then licence
			if (_global.ORCHID.commandLine.scorm){
				var presetCourseID = _global.ORCHID.root.scormHolder.scormNS.getCourseID();
				myTrace("use scorm based preset course");
			// v6.5.3 If this is preview, first time load, just stop here and tell APP to give you the navigation details by lc
			} else if (_global.ORCHID.commandLine.course==0 && _global.ORCHID.commandLine.preview) {
				_global.ORCHID.root.controlNS.receiveConn.send("OrchidResponse", "onOrchidReady", true);
				return; 
			} else if (_global.ORCHID.commandLine.course>0) {
				var presetCourseID = _global.ORCHID.commandLine.course;
				myTrace("use html passed preset course");
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID > 0 ) {
				var presetCourseID = _global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID;
				myTrace("use licence based preset course")
			}			
			// v6.3.4 You also want to jump straight in if there is only one course
			if (this.firstChild.childNodes.length == 1) {
				var presetCourseID = this.firstChild.childNodes[0].attributes["id"];
				myTrace("only one course so jump in");
				// v6.3.5 To avoid restart button, treat one course as if it has been preset in the licence
				_global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID = presetCourseID;
			}
			// v6.5 You might also be using the licence to state that ONLY certain course IDs can be run
			// Actually, maybe in this case i will want to see all the levels even though only 1 is active??
			if (_global.ORCHID.root.licenceHolder.licenceNS.validCourses.length==1) {				
				var presetCourseID = _global.ORCHID.root.licenceHolder.licenceNS.validCourses[0];
				myTrace("licence only lists one course, so try it");
				// v6.3.5 To avoid restart button, treat one course as if it has been preset in the licence
				_global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID = presetCourseID;
			}
			// v6.5.5.5 Language Key Hotel Test, LKHT special functions to choose a random course
			// v6.5.5.5 Plus other LK tests.
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("languagekey/hoteltest")>=0 ||
				_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("languagekey/test")>=0) {
				// But this is going to be asynchronous if I need to find out which courses this learner has already done.
				// I got that back from startUser into _global.ORCHID.user.startedContent
				var max=this.firstChild.childNodes.length;
				var startedContentList = _global.ORCHID.user.startedContent.join(",");
				var randomCourse=0; var thisCourseID="0";
				// Make sure that the user hasn't done all the courses already. If they have, just choose one at random.
				myTrace("LKHT, started content =" + startedContentList);
				if (_global.ORCHID.user.startedContent.length >= max) {
					myTrace("user has already done all courses, so do anything");
					startedContentList="";
				}
				do {
					randomCourse = Math.floor(Math.random()*max); 
					thisCourseID = this.firstChild.childNodes[randomCourse].attributes["id"];
					myTrace("LKHT special course randomiser, chooses " + randomCourse);
				} while (startedContentList.indexOf(thisCourseID)>=0);
				var presetCourseID = thisCourseID;
			}

			// v6.5.4.5 hiddenContent will also block some courses. So we should see what that is
			// then we can block any courses that would otherwise be available.
			// ALERT this is no good because it is a database read and so takes time. We need to have
			// run the call as part of the initial loading of the user so that it is ready for us now.
			// v6.5.5.3 Because this is not a sequential array, the .length property is wrong.
			//myTrace("screen.as go through the hidden content (" + _global.ORCHID.user.hiddenContent.length + " items) to block any courses");
			//myTrace("screen.as go through the hidden content to block any courses (" + this.firstChild.childNodes.length + ")");
			//var hiddenCourseArray = new Array();
			var hiddenCourseArray = _global.ORCHID.user.hiddenContent;
			// go through the course.xml and disable anything that is hidden

			// v6.5.4.7 new code for minimal hiddenContent table.
			// Rules: for each item in the scaffold, you need to build the UID and pass it to a checking function.
			// This function will try to match against hiddenContent. If it is hidden, then skip out as that is it.
			// If it is displayed, skip out as that is also it. Otherwise, drop the . to get to the parent of the UID and test again.
			// Its a bit different for the courses as I don't know everything below. For the moment skip it.
			var productUID = _global.ORCHID.root.licenceHolder.licenceNS.productCode;
			for (var i = 0; i < this.firstChild.childNodes.length; i++) {
				// First see if the product or course is switched off, if not, then all is well
				var currNode = this.firstChild.childNodes[i];
				var courseUID = currNode.attributes["id"];
				var UID = _global.ORCHID.root.objectHolder.buildUID(productUID, courseUID);
				var courseEF = _global.ORCHID.root.objectHolder.getEnabledFlagForUID(UID, hiddenCourseArray);
				//myTrace("check on UID=" + UID + " got eF=" + courseEF);
				if (courseEF & _global.ORCHID.enabledFlag.disabled ) {
					// If this is off, then you need to see if any UID under the course is on. This is a rough and ready way of checking
					// that will err on the side of caution (you may switch a course on, but everything under it is disabled, a little frustrating but not wrong)
					courseEF = _global.ORCHID.root.objectHolder.getEnabledFlagUnderUID(UID, hiddenCourseArray);
					//myTrace("further check on UID=" + UID + " got eF=" + courseEF);
				}
				currNode.attributes["enabledFlag"] |= courseEF;
			}
			// v6.5.5.2 It would be nice to show a reason why you have just switched off a course.
			
			/*
			for (var i = 0; i < this.firstChild.childNodes.length; i++) {
				var currNode = this.firstChild.childNodes[i];
				//myTrace("check on course.xml.courseID=" + currNode.attributes["id"]);
				for (var j in hiddenCourseArray) {
					//myTrace("match against=" + hiddenCourseArray[j].id);
					if (currNode.attributes["id"] == hiddenCourseArray[j].id) {
						myTrace("matched courseID=" + hiddenCourseArray[j].id);
						currNode.attributes["enabledFlag"] |= hiddenCourseArray[j].enabledFlag;
						break;
					}
				}
			}
			*/
			//myTrace("full course.xml=" + this.firstChild.toString());
			// v6.5.4.3 Yiu, if someone goes into the course directly with presetCourseID, we just let him/her
			// get in without checking the enabledFlag, we do it intentionally. Is this true? Surely anything that blocks
			// them should be shown - so they see a screen with "Sorry, there are no courses you can run"
			if (presetCourseID > 0) {
				// v6.5.4.1 Note that this loop only works for simple lists, not for MyCanada like tree structures.
				myTrace("checking preset course, validPreview=" + _global.ORCHID.session.validPreview);
				for (var i = 0; i < this.firstChild.childNodes.length; i++) {
					var currNode = this.firstChild.childNodes[i];
					//var item = this.master.courseMenu_lb.getItemAt(i);
					//if(item.data.attributes["id"] == _global.ORCHID.root.licenceHolder.licenceNS.defaultCourseID) {
					var itemID = currNode.attributes["id"];
					if (itemID == presetCourseID) {
						// is it blocked though?
						// Don't block if we are previewing from AP
						//if (currNode.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.disabled) {
						if (!_global.ORCHID.session.validPreview && (currNode.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.disabled)) {
							var errObj = {literal:"noAuthorisedCourses", detail:_global.ORCHID.root.licenceHolder.licenceNS.product};
							_global.ORCHID.root.controlNS.sendError(errObj);			
							return false;
						} else {
							// pass the XML node to the course select function
							_global.ORCHID.viewObj.selectCourseInner(currNode)
							//showCourseMenu = false;
							//defaultIndex = i;
							//selectDefaultCourse = function() {
							//	if(intID >= 0) clearInterval(intID);
							//	this.master.courseMenu_lb.setSelectedIndex(defaultIndex);
							//}
							// pause for 3 seconds before enter default course
							//intID = setInterval(selectDefaultCourse, 3000);
							//break;
							return true;
						}
					}
				}
			}
			// v6.5 You might also be using the licence to state the ONLY certain course IDs can be run
			// So go through the ones you picked up from course.xml and disable any not in the licence
			if (_global.ORCHID.root.licenceHolder.licenceNS.validCourses.length>0) {
				myTrace("this licence has protected course IDs=" + _global.ORCHID.root.licenceHolder.licenceNS.validCourses); 
				// for each course in course.xml
				for (var i = 0; i < this.firstChild.childNodes.length; i++) {
					var currNode = this.firstChild.childNodes[i];
					//myTrace("now checking on " + currNode.attributes["id"]);
					// assume that it is disabled
					var currentlyDisabled = true;
					for (var j in  _global.ORCHID.root.licenceHolder.licenceNS.validCourses) {
						var thisValidCourse = _global.ORCHID.root.licenceHolder.licenceNS.validCourses[j];
						// but if we match the id, remove the disabling
						//if (currNode.attributes["id"] == thisValidCourse) {
						if (currNode.attributes["id"] == thisValidCourse) {
							// v6.5.4.5 so long as we haven't disable this course
							if (currNode.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.disabled) {
								// leave the disabling in place
							} else {
								currentlyDisabled = false;
							}
							break;
						}
					}
					if (currentlyDisabled) {
						myTrace("disable " + currNode.attributes["name"] + " as not listed in licence");
						currNode.attributes["enabledFlag"] |= _global.ORCHID.enabledFlag.disabled;
					}
				}
				//// v6.5.4.4 This has been moved into the query
				//this.master._visible = true
			}
			// v6.5.5.2 How about seeing if you have blocked everything now!
			var allCoursesDisabled=true;
			for (var i = 0; i < this.firstChild.childNodes.length; i++) {
				var currNode = this.firstChild.childNodes[i];
				//myTrace("check course " + currNode.attributes["name"] + " eF=" + currNode.attributes["enabledFlag"]);
				if (currNode.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.disabled) {
				} else {
					// OK, something is visible, proceed please!
					allCoursesDisabled=false;
					break;
				}
			}
			// v6.5.6 You could do with more differentiation here - like are there no courses due to privacy or hiding
			if (this.firstChild.childNodes.length==0) {
				// This section is really only relevant to AP I think
				var errObj = {literal:"noCourses", detail:_global.ORCHID.root.licenceHolder.licenceNS.product};
				_global.ORCHID.root.controlNS.sendNotice(errObj);
			} else if (allCoursesDisabled) {
				var errObj = {literal:"noVisibleCourses", detail:_global.ORCHID.root.licenceHolder.licenceNS.product};
				_global.ORCHID.root.controlNS.sendNotice(errObj);
				// Don't break, as it is fine to see the disabled courses list
			}
			
			// v6.4.3 This now becomes quite interface specific
			if (this.master.courseMenu.fromInterface) {
				// So no need to move anything around (unless you have extra courses from authoring!)
				// Warning - this very implicitly ties the interface to the order of nodes in the course.xml
				for (var i = 0; i < this.firstChild.childNodes.length; i++) {
					var currNode = this.firstChild.childNodes[i];
					// v6.5.4.4 You have to add a name (and maybe action) even for disabled courses otherwise Flash was doing
					//horrible things to the interface (huge spreads of orange). Probably due to the name being stretched.
					this.master.courseMenu["course"+i].setReleaseAction(_global.ORCHID.viewObj.selectCourse);
					//v6.4.2.1 Courses might be disabled meaning they haven't been published yet
					if (currNode.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.disabled) {
						this.master.courseMenu["course"+i].setEnabled(false); 
					} else {
						myTrace("enabled course " + unescape(currNode.attributes["name"]));
						//this.master.courseMenu["course"+i].setReleaseAction(_global.ORCHID.viewObj.selectCourse);
						//this.master.courseMenu["course"+i].setLabel(unescape(currNode.attributes["name"]));
						// how to get the XML data onto the button, and from there to the releaseAction function?
						this.master.coursemenu["course"+i].courseXML = currNode;
					}
					// v6.5.5.2 You need to disable first, then do setLabel to pick up the caption formatting correctly.
					this.master.courseMenu["course"+i].setLabel(unescape(currNode.attributes["name"]));
					//myTrace(currNode.attributes["name"] + " is width=" + this.master.courseMenu["course"+i]._width + this.master.courseMenu["course"+i]._xscale); 
				}
				// v6.5.4.3 Check the hiddenContent from database for Course level
				// Stop this for the network version until it has the same tables as online
				//if(_global.ORCHID.commandLine.scripting.toLowerCase() != "projector") {
				// v6.5.4.4 Moved above
				//if (_global.ORCHID.projector.name != "MDM") {
				//	myTrace("getHiddenContent for courses");
				//	this.master.queryHiddenContentForCourseLevel();
				//} else {
					// v6.5.4.4 This has been moved into the query
					this.master._visible = true;
				//}
			// Or did we load the courseTree?
			// The tree component is loaded in a separate Flash movie - should be there by now
			//myTrace("courseTree=" + this.master.courseMenu.menu_tree);
			// 6.4.3 Check which you are going to use
			} else if (this.master.courseMenu.menu_tree <> undefined) {
				//myTrace("x=" + this.master.fakeCourseTree._x);
				this.master.courseMenu._x = this.master.fakeCourseTree._x;
				this.master.courseMenu._y = this.master.fakeCourseTree._y;
				//myTrace("courseData=" + this.firstChild.toString());
				//this.master.courseMenu.menu_tree.labelField = "name";
				// I can't pass XML object, so turn it into a string here, then back to XML in the tree movie
				// 6.4.3 Have to leave it to the courseMenu to sort out how to handle enabledFlag I think.
				this.master.courseMenu.setDataProvider(unescape(this.firstChild.toString()));
				// To set the size and the initial opening of branches, see how many items you have 
				// and what space the interface gives you?
				this.master.courseMenu.menu_tree.setSize(this.master.fakeCourseTree._width, this.master.fakeCourseTree._height);
				this.master.courseMenu_lb._visible = false;
				this.master.courseMenu_lb._enabled = false;
				this.master.fakeCourseTree._visible = false;
				// Let this be branding based for now
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("NAS/MyC") >= 0) {
					//myTrace("opening 2 levels for MyC");
					this.master.courseMenu.openNodesToLevel(2);
				} else {
					//myTrace("opening all levels for AP");
					this.master.courseMenu.openAllNodes();
				}
				// v6.5.4.4 This has been moved into the query for hidden content
				this.master._visible = true	// v6.5.4.3 Yiu, i want the course to show later in (this.master.courseMenu.fromInterface) case
			} else {
				// v6.4.3 If you are still using the list not the tree
				// v6.4.3 Course structure, not just linear
				for (var i = 0; i < this.firstChild.childNodes.length; i++) { 
					var currNode = this.firstChild.childNodes[i];
					//v6.4.2.1 Courses might be disabled meaning they haven't been published yet
					// But older courses don't have this attribute at all.
					// AR v6.4.2.5 use disabled rather than menuOn
					//if (	currNode.attributes["enabledFlag"] == undefined ||
						//currNode.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.menuOn) {
					if (currNode.attributes["enabledFlag"] & _global.ORCHID.enabledFlag.disabled) {
						myTrace("course " + unescape(currNode.attributes["name"]) + " has not been published.");
					} else {
						// we need to know the full node rather than just the scaffold
						//myTrace("add course " + currNode.attributes["name"]);
						// v6.4.2.1 unescape names
						//this.master.courseMenu_lb.addItem(currNode.attributes["name"], currNode); 
						this.master.courseMenu_lb.addItem(unescape(currNode.attributes["name"]), currNode); 
					}
				}
				this.master.courseMenu_lb._visible = true;
				this.master.courseMenu_lb._enabled = true;
				// v6.5.4.4 This has been moved into the query for hidden content
				this.master._visible = true	// v6.5.4.3 Yiu, i want the course to show later in (this.master.courseMenu.fromInterface) case
			}
			// this.master._visible = true;	// v6.5.4.3 Yiu, i changed the visible of course menu, after I got the hiddelcontent and finsihed the overwritten of the xml nodes
			//v6.3.6 You really only want to do this once.
			// v6.3.6 BUT, you don't know whether to do it on login, course selection or menu screen do you?
			// So clearly the commandLine bit of it should not be tied into the interface component.
			//myTrace("course screen, lit_cb.pop=" + this.literal_cb.populated ,1);
			if (this.master.literal_cb.populated == undefined) {
				// v6.3.5 Since you now want the literal selector on most screens
				// v6.3.6 Just read from xml once
				//var literalList = _global.ORCHID.literalModelObj.getLiteralLanguageList();
				var literalList = _global.ORCHID.literalModelObj.langList;
				if (literalList.length > 1) {
					//myTrace("courseList - set languages");
					// v6.3.4 I would like to be able to preset the language from SCORM as well
					// v6.3.5 Or indeed if the course or start up has somehow preset it
					this.master.literal_cb.removeAll();
					for (var i = 0; i < literalList.length; i++) {
						//v6.4.1 Array now has code and name
						//this.master.literal_cb.addItem(_global.ORCHID.literalModelObj.getLiteral("languageName", "labels", literalList[i]), literalList[i]);
						//myTrace("course screen, adding " + literalList[i].name + " to comboBox",1);
						this.master.literal_cb.addItem(literalList[i].name, literalList[i].code);
					}
					this.master.literal_cb.setSelectedIndex(_global.ORCHID.literalModelObj.currentLiteralIdx);
	
				} else {
					myTrace("courseList - don't use lang choice");
					// hide the language selector if there is only one option
					this.master.literal_cb.setEnabled(false);
					// v6.4.3 Not being hidden on course screen
					this.master.literal_cb._visible = false;
				}
				this.master.literal_cb.populated = true;
			}

		} else {
			// v6.3.5 What about a visible warning to the user?
			myTrace("course XML cannot be loaded");
			//v6.3.6 CourseFile can be separate from content
			//var errObj = {literal:"cannotLoadXML", detail:_global.ORCHID.paths.content + "course.xml"};
			var errObj = {literal:"cannotLoadXML", detail:_global.ORCHID.paths.courseFile};
			_global.ORCHID.root.controlNS.sendError(errObj);			
		}
		//this.master._visible = showCourseMenu;
	}
	if(_global.ORCHID.online){
		var cacheVersion = "?version=" + Number(new Date());
	} else {
		var cacheVersion = "";
	}
	// v6.4.3 How about not reloading course.xml each time you come back to this screen? That would make
	// it easier to remember the state of the course tree. And who would want to be forever getting a new course.xml apart from me?
	// If you wanted to be fancy you could read course.xml again and display it if it has changed.
	// v6.5.3 Always reload if preview, see below
	//if (this.courseMenu.menu_tree.getTreeNodeAt(0)==undefined) {
	if (this.courseMenu.menu_tree.getTreeNodeAt(0)==undefined || _global.ORCHID.commandLine.preview) {
		myTrace("reload course file"); 
		this.courseMenu_lb.removeAll();
		// v6.3.5 Course.xml should SURELY be read from the content folder!
		//courseXML.load(_global.ORCHID.paths.root + "course.xml" + cacheVersion);
		//v6.3.6 CourseFile can be separate from content
		//courseXML.load(_global.ORCHID.paths.content + "course.xml" + cacheVersion);
		myTrace("loading " + _global.ORCHID.paths.courseFile);
		courseXML.load(_global.ORCHID.paths.courseFile + cacheVersion);
	} else {
		// This means we already have something in the course tree, so lets just stick with it
		// v6.5.3 Not quite - if we are working with preview and changing courses in Arthur this can go wrong.
		// v6.5.3 So always reload if preview.
		myTrace("keep existing course menu!"); 
		this._visible = true;
	}
	
	// v6.3.5 The position of the progress bar changes (can) for each screen.
	// So in the display we will reset the coords (based on a holder called progressBar)
	// If you don't have a holder on this screen, don't move the progress bar
	var myController = _global.ORCHID.root.tlcController;
	if (this.progressBar != undefined) {
		//myTrace("show progress bar, width=" + this.progressBar._width);
		myController._x =this.progressBar._x;
		myController._y =this.progressBar._y;
		myController._width =this.progressBar._width;
		myController._height =this.progressBar._height;
		// sometimes this gets strangely shrunken, but not always. Try forcing the scale of the font
		//myController._xscale = 100;
		myController._yscale = 100;
		this.progressBar._visible = false;
	}
	//v6.4.2.1 Add licencee name to the intro screen - can't do it earlier as literals not loaded.
	// Better to do it once you know, so it doesn't matter if you don't have a course list or login screen
	//var substList = [{tag:"[x]", text:_global.ORCHID.root.licenceHolder.licenceNS.institution}];
	//this._parent.IntroScreen.licenceCaption.text = _global.ORCHID.root.objectHolder.substTags(_global.ORCHID.literalModelObj.getLiteral("licencedTo", "labels"), substList);
	//myTrace("institution is: "  + _global.ORCHID.root.licenceHolder.licenceNS.institution);
	//myTrace("licence says: "  + this.licenceCaption.text);
	
	// v6.4.2.8 Not in demo warning, clear it
	_global.ORCHID.root.buttonsHolder.MessageScreen.demoWarning.notInDemo._visible = false;
}

_global.ORCHID.root.buttonsHolder.CourseListScreen.clear = function() {
	//trace("CourseListScreen.clear");
	this._visible = false;
	// v6.4.3 Not in demo warning, clear it
	_global.ORCHID.root.buttonsHolder.MessageScreen.demoWarning.notInDemo._visible = false;
}

// v6.5.4.3 Yiu, function to find hidden courses
// v6.5.4.5 I think I can move this to course.as
/*
_global.ORCHID.root.buttonsHolder.CourseListScreen.queryHiddenContentForCourseLevel= function() {
	var objTargetNode;
	var nProductCode;
	var nUserID;

	nProductCode	= _global.ORCHID.root.licenceHolder.licenceNS.productCode;
	nUserID		= _global.ORCHID.user.userID;

	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	thisDB.queryString =	'<query method	="getHiddenContentForCourseLevel" ' +
				'productCode	="' + nProductCode + '" ' + 
				'userID		="' + nUserID + '"/>';
				
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		for (var node in this.firstChild.childNodes) {
			objTargetNode = this.firstChild.childNodes[node];

			if (objTargetNode.nodeName == "err") {
			} else if (objTargetNode.nodeName == "result") {
				this.master.enableCourseWithXML(objTargetNode);	
			}
		}
		this.master._visible = true
	}
	thisDB.runQuery();
}

_global.ORCHID.root.buttonsHolder.CourseListScreen.enableCourseWithXML= function(objTargetNode) {
	var nTarNodeID;
	var nTarNodeEnabledFlag;
	nTarNodeID		= objTargetNode.attributes["id"];
	nTarNodeEnabledFlag	= objTargetNode.attributes["enabledFlag"];

	// thatz mean we dont need to disable it anyway
	if(nTarNodeEnabledFlag == 0)
		return ;

	for (var i = 0; i < this.m_nNumOfCourse; i++) {
		if(nTarNodeID == this.coursemenu["course"+i].courseXML.attributes["id"])
		{
			_global.myTrace("course with id " + nTarNodeID + " is disabled");
			this.courseMenu["course"+i].setEnabled(false);
		}
	}
}
*/
// v6.3.5 Put progress back as a popupwindow
/*
// v6.3.3 New screen for progress
_global.ORCHID.root.buttonsHolder.ProgressScreen.init = function() {
	myTrace("progressScreen.init");
	this.loaded = true;
}
_global.ORCHID.root.buttonsHolder.ProgressScreen.setLiterals = function() {
}
_global.ORCHID.root.buttonsHolder.ProgressScreen.display = function() {
	myTrace("progressScreen.display");
	this._visible = true;
}
_global.ORCHID.root.buttonsHolder.ProgressScreen.clear = function() {
	this._visible = false;
}
*/
// v6.3.3 New screen for making tests
_global.ORCHID.root.buttonsHolder.TestScreen.init = function() {
	myTrace("TestScreen.init");
	this.loaded = true;
}
_global.ORCHID.root.buttonsHolder.TestScreen.setLiterals = function() {
}
_global.ORCHID.root.buttonsHolder.TestScreen.display = function() {
	myTrace("TestScreen.display");
	this._visible = true;
}
_global.ORCHID.root.buttonsHolder.TestScreen.clear = function() {
	this._visible = false;
}
// v6.3.3 New screen for any other kind of popup
_global.ORCHID.root.buttonsHolder.MessageScreen.init = function() {
	myTrace("MessageScreen.init");
	this.loaded = true;
}
_global.ORCHID.root.buttonsHolder.MessageScreen.setLiterals = function() {
	// v6.4.2.8 Not in demo warning
	this.demoWarning.notInDemo.notInDemo_lbl.text = _global.ORCHID.literalModelObj.getLiteral("notInDemo", "messages");
}
_global.ORCHID.root.buttonsHolder.MessageScreen.display = function() {
	//myTrace("MessageScreen.display");
	//this._visible = true;
}
_global.ORCHID.root.buttonsHolder.MessageScreen.clear = function() {
	//this._visible = false;
}
// v6.5.6 Used to allow content files saved on another domain to get at _global.ORCHID
_global.ORCHID.root.buttonsHolder.getGlobalOrchid = function() {
	return _global.ORCHID;
}

