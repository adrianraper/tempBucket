/*
	an instance of this class would be the view of NNW
	this class should only communicate with:
		1. control : the controller
		2. screens : namespace for functions that control/capture UI events
		3. pBar : the progress bar (in main)
*/

class Classes.view {
	
	// references
	var control:Object;
	var screens:Object;
	var literals:Object;
	var pBar:Object;
	
	var popupReason:String="";
	
	// v0.16.1, DL: keep track of previous screen
	var previousScreen:String;
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	
	function view() {
		mdm = _global.mdm; // mdm script 2.0
		literals = _global.NNW.literals;
		previousScreen = "";
	}
	
	function myTrace(s:String) {
		_global.myTrace(s);
	}
	
	// set visible
	function setVisible(objName:String, vis:Boolean) : Void {
		// v0.16.1, DL: special case: for Pro version, btnUpgrade is always NOT shown
		if (objName=="btnUpgrade" && !control._lite) {
			vis = false;
		}
		
		var obj:Object;
		switch(objName.substr(0, 3)) {
		case "acd" :	// for accordion
			obj = screens.acds[objName];
			break;
		case "chb" :	// for checkBoxes
			obj = screens.chbs[objName];
			break;
		case "txt" :	// for textinput
			obj = screens.txts[objName];
			break;
		case "win" :	// for window
			obj = screens.wins[objName];
			break;
		case "btn" :	// for buttons
			screens.btns["label"+objName.substr(3)]._visible = vis;
		case "lbl" :	// for labels
			obj = screens.btns[objName];
			break;
		// v6.4.3 Add tree
		case "tree" :	// for trees
			obj = screens.trees[objName];
			break;
		default :
			if (objName.substr(0, 2)=="dg") {	// for dataGrids
				obj = screens.dgs[objName];
			} else if (objName.substr(0, 5)=="combo") {	// for comboBoxes
				obj = screens.combos[objName];
			}
			break;
		}
		obj._visible = vis;
	}
	
	function showPleaseWait(b:Boolean) : Void {
		screens.showPleaseWait(b);
	}
	
	// show screen functions
	function showTestScreen() : Void {
		screens.showScreen("scnTest", true);
	}
	
	function showAlwaysOnTopScreen() : Void {
		setVisible("btnUpgrade", false);
		screens.showScreen("scnAlwaysOnTop", true);
	}
	
	function showAuthCodeScreen() : Void {
		screens.hideAuthCodeTick();
		screens.showScreen("scnAuthCode", true);
	}
	
	function showLoginScreen() : Void {
		// v6.4.2.5 Licenced to	
		//_global.myTrace("from licence, inst=" + control.login.licence.institution);
		// v6.4.2.5 Only pick this up once
		//screens.scnLogin.lblLicencedTo.text += control.login.licence.institution;
		screens.scnLogin.lblLicencedTo.text = literals.getLiteral("lblLicencedTo") + control.login.licence.institution;;
		screens.showScreen("scnLogin", true);
	}
	
	function showCourseScreen() : Void {
		screens.showScreen("scnCourse", true);

		// AR v6.4.2.5 Don't allow sharing from the course screen anymore
		//screens.showScreen("scnButtons", false);
	}
	
	function showUnitScreen() : Void {
		screens.fillInCourseName(control.data.currentCourse.name);
		
		// v6.4.3 This is now going to be static on this screen, only have rename on the front screen
		//screens.scnUnit.txtCourseName.editable = false;
		//screens.scnUnit.txtCourseName.enabled = false;
		// and hide the (obscure) save Button
		//screens.scnUnit.btnSaveCourseName._visible = false;
		
		// v0.15.0, DL: show getting started button if no exercises in this course
		setVisible("btnGettingStarted", true);
		screens.scnUnit.gettingStarted._visible = true;
		if (control.data.currentCourse.hasUnits()) {
			var u = control.data.currentCourse.Units;
			for (var i in u) {
				if (u[i].hasExercises()) {
					setVisible("btnGettingStarted", false);
					screens.scnUnit.gettingStarted._visible = false;
				}
			}
		}
		// v6.5.0.1 AR Hide the share button if this is a Kit authoring program
		// (at least until we have worked out how to protect exercises copied out of Tense Buster)
		//_global.myTrace("view.as: productType="+_global.NNW.control.login.licence.productType.toLowerCase());
		/*
		if (_global.NNW.control.login.licence.productType.toLowerCase()=="kit") {
			_global.myTrace("hide share as this is an AP kit");
			setVisible("btnShare", false);
			//screens.scnButtons.btnShare._visible = false;
		}
		// v6.5.0.1 AR Hide the share button if this is not Author Plus
		// Also, controversially, hide the share button for any editing of Clarity programs until we have MGS fully fixed
		// (and until we have worked out how to protect exercises copied out of Tense Buster)
		_global.myTrace("view.as: productType="+_global.NNW.interfaces.getInterface().toLowerCase());
		if (_global.NNW.interfaces.getInterface().toLowerCase() != "authorplus") {
			_global.myTrace("hide share as this is not Author Plus");
			setVisible("btnShare", false);
		} else {
			setVisible("btnShare", true);
		};
		*/
		screens.showScreen("scnUnit", true);
		screens.showScreen("scnButtons", false);
		//setVisible("btnShare", true);
	}
	
	function showExTypeScreen() : Void {
		_global.myTrace("view.showExTypeScreen");
		clearExTypeScreen();
		screens.setWindowsCenterToScreen();
		screens.showScreen("scnExType", false);
		screens.showScreen("scnMask", false);
	}
	
	function showExerciseScreen() : Void {
		screens.resetExerciseScreen();
		var viewObj = this;
		var intObj = new Object();
		intObj.intFunc = function() : Void {
			clearInterval(intObj.intID);
			viewObj.screens.showScreen("scnExercise", true);
			// v0.15.0, DL: inform user this exercise has been handmade by Handmaker program
			if (viewObj.control.data.currentExercise.settings.handmade) {
				viewObj.showPopup("handmadeExercise");
			}
		}
		intObj.intID = setInterval(intObj.intFunc, 250);
	}
	
	function showEmailScreen() : Void {
		screens.setWindowsCenterToScreen();
		screens.showScreen("scnEmail", false);
		screens.showScreen("scnMask", false);
	}
	
	function showFirstTimeScreen() : Void {
		screens.setWindowsCenterToScreen();
		screens.showScreen("scnFirstTime", false);
		screens.showScreen("scnMask", false);
	}
	
	function showFeedbackScreen() : Void {
		screens.setWindowsCenterToScreen();
		screens.showScreen("scnFeedback", false);
		screens.showScreen("scnMask", false);
	}
	
	function showBrowseScreen() : Void {
		screens.setWindowsCenterToScreen();
		screens.showScreen("scnBrowse", false);
		screens.showScreen("scnMask", false);
	}
	
