import Classes.dataField;
import mx.data.encoders.Num;

class Classes.dataFieldManager {
	
	var ex:Object;
	var fields:Array;
	var outputFields:Array;
	var exerciseType:String="";
	var defaultFieldType:String="";
	
	var processedFieldIDs:Array; // v0.11.0, DL: store the processed field ids
	
	var outputFeedback:Array;	// v0.12.0, DL: rearrange feedback & hint
	var outputHint:Array;
	
	var quizFieldTrue:String;	// v6.4.1.4, DL: DEBUG - add true option for quiz
	var quizFieldFalse:String;	// v6.4.1.4, DL: DEBUG - add false option for quiz
	
	function dataFieldManager() {
		fields = new Array();
		outputFields = new Array();
		exerciseType = "Presentation";
		defaultFieldType = "i:url";
		
		outputFeedback = new Array();
		outputHint = new Array();
		
		processedFieldIDs = new Array();
		
		// v6.4.1.4, DL: DEBUG - add true/false option labels for quiz
		quizFieldTrue = "";
		quizFieldFalse = "";
	}
	
	function setRefToExercise(e:Object) : Void {
		ex = e;
	}
	
	/* set the exercise type and set the default field type accordingly */
	function setExerciseType(s:String) : Void {
		exerciseType = s;
		switch (s) {
		case "MultipleChoice" :
		case "Quiz" :
		case "Analyze" :
		case "TargetSpotting" :	// v0.16.0, DL: new exercise type
		case "Proofreading" :	// v0.16.0, DL: new exercise type
		case _global.g_strQuestionSpotterID:
			defaultFieldType = "i:target";
			break;
		case "Cloze" :
		case "Stopgap" :
			defaultFieldType = "i:gap";
			break;
		// v6.4.3 Add new exercise type, item based drop-down
		case "Stopdrop" :
		case "Dropdown" :
			defaultFieldType = "i:dropdown";
			break;
		case "DragOn" :
		case "DragAndDrop" :
			defaultFieldType = "i:drop";
			break;
		case "Countdown" :
			defaultFieldType = "i:countDown";
			break;
		case _global.g_strBulletID:		// Yiu v6.5.1 added new type Bullet
		case "Presentation" :
			defaultFieldType = "i:url";
			break;
		// v6.5.1 Yiu 6-5-2008 New exercise type error correction
		case _global.g_strErrorCorrection:
			defaultFieldType = "i:targetGap";
			break;
		// End v6.5.1 Yiu 6-5-2008 New exercise type error correction
		}
	}
	
	/* on finish loading the xml file, reverse the fields */
	function onFinishedLoading() : Void {
		//fields.reverse();
	}
	
