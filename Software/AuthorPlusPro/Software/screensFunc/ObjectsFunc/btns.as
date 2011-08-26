
// buttons (including labels)
btns.totalNoOfButtons = 0;	// v0.16.0, DL: hold the no. of buttons in NNW
btns.noOfLabelsCreated = 0;	// v0.16.0, DL: hold the no. of button labels created

btns.browseFileType = "";	// v0.16.1, DL: hold the file type in the file list

btns.getLiteral = function(idName:String) : String {
	return NNW.view.literals.getLiteral(idName);
}

btns.setLabelsLiterals = function() : Void {
	var exType = NNW.control.data.currentExercise.exerciseType;
	// scnAuthCode
	this.lblPromptCode.text = this.getLiteral("lblPromptCode");
	this.lblTypeCode.text = this.getLiteral("lblTypeCode");
	// v0.11.0, DL: scnFirstTime
	NNW.screens.chbs.chbNoFirstTime.label = this.getLiteral("lblDontShow");
	// scnSettings
	this.lblSettings.text = this.getLiteral("btnSettings");
	this.lblInstantMarking.text = this.getLiteral("lblMarking");
	NNW.screens.chbs.chbMarkingInstant.label = this.getLiteral("lblInstantMarking");
	// v6.4.2.5 sound effects
	_global.myTrace("sound effects literal=" + this.getLiteral("lblSoundEffects"));
	NNW.screens.chbs.chbSoundEffects.label = this.getLiteral("lblSoundEffects");
	NNW.screens.chbs.chbMarkingDelayed.label = this.getLiteral("lblDelayedMarking");
	NNW.screens.chbs.chbMarkingChoose.label = this.getLiteral("lblStudentChooses");
	this.lblButtons.text = this.getLiteral("lblButtons");
	NNW.screens.chbs.chbBtnFeedback.label = this.getLiteral("lblFeedback");
	NNW.screens.chbs.chbBtnMarking.label = this.getLiteral("lblMarking");
	// v6.4.2.8 for tb rule
	NNW.screens.chbs.chbBtnRule.label = this.getLiteral("lblRule");
	//this.lblInstructionsAudio.text = this.getLiteral("lblInstructionsAudio");
	this.lblAudio.text = this.getLiteral("lblAudio");
	// v6.4.2.7 Add URLs
	this.lblURL.text = this.getLiteral("btnURL");
	_global.myTrace("lblURL=" + this.lblURL.text);
	NNW.screens.chbs.chbInstructionsAudioDefault.label = this.getLiteral("lblInstructionsAudioDefault");
	//NNW.screens.chbs.chbInstructionsAudioUpload.label = this.getLiteral("lblInstructionsAudioUpload");
	//NNW.screens.chbs.chbEmbedAudio.label = this.getLiteral("lblEmbedAudio");
	//NNW.screens.chbs.chbAfterMarkingAudio.label = this.getLiteral("lblAfterMarkingAudio");
	//NNW.screens.chbs.chbQuestionAudio.label = this.getLiteral("lblQuestionAudio")+"...";
	NNW.screens.chbs.chbQuestionAudioAfterMarking.label = this.getLiteral("lblQuestionAudioAfterMarking");
	//NNW.screens.chbs.chbSplitScreenQuestionAudio.label = this.getLiteral("lblQuestionAudio")+"...";
	NNW.screens.chbs.chbSplitScreenQuestionAudioAfterMarking.label = this.getLiteral("lblQuestionAudioAfterMarking");
	this.lblVideo.text = this.getLiteral("lblVideo");
	NNW.screens.chbs.chbEmbedVideo.label = this.getLiteral("lblEmbedVideo")+"...";
	//NNW.screens.chbs.chbFloatingVideo.label = this.getLiteral("lblFloatingVideo")+"...";
	NNW.screens.chbs.chbCapitalisation.label = this.getLiteral("lblMakeCapitalisationSignificant");
	NNW.screens.chbs.chbSameLengthGaps.label = this.getLiteral("lblSameLengthGaps");
	// v6.5.1 Yiu new default gap length check box and slider 
	NNW.screens.chbs.chbDefaultLengthGaps.label = this.getLiteral("lblDefaultLengthGaps");
	NNW.screens.chbs.chbShowTextFirst.label = this.getLiteral("lblShowTextFirst");	// v0.12.0, DL: show text before countdown
	NNW.screens.chbs.chbHideTargets.label = this.getLiteral("lblHideTargets");	// v0.16.0, DL: hide targets for proofreading
	NNW.screens.chbs.chbOverwriteAnswers.label = this.getLiteral("lblOverwriteAnswers");	// v0.16.0, DL: overwrite answers for drags/gaps
	NNW.screens.chbs.chbNeutralFeedback.label = this.getLiteral("lblNeutralFeedback");	// v0.16.0, DL: neutral feedback for target spotting
	NNW.screens.chbs.chbFeedbackScoreBased.label = this.getLiteral("lblScoreBasedFeedback");	// v0.16.0, DL:  score-based feedback
	NNW.screens.chbs.chbFeedbackDifferent.label = this.getLiteral("lblDifferentFeedback");	// v0.16.0, DL:  different feedback
	NNW.screens.chbs.chbSplitScreen.label = this.getLiteral("lblSplitScreen");	// v0.16.1, DL: split screen exercise
	NNW.screens.chbs.chbDragTimes.label = this.getLiteral("lblDragTimes");	// v0.16.1, DL: multiple drag times
	NNW.screens.chbs.chbTestMode.label = this.getLiteral("lblTest");	// v6.4.1.2, DL: test mode in exercise
	// scnExercise
	this.lblMenu.text = this.getLiteral("btnMenu");
	this.lblStep1.text = this.getLiteral("lblStep1");
	this.lblStep2.text = this.getLiteral("lblStep2");
	this.lblStep3.text = this.getLiteral("lblStep3");
	this.lblFinished.text = this.getLiteral("btnFinished");
	// -- exercise
	
	// v6.5.1 Yiu changed for new exericse choosing panel and others
	//this.lblChosenExType.text = this.getLiteral("lbl"+exType);	// v0.16.0, DL: no need to use switch
	
	// v6.5.0.2 Yiu
	this.lblSettingSession1.text				= this.getLiteral("lblSettingScreenSession1");
	this.lblSettingSession2.text				= this.getLiteral("lblSettingScreenSession2");
	this.lblSettingSession3.text				= this.getLiteral("lblSettingScreenSession3");
	this.lblSettingSession4Part1.text			= this.getLiteral("lblSettingScreenSession4Part1");
	this.lblSettingSession4Part2.text			= this.getLiteral("lblSettingScreenSession4Part2");

	this.lblExercise.text = this.getLiteral("lblExercise");
	this.lblTitle.text = this.getLiteral("lblTitle");
	this.lblImage.text = this.getLiteral("lblImage");
	this.lblPosition.text = this.getLiteral("lblPosition");
	this.lblSelectCategory.text = this.getLiteral("lblSelectCategory");
	this.lblFeedback.text = this.getLiteral("lblFeedback");
	this.lblFeedback1.text = this.getLiteral("lblFeedback");
	this.lblHint.text = this.getLiteral("lblHint");	// v0.16.0, DL: hint only
	this.lblTimeLimit.text = this.getLiteral("lblTimeLimit");
	this.lblMins.text = this.getLiteral("lblMins");
	// -- more panels
	this.lblMoreImage.text = this.getLiteral("lblMore");
	this.lblMoreAudio.text = this.getLiteral("lblMore");
	// v6.4.2.7 Add URLs
	this.lblMoreURL.text = this.getLiteral("lblMore");
	this.lblMoreVideo.text = this.getLiteral("lblMore");
	this.lblPositionImage.text = this.getLiteral("lblPosition");
	NNW.screens.chbs.chbImagePos0.label = this.getLiteral("lblTopRight");	// v0.16.0, DL: image position
	NNW.screens.chbs.chbImagePos1.label = this.getLiteral("lblTopLeft");	// v0.16.0, DL: image position
	// Yiu v6.5.1 Remove Banner
	//NNW.screens.chbs.chbImagePos2.label = this.getLiteral("lblBanner");	// v0.16.0, DL: image position
	// End Yiu v6.5.1 Remove Banner
	this.lblFilenameImage.text = this.getLiteral("lblFilename");
	this.lblPositionVideo.text = this.getLiteral("lblPosition");
	NNW.screens.chbs.chbVideoPos0.label = this.getLiteral("lblTopRight");	// v0.16.1, DL: video position
	NNW.screens.chbs.chbVideoPos1.label = this.getLiteral("lblTopLeft");	// v0.16.1, DL: video position
	// Yiu v6.5.1 Remove Banner
	//NNW.screens.chbs.chbVideoPos2.label = this.getLiteral("lblBanner");	// v0.16.1, DL: video position
	// End Yiu v6.5.1 Remove Banner
	NNW.screens.chbs.chbVideoPos3.label = this.getLiteral("lblFloatingVideo");	// v0.16.1, DL: video position
	this.lblFilenameVideo.text = this.getLiteral("lblFilename");
	this.lblInstructionsAudioUpload.text = this.getLiteral("lblInstructionsAudioUpload");
	this.lblEmbedAudio.text = this.getLiteral("lblEmbedAudio");
	this.lblAfterMarkingAudio.text = this.getLiteral("lblAfterMarkingAudio");
	// v6.4.2.7 Add URLs
	this.lblURL1.text = this.getLiteral("lblURL");
	this.lblURL2.text = this.getLiteral("lblURL");
	this.lblURL3.text = this.getLiteral("lblURL");
	this.lblURLCaption1.text = this.getLiteral("lblURLCaption");
	this.lblURLCaption2.text = this.getLiteral("lblURLCaption");
	this.lblURLCaption3.text = this.getLiteral("lblURLCaption");
	this.lblURLToolbar.text = this.getLiteral("lblURLToolbar");
	NNW.screens.chbs.chbURLToolbar1.label = "";
	NNW.screens.chbs.chbURLToolbar2.label = "";
	NNW.screens.chbs.chbURLToolbar3.label = "";
	
	// -- question
	this.lblQuestion.text = this.getLiteral("lblQuestion");
	this.lblOptions.text = this.getLiteral("lblOptions");
	this.lblOtherOptions.text = this.getLiteral("lblOtherOptions");
	this.lblOtherAnswers.text = this.getLiteral("lblOtherAnswers");
	this.lblTypeText.text = this.getLiteral("lblTypeText") + ":";
	this.lblTextTypeURL.text = this.getLiteral("lblTypeURL");
	this.lblQuestionTypeURL.text = this.getLiteral("lblTypeURL");
	this.lblTFOptions.text = this.getLiteral("lblOptions");
	this.lblAnswerIs.text = this.getLiteral("lblAnswerIs");
	this.lblMCTrue.text		= this.getLiteral("lblTRUE");
	this.lblMCFalse.text	= this.getLiteral("lblFALSE");
	NNW.screens.chbs.chbTrueOption.label	= this.getLiteral("lblTRUE");
	NNW.screens.chbs.chbFalseOption.label 	= this.getLiteral("lblFALSE");
	
	this.lblOptionsA.text	= this.getLiteral("lblOptionsA");
	this.lblOptionsB.text	= this.getLiteral("lblOptionsB");
	this.lblOptionsC.text	= this.getLiteral("lblOptionsC");
	this.lblOptionsD.text	= this.getLiteral("lblOptionsD");
	
	this.lblRMCOptionsA.text	= this.getLiteral("lblOptionsA");
	this.lblRMCOptionsB.text	= this.getLiteral("lblOptionsB");
	this.lblRMCOptionsC.text	= this.getLiteral("lblOptionsC");
	this.lblRMCOptionsD.text	= this.getLiteral("lblOptionsD");
	
	// v0.16.0, DL: no longer have panels, just chbQuizOptions0, chbQuizOptions1, chbQuizDummyOption
	/*NNW.screens.chbs.chbTrue0.label = this.getLiteral("lblTrue");
	NNW.screens.chbs.chbTrue1.label = "";
	NNW.screens.chbs.chbTrue2.label = "";
	NNW.screens.chbs.chbFalse0.label = this.getLiteral("lblFalse");
	this.lblFalse.text = this.getLiteral("lblFalse");
	NNW.screens.chbs.chbFalse1.label = "";
	NNW.screens.chbs.chbFalse2.label = "";*/
	NNW.screens.chbs.chbQuizOptions0.label = this.getLiteral("lblTrue");
	NNW.screens.chbs.chbQuizDummyOption.label = this.getLiteral("lblFalse");
	NNW.screens.chbs.chbQuizOptions1.label = " ";
	
	switch (exType) {
	case "Stopgap" :
	case "Cloze" :
		fieldType = "Gap";
		break;
	case "DragOn" :
	case "DragAndDrop" :
		fieldType = "Drop";
		break;
	// v6.4.3 Item based drop down
	case "Stopdrop" :
	case "Dropdown" :
		fieldType = "Dropdown";
		break;
	case "Countdown" :
		fieldType = "Countdown";
		break;
		
	case _global.g_strQuestionSpotterID: // v6.5.1 Yiu? add bew exercise type question spotter
	case "TargetSpotting" :	// v0.16.0, DL: new exercise type
	case "Proofreading" :	// v0.16.0, DL: new exercise type
		fieldType = "Target";
		break; 
	case _global.g_strBulletID:
		this.lblQuestion.text 				= this.getLiteral("lblQuestion");
		this.lblSplitScreenQuestion.text 	= this.getLiteral("lblQuestion");
		fieldType ="";
		break;
	case _global.g_strErrorCorrection:
		fieldType ="ErrorCorrection";
		break;
	default :
		fieldType ="";
		break;
	}
	this.lblMakeField.text = this.getLiteral("lblMakeField" + fieldType) + ":";
	this.lblShowDefault.text = "(" + this.getLiteral("lblShowDefault") + ")";
	
	this.lblSplitScreenText.text = this.getLiteral("lblTypeText") + ":";
	this.lblSplitScreenQuestion.text = this.getLiteral("lblQuestion");
	this.lblRMCOptions.text = this.getLiteral("lblOptions");
	// accordion labels
	/* v0.14.0, DL: debug - the scrolling problem is found to come from the accordion - although i don't know why */
	/* in order to play safe i'd better get rid of all the accordions and write them on my own */
	NNW.screens.acds.acdFH.setLabels(this.getLiteral("lblFeedback"), this.getLiteral("lblHint"));
	NNW.screens.acds.acdFFH.setLabels(_global.replace(this.getLiteral("lblFeedbackFor"), "[x]", NNW.screens.chbs.chbTrueOption.label), _global.replace(this.getLiteral("lblFeedbackFor"), "[x]", NNW.screens.chbs.chbFalseOption.label), this.getLiteral("lblHint"));
	//NNW.screens.acds.acdRMCFH.setLabels(this.getLiteral("lblFeedback"), this.getLiteral("lblHint"));
	//NNW.screens.acds.setLabels("acdExercise", this.getLiteral("lblExercise"), this.getLiteral("lblQuestion"));
	//var labelArray = new Array(this.getLiteral("lblFeedback"), this.getLiteral("lblHint"));
	//NNW.screens.acds.setLabels("acdFeedbackHint", labelArray);
	// v6.4.3 Item based dropdown
	//if (exType=="Dropdown") {
	if (exType=="Dropdown" || exType=="Stopdrop") {
		/* v0.14.0, DL: options are now taken out from the accordion */
		this.lblOptionListTitle.text = this.getLiteral("lblOptionsDropdown");
		// v6.4.1, DL: add correct label to option list for dropdown
		this.lblOptionListCorrect.text = this.getLiteral("lblCorrect");
		//labelArray = new Array(this.getLiteral("lblOtherOptions"), this.getLiteral("lblFeedback"), this.getLiteral("lblHint"));
		//labelArray = new Array(this.getLiteral("lblOptionsDropdown"), this.getLiteral("lblFeedback"), this.getLiteral("lblHint"));
		//NNW.screens.acds.setLabels("acd3Segments", labelArray);
	} else if (exType=="DragAndDrop"||exType=="DragOn") {
		/* v0.16.1, DL: some more drags can be added by users */
		// v6.4.2.5, AR: add correct label to option list for drags as well
		//this.lblOptionListTitle.text = this.getLiteral("lblOptionsGap");
		this.lblOptionListTitle.text = this.getLiteral("lblOptionsDropdown");
		this.lblOptionListCorrect.text = this.getLiteral("lblCorrect");
	} else if(exType==_global.g_strErrorCorrection){		// v6.5.1 Yiu 6-5-2008 New exercise type error correction
		this.lblOptionListTitle.text = this.getLiteral("lblOptionsErrorCorrection");
	} else {
		/* v0.14.0, DL: options are now taken out from the accordion */
		this.lblOptionListTitle.text = this.getLiteral("lblOptionsGap");
		//labelArray = new Array(this.getLiteral("lblOtherAnswers"), this.getLiteral("lblFeedback"), this.getLiteral("lblHint"));
		//labelArray = new Array(this.getLiteral("lblOptionsGap"), this.getLiteral("lblFeedback"), this.getLiteral("lblHint"));
		//NNW.screens.acds.setLabels("acd3Segments", labelArray);		
	}
	// v0.16.0, DL: correct target for 
	NNW.screens.chbs.chbCorrectTarget.label = this.getLiteral("lblCorrect");
	// -- more panels in question
	this.lblQuestionMM.text = this.getLiteral("lblAudio");
	this.lblQuestionAudio.text = this.getLiteral("lblFilename");
	// scnLogin
	this.lblLogin.text = this.getLiteral("lblLogin");
	// v6.4.2.5 Licenced to
	this.lblLicencedTo.text = this.getLiteral("lblLicencedTo");
	this.lblUsername.text = this.getLiteral("lblUsername") + ":";
	this.lblPassword.text = this.getLiteral("lblPassword") + ":";
	// scnEmail
	NNW.screens.wins.setTitle("winEmail", this.getLiteral("btnEmail"));
	this.lblTo.text = this.getLiteral("lblTo") + ":";
	this.lblSubject.text = this.getLiteral("lblSubject") + ":";
	// scnCourse
	this.lblSelectCourse.text = this.getLiteral("lblSelectCourse");
	this.lblSelectProgram.text = this.getLiteral("lblSelectProgram");
	// scnUnit
	this.lblCourseName.text = this.getLiteral("lblCourseName");
	this.lblSelectUnit.text = this.getLiteral("lblSelectUnit");
	this.lblSelectExercise.text = this.getLiteral("lblSelectExercise");
	NNW.screens.chbs.chbCourseEnable.label = this.getLiteral("lblCourseEnable");
	// scnExType
	NNW.screens.wins.setTitle("winExType", this.getLiteral("lblSelectExType"));
	this.lblSelectExType.text = "";//this.getLiteral("lblSelectExType");
	// scnExport
	this.lblExportTitle.text = this.getLiteral("lblShareScreenExport");	
	// scnImport
	this.lblImportTitle.text = this.getLiteral("lblShareScreenImport");
	
	// v6.5.1 Yiu changed for new exericse choosing panel and others
	this.lblExTypeTitle1.text	= this.getLiteral("lblExerciseTypeTitle1");
	this.lblExTypeTitle2.text	= this.getLiteral("lblExerciseTypeTitle2");
	this.lblExTypeTitle3.text	= this.getLiteral("lblExerciseTypeTitle3");
	this.lblExTypeTitle4.text	= this.getLiteral("lblExerciseTypeTitle4");
	this.lblExTypeTitle5.text	= this.getLiteral("lblExerciseTypeTitle5");
	this.lblExTypeTitle6.text	= this.getLiteral("lblExerciseTypeTitle6");
	this.lblExTypeTitle7.text	= this.getLiteral("lblExerciseTypeTitle7");
	this.lblExTypeTitle8.text	= this.getLiteral("lblExerciseTypeTitle8");
	this.lblExTypeTitle9.text	= this.getLiteral("lblExerciseTypeTitle9");
		
	var exType = NNW.control.data.currentExercise.exerciseType;
	var textForReadExerciseChoosedNameXML:String	= "";
	
	// erase all the space
	var tempArray:Array	= exType.split(" ");
	for(var i:Number= 0; i<tempArray.length; ++i){
		textForReadExerciseChoosedNameXML	+= tempArray[i];
	}
	
	this.lblChosenExType.text = this.getLiteral("lbl" + tempArray + "ChoosedExerciseWords");	// v0.16.0, DL: no need to use switch
	
	// set check box name 
	NNW.screens.chbs.chbExType01.label =	this.getCheckBoxName("chbExType01");
	NNW.screens.chbs.chbExType02.label =	this.getCheckBoxName("chbExType02");
	NNW.screens.chbs.chbExType03.label =	this.getCheckBoxName("chbExType03");
	NNW.screens.chbs.chbExType04.label =	this.getCheckBoxName("chbExType04");
	NNW.screens.chbs.chbExType05.label =	this.getCheckBoxName("chbExType05");
	NNW.screens.chbs.chbExType06.label =	this.getCheckBoxName("chbExType06");
	NNW.screens.chbs.chbExType07.label =	this.getCheckBoxName("chbExType07");
	NNW.screens.chbs.chbExType08.label =	this.getCheckBoxName("chbExType08");
	NNW.screens.chbs.chbExType09.label =	this.getCheckBoxName("chbExType09");
	NNW.screens.chbs.chbExType10.label =	this.getCheckBoxName("chbExType10");
	NNW.screens.chbs.chbExType11.label =	this.getCheckBoxName("chbExType11");
	NNW.screens.chbs.chbExType12.label =	this.getCheckBoxName("chbExType12");
	NNW.screens.chbs.chbExType13.label =	this.getCheckBoxName("chbExType13");
	NNW.screens.chbs.chbExType14.label =	this.getCheckBoxName("chbExType14");
	NNW.screens.chbs.chbExType15.label =	this.getCheckBoxName("chbExType15");
	NNW.screens.chbs.chbExType16.label =	this.getCheckBoxName("chbExType16");
	NNW.screens.chbs.chbExType17.label =	this.getCheckBoxName("chbExType17");
	NNW.screens.chbs.chbExType18.label =	this.getCheckBoxName("chbExType18");
	NNW.screens.chbs.chbExType19.label =	this.getCheckBoxName("chbExType19");
	// End v6.5.1 Yiu changed for new exericse choosing panel and others
	
	/*this.lblMultipleChoice.text = this.getLiteral("lblMultipleChoice");
	this.lblTrueFalse.text = this.getLiteral("lblTrueFalse");
	this.lblDropdown.text = this.getLiteral("lblDropdown");
	this.lblGapfill.text = this.getLiteral("lblGapfill");
	this.lblDragDrop.text = this.getLiteral("lblDragDrop");
	this.lblStoryboard.text = this.getLiteral("lblStoryboard");
	this.lblReadingComp.text = this.getLiteral("lblReadingComp");
	this.lblTextOnly.text = this.getLiteral("lblTextOnly");*/
	
	// v0.16.0, DL: score-based feedback
	// scnFeedback
	NNW.screens.wins.setTitle("winFeedback", this.getLiteral("lblScoreBasedFeedback"));
	this.lblAbove.text = this.getLiteral("lblAbove");
	
	// scnBrowse
	NNW.screens.wins.setTitle("winBrowse", this.getLiteral("lblBrowseFilesOnServer"));
	this.lblLoadingBrowse.text = this.getLiteral("lblLoading");
}

