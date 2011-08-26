import Classes.errorBox;

class Classes.errorCheckClass {
	var errorBoxes:Object;
	
	function errorCheckClass() {
		errorBoxes = new Object();
	}
	
	function changeErrorLiterals() : Void {
		//_global.myTrace("set literals in errorbox");
		for (var i in errorBoxes) {
			errorBoxes[i].setTextInTextArea();
		}
	}
	
	function passMenuTest() : Boolean {
		var pass = true;
		if (!passCourseNameCheck()) {
			pass = false;
		}
		return pass;
	}
	
	function passCreateExerciseTest() : Boolean {
		var pass = true;
		if (!passHasUnitsCheck()) {
			pass = false;
		} else if  (!passSelectedUnitCheck()) {
			pass = false;
		}
		return pass;
	}
	
	function passSaveExerciseTest() : Boolean {
		var pass = true;
		if (!passExerciseNameCheck()) {
			pass = false;
			// AR v6.4.2.5 Not clear to me why you have to type any instructions. But never mind.
		} else if (!passExerciseTitleCheck()) {
			pass = false;
		} else {
			// v6.4.1, DL: do not check whether there is a question or there is some text
			// moved into oldExerciseQuestionTextCheck()
			pass = true;
		}
		return pass;
	}
	
	// v6.4.1, DL: this function is not used
	// it is copied from the else statement of passSaveExerciseTest()
	function oldExerciseQuestionTextCheck() : Void {
		var pass = true;
			var exType = _global.NNW.control.data.currentExercise.exerciseType;
			switch (exType) {
			case "MultipleChoice" :
				if (!passExerciseQuestionCheck(exType)) {
					pass = false;
				} /*else if (!passExerciseOptionsCheck(exType)) {
					pass = false;
				}*/
				break;
			case "Quiz" :
			case "DragAndDrop" :
			case "Stopgap" :
				if (!passExerciseQuestionCheck(exType)) { pass = false; }
				break;
			case "Dropdown" :
				if (!passExerciseTextCheck(exType)) {
					pass = false;
				} /*else if (!passExerciseOptionsCheck(exType)) {
					pass = false;
				}*/
				break;
			case "Cloze" :
			case "DragOn" :
			case "Countdown" :
			case "Presentation" :
			case _global.g_strBulletID:		// Yiu v6.5.1 added new type Bullet
			case _global.g_strQuestionSpotterID: // v6.5.1 Yiu add bew exercise type question spotter
			case "TargetSpotting" :	// v0.16.0, DL: new exercise type
			case "Proofreading" :	// v0.16.0, DL: new exercise type
				if (!passExerciseTextCheck(exType)) { pass = false; }
				break;
			case "Analyze" :
				if (!passExerciseTextCheck(exType)) {
					pass = false;
				} else if (!passExerciseQuestionCheck(exType)) {
					pass = false;
				} /*else if (!passExerciseOptionsCheck(exType)) {
					pass = false;
				}*/
				break;
			}
	}
	
	function passCourseNameCheck() : Boolean {
		var screens = _global.NNW.screens;
		if (screens.scnUnit._visible) {	// v0.16.0, DL: if unit screen is not showing, there's no need to check
			if (screens.txts.txtCourseName.text!=undefined && _global.trim(screens.txts.txtCourseName.text)!="") {
				return true;
			} else {
				var p = screens.scnUnit;
				var n = "CourseNameRequiredError";
				errorBoxes[n] = new errorBox();
				errorBoxes[n].parent = p;
				errorBoxes[n].name = n;
				errorBoxes[n].setPosition(400, 30);
				errorBoxes[n].setSize(180, 100);
				errorBoxes[n].createErrorBox();
				return false;
			}
		} else {
			return true;
		}
	}
	
