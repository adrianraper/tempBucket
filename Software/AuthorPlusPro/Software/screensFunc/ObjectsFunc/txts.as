// v6.5.1 Yiu fixing the foont style problem of instruction
function processTitleTextEx(strOrigin:String):String{
	var aryLine:Array	= new Array();
	
	var strTarSearchString:String	= "";
	
	var nStartPos:Number 	= 0;
	var nEndPos:Number		= strOrigin.length;
	var nTarPos:Number		= 0;
	var strTarWord			= "</P>";
	
	// Innner variabels
	var nInnerStartPos:Number		= 0;
	var nInnerEndPos:Number			= 0;
	var nInnerTarPos:Number			= 0;
	var strInnerTarWord1:String		= "<"
	var strInnerTarWord2:String		= ">"
	var strInnerWordAsm:String		= "";
	var strALine:String				= "";
	
	// extract all lines of text and put into an array
	while((nTarPos = strOrigin.indexOf(strTarWord, nStartPos)) != -1){
		strTarSearchString	= strOrigin.substring(nStartPos, nTarPos);
		
		strInnerWordAsm	= "";
		strALine 		= "";
		nInnerStartPos	= 0;
		
		while((nInnerTarPos = strTarSearchString.indexOf(strInnerTarWord2, nInnerStartPos)) != -1){
			nInnerEndPos	= strTarSearchString.indexOf(strInnerTarWord1, nInnerTarPos);
			
			if(nInnerEndPos == -1){
				break;
			}
				
			if(!((nInnerTarPos + 1) < nInnerEndPos)){
				nInnerStartPos	= nInnerEndPos + 1;
				continue;
			}
				
			strInnerWordAsm	= strTarSearchString.substring(nInnerTarPos + 1, nInnerEndPos);
				
			strALine		+= strInnerWordAsm;
			
			nInnerStartPos	= nInnerEndPos + 1;
		}
		
		//if(strALine != ""){
			//_global.myTrace("strALine pushed: <" + strALine + ">");
			aryLine.push(strALine);
		//}
		
		nStartPos	= nTarPos + 1;
	}
	
	// reform the html text for each line
	var v1:Number;
	var strFinal:String	= "";
	for(v1=0; v1<aryLine.length; ++v1){
		strFinal += "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\"><FONT FACE=\"Verdana\" SIZE=\"12\" COLOR=\"#000000\" LETTERSPACING=\"0\" KERNING=\"0\"><B>" + aryLine[v1] + "</B></FONT></P></TEXTFORMAT>";
	}
	
	return strFinal;
}

// End v6.5.1 Yiu fixing the foont style problem of instruction

