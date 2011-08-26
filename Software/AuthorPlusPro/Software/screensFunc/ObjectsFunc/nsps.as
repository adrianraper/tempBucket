
// numeric stepper
nsps.change = function(evtObj:Object) : Void {
	var nsp = evtObj.target;
	var qNo = nsp.value;
	switch (nsp._name) {
		case "nspQuestionNo" :
			NNW.screens.btns.lblQNo.text = qNo.toString();
			NNW.control.onChangeQuestionNo(qNo);
			if (NNW.control.data.currentExercise.exerciseType=="Quiz") {
				NNW.screens.updateTrueFalseOptions();
			}
			Selection.setFocus(NNW.screens.txts.txtQuestion.label);
			Selection.setSelection(0, 0);
			break;
		case "nspSplitScreenQuestionNo" :
			NNW.screens.btns.lblSplitScreenQNo.text = qNo.toString();
			NNW.control.onChangeQuestionNo(qNo);
			Selection.setFocus(NNW.screens.txts.txtSplitScreenQuestion.label);
			Selection.setSelection(0, 0);
			break;
	}
}

nsps.setToOne = function() : Void {
	this.nspQuestionNo.value = 1;
	this.nspSplitScreenQuestionNo.value = 1;
	NNW.screens.btns.lblQNo.text = "1";
	NNW.screens.btns.lblSplitScreenQNo.text = "1";
}