	function showMask() : Void {
		screens.showScreen("scnMask", false);
		// v6.4.2.1 Can I enable the ESC key to clear the mask?
		screens.maskObj = new Object();
		screens.maskObj.master = this;
		screens.maskObj.onKeyUp = function() : Void {
			//_global.myTrace("onKeyUp in mask screen=" + Key.getCode());
			if (Key.getCode() == Key.ESCAPE) {
				this.master.hideMask();
			}
		}
		Key.addListener(screens.maskObj);		
	}
	
	function showExportScreen() : Void {
		previousScreen = (screens.scnCourse._visible) ? "scnCourse" : "scnUnit";
		screens.showScreen("scnExport", true);
	}
	
	function showImportScreen() : Void {
		screens.showScreen("scnImport", true);
	}
	
	function backFromExportScreen() : Void {
		if (previousScreen=="scnCourse") {
			showCourseScreen();
		} else {
			showUnitScreen();
		}
	}
	
	// popup functions
	function showPopup(s:String, v:String) : Void {
		popupReason = s;
		if (popupReason=="weblink") {
			screens.wins.setTitle("winPopup", screens.btns.getLiteral("btnURL"));
			screens.txts.txtPopupMsg.visible = false;
			screens.txts.txtLink.visible = true;
		} else {
			screens.wins.setTitle("winPopup", "");
			screens.txts.txtPopupMsg.visible = true;
			screens.txts.txtLink.visible = false;
		}
		switch (s) {
		case "licenceError" :
			screens.txts.txtPopupMsg.text = "Sorry, the licence for your account can't be read. Please contact your adminstator for help.";
			screens.setPopupButtons(1);
			break;
		// v6.4.3 New errors
		case "licenceAltered" :
			screens.txts.txtPopupMsg.text = "Sorry, your licence has been altered or has become corrupted. Please restore it.";
			screens.setPopupButtons(1);
			break;
		case "licenceExpired" :
			screens.txts.txtPopupMsg.text = "Sorry, your licence has expired. Please contact your supplier to renew it.";
			screens.setPopupButtons(1);
			break;
		case "noLicences" :
			screens.txts.txtPopupMsg.text = "Sorry, your licence does not allow you to run this program. Please contact your supplier to purchase it.";
			screens.setPopupButtons(1);
			break;
		case "productionServerNotMatch" :
			screens.txts.txtPopupMsg.text = "This program can only be run from one server. Please check your licence.";
			screens.setPopupButtons(1);
			break;
		case "blockAccess" :
			screens.txts.txtPopupMsg.text = "Block access!";
			screens.setPopupButtons(1);
			break;
		case "unregisteredUser" :
			screens.txts.txtPopupMsg.text = "The user is unregistered.";
			screens.setPopupButtons(1);
			break;
		case "loginFail" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgLoginFail");
			screens.setPopupButtons(1);
			break;
		case "loadingError" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgLoadingError");
			screens.setPopupButtons(1);
			break;
		case "savingError" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgSavingError");
			screens.setPopupButtons(1);
			break;
		case "connFail" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgConnFail");
			screens.setPopupButtons(1);
			break;
		case "promptDelCourse" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptDelCourse");
			screens.setPopupButtons(12);
			break;
		// v6.4.3 For bigger deletions
		case "promptDelCourseFolder" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptDelFolder");
			screens.setPopupButtons(12);
			break;
		case "promptDelUnit" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptDelUnit");
			screens.setPopupButtons(12);
			break;
		case "promptDelExercise" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptDelExercise");
			screens.setPopupButtons(12);
			break;
		case "funcNA" :
			screens.txts.txtPopupMsg.text = "This function is not yet available in this beta release.";
			screens.setPopupButtons(1);
			break;
		case "handmadeExercise" :	// v0.15.0, DL: inform user this exercise has been handmade by Handmaker program
			screens.txts.txtPopupMsg.text = "This exercise has been handmade by the Handmaker program. Author Plus Light/Pro may not be able to read it fully.";
			screens.setPopupButtons(1);
			break;
		case "promptExit" :	// v6.4.0.1, DL
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptExit");
			screens.setPopupButtons(12);
			break;
		case "promptExitSaving" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptSaving");
			screens.setPopupButtons(14);
			break;
		case "promptExitSavingExercise" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptSaving");
			screens.setPopupButtons(14);
			break;
		case "promptSavingExercise" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptSavingExercise");
			// AR v6.4.2.5 You should be able to cancel this command
			//screens.setPopupButtons(12);
			screens.setPopupButtons(14);
			break;
		case "weblink" :
			screens.txts.txtPopupMsg.text = "";
			screens.setPopupButtons(3);
			screens.txts.txtLink.text = v;
			Selection.setFocus(screens.txts.txtLink);
			Selection.setSelection(screens.txts.txtLink.text.length, screens.txts.txtLink.text.length);
			break;
		case "promptOverwriteCourse" :	// v0.16.1, DL: file locking
			screens.txts.txtPopupMsg.text = _global.replace(literals.getLiteral("msgPromptOverwriteCourse"), "[n]", v);
			screens.setPopupButtons(12);
			break;
		case "promptOverwriteExercise" :	// v0.16.1, DL: file locking
			screens.txts.txtPopupMsg.text = _global.replace(literals.getLiteral("msgPromptOverwriteExercise"), "[n]", v);
			screens.setPopupButtons(12);
			break;
		// gh#922
		case "promptTryLaterExercise":
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptTryLaterExercise");
			screens.setPopupButtons(1);
			break;
			
		case "noCoursesForExportError" :	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgNoCoursesForExportError");
			screens.setPopupButtons(1);
			break;
		case "loadCoursesForExportError" :	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgLoadCoursesForExportError");
			screens.setPopupButtons(1);
			break;
		case "exportError" :	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgExportError");
			screens.setPopupButtons(1);
			break;
		case "noSelectedCoursesForExportError":	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgNoSelectedCoursesForExportError");
			screens.setPopupButtons(1);
			break;
		case "noCoursesForImportError" :	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgNoCoursesForImportError");
			screens.setPopupButtons(1);
			break;
		case "loadCoursesForImportError" :	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgLoadCoursesForImportError");
			screens.setPopupButtons(1);
			break;
		case "unzipError" :	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgUnzipError");
			screens.setPopupButtons(1);
			break;
		case "importError" :	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgImportError");
			screens.setPopupButtons(1);
			break;
		case "noSelectedCoursesForImportError":	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgNoSelectedCoursesForImportError");
			screens.setPopupButtons(1);
			break;
		case "moreThanOneCourseForSCORMExportError" :	// v0.16.1, DL: share
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgMoreThanOneCourseForSCORMExportError");
			screens.setPopupButtons(1);
			break;
		case "lockMenuError" :	// v6.4.0.1, DL: locking
			screens.txts.txtPopupMsg.text = _global.replace(literals.getLiteral("msgLockMenuError"), "[n]", v);
			screens.setPopupButtons(1);
			break;
		case "lockExerciseError" :	// v6.4.0.1, DL: locking
			screens.txts.txtPopupMsg.text = _global.replace(literals.getLiteral("msgLockExerciseError"), "[n]", v);
			screens.setPopupButtons(1);
			break;
		case "promptReset" :
			screens.txts.txtPopupMsg.text = literals.getLiteral("msgPromptReset");
			screens.setPopupButtons(12);
			break;
		}
		screens.setWindowsCenterToScreen();
		screens.showScreen("scnPopup", false);
		screens.showScreen("scnMask", false);
	}
	