// textAreas or textInputs
// v6.4.2.7 This is very intensive, surely we don't usually want to watch every character typed, loseFocus would be the better event.
txts.change = function(evtObj:Object) : Void {
	var txt = evtObj.target;
	var ex = NNW.control.data.currentExercise;
	var exType = ex.exerciseType;
	var splitScreen = ex.settings.misc.splitScreen;
	// v0.16.1, DL: split-screen is not only for Analyze
	//if (exType!="Analyze") {
	if (!splitScreen) {
		var qNo = Number(NNW.screens.txts.txtQuestionNo.text);	//v0.12.0, DL: NNW.screens.nsps.nspQuestionNo.value;
	} else {
		var qNo = Number(NNW.screens.txts.txtSplitScreenQuestionNo.text);	//v0.12.0, DL: NNW.screens.nsps.nspRMCQuestionNo.value;
	}
	/*if (txt._name!="txtUsername"&&!txt._name!="txtPassword"&&!txt._name!="txtCode") {
		//txt.text = _global.tabToSpace(txt.text);
	}*/
	//_global.myTrace("txt.change " + txt._name + " to " + txt.text);
	switch (txt._name) {
		/*case "txtCode" :
			NNW.control.onEnteredCode(txt.text);
			break;*/
		case "txtCourseName" :
			NNW.control.renameCourse(txt.text);
			break;
		case "txtExerciseName" :
			NNW.control.updateExerciseCaption(txt.text);
			break;
			
// v6.5.1 original instruction text box is deleted, replaced by txtTitle2
/*

		case "txtTitle" :
			
			if(	Key.getCode() == 32	||	// Space
				Key.getCode() == 13	||	// Enter
				Key.getCode() == 8 	||	// Backspace
				Key.getCode() == 17 ||	// left Ctrl
				Key.getCode() == 44 ||	// Print screen
				Key.getCode() == 36 ||	// Home
				Key.getCode() == 35 ||	// End
				Key.getCode() == 33 ||	// Page up
				Key.getCode() == 34 ||	// Page down
				Key.getCode() == 16 ||	// Shift
				Key.getCode() == 91 ||	// Window key
				Key.getCode() == 20 ||	// Caps Locks
				Key.getCode() == 27 ||	// Escape key
				Key.getCode() == 46 ||	// Escape key
				Key.getCode() == 37 ||	// Left arrow
				Key.getCode() == 38 ||	// Up arrow
				Key.getCode() == 39 ||	// Right arrow
				Key.getCode() == 40		// Down arrow
			){
				_global.bSkipInstructionTextCheck	= true;
			}
			if(!_global.bSkipInstructionTextCheck){
				//txt.text	= processTitleTextEx(txt.text);
			} else {
				_global.bSkipInstructionTextCheck	= false;
			} 
			
			NNW.control.updateExerciseTitle(txt.text);
			break; 
* */
// End v6.5.1 original instruction text box is deleted, replaced by txtTitle2

		case "txtTitle2" :
			NNW.control.updateExerciseTitle(txt.text);
		break;
		case "txtText" :
			NNW.control.updateExerciseText(txt.text);
			break;
		case "txtQuestion" :
			NNW.control.updateExercise("question", qNo, txt.text);
			// v0.16.1, DL: debug - quiz options should also be updated
			if (exType=="Quiz") {
				NNW.screens.updateWholeExercise();
			}
			break;
			
		// v0.16.1, DL: debug - there was no update when reading text is updated
		case "txtSplitScreenText" :
			NNW.control.updateExerciseText(txt.text);
			break;
			
		case "txtSplitScreenQuestion" :
			NNW.control.updateExercise("question", qNo, txt.text);
			
			if (exType=="Quiz") {	// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311
				NNW.screens.updateWholeExercise();
			}
			break;
		case "txtFeedback" :
			//_global.myTrace("feedback "+NNW.screens.textFormatting.activeFieldNo+" = "+txt.text);
			if (	exType=="Dropdown"		||
					exType=="Cloze"			||
					exType=="DragOn"		||
					exType==_global.g_strErrorCorrection	// v6.5.1 Yiu 6-5-2008 New exercise type error correction
					) {
				NNW.control.updateExercise("feedback", NNW.screens.textFormatting.activeFieldNo, txt.text);
			} else if (txt._parent._name=="feedback0_mc") {	// v0.16.0, DL: for different feedback
				NNW.control.updateExercise("differentFeedback", qNo, txt.text, 0);
			} else if (txt._parent._name=="feedback1_mc") {	// v0.16.0, DL: for different feedback
				NNW.control.updateExercise("differentFeedback", qNo, txt.text, 1);
			} else {
				NNW.control.updateExercise("feedback", qNo, txt.text);
			}
			break;
		case "txtHint" :
		case "txtHintOnly" :	// v0.16.0, DL: hint only
			//_global.myTrace("hint "+qNo+" = "+txt.text);
			if (	exType=="Dropdown"				||
					exType=="Cloze"					||
					exType=="DragOn"				||
					exType==_global.g_strErrorCorrection	// v6.5.1 Yiu 6-5-2008 New exercise type error correction
					) {
				NNW.control.updateExercise("hint", NNW.screens.textFormatting.activeFieldNo, txt.text);
			} else {
				NNW.control.updateExercise("hint", qNo, txt.text);
			}
			break;
		case "txtFeedbackOnly" :
			if (	exType==_global.g_strQuestionSpotterID	|| 
					exType==_global.g_strErrorCorrectionID
				) {
				NNW.control.updateExercise("feedback", qNo, txt.text);
			} else {
				NNW.control.updateExercise("feedback", NNW.screens.textFormatting.activeFieldNo, txt.text);
			}
			break;
		case "txtScoreBasedFeedback" :
			NNW.control.updateExercise("scoreBasedFeedback", Number(NNW.screens.combos.comboScore.selectedItem.label), txt.text);
			break;
		case "txtOption0" :
		case "txtOption1" :
		case "txtOption2" :
		case "txtOption3" :	
			NNW.screens.updateOptions();
			break;
		case "txtRMCOption0" :
		case "txtRMCOption1" :
		case "txtRMCOption2" :
		case "txtRMCOption3" :
			NNW.screens.updateRMCOptions();
			break;
/*		case "txtOtherAnswer0" :
			NNW.control.updateExercise("answer", qNo, txt.text, 0, true);
			break;
		case "txtOtherAnswer1" :
			NNW.control.updateExercise("answer", qNo, txt.text, 1, true);
			break;
		case "txtOtherAnswer2" :
			NNW.control.updateExercise("answer", qNo, txt.text, 2, true);
			break;
		case "txtOtherAnswer3" :
			NNW.control.updateExercise("answer", qNo, txt.text, 3, true);
			break;*/
		case "txtOtherOption0" :
			// v6.4.3 Item based drop down
			//var correct = (exType=="Dropdown") ? false : true;
			//if (exType=="Stopgap") {
			var correct = (exType=="Dropdown"||exType=="Stopdrop") ? false : true;
			if (exType=="Stopgap"||exType=="Stopdrop") {
				NNW.control.updateExercise("answer", qNo, txt.text, 0, correct);
			} else {
				NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txt.text, 0, correct);
			}
			break;
		case "txtOtherOption1" :
			// v6.4.3 Item based drop down
			//var correct = (exType=="Dropdown") ? false : true;
			var correct = (exType=="Dropdown"||exType=="Stopdrop") ? false : true;
			if (exType=="Stopgap") {
				NNW.control.updateExercise("answer", qNo, txt.text, 1, correct);
			} else {
				NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txt.text, 1, correct);
			}
			break;
		case "txtOtherOption2" :
			// v6.4.3 Item based drop down
			//var correct = (exType=="Dropdown") ? false : true;
			var correct = (exType=="Dropdown"||exType=="Stopdrop") ? false : true;
			if (exType=="Stopgap") {
				NNW.control.updateExercise("answer", qNo, txt.text, 2, correct);
			} else {
				NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txt.text, 2, correct);
			}
			break;
		case "txtOtherOption3" :
			// v6.4.3 Item based drop down
			//var correct = (exType=="Dropdown") ? false : true;
			var correct = (exType=="Dropdown"||exType=="Stopdrop") ? false : true;
			if (exType=="Stopgap") {
				NNW.control.updateExercise("answer", qNo, txt.text, 3, correct);
			} else {
				NNW.control.updateExercise("answer", NNW.screens.textFormatting.activeFieldNo, txt.text, 3, correct);
			}
			break;
		case "txtTrue" :
		case "txtFalse" :
			//NNW.screens.panels.updateTrueFalseOptions("chbTrue2");
			NNW.screens.updateQuizOptionsLabels();	// v0.16.0, DL: no panels anymore
			break;
		case "txtTimeLimit" :
			if (Number(txt.text)>0) {
				NNW.control.updateExerciseSettings("misc", "timed", Number(txt.text));
			} else {
				NNW.control.updateExerciseSettings("misc", "timed", 0);
			}
			break;
		// v6.4.2.7 Adding URLs
		case "txtURL1":
			//_global.myTrace("txts.txtURL1 call to control");
			NNW.control.updateExerciseURL(1, txt.text, undefined, undefined);
			break;
		case "txtURL2":
			NNW.control.updateExerciseURL(2, txt.text, undefined, undefined);
			break;
		case "txtURL3":
			NNW.control.updateExerciseURL(3, txt.text, undefined, undefined);
			break;
		case "txtURLCaption1":
			//_global.myTrace("txts.txtURLCaption1 call to control");
			NNW.control.updateExerciseURL(1, undefined, txt.text, undefined);
			break;
		case "txtURLCaption2":
			NNW.control.updateExerciseURL(2, undefined, txt.text, undefined);
			break;
		case "txtURLCaption3":
			NNW.control.updateExerciseURL(3, undefined, txt.text, undefined);
			break;
	}
}

