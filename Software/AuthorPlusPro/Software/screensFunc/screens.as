// v0.1, DL: everything in this movie should be in NNW.screens

// v6.5.1 Yiu add bew exercise types
_global.g_strQuestionSpotterID		= "QuestionSpotter";
_global.g_strBulletID				= "Bullet";
_global.g_strErrorCorrection		= "ErrorCorrection";
_global.g_strSplitDropdown			= "SplitDropdown";
_global.g_strSplitGapfill			= "SplitGapfill";

_global.aryTextAreaFormatting		= new Array();	// v6.5.1 Yiu fixing Scorebasedfeedback font style problem

// End v6.5.1 Yiu add bew exercise types
var scnNameArray = new Array("scnTest", "scnAuthCode", "scnLogin", "scnCourse", "scnUnit", "scnExercise", "scnImport", "scnExport", "scnButtons", "scnAlwaysOnTop", "scnFirstTime", "scnMask", "scnEmail", "scnFeedback", "scnBrowse", "scnExType", "scnPopup");
var screensLoaded = 0;
//v6.4.2 Where does this 31 come from? Is this all the little mini-screens like options_mc? Now seems to be 30
//var totalNoOfScreens = scnNameArray.length + 31;
var totalNoOfScreens = scnNameArray.length + 30;
var allScreensLoaded = false;
var intID = 0;
var liteWords = new Array();
var proWords = new Array();

// function for auth code screen
hideAuthCodeTick = function() : Void { scnAuthCode.tick_mc._visible = false; }
showAuthCodeTick = function() : Void { scnAuthCode.tick_mc._visible = true; }

// functions for floating windows
setWindowsCenterToScreen = function() : Void { wins.centerToScreen(); }
setPopupButtonsVisibility = function(v1:Boolean, v2:Boolean, v3:Boolean, v4:Boolean) {
	btns.btnPopupOK._visible = v1;
	btns.labelPopupOK._visible = v1;
	btns.btnPopupCancel._visible = v2;
	btns.labelPopupCancel._visible = v2;
	btns.btnPopupYes._visible = v3;
	btns.labelPopupYes._visible = v3;
	btns.btnPopupNo._visible = v4;
	btns.labelPopupNo._visible = v4;
}
setPopupButtons = function(n:Number) : Void {
	/* 1 for OK, 2 for Cancel, 3 for OK+Cancel, 12 for Yes+No, 14 for Yes+No+Cancel */
	switch (n) {
	case 1 : // ok
		btns.btnPopupOK._x = (wins.winPopup._width - btns.btnPopupOK._width) / 2 - 7;
		btns.labelPopupOK._x = btns.btnPopupOK._x;
		setPopupButtonsVisibility(true, false, false, false);
		break;
	case 2 : // cancel
		btns.btnPopupCancel._x = (wins.winPopup._width - btns.btnPopupCancel._width) / 2 - 7;
		btns.labelPopupCancel._x = btns.btnPopupCancel._x;
		setPopupButtonsVisibility(false, true, false, false);
		break;
	case 3 : // ok + cancel
		btns.btnPopupOK._x = (wins.winPopup._width - btns.btnPopupOK._width) / 2 - 60 - 7;
		btns.labelPopupOK._x = btns.btnPopupOK._x;
		btns.btnPopupCancel._x = (wins.winPopup._width - btns.btnPopupCancel._width) / 2 + 60 - 7;
		btns.labelPopupCancel._x = btns.btnPopupCancel._x;
		setPopupButtonsVisibility(true, true, false, false);
		break;
	case 12 : // yes + no
		btns.btnPopupYes._x = (wins.winPopup._width - btns.btnPopupYes._width) / 2 - 60 - 7;
		btns.labelPopupYes._x = btns.btnPopupYes._x;
		btns.btnPopupNo._x = (wins.winPopup._width - btns.btnPopupNo._width) / 2 + 60 - 7;
		btns.labelPopupNo._x = btns.btnPopupNo._x;
		setPopupButtonsVisibility(false, false, true, true);
		break;
	case 14: // yes + no + cancel
		btns.btnPopupYes._x = (wins.winPopup._width - btns.btnPopupNo._width) / 2 - btns.btnPopupNo._width - 30 - 7;
		btns.labelPopupYes._x = btns.btnPopupYes._x;
		btns.btnPopupNo._x = (wins.winPopup._width - btns.btnPopupNo._width) / 2 - 7;
		btns.labelPopupNo._x = btns.btnPopupNo._x;
		btns.btnPopupCancel._x = (wins.winPopup._width - btns.btnPopupNo._width) / 2 + btns.btnPopupNo._width + 30 - 7;
		btns.labelPopupCancel._x = btns.btnPopupCancel._x;
		setPopupButtonsVisibility(false, true, true, true);
		break;
	}
}

// functions for loading first time screen
loadFirstTimeMovie = function(m:Object) : Void {
	m.loadSwf_mc.loadMovie(_global.NNW.paths.main+"/Help/Screens/Screen-FirstTime.swf");
}

// function for login screen
function showPleaseWait(b:Boolean) : Void {
	NNW.screens.pleaseWait._visible = b;
}
clearLoginFields = function() : Void {
	txts.txtUsername.text = "";
	txts.txtPassword.text = "";
}
// function for email screen
clearEmailFields = function() : Void {
	txts.txtEmailSubject.text = "";
	txts.txtEmailText.text = "";
}

// functions for browse file list
clearBrowseFileList = function() : Void { dgs.clearList("BrowseFiles"); }
addFilesToBrowseList = function(arr:Array) : Void {
	for (var i=0; i<arr.length; i++) {
		if (arr[i]!="") {
			dgs.addItemToList("BrowseFiles", {label:arr[i]});
		}
	}
}

// show Clarity programs
showClarityPrograms = function() : Void {
	var edit = _global.NNW.control.edit;
	var n = edit.getNoOfPrograms();
	_global.myTrace("screens.showClarityProgram - n="+n);
	if (n>1) {
		var a = edit.getProgramsCodes();
		var y = 112;
		a.sort();
		for (var i=0; i<a.length; i++) {
			// v6.4.2.6 In case one program is not present
			if (a[i]!=undefined) {
				myTrace("editing for " + a[i]);
				scnCourse[a[i]+"_mc"]._visible = true;
				scnCourse[a[i]+"_mc"]._y = y;
				y += 72;
			}
		}
		scnCourse.showProgramSelection(a[0]+"_mc");
		_global.NNW.interfaces.setInterface(a[0]);
		scnCourse.lblSelectProgram.visible = true;
	}
}

// functions for course list
// v6.4.3 Change to tree
//promptForNewCourse = function() : Void { dgs.promptForNewItem("Course"); }
promptForNewCourse = function() : Void { 
	myTrace("screens.promptForNewCourse");
	trees.promptForNewItem("Course"); 
}
// v6.4.3 Change to tree
//renameCourseOnList = function() : Void { dgs.renameSelectedItem("Course"); }
renameCourseOnList = function() : Void { 
	myTrace("screens.renameSelectedItem");
	trees.renameSelectedItem("Course"); 
}
renameCourseInTree = function() : Void {
	trees.renameSelectedNode("Course");
}
// v6.4.3 Change to tree
//delCourseFromList = function() : Void { dgs.removeSelectedItem("Course"); }
delCourseFromList = function() : Void { 
	_global.myTrace("delCourseFromList");
	trees.removeSelectedItem("Course"); 
}
// v6.4.3 Change to tree
//getSelectedCourseLabel = function() : String { return dgs.getSelectedLabel("Course"); }
getSelectedCourseLabel = function() : String { 
	return trees.getSelectedLabel("Course"); 
}
// v6.4.3 Change to tree
//getSelectedCourseID = function() : String { return dgs.getSelectedID("Course"); }
getSelectedCourseID = function() : String { 
	return trees.getSelectedID("Course"); 
}
// v6.4.3 Change to tree
clearCourseList = function() : Void { 
	//dgs.clearList("Course"); 
	trees.clearList("Course"); 
}
// v6.4.3 Change to XML 
//addCoursesToList = function(arr:Array) : Void {
addCoursesToList = function(dp:XML) : Void {
	/*
	for (var i=0; i<arr.length; i++) {
		var item = arr[i];
		dgs.addItemToList("Course", {label:item.name, id:item.id});
	}
	dgs.removeExtraColumns("Course");
	*/
	// v6.4.3 At this point you should check that the Courses array matches the interface xml
	// or is it easier to make sure you update both together? Add, delete, rename.
	// Moving doesn't matter as we only do that in the interface.
	
	// v6.4.3 Also add items to a course tree
	trees.setDataProvider("Course", dp);
	// and show them - to a certain degree - I suppose that ideally you would count the courses and open to fit them in the box.
	// and you might not want to do this if the user is already working away, just remember their old status
	trees.openNodesToLevel("Course", 2);
}
// v6.4.3 Change to tree
//selectCourseByIndex = function(n:Number) : Void { dgs.setSelectedItem("Course", n); }
selectCourseByIndex = function(n:Number) : Void { 
	trees.setSelectedItem("Course", n); 
}
//getSelectedCourseIndex = function() : Number { return dgs.getSelectedIndex("Course"); }
getSelectedCourseIndex = function() : Number { 
	return trees.getSelectedIndex("Course"); 
}

// functions for unit screen
fillInCourseName = function(t:String) : Void { txts.txtCourseName.text = (t!=undefined && t!="undefined") ? t : ""; }
setCourseEnabled = function(b:Boolean) : Void { 
	chbs.setChecked("chbCourseEnable", b); 
	//v6.4.2.2 course enabling is a Pro version feature
	if (NNW.control._lite) {
		//_global.myTrace("hiding course enable for Light")
		NNW.view.setVisible("chbCourseEnable", false);
	}
}

setCoursePrivacy = function(Flag:Number) : Void {
	if(Flag == 1){
		chbs.setChecked("chbPrivacyPrivate", true);
		chbs.setChecked("chbPrivacyGroup", false);
		chbs.setChecked("chbPrivacyPublic", false);
	}else if(Flag == 2){
		chbs.setChecked("chbPrivacyPrivate", false);
		chbs.setChecked("chbPrivacyGroup", true);
		chbs.setChecked("chbPrivacyPublic", false);		
	}else{
		chbs.setChecked("chbPrivacyPrivate", false);
		chbs.setChecked("chbPrivacyGroup", false);
		chbs.setChecked("chbPrivacyPublic", true);		
	}
}

// functions for unit list
promptForNewUnit = function() : Void { dgs.promptForNewItem("Unit"); }
renameUnitOnList = function() : Void { dgs.renameSelectedItem("Unit"); }
delUnitFromList = function() : Void { dgs.removeSelectedItem("Unit"); }
getSelectedUnitLabel = function() : String { return dgs.getSelectedLabel("Unit"); }
getSelectedUnit = function() : String { return dgs.getSelectedUnit("Unit"); }
moveUnitUp = function() : Void { dgs.moveUpSelectedItem("Unit"); }
moveUnitDown = function() : Void { dgs.moveDownSelectedItem("Unit"); }
clearUnitList = function() : Void { dgs.clearList("Unit"); }
addUnitsToList = function(arr:Array) : Void {
	
	// v6.4.0.1, DL: don't show more than max. no. of units allowed if Lite version
	var maxNo = arr.length;
	if (NNW.control._lite && arr.length>NNW.control.__maxNoOfUnits) {
		maxNo = NNW.control.__maxNoOfUnits;
	}
	
	for (var i=0; i<maxNo; i++) {
		var item = arr[i];
		dgs.addItemToList("Unit", {label:item.caption, unit:item.unit});
	}
	dgs.removeExtraColumns("Unit");
	dgs.dgUnit.getColumnAt(0).cellRenderer = "dropCaptureCellRenderer";
}
selectUnitByIndex = function(n:Number) : Void { dgs.setSelectedItem("Unit", n); }
getSelectedUnitIndex = function() : Number { return dgs.getSelectedIndex("Unit"); }
selectUnitByField = function(f:String, v:String) : Void { dgs.setSelectedItemByField("Unit", f, v); }

// functions for exercise list
promptForNewExercise = function() : Void { dgs.promptForNewItem("Exercise"); }
renameExerciseOnList = function() : Void { dgs.renameSelectedItem("Exercise"); }
delExerciseFromList = function() : Void { dgs.removeSelectedItem("Exercise"); }
getSelectedExerciseLabel = function() : String { return dgs.getSelectedLabel("Exercise"); }
getSelectedExerciseUnit = function() : String { return dgs.getSelectedUnit("Exercise"); }
getSelectedExerciseID = function() : String { return dgs.getSelectedID("Exercise"); }
moveExerciseUp = function() : Void { dgs.moveUpSelectedItem("Exercise"); }
moveExerciseDown = function() : Void { dgs.moveDownSelectedItem("Exercise"); }
clearExerciseList = function() : Void { dgs.clearList("Exercise"); }
addExercisesToList = function(arr:Array) : Void {
	
	// v6.4.0.1, DL: don't show more than max. no. of exercises allowed if Lite version
	var maxNo = arr.length;
	if (NNW.control._lite && arr.length>NNW.control.__maxNoOfExercises) {
		maxNo = NNW.control.__maxNoOfExercises;
	}
	
	for (var i=0; i<maxNo; i++) {
		var item = arr[i];
		if (item.caption!=undefined && _global.trim(item.caption)!="") {
			dgs.addItemToList("Exercise", {label:item.caption, unit:item.unit, id:item.id});
		}
	}
	dgs.removeExtraColumns("Exercise");
}
selectExerciseByIndex = function(n:Number) : Void { 
	//_global.myTrace("dgs.setSelectedItem to " + n);
	dgs.setSelectedItem("Exercise", n); 
	// v6.4.2.5 and set the focus? This is not enough
	//Selection.setFocus(dgs.dgExercise);
}
getSelectedExerciseIndex = function() : Number { return dgs.getSelectedIndex("Exercise"); }

// functions for exType screen
getSelectedExType = function() : String {
	return chbs.getSelectedCheckBox("chbExType");
}

// functions for exercise screen
resetExerciseScreen = function() : Void {
	// v6.5.4.2 Yiu, fixingone more question if reopen a gapfill exercise after dragging gap length before exit the menu
	Selection.setSelection(0, 0);
	NNW.screens.textFormatting.resetFormatURL();
	// End v6.5.4.2 Yiu, fixingone more question if reopen a gapfill exercise after dragging gap length before exit the menu
	
	scnExercise.setToSegment1();
	
	var ex 		= NNW.control.data.currentExercise;
	ex.initExerciseScreenGapLength(1); 

	acds.setToFirstSegments();
	//_global.myTrace("reset exercise screen");
}
fillInExerciseName = function(t:String) : Void { 
	//_global.myTrace("menu name text, font=" + txts.txtExerciseName.getStyle("fontFamily"));
	txts.txtExerciseName.text = (t!=undefined && t!="undefined") ? t : ""; 
}

// v6.5.1 Yiu new default gap length check box and slider 
checkIfSliderIsAllowedToVisible	= function():Boolean
{
	var ex 		= NNW.control.data.currentExercise;
	var exType 	= ex.exerciseType;
	return exType == "Countdown";
}
// End v6.5.1 Yiu new default gap length check box and slider 

// v6.5.1 original instruction text box is deleted, replaced by txtTitle2
/*
fillInTitle = function(t:String) : Void {
	txts.txtTitle.vPosition = 0;
	txts.txtTitle.html = true;
	txts.txtTitle.text = "";
	if (t!=undefined&&t!="undefined") {
		//_global.myTrace("title=" + t);
		if (t.indexOf("<")==0) {
			txts.txtTitle.text = t;
		} else {
			// v6.4.2 AR The formatting doesn't work for typing at the end of line. Why is <B> outside everything else?
			//t = "<B><TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\"><FONT FACE=\"Verdana\" SIZE=\"12\" COLOR=\"#000000\">" + t;
			//t = t + "</FONT></P></TEXTFORMAT></B>";
			t = "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\"><B><FONT FACE=\"Verdana\" SIZE=\"12\" COLOR=\"#000000\">" + t +
				"</FONT></B></P></TEXTFORMAT>";
			txts.txtTitle.text = t;
		}
	}
	//_global.myTrace("style before text, bold=" + txts.txtTitle.getStyle("fontWeight"));
	//txts.txtTitle.setStyle("fontWeight", "bold"));
	//txts.txtTitle.text = "Adrian's plain text";
}
*/
fillInTitle2 = function(t:String) : Void {
	txts.txtTitleTemp.html	= true;
	txts.txtTitleTemp.text	= t;
	txts.txtTitleTemp.html	= false;
	
	txts.txtTitle2.vPosition 	= 0;
	txts.txtTitle2.text 		= txts.txtTitleTemp.text;
}
// End v6.5.1 original instruction text box is deleted, replaced by txtTitle2