	function hidePopup() : Void {
		screens.hideScreen("scnPopup");
		if (!screens.scnExType._visible) {
			screens.hideScreen("scnMask");
		}
	}
	
	function onPopupBtnClick(s:String) : Void {
		control.onPopupResponse(popupReason, s);
		hidePopup();
	}
	
	function hideEmailScreen() : Void {
		screens.hideScreen("scnEmail");
		if (!screens.scnEmail._visible) {
			screens.hideScreen("scnMask");
		}
	}
	
	function hideFeedbackScreen() : Void {
		screens.hideScreen("scnFeedback");
		if (!screens.scnFeedback._visible) {
			screens.hideScreen("scnMask");
		}
	}
	
	function hideBrowseScreen() : Void {
		screens.hideScreen("scnBrowse");
		if (!screens.scnBrowse._visible) {
			screens.hideScreen("scnMask");
		}
	}
	
	function hideMask() : Void {
		// v6.4.2.1 Can I enable the ESC key to clear the mask?
		Key.removeListener(screens.maskObj);		
		screens.maskObj = undefined;
		screens.hideScreen("scnMask");
	}
	
	// clear screen functions
	function clearLoginScreen() : Void {
		screens.clearLoginFields();
	}
	
	function clearExTypeScreen() : Void {
		screens.chbs.resetCheckBoxesByName("chbExType", true);
	}
	
	function clearEmailScreen() : Void {
		screens.clearEmailFields();
	}
	
	// auth code screen functions
	function toggleAuthCodeTick(pass:Boolean) : Void {
		if (pass) {
			screens.showAuthCodeTick();
		} else {
			screens.hideAuthCodeTick();
		}
	}
	
	// browse file list functions
	function clearBrowseFileList() : Void {
		screens.clearBrowseFileList();
	}
	function fillInBrowseFileList(l:Array, fileType:String) : Void {
		screens.addFilesToBrowseList(l);
		screens.btns.browseFileType = fileType;
		screens.showBrowseList();
	}
	
	// course list functions
	function selectCourseByIndex(index : Number) : Void {
		screens.selectCourseByIndex(index);
	}
	
	function onAddCourse() : Void {
		myTrace("view.onAddCourse");
		screens.promptForNewCourse();
	}
	
	function onRenameCourse() : Void {
		if (screens.getSelectedCourseID()!=undefined) {
			screens.renameCourseOnList();
		}
	}

	// v6.4.3 Use xml for the dataProvider
	//function fillInCourseList(l:Array) : Void {
	function fillInCourseList(l:XML) : Void {
		
		// v6.4.1.4, DL: support for Clarity programs
		//var a = new Array();
		/*if (control.edit.getNoOfPrograms()>1) {
			for (var i=0; i<l.length; i++) {
				if (l[i].program==_global.NNW.interfaces.getInterface()) {
					a.push(l[i]);
				}
			}
		} else {
			for (var i=0; i<l.length; i++) {
				a.push(l[i]);
			}
		}*/
		
		screens.clearCourseList();
		screens.addCoursesToList(l);
		control.onFinishFillInCourseList();
	}
	// v6.4.3 Function to add a new course to the interface tree
	// This will all be done by the dnd tree directly
	function addToCourseList(Courses:Array) : Void {
		var newCourse = Courses[Courses.length-1];
		newCourse.name = "New course";
		myTrace("**NO NO** view.addToCourseList " + newCourse.id + ", name=" + newCourse.name);
		screens.trees.addItemToList("Course", newCourse);
	}
	
	// unit list functions
	function selectUnitByIndex(index : Number) : Void {
		screens.selectUnitByIndex(index);
	}
	
	function selectUnitByField(f:String, v:String) : Void {
		screens.selectUnitByField(f, v);
	}
	
	function onAddUnit() : Void {
		screens.promptForNewUnit();
	}
	
	function onRenameUnit() : Void {
		if (screens.getSelectedUnit()!=undefined) {
			screens.renameUnitOnList();
		}
	}
	
	function fillInUnitList(l:Array) : Void {
		screens.clearUnitList();
		screens.addUnitsToList(l);
		control.onFinishFillInUnitList();
	}
	
	function clearUnitList() : Void {
		screens.clearUnitList();
	}
	
	// v6.4.1.5, DL: add enabledFlag to a course
	// v6.4.2.5 This is actually setting the checkbox on the screen to reflect the xml contents. Use numbers
	//function fillInCourseEnabled(flag:String) : Void {
	function fillInCourseEnabled(flag:Number) : Void {
		// v6.4.4, RL: if that course is non-editable, can this be enable?
		//if (flag!="0" && flag!="4" && number(flag)>=32) {
		// v6.4.2.5 AR The only one that counts is disabled
		//if (flag!="0" && flag!=4) {
		if (flag&control.enabledFlag.disabled) {
			screens.setCourseEnabled(false);
		} else {
			screens.setCourseEnabled(true);
		}
	}
	
	// exercise list functions
	function selectExerciseByIndex(index : Number) : Void {
		screens.selectExerciseByIndex(index);
	}
	
	function onRenameExercise() : Void {
		if (screens.getSelectedExerciseID()!=undefined) {
			screens.renameExerciseOnList();
		}
	}
	
	function onMoveUnitUp() : Void {
		screens.moveUnitUp();
	}
	
	function onMoveUnitDown() : Void {
		screens.moveUnitDown();
	}
	
	function onMoveExerciseUp() : Void {
		screens.moveExerciseUp();
	}
	
	function onMoveExerciseDown() : Void {
		screens.moveExerciseDown();
	}
	
	function fillInExerciseList(l:Array) : Void {
		screens.clearExerciseList();
		screens.addExercisesToList(l);
		control.onFinishFillInExerciseList();
	}
	
	function clearExerciseList() : Void {
		screens.clearExerciseList();
	}
	
	// exercise type functions
	function onCancelExType() : Void {
		showUnitScreen();
	}
	
