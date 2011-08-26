
// checkBoxes
chbs.lastClickedItem = "";
chbs.firstClick = 0;
chbs.click = function(evtObj) : Void {
	this.checkboxOnClick(evtObj.target);
	var qNo = Number(NNW.screens.txts.txtQuestionNo.text); //v0.12.0, DL: NNW.screens.nsps.nspQuestionNo.value;
	var chbName = evtObj.target._name;
	switch (chbName) {
	case "chbImagePos0" :	// v0.16.0, DL:  image position
		// v0.16.1, DL: need change the image if switching to/from banner
		// Yiu v6.5.1 Remove Banner
		/*if (combos.comboImageCategory.value!="YourGraphic" && NNW.control.data.currentExercise.image.position=="banner") {
			NNW.control.updateExerciseImagePosition("top-right");
			NNW.control.updateExerciseImage("category", combos.comboImageCategory.value);
		} else {*/
			NNW.control.updateExerciseImagePosition("top-right");
		//}
		// End Yiu v6.5.1 Remove Banner
		break;
	case "chbImagePos1" :	// v0.16.0, DL:  image position
		// v0.16.1, DL: need change the image if switching to/from banner
		// Yiu v6.5.1 Remove Banner
		/*
		if (combos.comboImageCategory.value!="YourGraphic" && NNW.control.data.currentExercise.image.position=="banner") {
			NNW.control.updateExerciseImagePosition("top-left");
			NNW.control.updateExerciseImage("category", combos.comboImageCategory.value);
		} else {*/
			NNW.control.updateExerciseImagePosition("top-left");
		//}
		// End Yiu v6.5.1 Remove Banner
		break;
	case "chbImagePos2" :	// v0.16.0, DL:  image position
		// v0.16.1, DL: need change the image if switching to/from banner
		// Yiu v6.5.1 Remove Banner
		/*
		if (combos.comboImageCategory.value!="YourGraphic" && NNW.control.data.currentExercise.image.position!="banner") {
			NNW.control.updateExerciseImagePosition("banner");
			NNW.control.updateExerciseImage("category", combos.comboImageCategory.value);
		} else {
			NNW.control.updateExerciseImagePosition("banner");
		}
		*/
		// End Yiu v6.5.1 Remove Banner
		break;
	case "chbVideoPos0" :	// v0.16.1, DL:  video position - embed top-right
		var fileName = NNW.screens.txts.txtFilenameVideo.text;
		// video is embedded, so there cannot be any image
		NNW.control.updateExerciseImage("category", "NoGraphic");
		// mode 1 of video is embedded in exercise, mode 16 is floating
		NNW.control.updateExerciseVideo(fileName, "1", "top-right");
		break;
	case "chbVideoPos1" :	// v0.16.0, DL:  video position - embed top-left
		var fileName = NNW.screens.txts.txtFilenameVideo.text;
		// video is embedded, so there cannot be any image
		NNW.control.updateExerciseImage("category", "NoGraphic");
		// mode 1 of video is embedded in exercise, mode 16is floating
		NNW.control.updateExerciseVideo(fileName, "1", "top-left");
		break;
		// Yiu v6.5.1 Remove Banner
		/*
	case "chbVideoPos2" :	// v0.16.0, DL:  video position - embed banner
		var fileName = NNW.screens.txts.txtFilenameVideo.text;
		// video is embedded, so there cannot be any image
		NNW.control.updateExerciseImage("category", "NoGraphic");
		// mode 1 of video is embedded in exercise, mode 16 is floating
		NNW.control.updateExerciseVideo(fileName, "1", "banner");
		break;
		*/
		// End Yiu v6.5.1 Remove Banner
	case "chbVideoPos3" :	// v0.16.0, DL:  video position - floating
		var fileName = NNW.screens.txts.txtFilenameVideo.text;
		// mode 1 of video is embedded in exercise, mode 16 is floating
		NNW.control.updateExerciseVideo(fileName, "16", "");
		break;

	// v6.4.2.7 Adding URLs - the chb controls the mode of this URL
	// just one of them can be linked from toolbar button
	// mode 1 is toolbar - the caption and URL are handled elsewhere
	// mode 2 is under the picture
	case "chbURLToolbar1" :	
		//var fileName = NNW.screens.txts.txtURL1.text;
		//_global.myTrace("switch chb1 to " + evtObj.target.selected);
		if (evtObj.target.selected) {
			NNW.control.updateExerciseURL(1, undefined, undefined,true);
			NNW.control.updateExerciseURL(2, undefined, undefined,false);
			NNW.control.updateExerciseURL(3, undefined, undefined,false);
			this.setChecked("chbURLToolbar2", false);
			this.setChecked("chbURLToolbar3", false);
		} else {
			NNW.control.updateExerciseURL(1, undefined, undefined, false);
		}
		break;
	case "chbURLToolbar2" :	
		//_global.myTrace("switch chb2 to " + evtObj.target.selected);
		if (evtObj.target.selected) {
			NNW.control.updateExerciseURL(2, undefined, undefined, true);
			NNW.control.updateExerciseURL(1, undefined, undefined,false);
			NNW.control.updateExerciseURL(3, undefined, undefined,false);
			this.setChecked("chbURLToolbar1", false);
			this.setChecked("chbURLToolbar3", false);
		} else {
			NNW.control.updateExerciseURL(2, undefined, undefined, false);
		}
		break;
	case "chbURLToolbar3" :	
		if (evtObj.target.selected) {
			NNW.control.updateExerciseURL(3, undefined, undefined, true);
			NNW.control.updateExerciseURL(1, undefined, undefined, false);
			NNW.control.updateExerciseURL(2, undefined, undefined, false);
			this.setChecked("chbURLToolbar1", false);
			this.setChecked("chbURLToolbar2", false);
		} else {
			NNW.control.updateExerciseURL(3, undefined, undefined, false);
		}
		break;
		
	case "chbMarkingInstant" :
		NNW.control.updateExerciseSettings("marking", "instant", true);
		NNW.control.updateExerciseSettings("buttons", "chooseInstant", false);
		break;
	// v6.4.2.5 sound effects
	case "chbSoundEffects" :
		NNW.control.updateExerciseSettings("misc", "soundEffects", evtObj.target.selected);
		break;
	case "chbMarkingDelayed" :
		NNW.control.updateExerciseSettings("marking", "instant", false);
		NNW.control.updateExerciseSettings("buttons", "chooseInstant", false);
		break;
	case "chbMarkingChoose" :
		NNW.control.updateExerciseSettings("marking", "instant", false);
		NNW.control.updateExerciseSettings("buttons", "chooseInstant", true);
		break;
	case "chbBtnFeedback" :	// v0.16.0, DL: switch on/off feedback button
		NNW.control.updateExerciseSettings("buttons", "feedback", evtObj.target.selected);
		break;
	case "chbBtnMarking" :	// v0.16.0, DL: switch on/off marking button
		NNW.control.updateExerciseSettings("buttons", "marking", evtObj.target.selected);
		if(evtObj.target.selected){
			this.chbBtnFeedback.enabled	= true;
		} else {
			this.setChecked("chbBtnFeedback", false);
			NNW.control.updateExerciseSettings("buttons", "feedback", false);
			this.chbBtnFeedback.enabled	= false;
		}
		break;
	// v6.4.2.8 For TB rules
	case "chbBtnRule" :
		NNW.control.updateExerciseSettings("buttons", "rule", evtObj.target.selected);
		break;
	case "chbInstructionsAudioDefault" :
		if (evtObj.target.selected) {
			if (this.chbInstructionsAudioUpload.selected) {
				this.chbInstructionsAudioUpload.selected = false;
				// v0.16.1, DL: del non-shared instructions audio
				NNW.control.updateExerciseInstructionsAudio(false, false);
			}
		}
		// v0.16.1, DL: add shared instructions audio
		NNW.control.updateExerciseInstructionsAudio(true, evtObj.target.selected);
		break;
		
	// v0.16.1, DL: move the upload feature into the browse window
	// so this case does not exist anymore
	case "chbInstructionsAudioUpload" :
		// v0.16.1, DL: debug - this should be done after upload has finished
		/*if (evtObj.target.selected) {
			if (this.chbInstructionsAudioDefault.selected) {
				this.chbInstructionsAudioDefault.selected = false;
				// v0.16.1, DL: del shared instructions audio
				NNW.control.updateExerciseInstructionsAudio(true, false);
			}
		}
		// v0.16.1, DL: add non-shared instructions audio
		NNW.control.updateExerciseInstructionsAudio(false, evtObj.target.selected);
		*/
		NNW.control.uploadAudio("AutoPlay");
		break;
	// v0.16.1, DL: move the upload feature into the browse window
	// so this case does not exist anymore
	case "chbEmbedAudio" :
		if (evtObj.target.selected) {
			NNW.control.uploadAudio("Embed");
		} else {
			NNW.control.updateExerciseEmbedAudio("");
		}
		break;
	// v0.16.1, DL: move the upload feature into the browse window
	// so this case does not exist anymore
	case "chbAfterMarkingAudio" :
		if (evtObj.target.selected) {
			NNW.control.uploadAudio("AfterMarking");
		} else {
			NNW.control.updateExerciseAfterMarkingAudio("");
		}
		break;
		
	case "chbQuestionAudio" :
	case "chbSplitScreenQuestionAudio" :
		if (!NNW.control.data.currentExercise.settings.misc.splitScreen) {
			var qNo = Number(NNW.screens.txts.txtQuestionNo.text);
		} else {
			var qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
		}
		if (evtObj.target.selected) {
			NNW.control.uploadMultipleAudio("Question", qNo);
		} else {
			if (!NNW.control.data.currentExercise.settings.misc.splitScreen) {
				var mode = (this.chbQuestionAudioAfterMarking.selected) ? "2" : "1";
			} else {
				var mode = (this.chbSplitScreenQuestionAudioAfterMarking.selected) ? "2" : "1";
			}
			NNW.control.updateExerciseQuestionAudio("", mode, qNo);
		}
		//NNW.screens.btns.lblQuestionAudio.text = "";
		//NNW.screens.btns.lblSplitScreenQuestionAudio.text = "";
		//NNW.screens.chbs.chbQuestionAudioAfterMarking.visible = false;
		//NNW.screens.chbs.chbSplitScreenQuestionAudioAfterMarking.visible = false;
		break;
	case "chbQuestionAudioAfterMarking" :
	case "chbSplitScreenQuestionAudioAfterMarking" :
		if (!NNW.control.data.currentExercise.settings.misc.splitScreen) {
			var qNo = Number(NNW.screens.txts.txtQuestionNo.text);
		} else {
			var qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
		}
		if (evtObj.target.selected) {
			NNW.control.updateExerciseQuestionAudio(undefined, "2", qNo);
		} else {
			NNW.control.updateExerciseQuestionAudio(undefined, "1", qNo);
		}
		break;
	case "chbEmbedVideo" :
		if (evtObj.target.selected) {
			NNW.control.uploadVideo("Embed");
		} else {
			NNW.control.updateExerciseVideo("", "1", "top-right");
		}
		break;
	/*case "chbFloatingVideo" :
		if (evtObj.target.selected) {
			NNW.control.uploadVideo("Floating");
		} else {
			NNW.control.updateExerciseVideo("", "4");
		}
		break;*/
	case "chbCapitalisation" :
		NNW.control.updateExerciseSettings("exercise", "matchCapitals", evtObj.target.selected);
		break;
	case "chbSameLengthGaps" :
		if (evtObj.target.selected) {
			if (NNW.control.data.currentExercise.exerciseType == "Countdown") {
				// v6.5.1 Yiu get rip of the same length gap slider which is not used
				NNW.control.updateExerciseSettings("exercise", "sameLengthGaps", NNW.screens.sliderSameLengthGap.getValue().toString());
				} else {
				NNW.control.updateExerciseSettings("exercise", "sameLengthGaps", "true");
			}
			NNW.screens.handleSameLengthGapsChecked(true);
		} else {
			NNW.control.updateExerciseSettings("exercise", "sameLengthGaps", "");
			NNW.screens.handleSameLengthGapsChecked(false);
			
			if (!NNW.control.data.currentExercise.exerciseType == "Countdown") {
				NNW.screens.showSliderAndLabel(true);
			}
		} 
		break;
	// v6.5.1 Yiu new default gap length check box and slider 
	case "chbDefaultLengthGaps":
		if (evtObj.target.selected) {
			NNW.control.updateExerciseSettings("exercise", "defaultLengthGaps", NNW.screens.sliderDefaultLengthGap.getValue().toString());
			NNW.screens.handleDefaultLengthGapsChecked(true);
		} else {			
			NNW.control.updateExerciseSettings("exercise", "defaultLengthGaps", "");
			NNW.screens.handleDefaultLengthGapsChecked(false);
		}
		 
		// when it is checked or unchecked, should update the existing question first
		var ex 			= NNW.control.data.currentExercise;
		
		if (ex.exerciseType	!= "Stopgap")
			NNW.screens.textFormatting.resetFormatURL();
			
		var splitScreen = ex.settings.misc.splitScreen; 
		var qNo 		= (splitScreen) ? Number(NNW.screens.txts.txtSplitScreenQuestionNo.text) : Number(NNW.screens.txts.txtQuestionNo.text);
		ex.initExerciseScreenGapLength(qNo);
		NNW.screens.checkAndSetlblShowDefaultVisible();
		break;
	// End v6.5.1 Yiu new default gap length check box and slider 
	case "chbNoFirstTime" :	// v0.11.0, DL: show first time screen setting
		NNW.control.setShowFirstTime(evtObj.target.selected);
		break;
	case "chbShowTextFirst" :	// v0.12.0, DL: show text before countdown
		NNW.control.updateExerciseSettings("exercise", "preview", evtObj.target.selected);
		
		// v6.4.1, DL: different default instructions for preview in countdown
		if (this.chbInstructionsAudioDefault.selected) {
			NNW.control.updateExerciseInstructionsAudio(true, true);
		}
		break;
	case "chbHideTargets" :	// v0.16.0, DL: hide targets for target spotting exercise
		NNW.control.updateExerciseSettings("exercise", "hiddenTargets", evtObj.target.selected);
		
		// v6.4.1, DL: different default instructions for hidden targets
		if (this.chbInstructionsAudioDefault.selected) {
			NNW.control.updateExerciseInstructionsAudio(true, true);
		}
		break;
	case "chbOverwriteAnswers" :	// v0.16.0, DL: overwrite answers for drags/gaps
		NNW.control.updateExerciseSettings("marking", "overwriteAnswers", evtObj.target.selected);
		break;
	case "chbFeedbackScoreBased" :	// v0.16.0, DL: score-based feedback
		if (evtObj.target.selected) { 
			this.chbFeedbackDifferent.selected = false; 
			// ar v6.4.2.1 If you are having score based feedback, cannot have instant
			NNW.control.updateExerciseSettings("buttons", "feedback", true);
			NNW.control.updateExerciseSettings("buttons", "marking", true);
			NNW.control.updateExerciseSettings("marking", "delayed", true);
			this.setChecked("chbMarkingInstant", false);
			this.setChecked("chbMarkingDelayed", true);
			this.setChecked("chbMarkingChoose", false);
			this.chbMarkingInstant.enabled = false;
			// v6.4.2.5 sound effects
			this.chbSoundEffects.enabled = false;
			this.chbMarkingDelayed.enabled = false;
			this.chbMarkingChoose.enabled = false;
			// ar v6.4.2.1 If you are having score based feedback, default marking and feedback buttons
			this.setChecked("chbBtnMarking", true);
			this.setChecked("chbBtnFeedback", true);
		} else {
			// ar v6.4.2.1 
			this.chbMarkingInstant.enabled = true; 
			// v6.4.2.5 sound effects
			this.chbSoundEffects.enabled = true;
			this.chbMarkingDelayed.enabled = true;
			this.chbMarkingChoose.enabled = true;
		}
				
		NNW.control.updateExerciseSettings("feedback", "scoreBased", this.chbFeedbackScoreBased.selected);
		NNW.control.updateExerciseSettings("feedback", "groupBased", !this.chbFeedbackDifferent.selected);
		NNW.screens.refreshFeedbackHint(); 
		
		// v6.5.0.1 Yiu fixing score base feedback box present
		var exType = NNW.control.data.currentExercise.exerciseType;
		switch(exType)
		{
			case "Stopdrop":
			case "Stopgap":
			case "DragAndDrop":
			case "Analyze":
			case "SplitGapfill":
			/*
			 
				var ex = NNW.control.data.currentExercise;
				if (ex.settings.feedback.scoreBased) {
					scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = false;
					NNW.view.setVisible("btnScoreBasedFeedback", true);
				} else {
					scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = true;
					NNW.view.setVisible("btnScoreBasedFeedback", false);
				}
			 
			 * */
				NNW.screens.visibleFeedbackAndHintIfADropPresent();
				break;
			// v6.5.4.1 AR It seems that qusetionSpotter should be listed here too, except I don't have hint. Does it matter?
			// Yes, so I suppose need a similar version, but without the hint. So separate from the above.
			case _global.g_strQuestionSpotterID:
				NNW.screens.visibleFeedbackIfADropPresent();
				break;
		}
		break;
	case "chbFeedbackDifferent" :	// v0.16.0, DL: different feedback
		if (evtObj.target.selected) { this.chbFeedbackScoreBased.selected = false; }
		NNW.control.updateExerciseSettings("feedback", "scoreBased", this.chbFeedbackScoreBased.selected);
		NNW.control.updateExerciseSettings("feedback", "groupBased", !this.chbFeedbackDifferent.selected);
		NNW.screens.refreshFeedbackHint();
		break;
	case "chbSplitScreen" :	// v0.16.1, DL: split-screen exercise
		NNW.control.updateExerciseSettings("misc", "splitScreen", evtObj.target.selected);
		
		// v6.4.1, DL: if it's MC then change to Analyze, vice versa
		var exType = NNW.control.data.currentExercise.exerciseType;
		if (exType=="Analyze") {
			NNW.control.data.currentExercise.exerciseType = "MultipleChoice";
		} else if (exType=="MultipleChoice"){
			NNW.control.data.currentExercise.exerciseType = "Analyze";
		}
		
		// update the picture (vertical <-> horizontal)
		
		// v6.5.1 Yiu fix upload photo keep popup problem, the third parameter added
		NNW.control.updateExerciseImage("category", combos.comboImageCategory.value, true);
		// disable image position settings for split-screen
		enableImagePositionCheckBoxes((!evtObj.target.selected));
		// update question screen
		NNW.screens.changeQuestionSegment();
		NNW.screens.refreshFeedbackHint();
		var ex = NNW.control.data.currentExercise;
		qNo = (evtObj.target.selected) ? Number(NNW.screens.txts.txtSplitScreenQuestionNo.text) : Number(NNW.screens.txts.txtQuestionNo.text);
		NNW.view.fillInQuestionDetails(ex, qNo);
		
		break;
	case "chbDragTimes" :	// v0.16.1, DL: drag times for drags
		if (evtObj.target.selected) {
			NNW.control.updateExerciseSettings("exercise", "dragTimes", 0);	// it means nothing in XML file - only 1 means once
		} else {
			NNW.control.updateExerciseSettings("exercise", "dragTimes", 1);
		}
		break;
	case "chbOption0" :
		this.ensureAtLeastOneCheckboxIsChecked("chbOption", "0", true);
		NNW.screens.updateOptions();
		break;
	case "chbOption1" :
		this.ensureAtLeastOneCheckboxIsChecked("chbOption", "1", true);
		NNW.screens.updateOptions();
		break;
	case "chbOption2" :
		this.ensureAtLeastOneCheckboxIsChecked("chbOption", "2", true);
		NNW.screens.updateOptions();
		break;
	case "chbOption3" :
		this.ensureAtLeastOneCheckboxIsChecked("chbOption", "3", true);
		NNW.screens.updateOptions();
		break;
	case "chbRMCOption0" :
		qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text); //v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.value;
		this.ensureAtLeastOneCheckboxIsChecked("chbRMCOption", "0", true);
		NNW.screens.updateRMCOptions();
		break;
	case "chbRMCOption1" :
		qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text); //v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.value;
		this.ensureAtLeastOneCheckboxIsChecked("chbRMCOption", "1", true);
		NNW.screens.updateRMCOptions();
		break;
	case "chbRMCOption2" :
		qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text); //v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.value;
		this.ensureAtLeastOneCheckboxIsChecked("chbRMCOption", "2", true);
		NNW.screens.updateRMCOptions();
		break;
	case "chbRMCOption3" :
		qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text); //v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.value;
		this.ensureAtLeastOneCheckboxIsChecked("chbRMCOption", "3", true);
		NNW.screens.updateRMCOptions();
		break;
	case "chbOtherOption0" :
		NNW.control.updateExercise("answer", qNo, NNW.screens.txts["txtOtherOption0"].text, 0, NNW.screens.chbs.getChecked(chbName));
		break;
	case "chbOtherOption1" :
		NNW.control.updateExercise("answer", qNo, NNW.screens.txts["txtOtherOption1"].text, 1, NNW.screens.chbs.getChecked(chbName));
		break;
	case "chbOtherOption2" :
		NNW.control.updateExercise("answer", qNo, NNW.screens.txts["txtOtherOption2"].text, 2, NNW.screens.chbs.getChecked(chbName));
		break;
	case "chbOtherOption3" :
		NNW.control.updateExercise("answer", qNo, NNW.screens.txts["txtOtherOption3"].text, 3, NNW.screens.chbs.getChecked(chbName));
		break;
	case "chbTrueOption" :
		this.setChecked("chbTrueOption", true);
		this.setChecked("chbFalseOption", false);
		NNW.screens.updateTrueFalseOptions();
		break;
	case "chbFalseOption" :
		this.setChecked("chbFalseOption", true);
		this.setChecked("chbTrueOption", false);
		NNW.screens.updateTrueFalseOptions();
		break;
		
	// v0.16.0, DL: quiz options (true/false or user-defined)
	/*case "chbTrue" :
	case "chbFalse" :
		this.checkPanelCheckbox(chbName, evtObj.target._parent._name.substr(-1, 1));
		NNW.screens.panels.highlightSelected(evtObj.target._parent._name);
		break;*/
	case "chbQuizOptions0" :
	case "chbQuizDummyOption" :
		this.chbQuizDummyOption.iconName._visible = false;
		this.setChecked("chbQuizOptions0", true);
		this.setChecked("chbQuizOptions1", false);
		NNW.screens.updateQuizOptionsLabels();
		this["chbQuizOptions0"].setFocus();
		break;
	case "chbQuizOptions1" :
		this.setChecked("chbQuizOptions1", true);
		this.setChecked("chbQuizOptions0", false);
		NNW.screens.updateQuizOptionsLabels();
		NNW.screens.txts.txtTrue.setFocus();
		Selection.setSelection(0,0);
		break;
		
	case "chbCorrectTarget" :	// v0.16.0, DL: correct target for target spotting
		qNo = NNW.screens.textFormatting.activeFieldNo;
		var a = NNW.control.data.currentExercise.fieldManager.getAnswers(qNo+1);
		NNW.control.updateExercise("option", qNo, a[0].value, 0, evtObj.target.selected);
		NNW.control.onExerciseChanged();
		break;
		
	case "chbTestMode" :
		if (evtObj.target.selected) {
			NNW.control.updateExerciseSettings("marking", "test", true);
			NNW.control.updateExerciseSettings("marking", "instant", false);
			NNW.control.updateExerciseSettings("buttons", "chooseInstant", false);
						
			// v6.5.1 Yiu hidden progress, scratchPad, print and hints button when the exercise is a test
			NNW.control.updateExerciseSettings("buttons", "progress", false);
			NNW.control.updateExerciseSettings("buttons", "scratchPad", false);
			NNW.control.updateExerciseSettings("buttons", "print", false);
			NNW.control.updateExerciseSettings("buttons", "hints", false);
			// End v6.5.1 Yiu hidden progress, scratchPad, print and hints button when the exercise is a test
			
			this.setChecked("chbMarkingInstant", false);
			this.setChecked("chbMarkingDelayed", true);
			this.setChecked("chbMarkingChoose", false);
			this.chbMarkingInstant.enabled = false;
			// v6.4.2.5 sound effects - always leave them available
			//this.chbSoundEffects.enabled = false;
			this.chbMarkingDelayed.enabled = false;
			this.chbMarkingChoose.enabled = false;
			//v6.4.2.1 AR Also disable feedback button (switch off)
			NNW.control.updateExerciseSettings("buttons", "feedback", false);
			this.setChecked("chbBtnFeedback", false);
			this.chbBtnFeedback.enabled = false;
			//v6.4.2.8 AR Also disable rule button (switch off)
			NNW.control.updateExerciseSettings("buttons", "rule", false);
			this.setChecked("chbBtnRule", false);
			this.chbBtnRule.enabled = false;
			//v6.4.2.2 AR Force on marking button (will become submit)
			NNW.control.updateExerciseSettings("buttons", "marking", true);
			this.setChecked("chbBtnMarking", true);
			this.chbBtnMarking.enabled = false;
			// v6.4.2.6 Also disable score based feedback option
			chbs.chbFeedbackScoreBased.enabled = false;
		} else {
			NNW.control.updateExerciseSettings("marking", "test", false);
			this.chbMarkingInstant.enabled = true;
			// v6.4.2.5 sound effects
			//this.chbSoundEffects.enabled = true;
			this.chbMarkingDelayed.enabled = true;
			this.chbMarkingChoose.enabled = true;
			//v6.4.2.1 AR Now enable the marking and feedback buttons if not a test
			NNW.control.updateExerciseSettings("buttons", "feedback", true);
			NNW.control.updateExerciseSettings("buttons", "marking", true);
						
			// v6.5.1 Yiu restore hidden progress, scratchPad, print and hints button when the exercise is not a test
			NNW.control.updateExerciseSettings("buttons", "progress", true);
			NNW.control.updateExerciseSettings("buttons", "scratchPad", true);
			NNW.control.updateExerciseSettings("buttons", "print", true);
			NNW.control.updateExerciseSettings("buttons", "hints", true);
			// End v6.5.1 Yiu restore hidden progress, scratchPad, print and hints button when the exercise is not a test
			
			this.setChecked("chbBtnMarking", true);
			this.setChecked("chbBtnFeedback", true);
			this.chbBtnMarking.enabled = true;
			this.chbBtnFeedback.enabled = true;
			//v6.4.2.8 AR Also enable rule button
			this.chbBtnRule.enabled = true;
			// v6.4.2.6 Also enable score based feedback option
			chbs.chbFeedbackScoreBased.enabled = true;
		}
		NNW.control.onExerciseChanged();
		break;
	case "chbNeutralFeedback" :	// v0.16.0, DL: neutral feedback for target spotting
		// change all targets to neutral/true according to the selection
		// v6.4.1.3, DL: debug - neutral marking => no marking button, no feedback button, only instant marking
		if (evtObj.target.selected) {
			NNW.control.updateExerciseTargetsCorrectness("neutral");
			NNW.control.updateExerciseSettings("feedback", "neutral", true);
			NNW.control.updateExerciseSettings("buttons", "feedback", false);
			NNW.control.updateExerciseSettings("buttons", "marking", false);
			NNW.control.updateExerciseSettings("marking", "instant", true);
			NNW.control.updateExerciseSettings("buttons", "chooseInstant", false);
			this.setChecked("chbBtnMarking", false);
			this.setChecked("chbBtnFeedback", false);
			this.chbBtnMarking.enabled = false;
			this.chbBtnFeedback.enabled = false;
			this.setChecked("chbMarkingInstant", true);
			this.setChecked("chbMarkingDelayed", false);
			this.setChecked("chbMarkingChoose", false);
			this.chbMarkingInstant.enabled = false;
			// v6.4.2.5 sound effects
			this.chbSoundEffects.enabled = false;
			this.chbMarkingDelayed.enabled = false;
			this.chbMarkingChoose.enabled = false;
			// v6.4.2.1 You have score based feedback now, dim that 
			NNW.control.updateExerciseSettings("feedback", "scoreBased", false);
			this.chbFeedbackScoreBased.enabled = false;
			this.setChecked("chbFeedbackScoreBased", false);
			// This seems to be needed when you change score based
			NNW.screens.refreshFeedbackHint();
		} else {
			NNW.control.updateExerciseTargetsCorrectness("true");
			NNW.control.updateExerciseSettings("feedback", "neutral", false);
			this.chbBtnMarking.enabled = true;
			this.chbBtnFeedback.enabled = true;
			this.chbMarkingInstant.enabled = true;
			// v6.4.2.5 sound effects
			this.chbSoundEffects.enabled = true;
			this.chbMarkingDelayed.enabled = true;
			this.chbMarkingChoose.enabled = true;
			// v6.4.2.1 You have score based feedback now, enable that 
			this.chbFeedbackScoreBased.enabled = true;
		}
		break;
	case "chbCourseEnable" :
		NNW.control.updateCourseEnabled(evtObj.target.selected);
		break;
	case "chbPrivacyPrivate":
		this.chbPrivacyPrivate.selected = true;
		this.chbPrivacyGroup.selected = false;
		this.chbPrivacyPublic.selected = false;
		NNW.control.updateCoursePrivacy(1);
		break;
	case "chbPrivacyGroup":
		this.chbPrivacyPrivate.selected = false;
		this.chbPrivacyGroup.selected = true;
		this.chbPrivacyPublic.selected = false;
		NNW.control.updateCoursePrivacy(2);
		break;
	case "chbPrivacyPublic":
		this.chbPrivacyPrivate.selected = false;
		this.chbPrivacyGroup.selected = false;
		this.chbPrivacyPublic.selected = true;
		NNW.control.updateCoursePrivacy(4);
		break;
	}
}