	function passExerciseNameCheck() : Boolean {
		var screens = _global.NNW.screens;
		if (screens.txts.txtExerciseName.text!=undefined && _global.trim(screens.txts.txtExerciseName.text)!="") {
			return true;
		} else {
			var p = screens.scnExercise;
			var n = "ExerciseNameRequiredError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(345, 9);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	function passExerciseTitleCheck() : Boolean {
		var screens = _global.NNW.screens;
		//if (screens.txts.txtTitle.text!=undefined && _global.trim(screens.txts.txtTitle.text)!="") {	// v6.5.1 original instruction text box is deleted, replaced by txtTitle2
		if (screens.txts.txtTitle2.text!=undefined && _global.trim(screens.txts.txtTitle2.text)!="") {	// v6.5.1 original instruction text box is deleted, replaced by txtTitle2
			return true;
		} else {
			var p = screens.scnExercise;
			var n = "ExerciseTitleRequiredError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(345, 9);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	function passExerciseTextCheck(exType:String) : Boolean {
		if (exType=="Analyze") {
			var tFieldName = "txtSplitScreenText";	// v0.16.1, DL: change txtRMCText to txtSplitScreenText
		} else {
			var tFieldName = "txtText";
		}
		
		var screens = _global.NNW.screens;
		// check if it's empty
		if (screens.txts[tFieldName].label.text!=undefined && _global.trim(_global.replace(screens.txts[tFieldName].label.text, "\r", ""))!="") {
			if (	exType=="Dropdown"						||
					exType=="DragOn"						||
					exType=="Cloze"							||
					exType=="TargetSpotting"				||
					exType=="Proofreading"					||
					exType==_global.g_strQuestionSpotterID // v6.5.1 Yiu? add bew exercise type question spotter
					) {
				// check if it has fields
				if (screens.txts[tFieldName].label.htmlText.indexOf("_global.fieldClick", 0)==-1) {
					// no fields => error
					var p = screens.scnExercise;
					var n = "ExerciseTextWithFieldRequiredError";
					errorBoxes[n] = new errorBox();
					errorBoxes[n].parent = p;
					errorBoxes[n].name = n;
					errorBoxes[n].setPosition(345, 9);
					errorBoxes[n].setSize(180, 100);
					errorBoxes[n].createErrorBox();
					return false;
				}
			}
		// empty => error
		} else {
			var p = screens.scnExercise;
			var n = "ExerciseTextRequiredError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(345, 9);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
		
		var str = screens.txts[tFieldName].label.text;
		var searchIndex = 0;
		var i = str.indexOf("\r", searchIndex);
		while (i>-1) {
			if (i>1000+searchIndex) {
				// too many words in a paragraph
				var p = screens.scnExercise;
				var n = "ExerciseTextParagraphTooLongError";
				errorBoxes[n] = new errorBox();
				errorBoxes[n].parent = p;
				errorBoxes[n].name = n;
				errorBoxes[n].setPosition(345, 9);
				errorBoxes[n].setSize(180, 100);
				errorBoxes[n].createErrorBox();
				return false;
			} else {
				searchIndex = i+1;
				i = str.indexOf("\r", searchIndex);
			}
		}
		return true;
	}
	function passExerciseQuestionCheck(exType:String) : Boolean {
		/* v0.12.0, DL: get all questions and see if they are filled in, and have a gap */
		var checking = new Array();
		var pass = true;
		var emptyQNo = 0;
		var q = _global.NNW.control.data.currentExercise.question;
		for (var i=0; i<q.length; i++) {
			var empty = false;
			var hasField = false;
			if (q[i].value==undefined || q[i].value=="") {
				empty = true;
			} else {
				var field = _global.NNW.screens.d1_txt;
				field.htmlText = "";	// just to clear it up
				field.htmlText = q[i].value;
				if (_global.trim(_global.replace(field.text, "\r", ""))=="") {
					empty = true;
					q[i].value = "";
				} else {
					hasField = (field.htmlText.indexOf("_global.fieldClick", 0)>-1) ? true : false;
				}
			}
			checking[i] = new Object({empty:empty, hasField:hasField});
			//_global.myTrace("question "+i+" = "+_global.trim(field.text));
			//_global.myTrace("checking = "+checking[i].empty)
		}
		
		/* v0.12.1, DL: if there is some answers in a group but no question, it's empty */
		if (exType=="MultipleChoice"||exType=="Analyze") {
			var gpLimit = _global.NNW.control.data.currentExercise.fieldManager.getNewGroupNo();
			for (var i=1; i<gpLimit; i++) {
				var options = _global.NNW.control.data.currentExercise.fieldManager.getTargetsOfSameGroup(i);
				var ansCount = 0;
				for (var j=0; j<options.length; j++) {
					if (options[j].value!=undefined && options[j].value!="") {
						ansCount++;
					}
				}
				if (ansCount>0 && (checking[i-1]==undefined || checking[i-1].empty)) {
					pass = false;
					emptyQNo = i;
					break;
				}
			}
		}
		
		// check if there's some empty question before other question(s)
		for (var i=0; i<checking.length; i++) {
			if (checking[i].empty) {
				for (var j=i+1; j<checking.length; j++) {
					if (!checking[j].empty) {
						pass = false;
						emptyQNo = i+1;
						break;
					}
				}
				if (!pass) {
					break;
				}
			}
		}
		if (pass && checking[0].empty) {
			pass = false;
			emptyQNo = 1;
		}
		
		// if pass, there's no empty question
		if (pass) {
			// if drag'n'drop or stopgap, need to check for fields
			if (exType=="DragAndDrop"||exType=="Stopgap") {
				for (var i=0; i<checking.length; i++) {
					if (!checking[i].empty && !checking[i].hasField) {
						pass = false;
						emptyQNo = i+1;
						break;
					}
				}
				if (pass) {
					return true;
				} else {
					var p = _global.NNW.screens.scnExercise;
					var n = "ExerciseQuestionWithFieldRequiredError";
					errorBoxes[n] = new errorBox();
					errorBoxes[n].parent = p;
					errorBoxes[n].name = n;
					errorBoxes[n].attr = new Object({n:emptyQNo});
					errorBoxes[n].setPosition(345, 9);
					errorBoxes[n].setSize(180, 100);
					errorBoxes[n].createErrorBox();
					return false;
				}
			} else {
				return true;
			}
		
		// if not pass, there's empty question, prompt the user
		} else {
			var p = _global.NNW.screens.scnExercise;
			var n = "ExerciseQuestionRequiredError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].attr = new Object({n:emptyQNo});
			errorBoxes[n].setPosition(345, 9);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	function passExerciseOptionsCheck(exType:String) : Boolean {
		/* v0.12.0, DL: check if there are more than 1 option in a question/field */
		var fieldManager = _global.NNW.control.data.currentExercise.fieldManager;
		var q = _global.NNW.control.data.currentExercise.question;
		var gpLimit = fieldManager.getNewGroupNo();
		var idLimit = fieldManager.getNewID();
		var onlyOneAnsGp = 0;
		var noCorrectAns = 0;
		
		if (exType=="MultipleChoice"||exType=="Analyze") {
			for (var i=1; i<gpLimit; i++) {
				if (q[i-1].value!=undefined) {
					var empty = false;
					var field = _global.NNW.screens.d1_txt;
					field.htmlText = "";	// just to clear it up
					field.htmlText = q[i].value;
					if (_global.trim(_global.replace(field.text, "\r", ""))=="") {
						empty = true;
					}
					if (!empty) {
						var options = fieldManager.getTargetsOfSameGroup(i);
						var ansCount = 0;
						var hasCorrect = false;
						for (var j=0; j<options.length; j++) {
							if (options[j].value!=undefined && options[j].value!="") {
								ansCount++;
								if (options[j].correct=="true") { hasCorrect = true; }
							}
						}
						if (ansCount<2) {
							onlyOneAnsGp = i;
							break;
						} else if (!hasCorrect) {
							noCorrectAns = i;
							break;
						}
					}
				}
			}
			var screens = _global.NNW.screens;
			if (onlyOneAnsGp>0) {
				var p = _global.NNW.screens.scnExercise;
				var n = "ExerciseQuestionOptionsRequiredError";
				errorBoxes[n] = new errorBox();
				errorBoxes[n].parent = p;
				errorBoxes[n].name = n;
				errorBoxes[n].attr = new Object({n:onlyOneAnsGp});
				errorBoxes[n].setPosition(345, 9);
				errorBoxes[n].setSize(180, 100);
				errorBoxes[n].createErrorBox();
				return false;
			} else if (noCorrectAns>0) {
				var p = _global.NNW.screens.scnExercise;
				var n = "ExerciseQuestionCorrectRequiredError";
				errorBoxes[n] = new errorBox();
				errorBoxes[n].parent = p;
				errorBoxes[n].name = n;
				errorBoxes[n].attr = new Object({n:noCorrectAns});
				errorBoxes[n].setPosition(345, 9);
				errorBoxes[n].setSize(180, 100);
				errorBoxes[n].createErrorBox();
				return false;
			} else {
				return true;
			}
		} else if (exType=="Dropdown") {
			for (var i=1; i<gpLimit; i++) {
				var options = fieldManager.getAnswers(i);
				var ansCount = 0;
				var ans = new Array();
				for (var j=0; j<options.length; j++) {
					if (options[j].value!=undefined && options[j].value!="") {
						ansCount++;
						/* v0.13.0, DL: not to count duplicated options in dropdown */
						for (var k=options.length-1; k>j; k--) {
							if (options[j].value==options[k].value) {
								ansCount--;
								break;
							}
						}
					}
				}
				if (ansCount<2) {
					onlyOneAnsGp = i;
					break;
				}
			}
			var screens = _global.NNW.screens;
			if (onlyOneAnsGp>0) {
				var p = _global.NNW.screens.scnExercise;
				var n = "ExerciseOptionsRequiredError";
				errorBoxes[n] = new errorBox();
				errorBoxes[n].parent = p;
				errorBoxes[n].name = n;
				errorBoxes[n].setPosition(345, 9);
				errorBoxes[n].setSize(180, 100);
				errorBoxes[n].createErrorBox();
				return false;
			} else {
				return true;
			}
		}
	}
	
	function passHasUnitsCheck() : Boolean {
		if (_global.NNW.screens.dgs.dgUnit.length>0 && _global.NNW.control.data.currentCourse.hasUnits()) {
			//_global.myTrace("pass has units test");
			return true;
		} else {
			//_global.myTrace("not pass has units test");
			var p = _global.NNW.screens.scnUnit;
			var n = "CourseHasUnitsError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(153, 130);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	
	function passMaxCourseCheck() : Boolean {
		if (!_global.NNW.control._lite||(_global.NNW.control.__maxNoOfCourses>_global.NNW.control.data.getNoOfCourses())) {
			return true;
		} else {
			//v6.4.2.4 Surely this is the wrong screen? But not checked
			//var p = _global.NNW.screens.scnUnit;
			var p = _global.NNW.screens.scnCourse;
			var n = "MaxCourseError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(20, 130);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	// v6.4.2.4 New type of product restriction
	function passNewCourseCheck() : Boolean {
		if (!_global.NNW.control._productRestriction) {
			return true;
		} else {
			_global.myTrace("new course error"); 
			var p = _global.NNW.screens.scnCourse;
			var n = "NewCourseError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(18, 130);
			errorBoxes[n].setSize(210, 200);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}

	function passMaxUnitCheck() : Boolean {
		if (!_global.NNW.control._lite||(_global.NNW.control.__maxNoOfUnits>_global.NNW.control.data.getNoOfUnits())) {
			return true;
		} else {
			var p = _global.NNW.screens.scnUnit;
			var n = "MaxUnitError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(153, 130);
			errorBoxes[n].setSize(220, 140);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	
	function passMaxExerciseCheck() : Boolean {
		if (!_global.NNW.control._lite||(_global.NNW.control.__maxNoOfExercises>_global.NNW.control.data.getNoOfExercises())) {
			return true;
		} else {
			var p = _global.NNW.screens.scnUnit;
			var n = "MaxExerciseError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(518, 130);
			errorBoxes[n].setSize(220, 155);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}

	// AR v6.4.2.5a Use an alert to tell the user that the menu has changed if they are about to do something to it
	// The test has already been done, just use this class to display the alert
	function passMenuChangedCheck(pass:Boolean) : Boolean {
		if (pass) {
			return true;
		} else {
			var p = _global.NNW.screens.scnUnit;
			var n = "MenuChangedError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(518, 130);
			errorBoxes[n].setSize(220, 155);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	// v6.4.3 Similar check for course.xml changing
	function passCourseChangedCheck(pass:Boolean) : Boolean {
		if (pass) {
			return true;
		} else {
			var p = _global.NNW.screens.scnCourse;
			var n = "CourseChangedError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(518, 130);
			errorBoxes[n].setSize(220, 155);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	
	function passSelectedUnitCheck() : Boolean {
		var screens = _global.NNW.screens;
		if (screens.getSelectedUnit()!=undefined) {
			//_global.myTrace("pass selected unit test");
			return true;
		} else {
			//_global.myTrace("not pass selected unit test");
			var p = screens.scnUnit;
			var n = "SelectedUnitError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(153, 130);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	
	function passSingleFieldCheck(h:String) : Boolean {
	// v0.7.1, DL: debug - do single field check on that textfield only
	//function passSingleFieldCheck(qNo:Number) : Boolean {
		var ex = _global.NNW.control.data.currentExercise;
		if (h.indexOf("fieldClick", 0) > -1) {
		//if (ex.fieldManager.hasFieldInThisGroup(qNo)) {
			var p = _global.NNW.screens.scnExercise.segment2.contentHolder;
			var n = "SingleFieldError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(320, -50);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		} else {
			return true;
		}
	}
	
	
	// v6.5.1 Yiu fixing question based drop
	function ifStringContainField(h:String) : Boolean {
		var ex = _global.NNW.control.data.currentExercise;
		if (h.indexOf("fieldClick", 0) > -1) {
			return false;
		} else {
			return true;
		}
	}
	// End v6.5.1 Yiu fixing question based drop
	function passFieldLengthCheck(h:Number) : Boolean {
		var ex = _global.NNW.control.data.currentExercise;
		if (h>36) {
			var p = _global.NNW.screens.scnExercise.segment2.contentHolder;
			var n = "FieldLengthTooLongError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(320, -50);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		} else {
			return true;
		}
	}
	
	function passFieldEmptyCheck(t:String) : Boolean {
		var ex = _global.NNW.control.data.currentExercise;
		t = _global.replace(t, " ", "");
		t = _global.replace(t, "\t", "");
		t = _global.replace(t, "\n", "");
		t = _global.replace(t, "\r", "");
		if (t.length<=0) {
			var p = _global.NNW.screens.scnExercise.segment2.contentHolder;
			var n = "FieldEmptyError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(320, -50);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		} else {
			return true;
		}
	}
	
	function passEmailCheck(subject:String, body:String) : Boolean {
		var pass = true;
		if (subject==undefined||subject=="") {
			pass = false;
			var p = _global.NNW.screens.txts.txtEmailSubject._parent;
			var n = "EmailSubjectError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(310, 4);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
		}
		if (body==undefined||body=="") {
			pass = false;
			var p = _global.NNW.screens.txts.txtEmailText._parent;
			var n = "EmailTextError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(8, 170);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
		}
		return pass;
	}
	
	var s_nHighestDepth:Number		= 0;
	var s_objHighestDepthObj:Object;
	// v0.10.0, DL: show tip when selecting exercise type
	function showExerciseTypeTip(t:String, x:Number, y:Number) : Void {
		var screens = _global.NNW.screens;
		var p = screens.scnExType;
		//var n = t+"Tip";
		var n = t + "TypeTips";
		errorBoxes[n] = new errorBox();
		errorBoxes[n].parent = p;
		errorBoxes[n].name = n;
		//errorBoxes[n].setPosition(350, y);
		errorBoxes[n].setPosition(x, y);
		errorBoxes[n].setSize(380, 100);
		errorBoxes[n].time = 0; 
		errorBoxes[n].createErrorBox();
	}
	
	// v0.10.0, DL: hide tip when selecting exercise type
	function hideExerciseTypeTip(t:String) : Void {
		//var n = t+"Tip";
		var n = t + "TypeTips";
		errorBoxes[n].removeErrorBox();
		
		// v6.4.1, DL: also remove the select Pro exercise type error box
		var n = "SelectProExerciseTypeError";
		errorBoxes[n].removeErrorBox();
	}
	
	// v0.10.0, DL: check if it's lite version, if so, can't add audio
	function passAddAudioCheck(lite:Boolean) : Boolean {
		if (lite) {
			var screens = _global.NNW.screens;
			var p = screens.scnExercise;
			var n = "AddAudioError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(300, 250);
			errorBoxes[n].setSize(220, 155);
			errorBoxes[n].createErrorBox();
			screens.chbs.chbAddAudio.selected = false;	// set the checkbox to false
		}
		return lite;
	}
	
	function passExerciseImageCheck(lite:Boolean, c:String) : Boolean {
		var pass = true;
		if (lite) {
			if (c=="YourGraphic" || c=="NoGraphic") {
				pass = false;
				var screens = _global.NNW.screens;
				var p = screens.scnExercise;
				var n = "PresetGraphicError";
				errorBoxes[n] = new errorBox();
				errorBoxes[n].parent = p;
				errorBoxes[n].name = n;
				errorBoxes[n].setPosition(300, 250);
				errorBoxes[n].setSize(220, 155);
				errorBoxes[n].createErrorBox();
				screens.combos.comboImageCategory.selectedIndex=0;
			}
		}
		return pass;
	}
	
	function raiseMaxNoOfQuestionsError(lite:Boolean) : Boolean {
		var p = _global.NNW.screens.scnExercise.segment2.contentHolder;
		var n = "MaxNoOfQuestionsError";
		if (!lite) {
			n = "MaxNoOfQuestionsProError";
		}
		errorBoxes[n] = new errorBox();
		errorBoxes[n].parent = p;
		errorBoxes[n].name = n;
		errorBoxes[n].setPosition(518, 90);
		errorBoxes[n].setSize(220, 155);
		errorBoxes[n].createErrorBox();
		return false;
	}
	
	// v6.4.0.1, DL: compare xml against the one on server, if not up-to-date, tell the user XML will be reloaded
	function passCompareCourseXmlCheck(b:Boolean) : Boolean {
		if (b) {
			return true;
		} else {
			var p = _global.NNW.screens.scnUnit;
			var n = "CourseXmlNotUpToDateError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(20, 130);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	
	// v6.4.1, DL: do not let the user to create certain types of exercises in Lite version
	function passSelectExerciseTypeCheck(lite:Boolean, exType:Boolean) : Boolean {
		if (!lite) {
			return true;
		} else {
			switch (exType) {
			case "MultipleChoice" :
			case "Quiz" :
			case "Dropdown" :
			case "DragAndDrop" :
			case "DragOn" :
			case "Stopgap" :
			case "Cloze" :
			case "Countdown" :
			case "Analyze" :
			case _global.g_strQuestionSpotterID:
			case _global.g_strBulletID:			// Yiu v6.5.1 added new type Bullet
			case "Presentation" :
			case _global.g_strErrorCorrection:	// v6.5.1 Yiu 6-5-2008 New exercise type error correction
				return true;
			default :
				var screens = _global.NNW.screens;
				var p = screens.scnExType;
				var n = "SelectProExerciseTypeError";
				errorBoxes[n] = new errorBox();
				errorBoxes[n].parent = p;
				errorBoxes[n].name = n;
				errorBoxes[n].setPosition(10, 270);
				errorBoxes[n].setSize(220, 155);
				errorBoxes[n].createErrorBox();
				return false;
			}
		}
	}
	
	// v6.4.1.4, DL: do not let users to open exercises with certain enabledFlag
	function passExerciseEnabledFlagCheck() : Boolean {
		var eF = _global.NNW.control.data.currentExercise.enabledFlag;
		// AR v6.4.2.5 use numbers
		//if (!_global.haveComponent(eF, 32)) {
		if (eF&_global.NNW.control.enabledFlag.nonEditable) {
			var screens = _global.NNW.screens;
			var p = screens.scnUnit;
			var n = "ExerciseNotForAuthoringError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(550, 170);
			errorBoxes[n].setSize(200, 155);
			errorBoxes[n].createErrorBox();
			return false;
		}
		return true;
	}
	
	// v6.4.2 Check permissions in mdm. But actually do the relevant call in the mdm class
	// to keep all that code together.
	function passMDMPermissionsCheck(pass:Boolean) : Boolean {
		//_global.myTrace("passMDMPermissionsCheck:"+pass);
		if (pass) {
			return true;
		} else {
			var screens = _global.NNW.screens;
			var p = screens.scnExport;
			var n = "FolderPermissionError";
			errorBoxes[n] = new errorBox();
			errorBoxes[n].parent = p;
			errorBoxes[n].name = n;
			errorBoxes[n].setPosition(400, 30);
			errorBoxes[n].setSize(180, 100);
			errorBoxes[n].createErrorBox();
			return false;
		}
	}
	
	// v6.4.3 Need to check that a 'kit' only lets users in an MGS do the editing of the default (Author Plus) course
	// v6.5.0.1 No. A kit only allows editing of the one, non Author Plus, listed title.
	function passLicenceProductTypeCheck() : Boolean {
		var productType = _global.NNW.control.login.licence.productType.toLowerCase();
		var branding = _global.NNW.control.login.licence.branding.toLowerCase();
		//if (_global.NNW.control._enableMGS || productType<>"kit") {
		if (productType<>"kit") {
			return true;
		} else {
			// So, if you are a kit, then you must be in an MGS space, and you must be authorised for editing
			if (_global.NNW.control._enableMGS && _global.NNW._userSettings=="1") {
				return true;
			} else {
				_global.myTrace("NotInMGSError for " + branding); 
				// This has to be displayed on the base screen
				var p = _global.NNW.screens;
				var n = "NotInMGSError";
				errorBoxes[n] = new errorBox();
				errorBoxes[n].parent = p;
				errorBoxes[n].name = n;
				errorBoxes[n].setPosition(460, 130);
				errorBoxes[n].setSize(250, 200);
				errorBoxes[n].time = 0;
				errorBoxes[n].createErrorBox();
				// I also want to add the branding for this title
				var initObj = {_x:20, _y:130};
				if (branding.indexOf("nas/myc")>=0) {
					var kitTitle = "MyCanada_mc";
				} else if (branding.indexOf("nas/ldt")>=0) {
					var kitTitle = "Lamour_mc"; 
				} else if (branding.indexOf("clarity/tb")>=0) {
					var kitTitle = "TenseBuster_mc"; 
				} else if (branding.indexOf("clarity/sss")>=0) {
					var kitTitle = "StudySkillsSuccess_mc"; 
				} else if (branding.indexOf("clarity/ro")>=0) {
					var kitTitle = "Reactions_mc"; 
				} else if (branding.indexOf("clarity/bw")>=0) {
					var kitTitle = "BusinessWriting_mc"; 
				}
				p.attachMovie(kitTitle, "branding_mc", p.getNextHighestDepth(), initObj);
				return false;
			}
		}
	}
}