	function getSelectedExType() : String {
		switch (screens.getSelectedExType()) {
		case "chbExType01" :
			return "MultipleChoice";
			break;
		case "chbExType02" :
			return "Quiz";
			break;
		case "chbExType03" :
			return "Dropdown";
			break;
		case "chbExType04" :
			return "DragAndDrop";
			break;
		case "chbExType05" :
			return "DragOn";
			break;
		case "chbExType06" :
			return "Stopgap";
			break;
		case "chbExType07" :
			return "Cloze";
			break;
		case "chbExType08" :
			return "Countdown";
			break;
		case "chbExType09" :
			return "Analyze";
			break;
		case "chbExType10" :
			return "Presentation";
			break;
		case "chbExType11" :	// v0.16.0, DL: new exercise type
			return "TargetSpotting";
			break;
		case "chbExType12" :	// v0.16.0, DL: new exercise type
			return "Proofreading";
			break;
		// v6.4.3 New exercise type
		case "chbExType13" :
			return "Stopdrop";
			break;
		case "chbExType14" :
			return _global.g_strQuestionSpotterID;	// v6.5.1 Yiu add bew exercise type question spotter
			break;
		case "chbExType15" :
			return _global.g_strBulletID;	// v6.5.1 Yiu add bew exercise type question spotter
			break;
		case "chbExType16" :
			return _global.g_strErrorCorrection;	// v6.5.1 Yiu add bew exercise type question spotter
			break;
		case "chbExType17" :
			return "Analyze";
			break;
		case "chbExType18" :
			return _global.g_strSplitDropdown;
			break;
		case "chbExType19" :
			return _global.g_strSplitGapfill;
			break;
		}
	}
	
	// exercise functions
	function onExerciseBack() : Void {
		// 6.5.4.2 Yiu
		Selection.setSelection(0, 0);
		screens.resetExerciseScreen();
		// v0.4.4, DL: debug - should not select 1st unit after back from exercise
		// AR v6.4.2.5 You will only have called this if you are not saving the exercise, so there can be no need to update the menu
		// But we do need to release the lock
		_global.myTrace("view.onExerciseBack - jump to release locks");
		//control.addExerciseToMenu(); //control.readUnitXML();
		control.releaseExerciseFileToMenu();
	}
	