fillInImage = function(image:Object) : Void {
	if (image.filename!=undefined && image.filename!="undefined") {
		txts.txtFilenameImage.text = (image.location=="shared") ? "" : image.filename;
	} else {
		txts.txtFilenameImage.text = "";
	}
}
fillInAudios = function(audios:Object) : Void {
	
	// reset to nothing first
	txts.txtEmbedAudio.text = "";
	txts.txtAfterMarkingAudio.text = "";
	txts.txtInstructionsAudioUpload.text = "";
	
	for (var i in audios) {
		var audioObj = audios[i];
		switch (audioObj.mode) {	// audio mode: 1 - embed, 2 - after marking, 4 - autoplay
		case "1" :
			if (audioObj.filename!=undefined && audioObj.filename!="undefined") {
				txts.txtEmbedAudio.text = audioObj.filename;
			}
			break;
		case "2" :
			if (audioObj.filename!=undefined && audioObj.filename!="undefined") {
				txts.txtAfterMarkingAudio.text = audioObj.filename;
			}
			break;
		case "4" :
			if (audioObj.filename!=undefined && audioObj.filename!="undefined") {
				txts.txtInstructionsAudioUpload.text = (audioObj.location=="shared") ? "" : audioObj.filename;
			}
			break;
		}
	}
}
// v6.4.2.7 Adding URLs
fillInURLs = function(URLs:Object):Void {
	// reset to nothing first
	txts.txtURL1.text = "";
	txts.txtURL2.text = "";
	txts.txtURL3.text = "";
	txts.txtURLCaption1.text = "";
	txts.txtURLCaption2.text = "";
	txts.txtURLCaption3.text = "";
	
	// then fill in from the object
	for (var i in URLs) {
		_global.myTrace("screens.fillInURLS["+URLs[i].idx+"] url=" + URLs[i].url);
		var urlObj = URLs[i];
		var thisIdx = urlObj.idx;
		txts["txtURL" + thisIdx].text = urlObj.url;
		txts["txtURLCaption" + thisIdx].text = urlObj.caption;
		// and set the chb? or is this done in setURLMode?
		//if (urlObj.floating) {
		//	chbs.setChecked("chbURLToolbar" + thisIdx, true);
		//}
	}
	
	// then call the chbs setting routine - or is the above OK?
	this.setURLMode(URLs);
}
fillInVideos = function(videos:Object) : Void {
	var videoObj = videos[0];
	if (videoObj.filename!=undefined && videoObj.filename!="undefined") {
		txts.txtFilenameVideo.text = videoObj.filename;
	} else {
		txts.txtFilenameVideo.text = "";
	}
}
handleSameLengthGapsChecked	= function(b:Boolean):Void
{
	chbs.chbDefaultLengthGaps.enabled	= !b;
	// v6.5.1 Yiu get rip of the same length gap slider which is not used
	
	if (checkIfSliderIsAllowedToVisible())
	{
		sliderSameLengthGap._visible		= b;
	} else {
		sliderSameLengthGap._visible		= false;
	}
	showSliderAndLabel(!b);
}

handleDefaultLengthGapsChecked	= function(b:Boolean):Void
{
	chbs.chbSameLengthGaps.enabled	= !b;
	sliderDefaultLengthGap._visible	= b;
	setlblShowDefaultVisible(b);
}
			
fillInSettings = function(s:Object) : Void {
	// ar v6.2.4.6 Reset any chbs that might have been disabled in the last exercise
//resetChbEnabled = function() : Void {
	chbs.chbBtnMarking.enabled = true;
	chbs.chbBtnFeedback.enabled = true;
	chbs.chbBtnRule.enabled = true;
	chbs.chbMarkingInstant.enabled = true;
	chbs.chbMarkingDelayed.enabled = true;
	chbs.chbMarkingChoose.enabled = true;
	chbs.chbFeedbackScoreBased.enabled = true;
//}
	if (s.marking.instant) {
		chbs.setChecked("chbMarkingInstant", true);
		chbs.setChecked("chbMarkingDelayed", false);
		chbs.setChecked("chbMarkingChoose", false);
	} else if (s.buttons.chooseInstant) {
		chbs.setChecked("chbMarkingInstant", false);
		chbs.setChecked("chbMarkingDelayed", false);
		chbs.setChecked("chbMarkingChoose", true);
	} else {
		chbs.setChecked("chbMarkingInstant", false);
		chbs.setChecked("chbMarkingDelayed", true);
		chbs.setChecked("chbMarkingChoose", false);
	}
	// v6.4.2.5 sound effects
	if (s.misc.soundEffects) {
		chbs.setChecked("chbSoundEffects", true);
	} else {
		chbs.setChecked("chbSoundEffects", false);
	}
	
	// v0.16.1, DL: debug - instructions audio isn't a real setting!
	// switch to nnw instead of misc node
	if (s.nnw.instructionsAudioDefault) {
		chbs.setChecked("chbInstructionsAudioDefault", true);
		chbs.setChecked("chbInstructionsAudioUpload", false);
	} else if (s.nnw.instructionsAudioUpload) {
		chbs.setChecked("chbInstructionsAudioDefault", false);
		chbs.setChecked("chbInstructionsAudioUpload", true);
	} else {
		//v6.4.2.1 Set the default to include the audio instruction
		// No, not done here as this is read every time
		chbs.setChecked("chbInstructionsAudioDefault", false); 
		//chbs.setChecked("chbInstructionsAudioDefault", true);
		chbs.setChecked("chbInstructionsAudioUpload", false);
	}
	// v0.16.1, DL: add embedded audio and after marking audio settings (not real settings in xml)
	if (s.nnw.embedAudio) {
		chbs.setChecked("chbEmbedAudio", true);
	} else {
		chbs.setChecked("chbEmbedAudio", false);
	}
	if (s.nnw.afterMarkingAudio) {
		chbs.setChecked("chbAfterMarkingAudio", true);
	} else {
		chbs.setChecked("chbAfterMarkingAudio", false);
	}
	// v0.16.1, DL: add video
	if (s.nnw.embedVideo||s.nnw.floatingVideo) {
		chbs.setChecked("chbEmbedVideo", true);
	} else {
		chbs.setChecked("chbEmbedVideo", false);
	}
	// combined with embedVideo
	/*if (s.nnw.floatingVideo) {
		chbs.setChecked("chbFloatingVideo", true);
	} else {
		chbs.setChecked("chbFloatingVideo", false);
	}*/
	
	if (s.exercise.matchCapitals) {
		chbs.setChecked("chbCapitalisation", true);
	} else {
		chbs.setChecked("chbCapitalisation", false);
	}
	// v6.4.1, DL: same length gaps is available to Countdown and gaps
	// for countdown, there'll be a slider for user to choose the length of gaps
	
	// v6.5.1 Yiu get rip of the same length gap slider which is not used	
	//if (NNW.control.data.currentExercise.exerciseType == "Countdown" && Number(s.exercise.sameLengthGaps) > 0) {
	if (	NNW.control.data.currentExercise.exerciseType == "Countdown" && 
			(Number(s.exercise.sameLengthGaps) > 0 || s.exercise.sameLengthGaps=="true")) {
		chbs.setChecked("chbSameLengthGaps", true);
		NNW.screens.handleSameLengthGapsChecked(true);
		// v6.5.1 Yiu get rip of the same length gap slider which is not used
		NNW.screens.sliderSameLengthGap.setValue(Number(s.exercise.sameLengthGaps));
	// for gaps, it is only a true/false setting
	} else if (s.exercise.sameLengthGaps=="true" || Number(s.exercise.sameLengthGaps) > 0){
		chbs.setChecked("chbSameLengthGaps", true);
		NNW.screens.handleSameLengthGapsChecked(true);		
		
		// v6.5.1 Yiu get rip of the same length gap slider which is not used
		//NNW.screens.sliderSameLengthGap.setValue(Number(s.exercise.sameLengthGaps));
	} else {
		chbs.setChecked("chbSameLengthGaps", false);
		NNW.screens.handleSameLengthGapsChecked(false);
	}

	// v6.5.1 Yiu new default gap length check box and slider 
	if (s.exercise.defaultLengthGaps == "true" || Number(s.exercise.defaultLengthGaps) > 0)	{
		chbs.setChecked("chbDefaultLengthGaps", true);
		NNW.screens.handleDefaultLengthGapsChecked(true);
		NNW.screens.sliderDefaultLengthGap.setValue(Number(s.exercise.defaultLengthGaps));
	} else {
		NNW.screens.sliderDefaultLengthGap.setValue(1);
		chbs.setChecked("chbDefaultLengthGaps", false);
		NNW.screens.handleDefaultLengthGapsChecked(false);
	}
	NNW.screens.checkAndSetlblShowDefaultVisible();
	
	// end v6.5.1 Yiu new default gap length check box and slider
	
	if (s.exercise.preview) {	// v0.12.0, DL: show text before countdown
		chbs.setChecked("chbShowTextFirst", true);
	} else {
		chbs.setChecked("chbShowTextFirst", false);
	}
	if (s.exercise.hiddenTargets) {	// v0.16.0, DL: hide targets for proofreading
		chbs.setChecked("chbHideTargets", true);
	} else {
		chbs.setChecked("chbHideTargets", false);
	}
	if (s.marking.overwriteAnswers) {	// v0.16.0, DL: overwrite answers for drags/gaps
		chbs.setChecked("chbOverwriteAnswers", true);
	} else {
		chbs.setChecked("chbOverwriteAnswers", false);
	}
	if (s.misc.timed>0) {	// v0.16.0, DL: time limit
		txts.txtTimeLimit.text = s.misc.timed.toString();		
	} else {
		txts.txtTimeLimit.text = "";
	}
	if (s.buttons.marking==false) {	// v0.16.0, DL: switch on/off marking button
		chbs.setChecked("chbBtnMarking", false);
	} else {
		chbs.setChecked("chbBtnMarking", true);
	}
	if (s.buttons.feedback==false) {	// v0.16.0, DL: switch on/off feedback button
		chbs.setChecked("chbBtnFeedback", false);
	} else {
		chbs.setChecked("chbBtnFeedback", true);
	}
	// v6.4.2.8 Rule button for TB
	if (s.buttons.rule==false) {	// v0.16.0, DL: switch on/off marking button
		chbs.setChecked("chbBtnRule", false);
	} else {
		chbs.setChecked("chbBtnRule", true);
	}
	refreshFeedbackHint();
	if (s.feedback.groupBased) {	// v0.16.0, DL: different feedback
		chbs.setChecked("chbFeedbackDifferent", false);
	} else {
		chbs.setChecked("chbFeedbackDifferent", true);
	}
	if (s.misc.splitScreen) {	// v0.16.1, DL: split-screen
		chbs.setChecked("chbSplitScreen", true);
	} else {
		chbs.setChecked("chbSplitScreen", false);
	}
		
	if (s.exercise.dragTimes==1) {	// v0.16.1, DL: drag times for drags
		chbs.setChecked("chbDragTimes", false);
	} else {
		chbs.setChecked("chbDragTimes", true);
	}
	
	// v6.4.1.3, DL: debug - neutral marking => no marking button, no feedback button, only instant marking
	if (s.feedback.neutral) {
		chbs.setChecked("chbNeutralFeedback", true);
		chbs.chbBtnMarking.enabled = false;
		chbs.chbBtnFeedback.enabled = false;
		chbs.setChecked("chbMarkingInstant", true);
		// v6.4.2.5 silent marking - always let the author choose sound effects
		//chbs.chbSoundEffects.enabled = true;
		chbs.chbMarkingInstant.enabled = false;
		chbs.chbMarkingDelayed.enabled = false;
		chbs.chbMarkingChoose.enabled = false;
		// v6.4.2.1 You have score based feedback now, dim that 
		chbs.chbFeedbackScoreBased.enabled = false;
	} else {
		chbs.setChecked("chbNeutralFeedback", false);
		//v6.4.3 No need to set enabled to true - this will be the default
		//chbs.chbBtnMarking.enabled = true;
		//chbs.chbBtnFeedback.enabled = true;
		//chbs.chbMarkingInstant.enabled = true;
		//chbs.chbMarkingDelayed.enabled = true;
		//chbs.chbMarkingChoose.enabled = true;
		// v6.4.2.1 You have score based feedback now, enable that 
		//chbs.chbFeedbackScoreBased.enabled = true;
	}
	// v6.4.1.2, DL: test mode in exercise
	//v6.4.3 Moved from before neutral feedback test
	if (s.marking.test) {
		chbs.setChecked("chbTestMode", true);
		chbs.chbBtnMarking.enabled = false;
		chbs.chbBtnFeedback.enabled = false;
		chbs.chbMarkingInstant.enabled = false;
		// v6.4.2.5 silent marking - always let the author choose sound effects
		//chbs.chbSoundEffects.enabled = false;
		chbs.chbMarkingDelayed.enabled = false;
		chbs.chbMarkingChoose.enabled = false;
		// v6.4.2.6 A test also stops you from setting score based feedback		
		chbs.chbFeedbackScoreBased.enabled = false;
	} else {
		chbs.setChecked("chbTestMode", false);
		//v6.4.3 No need to set enabled to true - this will be the default
		//chbs.chbMarkingInstant.enabled = true;
		//chbs.chbMarkingDelayed.enabled = true;
		//chbs.chbMarkingChoose.enabled = true;
	}
	// Moved from higher up
	if (s.feedback.scoreBased) {	// v0.16.0, DL: score-based feedback
		chbs.setChecked("chbFeedbackScoreBased", true);
		//v6.4.2.2 If you have score based feedback, the only option is delayed
		chbs.setChecked("chbMarkingDelayed", true);
		chbs.chbMarkingInstant.enabled = false;
		// v6.4.2.5 silent marking - always let the author choose sound effects
		//chbs.chbSoundEffects.enabled = false;
		chbs.chbMarkingDelayed.enabled = false;
		chbs.chbMarkingChoose.enabled = false;
	} else {
		chbs.setChecked("chbFeedbackScoreBased", false);
		// v6.4.2.6 AR None of the above is working - we are not resetting all the chbs to enabled when you start a new exercise
	}
}
setImageCategory = function(cat:String) { combos.setComboSelectedData("ImageCategory", cat); }
setAudioCheckBox = function(t:String, b:Boolean) : Void {
	switch (t) {
	case "Default" :
		chbs.chbInstructionsAudioDefault.selected = b;
		break;
	case "AutoPlay" :
		chbs.chbInstructionsAudioUpload.selected = b;
		break;
	case "Embed" :
		chbs.chbEmbedAudio.selected = b;
		break;
	case "AfterMarking" :
		chbs.chbAfterMarkingAudio.selected = b;
		break;
	case "Question" :
		//chbs.chbQuestionAudio.selected = b;
		//chbs.chbSplitScreenQuestionAudio.selected = b;
		if (!NNW.control.data.currentExercise.settings.misc.splitScreen) {
			var qNo = Number(txts.txtQuestionNo.text);
		} else {
			var qNo = Number(txts.txtSplitScreenQuestionNo.text);
		}
		//btns.lblQuestionAudio.text = (b) ? NNW.control.data.currentExercise.questionAudios[qNo-1].filename : "";
		//btns.lblSplitScreenQuestionAudio.text = (b) ? NNW.control.data.currentExercise.questionAudios[qNo-1].filename : "";
		chbs.chbQuestionAudioAfterMarking.enabled = b;
		if (b) {
			txts.txtQuestionAudio.text = NNW.control.data.currentExercise.questionAudios[qNo-1].filename;
			chbs.chbQuestionAudioAfterMarking.selected = (NNW.control.data.currentExercise.questionAudios[qNo-1]. mode=="2");
		} else {
			txts.txtQuestionAudio.text = "";
			chbs.chbQuestionAudioAfterMarking.selected = false;
		}
		//chbs.chbSplitScreenQuestionAudioAfterMarking.visible = b;
		//chbs.chbSplitScreenQuestionAudioAfterMarking.selected = (NNW.control.data.currentExercise.questionAudios[qNo-1]. mode=="2");
		break;
	}
}
setVideoCheckBox = function(t:String, b:Boolean) {
	switch (t) {
	case "Embed" :
		chbs.chbEmbedVideo.selected = b;
		break;
	case "Floating" :
		//chbs.chbFloatingVideo.selected = b;
		chbs.chbEmbedVideo.selected = b;
		break;
	}
}
setImagePosition = function(pos:String) {	// v0.16.0, DL: image position
	if (combos.getComboSelectedData("ImageCategory")=="NoGraphic") {
		enableImagePositionCheckBoxes(false);
	} else {
		// Yiu v6.5.1 Remove Banner
		// AR comment - what happens if an old exercise has a banner - what will happen to it?
		// Either should leave it as it is, or there should be an 'else' clause to catch it.
		_global.myTrace("setImagePosition to " + pos);
		if (pos=="top-right") {
			chbs.setChecked("chbImagePos0", true);
			chbs.setChecked("chbImagePos1", false);
			// Yiu v6.5.1 Remove Banner
			//chbs.setChecked("chbImagePos2", false);
			// End Yiu v6.5.1 Remove Banner
		} else if (pos=="top-left") {
			chbs.setChecked("chbImagePos0", false);
			chbs.setChecked("chbImagePos1", true);
			// Yiu v6.5.1 Remove Banner
			//chbs.setChecked("chbImagePos2", false);
			// End Yiu v6.5.1 Remove Banner
		} /*else {	// banner
			chbs.setChecked("chbImagePos0", false);
			chbs.setChecked("chbImagePos1", false);
			chbs.setChecked("chbImagePos2", true);
		}*/
		// End Yiu v6.5.1 Remove Banner
		enableImagePositionCheckBoxes(true);
	}
}

// v6.5.1 Yiu fixing video float problem
var s_bImageSelected:Boolean	= true;
// End v6.5.1 Yiu fixing video float problem
 