chbs.checkboxOnClick = function(thisCB) : Void {
	// reset others to false
	this.resetOthersToFalse(thisCB, "chbExType");
	this.resetOthersToFalse(thisCB, "chbMarking");
	this.resetOthersToFalse(thisCB, "chbImagePos");	// v0.16.0, DL: image position
	this.resetOthersToFalse(thisCB, "chbQuizOptions");	// v0.16.0, DL: quiz options (true/false or user-defined)
	this.resetOthersToFalse(thisCB, "chbVideoPos");	// v0.16.1, DL: video position
	
	// check double click
	this.checkDoubleClick(thisCB, "chbExType");
}

chbs.ensureAtLeastOneCheckboxIsChecked = function(chbName:String, no:String, onClick:Boolean) : Void {
	var selected = false;
	for (var i in this) {
		if (i.substr(0, chbName.length)==chbName) {
			if (this[i].selected) { selected = true; }
		}
	}
	if (!selected) {
		this[chbName+no].selected = true;
	}
}

/* this function is to mark all other checkBoxes in this group to false and force thisCB to be true */
chbs.resetOthersToFalse = function(thisCB, chbName:String) : Void {
	if (thisCB._name.substr(0, chbName.length)==chbName) {
		for (var i in this) {
			if (this[i]._name!=thisCB._name and this[i]._name.substr(0, chbName.length)==chbName) {
				this[i].selected = false;
			}
		}
		thisCB.selected = true;
	}
}