	function fillInExerciseDetails(ex:Object) : Void {
		screens.resetQuestionNo();
		screens.fillInExerciseName(ex.caption);
		// v6.4.3 Enabled flag for hiding exercise on menu
		screens.fillInEnabledFlag(ex.enabledFlag);
		
		//_global.myTrace("call fillInTitle with " + ex.title.value);
		// v6.5.1 original instruction text box is deleted, replaced by txtTitle2
		//screens.fillInTitle(ex.title.value);
		screens.fillInTitle2(ex.title.value);
		// End v6.5.1 original instruction text box is deleted, replaced by txtTitle2
		screens.fillInSettings(ex.settings);
		screens.setImageCategory(ex.image.category);
		
		// v0.16.1, DL: image
		fillInImage(ex.image);
		// v0.16.1, DL: audio
		fillInAudios(ex.audios);
		// v0.16.1, DL: video
		fillInVideos(ex.videos);
		// v6.4.2.7 Adding URLs
		fillInURLs(ex.URLs);
		// v0.16.1, DL: close all the 3 multimedia panels
		screens.closeImagePanel();
		screens.closeAudioPanel();
		screens.closeVideoPanel();
		// v6.4.2.7 Adding URLs
		screens.closeURLPanel();
		// v6.4.0, DL: close question multimedia panel
		screens.closeQuestionMMPanel();
		
		// v0.16.0, DL: image position
		screens.setImagePosition(ex.image.position);
		
		// v0.11.0, DL: reset text format in TextAreas
		screens.resetTextFormats();
		
		// v0.5.2, DL: set literals for different kinds of exercise
		screens.btns.setLabelsLiterals();
		screens.btns.setButtonsLiterals();
		
		// v0.5.2, DL: default not show slider (except gapfill)
		if (	ex.exerciseType=="Stopgap"	||
				ex.exerciseType=="Cloze"
			) {
			// v6.5.1 Yiu commented, new default gap length check box and slider 
			//screens.showSlider(true);
		} else {
			screens.showSlider(false);
		}
		
		// v0.12.0, DL: set no comment and upgrade buttons to Analyze exercise type
		// v6.5.4.2 Yiu commented to fix the comment button disappeared problem, Bug ID 1320
/*
		if (ex.exerciseType=="Analyze") {
			setVisible("btnEmail", false);
			setVisible("btnUpgrade", false);
		}
*/
		// End v6.5.4.2 Yiu commented to fix the comment button disappeared problem, Bug ID 1320
		
		screens.showStep1(true);
		screens.showStep2(true);
		screens.showStep3(false);
		
		// v0.16.0, DL: fill in comboScore if it's score-based feedback
		if (ex.settings.feedback.scoreBased) {
			screens.fillInScores(ex.scoreBasedFeedback);
		} else {
			screens.fillInScores();
		}
		
		screens.changeQuestionSegment();	// v0.16.1, DL: no need to pass exercise type as parameter
		// v0.16.1, DL: i'm trying to move all settings to one movieclip for faster loading and easier screen-design
		// v0.16.1, DL: set up settings screen according to exercise
		screens.setSettingsScreen(ex);
		
		// v0.16.1, DL: some settings are invisible in Lite
		setLiteProSettings(control._lite);
		
		screens.txts.txtTestOutput.text = ex.question[0].value;
		switch (ex.exerciseType) {
		case "MultipleChoice" :
			screens.showMakeFieldButton(false);
			screens.showFeedbackHint(true);
			screens.fillInQuestion(ex.parseInputString(ex.question[0].value));
			screens.fillInQuestionAudio(ex.questionAudios[0].filename, ex.questionAudios[0].mode);	// v0.16.1, DL: question audio
			screens.fillInOptions(ex, ex.getOptions(1));
			screens.fillInFeedback(ex.feedback[0].value);
			screens.fillInHint(ex.hint[0].value);
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtQuestion.vPosition = 0;
			screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
			screens.acds.acdFH.child1.txtHint.vPosition = 0;
			screens.txts.txtHintOnly.vPosition = 0;
			
			// v0.12.0, DL: add tab indexes
			// v0.15.0, DL: reorganize tab indexes
			screens.txts.txtQuestion.tabIndex = 201;
			screens.txts.txtOption0.tabIndex = 202;
			screens.txts.txtOption1.tabIndex = 203;
			screens.txts.txtOption2.tabIndex = 204;
			screens.txts.txtOption3.tabIndex = 205;
			//screens.acds.acdFH.child0.txtFeedback.tabIndex = 206;
			
			break;
		case "Quiz" :
			// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311, add Quiz split screen
			screens.showMakeFieldButton(false);
			screens.fillInQuestion(ex.parseInputString(ex.question[0].value));
			screens.fillInQuestionAudio(ex.questionAudios[0].filename, ex.questionAudios[0].mode);
			screens.fillInHint(ex.hint[0].value);
			screens.fillInTrueFalseText(ex.getOptions(1));
			screens.fillInTrueFalseOptions(ex.getOptions(1));
		
			if (!ex.settings.feedback.scoreBased && !ex.settings.feedback.groupBased) {
				screens.fillInDifferentFeedbackForQuiz(ex.getDifferentFeedback(1,0), ex.getDifferentFeedback(1,1));
			} else {
				screens.fillInFeedback(ex.feedback[0].value);
			}
			
			if (!ex.settings.misc.splitScreen) {
				screens.showFeedbackHint(true);
				
				screens.txts.txtQuestion.vPosition = 0;
				screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
				screens.acds.acdFH.child1.txtHint.vPosition = 0;
				screens.txts.txtHintOnly.vPosition = 0;
				
				screens.txts.txtQuestion.tabIndex = 201;
			} else {
				screens.showFeedbackHint(true, 312.9);
				screens.fillInText(ex.parseInputString(ex.text.value));
				
				screens.txts.txtSplitScreenText.vPosition = 0;
				screens.txts.txtSplitScreenQuestion.vPosition = 0;
				screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
				screens.acds.acdFH.child1.txtHint.vPosition = 0;
				screens.txts.txtHintOnly.vPosition = 0;
				
				screens.txts.txtSplitScreenText.tabIndex = 201;
				screens.txts.txtSplitScreenQuestion.tabIndex = 202;
			}
			// End v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311, add Quiz split screen
			
			break;
			
		// v6.5.1 Yiu fixing add alt ans before have a drop, commeted
		/*
		case "DragAndDrop" :
		// v6.4.3 Add new exercise type, item based drop-down
			screens.showMakeFieldButton(true);
			//if (ex.exerciseType=="DragAndDrop") {
				// v0.16.1, DL: split-screen exercise
			//	if (ex.settings.misc.splitScreen) {
			//		screens.showFeedbackHint(true, 312.9, 221.3);
			//		setVisible("btnUpgrade", false);
			//	} else {
			//		screens.showFeedbackHint(true);
			//		setVisible("btnUpgrade", true);
			//	}
			//} else {
				// v0.16.1, DL: split-screen exercise
				if (ex.settings.misc.splitScreen) {
					screens.showOptionsFeedbackHint(true, 312.9, 211.3, -117, -147);
					screens.moveFormattingButtons(12.6, 1);
					screens.moveMakeField(-195.05, 181.55);
					setVisible("btnUpgrade", false);
				} else {
					screens.showOptionsFeedbackHint(true);
					screens.moveFormattingButtons(-94.4, 1);
					screens.moveMakeField(-328.55, 121.55);
					setVisible("btnUpgrade", true);
				}
			//}
			screens.fillInText(ex.parseInputString(ex.text.value));	// v0.16.1, DL: for split-screen text
			screens.fillInQuestion(ex.parseInputString(ex.question[0].value));
			screens.fillInQuestionAudio(ex.questionAudios[0].filename, ex.questionAudios[0].mode);	// v0.16.1, DL: question audio
			screens.fillInOtherOptions(ex.getAnswers(1));
			screens.fillInFeedback(ex.feedback[0].value);
			screens.fillInHint(ex.hint[0].value);
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtQuestion.vPosition = 0;
			screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
			screens.acds.acdFH.child1.txtHint.vPosition = 0;
			screens.txts.txtHintOnly.vPosition = 0;
			
			// v0.12.0, DL: add tab indexes
			// v0.15.0, DL: reorganize tab indexes
			screens.txts.txtQuestion.tabIndex = 201;
			//screens.acds.acdFH.child0.txtFeedback.tabIndex = 202;
			
			break;
		// End v6.5.1 Yiu fixing add alt ans before have a drop, commeted
		*/
		
		// v6.5.1 Yiu fixing add alt ans before have a drop
		case "DragAndDrop" :
		case "Stopdrop" :
		case "Stopgap" :
			screens.showMakeFieldButton(true);
			/*if (ex.exerciseType=="DragAndDrop") {
				// v0.16.1, DL: split-screen exercise
				if (ex.settings.misc.splitScreen) {
					screens.showFeedbackHint(true, 312.9, 221.3);
					setVisible("btnUpgrade", false);
				} else {
					screens.showFeedbackHint(true);
					setVisible("btnUpgrade", true);
				}
			} else {*/
				// v0.16.1, DL: split-screen exercise
				
				//screens.showFeedbackHint(false);
				//screens.showOptionsFeedbackHint(false);
				/*
				if (ex.settings.misc.splitScreen) {
					screens.showOptionsFeedbackHint(true, 312.9, 211.3, -117, -147);
					screens.moveFormattingButtons(12.6, 1);
					screens.moveMakeField(-195.05, 181.55);
					setVisible("btnUpgrade", false);
				} else {
					screens.showOptionsFeedbackHint(true);
					screens.moveFormattingButtons(-94.4, 1);
					screens.moveMakeField(-328.55, 121.55);
					setVisible("btnUpgrade", true);
				} 
				*/
			
			//}
			screens.fillInText(ex.parseInputString(ex.text.value));	// v0.16.1, DL: for split-screen text
			screens.fillInQuestion(ex.parseInputString(ex.question[0].value));
			screens.fillInQuestionAudio(ex.questionAudios[0].filename, ex.questionAudios[0].mode);	// v0.16.1, DL: question audio
			screens.fillInOtherOptions(ex.getAnswers(1));
			screens.fillInFeedback(ex.feedback[0].value);
			screens.fillInHint(ex.hint[0].value);
			
			screens.visibleFeedbackAndHintIfADropPresent(); 
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtQuestion.vPosition = 0;
			screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
			screens.acds.acdFH.child1.txtHint.vPosition = 0;
			screens.txts.txtHintOnly.vPosition = 0;
			
			// v0.12.0, DL: add tab indexes
			// v0.15.0, DL: reorganize tab indexes
			screens.txts.txtQuestion.tabIndex = 201;
			//screens.acds.acdFH.child0.txtFeedback.tabIndex = 202;
			
			break;
			// End v6.5.1 Yiu fixing add alt ans before have a drop
		case "DragOn" :
		case "Cloze" :
		case "Dropdown" :
			screens.showMakeFieldButton(true);
			screens.showFeedbackHint(false);
			screens.showOptionsFeedbackHint(false);
			/* v0.14.0, DL: debug - no need to fill in feedback as no field will be selected as default */
			/*screens.fillInFeedback(ex.feedback[0].value);
			screens.fillInHint(ex.hint[0].value);*/
			screens.fillInText(ex.parseInputString(ex.text.value));
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtText.vPosition = 0;
			screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
			screens.acds.acdFH.child1.txtHint.vPosition = 0;
			screens.txts.txtHintOnly.vPosition = 0;
			
			break;
		case "Countdown" :
			screens.showMakeFieldButton(true);
			screens.showFeedbackHint(false);
			screens.fillInText(ex.parseInputString(ex.text.value));
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtText.vPosition = 0;
			
			break;
		case "Analyze" :
			screens.showMakeFieldButton(false);
			screens.showFeedbackHint(true, 312.9);
			screens.fillInQuestion(ex.parseInputString(ex.question[0].value));
			screens.fillInQuestionAudio(ex.questionAudios[0].filename, ex.questionAudios[0].mode);	// v0.16.1, DL: question audio
			screens.fillInOptions(ex, ex.getOptions(1));
			screens.fillInFeedback(ex.feedback[0].value);
			screens.fillInHint(ex.hint[0].value);
			screens.fillInText(ex.parseInputString(ex.text.value));
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtSplitScreenText.vPosition = 0;	// v0.16.1, DL: change txtRMCText to txtSplitScreenText
			screens.txts.txtSplitScreenQuestion.vPosition = 0;	// v0.16.1, DL: change txtRMCQuestion to txtSplitScreenQuestion
			screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
			screens.acds.acdFH.child1.txtHint.vPosition = 0;
			screens.txts.txtHintOnly.vPosition = 0;
			
			// v0.15.0, DL: reorganize tab indexes
			screens.txts.txtSplitScreenText.tabIndex = 201;	// v0.16.1, DL: change txtRMCText to txtSplitScreenText
			screens.txts.txtSplitScreenQuestion.tabIndex = 202;	// v0.16.1, DL: change txtRMCQuestion to txtSplitScreenQuestion
			screens.txts.txtRMCOption0.tabIndex = 203;
			screens.txts.txtRMCOption1.tabIndex = 204;
			screens.txts.txtRMCOption2.tabIndex = 205;
			screens.txts.txtRMCOption3.tabIndex = 206;
			//screens.acds.acdFH.child0.txtFeedback.tabIndex = 207; //screens.acds.acdRMCFH.child0.txtFeedback.tabIndex = 207;
			
			break;
		case "Presentation" :
			screens.showMakeFieldButton(false);
			screens.showFeedbackHint(false);
			screens.fillInText(ex.parseInputString(ex.text.value));
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtText.vPosition = 0;
			
			break;
		case _global.g_strBulletID:	// v6.5.1 Yiu add bew exercise type question spotter
			screens.showMakeFieldButton(false);
			screens.showFeedbackHint(false);
			screens.fillInText(ex.parseInputString(ex.text.value));
			screens.fillInQuestion(ex.parseInputString(ex.question[0].value));
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtText.vPosition = 0;
			
			break;
		case "TargetSpotting" :	// v0.16.0, DL: new exercise type
		case "Proofreading" :	// v0.16.0, DL: new exercise type
			screens.showMakeFieldButton(true);
			screens.showFeedbackHint(false);
			screens.fillInText(ex.parseInputString(ex.text.value));
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtText.vPosition = 0;
			
			break;
			
		case _global.g_strQuestionSpotterID:	// v6.5.1 Yiu? add bew exercise type question spotter			
			screens.showMakeFieldButton(true);
			screens.showFeedbackHint(false);
			screens.fillInText(ex.parseInputString(ex.text.value));
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtText.vPosition = 0;
		
			// v0.16.1, DL: split-screen exercise
			if (ex.settings.misc.splitScreen) {
				//screens.showOptionsFeedbackHint(true, 312.9, 211.3, -117, -147);
				screens.moveFormattingButtons(12.6, 1);
				screens.moveMakeField(-195.05, 181.55);
				setVisible("btnUpgrade", false);
			} else {
				//screens.showOptionsFeedbackHint(true);
				screens.moveFormattingButtons(-94.4, 21);
				screens.moveMakeField(-288.55, 171.55);
				setVisible("btnUpgrade", true);
			}
			
			screens.fillInText(ex.parseInputString(ex.text.value));	// v0.16.1, DL: for split-screen text
			screens.fillInQuestion(ex.parseInputString(ex.question[0].value));
			screens.fillInQuestionAudio(ex.questionAudios[0].filename, ex.questionAudios[0].mode);	// v0.16.1, DL: question audio
			screens.fillInOtherOptions(ex.getAnswers(1));
			screens.fillInFeedback(ex.feedback[0].value);
			//screens.fillInHint(ex.hint[0].value);
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtQuestion.vPosition = 0;
			screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
			screens.acds.acdFH.child1.txtHint.vPosition = 0;
			screens.txts.txtHintOnly.vPosition = 0;
			
			// v0.12.0, DL: add tab indexes
			// v0.15.0, DL: reorganize tab indexes
			screens.txts.txtQuestion.tabIndex = 201;
			//screens.acds.acdFH.child0.txtFeedback.tabIndex = 202;
			// v6.5.1 Yiu fixing add alt ans before have a drop
			screens.visibleFeedbackOnlyMcIfADropPresent(); 
			break;
		case _global.g_strErrorCorrection:
			screens.showMakeFieldButton(true);
			screens.showFeedbackHint(false);
			screens.showOptionsFeedbackHint(false);
			
			screens.fillInText(ex.parseInputString(ex.text.value));
			
			// v0.15.0, DL: set vPos of TextAreas to 0
			screens.txts.txtText.vPosition = 0;
			screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
			screens.acds.acdFH.child1.txtHint.vPosition = 0;
			screens.txts.txtHintOnly.vPosition = 0; 
			break;
		}
		_global.styles.TextArea.setStyle("color", 0x000000);
		_global.styles.TextArea.setStyle("fontSize", 13);
		_global.styles.TextArea.setStyle("backgroundColor", 0xFFFFFF);
		//_global.styles.TextArea.setStyle("fontFamily", "Verdana");
		
		// v0.6.0, DL: after filling in the settings, exercise will be updated, which is not correct
		control.data.currentExercise.noChange = true;
		
		control.onFinishFillInExerciseDetails();
	}
	