enableImagePositionCheckBoxes = function(b:Boolean, bDontTouchVideo:Boolean) {
	// if it's lite version, always false
	if (NNW.control._lite) {
		b = false;
	}
	
	chbs.chbImagePos0.enabled = b;
	chbs.chbImagePos1.enabled = b;
	
	// Yiu v6.5.1 Remove Banner
	//chbs.chbImagePos2.enabled = b;
	// End Yiu v6.5.1 Remove Banner
	
	// v0.16.1, DL: set video position
	
	// v6.5.1 Yiu fixing floating videoposition problem
	if(!bDontTouchVideo)
		enableVideoPositionCheckBoxes(!b);
	// End v6.5.1 Yiu fixing floating videoposition problem
	
	// if it's not enabled, set position to top-right
	if (!b) {
		chbs.setChecked("chbImagePos0", true);
		chbs.setChecked("chbImagePos1", false);
		// Yiu v6.5.1 Remove Banner
		//chbs.setChecked("chbImagePos2", false);
		// End Yiu v6.5.1 Remove Banner
	}
}
setVideoPosition = function(videos:Object) {	// v0.16.0, DL: image position
	var videoObj = videos[0];
	if (videoObj.filename!=undefined && videoObj.filename!="undefined" && videoObj.filename!="") {
		var pos = videoObj.position;
		_global.myTrace("setVideoPosition:pos=" + pos + " and mode=" + videoObj.mode);
		if (videoObj.mode=="1") { // embed
			switch (pos) {
			case "top-right" :
				chbs.setChecked("chbVideoPos0", true);
				chbs.setChecked("chbVideoPos1", false);
				// Yiu v6.5.1 Remove Banner
				//chbs.setChecked("chbVideoPos2", false);
				// End Yiu v6.5.1 Remove Banner
				chbs.setChecked("chbVideoPos3", false);
				break;
			case "top-left" :
				chbs.setChecked("chbVideoPos0", false);
				chbs.setChecked("chbVideoPos1", true);
				// Yiu v6.5.1 Remove Banner
				//chbs.setChecked("chbVideoPos2", false);
				// End Yiu v6.5.1 Remove Banner
				chbs.setChecked("chbVideoPos3", false);
				break;
			// Yiu v6.5.1 Remove Banner
			/*
			case "banner" :
				chbs.setChecked("chbVideoPos0", false);
				chbs.setChecked("chbVideoPos1", false);
				chbs.setChecked("chbVideoPos2", true);
				chbs.setChecked("chbVideoPos3", false);
				break;
			*/
			// End Yiu v6.5.1 Remove Banner
			}
			enableImagePositionCheckBoxes(false);
		} else { // floating
			_global.myTrace("setVideoPosition, in floating for chbs");
			chbs.setChecked("chbVideoPos0", false);
			chbs.setChecked("chbVideoPos1", false);
			// Yiu v6.5.1 Remove Banner
			//chbs.setChecked("chbVideoPos2", false);
			// Yiu v6.5.1 Remove Banner
			chbs.setChecked("chbVideoPos3", true);
			// v6.4.2 AR - seems I have to also do this, as well as setting the above.
			// It probably used to be done on returning videoEmbed
			
// v6.5.1 Yiu fixing video float problem
			if(!s_bImageSelected){
				enableVideoPositionCheckBoxes(true);
			}
// End v6.5.1 Yiu fixing video float problem
		}
	// no file, disable the position settings
	} else {
		enableVideoPositionCheckBoxes(false);
	}
}
// v6.4.2.7 Adding URLs
// This function sets the chb to reflect the mode of each URL. Whatever calls this should make sure
// that only one of the array items has mode=1 (toolbar button link)
setURLMode = function(URLs:Object) {
	chbs.setChecked("chbURLToolbar1", false);
	chbs.setChecked("chbURLToolbar2", false);
	chbs.setChecked("chbURLToolbar3", false);
	for (var i in URLs) {
		if (URLs[i].floating) {
			chbs.setChecked("chbURLToolbar" + URLs[i].idx, true);
		} else {
			chbs.setChecked("chbURLToolbar" + URLs[i].idx, false);
		}
	}
}

enableVideoPositionCheckBoxesPlus	= function() {
	var ex 								= NNW.control.data.currentExercise;
	var bSplitScreen:Boolean			= ex.settings.misc.splitScreen;
	var bHaveVideo:Boolean				= (txts.txtFilenameVideo.text != "");
	var bHavePhoto:Boolean				= (NNW.screens.combos.comboImageCategory.value!="NoGraphic");
	var bIsAnalyzeExercise:Boolean		= (ex.exerciseType=="Analyze");
	
	var bEnableVideoPosChb0:Boolean		= false;
	var bEnableVideoPosChb1:Boolean		= false;
	var bEnableVideoPosChb3:Boolean		= false;
		
	var bCheckVideoPosChb0:Boolean		= chbs.getChecked("chbVideoPos0");
	var bCheckVideoPosChb1:Boolean		= chbs.getChecked("chbVideoPos1");
	var bCheckVideoPosChb3:Boolean		= chbs.getChecked("chbVideoPos3");
	
	if(!bHaveVideo){
		bEnableVideoPosChb0		= false;
		bEnableVideoPosChb1		= false;
		bEnableVideoPosChb3		= false;
		
		bCheckVideoPosChb0		= false;
		bCheckVideoPosChb1		= false;
		bCheckVideoPosChb3		= true;
	}
	else if(bSplitScreen){
		if(bHavePhoto){
			bEnableVideoPosChb0		= false;
			bEnableVideoPosChb1		= false;
			bEnableVideoPosChb3		= true;
			
			bCheckVideoPosChb0		= false;
			bCheckVideoPosChb1		= false;
			bCheckVideoPosChb3		= true;
		} else {
			bEnableVideoPosChb0		= true;
			bEnableVideoPosChb1		= false;
			bEnableVideoPosChb3		= true;
			
			if(bCheckVideoPosChb1){
				bCheckVideoPosChb0		= false;
				bCheckVideoPosChb1		= false;
				bCheckVideoPosChb3		= true;	
			}
		}
	} else {
		if(bHavePhoto){
			bEnableVideoPosChb0		= false;
			bEnableVideoPosChb1		= false;
			bEnableVideoPosChb3		= true;
		
			bCheckVideoPosChb0		= false;
			bCheckVideoPosChb1		= false;
			bCheckVideoPosChb3		= true;	
		} else {
			bEnableVideoPosChb0		= true;
			bEnableVideoPosChb1		= true;
			bEnableVideoPosChb3		= true;
		}
	}
	
	chbs.chbVideoPos0.enabled		= bEnableVideoPosChb0;
	chbs.chbVideoPos1.enabled		= bEnableVideoPosChb1;
	chbs.chbVideoPos3.enabled		= bEnableVideoPosChb3;
	
	chbs.setChecked("chbVideoPos0", bCheckVideoPosChb0);
	chbs.setChecked("chbVideoPos1", bCheckVideoPosChb1);
	chbs.setChecked("chbVideoPos3", bCheckVideoPosChb3);
}

enableVideoPositionCheckBoxes = function(b:Boolean) {
	enableVideoPositionCheckBoxesPlus();
	return ;
	// v6.5 AR code after this point is no longer used
	/*
	// if it's lite version, always false
	if (NNW.control._lite) {
		b = false;
	}
	
	// if no video file set, disable all position settings
	if (txts.txtFilenameVideo.text == "") {
		b = false;
		chbs.chbVideoPos3.enabled = false;
		chbs.setChecked("chbVideoPos3", false);
	} else {
		// with a file, always allow floating
		chbs.chbVideoPos3.enabled = true;
	}

	// all layouts let you have top-right, although for split screen a nicer option might be banner, but little difference
	chbs.chbVideoPos0.enabled = b;
	// v6.4.1.4, DL: DEBUG - if it's split-screen, then no top-left or banner
	var ex = NNW.control.data.currentExercise;
	chbs.chbVideoPos1.enabled = (ex.exerciseType=="Analyze"||ex.settings.misc.splitScreen) ? false : b;
	// Yiu v6.5.1 Remove Banner
	//chbs.chbVideoPos2.enabled = (ex.exerciseType=="Analyze"||ex.settings.misc.splitScreen) ? false : b;
	// End Yiu v6.5.1 Remove Banner
	// if it's not enabled, set position to top-right
	if (!b) {
		//_global.myTrace("evpcb:set floating video");
		// v6.4.2 AR. No, set the default to be floating. Doesn't help.
		chbs.setChecked("chbVideoPos0", !chbs.getChecked("chbVideoPos3"));
		//chbs.setChecked("chbVideoPos0", false);
		chbs.setChecked("chbVideoPos1", false);
		// Yiu v6.5.1 Remove Banner
		//chbs.setChecked("chbVideoPos2", false);
		// End Yiu v6.5.1 Remove Banner
		//chbs.setChecked("chbVideoPos3", true); 
	}
	*/
}
fillInTrueFalseText = function(a:Array) : Void {
	// clear up txtTrue & txtFalse
	txts["txtTrue"].text = "";
	txts["txtFalse"].text = "";
	
	// retrieve the fields
	var f1 = a[0];
	var f2 = a[1];
	
	// v0.16.0, DL: no panels anymore
	/*var lblTrue = NNW.screens.chbs.chbTrue0.label;
	var lblFalse = NNW.screens.chbs.chbFalse0.label;
	var lblYes = NNW.screens.chbs.chbTrue1.label;
	var lblNo = NNW.screens.chbs.chbFalse1.label;
	if ((f1.value==lblTrue && f2.value==lblFalse) || (f1.value==lblFalse && f2.value==lblTrue)) {
		chbs.checkPanelCheckbox("chbTrue", "0");
		panels.highlightSelected("panel0");
	} else if ((f1.value==lblYes && f2.value==lblNo) || (f1.value==lblNo && f2.value==lblYes)) {
		chbs.checkPanelCheckbox("chbTrue", "1");
		panels.highlightSelected("panel1");
	} else if (f1.value!=undefined && f2.value!=undefined) {
		txts["txtTrue"].text = f1.value;
		txts["txtFalse"].text = f2.value;
		chbs.checkPanelCheckbox("chbTrue", "2");
		panels.highlightSelected("panel2");
	} else {
		chbs.checkPanelCheckbox("chbTrue", "0");
		panels.highlightSelected("panel0");
	}*/
	
	// set values
	var trueLabel = chbs.chbQuizOptions0.label;
	var falseLabel = chbs.chbQuizDummyOption.label;
	if ((f1.value==trueLabel && f2.value==falseLabel)||(f2.value==trueLabel && f1.value==falseLabel)) {
		chbs.setChecked("chbQuizOptions0", true);
		chbs.setChecked("chbQuizOptions1", false);
	} else if (f1.value!=undefined && f2.value!=undefined){
		txts.txtTrue.text = f1.value;
		txts.txtFalse.text = f2.value;
		chbs.setChecked("chbQuizOptions1", true);
		chbs.setChecked("chbQuizOptions0", false);
	} else {
		chbs.setChecked("chbQuizOptions0", true);
		chbs.setChecked("chbQuizOptions1", false);
	}
	
	// no panels now, so we just update the chosen option labels
	updateQuizOptionsLabels();
}
fillInQuestion = function(t:String) : Void {
	txts.txtQuestion.html = true;
	txts.txtQuestion.text = (t != undefined && t != "undefined") ? t : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	txts.txtQuestion.formerTextLength	= txts.txtQuestion.text.length;
	
	txts.txtSplitScreenQuestion.html = true;
	txts.txtSplitScreenQuestion.text = (t != undefined && t != "undefined") ? t : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	txts.txtSplitScreenQuestion.formerTextLength	= txts.txtSplitScreenQuestion.text.length;
}
fillInQuestionAudio = function(t:String, m:String) : Void {
	if (!NNW.control.data.currentExercise.settings.misc.splitScreen) {
		var qNo = Number(txts.txtQuestionNo.text);
	} else {
		var qNo = Number(txts.txtSplitScreenQuestionNo.text);
	}
	if (t!=undefined && t!=undefined && t!="") {
		//chbs.chbQuestionAudio.selected = true;
		//chbs.chbSplitScreenQuestionAudio.selected = true;
		//btns.lblQuestionAudio.text = NNW.control.data.currentExercise.questionAudios[qNo-1].filename;
		//btns.lblSplitScreenQuestionAudio.text = NNW.control.data.currentExercise.questionAudios[qNo-1].filename;
		txts.txtQuestionAudio.text = NNW.control.data.currentExercise.questionAudios[qNo-1].filename;
		chbs.chbQuestionAudioAfterMarking.enabled = true;
		chbs.chbQuestionAudioAfterMarking.selected = (m!="1");
		//chbs.chbSplitScreenQuestionAudioAfterMarking.visible = true;
		//chbs.chbSplitScreenQuestionAudioAfterMarking.selected = (m!="1");
	} else {
		//chbs.chbQuestionAudio.selected = false;
		//chbs.chbSplitScreenQuestionAudio.selected = false;
		//btns.lblQuestionAudio.text = "";
		//btns.lblSplitScreenQuestionAudio.text = "";
		txts.txtQuestionAudio.text = "";
		chbs.chbQuestionAudioAfterMarking.enabled = false;
		chbs.chbQuestionAudioAfterMarking.selected = false;
		//chbs.chbSplitScreenQuestionAudioAfterMarking.visible = false;
	}
}
fillInOptions = function(ex:Object, a:Array) : Void {
	if (ex.exerciseType=="Analyze") {
		var option = "RMCOption";
	} else {
		var option = "Option";
	}
	for (var i=0; i<4; i++) {
		txts["txt"+option+i].text = "";
		chbs.setChecked("chb"+option+i, false);
	}
	var noTrueOption = true;
	for (var i=0; i<a.length; i++) {
		var f = a[i];
		if (f.correct=="true" || f.correct=="false" || f.correct==true || f.correct==false) {
			txts["txt"+option+i.toString()].text = f.value;
			if (f.correct=="true"||f.correct==true) {
				chbs.setChecked("chb"+option+i, true);
				noTrueOption = false;
			}
		}
	}
	if (noTrueOption) {
		chbs.ensureAtLeastOneCheckboxIsChecked("chb"+option, random(4).toString());
	}
	// v0.15.0, DL: update options after filling in them - to save the randomly chosen correct options
	if (ex.exerciseType=="Analyze") {
		updateRMCOptions();
	} else {
		updateOptions();
	}
}
fillInTrueFalseOptions = function(a:Array) : Void {
	var f1 = a[0];
	var f2 = a[1];
	
	// v0.16.0, DL: set default to true instead of false
	if (f1.correct=="true") {	// the first answer is true
		if (f1.value==chbs.chbTrueOption.label) {
			chbs.setChecked("chbTrueOption", true);
			chbs.setChecked("chbFalseOption", false);
		} else if (f2.value==chbs.chbTrueOption.label) {
			chbs.setChecked("chbFalseOption", true);
			chbs.setChecked("chbTrueOption", false);
		} else {	// error, set default to true anyway
			chbs.setChecked("chbTrueOption", true);
			chbs.setChecked("chbFalseOption", false);
		}
	} else if (f2.correct=="true") {	// the second answer is true
		if (f1.value==chbs.chbTrueOption.label) {
			chbs.setChecked("chbTrueOption", false);
			chbs.setChecked("chbFalseOption", true);
		} else if (f2.value==chbs.chbTrueOption.label)  {
			chbs.setChecked("chbFalseOption", false);
			chbs.setChecked("chbTrueOption", true);
		} else {	// error, set default to true anyway
			chbs.setChecked("chbTrueOption", true);
			chbs.setChecked("chbFalseOption", false);
		}
	} else {	// no answer, set default to true
		chbs.setChecked("chbTrueOption", true);
		chbs.setChecked("chbFalseOption", false);
	}
	
	// v0.15.0, DL: update options after filling in them - to save the randomly chosen correct options
	updateTrueFalseOptions();
}
fillInOtherOptions = function(a:Array) : Void {
	/*for (var i=0; i<4; i++) {
		txts["txtOtherOption"+i].text = "";
		//chbs.setChecked("chbOtherOption"+i, false);
	}
	for (var i=0; i<a.length; i++) {
		var f = a[i+1];
		if (f.correct=="true" || f.correct=="false") {
			txts["txtOtherOption"+i].text = f.value;
			//chbs.setChecked("chbOtherOption"+i, (f.correct=="true"));
		}
	}*/
	/* v0.14.0, DL: fill in options list */
	var l = new Array();
	for (var i=0; i<a.length; i++) {
		var f = a[i+1];
		if (f.correct=="true" || f.correct=="false" || f.correct==true || f.correct==false) {
			l.push(f);
		}
	}
	clearOptionList();
	addOptionsToList(l);
}
/*fillInOtherAnswers = function(a:Array) : Void {
	for (var i=0; i<4; i++) {
		txts["txtOtherAnswer"+i].text = "";
	}
	for (var i=0; i<a.length; i++) {
		var f = a[i+1];
		if (f.correct=="true" || f.correct=="false") {
			txts["txtOtherAnswer"+i].text = f.value;
		}
	}
}*/
fillInFeedback = function(t:String) : Void {
	/* v0.12.0, DL: debug - acds should move back to first segment on filling */
	/*acds.acdFeedbackHint.selectedIndex = 0;
	acds.acd3Segments.selectedIndex = 0;
	acds.acdRMCFeedbackHint.selectedIndex = 0;
	acds.acd3Segments.child0.otherOptionsPane.vPosition = 0; // v0.12.1, DL*/
	acds.acdFH.child0.txtFeedback.vPosition = 0;
	acds.acdFH.child1.txtHint.vPosition = 0;
	
	/* v0.14.0, DL: debug - use my own accordions */
	acds.acdFH.setToFirstSegment();
	//acds.acdRMCFH.setToFirstSegment();
	
	/*acds.acdFeedbackHint.child0.txtFeedback.html = true;
	acds.acdFeedbackHint.child0.txtFeedback.text = (t!=undefined && t!="undefined") ? t : "";
	acds.acd3Segments.child1.txtFeedback.html = true;
	acds.acd3Segments.child1.txtFeedback.text = (t!=undefined && t!="undefined") ? t : "";
	acds.acdRMCFeedbackHint.child0.txtFeedback.html = true;
	acds.acdRMCFeedbackHint.child0.txtFeedback.text = (t!=undefined && t!="undefined") ? t : "";*/
	
	/* v0.14.0, DL: debug - use my own accordions */
	scnExercise.segment2.contentHolder.feedbackOnly_mc.txtFeedbackOnly.html = true;
	scnExercise.segment2.contentHolder.feedbackOnly_mc.txtFeedbackOnly.text = (t != undefined && t != "undefined") ? t : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	scnExercise.segment2.contentHolder.feedbackOnly_mc.txtFeedbackOnly.formerTextLength	= scnExercise.segment2.contentHolder.feedbackOnly_mc.txtFeedbackOnly.text.length;
		
	acds.acdFH.child0.txtFeedback.html = true;
	acds.acdFH.child0.txtFeedback.text = (t!=undefined && t!="undefined") ? t : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	acds.acdFH.child0.txtFeedback.formerTextLength	= acds.acdFH.child0.txtFeedback.text.length;
	
	//acds.acdRMCFH.child0.txtFeedback.html = true;
	//acds.acdRMCFH.child0.txtFeedback.text = (t!=undefined && t!="undefined") ? t : "";
}
fillInDifferentFeedbackForQuiz = function(t0:String, t1:String) : Void {	// v0.16.0, DL: different feedback
	acds.acdFFH.child0.txtFeedback.vPosition = 0;
	acds.acdFFH.child1.txtFeedback.vPosition = 0;
	acds.acdFFH.child2.txtHint.vPosition = 0;
	
	acds.acdFFH.setToFirstSegment();
	
	acds.acdFFH.child0.txtFeedback.html = true
	acds.acdFFH.child0.txtFeedback.text = (t0!=undefined && t0!="undefined") ? t0 : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	acds.acdFFH.child0.txtFeedback.formerTextLength	= acds.acdFFH.child0.txtFeedback.text.length;
	
	acds.acdFFH.child1.txtFeedback.html = true
	acds.acdFFH.child1.txtFeedback.text = (t1!=undefined && t1!="undefined") ? t1 : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	acds.acdFFH.child1.txtFeedback.formerTextLength	= acds.acdFFH.child1.txtFeedback.text.length;
}
fillInScoreBasedFeedback = function(t:String) : Void {	// v0.16.0, DL: score-based feedback
	txts.txtScoreBasedFeedback.html = true;
	txts.txtScoreBasedFeedback.text = (t!=undefined && t!="undefined") ? t : "";
}
fillInScores = function(a:Array) : Void {
	combos.clearCombo("Score");
	if (a!=undefined && a.length>0) {
		for (var i in a) {
			if (a[i]!=undefined && a[i].value!=undefined && a[i].value!="undefined") {
				combos.addNewScore(i.toString());
			}
		}
	} else {
		// add default (0%)
		combos.comboScore.addItem({label:"0", data:"0"});
	}
}
fillInHint = function(t:String) : Void {
	/*acds.acdFeedbackHint.child1.txtHint.html = true;
	acds.acdFeedbackHint.child1.txtHint.text = (t!=undefined && t!="undefined") ? t : "";
	acds.acd3Segments.child2.txtHint.html = true;
	acds.acd3Segments.child2.txtHint.text = (t!=undefined && t!="undefined") ? t : "";
	acds.acdRMCFeedbackHint.child1.txtHint.html = true;
	acds.acdRMCFeedbackHint.child1.txtHint.text = (t!=undefined && t!="undefined") ? t : "";*/
	
	/* v0.14.0, DL: debug - use my own accordions */
	acds.acdFH.child1.txtHint.html = true;
	acds.acdFH.child1.txtHint.text = (t!=undefined && t!="undefined") ? t : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	acds.acdFH.child1.txtHint.formerTextLength	= acds.acdFH.child1.txtHint.text.length;
	
	/* v0.16.0, DL: add hint only */
	scnExercise.segment2.contentHolder.hintOnly_mc.txtHintOnly.html = true;
	scnExercise.segment2.contentHolder.hintOnly_mc.txtHintOnly.text = (t!=undefined && t!="undefined") ? t : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	scnExercise.segment2.contentHolder.hintOnly_mc.txtHintOnly.formerTextLength	= scnExercise.segment2.contentHolder.hintOnly_mc.txtHintOnly.text.length;
		
	// v6.4.1.3, DL: debug - fill in hint for individual feedback hint
	acds.acdFFH.child2.txtHint.html = true;
	acds.acdFFH.child2.txtHint.text = (t!=undefined && t!="undefined") ? t : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	acds.acdFFH.child2.txtHint.formerTextLength	= acds.acdFFH.child2.txtHint.text.length;
	
	//acds.acdRMCFH.child1.txtHint.html = true;
	//acds.acdRMCFH.child1.txtHint.text = (t!=undefined && t!="undefined") ? t : "";
}
fillInText = function(t:String) : Void {
	txts.txtText.html = true;
	txts.txtText.text = (t != undefined && t != "undefined") ? t : "";
	// v6.5.1 Yiu prevent deleting gaps with typing words
	txts.txtText.formerTextLength	= txts.txtText.text.length;
	
	txts.txtSplitScreenText.html = true;	// v0.16.1, DL: change txtRMCText to txtSplitScreenText
	txts.txtSplitScreenText.text = (t != undefined && t != "undefined") ? t : "";	// v0.16.1, DL: change txtRMCText to txtSplitScreenText
	// v6.5.1 Yiu prevent deleting gaps with typing words
	txts.txtSplitScreenText.formerTextLength	= txts.txtSplitScreenText.text.length;
}
fillInCorrectTarget = function(a:Array) : Void {	// v0.16.0, DL: correct target for target spotting
	var f = a[0];
	if (f.correct=="false"||f.correct==false) {
		chbs.setChecked("chbCorrectTarget", false);
	} else {
		chbs.setChecked("chbCorrectTarget", true);
	}
}

