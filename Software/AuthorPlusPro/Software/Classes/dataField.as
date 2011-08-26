class Classes.dataField{
	var attr:Object;		// id, mode, type, group, url
	var answers:Array;
	
	function dataField() {
		attr = new Object;
		answers = new Array;
	}
	function setAttributes(obj:Object) : Void {
		for (var i in obj) {
			if (obj[i]!=undefined) {
				attr[i] = obj[i];
			}
		}
	}
	
	// set the value of attribute, suppose all the value is String type
	function setAttr(n:String, v:String) : Void {
		attr[n] = v;
	}
	
	function getAttr(n:String) : String {
		return attr[n];
	}
	
	function addAnswer(ans:String, cor:String) : Void {
		if (ans!=undefined) {
			answers.push({value:ans, correct:cor});
		} else {
			_global.myTrace("warning: answer is undefined");
		}
	}
	
	function setAnswer(n:Number, ans:String, cor:String) : Void {
		if (answers[n] == undefined) {
			answers[n] = new Object();
		}
		if (ans != undefined) {
			answers[n].value = ans;
		}
		if (cor != undefined) {
			answers[n].correct = cor;
		}
	}
	
	function removeAllAnswers() : Void {
		for (var i in answers) {
			delete answers[i];
		}
		answers.length = 0;
	}
	
	/* Duplicate dataField */
	static function duplicate(oField: dataField): dataField {
		var newField : dataField = new dataField();
		var newFieldAttr : Object = {
				id		: oField.attr.id,
				mode	: oField.attr.mode,
				type	: oField.attr.type,
				group	: oField.attr.group,
				gapLength: oField.attr.gapLength,
				url		:oField.attr.url
			}; 
		
		newField.setAttributes(newFieldAttr);
		for (var i = 0; i < oField.answers.length; i++) {
			newField.addAnswer(oField.answers[i].value, oField.answers[i].correct);
		}
		return newField;
	}
}