	function fillInQuestionDetails(ex:Object, qNo:Number) : Void {
		screens.changeQuestionSegment();	// v0.16.1, DL: no need to pass exercise type as parameter
		switch (ex.exerciseType) {
		case "MultipleChoice" :
		case "Analyze" :
			screens.fillInQuestion(ex.parseInputString(ex.question[qNo-1].value));
			screens.fillInQuestionAudio(ex.questionAudios[qNo-1].filename, ex.questionAudios[qNo-1].mode);	// v0.16.1, DL: question audio
			screens.fillInOptions(ex, ex.getOptions(qNo));
			screens.fillInFeedback(ex.feedback[qNo-1].value);
			screens.fillInHint(ex.hint[qNo-1].value);
			break;
		case "Quiz" :
			screens.fillInQuestion(ex.parseInputString(ex.question[qNo-1].value));
			screens.fillInQuestionAudio(ex.questionAudios[qNo-1].filename, ex.questionAudios[qNo-1].mode);	// v0.16.1, DL: question audio
			screens.fillInTrueFalseOptions(ex.getOptions(qNo));
			
			// v0.16.0, DL: for different feedback of quiz
			if (!ex.settings.feedback.scoreBased && !ex.settings.feedback.groupBased) {
				screens.fillInDifferentFeedbackForQuiz(ex.getDifferentFeedback(qNo,0), ex.getDifferentFeedback(qNo,1));
			} else {
				screens.fillInFeedback(ex.feedback[qNo-1].value);
			}
			
			screens.fillInHint(ex.hint[qNo-1].value);
			break;
		//case "DragAndDrop" :	// v6.5.1 Yiu fixing alt ans problem for DragAndDrop, commetned
		case _global.g_strQuestionSpotterID:	// v6.5.1 Yiu add bew exercise type question spotter
			screens.fillInQuestion(ex.parseInputString(ex.question[qNo-1].value));
			screens.fillInQuestionAudio(ex.questionAudios[qNo-1].filename, ex.questionAudios[qNo-1].mode);	// v0.16.1, DL: question audio
			screens.fillInOtherOptions(ex.getAnswers(qNo));
			screens.fillInFeedback(ex.feedback[qNo-1].value);
			screens.fillInHint(ex.hint[qNo - 1].value);
			screens.visibleFeedbackOnlyMcIfADropPresent();
		case _global.g_strBulletID:	// v6.5.1 Yiu add bew exercise type question spotter
		// v6.4.3 Add new exercise type, item based drop-down
			screens.fillInQuestion(ex.parseInputString(ex.question[qNo-1].value));
			screens.fillInQuestionAudio(ex.questionAudios[qNo-1].filename, ex.questionAudios[qNo-1].mode);	// v0.16.1, DL: question audio
			screens.fillInOtherOptions(ex.getAnswers(qNo));
			screens.fillInFeedback(ex.feedback[qNo-1].value);
			screens.fillInHint(ex.hint[qNo-1].value);
			break;
			// v6.5.1 Yiu fixing add alt ans before have a drop
		case "Stopdrop" :
		case "Stopgap":		// v6.5.1 Yiu fixing alt ans problem of Stopgap
		case "DragAndDrop" :	// v6.5.1 Yiu fixing alt ans problem for DragAndDrop
			screens.fillInQuestion(ex.parseInputString(ex.question[qNo-1].value));
			screens.fillInQuestionAudio(ex.questionAudios[qNo-1].filename, ex.questionAudios[qNo-1].mode);	// v0.16.1, DL: question audio
			screens.fillInOtherOptions(ex.getAnswers(qNo));
			screens.fillInFeedback(ex.feedback[qNo-1].value);
			screens.fillInHint(ex.hint[qNo-1].value);
			screens.visibleFeedbackAndHintIfADropPresent();
			// invisble the feedbackHint when the exercise is first opened
			//screens.showOptionsFeedbackHint(false);
			break;
			// End v6.5.1 Yiu fixing add alt ans before have a drop
		}

		if (	ex.exerciseType == "Countdown" || 
				ex.exerciseType == "Stopgap" || 
				ex.exerciseType == "Cloze") {
			var gapLength:Number;
			gapLength	= Number(ex.m_aryGapLength[qNo -1]);
			
			if (gapLength == undefined || isNaN(gapLength))
			{
				// Check if default gap length was set
				if (screens.chbs.getChecked("chbSameLengthGaps"))
				{
					gapLength	= Number(screens.sliderSameLengthGap.getValue());
				}	// Check if uniform gap was set
				else if (screens.chbs.getChecked("chbDefaultLengthGaps"))
				{
					gapLength	= Number(screens.sliderDefaultLengthGap.getValue());
				} else {
					var nDefaultGapLength:Number;
					nDefaultGapLength	= 1;
					gapLength			= nDefaultGapLength;
				}
			}
			
			screens.fillInGapLength(gapLength);
		}
		
		// v0.15.0, DL: set vPos of TextAreas to 0
		screens.txts.txtQuestion.vPosition = 0;
		screens.txts.txtSplitScreenQuestion.vPosition = 0;	// v0.16.1, DL: change txtRMCQuestion to txtSplitScreenQuestion
		screens.acds.acdFH.child0.txtFeedback.vPosition = 0;
		screens.acds.acdFH.child1.txtHint.vPosition = 0;
		screens.txts.txtFeedbackOnly.vPosition = 0;	// v0.16.0, DL
		screens.txts.txtHintOnly.vPosition = 0;	// v0.16.0, DL
	}
	