// v6.5.1 Yiu new default gap length check box and slider 
fillInGapLength	= function(nGapLength:Number):Void
{
	textFormatting.gapLength	= nGapLength;
	slider.setValue(nGapLength);
}

refreshFeedbackHint = function() : Void {	// v0.16.0, DL: refresh feedback/hint box after setting score-based feedback
	//_global.myTrace("refreshFeedbackHint");
	var ex = NNW.control.data.currentExercise;
	var exType = ex.exerciseType;
	switch (exType) {
	// only question-based exercise types need to refresh
	case "MultipleChoice" :
	case "Quiz" :
		// v0.16.1, DL: split-screen exercise
		moveFormattingButtons(-100, 20);
			
		if (ex.settings.misc.splitScreen) {
			showFeedbackHint(true, 312.9);
			NNW.view.setVisible("btnUpgrade", false);
			scnExercise.segment2.contentHolder.answerIs_mc._x = 315;
			scnExercise.segment2.contentHolder.answerIs_mc._y = 85;
		} else {
			showFeedbackHint(true);
			NNW.view.setVisible("btnUpgrade", true);
			scnExercise.segment2.contentHolder.answerIs_mc._x = 0;
			scnExercise.segment2.contentHolder.answerIs_mc._y = 85;
		}
		break;
	case "DragAndDrop" :
	case "Stopgap" :
	// v6.4.3 Add item based drop down
	case "Stopdrop" : 
		// v0.16.1, DL: split-screen exercise
		if (ex.settings.misc.splitScreen) {
			showOptionsFeedbackHint(true, 312.9, undefined, -117, -87);
			moveFormattingButtons(12.6, 21);
			moveMakeField(-195.05, 221.55);
			NNW.view.setVisible("btnUpgrade", false);
		} else {
			showOptionsFeedbackHint(true);
			moveFormattingButtons( -94.4, 20);
			moveMakeField(-268.55, 171.55);
			//moveMakeField(-328.55, 121.55);
			NNW.view.setVisible("btnUpgrade", true);
		}
		break;
	case "Analyze" :
		showFeedbackHint(true, 312.9);
		
		if (ex.settings.misc.splitScreen) {
			moveFormattingButtons(-80, 21);
		} else {
			moveFormattingButtons(-194.4, 1);
		}
		break;
	case "Cloze":
	case "DragOn":
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
		moveMakeField(-268.55, 171.55);
		moveFormattingButtons( -94.4, 1);
		break;
	case "Dropdown":
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
		moveMakeField(-268.55, 171.55);
		moveFormattingButtons( -94.4, 1);
		break;
	case "Presentation":
		moveFormattingButtons(-94.4, 1);
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
		break;
	// others just set to false is ok
	case _global.g_strQuestionSpotterID:
		// v6.5.4.1 AR this doesn't react correctly to changing score based feedback
		showOptionsFeedbackHint(false);
		//showFeedbackHint(true);
		if (ex.settings.misc.splitScreen) {
			scnExercise.segment2.contentHolder.feedbackOnly_mc._x = 312.9;
			scnExercise.segment2.contentHolder.feedbackOnly_mc._y = 55;
			moveFormattingButtons(12.6, 1);
			moveMakeField(-425.05, 231.55);
			//showFeedbackHint(true, 312.9, 0);
		} else {
			scnExercise.segment2.contentHolder.feedbackOnly_mc._x = 20;
			scnExercise.segment2.contentHolder.feedbackOnly_mc._y = -50;
			moveFormattingButtons(-94.4, 21);
			moveMakeField(-238.55, 171.55);
		} 
		break; 
	case "TargetSpotting":
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
		moveFormattingButtons(-94.4, 1);
		break;
	case _global.g_strErrorCorrection:
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
		moveFormattingButtons(-94.4, 1);
		break;
	case "Proofreading":
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
		moveMakeField(-258.55, 151.55);
		moveFormattingButtons(-94.4, 1);
		break;
	case "Countdown":
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
		moveFormattingButtons( -94.4, 1);
		break;
	case _global.g_strBulletID:
		showOptionsFeedbackHint(false);
		if (ex.settings.misc.splitScreen) {
			moveFormattingButtons(12.6, 1);
		} else {
			moveFormattingButtons(-94.4, 21);
		} 
		break;
	default:
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
		break;
	}
}
showFeedbackHint = function(b:Boolean, x:Number, y:Number) : Void {
	//_global.myTrace("showFeedbackHint");
	var ex = NNW.control.data.currentExercise;
	var exType = ex.exerciseType;
	switch (exType) {
	case _global.g_strQuestionSpotterID: // v6.5.1 Yiu add new exercise type question spotter
		//scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = b;
		chbs.chbCorrectTarget.visible	= false;
		//NNW.view.setVisible("btnScoreBasedFeedback", false);
		scnExercise.segment2.contentHolder.feedbackOnly_mc._x = x;
		scnExercise.segment2.contentHolder.feedbackOnly_mc._y = y;
		//v6.5.4.1 AR This should also be a condition
		if (ex.settings.feedback.scoreBased) {
			_global.myTrace("showFeedbackHint, set to score based")
			scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = false;
			NNW.view.setVisible("btnScoreBasedFeedback", true);
		} else {
			_global.myTrace("showFeedbackHint, set to q based")
			scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = b;
			NNW.view.setVisible("btnScoreBasedFeedback", false);
		}
		break;
	case "TargetSpotting" :	// v0.16.0, DL: new exercise type
		chbs.chbCorrectTarget.visible = !(ex.settings.feedback.neutral);
		//v6.4.2.1 Try to add score based feedback to Target Spotting
		//scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = b;
		if (ex.settings.feedback.scoreBased) {
			scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = false;
			NNW.view.setVisible("btnScoreBasedFeedback", true);
		} else {
			scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = b;
			NNW.view.setVisible("btnScoreBasedFeedback", false);
		}
		
		scnExercise.segment2.contentHolder.feedbackOnly_mc._x = x? x : 0;
		scnExercise.segment2.contentHolder.feedbackOnly_mc._y = y? y : 50;
		break;
	case "Proofreading" :	// v0.16.0, DL: new exercise type
		chbs.chbCorrectTarget.visible = false;
		if (ex.settings.feedback.scoreBased) {
			scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = false;
			NNW.view.setVisible("btnScoreBasedFeedback", true);
		} else {
			scnExercise.segment2.contentHolder.feedbackOnly_mc._visible = b;
			NNW.view.setVisible("btnScoreBasedFeedback", false);
		}
		
		scnExercise.segment2.contentHolder.feedbackOnly_mc._x = x? x : 0;
		scnExercise.segment2.contentHolder.feedbackOnly_mc._y = y? y : 50;
		break;
	default :
		// v0.16.0, DL: show hint only if score-based feedback or not group-based
		if (!ex.settings.feedback.groupBased && exType=="Quiz") {	// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311, suspicious
			// we need to update the quizOptionsFeedbackHint labels
			acds.acdFFH.setLabels(_global.replace(btns.getLiteral("lblFeedbackFor"), "[x]", chbs.chbTrueOption.label), _global.replace(btns.getLiteral("lblFeedbackFor"), "[x]", chbs.chbFalseOption.label), btns.getLiteral("lblHint"));
			
			/* v0.14.0, DL: debug - use my own accordions */
			acds.acdFFH._visible = b;
			acds.acdFFH._y	= 320;
			scnExercise.segment2.contentHolder.quizOptionsFeedbackHint_mc._visible = b;
			
			// v0.16.0, DL: set hint only to invisible anyway
			scnExercise.segment2.contentHolder.hintOnly_mc._visible = false;
			acds.acdFH._visible = false;
			
			// v0.16.0, DL: reset tabIndexes
			txts.txtHintOnly.tabIndex = undefined;
			acds.acdFH.child0.txtFeedback.tabIndex = undefined;
			acds.acdFFH.child0.txtFeedback.tabIndex = 202;
			
			// v0.16.0, DL: invisible the add score-based feedback button on segment 1
			NNW.view.setVisible("btnScoreBasedFeedback", false);
			
		} else if (ex.settings.feedback.scoreBased || (!ex.settings.feedback.groupBased && (exType=="MultipleChoice"||exType=="Analyze"))) {
			scnExercise.segment2.contentHolder.hintOnly_mc._x = (x!=undefined) ? x : 0;
			scnExercise.segment2.contentHolder.hintOnly_mc._y = (y!=undefined) ? y : 334;
			
			scnExercise.segment2.contentHolder.hintOnly_mc._visible = b;
			
			// v0.16.0, DL: set feedback+hint to invisible anyway
			acds.acdFH._visible = false;
			acds.acdFFH._visible = false;
			
			// v0.16.0, DL: reset tabIndexes
			acds.acdFH.child0.txtFeedback.tabIndex = undefined;
			acds.acdFFH.child0.txtFeedback.tabIndex = undefined;
			if (exType=="MultipleChoice") {
				txts.txtHintOnly.tabIndex = 206;
			// v6.4.3 Item based drop down
			//} else if (exType=="Quiz"||exType=="Stopgap"||exType=="DragAndDrop") {
			} else if (exType=="Quiz"||exType=="Stopgap"||exType=="DragAndDrop"||exType=="Stopdrop") {
				txts.txtHintOnly.tabIndex = 202;
			} else if (exType=="Analyze") {
				txts.txtHintOnly.tabIndex = 207;
			}
			
			// v0.16.0, DL: show the add score-based feedback button on segment 1
			if (ex.settings.feedback.scoreBased) {
				NNW.view.setVisible("btnScoreBasedFeedback", true);
			} else {
				NNW.view.setVisible("btnScoreBasedFeedback", false);
			}
			
		} else {
			/* v0.15.0, DL: debug - now use only 1 set of accordion */
			acds.acdFH._x = (x!=undefined) ? x : 0;
			acds.acdFH._y = (y!=undefined) ? y : 204;
			/* v0.14.0, DL: debug - use my own accordions */
			acds.acdFH._visible = b;
			scnExercise.segment2.contentHolder.feedbackhint_mc._visible = b;
			
			// v0.16.0, DL: set hint only to invisible anyway
			scnExercise.segment2.contentHolder.hintOnly_mc._visible = false;
			acds.acdFFH._visible = false;
			
			// v0.16.0, DL: reset tabIndexes
			txts.txtHintOnly.tabIndex = undefined;
			acds.acdFFH.child0.txtFeedback.tabIndex = undefined;
			if (exType=="MultipleChoice") {
				acds.acdFH.child0.txtFeedback.tabIndex = 206;
			// v6.4.3 Item based drop down
			//} else if (exType=="Quiz"||exType=="Stopgap"||exType=="DragAndDrop") {
			} else if (exType=="Quiz"||exType=="Stopgap"||exType=="DragAndDrop"||exType=="Stopdrop"||
						exType==_global.g_strQuestionSpotterID	// v6.5.1 Yiu add bew exercise type question spotter
						) {
				acds.acdFH.child0.txtFeedback.tabIndex = 202;
			} else if (exType=="Analyze") {
				acds.acdFH.child0.txtFeedback.tabIndex = 207;
			}
			
			// v0.16.0, DL: invisible the add score-based feedback button on segment 1
			NNW.view.setVisible("btnScoreBasedFeedback", false);
		}
		break;
	}
}

setFeedbackHintPosForQuiz = function(fhx:Number, fhy:Number) : Void {
	//scnExercise.segment2.contentHolder.feedbackhint_mc._visible = b;
	//scnExercise.segment2.contentHolder.feedbackhint_mc._x 		= (fhx!=undefined) ? fhx : 0;
	//scnExercise.segment2.contentHolder.feedbackhint_mc._y 		= (fhy!=undefined) ? fhy : 234;
	acds.acdFH._x = fhx;
	acds.acdFH._y = fhy;
	//scnExercise.segment2.contentHolder.feedbackhint_mc._x 		= fhx;
	//scnExercise.segment2.contentHolder.feedbackhint_mc._y 		= fhy;
}

