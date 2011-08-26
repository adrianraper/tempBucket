
// comboBoxes
combos.change = function(evtObj) : Void {
	var c = evtObj.target;
	switch(c._name) {
	case "comboLanguage" :
		NNW.view.literals.onChangeLiterals(c.value);
		break;
	case "comboScreens" :
		NNW.screens.hideAllScreens();
		NNW.screens.showScreen(c.value);
		break;
	case "comboImageCategory" :
		if (c.value=="YourGraphic") {
			// v0.16.1, DL: if it's lite version, leave errorCheck class to catch this attempt
			if (NNW.control._lite) {
				NNW.control.updateExerciseImage("category", c.value);
			} else {
				// v0.16.1, DL: show the file list for browsing
				NNW.screens.resetBrowseScreen("image");
				NNW.view.showBrowseScreen();				
			}
		} else {
			if (c.value=="NoGraphic") {
				NNW.screens.s_bImageSelected	= false;
				NNW.screens.enableImagePositionCheckBoxes(false);
			} else {
				NNW.screens.s_bImageSelected	= true;
				// v6.5.1 Fix floating problem
				/* commeted by Yiu
				if (NNW.control.data.currentExercise.settings.misc.splitScreen) {
					NNW.screens.enableImagePositionCheckBoxes(false, true);
				} else {
					NNW.screens.enableImagePositionCheckBoxes(true);
				}
				*/
				NNW.screens.enableImagePositionCheckBoxes(true);
				// End v6.5.1 Fix floating problem
			}
			NNW.control.updateExerciseImage("category", c.value);
		}
		break;
	case "comboTestFunc" :
		NNW.control.testCases.runTest(c.value);
		break;
	}
}

combos.setComboSelectedData = function(comboName:String, data:String) : Void {
	var c = this["combo"+comboName];
	c.selectedIndex = 0;
	for (var i=0; i<c.length; i++) {
		if (c.getItemAt(i).data == data) {
			c.selectedIndex = i;
		}
	}
}

combos.getComboSelectedData = function(comboName:String) : String {
	var c = this["combo"+comboName];
	if (c.selectedIndex!=undefined) {
		return (c.getItemAt(c.selectedIndex).data!=undefined) ? c.getItemAt(c.selectedIndex).data : "";
	} else {
		return "";
	}
}

combos.resetPhotoCatergoryLiterals = function() : Void {
	for (var i in NNW.photos.Sizes) {
		var categories = NNW.photos.Sizes[i].Categories;
		break;
	}
	var c = this.comboImageCategory;
	var oldData = c.selectedItem.data;
	c.removeAll();
	for (var i in categories) {
		// v0.10.0, DL: your graphic & no graphic should be the last 2 choices
		if (i!="YourGraphic" && i!="NoGraphic") {
			var n:String = NNW.view.literals.getLiteral("lbl"+i);
			c.addItem(n.toString(), i);
		}
	}
	c.rowCount = 9;
	c.sortItemsBy("label", "ASC");
	
	// v0.10.0, DL: your graphic & no graphic should be the last 2 choices
	var n1:String = NNW.view.literals.getLiteral("lblYourGraphic");
	c.addItem(n1.toString(), "YourGraphic");
	var n2:String = NNW.view.literals.getLiteral("lblNoGraphic");
	c.addItem(n2.toString(), "NoGraphic");
	
	this.setComboSelectedData("ImageCategory", oldData);
}

combos.clearCombo = function(comboName:String) : Void {
	var c = this["combo"+comboName];
	c.removeAll();
}

combos.showFeedback = function(n:Number) : Void {	// v0.16.0, DL: for score-based feedback
	this.clearFeedback();
	NNW.control.onChangeScore(n);
}
combos.clearFeedback = function() : Void {	// v0.16.0, DL: for score-based feedback
	NNW.screens.txts.txtScoreBasedFeedback.text = "";
}
combos.resetScoreBasedFeedback = function() : Void {	// v0.16.0, DL: for score-based feedback
	var cb = this.comboScore;
	cb.selectedIndex = 0;
	this.showFeedback(Number(cb.selectedItem.label));
}
combos.compareFunc = function(a, b) : Boolean {	// v0.16.0, DL: for score-based feedback
	return (Number(a.label) > Number(b.label));
}
combos.addNewScore = function(t:String) : Void {	// v0.16.0, DL: for score-based feedback
	var cb = this.comboScore;

	var n = Math.round(Number(t));
	t = n.toString();
	
	// check if it's inside suitable range, if yes, add it
	if (!isNaN(n) && n>=0 && n<=100) {
		// check if it's already in the list, if no, add it
		var found = false;
		for (var i=0; i<cb.length; i++) {
			if (cb.getItemAt(i).label==t) {
				found = true;
			}
		}
		if (!found) {
			cb.addItem({label:t, data:n});
		}
		// sort items in combo
		cb.sortItems(this.compareFunc);
		// select the newly selected score
		for (var i=0; i<cb.length; i++) {
			if (cb.getItemAt(i).label==t) {
				cb.selectedIndex = i;
			}
		}
		// show feedback for the newly selected score
		this.showFeedback(Number(cb.selectedItem.label));
	} else if (!isNaN(n)) {
		cb.text = "";
		this.clearFeedback();
	}
}
combos.addNewScoreFromInput = function(cb) : Void {	// v0.16.0, DL: for score-based feedback
	var t = cb.value;
	this.addNewScore(t);
}
combos.enter = function(evtObj:Object) : Void {	// v0.16.0, DL: for score-based feedback
	this.addNewScoreFromInput(evtObj.target);
}
combos.focusOut = function(evtObj:Object) : Void {	// v0.16.0, DL: for score-based feedback
	this.addNewScoreFromInput(evtObj.target);
}
combos.close = function(evtObj:Object): Void {	// v0.16.0, DL: for score-based feedback
	this.showFeedback(Number(evtObj.target.selectedItem.label));
	//NNW.screens.txts.txtScoreBasedFeedback.setFocus();
}