txts.enter = function(evtObj:Object) : Void {
	var txt = evtObj.target;
	switch (txt._name) {
		case "txtQuestionNo" :
			var qNo = Number(txt.text);
			if (qNo>NNW.control.__maxNoOfQuestions || qNo<1) {
				if (qNo>NNW.control.__maxNoOfQuestions) {
					NNW.control.raiseMaxNoOfQuestionsError();
				}
				txt.text = NNW.screens.btns.lblQNo.text;
			} else {
				NNW.screens.btns.lblQNo.text = txt.text;
				NNW.control.onChangeQuestionNo(qNo);
				if (NNW.control.data.currentExercise.exerciseType=="Quiz") {	
					NNW.screens.updateTrueFalseOptions();
				}
				//Selection.setFocus(NNW.screens.txts.txtQuestion.label);
				//Selection.setSelection(0, 0);
			}
			break;
		case "txtSplitScreenQuestionNo" :
			var qNo = Number(txt.text);
			if (qNo>NNW.control.__maxNoOfQuestions || qNo<1) {
				if (qNo>NNW.control.__maxNoOfQuestions) {
					NNW.control.raiseMaxNoOfQuestionsError();
				}
				txt.text = NNW.screens.btns.lblSplitScreenQNo.text;
			} else {
				NNW.screens.btns.lblSplitScreenQNo.text = txt.text;
				NNW.control.onChangeQuestionNo(qNo);
				
				if (NNW.control.data.currentExercise.exerciseType=="Quiz") {		// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311
					NNW.screens.updateTrueFalseOptions();
				}
				//Selection.setFocus(NNW.screens.txts.txtRMCQuestion.label);
				//Selection.setSelection(0, 0);
			}
			break;
		case "txtUsername" :
			this.txtPassword.setFocus();
			break;
		case "txtPassword" :
			NNW.control.login.checkLogin(this.txtUsername.text, this.txtPassword.text);
			break;
		/*case "txtCode" :
			NNW.control.checkAuthCode();
			break;*/
	}
}
