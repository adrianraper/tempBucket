import mx.controls.TextArea;

class Classes.errorBox {
	
	var parent:Object;
	var name:String;
	var attr:Object;
	var x:Number;
	var y:Number;
	var w:Number;
	var h:Number;
	var text:String;
	var time:Number;
	var timerInterval:Number;
	
	function errorBox() {
		timerInterval = 0;
	}
	
	function setPosition(n1:Number, n2:Number) : Void {
		if (n1!=undefined) { x = n1; }
		if (n2!=undefined) { y = n2; }
	}
	function setSize(n1:Number, n2:Number) : Void {
		if (n1!=undefined) { w = n1; }
		if (n2!=undefined) { h = n2; }
	}
	
	function createErrorBox() : Void {
		/* create the errorbox mc if it's undefined */
		if (parent[name+"_mc"]==undefined) {
			parent.createEmptyMovieClip(name+"_mc", parent.getNextHighestDepth());
		}
		/* make the errorbox invisible to set up positions and things */
		parent[name+"_mc"]._visible = false;
		parent[name+"_mc"]._x = x;
		parent[name+"_mc"]._y = y;
		parent[name+"_mc"].attachMovie("MC - bubble", "bg", 1);
		parent[name+"_mc"].bg._width = w;
		parent[name+"_mc"].bg._height = h;
		parent[name+"_mc"].createClassObject(TextArea, "txt", 2);
		var t = parent[name+"_mc"].txt;
		t.setStyle("borderStyle", "none");
		t.depthChild0._visible = false;
		var tw = w*131/180;
		var th = h*55.4/100;
		t.setSize(tw, th);
		t.wordWrap = true;
		t.editable = false;
		t.html = true;
		t.label.selectable = false;
		t.hScrollPolicy = "off";
		t.vScrollPolicy = "off";
		setTextInTextArea();
		t.label.autoSize = "left";
		var tx = w*27.6/180;
		var ty = h*22.7/100;
		t._x = tx;
		t._y = ty;
		/* show the errorbox */
		parent[name+"_mc"]._visible = true;
		if (time==undefined) {time = 3000;}
		// v0.9.0, DL: time=0 means forever!
		if (time!=0) {
			timerInterval = setInterval(this, "removeErrorBox", time);
		}
	}
	
	function removeErrorBox() : Void {
		clearInterval(timerInterval);
		parent[name+"_mc"]._visible = false;
		if (parent[name+"_mc"].txt!=undefined) {
			parent[name+"_mc"].destroyObject("txt");
		}
	}
	
	function setTextInTextArea() : Void {
		var literals = _global.NNW.view.literals;
		var s = literals.getLiteral("msg"+name);
		
		// v0.16.1, DL: get font for particular language
		var f = literals.getSelectedLanguageFont();
		
		s = "<FONT FACE='" + f + "'><FONT SIZE='13'>" + s;
		s = s + "</FONT></FONT>"
		if (s.indexOf("[APP]", 0)>-1) {
			var appStr = "<A HREF='asfunction:_global.NNW.control.upgrade' target='_blank'><FONT COLOR='#0000FF'>Author Plus Pro</FONT></A>";
			s = _global.replace(s, "[APP]", appStr);
		}
		if (s.indexOf("[field]", 0)>-1) {
			switch (_global.NNW.control.data.currentExercise.exerciseType) {
			case "Dropdown" :
				var f = _global.NNW.view.literals.getLiteral("lblFieldDropdown");
				break;
			case "Stopgap" :
			case "Cloze" :
				var f = _global.NNW.view.literals.getLiteral("lblFieldGap");
				break;
			case "DragAndDrop" :
			case "DragOn" :
			case "Stopdrop":
				var f = _global.NNW.view.literals.getLiteral("lblFieldDrop");
				break;
			case "Countdown" :
				var f = _global.NNW.view.literals.getLiteral("lblFieldCountdown");
				break;
			case "TargetSpotting" :
			case "Proofreading" :
				var f = _global.NNW.view.literals.getLiteral("lblFieldTarget");
				break;
			case _global.g_strQuestionSpotterID: // v6.5.1 Yiu add bew exercise type question spotter
				var f = _global.NNW.view.literals.getLiteral("lblFieldQuestionSpotter");
				break;
			// v6.5.1 Yiu 6-5-2008 New exercise type error correction
			case _global.g_strErrorCorrection:	
				var f = _global.NNW.view.literals.getLiteral("lblFieldError");
				break;
			// End v6.5.1 Yiu 6-5-2008 New exercise type error correction
			default :
				var f = "";
			}
			s = _global.replace(s, "[field]", f);
			
	//case _global.g_strErrorCorrection:	// v6.5.1 Yiu 6-5-2008 New exercise type error correction
		}
		for (var i in attr) {
			if (attr[i]!=undefined) {
				if (s.indexOf("["+i+"]", 0)>-1) {
					s = _global.replace(s, "["+i+"]", attr[i]);
				}
			}
		}
		parent[name+"_mc"].txt.text = s;
	}	
}