// v6.5.1 Yiu fixing question based drop
visibleFeedbackOnlyMcIfADropPresent	= function():Void
{
	var ex = NNW.control.data.currentExercise;
	var splitScreen = ex.settings.misc.splitScreen;
	
	if (textFormatting.checkIfThereIsADrop())
	{
		if(splitScreen){
			showFeedbackHint(true, 312.9, 221.3);
		} else {
			showFeedbackHint(true);
		}
	} else {
		showFeedbackHint(false);
	}
}

visibleFeedbackAndHintIfADropPresent	= function():Void{
	var ex = NNW.control.data.currentExercise;
	var splitScreen = ex.settings.misc.splitScreen;
	
	if (textFormatting.checkIfThereIsADrop())
	{
		if(splitScreen){
			showFeedbackHint(true, 312.9, 221.3);
			showOptionsFeedbackHint(true, 312.9, undefined, -117, -87);
		} else {
			showFeedbackHint(true);
			showOptionsFeedbackHint(true);
		}
	} else {
		showFeedbackHint(false);
		showOptionsFeedbackHint(false);
	}
}
// v6.5.4.1 AR a version for target spotting (no hints)
visibleFeedbackIfADropPresent	= function():Void{
	//_global.myTrace("visibleFeedbackIfADropPresent");
	var ex = NNW.control.data.currentExercise;
	var splitScreen = ex.settings.misc.splitScreen;
	
	if (textFormatting.checkIfThereIsADrop())
	{
		if(splitScreen){
			showFeedbackHint(true, 312.9, 221.3);
		} else {
			showFeedbackHint(true);
		}
	} else {
		showFeedbackHint(false);
	}
}

// End v6.5.1 Yiu fixing question based drop

showOptionsFeedbackHint = function(b:Boolean, fhx:Number, fhy:Number, ox:Number, oy:Number) : Void {
	//_global.myTrace("showOptionsFeedbackHint");
	// v0.16.0, DL: do not show quizOptionsFeedbackHint
	scnExercise.segment2.contentHolder.quizOptionsFeedbackHint_mc._visible = false;
	
	// v0.16.1, DL: move options list according to the given x & y positions
	scnExercise.segment2.contentHolder.otherOptions_mc._x = (ox!=undefined) ? ox : 40;
	scnExercise.segment2.contentHolder.otherOptions_mc._y = (oy!=undefined) ? oy : 85;
	
	// v0.16.0, DL: show hint only if score-based feedback
	var ex = NNW.control.data.currentExercise;
	if (ex.settings.feedback.scoreBased) {
		// show hint only
		scnExercise.segment2.contentHolder.hintOnly_mc._x = (fhx!=undefined) ? fhx : 0;
		scnExercise.segment2.contentHolder.hintOnly_mc._y = (fhy!=undefined) ? fhy : 334;
		scnExercise.segment2.contentHolder.hintOnly_mc._visible = b;
		// show options list
		scnExercise.segment2.contentHolder.otherOptions_mc._visible = b;
		
		// v0.16.0, DL: set feedback+hint to invisible anyway
		acds.acdFH._visible = false;
		
		// v0.16.1, DL: debug - should set visibility offeedback button according to setting!
		NNW.view.setVisible("btnScoreBasedFeedback", true);
	} else {
		/* v0.14.0, DL: debug - use my own accordions */
		acds.acdFH._x = (fhx!=undefined) ? fhx : 10;
		acds.acdFH._y = (fhy!=undefined) ? fhy : 204;
		acds.acdFH._visible = b;
		scnExercise.segment2.contentHolder.feedbackhint_mc._visible = b;
		/* v0.14.0, DL: use options list */
		scnExercise.segment2.contentHolder.otherOptions_mc._visible = b;
		
		// v0.16.0, DL: set hint only to invisible anyway
		scnExercise.segment2.contentHolder.hintOnly_mc._visible = false;
		
		// v0.16.1, DL: debug - should set visibility of feedback button according to setting!
		NNW.view.setVisible("btnScoreBasedFeedback", false);
	}
}
resetQuestionNo = function() : Void {
	nsps.setToOne();
	txts.txtQuestionNo.text = "1";		// v0.12.0, DL
	txts.txtSplitScreenQuestionNo.text = "1";	// v0.12.0, DL
	btns.lblQNo.text = "1";				// v0.12.0, DL
	btns.lblSplitScreenQNo.text = "1";			// v0.12.0, DL
}
changeQuestionSegment = function() : Void {
	var showNames = new Array();
	var hideNames = new Array();
	
	// v0.16.1, DL: no need to pass exercise type as parameter
	var ex = NNW.control.data.currentExercise;
	var exType = ex.exerciseType;
	var splitScreen = ex.settings.misc.splitScreen;
	
	if (!splitScreen) {
		scnExercise.segment2.contentHolder.questionMM_mc._x = 0;
		scnExercise.segment2.contentHolder.questionMM_mc._y = 20;
	} else {
		scnExercise.segment2.contentHolder.questionMM_mc._x = 81;
		scnExercise.segment2.contentHolder.questionMM_mc._y = 59;
	}
	
	// v 6.5.0.1 Yiu bigger screen mc position modified
	scnExercise.segment2.contentHolder.txtText._x					= 10;
	scnExercise.segment2.contentHolder.question_mc._y 				= 20;
	scnExercise.segment2.contentHolder.splitScreenQuestion_mc._y	= 20;
	
	if (!splitScreen) {
		scnExercise.segment2.contentHolder.options_mc._y 		= 70;
	} else {
		scnExercise.segment2.contentHolder.readingMC_mc._y 		= 70;
	}
	scnExercise.segment2.contentHolder.feedbackhint_mc._y 	= 120;
	scnExercise.segment2.contentHolder.formatting_mc._y 	= 10;
	// End v 6.5.0.1 Yiu bigger screen mc position modified
	
	switch (exType) {
	case "MultipleChoice" :
		showNames.push("question_mc");
		showNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		showNames.push("options_mc");
		//showNames.push("feedbackhint_mc");
		hideNames.push("otherOptions_mc");	//hideNames.push("optionsfeedbackhint_mc");
		hideNames.push("text_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		//hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	case "Quiz" :
		// v6.5.3.5 Yiu add split screen for Quiz, bug ID 1311
		showNames.push("questionMM_mc");
		showNames.push("quizOptions_mc");
		showNames.push("answerIs_mc");
		showNames.push("formatting_mc");
		
		hideNames.push("otherOptions_mc");
		hideNames.push("options_mc");
		hideNames.push("text_mc");
		hideNames.push("feedbackOnly_mc");
		hideNames.push("readingMC_mc");

		if (splitScreen) {
			hideNames.push("question_mc");
			showNames.push("splitScreenText_mc");
			showNames.push("splitScreenQuestion_mc");
			
			scnExercise.segment2.contentHolder.formatting_mc._x = 90;
			scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		} else {
			showNames.push("question_mc");
			hideNames.push("splitScreenText_mc");
			hideNames.push("splitScreenQuestion_mc");
				
			scnExercise.segment2.contentHolder.formatting_mc._x = 0;
			scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		}
		// end v6.5.3.5 Yiu add split screen for Quiz, bug ID 1311
		break;
	case "DragAndDrop" :	// question-based
		showNames.push("question_mc");
		showNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		//showNames.push("feedbackhint_mc");
		//hideNames.push("otherOptions_mc");	//hideNames.push("optionsfeedbackhint_mc");
		showNames.push("otherOptions_mc");
		hideNames.push("options_mc");
		hideNames.push("text_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		//hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	// v6.4.3 Item based drop down
	case "Stopdrop" :
	case "Stopgap" :	// question-based
		hideNames.push("options_mc");
		showNames.push("otherOptions_mc");
		//showNames.push("feedbackhint_mc");	// v0.14.0, DL: show feedback/hint accordion
		hideNames.push("text_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		
		if (splitScreen) {
			hideNames.push("question_mc");
			showNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
			showNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
			showNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		} else {
			showNames.push("question_mc");
			showNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
			hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
			hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		}
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		//hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	case "DragOn" :
	case "Cloze" :
	case "Dropdown" :
		showNames.push("text_mc");
		showNames.push("feedbackhint_mc");
		showNames.push("otherOptions_mc");	//showNames.push("optionsfeedbackhint_mc");
		hideNames.push("question_mc");
		hideNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		hideNames.push("options_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	case "Countdown" :
		showNames.push("text_mc");
		showNames.push("feedbackhint_mc");
		hideNames.push("otherOptions_mc")	//hideNames.push("optionsfeedbackhint_mc");
		hideNames.push("question_mc");
		hideNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		hideNames.push("options_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	case "Analyze" :
		hideNames.push("question_mc");
		showNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		hideNames.push("options_mc");
		//showNames.push("feedbackhint_mc");	// v0.15.0, DL: use global feedback/hint accordion
		hideNames.push("otherOptions_mc");	//hideNames.push("optionsfeedbackhint_mc");
		hideNames.push("text_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		showNames.push("readingMC_mc");
		showNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		showNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 90;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		//hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	case "TargetSpotting" :	// v0.16.0, DL: new exercise type
		showNames.push("text_mc");

		hideNames.push("feedbackhint_mc");
		hideNames.push("otherOptions_mc");	//showNames.push("optionsfeedbackhint_mc");
		hideNames.push("question_mc");
		hideNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		hideNames.push("options_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		hideNames.push("quizOptionsFeedbackHint_mc");
		break;
	case "Proofreading" :	// v0.16.0, DL: new exercise type
		showNames.push("text_mc");		
		hideNames.push("feedbackhint_mc");
		hideNames.push("otherOptions_mc");	//showNames.push("optionsfeedbackhint_mc");
		hideNames.push("question_mc");
		hideNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		hideNames.push("options_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		hideNames.push("quizOptionsFeedbackHint_mc");
		break;
	case _global.g_strQuestionSpotterID:	// v6.5.1 Yiu add bew exercise type question spotter
		hideNames.push("options_mc");
		hideNames.push("otherOptions_mc");
		hideNames.push("feedbackhint_mc");	// v0.14.0, DL: show feedback/hint accordion
		hideNames.push("text_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		showNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		
		if (splitScreen) {
			hideNames.push("question_mc");
			showNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
			showNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		} else {
			showNames.push("question_mc");
			hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
			hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		}
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		showNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		break;
	case _global.g_strBulletID:	// v6.5.1 Yiu add bew exercise type question spotter
		hideNames.push("text_mc");
		hideNames.push("options_mc");
		hideNames.push("feedbackhint_mc");
		hideNames.push("otherOptions_mc");	//hideNames.push("optionsfeedbackhint_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		showNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		
		//hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		//hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		//hideNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		
		if (splitScreen) {
			hideNames.push("question_mc");
			showNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
			showNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		} else {
			showNames.push("question_mc");
			hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
			hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		}
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	case _global.g_strErrorCorrection:	// v6.5.1 Yiu add bew exercise type error correction
		showNames.push("text_mc");
		showNames.push("feedbackhint_mc");
		showNames.push("otherOptions_mc");
		hideNames.push("question_mc");
		hideNames.push("questionMM_mc");
		hideNames.push("options_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		hideNames.push("splitScreenText_mc");
		hideNames.push("splitScreenQuestion_mc");
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	case "Presentation" :
	default :
		showNames.push("text_mc");
		hideNames.push("question_mc");
		hideNames.push("questionMM_mc");	// v6.4.0.1, DL: question multimedia
		hideNames.push("options_mc");
		hideNames.push("feedbackhint_mc");
		hideNames.push("otherOptions_mc");	//hideNames.push("optionsfeedbackhint_mc");
		hideNames.push("quizOptions_mc");
		hideNames.push("answerIs_mc");
		hideNames.push("readingMC_mc");
		hideNames.push("splitScreenText_mc");	// v0.16.1, DL: split screen text for other ex types
		hideNames.push("splitScreenQuestion_mc");	// v0.16.1, DL: split screen question for other ex types
		
		showNames.push("formatting_mc");
		scnExercise.segment2.contentHolder.formatting_mc._x = 0;
		scnExercise.segment2.contentHolder.formatting_mc._y = 0;
		
		hideNames.push("feedbackOnly_mc");	// v0.16.0, DL: feedback only (without hint)
		hideNames.push("hintOnly_mc");	// v0.16.0, DL: hint only
		break;
	}
	scnExercise.changeSegment(1, showNames, hideNames);
	scnExercise.changeSegment(2, showNames, hideNames);
}
extractTextFromCDATA = function(s:String) : String {
	d1_txt.htmlText = "";
	d2_txt.htmlText = "";
	d1_txt.htmlText = s;
	d2_txt.htmlText = d1_txt.text;
	return d2_txt.text;
}
showStep1 = function(b:Boolean) : Void { scnExercise.showTab1(b); }
showStep2 = function(b:Boolean) : Void { scnExercise.showTab2(b); }
showStep3 = function(b:Boolean) : Void { scnExercise.showTab3(b); }
showMakeFieldButton = function(b:Boolean) : Void {
	btns.btnMakeField.visible = b;
	btns.btnClearField.visible = b;
	//btns.lblMakeField.visible = b;
}
showSlider = function(b:Boolean) : Void {
	slider._visible = b;
}

// v6.5.1 Yiu invisible the slide bar when uniform gap bar
showSliderAndLabel	= function(b:Boolean) : Void
{
	showSlider(b);
	btns.lblMakeField.visible	= b;
}

/* update things on the screen before getting out */
updateWholeExercise = function() : Void {
	NNW.control.updateExerciseCaption(txts.txtExerciseName.text);
	
	// v6.5.1 original instruction text box is deleted, replaced by txtTitle2
	//NNW.control.updateExerciseTitle(txts.txtTitle.text);
	NNW.control.updateExerciseTitle(txts.txtTitle2.text);
	// End v6.5.1 original instruction text box is deleted, replaced by txtTitle2
	
	var ex = NNW.control.data.currentExercise;
	var exType = ex.exerciseType;
	var splitScreen = ex.settings.misc.splitScreen;
	
	// v0.16.1, DL: check splitscreen to see which question no. to take
	//var qNo = Number(txts.txtQuestionNo.text); // v0.12.0, DL: nsps.nspQuestionNo.value;
	var qNo = (splitScreen) ? Number(txts.txtSplitScreenQuestionNo.text) : Number(txts.txtQuestionNo.text);
	
	switch (exType) {
	case "MultipleChoice" :
		NNW.control.updateExercise("question", qNo, txts.txtQuestion.text);
		/* v0.15.0, DL: centralize updating of options */
		/*NNW.control.updateExercise("option", qNo, txts.txtOption0.text, 0, chbs.getChecked("chbOption0"));
		NNW.control.updateExercise("option", qNo, txts.txtOption1.text, 1, chbs.getChecked("chbOption1"));
		NNW.control.updateExercise("option", qNo, txts.txtOption2.text, 2, chbs.getChecked("chbOption2"));
		NNW.control.updateExercise("option", qNo, txts.txtOption3.text, 3, chbs.getChecked("chbOption3"));*/
		updateOptions();

		/* v0.14.0, DL: debug - use my own accordions */
		/*NNW.control.updateExercise("feedback", qNo, acds.acdFeedbackHint.child0.txtFeedback.text);
		NNW.control.updateExercise("hint", qNo, acds.acdFeedbackHint.child1.txtHint.text);*/
		if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		} else {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		}
		break;
	case "Quiz" :
		// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311, adding split screen
		if (splitScreen) {
			NNW.control.updateExercise("question", qNo, txts.txtSplitScreenQuestion.text);
			NNW.control.updateExerciseText(txts.txtSplitScreenText.text);
		} else {
			NNW.control.updateExercise("question", qNo, txts.txtQuestion.text);
		}
	
		updateTrueFalseOptions();
		if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		} else if (ex.settings.feedback.groupBased) {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		} else {
			NNW.control.updateExercise("differentFeedback", qNo, acds.acdFFH.child0.txtFeedback.text, 0);
			NNW.control.updateExercise("differentFeedback", qNo, acds.acdFFH.child1.txtFeedback.text, 1);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		}
			
		/*	from Analysis
		NNW.control.updateExerciseText(txts.txtSplitScreenText.text);
		NNW.control.updateExercise("question", qNo, txts.txtSplitScreenQuestion.text);
		updateRMCOptions();
		if (acds.acdFH._visible) {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		} else if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		}
		*/
		
		/*	// v6.5.4.2 Yiu commented origin, add split screen for Quiz, bug ID 1311
		NNW.control.updateExercise("question", qNo, txts.txtQuestion.text);
		updateTrueFalseOptions();
		if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		} else if (ex.settings.feedback.groupBased) {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		} else {
			NNW.control.updateExercise("differentFeedback", qNo, acds.acdFFH.child0.txtFeedback.text, 0);
			NNW.control.updateExercise("differentFeedback", qNo, acds.acdFFH.child1.txtFeedback.text, 1);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		}
		
		 * */
		// End v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311
		break;
	case "DragAndDrop" :
	case "Stopgap" :
	// v6.4.3 Item based drop down
		/*NNW.control.updateExercise("answer", qNo, txts.txtOtherAnswer0.text, 0, true);
		NNW.control.updateExercise("answer", qNo, txts.txtOtherAnswer1.text, 1, true);
		NNW.control.updateExercise("answer", qNo, txts.txtOtherAnswer2.text, 2, true);
		NNW.control.updateExercise("answer", qNo, txts.txtOtherAnswer3.text, 3, true);*/
		/* v0.14.0, DL: use dgOption list instead of TextInputs */
		/*NNW.control.updateExercise("answer", qNo, txts.txtOtherOption0.text, 0, true);
		NNW.control.updateExercise("answer", qNo, txts.txtOtherOption1.text, 1, true);
		NNW.control.updateExercise("answer", qNo, txts.txtOtherOption2.text, 2, true);
		NNW.control.updateExercise("answer", qNo, txts.txtOtherOption3.text, 3, true);*/
		/* v0.14.0, DL: debug - use my own accordions */
		/*NNW.control.updateExercise("feedback", qNo, acds.acd3Segments.child1.txtFeedback.text);
		NNW.control.updateExercise("hint", qNo, acds.acd3Segments.child2.txtHint.text);*/
		/* v0.16.1, DL: split-screen text */
		// for non-split-screen, update txtQuestion
		// for split-screen, update txtSplitScreenQuestion
		// get the qNo before updating anything
		if (splitScreen) {
			NNW.control.updateExercise("question", qNo, txts.txtSplitScreenQuestion.text);
			NNW.control.updateExerciseText(txts.txtSplitScreenText.text);
		} else {
			NNW.control.updateExercise("question", qNo, txts.txtQuestion.text);
		}
		NNW.control.data.currentExercise.fieldManager.removeAllAnswers(qNo);
		for (var i=0; i<dgs.dgOption.length; i++) {
			// v6.4.2.5 Drag fields can have alt answers being true or false
			// v6.4.3 Item based drop down
			//if (exType.toLowerCase().indexOf("drag")>=0) {
			// This line copied from dropdown, don't know why it wasn't in this section anyway.
			// Well, if you put it in, then it removes answers that are not ticked, that is why!
			//NNW.control.data.currentExercise.fieldManager.removeAllAnswers(qNo);
			if (exType.toLowerCase().indexOf("drag")>=0 || exType=="Stopdrop") {
				NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, getOptionCorrectnessAtIndex(i));
			} else {
				NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, true);
			}
		}
		if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		} else {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		}
		break;
	// v6.5.1 Yiu fixing add alt before ans problem
	case "Stopdrop" :
		//qNo = NNW.screens.textFormatting.activeFieldNo;
		if (splitScreen) {
			NNW.control.updateExercise("question", qNo, txts.txtSplitScreenQuestion.text);
			NNW.control.updateExerciseText(txts.txtSplitScreenText.text);
		} else {
			NNW.control.updateExercise("question", qNo, txts.txtQuestion.text);
		}
		NNW.control.data.currentExercise.fieldManager.removeAllAnswers(qNo);
		for (var i=0; i<dgs.dgOption.length; i++) {
			if (exType.toLowerCase().indexOf("drag")>=0 || exType=="Stopdrop") {
				NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, getOptionCorrectnessAtIndex(i));
			} else {
				NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, true);
			}
		}
		
		NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
		NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		
		break;
	// End v6.5.1 Yiu fixing add alt before ans problem
	/*case "DragAndDrop" :
		NNW.control.updateExercise("question", qNo, txts.txtQuestion.text);
		//v0.14.0, DL: debug - use my own accordions
		//NNW.control.updateExercise("feedback", qNo, acds.acdFeedbackHint.child0.txtFeedback.text);
		//NNW.control.updateExercise("hint", qNo, acds.acdFeedbackHint.child1.txtHint.text);
		if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		} else {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		}
		break;*/
	case "Dropdown" :
		qNo = NNW.screens.textFormatting.activeFieldNo;
		//_global.myTrace("DEBUG - now updating #"+qNo);
		NNW.control.updateExerciseText(txts.txtText.text);
		/*if (acds.acd3Segments._visible) {
			NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txts.txtOtherOption0.text, 0, false);
			NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txts.txtOtherOption1.text, 1, false);
			NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txts.txtOtherOption2.text, 2, false);
			NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txts.txtOtherOption3.text, 3, false);
			NNW.control.updateExercise("feedback", NNW.screens.textFormatting.activeFieldNo, acds.acd3Segments.child1.txtFeedback.text);
			NNW.control.updateExercise("hint", NNW.screens.textFormatting.activeFieldNo, acds.acd3Segments.child2.txtHint.text);
		}*/
		/* v0.14.0, DL: use dgOption list instead of TextInputs */
		if (scnExercise.segment2.contentHolder.otherOptions_mc._visible) {
			NNW.control.data.currentExercise.fieldManager.removeAllAnswers(qNo);
			for (var i=0; i<dgs.dgOption.length; i++) {
				// v0.16.1, DL: set correctness by user
				//NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, false);
				NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, getOptionCorrectnessAtIndex(i));
			}
		}
		/* v0.14.0, DL: debug - use my own accordions */
		if (acds.acdFH._visible) {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		} else if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		}
		break;
	case "DragOn" :
	case "Cloze" :
		qNo = NNW.screens.textFormatting.activeFieldNo;
		NNW.control.updateExerciseText(txts.txtText.text);
		/*if (acds.acd3Segments._visible) {
			NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txts.txtOtherOption0.text, 0, true);
			NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txts.txtOtherOption1.text, 1, true);
			NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txts.txtOtherOption2.text, 2, true);
			NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txts.txtOtherOption3.text, 3, true);
			NNW.control.updateExercise("feedback", NNW.screens.textFormatting.activeFieldNo, acds.acd3Segments.child1.txtFeedback.text);
			NNW.control.updateExercise("hint", NNW.screens.textFormatting.activeFieldNo, acds.acd3Segments.child2.txtHint.text);
		}*/
		/* v0.14.0, DL: use dgOption list instead of TextInputs */
		if (scnExercise.segment2.contentHolder.otherOptions_mc._visible) {
			NNW.control.data.currentExercise.fieldManager.removeAllAnswers(qNo);
			for (var i=0; i<dgs.dgOption.length; i++) {
				// v6.4.2.5 Drag fields can have alt answers being true or false>
				if (exType.toLowerCase().indexOf("drag")>=0) {
					NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, getOptionCorrectnessAtIndex(i));
				} else {
					NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, true);
				}
			}
		}
		/* v0.14.0, DL: debug - use my own accordions */
		if (acds.acdFH._visible) {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		} else if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		}
		break;
	/*case "DragOn" :
		qNo = NNW.screens.textFormatting.activeFieldNo;
		NNW.control.updateExerciseText(txts.txtText.text);
		//if (acds.acdFeedbackHint._visible) {
		//	NNW.control.updateExercise("feedback", NNW.screens.textFormatting.activeFieldNo, acds.acdFeedbackHint.child0.txtFeedback.text);
		//	NNW.control.updateExercise("hint", NNW.screens.textFormatting.activeFieldNo, acds.acdFeedbackHint.child1.txtHint.text);
		//}
		// v0.14.0, DL: debug - use my own accordions
		if (acds.acdFH._visible) {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		} else if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		}
		break;*/
	case "Analyze" :
		//qNo = Number(txts.txtSplitScreenQuestionNo.text); //v0.12.0, DL: nsps.nspRMCQuestionNo.value;
		NNW.control.updateExerciseText(txts.txtSplitScreenText.text);	// v0.16.1, DL: change txtRMCText to txtSplitScreenText
		NNW.control.updateExercise("question", qNo, txts.txtSplitScreenQuestion.text);
		/* v0.15.0, DL: centralize updating of options */
		/*NNW.control.updateExercise("option", qNo, txts.txtRMCOption0.text, 0, chbs.getChecked("chbRMCOption0"));
		NNW.control.updateExercise("option", qNo, txts.txtRMCOption1.text, 1, chbs.getChecked("chbRMCOption1"));
		NNW.control.updateExercise("option", qNo, txts.txtRMCOption2.text, 2, chbs.getChecked("chbRMCOption2"));
		NNW.control.updateExercise("option", qNo, txts.txtRMCOption3.text, 3, chbs.getChecked("chbRMCOption3"));*/
		updateRMCOptions();
		//NNW.control.updateExercise("feedback", qNo, acds.acdRMCFeedbackHint.child0.txtFeedback.text);
		//NNW.control.updateExercise("hint", qNo, acds.acdRMCFeedbackHint.child1.txtHint.text);
		/* v0.14.0, DL: debug - use my own accordions */
		if (acds.acdFH._visible) {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		} else if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
			NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		}
		//NNW.control.updateExercise("feedback", qNo, acds.acdRMCFH.child0.txtFeedback.text);
		//NNW.control.updateExercise("hint", qNo, acds.acdRMCFH.child1.txtHint.text);
		break;
	case "TargetSpotting" :	// v0.16.0, DL: new exercise type
	case "Proofreading" :	// v0.16.0, DL: new exercise type
		qNo = NNW.screens.textFormatting.activeFieldNo;
		NNW.control.updateExerciseText(txts.txtText.text);
		if (scnExercise.segment2.contentHolder.feedbackOnly_mc._visible) {
			NNW.control.updateExercise("feedback", qNo, scnExercise.segment2.contentHolder.feedbackOnly_mc.txtFeedbackOnly.text);
		}
		break;
	case "Countdown" :
	case "Presentation" :
		NNW.control.updateExerciseText(txts.txtText.text);
		break;
	case _global.g_strQuestionSpotterID:	// v6.5.1 Yiu add bew exercise type question spotter
		var qNo = Number(txts.txtQuestionNo.text);
		if (splitScreen) {
			NNW.control.updateExercise("question", qNo, txts.txtSplitScreenQuestion.text);
			NNW.control.updateExerciseText(txts.txtSplitScreenText.text);
		} else {
			NNW.control.updateExercise("question", qNo, txts.txtQuestion.text);
		}
		//NNW.control.data.currentExercise.fieldManager.removeAllAnswers(qNo);
		
		//if (scnExercise.segment2.contentHolder.feedbackOnly_mc._visible) {
			NNW.control.updateExercise("feedback", qNo, scnExercise.segment2.contentHolder.feedbackOnly_mc.txtFeedbackOnly.text);
		//}
		break;
	case _global.g_strBulletID:	// v6.5.1 Yiu add bew exercise type question spotter
		if (splitScreen) {
			NNW.control.updateExercise("question", qNo, txts.txtSplitScreenQuestion.text);
			NNW.control.updateExerciseText(txts.txtSplitScreenText.text);
		} else {
			NNW.control.updateExercise("question", qNo, txts.txtQuestion.text);
		}
		break;
	case _global.g_strErrorCorrection:
		qNo = NNW.screens.textFormatting.activeFieldNo;
		NNW.control.updateExerciseText(txts.txtText.text);
		
		if (scnExercise.segment2.contentHolder.otherOptions_mc._visible) {
			NNW.control.data.currentExercise.fieldManager.removeAllAnswers(qNo);
			for (var i=0; i<dgs.dgOption.length; i++) {
				NNW.control.updateExercise("answer", qNo, getOptionAtIndex(i), i, true);
			}
		}
		
		//if (acds.acdFH._visible) {
			NNW.control.updateExercise("feedback", qNo, acds.acdFH.child0.txtFeedback.text);
			NNW.control.updateExercise("hint", qNo, acds.acdFH.child1.txtHint.text);
		//} else if (scnExercise.segment2.contentHolder.hintOnly_mc._visible) {
		//	NNW.control.updateExercise("hint", qNo, txts.txtHintOnly.text);
		//}
		break;
	}
}