btns.getCheckBoxName= function(checkBoxName:String):String{
	// extra the final two words
	var strResult:String= this.getLiteral("lblExerciseTypeSubTitle" + checkBoxName.substr(checkBoxName.length - 2, 2));
	return strResult;
}

btns.setButtonsLiterals = function() : Void {
	// scnAuthCode
	this.btnSubmitCode.tooltip = "" //this.getLiteral("btnOK");
	this.setButtonLabel("labelSubmitCode", this.getLiteral("btnOK"));
	// scnLogin
	this.btnLoginOK.tooltip = "" //this.getLiteral("btnOK");
	this.setButtonLabel("labelLoginOK", this.getLiteral("btnOK"));
	this.btnLoginClear.tooltip = "" //this.getLiteral("btnClear");
	this.setButtonLabel("labelLoginClear", this.getLiteral("btnClear"));
	// scnButtons
	this.btnReset.tooltip = "";
	this.setButtonLabel("labelReset", this.getLiteral("btnReset"));
	this.btnGuide.tooltip = "";
	this.btnGuideInCouseScreen.tooltip = "";
	this.setButtonLabel("labelGuide", this.getLiteral("btnGuide"));
	this.setButtonLabel("labelGuideInCouseScreen", this.getLiteral("btnGuide"));
	this.btnEmail.tooltip = "";
	this.btnEmailInCouseScreen.tooltip = "";	// v6.5.4.2 Yiu, show the comment button on the course screen, Bug ID 1320
	this.setButtonLabel("labelEmail", this.getLiteral("btnEmail"));
	this.setButtonLabel("labelEmailInCouseScreen", this.getLiteral("btnEmail"));	// v6.5.4.2 Yiu, show the comment button on the course screen, Bug ID 1320
	this.btnUpgrade.tooltip = "" //this.getLiteral("btnUpgrade");
	this.setButtonLabel("labelUpgrade", this.getLiteral("btnUpgrade"));
	this.btnUpload.tooltip = "" //this.getLiteral("btnUpload");
	this.btnHelp.tooltip = this.getLiteral("btnHelp");
	this.btnPreview.tooltip = "" //this.getLiteral("btnPreview");
	this.setButtonLabel("labelPreview", this.getLiteral("btnPreview"));
	this.btnPreviewMenu.tooltip = "" //this.getLiteral("btnPreview");
	this.setButtonLabel("labelPreviewMenu", this.getLiteral("btnPreview"));
	this.btnPreviewCourses.tooltip = "" //this.getLiteral("btnPreview");
	this.setButtonLabel("labelPreviewCourses", this.getLiteral("btnPreview"));
	this.btnSaveCourse.tooltip = "" //this.getLiteral("btnSave");
	this.setButtonLabel("labelSaveCourse", this.getLiteral("btnSave"));
	this.btnSettings.tooltip = "" //this.getLiteral("btnSettings");
	this.setButtonLabel("labelSettings", this.getLiteral("btnSettings"));
	// v0.15.0, DL: getting started button
	this.btnGettingStarted.tooltip = "";
	this.setButtonLabel("labelGettingStarted", this.getLiteral("btnGettingStarted"));
	// v0.16.1, DL: share button
	this.btnShare.tooltip = "";
	this.setButtonLabel("labelShare", this.getLiteral("btnShare"));
	// scnCourse
	this.btnAddCourse.tooltip = "" //this.getLiteral("btnAdd");
	this.setButtonLabel("labelAddCourse", this.getLiteral("btnNew"));
	this.btnEditCourse.tooltip = "" //this.getLiteral("btnEdit");
	this.setButtonLabel("labelEditCourse", this.getLiteral("btnEdit"));
	this.btnDelCourse.tooltip = "" //this.getLiteral("btnDelete");
	this.setButtonLabel("labelDelCourse", this.getLiteral("btnDelete"));
	// v6.4.3 New button
	this.btnRenameCourse.tooltip = "" //this.getLiteral("btnRename");
	this.setButtonLabel("labelRenameCourse", this.getLiteral("btnRename"));
	this.btnWhatDoCourse.tooltip = "";	// v0.16.0, DL
	this.setButtonLabel("labelWhatDoCourse", this.getLiteral("btnWhatDo"));	// v0.16.0, DL
	// scnExType
	this.btnExTypeOK.tooltip = "" //this.getLiteral("btnOK");
	this.setButtonLabel("labelExTypeOK", this.getLiteral("btnOK"));
	this.btnExTypeCancel.tooltip = "" //this.getLiteral("btnCancel");
	this.setButtonLabel("labelExTypeCancel", this.getLiteral("btnCancel"));
	// scnExercise
	this.btnExerciseSave.tooltip = "" //this.getLiteral("btnSave"); //this.getLiteral("btnFinished");
	this.setButtonLabel("labelExerciseSave", this.getLiteral("btnSave"));
	//this.btnExerciseBack.tooltip = "" //this.getLiteral("btnMenu");
	//this.setButtonLabel("labelExerciseBack", this.getLiteral("btnMenu"));
	//this.btnExerciseExit.tooltip = this.getLiteral("btnExit");
	this.btnBold.tooltip = this.getLiteral("btnBold");
	this.btnItalic.tooltip = this.getLiteral("btnItalic");
	this.btnUnderline.tooltip = this.getLiteral("btnUnderline");
	this.btnLeft.tooltip = this.getLiteral("btnAlignLeft");
	this.btnCenter.tooltip = this.getLiteral("btnAlignCenter");
	this.btnRight.tooltip = this.getLiteral("btnAlignRight");
	this.btnBullet.tooltip = this.getLiteral("btnBullet");
	this.btnDeBlockIndent.tooltip = this.getLiteral("btnDeBlockIndent");
	this.btnInBlockIndent.tooltip = this.getLiteral("btnInBlockIndent");
	this.btnLink.tooltip = this.getLiteral("btnURL");
	this.btnBlack.tooltip=this.getLiteral("btnBlack");
	this.btnDarkBlue.tooltip=this.getLiteral("btnDarkBlue");
	this.btnBlue.tooltip=this.getLiteral("btnBlue");
	/* v0.14.0, DL: add options list */
	this.btnNewOption.tooltip = "" //this.getLiteral("btnNew");
	this.setButtonLabel("labelNewOption", this.getLiteral("btnNew"));
	this.btnRenOption.tooltip = "" //this.getLiteral("btnEdit");
	this.setButtonLabel("labelRenOption", this.getLiteral("btnEdit"));
	this.btnDelOption.tooltip = "" //this.getLiteral("btnDelete");
	this.setButtonLabel("labelDelOption", this.getLiteral("btnDelete"));
	switch (NNW.control.data.currentExercise.exerciseType) {
	case "Stopgap" :
	case "Cloze" :
		fieldType = "Gap";
		break;
	case "DragOn" :
	case "DragAndDrop" :
		fieldType = "Drop";
		break;
	case "Dropdown" :
	// v6.4.3 Item based drop down
	case "Stopdrop" :
		fieldType = "Dropdown";
		break;
	case "Countdown" :
		fieldType = "Countdown";
		break;
	case "TargetSpotting" :	// v0.16.0, DL: new exercise type
	case "Proofreading" :	// v0.16.0, DL: new exercise type
	case _global.g_strQuestionSpotterID: // v6.5.1 Yiu add bew exercise type question spotter
		fieldType = "Target";
		break;
	case _global.g_strErrorCorrection: // v6.5.1 Yiu add bew exercise type Error correction
		fieldType = "ErrorCorrection";
		break;
	default :
		fieldType ="";
		break;
	}
	this.btnMakeField.label = this.getLiteral("btnAddField"+fieldType);
	//this.btnMakeField.tooltip = this.getLiteral("btnAddField"+fieldType);
	this.btnClearField.label = this.getLiteral("btnClearField"+fieldType);
	//this.btnClearField.tooltip = this.getLiteral("btnClearField"+fieldType);
	this.btnPrevQ.tooltip = ""; //this.getLiteral("btnPrevious");
	this.btnNextQ.tooltip = ""; //this.getLiteral("btnNext");
	this.btnPrevSplitScreen.tooltip = ""; //this.getLiteral("btnPrevious");
	this.btnNextSplitScreen.tooltip = ""; //this.getLiteral("btnNext");
	this.btnWhatDoExercise.tooltip = "";	// v0.9.0, DL
	this.setButtonLabel("labelWhatDoExercise", this.getLiteral("btnWhatDo"));	// v0.9.0, DL
	// Add by Wei
	//this.btnDeleteQue.label = this.getLiteral("btnDeleteQue");
	this.btnCutQue.tooltip = this.getLiteral("btnCutQue");
	//this.btnCopyQue.label = this.getLiteral("btnCopyQue");
	this.btnCopyQue.tooltip = this.getLiteral("btnCopyQue");
	//this.btnPasteQue.label = this.getLiteral("btnPasteQue");
	this.btnPasteQue.tooltip = this.getLiteral("btnPasteQue");
	//this.btnDeleteQueS.label = this.getLiteral("btnDeleteQue");
	this.btnCutQueS.tooltip = this.getLiteral("btnCutQue");
	//this.btnCopyQueS.label = this.getLiteral("btnCopyQue");
	this.btnCopyQueS.tooltip = this.getLiteral("btnCopyQue");
	//this.btnPasteQueS.label = this.getLiteral("btnPasteQue");
	this.btnPasteQueS.tooltip = this.getLiteral("btnPasteQue");
	// v0.16.0, DL: add score-based feedback
	this.btnScoreBasedFeedback.label = this.getLiteral("lblFeedback");
	// -- more panels
	this.btnBrowseInstructionsAudio.tooltip = this.getLiteral("btnBrowse");
	this.btnBrowseEmbedAudio.tooltip = this.getLiteral("btnBrowse");
	this.btnBrowseAfterMarkingAudio.tooltip = this.getLiteral("btnBrowse");
	this.btnBrowseImage.tooltip = this.getLiteral("btnBrowse");
	this.btnBrowseVideo.tooltip = this.getLiteral("btnBrowse");
	this.btnClearInstructionsAudio.tooltip = this.getLiteral("btnClear");
	this.btnClearEmbedAudio.tooltip = this.getLiteral("btnClear");
	this.btnClearAfterMarkingAudio.tooltip = this.getLiteral("btnClear");
	// v6.4.2.7 Add URLs
	this.btnClearURL1.tooltip = this.getLiteral("btnClear");
	this.btnClearURL2.tooltip = this.getLiteral("btnClear");
	this.btnClearURL3.tooltip = this.getLiteral("btnClear");
	this.btnClearImage.tooltip = this.getLiteral("btnClear");
	this.btnClearVideo.tooltip = this.getLiteral("btnClear");
	// -- panel for question multimedia
	this.btnBrowseQuestionAudio.tooltip = this.getLiteral("btnBrowse");
	this.btnClearQuestionAudio.tooltip = this.getLiteral("btnClear");
	// scnUnit
	this.btnBackCourse.tooltip = "" //this.getLiteral("btnBack");
	this.setButtonLabel("labelBackCourse", this.getLiteral("btnBack"));
	this.btnNewUnit.tooltip = "" //this.getLiteral("btnNew");
	this.setButtonLabel("labelNewUnit", this.getLiteral("btnNew"));
	this.btnRenUnit.tooltip = "" //this.getLiteral("btnRename");
	this.setButtonLabel("labelRenUnit", this.getLiteral("btnRename"));
	this.btnDelUnit.tooltip = "" //this.getLiteral("btnDelete");
	this.setButtonLabel("labelDelUnit", this.getLiteral("btnDelete"));
	this.btnNewExercise.tooltip = "" //this.getLiteral("btnNew");
	this.setButtonLabel("labelNewExercise", this.getLiteral("btnNew"));
	this.btnEditExercise.tooltip = "" //this.getLiteral("btnEdit");
	this.setButtonLabel("labelEditExercise", this.getLiteral("btnEdit"));
	this.btnDelExercise.tooltip = "" //this.getLiteral("btnDelete");
	this.setButtonLabel("labelDelExercise", this.getLiteral("btnDelete"));
	this.btnUpUnit.tooltip = ""; // this.getLiteral("btnUp");
	this.btnDownUnit.tooltip = ""; // this.getLiteral("btnDown");
	this.btnUpExercise.tooltip = ""; // this.getLiteral("btnUp");
	this.btnDownExercise.tooltip = ""; // this.getLiteral("btnDown");
	this.labelDownExercise.setLabel1(this.getLiteral("btnDown"));
	this.btnWhatDoUnit.tooltip = "";	// v0.9.0, DL
	this.setButtonLabel("labelWhatDoUnit", this.getLiteral("btnWhatDo"));	// v0.9.0, DL
	this.btnSaveCourseName.tooltip = this.getLiteral("btnSave");	// v6.4.0.1, DL
	// scnPopup
	this.btnPopupOK.tooltip = "" //this.getLiteral("btnOK");
	this.setButtonLabel("labelPopupOK", this.getLiteral("btnOK"));
	this.btnPopupCancel.tooltip = "" //this.getLiteral("btnCancel");
	this.setButtonLabel("labelPopupCancel", this.getLiteral("btnCancel"));
	this.btnPopupYes.tooltip = "" //this.getLiteral("btnYes");
	this.setButtonLabel("labelPopupYes", this.getLiteral("btnYes"));
	this.btnPopupNo.tooltip = "" //this.getLiteral("btnNo");
	this.setButtonLabel("labelPopupNo", this.getLiteral("btnNo"));
	// exit button
	this.btnExit.tooltip = this.getLiteral("btnExit");
	// scnEmail
	this.btnEmailSend.tooltip = "";
	this.setButtonLabel("labelEmailSend", this.getLiteral("btnSend"));
	this.btnEmailCancel.tooltip = "";
	this.setButtonLabel("labelEmailCancel", this.getLiteral("btnCancel"));
	// v0.16.1, DL: scnExport
	this.btnExport.tooltip = "" //this.getLiteral("btnExport");
	this.setButtonLabel("labelExport", this.getLiteral("btnExport"));
	this.btnSCORMExport.tooltip = "" //this.getLiteral("btnSCORMExport");
	this.setButtonLabel("labelSCORMExport", this.getLiteral("btnSCORMExport"));
	this.btnUploadImport.tooltip = "" //this.getLiteral("btnUploadImport");
	this.setButtonLabel("labelUploadImport", this.getLiteral("btnImport"));
	this.btnImport.tooltip = "" //this.getLiteral("btnImport");
	//v6.4.2.1 ar This is now labelled select
	//this.setButtonLabel("labelImport", this.getLiteral("btnImport"));
	this.setButtonLabel("labelImport", this.getLiteral("btnSelect"));
	this.btnBackFromExport.tooltip = "" //this.getLiteral("btnBack");
	this.setButtonLabel("labelBackFromExport", this.getLiteral("btnBack"));
	this.btnBackFromImport.tooltip = "" //this.getLiteral("btnBack");
	this.setButtonLabel("labelBackFromImport", this.getLiteral("btnBack"));
	// v0.16.1, DL: scnBrowse
	this.btnBrowseOK.tooltip = "" //this.getLiteral("btnOK");
	this.setButtonLabel("labelBrowseOK", this.getLiteral("btnOK"));
	this.btnBrowseCancel.tooltip = "" //this.getLiteral("btnCancel");
	this.setButtonLabel("labelBrowseCancel", this.getLiteral("btnCancel"));
	this.btnBrowseUpload.tooltip = "" //this.getLiteral("btnUpload");
	//v6.4.2.1 ar This is now labelled browse
	//this.setButtonLabel("labelBrowseUpload", this.getLiteral("btnUpload"));
	this.setButtonLabel("labelBrowseUpload", this.getLiteral("btnBrowse"));
}