/* this function is to capture the double-clicks on checkBoxes */
chbs.checkDoubleClick = function(thisCB, chbName:String) : Void {
	if (thisCB._name.substr(0, chbName.length)==chbName) {
		// AR v6.4.2.5 Make the double click faster as too easy to be trying to see the exType explanations.
		//if (getTimer() - this.firstClick < 750 && this.lastClickedItem==thisCB._name) {
		if (getTimer() - this.firstClick < 400 && this.lastClickedItem==thisCB._name) {
			/* double click*/
			NNW.control.selectExType(NNW.screens.getSelectedExType());
		} else {
			/* single click */
			this.lastClickedItem = thisCB._name;
		}
		this.firstClick = getTimer();
	}
}

chbs.resetCheckBoxesByName = function(chbName:String, checkFirstBox:Boolean) : Void {
	for (var i in this) {
		if (this[i]._name.substr(0, chbName.length)==chbName) {
			this[i].selected = false;
		}
	}
	if (checkFirstBox) {
		this[chbName+"01"].selected = true;
	}
}

chbs.getSelectedCheckBox = function(chbName:String) : String {
	for (var i in this) {
		if (i.substr(0, chbName.length)==chbName and this[i].selected) {
			return i;
		}
	}
	return "";
}

chbs.getChecked = function(chbName:String) : Boolean {
	return this[chbName].selected;
}