updateOptions = function() {
	var qNo = Number(txts.txtQuestionNo.text);
	NNW.control.updateExercise("option", qNo, txts.txtOption0.text, 0, chbs.getChecked("chbOption0"));
	NNW.control.updateExercise("option", qNo, txts.txtOption1.text, 1, chbs.getChecked("chbOption1"));
	NNW.control.updateExercise("option", qNo, txts.txtOption2.text, 2, chbs.getChecked("chbOption2"));
	NNW.control.updateExercise("option", qNo, txts.txtOption3.text, 3, chbs.getChecked("chbOption3"));
}
// v0.16.1, DL: skip updating exercise if an exercise has just been loaded
updateQuizOptionsLabels = function() {	// v0.16.0, DL: this is a replacement of the panel functions
	var trueLabel = "";
	var falseLabel = "";
	if (chbs.chbQuizOptions0.selected) {
		trueLabel = chbs.chbQuizOptions0.label;
		falseLabel = chbs.chbQuizDummyOption.label;
	} else {
		trueLabel = (txts["txtTrue"].text!=undefined) ? txts["txtTrue"].text : "";
		falseLabel = (txts["txtFalse"].text!=undefined) ? txts["txtFalse"].text : "";
	}
	chbs.chbTrueOption.label = trueLabel;
	chbs.chbFalseOption.label = falseLabel;
	acds.acdFFH.setLabels(_global.replace(btns.getLiteral("lblFeedbackFor"), "[x]", trueLabel), _global.replace(btns.getLiteral("lblFeedbackFor"), "[x]", falseLabel), btns.getLiteral("lblHint"));
	
	//_global.myTrace("true label = "+trueLabel);
	//_global.myTrace("false label = "+falseLabel);
	
	// v6.4.1.4, DL: DEBUG - added a true option and a false option variables in dataExercise class
	NNW.control.updateExerciseQuizOption(true, trueLabel);
	NNW.control.updateExerciseQuizOption(false, falseLabel);
}
updateTrueFalseOptions = function() {
	if(ex.question.length == undefined){
		// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311, add splitscreen stuff
		// moved in 6.5.4.2
		var ex 			= NNW.control.data.currentExercise;
		var splitScreen 	= ex.settings.misc.splitScreen;
		var qNo:Number;
		splitScreen != undefined? qNo = Number(txts.txtSplitScreenQuestionNo.text) : qNo = Number(txts.txtQuestionNo.text);

		// moved in 6.5.4.2
		NNW.control.updateExercise("option", qNo, chbs.chbTrueOption.label, 0, chbs.chbTrueOption.selected);
		NNW.control.updateExercise("option", qNo, chbs.chbFalseOption.label, 1, !chbs.chbTrueOption.selected);
	} else {
		var i:Number;
		for(i=1; i<=ex.question.length; ++i){
			NNW.control.updateExercise("option", i, chbs.chbTrueOption.label, 0, chbs.chbTrueOption.selected);
			NNW.control.updateExercise("option", i, chbs.chbFalseOption.label, 1, !chbs.chbTrueOption.selected);
		}
		// end v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311
	}
}
updateRMCOptions = function() {
	var qNo = Number(txts.txtSplitScreenQuestionNo.text);
	NNW.control.updateExercise("option", qNo, txts.txtRMCOption0.text, 0, chbs.getChecked("chbRMCOption0"));
	NNW.control.updateExercise("option", qNo, txts.txtRMCOption1.text, 1, chbs.getChecked("chbRMCOption1"));
	NNW.control.updateExercise("option", qNo, txts.txtRMCOption2.text, 2, chbs.getChecked("chbRMCOption2"));
	NNW.control.updateExercise("option", qNo, txts.txtRMCOption3.text, 3, chbs.getChecked("chbRMCOption3"));
}
// v0.16.1, DL: move formatting buttons around
moveFormattingButtons = function(x:Number, y:Number) : Void {
	scnExercise.segment2.contentHolder.formatting_mc.formattingTool_mc.buttons_mc._x = (x!=undefined) ? x : -94.4;
	scnExercise.segment2.contentHolder.formatting_mc.formattingTool_mc.buttons_mc._y = (y!=undefined) ? y : 1;
}
// v0.16.1, DL: move make field buttons around
moveMakeField = function(x:Number, y:Number) : Void {
	scnExercise.segment2.contentHolder.formatting_mc.formattingTool_mc.field_mc._x = (x!=undefined) ? x : -328.55;
	scnExercise.segment2.contentHolder.formatting_mc.formattingTool_mc.field_mc._y = (y!=undefined) ? y : 121.55;
}

/* v0.14.0, DL: functions for dgOption */
promptForNewOption = function() : Void { dgs.promptForNewItem("Option"); }
renameOptionOnList = function() : Void { dgs.renameSelectedItem("Option"); }
delOptionFromList = function() : Void { dgs.removeSelectedItem("Option"); }
clearOptionList = function() : Void { dgs.clearList("Option"); }
addOptionsToList = function(arr:Array) : Void {
	var exType = NNW.control.data.currentExercise.exerciseType;
	
	// v0.16.1, DL: reset columns for options
	dgs.removeAllColumns("Option");
	
	if (arr.length>0) {
		for (var i=0; i<arr.length; i++) {
			var item = arr[i];
			//v6.4.2.2, RL: Drag&Drop and DragOn exType add preset the 2 columns
			//if (exType=="Dropdown") {
			// v6.4.3 Item based drop down
			//if (exType=="Dropdown"||exType=="DragOn"||exType=="DragAndDrop") {
			if (exType=="Dropdown"||exType=="DragOn"||exType=="DragAndDrop"||exType=="Stopdrop") {
				dgs.addItemToList("Option", {label:item.value, correct:item.correct});
			} else {
				dgs.addItemToList("Option", {label:item.value});
			}
		}
	} else {
		// v0.16.1, DL: for Dropdown, we need to add preset the 2 columns
		//v6.4.2.2, RL: Drag&Drop and DragOn exType add preset the 2 columns
		//if (exType=="Dropdown") {
		// v6.4.3 Item based drop down
		//if (exType=="Dropdown"||exType=="DragOn"||exType=="DragAndDrop") {
		if (exType=="Dropdown"||exType=="DragOn"||exType=="DragAndDrop"||exType=="Stopdrop") {
			dgs.dgOption.addColumnAt(0, "label");
			dgs.dgOption.addColumnAt(1, "correct");
		}
	}
	
	// v0.16.1, DL: only Dropdown needs to have checkbox in options
	// v6.4.2.2, RL: Drag&Drop and DragOn exType add checkbox in options
	//if (exType=="Dropdown") {
	// v6.4.3 Item based drop down
	//if (exType=="Dropdown"||exType=="DragOn"||exType=="DragAndDrop") {
	if (exType=="Dropdown"||exType=="DragOn"||exType=="DragAndDrop"||exType=="Stopdrop") {
		dgs.dgOption.getColumnAt(1).cellRenderer = "checkBoxCellRenderer";
		dgs.dgOption.getColumnAt(0).width = 195;
	} else {
		dgs.removeExtraColumns("Option");
	}
}
selectOptionByIndex = function(n:Number) : Void { dgs.setSelectedItem("Option", n); }
getSelectedOptionIndex = function() : Number { return dgs.getSelectedIndex("Option"); }
getOptionAtIndex = function(n:Number) : String { return dgs.dgOption.getItemAt(n).label; }
getOptionCorrectnessAtIndex = function(n:Number) : String { return dgs.dgOption.getItemAt(n).correct; }

