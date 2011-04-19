class Classes.dataParagraph {
	var attr:Object;
	var value:String;
	
	function dataParagraph() {
		attr = new Object();
		value = "";
	}
	
	function setAttributes(obj:Object) : Void {
		for (var i in obj) {
			if (obj[i]!=undefined) {
				attr[i] = obj[i];
			}
		}
	}
	
	function setValue(s:String) : Void {
		value = (s!=undefined && s.length>0) ? s : "";
	}
	
	function addParagraphToBeginning(s:String)  : Void {
		if (s!=undefined && s.length>0) {
			value = s + value;
		}
	}
	
	function addParagraphToEnd(s:String) : Void {
		if (s!=undefined && s.length>0) {
			value = value + s;
		}
	}
	
	/* Duplicate dataParagraph */
	static function duplicate(oParagraph: dataParagraph): dataParagraph {
		var newObj : dataParagraph = new dataParagraph();
		
		// following attributes are copied from dataExercise.as, please update with those file together.
		// questionAttr = {type:"question", x:"50", y:"=", width:"382", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
		var newAttr : Object = {
				type	: oParagraph.attr.type,
				x		: oParagraph.attr.x,
				y		: oParagraph.attr.y,
				width	: oParagraph.attr.width,
				height	: oParagraph.attr.height,
				style	: oParagraph.attr.style,
				tabs	: oParagraph.attr.tabs,
				indent	: oParagraph.attr.indent
			}; 
		
		newObj.setAttributes(newAttr);
		newObj.value = oParagraph.value;
		return newObj;
	}
}