btns.setIcons = function() : Void {
	// scnAuthCode
	this.btnSubmitCode.icon = "MC - OK";
	// scnLogin
	this.btnLoginOK.icon = "MC - OK";
	this.btnLoginClear.icon = "MC - Clear";
	// scnEmail
	this.btnEmailSend.icon = "MC - OK";
	this.btnEmailCancel.icon = "MC - Cancel";
	// scnButtons
	this.btnGuide.icon = "MC - What to do";
	this.btnGuideInCouseScreen.icon	= "MC - What to do";
	this.btnEmail.icon = "MC - Email";
	this.btnEmailInCouseScreen.icon = "MC - Email";	// v6.5.4.2 Yiu, show the comment button on the course screen, Bug ID 1320
	this.btnUpgrade.icon = "MC - Upgrade";
	this.btnUpload.icon = "MC - Upload";
	this.btnHelp.icon = "GR - help";
	this.btnPreview.icon = "MC - Preview";
	this.btnPreviewMenu.icon = "MC - Preview";
	this.btnPreviewCourses.icon = "MC - Preview";
	this.btnSaveCourse.icon = "MC - Save";
	this.btnSettings.icon = "";
	// v0.15.0, DL: getting started button
	this.btnGettingStarted.icon = "";
	// v0.16.1, DL: share button
	this.btnShare.icon = "MC - Share";
	// scnCourse
	this.btnAddCourse.icon = "MC - New";
	this.btnEditCourse.icon = "MC - Edit";
	this.btnDelCourse.icon = "MC - Delete";
	// v6.4.3 New button
	this.btnRenameCourse.icon = "MC - Edit";
	this.btnWhatDoCourse.icon = "MC - What to do";
	this.btnReset.icon = "GR - Reset";
	// scnExType
	this.btnExTypeOK.icon = "MC - OK";
	this.btnExTypeCancel.icon = "MC - Cancel";
	// scnExercise
	this.btnExerciseSave.icon = "MC - Save";
	//this.btnExerciseBack.icon = "MC - Back";
	//this.btnExerciseExit.icon = "GR - Close";
	this.btnPrevQ.icon = "MC - PrevQ";
	this.btnNextQ.icon = "MC - NextQ";
	this.btnPrevSplitScreen.icon = "MC - PrevQ";
	this.btnNextSplitScreen.icon = "MC - NextQ";
	this.btnWhatDoExercise.icon = "MC - What to do";
	/* v0.14.0, DL: add list of other options */
	this.btnNewOption.icon = "MC - New";
	this.btnRenOption.icon = "MC - Edit";
	this.btnDelOption.icon = "MC - Delete";
	// -- more panels
	this.btnBrowseInstructionsAudio.icon = "GR - Browse";
	this.btnBrowseEmbedAudio.icon = "GR - Browse";
	this.btnBrowseAfterMarkingAudio.icon = "GR - Browse";
	this.btnBrowseImage.icon = "GR - Browse";
	this.btnBrowseVideo.icon = "GR - Browse";
	this.btnClearInstructionsAudio.icon = "GR - Clear";
	this.btnClearEmbedAudio.icon = "GR - Clear";
	this.btnClearAfterMarkingAudio.icon = "GR - Clear";
	this.btnClearImage.icon = "GR - Clear";
	this.btnClearVideo.icon = "GR - Clear";
	// v6.4.2.7 Add URLs
	this.btnClearURL1.icon = "GR - Clear";
	this.btnClearURL2.icon = "GR - Clear";
	this.btnClearURL3.icon = "GR - Clear";
	// -- panel for question multimedia
	this.btnBrowseQuestionAudio.icon = "GR - Browse";
	this.btnClearQuestionAudio.icon = "GR - Clear";
	// scnUnit
	this.btnBackCourse.icon = "MC - Back";
	this.btnNewUnit.icon = "MC - New";
	this.btnRenUnit.icon = "MC - Rename";
	this.btnDelUnit.icon = "MC - Delete";
	this.btnNewExercise.icon = "MC - New";
	this.btnEditExercise.icon = "MC - Edit";
	this.btnDelExercise.icon = "MC - Delete";
	this.btnUpUnit.icon = "MC - Up";
	this.btnDownUnit.icon = "MC - Down";
	this.btnUpExercise.icon = "MC - Up";
	this.btnDownExercise.icon = "MC - Down";
	this.btnWhatDoUnit.icon = "MC - What to do";
	this.btnSaveCourseName.icon = "GR - Save small";
	// scnPopup
	this.btnPopupOK.icon = "MC - OK";
	this.btnPopupCancel.icon = "MC - Cancel";
	this.btnPopupYes.icon = "MC - OK";
	this.btnPopupNo.icon = "MC - Delete";
	// exit button
	this.btnExit.icon = "GR - Close";
	// v0.16.1, DL: scnExport
	this.btnExport.icon = "MC - OK";
	this.btnSCORMExport.icon = "MC - OK";
	this.btnUploadImport.icon = "MC - OK";
	this.btnImport.icon = "MC - OK";
	this.btnBackFromExport.icon = "MC - Back";
	this.btnBackFromImport.icon = "MC - Back";
	// v0.16.1, DL: scnBrowse
	this.btnBrowseOK.icon = "MC - OK";
	this.btnBrowseCancel.icon = "MC - Cancel";
	this.btnBrowseUpload.icon = "MC - Upload";
	
	this.btnCutQue.icon = "MC - Cut";
	this.btnCutQueS.icon = "MC - Cut";
	this.btnCopyQue.icon = "MC - Copy";
	this.btnCopyQueS.icon = "MC - Copy";
	this.btnPasteQue.icon = "MC - Paste";
	this.btnPasteQueS.icon = "MC - Paste";
}

