class Classes.xmlCompareClass extends XML {

var localXml:Object;
var nextAction:String;
	
function xmlCompareClass(o:Object) {
	this.ignoreWhite = true;
	localXml = o;
	nextAction = "";
}

function onLoad(success) : Void {
	// an instance of this will reload the xml file when necessary
	// but the declaration will be accumulated each time (bug?) so we've to rewrite it
	this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
	if (success) {
		//_global.myTrace("compare class got sth back");
		compareXml();
	} else {
		//_global.myTrace("compare class got no response");
		returnResult(true);
	}
}

function loadXML(action:String) : Void {
	nextAction = action;
	//_global.myTrace("loading " + localXml.XMLfile+"?nocache="+random(999999));
	this.load(localXml.XMLfile+"?nocache="+random(999999));
}

function compare(m:XMLNode, n:XMLNode) : Boolean {
	var pass = true;
	if (m.hasChildNodes()) {
		if (m.childNodes.length!=n.childNodes.length) {
			//_global.myTrace("m nodes.length=" + m.childNodes.length);
			//_global.myTrace("n  nodes.length=" + n.childNodes.length);
			pass = false;
		} else {
			for (var i in m.childNodes) {
				if (!compare(m.childNodes[i], n.childNodes[i])) {
					//_global.myTrace("compare false for id=" + m.childNodes[i].attributes.id);
					//_global.myTrace("m=" + m.childNodes[i].toString());
					//_global.myTrace("n =" + n.childNodes[i].toString());
					pass = false;
				}
			}
		}
	} else if (n.hasChildNodes()) {
		pass = false;
	}
	if (pass) {
		if (m.nodeName!=n.nodeName) {
			//_global.myTrace("m nodes.name=" + m.nodeName);
			//_global.myTrace("n  nodes.name=" + n.nodeName);
			pass = false;
		} else if (m.attributes.length!=n.attributes.length){
			//_global.myTrace("m attributes.length=" + m.attributes.length);
			//_global.myTrace("n  attributes.length=" + n.attributes.length);
			pass = false;
		} else {
			for (var i in m.attributes) {
				if (m.attributes[i]!=n.attributes[i]) {
					//_global.myTrace("m attributes.[" + i + "]=" + m.attributes[i] + (typeof m.attributes[i]));
					//_global.myTrace("n  attributes.[" + i + "]=" + n.attributes[i] + (typeof n.attributes[i]));
					pass = false;
				}
			}
		}
	}
	return pass;
}

function compareXml() : Void {
	//_global.myTrace("compareXML data=" + this.firstChild.toString() + " file=" + localXml.firstChild.toString());
	var pass = compare(this.firstChild, localXml.firstChild);
	returnResult(pass);
}

function returnResult(b:Boolean) : Void {
	_global.myTrace(localXml.XMLfile + " same as "+b);
	
	var control = _global.NNW.control;
	switch (nextAction) {
	case "AddCourse" :
		control.onComparedXmlAddCourse(b, this);
		break;
	case "AddUnit" :
		control.onComparedXmlAddUnit(b, this);
		break;
	case "RenameUnit" :
		control.onComparedXmlRenameUnit(b, this);
		break;
	case "MoveUnit" :
		control.onComparedXmlMoveUnit(b, this);
		break;
	case "AddExercise" :
		// there's no need to compare coz we'll update it anyway
		control.onComparedXmlAddExercise(this);
		break;
	// v6.4.3 Added for other events too
	case "DelCourse" :
		control.onComparedXmlDelCourse(b, this);
		break;
	case "DelCourseFolder" :
		control.onComparedXmlDelCourseFolder(b, this);
		break;
	case "RenameCourse" :
		control.onComparedXmlRenameCourse(b, this);
		break;
	case "RenameCourseFolder" :
		control.onComparedXmlRenameCourseFolder(b, this);
		break;
	}
}

}