	/* copy the field with oldID from fields[] to outputFields[] */
	// v6.5.0.1 extra parameter for question number
	//function addToOutputFields(oldID:String, newID:String) : Void {
	function addToOutputFields(oldID:String, newID:String, qNo:Number) : Void {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.id==oldID) {
				var oldField = fields[i];
				var newField = new dataField();
				for (var a in oldField.attr) {
					newField.attr[a] = oldField.attr[a];
				}
				newField.attr.id = newID;
				_global.myTrace("dataFM:exType=" + exerciseType + " groupID=" + newField.attr.group + " newID=" + newID + " qNo=" + qNo); 
				// v6.5.0.1 AR why don't you do this processing for question based exercises? Or at least ensure that the group ID
				// is not out of kilter. As far as I can see, the only occasions where fieldID doesn't equal group ID is for MC.
				// And you don't ever come into this function for those types. But just in case...
				if (exerciseType=="MultipleChoice" || exerciseType=="Quiz" || exerciseType=="Analyze") {
				} else {
					// one problem with this is that if you have a question with no field, the fb and hints get mixed 
					// So how about forcing the groupID to be the same as the question number?
					if (qNo<0 || qNo==undefined) {
						newField.attr.group = newID;
					} else {
						newField.attr.group = qNo;
					}
				}
				if (	exerciseType=="Cloze" 						|| 
					exerciseType=="DragOn" 						|| 
					exerciseType=="Dropdown" 					|| 
					exerciseType=="Countdown"					||
					exerciseType=="TargetSpotting"				||
					exerciseType=="Proofreading"					||
					// v6.5.0.1 AR surely the rest of this list are text based exercises? So questionSpotter shouldn't be here?
					// exerciseType==_global.g_strQuestionSpotterID	||	// v6.5.1 Yiu add bew exercise type question spotter
					exerciseType==_global.g_strErrorCorrection		// v6.5.1 Yiu 6-5-2008 New exercise type error correction
					) {
					// v6.5.0.1 Now done above
					// newField.attr.group = newID;
					var oldfb = ex.feedback[Number(oldField.attr.group)-1].value;
					var oldhint = ex.hint[Number(oldField.attr.group)-1].value;
					//_global.myTrace("old feedback "+oldField.attr.group+" = "+oldfb);
					outputFeedback.push({id:Number(newID)-1, value:oldfb});
					outputHint.push({id:Number(newID)-1, value:oldhint});
				}
				_global.myTrace("dataFM: now groupID=" + newField.attr.group + " newID=" + newID);
				
				for (var j=0; j<oldField.answers.length; j++) {
					if (oldField.attr.type!="i:url") {
						//_global.myTrace("DEBUG - trace answer: "+oldField.answers[j].value);
						newField.addAnswer(oldField.answers[j].value, oldField.answers[j].correct);
					} else {
						newField.addAnswer(oldField.answers[j].value);
					}
				}
				outputFields.push(newField);
				processedFieldIDs.push(oldID); /* v0.11.0, DL: debug - store processed field id */
			}
		}
	}
	/* v0.12.0, DL: debug - rearrange feedback & hint */
	function rearrangeFeedbackHint() : Void {
		if (	exerciseType=="Cloze" 							|| 
				exerciseType=="DragOn" 							|| 
				exerciseType=="Dropdown"						||
				exerciseType=="TargetSpotting"					||
				exerciseType=="Proofreading"					||
				// v6.5.0.1 AR surely the rest of this list are text based exercises? So questionSpotter shouldn't be here?
				// exerciseType==_global.g_strQuestionSpotterID	||	// v6.5.1 Yiu add bew exercise type question spotter
				exerciseType==_global.g_strErrorCorrection			// v6.5.1 Yiu 6-5-2008 New exercise type error correction
				) {
			for (var i=0; i<outputFeedback.length; i++) {
				ex.setFeedback(outputFeedback[i].id, outputFeedback[i].value);
			}
			for (var i=0; i<outputHint.length; i++) {
				ex.setHint(outputHint[i].id, outputHint[i].value);
			}
		}
	}
	
	/* v0.11.0, DL: debug - fields that have been added via addToOutputFields should be skipped */
	/* v0.11.0, DL: debug - don't mix up with used output field ids, increment them (starting from fieldCount+1) */
	/* copying static fields */
	function copyStaticFields(fieldCount:Number) : Void {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.type!="i:url") {
				/* v0.11.0, DL: debug - skip processed fields */
				var processed = false;
				for (var j=0; j<processedFieldIDs.length; j++) {
					if (fields[i].attr.id==processedFieldIDs[j]) {
						processed = true;
					}
				}
				if (!processed) {
					var oldField = fields[i];
					var newField = new dataField();
					for (var a in oldField.attr) {
						newField.attr[a] = oldField.attr[a];
					}
					/* v0.12.0, DL: check to see if there's really an answer in this field */
					var hasAnswer = false;
					for (var j=0; j<oldField.answers.length; j++) {
						if (oldField.answers[j].value!=undefined && oldField.answers[j].value.length>0) {
							hasAnswer = true;
							newField.addAnswer(oldField.answers[j].value, oldField.answers[j].correct);
						}
					}
					if (hasAnswer) {
						/*v0.11.0, DL: debug - get new field id (fieldCount++) */
						fieldCount++;
						newField.attr.id = fieldCount.toString();
						outputFields.push(newField);
						//_global.myTrace("assign new field id to "+newField.answers[0].value);
					}
				}
			}
		}
	}
	
	/* clear up the outputFields[] */
	function clearOutputFields() : Void {
		outputFields = new Array();
		/*var l = outputFields.length;
		for (var i=0; i<l; i++) {
			outputFields.pop();
		}*/
		
		/* v0.11.0, DL: debug - skip processed fields */
		processedFieldIDs = new Array();
	}
	
	/* v0.11.0, DL: debug - before we can parse the file, we have to reset the fields */
	function copyOutputFieldsToFields() : Void {
		fields = new Array();
		var l = outputFields.length;
		for (var i=0; i<l; i++) {
			fields.push(outputFields[i]);
		}
	}
	
	/* add a field with the input attributes and answer nodes */
	function addFieldFromXML(attr:Object, answerNodes:Array) : Void {
		if (attr.type!="i:drag") {
			var newField:Object = new dataField();
			newField.setAttributes(attr);
			for(var i=0; i<answerNodes.length; i++) {
				if (answerNodes[i].attributes.correct!=undefined) {
					newField.addAnswer(answerNodes[i].firstChild.nodeValue, answerNodes[i].attributes.correct);
				} else {
					newField.addAnswer(answerNodes[i].firstChild.nodeValue);
				}
			}
			// Changed by WZ
			// Array.reverse() method can't execute correct with object element in array,
			// so we use unshift instead of pop, and not use reverse method.
			fields.unshift(newField);
		}
	}
	
	/* get a new field id */
	function getNewID() : Number {
		var newID = 1;
		for (var i=0; i<fields.length; i++) {
			var id = Number(fields[i].attr.id);
			newID = (id>=newID) ? id+1 : newID;
		}
		return newID;
	}
	
	/* get a new group number */
	function getNewGroupNo() : Number {
		var newGpNo = 1;
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.type!="i:url") {
				var gpNo = Number(fields[i].attr.group);
				newGpNo = (gpNo>=newGpNo) ? gpNo+1 : newGpNo;
			}
		}
		return newGpNo;
	}
	/* get new url group number */
	function getNewUrlGroupNo() : Number {
		var newGpNo = 5001;
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.type=="i:url") {
				var gpNo = Number(fields[i].attr.group);
				newGpNo = (gpNo>=newGpNo) ? gpNo+1 : newGpNo;
			}
		}
		return newGpNo;
	}

	function hasFieldInThisGroup(g:Number) : Boolean {
		var hasField = false;
		for (var i=0; i<fields.length; i++) {
			if (fields[i].getAttr("group")==g.toString()) {
				hasField = true;
				break;
			}
		}
		return hasField;
	}
	
	/* add a field with question number and default answer (and attribute correct) */
	/* return the field no. of this newly added field */
	function addField(qNo:Number, ans:String, cor:String) : Number {
		// v0.16.1, DL: debug - the group number assigned does not match the activeFieldNo assigned by TextAreaFormatting
		// this causes fields to lost their other options
		// it is because the fields are matched by their group no. but this function returns the field no.
		// to solve this problem we should set the group no. to be the same as the field no. if it's not passed
		//if (qNo==undefined || qNo<1) { qNo = getNewGroupNo(); }
		var newID = getNewID();
		if (qNo==undefined || qNo<1){ 	
			qNo = newID; 
		// v6.5.0.1 AR debugging
		} else {
			//_global.myTrace("dFM.addField.passed qNo=" + qNo + " newID=" + newID);
		}
		// v6.5.1 Yiu new default gap length check box and slider 
		var myGapLength:Number;
		myGapLength	= Number(_global.NNW.screens.textFormatting.gapLength);
		
		var newField:Object = new dataField();
		var newFieldAttr:Object = { mode:0, type:defaultFieldType, group:qNo, id:newID, gapLength:myGapLength}; 
		// End v6.5.1 Yiu new default gap length check box and slider 
		
		newField.setAttributes(newFieldAttr);
		newField.addAnswer(ans, cor);
		fields.push(newField);
		return newID;
	}
	/* add a URL with question number and url */
	/* return the field no. of this newly added field */
	function addURL(v:String, u:String) : Number {
		var gpNo = getNewUrlGroupNo();
		var newID = getNewID();
		var newField:Object = new dataField();
		var newFieldAttr:Object = {mode:0, type:"i:url", group:gpNo, url:u, id:newID};
		newField.setAttributes(newFieldAttr);
		newField.addAnswer(v);
		fields.push(newField);
		return newID;
	}
	
	/* delete a field with question no. and option no. */
	function delField(qNo:Number, optNo:Number) : Void {
		var c = 0;
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.group==qNo) {
				c++;
				if (c==optNo) {
					if (i != fields.length - 1) {
						var t1 = fields[i];
						var t2 = fields[fields.length - 1];
						fields[i] = t2;
						fields[fields.length - 1] = t1;
					}
				}
			}
		}
		fields.pop();
	}
	/* delete field with that field id */
	function delFieldWithID(id:Number) : Void {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.id==id && fields[i].attr.type!="i:url") {
				if (i != fields.length - 1) {
					var t1 = fields[i];
					var t2 = fields[fields.length - 1];
					fields[i] = t2;
					fields[fields.length - 1] = t1;
				}
			}
		}
		fields.pop();
	}
	/* delete the url of that field id */
	function delURL(id:Number) : Void {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.id==id && fields[i].attr.type=="i:url") {
				if (i != fields.length - 1) {
					var t1 = fields[i];
					var t2 = fields[fields.length - 1];
					fields[i] = t2;
					fields[fields.length - 1] = t1;
				}
			}
		}
		fields.pop();
	}
	
	/* edit the url of that field id */
	function editURL(id:Number, u:String) : Void {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.id==id && fields[i].attr.type=="i:url") {
				fields[i].attr.url = u;
			}
		}
	}
	
	/* retrieve the url of that field id */
	function retrieveURL(id:Number) : String {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].attr.id==id && fields[i].attr.type=="i:url") {
				return fields[i].attr.url;
			}
		}
		return "";
	}
	
	/* get fields by the type & group attributes */
	function getFields(t:String, g:String) : Array {
		var a:Array = new Array();
		for (var i = 0; i < fields.length; i++) {
			if (fields[i].getAttr("type")==t && fields[i].getAttr("group")==g) {
				a.push(fields[i]);
			}
		}
		return a;
	}
	
	/* get a particular option with its [id] */
	function getOptionWithID(id:String) : Object {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].getAttr("id")==id) {
				return fields[i].answers[0];
			}
		}
	}
	/* v0.11.0, DL: debug - get option with [id] is good, but cannot provide type & url information */
	/* now switch to use getFieldWithID(id) */
	function getFieldWithID(id:String) : Object {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].getAttr("id")==id) {
				return fields[i];
			}
		}
	}
	
	/* v0.11.0, DL: set option with its [id], used when parsing the output string (to capture changes in the field) */
	function setOptionWithID(id:Number, v:String) : Void {
		for (var i = 0; i < fields.length; i++) {
			if (fields[i].getAttr("id")==id.toString()) {
				fields[i].answers[0].value = v;
			}
		}
	}

	/* get targets for particular group, this is useful for MC, T/F & Reading MC */
	function getTargetsOfSameGroup(g:Number) : Array {
		var group = g.toString();
		var a:Array = getFields("i:target", group);
		var o:Array = new Array();
		for(var i=0; i<a.length; i++) {
			if (a[i].answers[0]!=undefined) {
				o.push(a[i].answers[0]);
			}
		}
		return o;
	}

	/* set targets with type & group, this is useful for MC, T/F, Reading MC & Target Spotting */
	function setTargetForGroup(gpNo:Number, targetNo:Number, v:String, c:Boolean) : Void {
		var group = gpNo.toString();
		var a:Array = getFields("i:target", group);
		if (a[targetNo] != undefined) {
			a[targetNo].setAnswer(0, v, c.toString());
		} else {
			var newID = getNewID();
			var newField:Object = new dataField();
			var newFieldAttr:Object = {mode:0, type:"i:target", group:gpNo, id:newID};
			newField.setAttributes(newFieldAttr);
			newField.addAnswer(v, c);
			fields.push(newField);
		}
	}
	/* get answers for particular group */
	function getAnswers(g:Number) : Array {
		var a:Array = new Array();
		for (var i=0; i<fields.length; i++) {
			if (fields[i].getAttr("group")==g.toString()) {
				for (var j=0; j<fields[i].answers.length; j++) {
					a.push(fields[i].answers[j]);
				}
			}
		}
		return a;
	}
	/* edit (other) answer with question no. and option no. */
	function setAnswer(qNo:Number, optNo:Number, val:String, cor:Boolean) : Void {
		var fieldFound = false;
		for (var i=0; i<fields.length; i++) {
			if (fields[i].getAttr("group")==qNo.toString()) {
				fieldFound = true;
				fields[i].setAnswer(optNo+1, val, cor.toString());
			}
		}
		if (!fieldFound) {
			addField(qNo);
			setAnswer(qNo, optNo, val, cor);
		}
	}
	/* get all options with its group (for dropdown) */
	function getOtherOptionsWithGroup(g:Number) : Array {
		var a:Array = new Array();
		for (var i=0; i<fields.length; i++) {
			if (fields[i].getAttr("group")==g.toString()) {
				for (var j=0; j<fields[i].answers.length; j++) {
					a.push(fields[i].answers[j]);
				}
			}
		}
		return a;
	}
	/* v0.14.0, DL: remove all (other) answers with question no. */
	function removeAllAnswers(qNo:Number) : Void {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].getAttr("group")==qNo.toString()) {
				for (var j=1; j<fields[i].answers.length; j++) {
					fields[i].answers.pop();
				}
				//while(fields[i].answers.length){
			//		fields[i].answers.pop();
				//}
			}
		}
	}
	
	function removeAllCurOptionAnsFields():Void {
		_global.NNW.screens.dgs.dgOption.removeAll();
	}
	
	/* v0.16.0, DL: change all targets to correct = true/neutral (for target spotting) */
	function changeTargetsCorrectness(s:String) : Void {
		for (var i=0; i<fields.length; i++) {
			if (fields[i].getAttr("type")=="i:target") {
				fields[i].answers[0].correct = s;
			}
		}
	}
	
	/* v0.16.0, DL: get field ID for an option with groupNo and optionNo */
	function getFieldIDWithGroupAndOptionNos(g:Number, n:Number) : String {
		var group = g.toString();
		var a:Array = getFields("i:target", group);
		if (a[n]!=undefined) {
			return a[n].getAttr("id");
		} else {
			return "";
		}
	}
	
	function insertFieldsWithGroupNos(g:Number, insertFields:Array):Void {
		var index:Number; // index for inserting
		var groupID:Number; // current group id of field
		var isGetIndex:Boolean = false;
		var tmpFields : Array = new Array();
		//_global.myTrace("group id for inserint: " + g);
		// Search the insert index by group id first.
		for (var i = 0; i < fields.length; i++) {
			groupID = Number(fields[i].getAttr("group"));
			if (groupID >= g && fields[i].answers[0].value <> "") {
				// Change the group id which is after the insert place
				fields[i].setAttr("group", String(groupID + 1)); 
				if (!isGetIndex) {
					// return the index for inserting
					isGetIndex = true;
					index = i;
				}
			}
		}
		
		// if insert to the last
		if ( g > Number(fields[fields.length - 1].getAttr("group")) ) {
			index = g;
		}
		
		// duplicate inserting field and insert
		for (var j = 0; j < insertFields.length; j++) {
			tmpFields[j] = dataField.duplicate(insertFields[j]);
			tmpFields[j].setAttr("group", String(g));
			fields.splice(index + j , 0, tmpFields[j]);
		}
		
		// rebuild fields' id
		for (var k = 0; k < fields.length; k++) {
			fields[k].setAttr("id", String(k + 1));
		}
	}
	
	function deleteFieldsWithGroupNos(g:Number):Void {
		var index:Number; // index for inserting
		var groupID:Number; // current group id of field
		var delNum:Number = 0;
		var isGetIndex:Boolean = false;
		_global.myTrace("group id for deleting: " + g);
		// Search the insert index by group id first.
		for (var i = 0; i < fields.length; i++) {
			groupID = Number(fields[i].getAttr("group"));
			if (groupID == g && fields[i].answers[0].value <> "") {
				if (!isGetIndex) {
					// return the index for deleting
					isGetIndex = true;
					index = i;
				}
				delNum++;
			}
		}
		
		_global.myTrace("total delete number is:" + delNum);
		if (delNum > 0) {
			// delete field from fileds
			fields.splice(index, delNum);
		}else {
			_global.myTrace("Fields were not found with this group " + g);
		}


		// rebuild group id
		for (var i = 0; i < fields.length; i++) {
			groupID = Number(fields[i].getAttr("group"));
			if (groupID > g) {
				// Change the group id which is after the insert place
				fields[i].setAttr("group", String(groupID - 1)); 
			}
		}

		// rebuild fields' id
		for (var k = 0; k < fields.length; k++) {
			fields[k].setAttr("id", String(k + 1));
		}

	}
	
	/* Get the clone fields by group attributes */
	function getCloneFields(g:String) : Array {
		var a:Array = new Array();
		for (var i = 0; i < fields.length; i++) {
			if (fields[i].getAttr("group") == g && fields[i].answers[0].value <> "") {
				a.push(dataField.duplicate(fields[i]));
			}
		}
		return a;
	}
}