btns.createButtonLabels = function() : Void {	// v6.5.4.2 Yiu, show the comment button on the course screen, Bug ID 1320
	var twoLineButtons = new Array("btnSaveCourse", "btnExerciseSave", "btnBackCourse", "btnPreview", "btnPreviewMenu", "btnPreviewCourses", "btnUpgrade", "btnUpload", "btnEmail", "btnEmailInCouseScreen", "btnWhatDoExercise", "btnWhatDoUnit", "btnWhatDoCourse", "btnGettingStarted", "btnShare", "btnBackFromExport", "btnBackFromImport", "btnGuide", "btnGuideInCouseScreen", "btnReset");
	for (var i in this) {
		if (i.substr(0,3) == "btn") {
			
			this.totalNoOfButtons++;	// v0.16.0, DL: increment the count
			
			var btn = this[i];
			var mc = btn._parent;
			var lname = "label"+i.substr(3);
			var twoLine = false;
			for (var j in twoLineButtons) {
				if (twoLineButtons[j]==i) {
					twoLine = true;
				}
			}
			if (twoLine) {
				mc.attachMovie("twoLinesLabel", lname, mc.getNextHighestDepth());
				mc[lname]._x = btn._x + (btn._width / 2);
				mc[lname]._y = btn._y + 20;
			} else {
				mc.attachMovie("oneLineLabel", lname, mc.getNextHighestDepth());
				mc[lname]._x = btn._x;
				// v6.4.3 This is the label of text on buttons like rename, edit etc. Raise it a little
				//mc[lname]._y = btn._y-2;
				mc[lname]._y = btn._y-3;
			}
			this[lname] = mc[lname];
		}
	}
}