chbs.setChecked = function(chbName:String, value:Boolean) : Void {
	if (value) {
		this[chbName].selected = true;
	} else {
		this[chbName].selected = false;
	}
}

// v0.16.0, DL: this function is no longer used because there're no panels anymore
/* this function is to reset checkBoxes in True/False panels */
chbs.checkPanelCheckbox = function(chbName:String, no:String) : Void {
	/*for (var i in this) {
		var cn = i;
		if (cn==chbName+no) {
			this.setChecked(cn, true);
			NNW.screens.panels.updateTrueFalseOptions(cn);
			this[cn].setFocus();
		} else if (cn.substr(0, 7)=="chbTrue") {
			this.setChecked(cn, false);
		} else if (cn.substr(0, 8)=="chbFalse") {
			this.setChecked(cn, false);
		}
	}*/
	/*for (var i in this) {
		var cn = i;
		if (cn.substr(0, 7)=="chbTrue"||cn.substr(0, 8)=="chbFalse") {
			if (cn.substr(-1,1)==no) {
				this.setChecked("chbTrue"+no, true);
				this.setChecked("chbFalse"+no, false);
				NNW.screens.panels.updateTrueFalseOptions(cn);
				// v0.5.2, DL: debug - setting focus to the checkbox makes us can't use space in txtTrue/txtFalse
				if (no!="2") {
					this["chbTrue"+no].setFocus();
				}
			} else if ((cn.substr(0, 7)=="chbTrue"&&cn.length==8) || (cn.substr(0, 8)=="chbFalse"&&cn.length==9)){
				this.setChecked(cn, false);
			}
		}
	}*/
}