/* v0.12.0, DL: set weblink*/
setWebLink = function() {
	textFormatting.setUrl(txts.txtLink.text);
	updateWholeExercise();
}

/* v0.11.0, DL: reset text formats */
resetTextFormats = function() {
	var tf = new TextFormat();
	var a = new Array("txtText", "txtQuestion", "txtFeedback", "txtHint", "txtSplitScreenText", "txtSplitScreenQuestion");	// v0.16.1, DL: change txtRMCText to txtSplitScreenText
	for (var i in a) {
		txts[a[i]].text = "";
		txts[a[i]].label.setTextFormat(0, tf);
		txts[a[i]].label.setNewTextFormat(tf);
	}
}

// v0.16.1, DL: functions for browse file screen
resetBrowseScreen = function(fileType:String) : Void {
	browseFiles_mc.loading_mc._visible = true;
	browseFiles_mc.fileList_mc._visible = false;
	NNW.control.getMediaFilenames(fileType);
}
showBrowseList = function() : Void {
	browseFiles_mc.loading_mc._visible = false;
	browseFiles_mc.fileList_mc._visible = true;
}

// v6.4.0.1, DL: close multimedia panels
closeMultimediaPanels = function() {
	NNW.screens.closeImagePanel();
	NNW.screens.closeAudioPanel();
	NNW.screens.closeVideoPanel();
	// v6.4.2.7 Adding URLs - but where are these functions? In the mc for the panel.
	NNW.screens.closeURLPanel();
	NNW.screens.closeQuestionMMPanel();
}

// functions for literals
setLiteralsOnScreens = function() : Void {
	btns.setLabelsLiterals();
	btns.setButtonsLiterals();
	combos.resetPhotoCatergoryLiterals();
	NNW.control.errorCheck.changeErrorLiterals();	// v0.6.0, DL: change error checking literals
	
	// v6.4.1.4, DL: click here to get started button (not really a button)
	scnUnit.gettingStarted.label1.text = NNW.view.literals.getLiteral("btnClickToGetStarted1");
	scnUnit.gettingStarted.label2.text = NNW.view.literals.getLiteral("btnClickToGetStarted2");
	
	// v6.4.1.4, DL: DEBUG - update quiz options in data
	updateQuizOptionsLabels();
}

addLanguagesToCombo = function() : Void {
	var langArray = NNW.view.literals.LanguagesAvailable;
	var c = combos.comboLanguage;
	
	// v6.4.1.2, DL: add languages according to the order of parameter passed
	var l = NNW._defaultLanguage;
	if (l.indexOf(",")>-1) {
		var a = l.split(",");
		for (var n=0; n<a.length; n++) {
			for (var i=0; i<langArray.length; i++) {
				if (langArray[i].code==a[n]) {
					c.addItem(langArray[i].name, langArray[i].code);
				}
			}
		}
	// otherwise just add according to the order in the literals file
	} else {
		for (var i=0; i<langArray.length; i++) {
			c.addItem(langArray[i].name, langArray[i].code);
		}		
	}
	c.rowCount = c.length;
}

// functions for test screens
addTestsToCombo = function() : Void {
	var func = NNW.control.testCases.testFuncs;
	for (var i in func) {
		combos.comboTestFunc.addItem(func[i], func[i]);
	}
}

// functions for loading screens
onScreenLoaded = function(thisScreen:MovieClip) : Void {
	// make references to every object in this screen
	for (var j in thisScreen) {
		thisObject = thisScreen[j];
		switch (thisObject._name.substr(0, 3)) {
			case "acd" :	// for accordion
				acds[thisObject._name] = thisObject; 
				break;
			//case "bas" :
			case "chb" :	// for checkBoxes
				chbs[thisObject._name] = thisObject;
				thisObject.labelPath.autoSize = true;
				// v0.9.0, DL: show tooltip for dragging/rolling over a checkbox
				thisObject.onDragOver = function() {
					this.dispatchEvent({type:"dragOver"});
					super.onDragOver();
				}
				thisObject.onRollOver = function() {
					this.dispatchEvent({type:"rollOver"});
					super.onRollOver();
				}
				// v0.9.0, DL: hide tooltip for dragging/rolling out a checkbox
				thisObject.onDragOut = function() {
					this.dispatchEvent({type:"dragOut"});
					super.onDragOut();
				}
				thisObject.onRollOut = function() {
					this.dispatchEvent({type:"rollOut"});
					super.onRollOut();
				}
				thisObject.addEventListener("dragOver", chbs);
				thisObject.addEventListener("rollOver", chbs);
				thisObject.addEventListener("dragOut", chbs);
				thisObject.addEventListener("rollOut", chbs);
				// set listener
				thisObject.addEventListener("click", chbs);
				break;
			case "txt" :	// for textinput
				txts[thisObject._name] = thisObject;
				// set listener
				thisObject.addEventListener("change", txts);
				thisObject.addEventListener("enter", txts);
				break;
			case "nsp" :	// for numeric stepper
				nsps[thisObject._name] = thisObject;
				thisObject.nextButton_mc._visible = false;
				thisObject.prevButton_mc._visible = false;
				thisObject.inputField.addEventListener("enter", nsps);
				thisObject.addEventListener("change", nsps);
			case "win" :	// for window
				wins[thisObject._name] = thisObject;
				break;
			case "lbl" :	// for labels (only have literals but no functions assigned)
				btns[thisObject._name] = thisObject;
				thisObject.labelPath.autoSize = true;
				break;
			case "btn" :	// for buttons
				btns[thisObject._name] = thisObject;
				thisObject.labelPlacement = "bottom";
				thisObject.useHandCursor = true;
				// set listener
				thisObject.addEventListener("click", btns);
				break;
			default :
				if (thisObject._name.substr(0, 2)=="dg") {	// for dataGrids
					dgs[thisObject._name] = thisObject;
					// set column
					/* this makes the drag&drop doesn't work! so better add items and then remove columns */
					//thisObject.addColumn("label");
					/* seems the performance of using listeners outside the cells is better */
					//thisObject.getColumnAt(0).cellRenderer = "dropCaptureCellRenderer";
					thisObject.showHeaders = false;
					// set listener
					thisObject.addEventListener("cellEdit", dgs);
					thisObject.addEventListener("change", dgs);
					thisObject.addEventListener("cellPress", dgs);
					thisObject.addEventListener("cellFocusOut", dgs);
					thisObject.addEventListener("cellFocusIn", dgs);
				} else if (thisObject._name.substr(0, 5)=="combo") {	// for comboBoxes
					combos[thisObject._name] = thisObject;
					// set listener
					thisObject.addEventListener("change", combos);
					
					// v0.16.0, DL: for comboScore (score-based feedback)
					if (thisObject._name=="comboScore") {
						thisObject.text_mc.addEventListener("focusOut", combos);
						thisObject.addEventListener("enter", combos);
						thisObject.addEventListener("close", combos);
					}
					
				// v0.16.0, DL: no panels anymore
				/*} else if (thisObject._name.substr(0, 5)=="panel") {	// for panels
					panels[thisObject._name] = thisObject;
					// set onRelease functions
					panels.setOnReleaseFunctions(thisObject);
					// set references to checkBoxes inside the panel
					chbs["chbTrue"+thisObject._name.substr(5, 1)] = thisObject.chbTrue;
					chbs["chbFalse"+thisObject._name.substr(5, 1)] = thisObject.chbFalse;
					// set listener to checkBoxes inside the panel
					thisObject.chbTrue.addEventListener("click", chbs);
					thisObject.chbFalse.addEventListener("click", chbs);*/
					
				// v6.4.3 Use the tree more now - course tree
				} else if (thisObject._name.substr(0, 4)=="tree") {	// v0.16.1, DL: for trees
					trees[thisObject._name] = thisObject;
					thisObject.addEventListener("change", trees);
					thisObject.setStyle("fontFamily", "Verdana");
					// v6.4.3 Add customisations to the DnDtree
					
					thisObject.labelField = "name";
					//Hijack the label function to force nodes with no id to be branches
					thisObject.labelFunction = function(node) {
						// Use the name attribute as the label
						var label = node.attributes.name;
						var id = node.attributes.id;
						//_global.myTrace("check node " + label + " id=" + id);
						if (id == undefined || id=="") {
							this.setIsBranch(node, true);
						}
						return label;
					}
					thisObject.preserveBranches = true;

					// get reference to the context menu menu items array - you may have to use the theTree.menu property if you are using your own menu
					var menuItems = thisObject.cm.customItems;
					
					// remove menu items for cutting, copying etc
					menuItems.splice(0,5);
					 
					// also remove the delete/remove option - let it just be done by the button
					// rename 'branch' to be folder and 'leaf' to be course
					menuItems.splice(2,1);
					
					// v6.5.1 Yiu disable right click menu
					//menuItems[0].caption = "Add a course";
					//menuItems[1].caption = "Add a folder";
					menuItems[0].caption = "";
					menuItems[1].caption = "";
					// End v6.5.1 Yiu disable right click menu
					
					menuItems[2].separatorBefore = true;
					//menuItems[3].separatorBefore = false;
					//menuItems[2].caption = "Delete this"; // Note that this can't just be called 'Delete' otherwise it disappears.
					
					// v6.5.1 Yiu disable right click menu
					//menuItems[2].caption = "Rename";
					menuItems[2].caption = "";
					// End v6.5.1 Yiu disable right click menu
					
					// default for new courses
					thisObject.leafNodeXML = "<course name='New course' id='0' />";
					thisObject.branchNodeXML = "<course name='new folder' />";
					
					// set the events to be run on rename, delete, new course from the menu
					thisObject.addEventListener("renameNode", trees);
					thisObject.addEventListener("cutNode", trees);
					thisObject.addEventListener("addLeafNode", trees);
					thisObject.addEventListener("pasteNode", trees);

					// set the events to be called after any kind of rebuilding of the tree structure
					thisObject.addEventListener("drop", trees);
					thisObject.addEventListener("addBranchNode", trees);					

					// And some basic permissions
					thisObject.preventDropIntoLeafNodes = true;
					thisObject.renameField = "name";
					
					// I want the default double-click to be edit rather than rename
					thisObject.renameOnDoubleClick = false;
					thisObject.addEventListener("doubleClick", trees);
					// v6.4.3 I don't really need the following event, just useful for debugging
					//thisObject.addEventListener("singleClick", trees);
					
				} else if (thisObject._name == "pBar") {	// for progress bar
					pBar = thisObject;
					pBar._visible = false;
					pBar.label = thisObject.label_txt.text;
				} else if (thisObject._name == "mask_mc") { // for mask_mc
					thisObject.useHandCursor = false;
				} else if (thisObject._name == "lite_mc") {	// v6.4.1, DL: lite/pro words
					liteWords.push(thisObject);
				} else if (thisObject._name == "pro_mc") {	// v6.4.1, DL: lite/pro words
					proWords.push(thisObject);
				}
				break;
		}
	}
	// increment loaded count
	screensLoaded++;
	NNW.screens.pleaseWait.setProgress(screensLoaded, totalNoOfScreens);
	// trace screen name
	//myTrace(screensLoaded+". movieclip "+thisScreen._name+" loaded.");
	// if all screens are loaded, we can start other initialisations
	if (screensLoaded >= totalNoOfScreens) {
		if (!allScreensLoaded) {
			onAllScreensLoaded();
		}
	}
}

onAllScreensLoaded = function() : Void {
	// set allScreensLoaded to true
	allScreensLoaded = true;
	// set icons to buttons
	btns.setIcons();
	btns.createButtonLabels();	// v0.16.0, DL: creating button labels may take some time, and we've to wait
}
// v0.16.0, DL: this will be called after all button labels have been created
onAllButtonLabelsCreated = function() : Void {
	// set literals
	addLanguagesToCombo();
	// v0.16.1, DL: set to default literals language
	var l = NNW._defaultLanguage;
	if (l!=undefined && l!="" && l!="undefined") {
		if (l.indexOf(",")>-1) {
			l = l.split(",")[0];
		}
		combos.setComboSelectedData("Language", _global.replace(l, "*", ""));
		NNW.view.literals.onChangeLiterals(_global.replace(l, "*", ""));
		if (l.indexOf("*")>=0) {
			combos.comboLanguage.enabled = false;
		}
	}
	setLiteralsOnScreens();
	// reset exercise screen
	combos.setComboSelectedData("ImageCategory", "");
	resetSegments();
	
	/* testing stuffs */
	// add screens to combo (for testing)
	var c = combos.comboScreens;
	c._visible = NNW.__testMode;	// only visible if testMode is on
	for (var i in scnNameArray) {
		c.addItem(scnNameArray[i], scnNameArray[i]);
	}
	
	c.rowCount = c.length;
	// add tests to test screen
	addTestsToCombo();
	
	// v0.1, DL: initialise screen module after everything has been loaded
	NNW.screens.initialise();
}

loadScreens = function() : Void {
	// load all the screens in the screen array
	for (var i=0; i<scnNameArray.length; i++) {
		this.attachMovie(scnNameArray[i], scnNameArray[i], 100+i);
		var thisScreen = this[scnNameArray[i]];
		thisScreen._lockroot = true;
		// initially set every screen to be invisible
		thisScreen._visible = false;
	}
}

// set focus
setFocus = function(scnName:String, pos:String) : Void {
	switch (scnName) {
	case "scnAuthCode" :
		var txt = txts.txtCode;
		txt.setFocus();
		Selection.setSelection(0, 0);
		break;
	case "scnLogin" :
		var txt = txts.txtUsername;
		txt.setFocus();
		break;
	case "scnExercise" :
		var txt = txts.txtExerciseName;
		txt.setFocus();
		
		Selection.setSelection(txt.text.length, txt.text.length);
		break;
	}
}

// show screens
showScreen = function(screen, hideOthers) : Void {
	if (hideOthers) {
		hideAllScreens();
	}
	setFocus(screen);
	this[screen]._visible = true;
}

hideScreen = function(screen) : Void {
	this[screen]._visible = false;
}

hideAllScreens = function() : Void {
	for (var i in scnNameArray) {
		if (scnNameArray[i]!="scnAlwaysOnTop" && scnNameArray[i]!="scnFirstTime") {
			hideScreen(scnNameArray[i]);
		}
	}
}

// v0.16.0, DL: set Lite/Pro settings
setLiteSettings = function() : Void {
	// image position settings
	btns.lblPosition.visible = false;
	chbs.chbImagePos0.visible = false;
	chbs.chbImagePos1.visible = false;
	// Yiu v6.5.1 Remove Banner
	//chbs.chbImagePos2.visible = false;
	// Yiu v6.5.1 Remove Banner
	btns.btnMoreImage._visible = false;
	btns.lblMoreImage.visible = false;
	
	// audio settings
	chbs.chbEmbedAudio.visible = false;
	chbs.chbAfterMarkingAudio.visible = false;
	btns.btnMoreAudio._visible = false;
	btns.lblMoreAudio.visible = false;
	
	// video settings
	btns.lblVideo.visible = false;
	chbs.chbEmbedVideo.visible = false;
	chbs.chbFloatingVideo.visible = false;
	btns.btnMoreVideo._visible = false;
	btns.lblMoreVideo.visible = false;
	
	// v6.4.2.7 Adding URLs
	btns.lblURL.visible = false;
	btns.btnMoreURL._visible = false;
	btns.lblMoreURL.visible = false;
	
	// buttons settings
	chbs.chbBtnFeedback.visible = false;
	chbs.chbBtnMarking.visible = false;
	chbs.chbBtnRule.visible = false;
	chbs.chbHideTargets.visible = false;
	
	// Pro settings
	chbs.chbOverwriteAnswers.visible = false;
	chbs.chbNeutralFeedback.visible = false;
	chbs.chbCorrectTarget.visible = false;
	chbs.chbDragTimes.visible = false;
	
	// feedback settings
	btns.lblButtons.visible = false;
	chbs.chbFeedbackScoreBased.visible = false;
	chbs.chbFeedbackDifferent.visible = false;
	
	// time limit
	btns.lblTimeLimit.visible = false;
	txts.txtTimeLimit.visible = false;
	btns.lblMins.visible = false;
	
	// split-screen
	chbs.chbSplitScreen.visible = false;
	
	// question multimedia
	btns.btnQuestionMM._visible = false;
	btns.lblQuestionMM.visible = false;
	
	// v6.4.1.2, DL: test mode
	chbs.chbTestMode.visible = false;
}

setProSettings = function() : Void {
	// v6.4.1, DL: hide the SCORM export button
	//NNW.view.setVisible("btnSCORMExport", false);
}