btns.onButtonLabelCreated = function(mc) : Void {
	this.setButtonsLiterals();
	
	this.noOfLabelsCreated++;	// v0.16.0, DL: increment the count
	
	// v0.16.0, DL: wait until all button labels have been created => initialise screen module
	if (this.noOfLabelsCreated==this.totalNoOfButtons) {
		NNW.screens.onAllButtonLabelsCreated();
	}
}

btns.setButtonLabel = function(lname:String, s:String) : Void {
	var a = s.split("||");
	var s1 = a[0];
	var s2 = a[1];
	this[lname].line1.text = (s1!=undefined && s1!="undefined") ? s1 : "";
	this[lname].line2.text = (s2!=undefined && s2!="undefined") ? s2: "";
}

btns.click = function(evtObj:Object) : Void {
	var btnName = evtObj.target._name;
	switch (btnName) {
		/*// scnAuthCode (1)
		case "btnSubmitCode" :
			NNW.control.checkAuthCode();
			break;*/
		// scnLogin (2)
		case "btnLoginOK" :
			NNW.control.login.checkLogin(NNW.screens.txts.txtUsername.text, NNW.screens.txts.txtPassword.text);
			break;
		case "btnLoginClear" :
			NNW.view.clearLoginScreen();
			break;
		// scnEmail (2)
		case "btnEmailSend" :
			NNW.control.sendEmail(NNW.screens.txts.txtEmailSubject.text, NNW.screens.txts.txtEmailText.text);
			break;
		case "btnEmailCancel" :
			NNW.view.hideEmailScreen();
			break;
		// scnButtons (6)
		case "btnEmailInCouseScreen" : 	/// v6.5.4.2 Yiu, show the comment button on the course screen, Bug ID 1320
		case "btnEmail" :
			// v6.5.0.1 Yiu disable email screen things
			NNW.control.sendEmail("", "");
			//NNW.view.showEmailScreen(); 
			break;
		/*case "btnUpload" :
			NNW.control.upload();
			break;*/
		case "btnReset" :
			NNW.control.reset();
			break;
		case "btnUpgrade" :
			NNW.control.upgrade();
			break;
		case "btnGuideInCouseScreen":
		case "btnGuide" :
			NNW.control.showGuide();
			break;
		case "btnHelp" :
			NNW.control.showHelp();
			break;
		case "btnPreview" :
			NNW.control.onPreviewExercise();
			break;
		case "btnPreviewMenu" :
			NNW.control.onPreviewMenu();
			break;
		case "btnPreviewCourses" :
			NNW.control.onPreviewCourses();
			break;
		// v6.4.3 This doesn't exist anymore
		case "btnSaveCourse" :
			NNW.control.saveCourse();
			break;
		case "btnSettings" :
			NNW.control.showSettings();
			break;
		// v0.15.0, DL: getting started button
		case "btnGettingStarted" :
			NNW.control.showHelp();
			break;
		// v0.16.1, DL: share button
		case "btnShare" :
			NNW.control.shareFiles();
			break;
		// scnCourse (4)
		case "btnAddCourse" :
			// v6.4.3 We now want to use the dnd tree to get this going
			//NNW.control.addCourse();
			var thisTree = NNW.screens.trees.treeCourse;
			// Is there a selected node?
			if (thisTree.selectedNode == undefined) {
				// so in that case, we ideally want to add at the end. I think that this means selecting the last
				// of the top level folders/courses and then doing paste after.
				// So the last node at the top level is?
				// Then make sure it is opened and selected.
				var theLastNode = thisTree.getRootNode().lastChild;
				//myTrace("last node=" + theLastNode.toString());
				thisTree.setIsOpen(theLastNode, true);
				thisTree.selectedNode = theLastNode;
				// and visible on screen
				thisTree.firstVisibleNode = thisTree.selectedNode;
				// Finally make sure you paste after no matter whether the last one is a course or a folder
				thisTree.addLeafPastePosition = thisTree.PASTE_AFTER;
			} else {
				// we have a selected node, but are we adding into or after?
				// This is done already in trees.change
				//if (thisTree.selectedNode.attributes.id == undefined) {
				//	var thisPasteStyle = thisTree.PASTE_INTO;
				//} else {
				//	var thisPasteStyle = thisTree.PASTE_AFTER;
				//}
			}
			// We also need to make sure that the scrolling is sorted. At the moment, if the vscroll has moved UP
			// you end up with the rename showing on the wrong node visually, although the data ends up correct.
			// Or, the node is added correctly but we don't trigger into the rename.
			// Using this does correctly move the selected node to the top, but the rename then works on where it was.
			// You also don't really want to move the node most of the time, it seems unnecessary.
			// This is all now handled in showRenameNode which just needs a relative index.
			//thisTree.firstVisibleNode = thisTree.selectedNode;
			//thisTree.refresh();
			//thisTree.selectedNode = thisTree.firstVisibleNode;
			
			// select the root node so that adding a new leaf will put it at the very end, at the top level (?)
			// and scroll to it
			//thisTree.selectedNode = thisTree.getTreeNodeAt(0);
			//thisTree.addLeafNode(thisTree.getTreeNodeAt(0), thisTree.PASTE_AFTER);
			thisTree.addLeafNode(thisTree.selectedNode, tree.addLeafPastePosition);
			
			// This just adds at the top and doesn't then trigger my event in trees.
			// Now I see that it triggers the pasteNode event.
			// How about adding before the first one?
			// Hmm, this seems to do horrible things in that it puts the typing field over the wrong node (although it always ends up ok)
			//thisTree.selectedNode = thisTree.getRootNode();
			//thisTree.refresh();
			//myTrace("pasting after " + thisTree.getRootNode());
			//thisTree.addLeafNode(thisTree.getRootNode(), thisTree.PASTE_AFTER);
			break;
		case "btnEditCourse" :
			// v6.4.3 This is now a tree
			//NNW.control.onDoubleClickingItemOnList(NNW.screens.dgs.dgCourse);
			NNW.control.onDoubleClickingOnTree(NNW.screens.trees.treeCourse.selectedNode);
			break;
		case "btnRenameCourse" :
			// v6.4.3 This is a function for this screen
			// We need to find out how to trigger a rename on the selected node
			// Perhaps through the contextMenu object?
			NNW.screens.renameCourseInTree();
			break;
		case "btnDelCourse" :
			// v6.4.3 If the selected node is a folder, follow a different path to deleting a simple course
			// Since you might have an empty folder, you can't test like this.
			//if (NNW.screens.trees.treeCourse.selectedNode.hasChildNodes()) {
			var thisID = NNW.screens.getSelectedCourseID();
			if (thisID==undefined || thisID=="") {
				_global.myTrace("btns.deleteFolder=" + NNW.screens.trees.treeCourse.selectedNode);
				NNW.control.onDelCourseFolder(NNW.screens.trees.treeCourse.selectedNode);
			} else {
				_global.myTrace("btns.deleteCourse=" + NNW.screens.trees.treeCourse.selectedNode);
				NNW.control.onDelCourse(thisID);
				//NNW.control.onDelCourse(NNW.screens.getSelectedCourseID());
			}
			break;
		case "btnWhatDoCourse" :	// v0.16.0, DL
			NNW.control.showWhatDo("Course");
			break;
		// scnExType (2)
		case "btnExTypeOK" :
			// v6.5.0.1 Yiu convert new exercise type to exercise one
			NNW.control.convertSelectExType();
			NNW.control.selectExType(NNW.screens.getSelectedExType());
			break;
		case "btnExTypeCancel" :
			NNW.view.onCancelExType();
			break;
		// scnExercise (7)
		case "btnExerciseSave" :
			NNW.control.onExerciseSave();
			break;
		/*case "btnExerciseBack" :
			NNW.control.onExerciseBack();
			break;*/
		// v6.4.0.1, DL: now combine the buttons btnExit and btnExerciseExit
		// to trace btnExerciseExit codes, go to case "btnExit"
		/*case "btnExerciseExit" :
			NNW.control.onExerciseExit();
			break;*/
		case "btnWhatDoExercise" :	// v0.9.0, DL
			NNW.control.showWhatDo("Exercise", NNW.screens.scnExercise.showingIndex);
			break;
		case "btnNewOption" :
			// v0.16.1, DL: for Dropdown we need to preset correct value
			// v6.4.2.5 also drags
			// v6.4.3 Item based drop down
			if (NNW.control.data.currentExercise.exerciseType=="Dropdown" || 
				NNW.control.data.currentExercise.exerciseType=="Stopdrop" || 
				NNW.control.data.currentExercise.exerciseType=="DragAndDrop" || 
				NNW.control.data.currentExercise.exerciseType=="DragOn") {
				dgs.addItemToList("Option", {label:"", correct:"false"});
			} else {
				dgs.addItemToList("Option", {label:""});
			}
			NNW.screens.promptForNewOption();
			break;
		case "btnRenOption" :
			NNW.control.onDoubleClickingItemOnList(NNW.screens.dgs.dgOption);
			break;
		case "btnDelOption" :
			NNW.view.deleteSelectedOption();
			break;
		case "btnScoreBasedFeedback" :
			NNW.screens.combos.resetScoreBasedFeedback();
			NNW.view.showFeedbackScreen();
			break;
		// -- more panels (10)
		case "btnBrowseInstructionsAudio" :
			NNW.screens.resetBrowseScreen("audioAutoPlay");
			NNW.view.showBrowseScreen();
			break;
		case "btnBrowseEmbedAudio" :
			NNW.screens.resetBrowseScreen("audioEmbed");
			NNW.view.showBrowseScreen();
			break;
		case "btnBrowseAfterMarkingAudio" :
			NNW.screens.resetBrowseScreen("audioAfterMarking");
			NNW.view.showBrowseScreen();
			break;
		case "btnBrowseImage" :
			NNW.screens.resetBrowseScreen("image");
			NNW.view.showBrowseScreen();
			break;
		case "btnBrowseVideo" :
			NNW.screens.resetBrowseScreen("videoEmbed");
			NNW.view.showBrowseScreen();
			break;
		case "btnClearInstructionsAudio" :
			NNW.control.updateExerciseInstructionsAudio(false, false);
			break;
		case "btnClearEmbedAudio" :
			NNW.control.updateExerciseEmbedAudio("");
			break;
		case "btnClearAfterMarkingAudio" :
			NNW.control.updateExerciseAfterMarkingAudio("");
			break;
		// v6.4.2.7 Add URLs
		// Remove the url and caption and make sure the chb is not selected
		case "btnClearURL1" :
			NNW.control.updateExerciseURL(1, "", "", false);
			NNW.screens.fillInURLs(NNW.control.data.currentExercise.URLs);
			break;
		case "btnClearURL2" :
			NNW.control.updateExerciseURL(2, "", "", false);
			NNW.screens.fillInURLs(NNW.control.data.currentExercise.URLs);
			break;
		case "btnClearURL3" :
			NNW.control.updateExerciseURL(3, "",  "", false);
			NNW.screens.fillInURLs(NNW.control.data.currentExercise.URLs);
			break;
		case "btnClearImage" :
			NNW.screens.enableImagePositionCheckBoxes(false);
			NNW.control.updateExerciseImage("category", "NoGraphic");
			NNW.screens.combos.setComboSelectedData("ImageCategory", "NoGraphic");
			break;
		case "btnClearVideo" :
			NNW.control.updateExerciseVideo("", "1", "top-right");
			break;
		// -- panel for question multimedia
		case "btnBrowseQuestionAudio" :
			NNW.screens.resetBrowseScreen("audioQuestion");
			NNW.view.showBrowseScreen();
			break;
		case "btnClearQuestionAudio" :
			if (!NNW.control.data.currentExercise.settings.misc.splitScreen) {
				var qNo = Number(NNW.screens.txts.txtQuestionNo.text);
				var mode = (this.chbQuestionAudioAfterMarking.selected) ? "2" : "1";
			} else {
				var qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
				var mode = (this.chbSplitScreenQuestionAudioAfterMarking.selected) ? "2" : "1";
			}
			NNW.control.updateExerciseQuestionAudio("", mode, qNo);
			//NNW.screens.txts.txtQuestionAudio.text = "";
			NNW.screens.setAudioCheckBox("Question", false);
			break;
		// scnUnit (13)
		case "btnBackCourse" :
			// v6.4.0.1, DL: no more saving
			//NNW.control.saveCourse("backCourse");
			NNW.control.releaseUnitFileToCourse();
			break;
		case "btnNewUnit" :
			NNW.control.addUnit();
			break;
		case "btnRenUnit" :
			NNW.control.onDoubleClickingItemOnList(NNW.screens.dgs.dgUnit);
			break;
		case "btnDelUnit" :
			NNW.control.onDelUnit(NNW.screens.getSelectedUnitIndex());
			break;
		case "btnNewExercise" :
			NNW.control.addExercise();
			break;
		case "btnEditExercise" :
			NNW.control.onDoubleClickingItemOnList(NNW.screens.dgs.dgExercise);
			break;
		case "btnDelExercise" :
			NNW.control.onDelExercise(NNW.screens.getSelectedExerciseIndex());
			break;
		case "btnUpUnit" :
			NNW.control.moveUnitUp(NNW.screens.getSelectedUnitIndex());
			break;
		case "btnDownUnit" :
			NNW.control.moveUnitDown(NNW.screens.getSelectedUnitIndex());
			break;
		case "btnUpExercise" :
			NNW.control.moveExerciseUp(NNW.screens.getSelectedExerciseIndex());
			break;
		case "btnDownExercise" :
			NNW.control.moveExerciseDown(NNW.screens.getSelectedExerciseIndex());
			break;
		case "btnCutQue":
			var qNo = Number(NNW.screens.txts.txtQuestionNo.text);
			NNW.control.cutExercise("question", qNo);
			// Update screen content
			_global.NNW.screens.textFormatting.resetFormatURL();
			_global.NNW.screens.txts.txtQuestionNo.text = qNo;
			_global.NNW.screens.txts.txtQuestionNo.dispatchEvent( { type:"enter" } );
			_global.NNW.screens.checkAndSetlblShowDefaultVisible();
			break;
		case "btnCutQueS":
			var qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
			NNW.control.cutExercise("question", qNo);
			_global.NNW.screens.textFormatting.resetFormatURL();
			_global.NNW.screens.txts.txtSplitScreenQuestionNo.text = qNo;
			_global.NNW.screens.txts.txtSplitScreenQuestionNo.dispatchEvent( { type:"enter" } );
			_global.NNW.screens.checkAndSetlblShowDefaultVisible();
			break;
		case "btnCopyQue":
			var qNo = Number(NNW.screens.txts.txtQuestionNo.text);
			NNW.control.copyExercise("question", qNo);
			break;
		case "btnCopyQueS":
			var qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
			NNW.control.copyExercise("question", qNo);
			break;
		case "btnPasteQue":
			var qNo = Number(NNW.screens.txts.txtQuestionNo.text);
			NNW.control.pasteExercise("question", qNo);
			_global.NNW.screens.textFormatting.resetFormatURL();
			_global.NNW.screens.txts.txtQuestionNo.text = qNo;
			_global.NNW.screens.txts.txtQuestionNo.dispatchEvent( { type:"enter" } );
			_global.NNW.screens.checkAndSetlblShowDefaultVisible();
			break;		
		case "btnPasteQueS":
			var qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
			NNW.control.pasteExercise("question", qNo);
			_global.NNW.screens.textFormatting.resetFormatURL();
			_global.NNW.screens.txts.txtSplitScreenQuestionNo.text = qNo;
			_global.NNW.screens.txts.txtSplitScreenQuestionNo.dispatchEvent( { type:"enter" } );
			_global.NNW.screens.checkAndSetlblShowDefaultVisible();
			break;
		case "btnWhatDoUnit" :	// v0.9.0, DL
			NNW.control.showWhatDo("Unit");
			break;
		case "btnSaveCourseName" :	// v6.4.0.1, DL
			// v6.4.2 escape it instead
			// v6.4.1.4, DL: DEBUG - network version student side cannot handle apostrophe in course name
			//if (NNW.control.__local) {
			//	NNW.screens.txts.txtCourseName.text = _global.replace(NNW.screens.txts.txtCourseName.text, "'", "");
			//}
			// v6.4.3 Just call to saveCourse with the event, the renaming will have happened already (from txts)
			//NNW.control.saveCourseName(NNW.screens.txts.txtCourseName.text);
			NNW.control.saveCourse("saveCourseName");
			break;
		// v0.8.1, DL: add prevQ & nextQ buttons to numeric stepper
		// v0.12.0, DL: change question no. holder from numeric stepper to ordinary textinput
		case "btnPrevQ" :
			// v6.5.1 Yiu fixing dragging gap length in other question bugs
			NNW.screens.textFormatting.resetFormatURL();
			var oldValue = Number(NNW.screens.txts.txtQuestionNo.text);
			if (oldValue>1) {
				NNW.screens.txts.txtQuestionNo.text = Number(NNW.screens.txts.txtQuestionNo.text) - 1;	// v0.12.0, DL: NNW.screens.nsps.nspQuestionNo.value -= 1;
				NNW.screens.txts.txtQuestionNo.dispatchEvent({type:"enter"});	// v0.12.0, DL: NNW.screens.nsps.nspQuestionNo.dispatchEvent({type:"change"});
			}
			NNW.screens.checkAndSetlblShowDefaultVisible();
			break;
		case "btnNextQ" :
			var oldValue = Number(NNW.screens.txts.txtQuestionNo.text);
			// v6.5.1 Yiu fixing dragging gap length in other question bugs
			NNW.screens.textFormatting.resetFormatURL();
			if (oldValue<NNW.control.__maxNoOfQuestions) {
				NNW.screens.txts.txtQuestionNo.text = Number(NNW.screens.txts.txtQuestionNo.text) + 1;	// v0.12.0, DL: NNW.screens.nsps.nspQuestionNo.value += 1;
				NNW.screens.txts.txtQuestionNo.dispatchEvent( { type:"enter" } );	// v0.12.0, DL: NNW.screens.nsps.nspQuestionNo.dispatchEvent({type:"change"});
			} else {
				NNW.control.raiseMaxNoOfQuestionsError();
			} 
			NNW.screens.checkAndSetlblShowDefaultVisible();
			break;
		case "btnPrevSplitScreen" :
			// v6.5.1 Yiu fixing dragging gap length in other question bugs
			NNW.screens.textFormatting.resetFormatURL();
			var oldValue = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
			if (oldValue>1) {
				NNW.screens.txts.txtSplitScreenQuestionNo.text = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text) - 1;	// v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.value -= 1;
				NNW.screens.txts.txtSplitScreenQuestionNo.dispatchEvent({type:"enter"});	// v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.dispatchEvent({type:"change"});
			}
			NNW.screens.checkAndSetlblShowDefaultVisible();
			break;
		case "btnNextSplitScreen" :
			// v6.5.1 Yiu fixing dragging gap length in other question bugs
			NNW.screens.textFormatting.resetFormatURL();
			var oldValue = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
			if (oldValue<NNW.control.__maxNoOfQuestions) {
				NNW.screens.txts.txtSplitScreenQuestionNo.text = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text) + 1;	// v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.value += 1;
				NNW.screens.txts.txtSplitScreenQuestionNo.dispatchEvent({type:"enter"});	// v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.dispatchEvent({type:"change"});
			} else {
				NNW.control.raiseMaxNoOfQuestionsError();
			}
			NNW.screens.checkAndSetlblShowDefaultVisible();
			break;
		// scnPopup
		case "btnPopupOK" :
			NNW.view.onPopupBtnClick("ok");
			break;
		case "btnPopupCancel" :
			NNW.view.onPopupBtnClick("cancel");
			break;
		case "btnPopupYes" :
			NNW.view.onPopupBtnClick("yes");
			break;
		case "btnPopupNo" :
			NNW.view.onPopupBtnClick("no");
			break;
		// exit button (1)
		case "btnExit" :
			// v6.4.0.1, DL: now combine the buttons btnExit and btnExerciseExit
			// pass a boolean to indicate whether it is an exit from the exercise screen to exitProgram()
			NNW.control.exitProgram(NNW.screens.scnExercise._visible);
			break;
		// v0.16.1, DL: scnExport (4)
		case "btnExport" :
			// pass the dataProvider to control to see which exercises are selected
			NNW.control.exportFiles(NNW.screens.trees.treeExport.dataProvider, false);
			break;
		case "btnSCORMExport" :
			// pass the dataProvider to control to see which exercises are selected
			// v6.4.2.2 Use different function for SCORM creation, not just a type of export
			//NNW.control.exportFiles(NNW.screens.trees.treeExport.dataProvider, true);
			NNW.control.createSCO(NNW.screens.trees.treeExport.dataProvider);
			break;
		case "btnUploadImport" :
			// v6.4.2, DL: let user's select a file that is in his own directory first
			//NNW.control.uploadImport();
			NNW.screens.resetBrowseScreen("zip");
			NNW.view.showBrowseScreen();
			break;
		case "btnBackFromExport" :
			NNW.view.backFromExportScreen();
			break;
		// v0.16.1, DL: scnImport (2)
		case "btnImport" :
			NNW.control.importFiles(NNW.screens.trees.treeImport.dataProvider);
			break;
		case "btnBackFromImport" :
			NNW.view.backFromExportScreen();
			break;
		// v0.16.1, DL: scnBrowse (3)
		case "btnBrowseOK" :
			var browseFilename = NNW.screens.dgs.getSelectedLabel("BrowseFiles");
			if (browseFilename!=undefined && browseFilename!="undefined" && browseFilename!="") {
				var browseFileArray = new Array();
				browseFileArray.push(browseFilename);
				switch (this.browseFileType.substr(0, 5)) {
				case "image" :
					NNW.control.upload.onImageUploaded(browseFileArray);
					break;
				case "audio" :
					NNW.control.upload.uploadType = this.browseFileType;
					if (this.browseFileType=="audioQuestion") {
						if (!NNW.control.data.currentExercise.settings.misc.splitScreen) {
							NNW.control.upload.uploadQuestionNo = Number(NNW.screens.txts.txtQuestionNo.text);
						} else {
							NNW.control.upload.uploadQuestionNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
						}
					}
					NNW.control.upload.onAudioUploaded(browseFileArray);
					break;
				case "video" :
					NNW.control.upload.uploadType = this.browseFileType;
					NNW.control.upload.onVideoUploaded(browseFileArray);
					break;
				case "zip" :
					// v6.4.2, DL: browse for zip files
					NNW.view.showMask();
					NNW.control.upload.onImportUploaded(browseFileArray);
					break;
				}
			}
			NNW.view.hideBrowseScreen();
			break;
		case "btnBrowseUpload" :
			switch (this.browseFileType) {
			case "image" :
				NNW.control.updateExerciseImage("category", "YourGraphic");
				break;
			case "audioAutoPlay" :
				NNW.control.uploadAudio("AutoPlay");
				break;
			case "audioEmbed" :
				NNW.control.uploadAudio("Embed");
				break;
			case "audioQuestion" :
				if (!NNW.control.data.currentExercise.settings.misc.splitScreen) {
					var qNo = Number(NNW.screens.txts.txtQuestionNo.text);
				} else {
					var qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);
				}
				NNW.control.uploadMultipleAudio("Question", qNo);
				break;
			case "audioAfterMarking" :
				NNW.control.uploadAudio("AfterMarking");
				break;
			case "videoEmbed" :
				NNW.control.uploadVideo("Embed");
				break;
			case "zip" :
				// v6.4.2, DL: browse for zip files
				NNW.control.uploadImport();
				break;
			}
			NNW.view.hideBrowseScreen();
			break;
		case "btnBrowseCancel" :
			if (NNW.screens.combos.getComboSelectedData("ImageCategory")=="YourGraphic" && NNW.control.data.currentExercise.image.category!="YourGraphic") {
				NNW.screens.enableImagePositionCheckBoxes(false);
				NNW.control.updateExerciseImage("category", "NoGraphic");
				NNW.screens.combos.setComboSelectedData("ImageCategory", "NoGraphic");
				NNW.screens.enableVideoPositionCheckBoxesPlus();
			}
			NNW.view.hideBrowseScreen();
			break;
	}
	if (btnName.indexOf("btnBrowse")!=0 && btnName.indexOf("btnClear")!=0) {
		NNW.screens.closeMultimediaPanels();
	}
}

