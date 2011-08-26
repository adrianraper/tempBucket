_global.urlClick = function(no) {
	NNW.screens.textFormatting.urlClick(no);
}

_global.fieldClick = function(no) {
	NNW.screens.textFormatting.fieldClick(no);
	var ex = NNW.control.data.currentExercise;
	switch (ex.exerciseType) {
	case "Dropdown" :
	case "Cloze" :
	case "DragOn" :
	case "TargetSpotting" :	// v0.16.0, DL: new exercise type
	case "Proofreading" :	// v0.16.0, DL: new exercise type
	case _global.g_strErrorCorrection:	// v6.5.1 Yiu 6-5-2008 New exercise type error correction
		/* show feedback & hint */
		var fNo = Number(no) - 1;
		NNW.screens.fillInFeedback(ex.feedback[fNo].value);
		NNW.screens.fillInHint(ex.hint[fNo].value);
		
		if (	ex.exerciseType=="TargetSpotting"		||
				ex.exerciseType=="Proofreading") {
			NNW.screens.fillInCorrectTarget(ex.getAnswers(fNo+1));
			NNW.screens.showFeedbackHint(true);
		} else {
			NNW.screens.fillInOtherOptions(ex.getAnswers(fNo+1));
			NNW.screens.showOptionsFeedbackHint(true);
		}
		
		// v0.16.1, DL: debug - originally getOtherOptions() was designed for Dropdown
		// but it turned out to be identical to getAnswers
		/*if (ex.exerciseType=="DragOn") {
			NNW.screens.fillInOtherOptions(ex.getOtherOptions(fNo+1));
			NNW.screens.showFeedbackHint(true);
			
		// v0.16.0, DL: new exercise type
		} else if (ex.exerciseType=="TargetSpotting"||ex.exerciseType=="Proofreading") {
			NNW.screens.fillInCorrectTarget(ex.getAnswers(fNo+1));
			NNW.screens.showFeedbackHint(true);
			
		} else {
			NNW.screens.fillInOtherOptions(ex.getAnswers(fNo+1));
			NNW.screens.showOptionsFeedbackHint(true);
		}*/
		
		break;
		// v6.5.1 Yiu fixing add alt ans before have a drop
	case _global.g_strQuestionSpotterID:
		var ex = NNW.control.data.currentExercise;
		if (ex.settings.misc.splitScreen) {
			NNW.screens.showFeedbackHint(true);
		} else {
			NNW.screens.showFeedbackHint(true);
		} 
		break;
	case "Stopdrop":
	case "Stopgap":	// v6.5.1 Yiu fixing alt ans problem of Stopgap
	case "DragAndDrop" :	// v6.5.1 Yiu fixing alt ans problem for DragAndDrop
		//var fNo = Number(NNW.screens.txts.txtQuestionNo.text) -1;
		//var fNo = Number(no) - 1;
		//NNW.screens.fillInFeedback(ex.feedback[fNo].value);
		//NNW.screens.fillInHint(ex.hint[fNo].value);
		
		//NNW.screens.fillInOtherOptions(ex.getAnswers(fNo+1));
		
		var ex = NNW.control.data.currentExercise;
		if (ex.settings.misc.splitScreen) {
			NNW.screens.showOptionsFeedbackHint(true, 312.9, undefined, -117, -87);
			NNW.screens.moveFormattingButtons(12.6, 1);
			NNW.screens.moveMakeField(-195.05, 221.55);
			NNW.setVisible("btnUpgrade", false);
		} else {
			NNW.screens.showOptionsFeedbackHint(true);
			NNW.screens.moveFormattingButtons(-94.4, 21);
			//NNW.screens.moveMakeField(-328.55, 121.55);
			NNW.screens.moveMakeField(-268.55, 171.55);
			NNW.setVisible("btnUpgrade", true);
		} 
		break;
		// End v6.5.1 Yiu fixing add alt ans before have a drop
	}
}

_global.clearFeedbackAndHint = function(no:Number) : Void {
	/* remove feedback & hint */
	var fNo = no - 1;
	var ex = NNW.control.data.currentExercise;
	ex.feedback[fNo].value = "";
	ex.hint[fNo].value = "";
	switch (ex.exerciseType) {
	case "TargetSpotting" :	// v0.16.0, DL: new exercise type
	case _global.g_strBulletID:
	case "Proofreading" :	// v0.16.0, DL: new exercise type
	case _global.g_strQuestionSpotterID:
		NNW.screens.showFeedbackHint(false);
		break;
	case "DragOn" :
	case "Dropdown" :
	case "Cloze" :
	// v6.5.1 Yiu fixing add alt before ans problem
	case "Stopdrop":
	case "Stopgap":	// v6.5.1 Yiu fixing alt ans problem of Stopgap
	case "DragAndDrop" :	// v6.5.1 Yiu fixing alt ans problem for DragAndDrop
	case _global.g_strErrorCorrection:	// v6.5.1 Yiu 6-5-2008 New exercise type error correction
		NNW.screens.showOptionsFeedbackHint(false);
		break;
	// End v6.5.1 Yiu fixing add alt before ans problem
	default :
		break;
	}
}

import screensFunc.TextAreaFormatting;
var formatting = new TextAreaFormatting();
NNW.screens.textFormatting = formatting;
_global.myFormatting	= formatting;

var formattingListener = new Object();
Mouse.addListener(formattingListener);

formattingListener.onMouseUp = function() { 
	var exType = NNW.control.data.currentExercise.exerciseType;
	switch (exType) {
	case "TargetSpotting" :	// v0.16.0, DL: new exercise type
	case "Proofreading" :	// v0.16.0, DL: new exercise type
		if (Selection.getFocus()==targetPath(NNW.screens.txts.txtText.label)) {
			NNW.screens.showFeedbackHint(false);
		}
		break;
	case "DragOn" :
	case "Dropdown" :
	case _global.g_strErrorCorrection:	// v6.5.1 Yiu 6-5-2008 New exercise type error correction
		if (Selection.getFocus() == targetPath(NNW.screens.txts.txtText.label)) {
			NNW.screens.showOptionsFeedbackHint(false);
		}
		break;
	// v6.5.1 fixing add alt ans before have a drop
	case "Stopdrop":	
	case "Stopgap":	// v6.5.1 Yiu fixing alt ans problem of Stopgap
	case "DragAndDrop" :	// v6.5.1 Yiu fixing alt ans problem for DragAndDrop
		//if (Selection.getFocus()==targetPath(NNW.screens.txts.txtQuestion.label)) {
		//	NNW.screens.showOptionsFeedbackHint(false);
		//}
		break;
	// End v6.5.1 fixing add alt ans before have a drop
	// v6.5.1 Yiu fix the problem of feedback disappeared after dragging the gap length bar
	case "Cloze" :	
		if (	Selection.getFocus() == targetPath(NNW.screens.txts.txtText.label)	&&
				!bJustReturnFocusAfterReleaseOnSlider) 
		{
			NNW.screens.showOptionsFeedbackHint(false);
		}
		break;
	// End v6.5.1 Yiu fix the problem of feedback disappeared after dragging the gap length bar
	default :
		break;
	}
}

/* v0.11.0, DL: to capture release of slider, I've added this function to be called in the slider code */
_global.onSliderReleased = function() {
	_global.bJustReturnFocusAfterReleaseOnSlider	= true;
	NNW.screens.textFormatting.returnFocus();
}