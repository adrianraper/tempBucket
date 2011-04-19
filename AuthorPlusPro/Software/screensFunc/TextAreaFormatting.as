class screensFunc.TextAreaFormatting {
	var field:Object;
	var urlInput:Object;
	//var urlLabel:Object;
	
	var startIndex:Number;
	var endIndex:Number;
	var caretIndex:Number;
	// v0.7.1, DL: debug - keep vertical position of the text so that it doesn't scroll after applying format
	var vPos:Number;
	
	var format:TextFormat;
	var selectedColor:Number;

	// AR v6.4.2.5 save text screwed by ctrl-b characters
	var savedText:String;
	
	// v6.5.1 Yiu fixing text style problems
	var bDontCopyStyleFromFormerWord:Boolean	= false;
	var newUrl:Boolean;
	var activeFieldNo:Number;
	var m_lastClickNonFieldTime:Number;
	var m_bFirstClickOfDouble:Boolean;
	
	// true indicates there's a clicking on the field, and highlighting has not finished, so lock mouse click!
	var clickingOnField:Boolean;
	
	// add spaces after gap
	var gapLength:Number;
	var m_defaultGapLength:Number;
	
	/* v0.11.0, DL: button on formatting toolbar */
	var btnBold:Object;
	var btnItalic:Object;
	var btnUnderline:Object;
	var btnLeft:Object;
	var btnCenter:Object;
	var btnRight:Object;
	var btnBullet:Object;
	var btnDeBlockIndent:Object;
	var btnInBlockIndent:Object;
	var btnLink:Object;
	var cmbFont:Object;
	var cmbSize:Object;
	
	var showLinkBarFunc:Function;
	
	function TextAreaFormatting() {
		startIndex = 0;
		endIndex = 0;
		caretIndex = 0;
		vPos = 0;	// v0.7.1, DL: debug
		selectedColor = 0x000000;
		newUrl = true;
		activeFieldNo = 0;
		clickingOnField = false;
		gapLength = 1;
		
		m_defaultGapLength	= 1;
		Selection.addListener(this);
		
		m_lastClickNonFieldTime		= 0;
		m_bFirstClickOfDouble		= false;
		
		_global.aryTextAreaFormatting.push(this);	// v6.5.1 Yiu fixing Scorebasedfeedback font style problem
	}
	
	/* functions to set reference to text area and url input field */
	public function setTextArea(t:Object) : Void {
		field = t;
	}
	/* v0.11.0, DL: no need to control the label of url input field, all we need to do is just to put text into it */
	public function setUrlInput(t:Object) : Void {
		urlInput = t;
	}
	/*public function setUrlLabel(t:Object) : Void {
		urlLabel = t;
		t._visible = false;
	}*/
	
	/* v0.11.0, DL: show link bar function moved out of this class */
	public function showLinkBar(b:Boolean) : Void {
		if (b) {
			field._parent.editable = false;
			field.selectable = false;
		} else {
			field._parent.editable = true;
			field.selectable = true;
		}
		showLinkBarFunc(b);
	}
	/* v0.12.0, DL: show link popup */
	public function showLinkPopup(b:Boolean, v:String) : Void {
		_global.NNW.view.showPopup("weblink", v);
	}
	/* function for showing url input field */
	/*private function showUrlInput(b:Boolean) : Void {
		urlLabel._visible = b;
		urlInput._parent._visible = b;
		if (b) {
			field._parent.editable = false;
			field.selectable = false;
			Selection.setFocus(urlInput._parent);
			Selection.setSelection(urlInput.text.length, urlInput.text.length);
		} else {
			urlInput.text = "";
			field._parent.editable = true;
			field.selectable = true;
		}
	}*/
	
	/* functions to be called outside for setting formats */
	public function setFormat(f:String, v) : Void {
		switch (f) {
		case "bold" :
		case "italic" :
		case "underline" :
		case "left" :
		case "center" :
		case "right" :
		case "bullet" :
		case "deBlockIndent" :
		case "inBlockIndent" :
			bDontCopyStyleFromFormerWord	= true;
			toggleFormat(f);
			applyFormat();
			returnFocus();
			break;
		case "font" :
		case "size" :
			format[f] = v;
			applyFormat();
			/* odd things happen again, most probably combobox is still keeping the focus after broadcasting the change event? */
			//returnFocus();
			var intObj = new Object();
			intObj.field = field;
			intObj.startIndex = startIndex;
			intObj.endIndex = endIndex;
			intObj.intFunc = function(i) {
				clearInterval(i.intID);
				Selection.setFocus(i.field);
				
				Selection.setSelection(i.startIndex, i.endIndex);
			}
			intObj.intID = setInterval(intObj.intFunc, 500, intObj);
			break;
		case "setField" :
		case "clearField" :
			// v0.11.0, DL: only text or question TextArea can have fields
			// v0.16.1, DL: split-screen question can also have fields
			if (field._parent._name=="txtText"||field._parent._name=="txtQuestion"||field._parent._name=="txtSplitScreenQuestion") {
				setField(f);
				returnFocus();
			}
			break;
		}
	}
	public function setColor(c:Number) : Void {
		bDontCopyStyleFromFormerWord	= true;
		// v0.5.2, DL: don't keep the selected color
		//selectedColor = c;
		format.color = c;
		applyFormat();
		returnFocus();
	}
	/* v0.11.0, DL: debug - allow change of field length after a field is made */
	private function setGapLength(n:Number) : Void {
		gapLength = n;
		
		if (format.url.indexOf("fieldClick", 0) > -1) { 
			increaseCurrentFieldLength(gapLength);
			applyFormat();
			/*we cannot return focus here because the user might continuously dragging the slider */
		}
	}
	
	// v6.5.1 Yiu new default gap length check box and slider 
	public function setDefaultGapLength(n:Number) : Void {
		m_defaultGapLength = n;
	}
	// End v6.5.1 Yiu new default gap length check box and slider 
	
	/* end of functions to be called outside for setting formats */
	
	private function showCurrentFormat() : Void {
		//format.bold	= s_bBlackIsBold;	// v6.5.1 Yiu fix font style problem wave 2
		btnBold.selected = format.bold;
		btnItalic.selected = format.italic;
		btnUnderline.selected = format.underline;
		btnLeft.selected = (format.align!="center"&&format.align!="right");
		btnCenter.selected = (format.align=="center");
		btnRight.selected = (format.align=="right");
		btnBullet.selected = format.bullet;
		btnLink.selected = (format.url.indexOf("urlClick", 0) > -1);
		for (var i=0; i<cmbFont.length; i++) {
			if (cmbFont.getItemAt(i).data==format.font) {
				cmbFont.selectedIndex = i;
				break;
			}
		}
		for (var i=0; i<cmbSize.length; i++) {
			if (cmbSize.getItemAt(i).data==format.size) {
				cmbSize.selectedIndex = i;
				break;
			}
		}
	}
	
	/* listener/response functions */
	public function onSetFocus(oldFocus:Object, newFocus:Object) : Void {
		/* v0.11.0, DL: to use formatting tools on more than 1 field, use focus to set field */
		if (newFocus._parent instanceof mx.controls.TextArea) {
			field = newFocus;
			getOriginalFormat();
		//}
		//if (newFocus==field) {
			Mouse.addListener(this);
			Key.addListener(this);	// v0.7.1, DL: listen to keys as well (for highlighting)
		} else {
			Mouse.removeListener(this);
			Key.removeListener(this);	// v0.7.1, DL: listen to keys as well (for highlighting)
		}
	}
	// v0.7.1, DL: listen to keys as well (for highlighting)
	public function onKeyUp() {
		if(	Key.getCode()	==	37 ||
			Key.getCode()	==	38 ||
			Key.getCode()	==	39 ||
			Key.getCode()	==	40){
			bDontCopyStyleFromFormerWord	= false;
			getSelectionIndexes();
		}
		
		if(	Key.getCode()	==	8 ||
			Key.getCode()	==	46){
			getSelectionIndexes();
		}
		
		if (Key.isDown(Key.SHIFT)) {
			//_global.myTrace("good getSelectionIndexes 2");
			//getSelectionIndexes();
		// v0.7.1, DL: add ctrl+B, ctrl+I, ctrl+U for formatting
		} else if (Key.isDown(Key.CONTROL)) {
			// AR v6.4.2.5 You have to stop the network version inserting an odd character that replaces the selected text
			// if you press ctrl-b or ctrl-u - it seems these go in as ascii 2 and 21!!
			// But in onKeyUp it is too late, this has to be stopped in onKeyDown
			//_global.myTrace("selection=" + field.text.substr(startIndex, endIndex));
			// has the selected text changed? If it has, we need to get rid of the inserted character
			
			var bTarKeyPressed:Boolean	= false;
			//_global.myTrace("key.control=" + Key.getCode());
			switch(Key.getCode()) {
			case 66 :	// B
				setFormat("bold");
				bTarKeyPressed	= true;
				break;
			case 73 :	// I
				setFormat("italic");
				bTarKeyPressed	= true;
				break;
			// v6.5.1 Yiu Ctrl-U disabled
			//case 85 :	// U
			//	setFormat("underline");
			//	bTarKeyPressed	= true;
			//	break;
			}
			
			if(bTarKeyPressed){
				var newText = field.text.substring(startIndex, endIndex);
				if (newText != savedText) {
					//_global.myTrace("replace with " + this.savedText);
					Selection.setSelection(startIndex, startIndex+1);
					
					field.replaceSel(savedText);
				}
			}
		} else if (Key.getCode()!=Key.SHIFT) {
			//_global.myTrace("good getSelectionIndexes 1");
			//getSelectionIndexes();
			//_global.NNW.screens.dispatchEvent({type:"mouseUp"});

		}
	}
	
	// AR v6.4.2.5 Stop ctrl characters in network screwing up text	public function onKeyUp() {
	public function onKeyDown() {
		//getSelectionIndexes();
		
		if(	Key.getCode()	== 8	||
			Key.getCode()	== 46){
			bDontCopyStyleFromFormerWord	= true;
		}
		
		if (Key.isDown(Key.CONTROL)) {
			// AR v6.4.2.5 You have to stop the network version inserting an odd character that replaces the selected text
			// if you press ctrl-b or ctrl-u - it seems these go in as ascii 2 and 21!!
			// But in onKeyUp it is too late, this has to be stopped in onKeyDown
			//_global.myTrace("selection=" + field.text.substring(startIndex, endIndex));
			this.savedText = field.text.substring(startIndex, endIndex);
		}
	}

	public function onMouseDown() {
		if (!clickingOnField) {
		}
	}
	
	public function onMouseUp() {		
		bDontCopyStyleFromFormerWord	= false;
		// v0.7.1, DL: listen to keys as well (for highlighting)
		//_global.myTrace("start = "+startIndex+"; caret = "+caretIndex+"; end = "+endIndex);
		if (!field._parent.vScroller.hitTest(field._parent._xmouse, field._parent._ymouse, false)) {
			// v6.5.1 Yiu restore to default gap length if lose focus on the selected fill
			if (!_global.bJustReturnFocusAfterReleaseOnSlider)
			{
				var exType = _global.NNW.control.data.currentExercise.exerciseType;
				switch(exType)
				{
					case "Cloze":
						if (Selection.getFocus() == targetPath(_global.NNW.screens.txts.txtText.label)) {
							if (_global.NNW.screens.chbs.getChecked("chbDefaultLengthGaps"))
							{
								_global.NNW.screens.textFormatting.resetFormatURL();
				
								var ex 		= _global.NNW.control.data.currentExercise;
								_global.NNW.control.updateExerciseSettings(	"exercise", 
																			"defaultLengthGaps", 
																			_global.NNW.screens.sliderDefaultLengthGap.getValue().toString());
								ex.initExerciseScreenGapLength();
							}
						}
					break;
				}
			}
			
			_global.bJustReturnFocusAfterReleaseOnSlider	= false;
			// End v6.5.1 Yiu restore to default gap length if lose focus on the selected fill
	
			if (Key.isDown(Key.SHIFT)) {
				caretIndex= Selection.getCaretIndex();
				//_global.myTrace("SHIFT 1 - start = "+startIndex+"; caret = "+caretIndex+"; end = "+endIndex);
				if (caretIndex<startIndex) {
					//_global.myTrace("update from here 1");
					startIndex = caretIndex;
				} else if (caretIndex > endIndex) {
					endIndex = caretIndex;
				}
				//_global.myTrace("SHIFT 2 - start = "+startIndex+"; caret = "+caretIndex+"; end = "+endIndex);
				// v0.7.1, DL: Selection.setSelection(startIndex, endIndex); doesn't work backward!
				/* no idea why this happens, but the solution is to set the caret to startIndex before setting the Selection */
				
				Selection.setSelection(startIndex, startIndex);
				var intObj = new Object();
				intObj.startIndex = startIndex;
				intObj.endIndex = endIndex;
				intObj.intFunc = function(i) {
					clearInterval(i.intID);
					
					Selection.setSelection(i.startIndex, i.endIndex);
					/* v0.11.0, DL: capture original format */
					getOriginalFormat();
				}
				intObj.intID = setInterval(intObj.intFunc, 10, intObj);
			} else if (!clickingOnField) {
				getSelectionIndexes();
			}
		}
	}
	public function change() {
		if (!clickingOnField)
		{
			caretIndex = Selection.getCaretIndex(); 
		}
	}
	
	// v6.5.1 change the gap lenght when user clicked onto a field
	public function ifFieldIsClicked():Boolean
	{
		return format.url.indexOf("fieldClick", 0) > -1;
	}
	
	public function countTheHighlightedTextGapLength():Number
	{
		// v6.5.1 change the gap lenght when user clicked onto a field
		var nFieldGapLength:Number	= 0;
		var strExtracted:String		= field.text.substring(startIndex, endIndex);
		
		for (var v1:Number = strExtracted.length -1; v1 > 0; --v1)
		{	
			if (strExtracted.charAt(v1) == " ")
			{
				nFieldGapLength++;
			} else {
				break;
			}
		}
		
		return nFieldGapLength;
	}
	// End v6.5.1 change the gap lenght when user clicked onto a field
			
	public function fieldClick(no) : Void {
		if (activeFieldNo!=Number(no) || (!clickingOnField && activeFieldNo==Number(no))) {
			clickingOnField = true;
			focusOnField();
			
			if(_global.NNW.screens.textFormatting.getCurrentExerciseType() == "Cloze")
				_global.NNW.screens.setlblShowDefaultVisible(false);
				
			_global.NNW.screens.slider.setValue(countTheHighlightedTextGapLength());
			activeFieldNo = Number(no);
			clickingOnField = false;
		}
	}
	
	// v6.5.1 Yiu new default gap length check box and slider 
	public function setClickingOnField(b:Boolean) : Void {
		clickingOnField	= b;
	}
	
	public function resetFormatURL():Void
	{
		format.url	= ""; 
		startIndex	= 0;
		endIndex	= 0;
		caretIndex	= 0;
	}
	// End v6.5.1 Yiu new default gap length check box and slider 
	
	public function urlClick(no) : Void {
		fieldClick(no);
		newUrl = false;
		// v0.12.0, DL: urlInput.text = retrieveURL(activeFieldNo);
		//showUrlInput(true);
		//showLinkBar(true);	// v0.11.0, DL
		showLinkPopup(true, retrieveURL(activeFieldNo));	// v0.12.0, DL
	}
	public function setUrl(t:String) : Void {
		if (t.length>0) {
			// v6.4.1.4, DL: DEBUG - end-of-line character cracks the field system!
			// does taking them out help? let's see
			t = _global.replace(t, "\r", "");
			t = _global.replace(t, "\n", "");
			
			// v0.16.1, DL: right-trim the URL
			t = _global.rTrim(t);
			
			if (newUrl) {
				// add url
				
				// v6.4.1.4, DL: DEBUG - end-of-line character cracks the field system!
				// does taking them out help? let's see
				var fieldText = field.text.substring(startIndex, endIndex);
				fieldText = _global.replace(fieldText, " \r", " ");	// remove CR
				field.replaceText(startIndex, endIndex, fieldText);
				endIndex = startIndex + fieldText.length;
				
				var fieldNo = addURL(field.text.substring(startIndex, endIndex), t);
				format.url = "asfunction:_global.urlClick,"+fieldNo;
			} else {
				// not new, edit url
				editURL(activeFieldNo, t);
				format.url = "asfunction:_global.urlClick,"+activeFieldNo;
			}
			format.target = "_blank";
			format.color = 0x0000FF;
			//format.color = selectedColor;	// v0.11.0, DL: no more selected color
			format.underline = true;
		} else {
			// delete url
			delURL(activeFieldNo);
			format.url = "";
			format.underline = false;
		}
		applyFormat();
		//showUrlInput(false);
		//showLinkBar(false);	// v0.11.0, DL
		showLinkPopup(true);	// v0.12.0, DL
	}
	/* end of listener/response functions */
	
	/* functions for setting focus */
	// focus back on textarea after applying format
	private function returnFocus() : Void {
		Selection.setFocus(field);
		
		if (checkSelectionExists()) {
			Selection.setSelection(startIndex, endIndex);
		} else {
			//Selection.setSelection(caretIndex, caretIndex);	// v6.5.1 Yiu fix font style problem wave 2 - commented
			Selection.setSelection(startIndex, endIndex);
		}
		field._parent.vPosition = vPos;	// v0.7.1, DL: debug
	}	
	// focus on & select the field being clicked on
	private function focusOnField() : Void {
		findFieldBoundary(caretIndex);
		if (checkSelectionExists()) {
			Selection.setSelection(startIndex, endIndex);
		} else {
			// when the focused field is being clicked again within a short period of time
			// the caret index will go to the end of the selection
			// and then the mouse is just like got stuck there
		}
	}
	private function findFieldBoundary(index:Number) : Void {
		var tf = field.getTextFormat(index);
		var u:String = tf.url;
		if (u.indexOf("Click")>0) {
			var indexA = index;
			var indexB = index;
			var tfA = field.getTextFormat(indexA);
			var tfB = field.getTextFormat(indexB);
			while (tf.url==tfA.url) {
				indexA--;
				tfA = field.getTextFormat(indexA);
			}
			while (tf.url==tfB.url) {
				indexB++;
				tfB = field.getTextFormat(indexB);
			}
			//_global.myTrace("update from here 2");
			startIndex = indexA+1;
			endIndex = indexB;
		} else {
			//_global.myTrace("update from here 3");
			startIndex = index;
			endIndex = index;
		}
		/* v0.11.0, DL: capture original format */
		getOriginalFormat();
	}
	/* end of functions for setting focus */
	
	/* check if user has selected something */
	private function checkSelectionExists() : Boolean {
		//_global.myTrace("check selected start="+startIndex+ " end=" +endIndex);
		return (startIndex!=endIndex);
	}
	
	public function getSelectionIndexes() : Void {
		bDontCopyStyleFromFormerWord	= false;
		//_global.myTrace("get selection indexes");
		//_global.myTrace("update from here 4");
		startIndex = Selection.getBeginIndex();
		endIndex = Selection.getEndIndex();
		caretIndex = Selection.getCaretIndex();
		
		// v0.7.1, DL: debug - better to set start & end indexes to caret index if there's no selection
		if (startIndex==-1) {
			//_global.myTrace("update from here 5");
			startIndex = caretIndex;
		}
		if (endIndex==-1) {
			endIndex = caretIndex;
		}
		
		/* v0.11.0, DL: capture original format */
		getOriginalFormat();
	}
	
	// v6.5.1 Yiu solving high light
	private function modifySelectionIndexesToGetRipNewline(myStartIndex:Number, myEndIndex:Number):Void
	{
		var strSelectedText:String;
		strSelectedText = field.text.substring(myStartIndex, myEndIndex);
		if (myStartIndex == myEndIndex)
			return ;
		
		for (var v2:Number = 0; v2 < strSelectedText.length; ++v2)
		{
			if (!isNewlineChar(strSelectedText.charAt(v2)))
				break;
				
			myStartIndex++;
		}
		
		for (var v2:Number = strSelectedText.length - 1; v2 > 0; --v2)
		{
			if (!isNewlineChar(strSelectedText.charAt(v2)))
				break;
				
			myEndIndex--;
		}
				
		startIndex 	= myStartIndex;
		endIndex 	= myEndIndex;
	}
		
	// v6.5.1 Yiu check if the character is Punctuation
	private function isNewlineChar(strCharacter:String):Boolean
	{
		var nCharASCII_Code:Number;	
		
		for (var v1:Number = 0; v1 < strCharacter.length; ++v1)
		{
			nCharASCII_Code	= strCharacter.charCodeAt(v1);	
			switch(nCharASCII_Code)
			{
				case 13:
					break;
				default:
					return false;
			}		
		}
		
		return true;
	}
	
	private function isAllWord(strCharacter:String):Boolean
	{
		var nCharASCII_Code:Number;	
		
		for (var v1:Number = 0; v1 < strCharacter.length; ++v1)
		{
			nCharASCII_Code	= strCharacter.charCodeAt(v1);	
			
			switch(nCharASCII_Code)
			{
				case 13:
				case 33:
				case 34:
				case 35:
				case 36:
				case 37:
				case 38:
				case 39:
				case 40:
				case 41:
				case 42:
				case 43:
				case 44:
				case 45:
				case 46:
				case 47:
				case 58:
				case 59:
				case 60:
				case 61:
				case 62:
				case 63:
				case 64:
				case 91:
				case 92:
				case 93:
				case 94:
				case 95:
				case 96:
				case 123:
				case 124:
				case 125:
				case 126:
				case 127:
					return false;
			}		
		}
		
		return true;
	}
	
	private function getOriginalFormat() : Void {
		if (checkSelectionExists()) {
			format = field.getTextFormat(startIndex, endIndex);
		} else if (startIndex!=field.text.length) {
			format = field.getTextFormat(startIndex-1);
		} else {
			format = field.getNewTextFormat();
		}
		showCurrentFormat();
	}
	
	public function applyFormat() : Void {
		vPos = field._parent.vPosition;	// v0.7.1, DL: debug
		format.font = "Verdana";
		format.size = 13;
		
		//s_bBlackIsBold	= format.bold;	// v6.5.1 Yiu fix font style problem wave 2
		
		if (checkSelectionExists()) {
			//var backupTempFormat	= field.getTextFormat(endIndex+1, endIndex+2);
			//_global.myTrace("applyFormat to selection, bold= " + format.bold)
			field.setTextFormat(startIndex, endIndex, format);
			//Selection.setSelection(endIndex + 1, endIndex + 1);
			//field.setTextFormat(endIndex, format);
			
			//field.setTextFormat(endIndex, backupTempFormat);
		} else if (startIndex!=field.text.length) {
			//_global.myTrace("applyFormat to all, bold= " + format.bold)
			field.setTextFormat(startIndex, format);
		} else {
			//_global.myTrace("applyFormat to new, bold= " + format.bold) 
			field.setNewTextFormat(format);
		}
		var tempFormat = new TextFormat();
		tempFormat.font = "Verdana";
		tempFormat.size = 13;
		//  v6.4.2.5 Try to set tabs for display in authoring
		tempFormat.tabStops = [50,100,150,200,250,300,350,400];
		field.setNewTextFormat(tempFormat);
	}
	
	//var s_bBlackIsBold:Boolean	= false;	// v6.5.1 Yiu fix font style problem wave 2
	private function toggleFormat(f:String) : Void {
		switch (f) {
		case "bold" :
			format.bold = (format.bold) ? false : true;
			//s_bBlackIsBold	= format.bold;	// v6.5.1 Yiu fix font style problem wave 2
			break;
		case "italic" :
			format.italic = (format.italic) ? false : true;
			break;
		case "underline" :
			format.underline = (format.underline) ? false : true;
			break;
		case "left" :
		case "center" :
		case "right" :
			if (format.align!=f) {
				format.align = f;
			}
			break;
		case "bullet" :
			format.bullet = (format.bullet) ? false : true;
			break;
		case "deBlockIndent" :
			if (format.blockIndent!=null&&format.blockIndent>0) {
				format.blockIndent -= 1;
			} else {
				format.blockIndent = 0;
			}
			break;
		case "inBlockIndent" :
			if (format.blockIndent!=null) {
				format.blockIndent += 1;
			} else {
				format.blockIndent = 1;
			}
			break;
		}
	}
	
	public function showUrl() : Void {
		// v0.11.0, DL: only text or question (usual or RMC) TextArea can have url
		// v0.16.1, DL: change txtRMCText to txtSplitScreenText
		// v0.16.1, DL: change txtRMCQuestion to txtSplitScreenQuestion
		// v6.4.1.4, DL: split-screen text side doesn't support URLs
		//if (field._parent._name=="txtText" || field._parent._name=="txtQuestion" || field._parent._name=="txtSplitScreenText" || field._parent._name=="txtSplitScreenQuestion") {
		if (field._parent._name=="txtText" || field._parent._name=="txtQuestion" || field._parent._name=="txtSplitScreenQuestion") {
			if (checkSelectionExists()) {
				if (format.url.length > 0) {
					if (format.url.indexOf("fieldClick", 0) > -1) {
						// ignore field at the moment
						returnFocus();
					} else {
						// edit old url
						newUrl = false;
						// v0.12.0, DL: urlInput.text = retrieveURL(activeFieldNo);
						//showUrlInput(true);
						//showLinkBar(true);	// v0.11.0, DL
						showLinkPopup(true, retrieveURL(activeFieldNo));	// v0.12.0, DL
					}
				} else {
					// new url, copy the selected string into url input field
					newUrl = true;
					// v0.12.0, DL: urlInput.text = "http://"+field.text.substring(startIndex, endIndex);
					//showUrlInput(true);
					//showLinkBar(true);	// v0.11.0, DL
					
					// v6.4.1.4, DL: DEBUG - end-of-line character cracks the field system!
					// does taking them out help? let's see
					var t = field.text.substring(startIndex, endIndex);
					t = _global.replace(t, "\r", "");
					t = _global.replace(t, "\n", "");
					
					showLinkPopup(true, "http://"+t);	// v0.12.0, DL
				}
			} else {
				// nothing is selected, ignore
				returnFocus();
			}
		}
	}
	
	private function setField(action:String) : Void {
		if (checkSelectionExists()) {
			if (format.url.length > 0) {
				if (format.url.indexOf("urlClick", 0) > -1) {
					// ignore url at the moment
				} else {
					// v0.5.2, DL: set & clear field button seperated
					if (action=="clearField") {
						// clear field
						delField(activeFieldNo); 
						format.url = "";
						format.underline = false;
						applyFormat();
						// v0.5.2, DL: remove spaces from cleared gaps for gap fill exercises
						if (getCurrentExerciseType()=="Stopgap"||getCurrentExerciseType()=="Cloze") {
							leftTrimCurrentField();
						}
						_global.clearFeedbackAndHint(activeFieldNo);
						
						// v6.5.1 Yiu added function for clear all existing ans in other_option, since _global.clearFeedbackAndHint cannot do it's job well
						_global.NNW.control.data.currentExercise.fieldManager.removeAllCurOptionAnsFields();
						
						// Reset to default
						if (_global.NNW.screens.chbs.getChecked("chbDefaultLengthGaps"))
						{
							gapLength	= Number(_global.NNW.screens.sliderDefaultLengthGap.getValue());
						} else {
							var nDefaultGapLength:Number;
							nDefaultGapLength	= 1;
							gapLength			= nDefaultGapLength;
						}
						_global.NNW.screens.fillInGapLength(gapLength);
						var qNo = _global.NNW.screens.getCurrentQuestionNumber();
						_global.NNW.control.updateExercise("gapLength", qNo, gapLength);
						//_global.NNW.screens.checkAndSetlblShowDefaultVisible();
						_global.NNW.screens.setlblShowDefaultVisible(_global.NNW.screens.chbs.getChecked("chbDefaultLengthGaps"));
					}
				}
			} else {
				// v0.5.2, DL: set & clear field button seperated
				if (action == "setField") { 
					modifySelectionIndexesToGetRipNewline(startIndex, endIndex); 
					// not a field/url, add it
					var fieldNo = addField(field.text.substring(startIndex, endIndex)); 
					if (fieldNo>0) {
						trimField(); 	// v0.11.0, DL: trim and remove CR from fields
						// v0.5.2, DL: add spaces in gaps for gap fill exercises
						// v6.5.1 fixing extra space when adding gap in Stopgap
						if (getCurrentExerciseType()=="Stopgap"||getCurrentExerciseType()=="Cloze") {
						//if (getCurrentExerciseType()=="Cloze") {
							increaseCurrentFieldLength(gapLength);
						}
						// v6.4.2.5 AR; make the default for drops to be blue
						if (getCurrentExerciseType()=="DragAndDrop" ||getCurrentExerciseType()=="DragOn") {
							format.color = 0x0000FF; 
						}
						format.url = "asfunction:_global.fieldClick,"+fieldNo;
						format.target = "_blank";
						//format.color = selectedColor;	// v0.11.0, DL: no more selected color
						format.bold = false;
						format.italic = false;
						format.underline = true;
						applyFormat(); 
						// v0.12.0, DL: debug - should show feedback and things on setField
						_global.fieldClick(fieldNo); 
						_global.NNW.screens.checkAndSetlblShowDefaultVisible();
					}
				}
			}
		} else {
			// nothing is selected, ignore
		}
	}
	/* v0.5.2, DL: add spaces in gaps for gap fill exercises */
	private function increaseCurrentFieldLength(n:Number) : Void {
		// v6.5.1 Yiu new default gap length check box and slider 
		var qNo:Number;
		var ex = _global.NNW.control.data.currentExercise;
		var exType = ex.exerciseType;
		
		qNo = _global.NNW.screens.getCurrentQuestionNumber();
		
		if (ex.exerciseType	== "Stopgap")
		{
			_global.NNW.control.updateExercise("gapLength", qNo, n);
		}
		// End v6.5.1 Yiu new default gap length check box and slider 
		
		var fieldText = field.text.substring(startIndex, endIndex);
		fieldText = _global.rTrim(fieldText);	// v0.16.1, DL: debug - i've mixed up the names rTrim and lTrim, should be rTrim
		if (n>0) {
			for (var i=0; i<n; i++) {
				fieldText += " ";
			}
			field.replaceText(startIndex, endIndex, fieldText);
		}
		endIndex = startIndex + fieldText.length;
	}
	/* v0.5.2, DL: remove spaces from cleared gaps for gap fill exercises */
	private function leftTrimCurrentField() : Void {
		var fieldText = field.text.substring(startIndex, endIndex);
		fieldText = _global.rTrim(fieldText);	// v0.16.1, DL: debug - i've mixed up the names rTrim and lTrim, should be rTrim
		field.replaceText(startIndex, endIndex, fieldText);
		endIndex = startIndex + fieldText.length;
	}
	/* v0.11.0, DL: trim and remove CR from fields */
	private function trimField() : Void {
		var fieldText = field.text.substring(startIndex, endIndex);
		fieldText = _global.replace(fieldText, " \r", " ");	// remove CR
		fieldText = _global.replace(fieldText, "\r ", " ");
		fieldText = _global.replace(fieldText, "\r", " ");
		fieldText = _global.trim(fieldText);	// trim
		field.replaceText(startIndex, endIndex, fieldText);
		endIndex = startIndex + fieldText.length;
	}
	
	/* functions that calls to current exercise's field manager for editing fields */
	private function getCurrentExerciseType() : String {
		return _global.NNW.control.data.currentExercise.exerciseType;
	}
	private function retrieveURL(id:Number) : String {
		return _global.NNW.control.data.currentExercise.fieldManager.retrieveURL(id);
	}
	private function addField(t:String) : Number {
		if (t!=undefined && t.length>0) {
			var ex = _global.NNW.control.data.currentExercise;
			var exType = ex.exerciseType;
			// v0.5.2, DL: storyboard field settings - answer neutral
			if (exType=="Countdown") {
				var id = ex.fieldManager.addField(0, t, "neutral");
			} else if (exType=="TargetSpotting") {	// v0.16.0, DL: target spotting may be neutral
				if (_global.NNW.control.errorCheck.passFieldEmptyCheck(t)) {	// v0.16.1, DL: check field cannot be only spaces/CRs
					if (ex.settings.feedback.neutral) {
						var id = ex.fieldManager.addField(0, t, "neutral");
					} else {
						var id = ex.fieldManager.addField(0, t, "true");
					}
				} else {
					return -1;
				}
			}else if (	exType=="Cloze"			||
						exType=="DragOn"		||
						exType=="Dropdown"		||
						exType=="Proofreading"
						) {
				if (_global.NNW.control.errorCheck.passFieldLengthCheck(t.length)) {
					if (_global.NNW.control.errorCheck.passFieldEmptyCheck(t)) {	// v0.16.1, DL: check field cannot be only spaces/CRs
						var id = ex.fieldManager.addField(0, t, "true");
					} else {
						return -1;
					}
				} else {
					return -1;
				}
			// v6.5.1 Yiu 6-5-2008 New exercise type error correction
			} else if (	exType==_global.g_strErrorCorrection) {
				if (_global.NNW.control.errorCheck.passFieldLengthCheck(t.length)) {
					if (_global.NNW.control.errorCheck.passFieldEmptyCheck(t)) {
						var id = ex.fieldManager.addField(0, t, "false");
					} else {
						return -1;
					}
				} else {
					return -1;
				} 
			} /* else if (exType==_global.g_strQuestionSpotterID){
				if(_global.NNW.control.errorCheck.passSingleFieldCheck(field.htmlText)){
					if (_global.NNW.control.errorCheck.passFieldLengthCheck(t.length)) {
						if (_global.NNW.control.errorCheck.passFieldEmptyCheck(t)) {	// v0.16.1, DL: check field cannot be only spaces/CRs
							var id = ex.fieldManager.addField(0, t, "false");
						} else {
							return -1;
						}
					} else {
						return -1;
					}
				} else {
					return -1;
				}
			} // End v6.5.1 Yiu add bew exercise type error correction 
			*/
			else {
				// v0.16.1, DL: get qNo for split-screen exercises
				if (ex.settings.misc.splitScreen) {
					var  qNo = Number(_global.NNW.screens.txts.txtSplitScreenQuestionNo.text);
				} else {
					var qNo = Number(_global.NNW.screens.txts.txtQuestionNo.text);	// v0.12.0, DL: _global.NNW.screens.nsps.nspQuestionNo.value;
				}
				// v0.7.1, DL: debug - do single field check on that textfield only
				if (_global.NNW.control.errorCheck.passSingleFieldCheck(field.htmlText)) {	// v0.6.0, DL: error checking
					if (_global.NNW.control.errorCheck.passFieldLengthCheck(t.length)) {
						if (_global.NNW.control.errorCheck.passFieldEmptyCheck(t)) {	// v0.16.1, DL: check field cannot be only spaces/CRs
							var id = ex.fieldManager.addField(qNo, t, "true");  
						} else {
							return -1;
						}
					} else {
						return -1;
					}
				} else {
					return -1;
				}
			}
			return id;
		} else {
			return -1;
		}
	}
	private function addURL(t:String, u:String) : Number {
		return _global.NNW.control.data.currentExercise.fieldManager.addURL(t, u);
	}
	private function editURL(id:Number, u:String) : Void {
		_global.NNW.control.data.currentExercise.fieldManager.editURL(id, u);
	}
	private function delField(id:Number) : Void {
		_global.NNW.control.data.currentExercise.fieldManager.delFieldWithID(id);
	}
	private function delURL(id:Number) : Void {
		_global.NNW.control.data.currentExercise.fieldManager.delURL(id);
	}
	/* end of functions that calls to current exercise's field manager for editing fields */
	
	// v6.5.1 Yiu fixing question based drop
	public function checkIfThereIsADrop():Boolean{
		var ex 			= _global.NNW.control.data.currentExercise;
		var splitScreen = ex.settings.misc.splitScreen;
		var text		= splitScreen? _global.NNW.screens.txts.txtSplitScreenQuestion.label.htmlText : _global.NNW.screens.txts.txtQuestion.label.htmlText;
		
		return !_global.NNW.control.errorCheck.ifStringContainField(text);
	}
	// End v6.5.1 Yiu fixing question based drop
}