/*
btns.setButtonsFunctions = function() : Void {
	// scnAuthCode
	onAuthCode = function() { NNW.control.checkAuthCode(); }
	// scnLogin
	onLoginOK = function() { NNW.control.checkLogin(NNW.screens.txts.txtUsername.text, NNW.screens.txts.txtPassword.text); }
	onLoginClear = function() { NNW.view.clearLoginScreen(); }
	// scnButtons
	onUpload = function() { NNW.control.upload(); }
	onUpgrade = function() { NNW.control.upgrade(); }
	onHelp = function() { NNW.control.showHelp(); }
	onPreview = function() { NNW.control.previewExercise(); }
	onSaveCourse = function() { NNW.control.saveCourse(); }
	onSettings = function() { NNW.control.showSettings(); }
	// scnCourse
	onAddCourse = function() { NNW.control.addCourse(); }
	onRenCourse = function() { NNW.view.onRenameCourse(); }
	onDelCourse = function() { NNW.view.onDelCourse(); }
	// scnExType
	onSelectExType = function() { NNW.control.selectExType(); }
	onCancelExType = function() { NNW.view.onCancelExType(); }
	// scnExercise
	onExerciseFinish = function() { NNW.control.onExerciseFinish(); }
	onExerciseCancel = function() { NNW.view.onExerciseCancel(); }
	// scnUnit
	onBackCourse = function() { NNW.view.showCourseScreen(); }
	onNewUnit = function() { NNW.control.addUnit(); }
	onRenUnit = function() { NNW.view.onRenameUnit(); }
	onDelUnit = function() { NNW.view.onDelUnit(); }
	onNewExercise = function() { NNW.control.addExercise(); }
	onRenExercise = function() { NNW.view.onRenameExercise(); }
	onDelExercise = function() { NNW.view.onDelExercise(); }
	onUpUnit = function() { NNW.control.moveUnitUp(); }
	onDownUnit = function() { NNW.control.moveUnitDown(); }
	onUpExercise = function() { NNW.control.moveExerciseUp(); }
	onDownExercise = function() { NNW.control.moveExerciseDown(); }
	// exit button
	onExit = function() { NNW.control.exitProgram(); }
	
	// scnAuthCode
	this.btnSubmitCode.setOnRelease(onAuthCode);
	// scnLogin
	this.btnLoginOK.setOnRelease(onLoginOK);
	this.btnLoginClear.setOnRelease(onLoginClear);
	// scnButtons
	this.btnUpload.setOnRelease(onUpload);
	this.btnUpgrade.setOnRelease(onUpgrade);
	this.btnHelp.setOnRelease(onHelp);	
	this.btnPreview.setOnRelease(onPreview);
	this.btnSaveCourse.setOnRelease(onSaveCourse);
	this.btnSettings.setOnRelease(onSettings);
	// scnCourse
	this.btnAddCourse.setOnRelease(onAddCourse);
	this.btnRenCourse.setOnRelease(onRenCourse);
	this.btnDelCourse.setOnRelease(onDelCourse);
	// scnExType
	this.btnExTypeOK.setOnRelease(onSelectExType);
	this.btnExTypeCancel.setOnRelease(onCancelExType);
	// scnExercise
	this.btnExerciseFinish.setOnRelease(onExerciseFinish);
	this.btnExerciseCancel.setOnRelease(onExerciseCancel);
	// scnUnit
	this.btnBackCourse.setOnRelease(onBackCourse);
	this.btnNewUnit.setOnRelease(onNewUnit);
	this.btnRenUnit.setOnRelease(onRenUnit);
	this.btnDelUnit.setOnRelease(onDelUnit);
	this.btnNewExercise.setOnRelease(onNewExercise);
	this.btnRenExercise.setOnRelease(onRenExercise);
	this.btnDelExercise.setOnRelease(onDelExercise);
	this.btnUpUnit.setOnRelease(onUpUnit);
	this.btnDownUnit.setOnRelease(onDownUnit);
	this.btnUpExercise.setOnRelease(onUpExercise);
	this.btnDownExercise.setOnRelease(onDownExercise);
	// exit button
	this.btnExit.setOnRelease(onExit);
}
*/
