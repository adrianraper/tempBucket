
// accordion
//acds.questionArray = new Array("question_mc", "text_mc", "options_mc", "feedbackhint_mc", "answerIs_mc");
acds.onAccordionLoaded = function(acdName:String) : Void {
	this.assignSegments(acdName);
}

/*acds.assignSegments = function(acdName:String) : Void {
	// create children
	switch (acdName) {
	case "acdExercise" :
		//this[acdName].createSegment("exercise_mc", "child0");
		this[acdName].assignSegment(1, "exercise_mc");
		this[acdName].assignSegment(1, "truefalse_mc");
		//this[acdName].createSegment("multiplechoice_mc", "child1");
		for (var i in this.questionArray) {
			this[acdName].assignSegment(2, this.questionArray[i]);
		}
		//this[acdName].assignSegment(3, "settings_mc");
		break;
	case "acdTextEntry" :
		//this[acdName].createSegment("feedback_mc", "child0");
		this[acdName].assignSegment(1, "feedback_mc");
		//this[acdName].createSegment("hint_mc", "child1");
		this[acdName].assignSegment(2, "hint_mc");
		break;
	}
}*/

acds.changeSegment = function(acdName:String, index:Number, showNames:Array, hideNames:Array) : Void {
	switch (acdName) {
	case "acdExercise" :
		this[acdName].changeSegment(index, showNames, hideNames);
		break;
	}
}

acds.setLabels = function(acdName:String, labelArray:Array) : Void {
	var acd = this[acdName];
	// works for 1st time assignment only
	//acd.child0.label = label0;
	//acd.child1.label = label1;
	for (var i=0; i<labelArray.length; i++) {
		acd["child"+i].label = labelArray[i];
	}	
	// works for changes in header label after 1st assignment
	//acd._header0.label = label0;
	//acd._header1.label = label1;
	for (var i=0; i<labelArray.length; i++) {
		acd["_header"+i].label = labelArray[i];
	}	
	// works for MyAccordion
	//acd.setSegmentLabel(1, label0);
	//acd.setSegmentLabel(2, label1);
}

acds.setToFirstSegments = function() : Void {
	var a:Array = new Array("acdExercise", "acdTextEntry");
	for (var i in a) {
		this[a[i]].moveSegments(1);
	}
}