	// v0.16.0, DL: fill in score-based feedback
	function fillInScoreBasedFeedback(ex:Object, score:Number) : Void {
		screens.fillInScoreBasedFeedback(ex.scoreBasedFeedback[score].value);
	}
	
	function updateExerciseBeforeSaving() {
		screens.updateWholeExercise();
	}
	
	// v0.14.0, DL: option list functions
	function onRenameOption() {
		screens.renameOptionOnList();
	}
	
	function deleteSelectedOption() {
		screens.delOptionFromList();
		updateOptionsList();
	}
	
	function updateOptionsList() {
		screens.updateWholeExercise();
	}
	
	// function pBar functions
	function setupPBar(event:String) {
		screens.showScreen("scnMask", false);
		pBar = screens.pBar;
		switch (event) {
		case "byebye" :
			pBar.eventAfter = "byebye";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "backCourse" :
			pBar.eventAfter = "backCourse";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "showExTypeScreen" :
			pBar.eventAfter = "showExTypeScreen";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "showExercise" :
			pBar.eventAfter = "showExercise";
			pBar.label_txt.text = literals.getLiteral("msgLoadingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveFiles" :
			pBar.eventAfter = "";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveCoursesPreview" :
			pBar.eventAfter = "previewCourses";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveMenuPreview" :
			pBar.eventAfter = "previewMenu";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveUnit" :	// v6.4.0.1, DL
			pBar.eventAfter = "readUnit";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveUnitReloadUnit" :	// v6.4.0.1, DL
			pBar.eventAfter = "reloadUnit";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveExercise" :
			pBar.eventAfter = "";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveExercisePreview" :
			pBar.eventAfter = "previewExercise";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveExerciseBackUnit" :
			pBar.eventAfter = "backUnit";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveExerciseExit" :
			pBar.eventAfter = "byebye";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "saveCourseName" :
			pBar.eventAfter = "saveCourseName";
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 1;
			var total = 2;
			break;
		case "addCourseShowMenu" :	// v6.4.1, DL: enter menu after adding a course
		case "addCourseFillMenu" :		// v6.4.1.5, DL: enter menu after adding the first course (for Lite version)
			pBar.eventAfter = event;
			pBar.label_txt.text = literals.getLiteral("msgSavingFiles");
			var start = 0;
			var total = 2;
			break;
		case "sharing" :		// v6.4.2.1 AR Added to show progress during preparation for share
			pBar.eventAfter = "";
			pBar.label_txt.text = literals.getLiteral("msgLoadingFiles");
			var start = 0;
			var total = 2;
			break;
		}
		setProgressOnPBar(start, total);
	}
	
	function setProgressOnPBar(v1:Number, v2:Number) : Void {
		//myTrace("setProgOnPBar " + v1 + " of " + v2);
		pBar.setProgress(v1, v2);
		pBar._visible = true;
		screens.showScreen("scnMask", false);
		if (v1 == v2) {
			/* set a interval for clearing the progress bar (make it disappear smoothly) */
			var viewObj = this;
			var intObj = new Object();
			intObj.intFunc = function() {
				clearInterval(intObj.intID);
				/* clear the progress bar */
				viewObj.myTrace("Progress finished.");
				viewObj.pBar._visible = false;
				/* action on eventAfter */
				if (viewObj.pBar.eventAfter.length>0) {
					viewObj.actOnEventAfter(viewObj.pBar.eventAfter);
				} else {
					viewObj.screens.hideScreen("scnMask");
				}
			}
			intObj.intID = setInterval(intObj.intFunc, 500);
		}
	}
	
	function actOnEventAfter(eventAfter:String) : Void {
		switch (eventAfter) {
		case "backCourse" :
			screens.hideScreen("scnMask");
			control.readCourseXML();
			break;
		case "showExTypeScreen" :
			screens.hideScreen("scnMask");
			showExTypeScreen();
			break;
		case "showExercise" :
			control.xmlExercise.loadXML();
			break;
		case "byebye" :
			screens.hideScreen("scnMask");
			control.byebye();
			break;
		case "backUnit" :
			screens.hideScreen("scnMask");
			control.addExerciseToMenu();
			break;
		case "previewCourses" :
		case "previewMenu" :
		case "previewExercise" :
			screens.hideScreen("scnMask");
			control.setPreviewSessionVariables(eventAfter);
			break;
		case "readUnit" :
			control.readUnitXML("");
			break;
		case "reloadUnit" :
			screens.hideScreen("scnMask");
			// v6.4.1, DL: move to xmlUnitClass
			//control.releaseExerciseFileToMenu();
			break;
		case "saveCourseName" :
			control.saveUnit("");
			break;
		case "addCourseShowMenu" :
			// v6.4.3 Now through the tree
			//control.onDoubleClickingItemOnList(screens.dgs.dgCourse);
			control.onDoubleClickingOnTree(screens.trees.treeCourse.selectedNode);
			break;
		case "addCourseFillMenu" :	// v6.4.1.5, DL: enter menu after adding the first course (for Lite version)
			control.loadUnitXML();
			break;
		}
	}
	
	function setLiteProSettings(lite:Boolean) : Void {
		// v6.4.1, DL: set software logo
		screens.setAPLogo(lite);
		
		if (lite) {
			setVisible("btnBackCourse", false);	/* disable "back" button on scnUnit */
			setVisible("btnShare", false);	// v0.16.1, DL: share (importing/exporting)
			screens.setLiteSettings();
			// v6.4.1.2, DL: for FSP set windows title
			//_root.mdm.setwindowtitle("Author Plus Light");
			//_root.mdm.setapplicationtitle("Author Plus Light");
			mdm.Application.title = "Author Plus Light";
		} else {
			screens.setProSettings();
			// v6.4.1.2, DL: for FSP set windows title
			//_root.mdm.setwindowtitle("Author Plus Pro");
			//_root.mdm.setapplicationtitle("Author Plus Pro");
			mdm.Application.title = "Author Plus Pro";
		}
		
		// v6.4.0.1, DL: no saveCourse button from now on
		setVisible("btnSaveCourse", false);
	}

	// v0.16.1, DL: set image category to your graphic or no graphic (no graphic uploaded by user)
	function setImageCategory(cat:String) : Void {
		screens.setImageCategory(cat);
		screens.setImagePosition("top-right");	// it'll disable the position settings if no graphic
	}
	
	// v0.16.1, DL: set instructions audio to unselected (no audio uploaded by user)
	function setAudioCheckBox(t:String, b:Boolean) : Void {
		screens.setAudioCheckBox(t, b);
	}
	
	// v0.16.1, DL: set video to unselected (no video uploaded by user)
	function setVideoCheckBox(t:String, b:Boolean) : Void {
		screens.setVideoCheckBox(t, b);
	}
	
	// v0.16.1, DL: fill in export tree data provider with courses xml
	function fillInExportTreeDataProvider(x:XML) : Void {
		// v6.4.0.1, DL: debug - no, this is wrong!
		// if sharing is done in a course, just show the course. no need to pre-deselect other courses
		/*if (screens.scnUnit._visible) {
			for (var i in x.childNodes) {
				var courseNode = x.childNodes[i];
				if (courseNode.attributes.id!=control.data.currentCourse.id) {
					courseNode.attributes.check = "0";
					for (var j in courseNode.childNodes) {
						var unitNode = courseNode.childNodes[j];
						unitNode.attributes.check = "0";
						for (var k in unitNode.childNodes) {
							var exNode = unitNode.childNodes[k];
							exNode.attributes.check = "0";
						}
					}
				}
			}
		}*/
		screens.trees.treeExport.dataProvider = x;
		// v6.4.2.1 AR I have added in the progress bar, so tell it that it is finished
		//myTrace("fillInExportTree call to pbar");
		setProgressOnPBar(2, 2);
		showExportScreen();
	}
	
	// v0.16.1, DL: fill in import tree data provider with courses xml
	function fillInImportTreeDataProvider(x:XML) : Void {
		screens.trees.treeImport.dataProvider = x;
		// AR v6.4.2.5 Open up the import tree
		screens.trees.treeImport.dataProvider.openUpToLevel(screens.trees.treeImport, 2)
		showImportScreen();
	}
	
	// v0.16.1, DL: fill in image, audio & video file names
	function fillInImage(image:Object) : Void {
		screens.fillInImage(image);
	}
	function fillInAudios(audios:Object) : Void {
		screens.fillInAudios(audios);
	}
	// v6.4.2.7 Adding URLs
	function fillInURLs(URLs:Object) : Void {
		screens.fillInURLs(URLs);
	}	
	function fillInVideos(videos:Object) : Void {
		screens.fillInVideos(videos);
		screens.setVideoPosition(videos);
	}
}