// v0.16.1, DL: i'm trying to move all settings to one movieclip for faster loading and easier screen-design
// v0.16.1, DL: set settings screen according to exercise type
setSettingsScreen = function(ex:Object) : Void {
	
	var exType = ex.exerciseType;
	var splitScreen =ex.settings.misc.splitScreen;
	
	// disable image position settings for Analyze/split-screen exercises
	if (exType=="Analyze"||splitScreen) {
		enableImagePositionCheckBoxes(false);
	}
	
	// no marking settings for Countdown, Proofreading, Presentation
	if (exType=="Countdown"||exType=="Proofreading"||exType=="Presentation"||
		exType==_global.g_strBulletID	// v6.5.1 Yiu add new exercise type qbased presentation
	) {
		btns.lblInstantMarking.visible = false;
		chbs.chbMarkingInstant.visible = false;
		// v6.4.2.5 silent marking - always let the author choose sound effects
		//chbs.chbSoundEffects.visible = false;
		chbs.chbMarkingDelayed.visible = false;
		chbs.chbMarkingChoose.visible = false;
	} else {
		btns.lblInstantMarking.visible = true;
		chbs.chbMarkingInstant.visible = true;
		// v6.4.2.5 silent marking - always let the author choose sound effects
		//chbs.chbSoundEffects.visible = true;
		chbs.chbMarkingDelayed.visible = true;
		chbs.chbMarkingChoose.visible = true;
	}
	
	// no marking or feedback button for Presentation
	// v6.4.1.2, DL: no test mode for Presentation
	if (exType=="Presentation" ||		
		exType==_global.g_strBulletID	// v6.5.1 Yiu add new exercise type qbased presentation
		) {
		btns.lblButtons.visible = false;
		chbs.chbBtnMarking.visible = false;
		chbs.chbBtnFeedback.visible = false;
		chbs.chbTestMode.visible = false;
	} else {
		btns.lblButtons.visible = true;
		chbs.chbBtnMarking.visible = true;
		chbs.chbBtnFeedback.visible = true;
		chbs.chbTestMode.visible = true;
	}

	// v6.5 AR Why doesn't presentation also disable sound effects?
	if(exType=="Presentation" ||exType==_global.g_strBulletID){	// v6.5.1 Yiu disable sound effet on Bullet
		chbs.chbSoundEffects.visible = false;
	} else {
		chbs.chbSoundEffects.visible = true;
	}
	// v6.4.2.8 Here I want to see if this unit menu node has a ruleID. If it does, then I want to visible the button
	//if (ex.ruleID <> undefined) {
	//_global.myTrace("for this ex, the unit has ruleID=" + _global.NNW.control.data.currentUnit.ruleID);
	if (_global.NNW.control.data.currentUnit.ruleID == undefined) {
		chbs.chbBtnRule.visible = false;
	} else {
		chbs.chbBtnRule.visible = true;
	}
	
	// quiz options names for Quiz only
	// different feedback for Quiz only
	if (exType=="Quiz") {
		btns.lblTFOptions.visible = true;
		chbs.chbQuizOptions0.visible = true;
		chbs.chbQuizOptions1.visible = true;
		chbs.chbQuizDummyOption.visible = true;
		txts.txtTrue.visible = true;
		txts.txtFalse.visible = true;
		
		chbs.chbFeedbackDifferent.visible = true;
	} else {
		btns.lblTFOptions.visible = false;
		chbs.chbQuizOptions0.visible = false;
		chbs.chbQuizOptions1.visible = false;
		chbs.chbQuizDummyOption.visible = false;
		txts.txtTrue.visible = false;
		txts.txtFalse.visible = false;
		
		chbs.chbFeedbackDifferent.visible = false;
	}
	
	// no settings label for Presentation
	if (exType=="Presentation"	||
		exType==_global.g_strBulletID	// v6.5.1 Yiu add new exercise type qbased presentation
		) {
		btns.lblSettings.visible = false;
	} else {
		btns.lblSettings.visible = true;
	}
	
	// no score-based feedback for TargetSpotting, Presentation
	// v6.4.2.1 ar Try adding it for target spotting - or is it more complex? 
	//if (exType=="TargetSpotting"||exType=="Presentation") {
	if (exType=="Presentation"	||
		exType==_global.g_strBulletID	// v6.5.1 Yiu add new exercise type qbased presentation
		) {
		chbs.chbFeedbackScoreBased.visible = false;
		btns.btnScoreBasedFeedback.visible = false;
	} else {
		chbs.chbFeedbackScoreBased.visible = true;
	}
	
	sliderSameLengthGap._visible = false;
	
	// same gap length for Countdown/Stopgap/Cloze
	// slider for Countdown only
	if (exType=="Stopgap"||exType=="Cloze") {
		chbs.chbSameLengthGaps.visible = true;
		// v6.5.1 Yiu new default gap length check box and slider 
		chbs.chbDefaultLengthGaps.visible = true;		
	} else {
		chbs.chbSameLengthGaps.visible = false;
		// v6.5.1 Yiu new default gap length check box and slider 
		chbs.chbDefaultLengthGaps.visible = false;		
	}
	
	// capitalization, same gap length (slider), show text first for Countdown
	if (exType=="Countdown") {
		chbs.chbCapitalisation.visible = true;
		chbs.chbShowTextFirst.visible = true;	// v0.12.0
		chbs.chbSameLengthGaps.visible = true;
	} else {
		chbs.chbCapitalisation.visible = false;
		chbs.chbShowTextFirst.visible = false;	// v0.12.0
	}
	
	// hide targets for TargetSpotting
	if (	exType=="TargetSpotting"				||
			exType==_global.g_strQuestionSpotterID 	// v6.5.1 Yiu add new exercise type question spotter
			) {
		chbs.chbHideTargets.visible = true;	 // v0.16.0
	} else {
		chbs.chbHideTargets.visible = false;	 // v0.16.0
	}
	
	// overwrite answers for drag/gap
	if (	exType=="DragAndDrop"					||
			exType=="DragOn"						||
			exType=="Stopgap"						||
			exType=="Cloze"							||
			exType==_global.g_strErrorCorrection		// v6.5.1 Yiu add new exercise type error correction
			) {
		chbs.chbOverwriteAnswers.visible = true;	 // v0.16.0
	} else {
		chbs.chbOverwriteAnswers.visible = false;	 // v0.16.0
	}
	
	// neutral feedback for TargetSpotting
	if (	exType=="TargetSpotting"					||
			exType==_global.g_strQuestionSpotterID 		 	// v6.5.1 Yiu add new exercise type question spotter
			) {
		chbs.chbNeutralFeedback.visible = true;	// v0.16.0
	} else {
		chbs.chbNeutralFeedback.visible = false;	// v0.16.0
	}
	
	// if there're settings other than feedback settings, move feedback settings down
	// v6.4.3 Item based drop down
	//if (exType=="DragAndDrop"||exType=="DragOn"||exType=="Stopgap"||exType=="Cloze"||exType=="TargetSpotting"||exType=="Countdown") {
	if (	exType=="DragAndDrop"					||
			exType=="DragOn"						||
			exType=="Stopgap"						||
			exType=="Cloze"							||
			exType=="TargetSpotting"				||
			exType=="Countdown"						||
			exType=="Stopdrop"						||
			exType==_global.g_strQuestionSpotterID 	|| 	// v6.5.1 Yiu add new exercise type question spotter
			exType==_global.g_strErrorCorrection		// v6.5.1 Yiu add new exercise type error correction
		) {
		var yCoor = 281.8;
		//chbs.chbFeedbackScoreBased._y = yCoor;
		//btns.btnScoreBasedFeedback._y = yCoor;
		chbs.chbFeedbackDifferent._y = yCoor;
	} else {
		var yCoor = 254.8;
		//chbs.chbFeedbackScoreBased._y = yCoor;
		//btns.btnScoreBasedFeedback._y = yCoor;
		chbs.chbFeedbackDifferent._y = yCoor;
	}
	
	// split-screen for question-based exercise types only
	// v6.4.3 Item based drop down
	//if (exType=="Stopgap"||exType=="MultipleChoice"||exType=="Analyze") {
	if (	exType	=="Stopgap"				||
			exType	=="MultipleChoice"		||
			exType	=="Analyze"				||
			exType 	== "Stopdrop"			||
			exType 	== "Quiz"	// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311
			//exType	==_global.g_strQuestionSpotterID ||	// v6.5.1 Yiu add new exercise type question spotter
			//exType	==_global.g_strBulletID	 // v6.5.1 Yiu add new exercise type Bullet split screen
		) {
		chbs.chbSplitScreen.visible = true;
	} else {
		chbs.chbSplitScreen.visible = false;
	}
	
	// once/multiple drag times for drag
	if (exType=="DragAndDrop"||exType=="DragOn") {
		chbs.chbDragTimes.visible = true;	// v0.16.1
	} else {
		chbs.chbDragTimes.visible = false;	// v0.16.1
	}
	
	// 6.4.0.1, DL: only dropdown has the "correct" column on its option list
	//v6.4.2.2, RL: DragOn and Drag&Drop add "correct" column label.
	//if (exType=="Dropdown") {
	// v6.4.3 Item based drop down
	//if (exType=="Dropdown"||exType=="DragOn"||exType=="DragAndDrop") {
	if (exType=="Dropdown"||exType=="DragOn"||exType=="DragAndDrop"||exType=="Stopdrop") {
		btns.lblOptionListCorrect.visible = true;
	} else {
		btns.lblOptionListCorrect.visible = false;
	}
	
	// Yiu v6.5.0.1 set check box position for each exercise type
	// default settings
	btns.lblSettingScreenExerciseSettingsPart1.visible	= true;
	btns.lblSettingScreenExerciseSettingsPart2.visible	= true;
	btns.lblFeedback1.visible							= true;
	btns.lblTFOptions.visible 							= false;
	//sliderSameLengthGap._visible 						= false;
	//sliderDefaultLengthGap._visible 					= false;
	btns.lblMCTrue.visible								= false;
	btns.lblMCFalse.visible								= false;
	btns.lblMakeField.visible 							= false;
	setlblShowDefaultVisible(false);
	
	// end default settings
	
	var nStartX:Number;
	var nStartY:Number;
	var nOffsetY:Number;
	var nOffsetX:Number;
	
	nStartX		= 101.1;
	nStartY		= 353.9;
	nOffsetY	= 22;
	nOffsetX	= 206.9;
	
	var nPosY1	= nStartY + nOffsetY * 0;
	var nPosY2	= nStartY + nOffsetY * 1;
	var nPosY3	= nStartY + nOffsetY * 2;
	
	var nStartOptionX	= nStartX;
	var nStartOptionY	= 433.9;
	
	var nOptionPosY1	= nStartOptionY + nOffsetY * 0;
	var nOptionPosY2	= nStartOptionY + nOffsetY * 1;
	var nOptionPosY3	= nStartOptionY + nOffsetY * 2;
	
	var nOptionPosX1	= nStartOptionX + nOffsetX * 0;
	var nOptionPosX2	= 398.1;
	
	switch(exType)
	{
		case "MultipleChoice":
			chbs.chbSplitScreen._x			= nStartX;
			chbs.chbSplitScreen._y			= nPosY2;
			break;
		case "Quiz": 
			btns.lblMCTrue.visible			= true;
			btns.lblMCFalse.visible			= true;
			
			chbs.chbFeedbackDifferent._y	= nPosY2;
			
			// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311
			chbs.chbSplitScreen._x			= nStartX;	
			chbs.chbSplitScreen._y			= nPosY3;   
			break;
		case "Dropdown":
			break;
		case "DragAndDrop":
			btns.lblTFOptions.visible 		= true;
			
			chbs.chbOverwriteAnswers._x		= nOptionPosX1;
			chbs.chbOverwriteAnswers._y		= nOptionPosY1;
			
			chbs.chbDragTimes._x		= nOptionPosX1;
			chbs.chbDragTimes._y		= nOptionPosY2;
			break;
		case "DragOn":
			btns.lblTFOptions.visible 		= true;
			
			chbs.chbOverwriteAnswers._x		= nOptionPosX1;
			chbs.chbOverwriteAnswers._y		= nOptionPosY1;
			
			chbs.chbDragTimes._x		= nOptionPosX1;
			chbs.chbDragTimes._y		= nOptionPosY2;
			break;
		case "Stopgap":
			// v6.5.1 Yiu new default gap length check box and slider 
			btns.lblMakeField.visible 		= !chbs.getChecked("chbSameLengthGaps");
			setlblShowDefaultVisible();
			//sliderSameLengthGap._visible 	= true;
			btns.lblTFOptions.visible 		= true;
			
			chbs.chbOverwriteAnswers._x		= nOptionPosX1;
			chbs.chbOverwriteAnswers._y		= nOptionPosY1;
			
			chbs.chbSameLengthGaps._x		= nOptionPosX1;
			chbs.chbSameLengthGaps._y		= nOptionPosY2;
			
			chbs.chbSplitScreen._x			= nStartX;
			chbs.chbSplitScreen._y			= nPosY2;
			
			// v6.5.1 Yiu commented, new default gap length check box and slider 
			//slider._visible	= true;
			
			//slider._x	= nOptionStartX2;
			//slider._y	= nOptionPosY1;
			break;
		case "Cloze":
			// v6.5.1 Yiu new default gap length check box and slider 
			btns.lblMakeField.visible 		= !chbs.getChecked("chbSameLengthGaps");
			setlblShowDefaultVisible();
			//sliderSameLengthGap._visible 	= true;
			btns.lblTFOptions.visible 		= true;
			break;
		case "Countdown":
			//sliderSameLengthGap._visible 	= true;
			btns.lblTFOptions.visible 		= true;
			
			chbs.chbShowTextFirst._x		= nOptionPosX1;
			chbs.chbShowTextFirst._y		= nOptionPosY1;
			
			chbs.chbCapitalisation._x		= nOptionPosX2;
			chbs.chbCapitalisation._y		= nOptionPosY1;
			break;
		case "Analyze":
			break;
		case "Presentation":
			btns.lblFeedback1.visible		= false;
			
			btns.lblSettingScreenExerciseSettingsPart1.visible	= false;
			btns.lblSettingScreenExerciseSettingsPart2.visible	= false;
			break;
		case "TargetSpotting":
			chbs.chbNeutralFeedback._y		= nPosY2;
			
			btns.lblTFOptions.visible 		= true;
			chbs.chbHideTargets._x			= nOptionPosX1;
			chbs.chbHideTargets._y			= nOptionPosY1;
			break;
		case "Proofreading":
			break;
		case "Stopdrop":
			break;
		case _global.g_strQuestionSpotterID:			
			chbs.chbNeutralFeedback._y		= nPosY2;
			
			btns.lblTFOptions.visible 		= true;
						
			chbs.chbHideTargets._x			= nOptionPosX1;
			chbs.chbHideTargets._y			= nOptionPosY1;
			break;
		case _global.g_strBulletID:
			btns.lblFeedback1.visible		= false;
			
			btns.lblSettingScreenExerciseSettingsPart1.visible	= false;
			btns.lblSettingScreenExerciseSettingsPart2.visible	= false;
			break;
		case _global.g_strErrorCorrection:
			btns.lblTFOptions.visible 		= true;
			
			chbs.chbOverwriteAnswers._x		= nOptionPosX1;
			chbs.chbOverwriteAnswers._y		= nOptionPosY1;
			break;
		case _global.g_strSplitMultipleChoice:
			chbs.chbSplitScreen._x			= nStartX;
			chbs.chbSplitScreen._y			= nPosY2;
			break;
		case _global.g_strSplitDropdown:
			chbs.chbSplitScreen._x			= nStartX;
			chbs.chbSplitScreen._y			= nPosY2;
			break;
		case _global.g_strSplitGapfill:
			chbs.chbSplitScreen._x			= nStartX;
			chbs.chbSplitScreen._y			= nPosY2;
			break;
	}
}
	
// v6.5.1 Yiu added new function to get the current question number
getCurrentQuestionNumber	= function():Number
{
	var ex 		= NNW.control.data.currentExercise;
	var exType 	= ex.exerciseType;
	if (ex.settings.misc.splitScreen) {
		return Number(txts.txtSplitScreenQuestionNo.text);
	} else {
		return Number(txts.txtQuestionNo.text);
	} 
}
// end v6.5.1 Yiu added new function to get the current question number

// v6.5.1 Yiu function to show or hidden default word
setlblShowDefaultVisible	= function(b:Boolean):Void
{
	btns.lblShowDefault.visible	= b;
}

checkAndSetlblShowDefaultVisible	= function():Void
{
	var ex 		= NNW.control.data.currentExercise;
	var exType 	= ex.exerciseType;
	
	switch(exType)
	{		
		case "Stopgap":
		{
			var nCurQuestionNumber	= getCurrentQuestionNumber();
						
			// if the check box is not checked
			if (!chbs.getChecked("chbDefaultLengthGaps"))
			{
				setlblShowDefaultVisible(false);
				return ;
			}
			
			var strQuestionText:String	= textFormatting.field.htmlText;
			var bHaveField:Boolean		= _global.NNW.control.errorCheck.ifStringContainField(strQuestionText);
			bHaveField							= ex.getGapLength(nCurQuestionNumber-1) == undefined? false : true;
					
			// if there is no gap in the question
			if (!bHaveField)
			{
				setlblShowDefaultVisible(true);
			} else {
				setlblShowDefaultVisible(false);
			}
		}
		break;
	}
}
// End v6.5.1 Yiu function to show or hidden default word

// load all the screen when this file is loaded
loadScreens();