// v0.9.0, DL: show tooltip for dragging/rolling over a checkbox
chbs.dragOver = function(evtObj:Object) : Void {
	this.rollOver(evtObj);
}

chbs.getCheckBoxIdStr	= function(strTypeName:String):String{
	switch(strTypeName) {
		case "chbExType01" :
		case "chbExType02" :
			return "MultipleChoice";
			break;
		case "chbExType03" :
		case "chbExType13" :
			return "Dropdown";
			break;
		case "chbExType04" :
		case "chbExType05" :
			return "DragAndDrop";
			break;
		case "chbExType06" :
		case "chbExType07" :
			return "Gapfill";
			break;
		case "chbExType08" :
			return "TextReconstruction";
			break;
		case "chbExType09" :
			return "Analyze";
			break;
		case "chbExType10" :
		case "chbExType15" :
			return "Presentation";
			break;
		case "chbExType11" :
		case "chbExType14" :
			return "TargetSpotting";
			break;
		case "chbExType12" :	// v0.16.0, DL: new exercise type
		case "chbExType16" :
			return _global.g_strErrorCorrection;	// v6.5.1 Yiu add bew exercise type Error Correction
			break;
		case "chbExType17" :
		case "chbExType18" :
		case "chbExType19" :
			return "ReadingComprehension";
			break;
	}
	return "Unknow";
}
chbs.rollOver = function(evtObj:Object) : Void {
	// v6.5.0.1 Yiu 4-6-08 disabled this check box text mouse showing tips, mouse over base MC instead
	
	var chb = evtObj.target;
	var t = "";
	
	var nTargetX:Number	= 0;
	var nTargetY:Number	= 0;
	
	t	= this.getCheckBoxIdStr(chb._name);
	
	if (t!="") {
		NNW.control.showTip(t, nTargetX, nTargetY);
	}
}

// v0.9.0, DL: hide tooltip for dragging/rolling out a checkbox
chbs.dragOut = function(evtObj:Object) : Void {
	this.rollOut(evtObj);
}
chbs.rollOut = function(evtObj:Object) : Void {
	var chb = evtObj.target;
	var t = "";
	
	t	= this.getCheckBoxIdStr(chb._name);
	
	if (t!="") {
		NNW.control.hideTip(t);
	}
}
