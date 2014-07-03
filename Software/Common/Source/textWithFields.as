// I don't know where to put this function. It is used a lot in this component
// but if I put it here it will surely be duplicated many times if I use many
// copies of the component. But if I put outside, then the component cannot
// work unless it is copied as well. Hmmm.
// So, define it as a global and then it will just be redefined each time
// a new component is created and not take up extra space. Thanks Flashcoders.
if (_global.TWF == undefined) {
	_global.TWF = new Object();
}
// v6.3.5 These functions are in common for Orchid, but not easily accessible from
// there by twf functions. So they are duplicated here.
_global.TWF.lookupArrayItem = function(myArray, key, field) {
	var i = myArray.length;
	while(i--) {
		//myTrace("i=" + i + " value=" + myArray[i][field]); 
		if (myArray[i][field] == key) {
			//myTrace("found " + key + " at i=" + i + ", see=" + myArray[i][field]); 
			return i;
		}
	}
	return -1; // it wasn't found
}
_global.TWF.findReplace = function(myString, find, replace, occurence) {
//	trace("looking for " + find);
	if (!occurence) {
		return myString.split(find).join(replace);
	} else {
		n = myString.split(find);
		for (j in n) {
			if (j == occurence-1) {
				n[j] += replace;
			} else if (j!=n) {
				n[j] += find;
			}
		}
		return n.join("");
	}
}
_global.TWF.convertCurlyQuote = function(myString) {
	var build = myString;
	// list all types of odd quotes and apostrophes and the straight version they should be converted to.
	// Alt+0145, 146, 180, 96, 147, 148 turned into unicode mappings are...
	var replaceArray = [{f:8216, r:39}, {f:8217, r:39}, {f:180, r:39}, {f:96, r:39}, {f:8220, r:34}, {f:8221, r:34}];
	for (var i in replaceArray) {
		build = TWF.findReplace(build, String.fromCharCode(replaceArray[i].f), String.fromCharCode(replaceArray[i].r));
	}
	return build;
}

// v6.5.4.2 Yiu fixing 1223, adding variables for the control key clicking
_global.TWF.controlKeyTimeOutDuration = new Number(); 
_global.TWF.controlKeyTimeOutDuration = 1000;
_global.TWF.controlKeyTimeOutIntervalID	= 0;
// End v6.5.4.2 Yiu fixing 1223, adding variables for the control key

// the class constructor
function TextWithFieldsClass() {
	this._version = "6.5.0.0";
	this.init();
}
// parent type for the class
TextWithFieldsClass.prototype = new MovieClip();

// initialise the component
TextWithFieldsClass.prototype.init = function() {
//	myTrace("TWF init version " + this._version);
	// record original dimensions and then perform anti-distortion
	this.componentWidth = this._width;
	this.componentHeight = this._height;
	this._xscale = this._yscale = 100;
	this.boundingBox_mc._visible = false;
	// the default is to show the cursor change when over a field
	this.hideCursorChange = false;

	// pick up any formatting from the component parameters
	// currently this is forced on the component
	var myTF = new TextFormat();
	// v6.3.3 Try using fonts that will be always available
	if (myTF.font == undefined) myTF.font = "_sans";
	if (myTF.size == undefined) myTF.size = 12;

	// hold a depth in the component used for adding new MCs
	this.myDepth = 0;
	// the default for border is on, autoSize is true
	if (this.border_param == undefined) this.border_param = true;
	if (this.autoSize_param == undefined) this.autoSize_param = true;
	if (this.noProcessing_param == undefined) this.noProcessing_param = false;
	if (this.text_param == undefined) this.text_param = "";

	// v6.2 Try creating a simplified TWF setting that simply displays text (quickly)
	if (this.noProcessing_param == true) {
		//trace("this TWF has no processing");
	} else {
		// Create a canvas that will sit behind all other fields/MC that you can
		// put highlights on and use to collect general clicks
		var myCanvas = this.createEmptyMovieClip("TWFcanvas", this.myDepth++);
		
		// create a textField that is used for measuring width of chunks of text
		// using the textField method getTextDimensions
		this.createTextField("widthCalc",this.myDepth++,0,0,4,4);
		this.widthCalc.html = false;
		this.widthCalc.border = false;
		this.widthCalc.wordWrap = false; // this will keep it on one line for measuring widths
		this.widthCalc.autoSize = true;
		this.widthCalc._visible = false; // can you hide it without effecting its value?
	
		// Create a textField to display the text in the component.
		// It is also used for measuring height changes
		// as you add each character from the original to it one by one.
		// v6.2 Try creating the original field dynamically to see if that
		// helps with accuracy. No, no difference at all.
		//this.createTextField("original",this.myDepth++,0,0,10,10);
		//this.original.html = true;
		// I get strange text if I setSize before donig anything else. Why? The following init solves it.
		this.original.text = ""
		this.original.border = this.border_param;
		this.original.background = false;
		//this.original.wordWrap = true;
		this.original.multiline = true;
		//this.original.embedFonts = true;
		this.original.embedFonts = false;
		//this.original.selectable = false; // there is no copy of text at present
		this.original.autoSize = this.autoSize_param;
		// for debugging
		//this.original._y = 250;
	}
	this.createTextField("holder",this.myDepth++,0,0,10,10);
	if (this.noProcessing_param == true) {
		// use html as no indirect copying will take place
		this.holder.html = true;
	} else {
		this.holder.html = false;
	}
	// the default for border is on, autoSize is true (see init earlier)
	this.holder.border = this.border_param;
	this.holder.background = false;
	this.holder.wordWrap = true;
	this.holder.multiline = true;
	//this.holder.embedFonts = true;
	this.holder.embedFonts = false;
	// v6.4.3 To select text you can do it here, but it is very clumsy and hard to do
	this.holder.selectable = false; // there is no copy of text at present
	this.holder.autoSize = this.autoSize_param;
	
	// v6.2 No point doing this during init since no text is added
	//this.setSize(this.componentWidth, this.componentHeight);

	// display any default text from the components panel
	if (this.text_param != "") {
		this.setHtmlText(this.text_param, myTF);
	}
	// v6.2 Try creating a simplified TWF setting that simply displays text (quickly)
	if (this.noProcessing_param != true) {
		// set up the overlay layer to hold anything that needs to go OVER the covers
		if (_global.ORCHID.overlayDepth == undefined) {
			var myOverlayDepth = _global.ORCHID.coverDepth+1999;
		} else {
			var myOverlayDepth = _global.ORCHID.overlayDepth;
		}
		if (myOverlayDepth == 0) myOverlayDepth = this.myDepth++;
		this.createEmptyMovieClip("overlay_mc", myOverlayDepth);
		//trace("created " + this.overlay_mc + " at " + myOverlayDepth);
	}
	// v6.5 Mac problem
	if (System.capabilities.os.toLowerCase().indexOf("mac")==0) {
		this.textExtentCorrector = 20; // What is this value? web seems to suggest twips, but it is not truly accurate
	} else {
		this.textExtentCorrector = 1;
	}
	//trace("setting w,h=" + w + "," + this._height);
}
// A function for coping with width resizing and height change
TextWithFieldsClass.prototype.resetSize = function(w) {
	// record the initial height of the component
	var startHeight = this.getSize().height;
	// record (one time only) the original width of this component
	if (this.originalWidth == undefined) this.originalWidth = this.getSize().width;
	// don't let the component go wider than it was when you started ??
	if (w > this.originalWidth) w = this.originalWidth;
	// cause the component to change to the new width setting
	this.setSize(w, startHeight);
	// v6.2 Has this function caused the twf to change height? If so we should
	// trigger an event so that other things that come below this can move as 
	// well
	if (startHeight != this.getSize().height) {
		//trace("twf: height has changed by " + Number(this._height - startHeight));
		this.onHeightChange = eval(this.heightChangeCallback_param);
		this.onHeightChange(this.holder._height - startHeight);
	}
}
// Define functions that give general processing ability
TextWithFieldsClass.prototype.setSize = function(w, h) {
	//myTrace("twf.setSize of " + this + " to w=" + w + " h=" + h);
	var originalWidth = this.componentWidth;
	this.componentWidth = w;
	this.componentHeight = h;
	this.boundingBox_mc._width = w;
	this.boundingBox_mc._height = h;
	this.holder._width = w;
	// can I make the original the same width as the holder?
	// This is so that getBounds is accurate with the visible stuff.
	this.original._width = w; 
	// only set the height of the text box if autosize is false
	if (this.autosize_param) {
		if (this.holder._height < h) {
			this.holder._height = h;
		}
	} else {
		this.holder._height = h;
	}
	// set the background canvas to the same size as the text field
	// if it does not exist, well these calls will just be ignored
	if (this.TWFcanvas.canvasClick != undefined) {
		this.TWFcanvas.canvasClick._width = w;
		this.TWFcanvas.canvasClick._height = this.holder._height;
	}
	//trace("new canvas width=" + this.TWFcanvas.canvasClick._width);
	// v6.2 what about setting the size of original?
	//this.original._width = w;
	//this.original._height = h;
	this.original._xscale = this.original._yscale = 100;
	//trace("original xscale=" + this.original._xscale + " _width=" + this.original._width);	

	// v6.2 Try creating a simplified TWF setting that simply displays text (quickly)
	// v6.5 And also does nothing if empty?
	//if (this.noProcessing_param == true) {
	if (this.noProcessing_param == true || this.original.text=="") {
		//myTrace("no processing during (re)setSize");
	} else {
		//myTrace("refresh as text=" + this.original.text);
		// don't do any refreshes if the width has not changed
		if (originalWidth != w) {
		//	trace("in setSize - old("+originalWidth+")");
			this.refresh();
		}
	}
}
// let the component tell you how big it is (based on the holder)
TextWithFieldsClass.prototype.getSize = function() {
	return {width:this.holder._width, height:this.holder._height};
}
// getter/setter functions for class properties
TextWithFieldsClass.prototype.setHtmlText = function(myText, textFormat) {
	//myTrace("twf.sHT with " + myText + " tf.url=" + textFormat.url);
	//myTrace("twf.sHT");
	// put the text you have been asked to display into the design time text field
	// this will cause Flash to parse it and make it ready for us to process
	// Once our 'holder' contains the text we will delete/hide/clear original
	// as we don't want to use it (that is why we don't care about the size)
	
	// v6.2 Try creating a simplified TWF setting that simply displays text (quickly)
	if (this.noProcessing_param == true) {
		this.holder.setHtmlText(myText, textFormat);
		return;
	} else {
		// If you have not been passed a TF just use the text direct to html
		if (textFormat == undefined) {
			//myTrace("use pure htmlText");
			this.original.htmlText = myText;
		} else {
			// use the extended textField function to add text with a default TF
			//myTrace("before=" + myText);
			// Can I replace a string of consecutive spaces with alternate &nbsp; so that they will not get lost?
			// What about other forms of consecutive white space?
			myText = TWF.findReplace(myText, "  ", " &nbsp;");
			// A tab as the first character followed by a field gets lost. See if you can slip a &nbsp; in there as well.
			// I think I can only find it through it following a tag close. This will slip too many in!
			// v6.5 In Road to IELTS we have handmade so many exercises and some have tab followed by field (in a way that makes it work)
			// Is this a difference between <tab> and chr(9)? But no, this is the way that noScroll for d&d is always laid out.
			// Anyway, this screws it up by adding the space after the tab. What about adding the space before the tab? No.
			// So, until I can find an exercise where this is needed, remove it. Having tested in AP, it seems fine with tab as first followed by a field.
			// Which exercises (I guess in TB) caused me to make this edit in the first place?
			//myText = TWF.findReplace(myText, ">" + String.fromCharCode(9), ">" + String.fromCharCode(9) + "&nbsp;");
			//myText = TWF.findReplace(myText, ">" + String.fromCharCode(9), ">" + "&nbsp;" + String.fromCharCode(9));
			this.original.setHtmlText(myText, textFormat);
			//myTrace("after=" + this.original.htmlText);
		}
	}
	//trace("in sHT with " + this.original.htmlText);
	// clear out the holder from any current text
	this.holder.text = "";
	this.original._visible = false;
	//myTrace("this.original._visible=" + this.original._visible);

	// and start the process to copy text and find fields
	this.refresh();
	//myTrace("after refresh=" + this.original.htmlText);
	
	// the canvas needs to be the same height as the text, since we don't
	// call setSize, perhaps we can change this here?
	// If I use this._height I get what appears to be an extra line underneath
	if (this.TWFcanvas.canvasClick != undefined) {
		this.TWFcanvas.canvasClick._height = this.holder._height;
	}
}
TextWithFieldsClass.prototype.getHtmlText = function() {
//	trace("in getText");
	// this is why you need to keep the original text field as holder is NOT
	// an html field (despite appearances to the contrary)
	return this.original.htmlText;
}
// v6.5.4.2 Yiu
// Get the offset of field real pos because of CJK words, Bug ID 1370a
TextWithFieldsClass.prototype.getOffsetWithFieldStartOrEndPos	= function(fieldPos)
{
	var nOffset:Number;
	nOffset= this.aCJKRelatedShowingAnswerOffset[this.aCJKRelatedShowingAnswerOffset.length - 1];	// default return
	
	var v:Number;
	for (v=0; v<this.lines.length; ++v) {
		if(fieldPos < this.lines[v].idx)
		{
			nOffset	= this.aCJKRelatedShowingAnswerOffset[v-1];
			break;
		}
	}
	
	// debug trace
	//_global.myTrace("== getAccumOffsetwithfieldstartorendpos result: " + nOffset);
	//_global.myTrace("== getAccumOffsetwithfieldstartorendpos fieldPos: " + fieldPos);
	return nOffset;
}

TextWithFieldsClass.prototype.getAccumOffsetWithFieldStartOrEndPos	= function(fieldPos){
	var nOffset:Number;
	//myTrace("array length=" + this.aAccumCJKRelatedShowingAnswerOffset.length + " value is " + this.aAccumCJKRelatedShowingAnswerOffset[0]);
	nOffset= this.aAccumCJKRelatedShowingAnswerOffset[this.aAccumCJKRelatedShowingAnswerOffset.length - 1];	// default return
	//myTrace("in getAccumOffsetWithFieldStartOrEndPos nOffset=" + nOffset);
	
	var v:Number;
	for (v=0; v<this.lines.length; ++v) {
//	_global.myTrace("== getAccumOffsetwithfieldstartorendpos v: " + v);
//	_global.myTrace("== getAccumOffsetwithfieldstartorendpos this.lines[v].idx: " + this.lines[v].idx);
		if(fieldPos < this.lines[v].idx){
			nOffset	= this.aAccumCJKRelatedShowingAnswerOffset[v-1];
			break;
		}
	}
//	for (v=0; v<this.lines.length; ++v) {
//		_global.myTrace("aAccumCJKRelatedShowingAnswerOffset, v: " + v + " aAccumCJKRelatedShowingAnswerOffset: " +  this.aAccumCJKRelatedShowingAnswerOffset[v]);
//	}
	//_global.myTrace("getAccumOffsetWithFieldStartOrEndPos nOffset: " + nOffset + " fieldPos: " + fieldPos);
	// ar#869 to be safe
	if (isNaN(nOffset)) nOffset = 0;
	return nOffset;
}

// This function is called to set a TextFormat to a particular field
TextWithFieldsClass.prototype.setFieldTextFormat = function(fieldID, thisFormat) {
	var fieldIDX=TWF.lookupArrayItem(this.fields, fieldID, "id");
	//myTrace("twf.setFieldTextFormat with underline=" + thisFormat.underline + " for " + fieldIDX);
//	for (var i in this.fields[fieldID]) {
	//trace("field[" + fieldID + "].start="+this.fields[fieldIDX].start+" .end="+this.fields[fieldIDX].end);
	//var currentTF = this.holder.getTextFormat(this.fields[fieldIDX].start);
	//for (var i in currentTF) { myTrace("currentTF." + i + "=" + currentTF[i] + " thisFormat." + i + "=" + thisFormat[i])}
	//myTrace("twf.setFieldTF.a, url[10]=" + this.original.getTextFormat(10).url);
	// v6.5.4.2 Yiu, get the offset to make the field display correctly, Bug ID 1370a
	var nStartOffset:Number;
	var nEndOffset:Number;
	//myTrace("twf.setFieldTF, 1.end=" + this.fields[fieldIDX].end + " start=" + this.fields[fieldIDX].start);
	nStartOffset = this.getAccumOffsetWithFieldStartOrEndPos(this.fields[fieldIDX].start);
	nEndOffset = this.getAccumOffsetWithFieldStartOrEndPos(this.fields[fieldIDX].end);
	//myTrace("twf.setFieldTF, 2.endOffset=" + nEndOffset + " start=" + nStartOffset);
	//myTrace("twf.setFieldTF, url=" + thisFormat.url);

	this.holder.setTextFormat(this.fields[fieldIDX].start + nStartOffset,
					this.fields[fieldIDX].end + nEndOffset, 
					thisFormat);	// v6.5.4.2 Yiu, bug id 1370a 

	//this.holder.setTextFormat(this.fields[fieldIDX].start,this.fields[fieldIDX].end, thisFormat);	// v6.5.4.2 Yiu commented, bug id 1370a 
	// since we might refresh later, we need to update the new format in the original too
	this.original.setTextFormat(this.fields[fieldIDX].start, 
					this.fields[fieldIDX].end, 
					thisFormat);
	// v6.5.4.2 Yiu, tried to fix text with fields problem with the following code but always failed, commented
	//this.original.setTextFormat(	this.fields[fieldIDX].start + nStartOffset, 
	//				this.fields[fieldIDX].end + nEndOffset, 
	//				thisFormat);
	// end v6.5.4.2 Yiu, tried to fix text with fields problem with the following code but always failed, commented

	// v6.2 If there is a gap cover over this field, change it's format too
	for (var j in this.fields[fieldIDX].coords) {
		thisCover = this.fields[fieldIDX].coords[j].coverMC;
		//myTrace("twf.setFieldTextFormat for cover.gap " +thisCover + " gapHolder=" + thisCover.gapHolder);
		if (thisCover.gapHolder != undefined) {
			thisCover.gapHolder.gap.setTextFormat(thisFormat);
			// but we never want underlining on a cover gap, although you can't
			// change thisFormat as it will have other consequences
			if (thisFormat.underline || thisFormat.leading != null) {
				var myTF = new TextFormat();
				myTF.leading = null;
				myTF.underline = false;
				thisCover.gapHolder.gap.setTextFormat(myTF);
			}
		}
	}
//	}
}
// returns the TF of the FIRST character in this field
// Note: or should this return whatever is common to the whole field??
TextWithFieldsClass.prototype.getFieldTextFormat = function(fieldID) {
	var fieldIDX=TWF.lookupArrayItem(this.fields, fieldID, "id");
	//trace("gFTF: fieldID="+fieldID + " IDX=" + fieldIDX);
	// v6.5.4.2 Yiu, fixing drag and drop problem with CJK characters, bug ID 1370a
	var nStartOffset:Number;
	nStartOffset = this.getAccumOffsetWithFieldStartOrEndPos(this.fields[fieldIDX].start);

	//return this.holder.getTextFormat(this.fields[fieldIDX].start);	// v6.5.4.2 Yiu, yiu commented, Bug ID 1370a
	return this.holder.getTextFormat(this.fields[fieldIDX].start + nStartOffset);	// v6.5.4.2 Yiu, fixing drag and drop problem with CJK characters, bug ID 1370a
}
// v6.2 New function to hold text in the field cover when it doesn't
// need to actually go into the underlying text field
// OR is this a cover function not a TWF function?
//TextWithFieldsClass.prototype.setCoverText = function(fieldID, text) {
//	var fieldIDX=TWF.lookupArrayItem(this.fields, fieldID, "id");
//	for (var j in this.fields[fieldIDX].coords) {
//		thisCover = this.fields[fieldIDX].coords[j].coverMC;
//	}
//}

// This function is called to change the text contents of a particular field
TextWithFieldsClass.prototype.setFieldText = function(fieldID, text, partialRefresh) {
	//myTrace("twf.setFieldText for " + fieldID + " to "+ text);
	var startTime = new Date();

	// v6.2 what height is this twf at the moment? 
	// but is _height the right thing to use as a comparison?
	var startHeight = this.getSize().height; //holder._height;
	//trace("current height=" + startHeight);
	
	//myTrace("twf.setFieldText.a, url[10]=" + this.original.getTextFormat(10).url);
	var fieldIDX=TWF.lookupArrayItem(this.fields, fieldID, "id");
	//trace("sFT: fieldID="+fieldID + " IDX=" + fieldIDX);
	var thisTF = this.getFieldTextFormat(fieldID);
	var startSel = this.fields[fieldIDX].start;
	var endSel = this.fields[fieldIDX].end;
	var lengthChange = text.length - (endSel - startSel + 1);
	// holder will be refreshed so no need to do anything to it first
	//Selection.setFocus(this.holder);
	//Selection.setSelection(startSel, endSel);
	//this.holder.replaceSel(text);
	// //trace("sFT: start=" + startSel + " end=" + this.fields[fieldIDX].end + " partial=" + partialRefresh)
	// //trace("replace " + this.holder.text.substring(Selection.getBeginIndex(), Selection.getEndIndex()) + " with " + text);
	//Selection.setSelection(startSel + text.length, startSel + text.length);
	// apply the original formatting to the replaced text
	//this.holder.setTextFormat(startSel, startSel + text.length, thisTF);
	// since a refresh takes from the original we must update that
	//myTrace("twf.setFieldText, 1.original=" + this.original.text + " startSel=" + startSel + " endSel=" + this.fields[fieldIDX].end + " idx=" + fieldIDX);
	Selection.setFocus(this.original);
	Selection.setSelection(startSel, endSel);
	this.original.replaceSel(text);
	//myTrace("twf.setFieldText, 2.original=" + this.original.text + " startSel=" + startSel + " endSel=" + (Number(startSel) + Number(text.length)) + " idx=" + fieldIDX);
	this.original.setTextFormat(startSel, startSel + text.length, thisTF);
	//myTrace("twf.setFieldText.b, url[10]=" + this.original.getTextFormat(10).url);
	// update the field end
	this.fields[fieldIDX].end = startSel + text.length;
	//myTrace("field end moves from " + endSel + " to " + this.fields[fieldIDX].end);
	//myTrace("at this point field has " + this.fields[fieldIDX].coords + " covers");
	
	// v6.4.3 #errorCorrection problem# Use partialRefresh to show that this is a special case for setting the field text
	// Yes, then picked up in addFieldCover
	//if (partialRefresh == "saveCovers") {
		this.partialRefresh = partialRefresh;
	//}
	// v6.2 I don't see how a partial refresh could ever work - after all surely
	// we have potentially moved the line breaks so fields will be in different
	// cursor positions as well as text positions?
	// Force the full refresh for now.
	partialRefresh = false;
	
	//myTrace("twf.setFieldText, 2.original=" + this.original.text);
	// At this point we could do a FULL refresh, or we could cut some time by just 
	// pushing around the field locations that follow this position. 
	if (partialRefresh) {
		// just update the field text positions so that they are accuracte
		//myTrace("changing all fields after " + startSel + " by " + lengthChange);
		for (var i in this.fields) {
			if (this.fields[i].start > startSel) {
				this.fields[i].start += lengthChange;
				this.fields[i].end += lengthChange;
			}
		}
	} else {
		//trace("do a full refresh");
		//myTrace("before refresh from " + startSel);
		this.refresh(startSel);
		//myTrace("after refresh");
	}
	//myTrace("twf.setFieldText, 2.original=" + this.original.text);

	// v6.2 Has this function caused the twf to change height? If so we should
	// trigger an event so that other things that come below this can move as 
	// well.
	var newHeight = this.getSize().height;
	//myTrace("twf.setFieldText.new height=" + newHeight);
	if (startHeight != newHeight) {
		//myTrace("twf: height has changed by " + Number(newHeight - startHeight));
		this.onHeightChange = eval(this.heightChangeCallback_param);
		this.onHeightChange(Number(newHeight - startHeight));
	}
	var stopTime = new Date();
	//trace("setFieldText took " + (Number(stopTime.getTime()) - Number(startTime.getTime())));
	//myTrace("stop sfT");
}
// This function is called to retrieve the plain text contents of a particular field
// I think it is highly unlikely that I will call this as I know all about field
// contents in my main exercise structure, nevertheless, it should work!
TextWithFieldsClass.prototype.getFieldText = function(fieldID) {
	//trace("original:" + this.original.text.substr(0,100));
	//trace("holder:" + this.holder.text.substr(0,100));
	var fieldIDX=TWF.lookupArrayItem(this.fields, fieldID, "id");
	// Note: I cannot read from HOLDER as it has 'lost' all the CR if you do text.substr
	// but if I read from original, then it means I have to update original as well
	// when I change any text in holder.
	return this.original.text.substring(this.fields[fieldIDX].start,this.fields[fieldIDX].end);
}
// This function is called to hide the cursor for fields that are hidden.
TextWithFieldsClass.prototype.setHideCursor = function(flag) {
	if (flag == true) {
		this.hideCursorChange = true;
	} else {
		this.hideCursorChange = false;
	}
}
// This function is called to set event name callbacks
TextWithFieldsClass.prototype.setEvents = function(eventNames) {
	//myTrace("twf.setEvents");
	// passed as an object
	this.rollOverCallback_param = eventNames.rollOver;
	//trace("will use rollOver=" + eventNames.rollOver);
	this.rollOutCallback_param = eventNames.rollOut;
	this.mouseDownCallback_param = eventNames.mouseDown;
	this.mouseUpCallback_param = eventNames.mouseUp;
	this.dragCallback_param = eventNames.drag;
	this.dropCallback_param = eventNames.drop;
	// v6.2 new one for control clicking
	this.controlClick_param = eventNames.controlClick;
	
	// If I am not using the general MouseUp function, I should remove the canvasClick
	if (eventNames.generalMouseUp != undefined) {

		// Note: how to pick up "error" clicks in a target spotting exercise?
		// Indeed, how about a general click collector? Use the canvas as this
		// will be behind any active fields
		//myTrace("add a canvas clicker");
		var myCanvas = this.TWFcanvas.attachMovie("fieldCover", "canvasClick", 0);
		myCanvas.useHandCursor = false;
		// v6.2 for tabbing correction
		myCanvas._focusrect = false;
		myCanvas.onRelease = eval(eventNames.generalMouseUp);
		//myCanvas.onRelease = function() {trace("click on myCanvas")};
		myCanvas._width = this.holder._width;
		myCanvas._height = this.holder._height;
		// use an *undocumented* parameter to let you change the alpha on the FC
		// useful for debugging and maybe some other uses?
		if (this._$coverAlpha > 0 && typeof this._$coverAlpha == "number") {
			myCanvas._alpha = this._$coverAlpha;
		} else {
			myCanvas._alpha = 100; //IE10+Win8 fix gh#390
		}
		//trace(eventNames.generalMouseUp);
		//trace("test generalMouseUp = " + myCanvas.onRelease());
	} else {
		//v6.3.5 Why have I commented this out?
		//this.TWFcanvas.canvasClick.removeMovieClip();
	}
	// v6.2 add the extra event for heightChange
	//trace("height change event=" + eventNames.heightChange);
	this.heightChangeCallback_param = eventNames.heightChange;	
}
// This function is called to refresh the display 
TextWithFieldsClass.prototype.refresh = function(fromChar) {
	//myTrace("twf.refresh");
	// for speed testing
	var startTime = new Date().getTime();

	// #errorCorrection problem#
	// If I am refreshing the twf, but there is text in the covers, I should save it and then put it back in later.
	// Will this impact after marking stuff?
	
	// get rid of what is already there (it might not be overwritten)
	//myTrace("twf.refresh, 1.original=" + this.original.htmlText);
	this.removeFieldCovers(fromChar);
	//myTrace("twf.refresh, 2.original=" + this.original.htmlText);

	// find the text locations of the fields
	this.buildTextAndFields();
	//myTrace("twf.refresh, 3.original=" + this.original.htmlText);
	
	// if some fields were found
	if (this.fields.length > 0) {
		// find the screen locations of the fields
		this.measureFields(fromChar);
		
		// add field covers to these locations
		this.addFieldCovers(fromChar);
	}

	// for speed testing
	var stopTime = new Date().getTime();
	//trace("refresh for " + this._name + " took " + (Number(stopTime) - Number(startTime)));
}
// This function is called to find field information from the twf component
TextWithFieldsClass.prototype.getFieldObject = function(fieldID) {
	var fieldIDX=TWF.lookupArrayItem(this.fields, fieldID, "id");
	return this.fields[fieldIDX];
}
// This function is called to take out any url fields so that the text will not be
// 'active' anymore. Any lines and fields variables are assumed to be upto date so
// that you can still do things based on them.
// Note: it doesn't work as setting TF.url="" will not be implemented when you do
// the setTextFormat, it requires a value, which then causes all sorts of problems!
//TextWithFieldsClass.prototype.removeFieldsFromHTML = function() {
//	var noURL = new TextFormat();
//	noURL.url = "";
//	this.original.setTextFormat(noURL);
//}
// Try to sort out line breaking before I need it!
// This doesn't really cut the mustard. It seems to work, but then if you scroll
// the pane, the word-wrapping goes back to what it was.
/*
TextWithFieldsClass.prototype.shuffleLineBreaks = function() {
	// replace the first character with itself to see if that helps
	var firstTF = new TextFormat();
	firstTF = this.holder.getTextFormat(0);
	firstChar = this.holder.text.substr(0,1);
	Selection.setFocus(this.holder);
	Selection.setSelection(0,1);
	this.holder.replaceSel("*");
	Selection.setSelection(0,1);
	this.holder.replaceSel(firstChar);
	this.holder.setTextFormat(0,firstTF);
}
*/

// THESE ARE PRIVATE functions and should not be called directly
//
// Clear out the canvas (behind) and overlay (on top) of any attached MCs
TextWithFieldsClass.prototype.clearCanvas = function() {
	//myTrace("clear canvas");
	for (var i in this.TWFcanvas) {
		if (typeof this.TWFcanvas[i] == "movieclip") {
			delete this.TWFcanvas[i];
		}
	}
}
TextWithFieldsClass.prototype.clearOverlay = function() {
	for (var i in this.overlay_mc) {
		if (typeof this.overlay_mc[i] == "movieclip") {
			delete this.overlay_mc[i];
		}
	}
}

// v6.5.4.2 Yiu Fixing 1371, series of functions for identify CJK character to make line breaks
// v6.5.4.3 AR - this function is not called anywhere
/*
TextWithFieldsClass.prototype.ifTheWordBeforeIsEnglish	= function(strTargetString, nCurPosition)
{
	var nCharCode:Number = 0;
	var v1:Number;
	v1 = nCurPosition -1;
	for (v1= nCurPosition -1; v1 > 0; --v1)	// Different name for forloop index, same name will make a infinity loop because other forloop has the same index name will change the others
	{
		nCharCode	= strTargetString.charCodeAt(v1);
		if ((nCharCode >= 65 && nCharCode <= 90) || (nCharCode >= 97 && nCharCode <= 122))
			return true;
	}
}
*/
TextWithFieldsClass.prototype.ifTheStringAllInCJK	= function(strTargetString)
{
	var nCharCode:Number				= 0;
	var strTargetStringCopy2:String;
	var v2:Number;
	v2 = 0;
	
	strTargetStringCopy2	= strTargetString.toString(); 	// Copy the string... to force it into a String Object
	for (v2= 0; v2 < strTargetStringCopy2.length; ++v2)	// Different name for forloop index, same name will make a infinity loop because other forloop has the same index name will change the others
	{
		nCharCode	= strTargetStringCopy2.charCodeAt(v2);
		// v6.5.4.3 AR what is the reference for these numbers?
		if 
		(
			(nCharCode >= 0x3400	&&	nCharCode <= 0x4DB5)	||
			(nCharCode >= 0x4E00	&&	nCharCode <= 0x9FA5)	||
			(nCharCode >= 0x9FA6 	&& 	nCharCode <= 0x9FBB)	||
			(nCharCode >= 0xF900 	&&	nCharCode <= 0xFA2D)	||
			(nCharCode >= 0xFA30	&&	nCharCode <= 0xFA6A)	||
			(nCharCode >= 0xFA70 	&& 	nCharCode <= 0xFAD9)	||
			(nCharCode >= 0xFF00	&&	nCharCode <= 0xFFEF)	||
			(nCharCode >= 0x2E80	&&	nCharCode <= 0x2EFF)	||
			(nCharCode >= 0x3000	&&	nCharCode <= 0x303F)	||
			(nCharCode >= 0x31C0	&&	nCharCode <= 0x31EF)	||
			(nCharCode >= 0x2F00	&&	nCharCode <= 0x2FDF)	||
			(nCharCode >= 0x2FF0	&&	nCharCode <= 0x2FFF)	||
			(nCharCode >= 0x3100	&&	nCharCode <= 0x312F)	||
			(nCharCode >= 0x31A0	&&	nCharCode <= 0x31BF)	||
			(nCharCode >= 0x3040	&&	nCharCode <= 0x309F)	||
			(nCharCode >= 0x30A0	&&	nCharCode <= 0x30FF)	||
			(nCharCode >= 0x31F0	&&	nCharCode <= 0x31FF)	||
			(nCharCode >= 0xAC00	&&	nCharCode <= 0xD7AF)	||
			(nCharCode >= 0x1100	&&	nCharCode <= 0x11FF)	||
			(nCharCode >= 0x3130	&&	nCharCode <= 0x318F)
		){
		} else {
			return false;
		}
	}
	return true;
}

TextWithFieldsClass.prototype.ifTheStringIsASCII_Numbers	= function(strTargetString)
{
	var nCharCode:Number;
	var strTargetChar:String;
	var strTarget:String;
	
	strTarget	= strTargetString.toString();	// Copy the string... to force it into a String Object
	nCharCode	= 0;
	
	var v3:Number;
	for (v3= 0; v3 < strTarget.length; ++v3)	// Different name for forloop index, same name will make a infinity loop because other forloop has the same index name will change the others
	{
		nCharCode		= strTarget.charCodeAt(v3);
		strTargetChar	= strTarget.charAt(v3);
		
		if(nCharCode >= 48	&&	nCharCode <= 57){	// 0 ~ 9
		} else {
			return false;
		}
	}
	return true;
}

TextWithFieldsClass.prototype.ifTheStringIsASCII_Punctuation	= function(strTargetString)
{
	var nCharCode:Number;
	var strTargetChar:String;
	var strTarget:String;
	
	strTarget	= strTargetString.toString();	// Copy the string... to force it into a String Object
	nCharCode	= 0;
	
	var v4:Number;
	for (v4= 0; v4 < strTarget.length; ++v4)	// Different name for forloop index, same name will make a infinity loop because other forloop has the same index name will change the others
	{
		nCharCode		= strTarget.charCodeAt(v4);
		strTargetChar	= strTarget.charAt(v4);
		
		if 	// the numbers are reference from this site: http://www.asciitable.com/
		(
			(nCharCode >= 0		&&	nCharCode <= 47)	||	
			(nCharCode >= 58	&&	nCharCode <= 64)	||
			(nCharCode >= 91 	&& 	nCharCode <= 96)	||
			(nCharCode >= 123 	&&	nCharCode <= 127)	||
			(nCharCode == 160)
		){
		} else {
			return false;
		}
	}
	return true;
}

TextWithFieldsClass.prototype.ifNextCharacterIsInCKJ	= function(strTargetString, nCurPos)
{
	var strTargetStringCopy:String;
	var strTargetChar:String;
	var v5:Number;
	
	strTargetStringCopy	= strTargetString.toString();	// Copy the string... to force it into a String Object
	
	var nStringLength:Number;
	nStringLength = strTargetStringCopy.length;

	for (v5	= nCurPos + 1; v5 < nStringLength; ++v5)	// Different name for forloop index, same name will make a infinity loop because other forloop has the same index name will change the others
	{
		strTargetChar	= strTargetStringCopy.charAt(v5);
		if (this.ifTheStringIsASCII_Punctuation(strTargetChar))	// Ignore punctuation
		{
			continue;
		}
		
		if (this.ifTheStringIsASCII_Numbers(strTargetChar))	// Ignore number
		{
			continue;
		}
		
		if (this.ifTheStringAllInCJK(strTargetChar))
		{
			return true;
		} else {
			return false;
		}
	}
	
	return false;	// unknown, it never goes here but if the parameter string is null
}
// End v6.5.4.2 Yiu Fixing 1371, series of functions for identify CJK character to make line breaks

// v6.5.4.2 Yiu, check if it is in fields range, Bug ID 1370a
TextWithFieldsClass.prototype.checkIfInFieldsRange= function(nPos) {
//_global.myTrace("textWithFields ==== , in checkIfInFieldsRange ==================================== nPos: " + nPos);
	var nStartPos:Number;
	var nEndPos:Number;

	for(var v=0; v<this.fields.length; ++v){
		nStartPos	= this.fields[v].start;	
		nEndPos		= this.fields[v].end;	
		if(nStartPos <= nPos && nEndPos > nPos)
			return v;
	}	
	
	return -1;
}
// End v6.5.4.2 Yiu, check if it is in fields range

// v6.5.4.2 Yiu, fixing the field cover problem with the last character on end of each line
TextWithFieldsClass.prototype.findCoverOffsetInField= function(nFieldNumber)
{
	var nResult:Number;
	nResult= 0;	

	for(var v:Number=0; v<this.aCoverOffset.length; ++v){
		if(this.aCoverOffset[v] == nFieldNumber)
			nResult++;
	}
	//_global.myTrace("findCoverOffsetInField result: " + nResult);
	return nResult;
}

// This is the key function that finds the fields in the text and then works out
// their coordinates. It first finds the line breaks and line heights, then measures
// widths of bits of text to get the x and w coordinates.
TextWithFieldsClass.prototype.buildTextAndFields = function() {
	//myTrace("twf.buildTextAndFields");
	//	var startTime = new Date();
	// First of all, check to see if there are any fields in this text.
	// If not, then you can simply display it with no fancy processing
	var thisTF = new TextFormat();
	thisTF = this.original.getTextFormat();
	//myTrace("bTAF.1 with " + this.original.text);
	//myTrace("bTAF.2 with " + this.original.htmlText);

	// If this is not commented out, then any text after the first field
	// clearly has a .url set as I get the fat finger moving over it.
	// BUT WHY?!
	
	// Ahhh, some people might want to use the component just to get line
	// breaks and not care about fields at all! So perhaps we shouldn't be
	// doing this short cut.
	// v6.2 Yes, in fact we want a lines array for each twf as ctrl-click
	// uses it even without any fields. So try commenting the whole block.
	/*
	// if the url changes at all through the text it's value will be null now
	// if it is not used, the value will be empty
	if (thisTF.url != null && thisTF.url == "") {
		this.holder.html = true;
		this.holder.htmlText = this.original.htmlText;
		this.fields = [];
		this.lines = [];
		return;
	} else {
		this.holder.html = false;
	}
	*/

	// initialise variables and set up starting values
	// these are the characters that you can word wrap at, we will search for them later
	// v6.3.4 Do you also need to break at underscores (95) for long gaps?
	// No, they are not in the gap, but &nbsp; comes as character code 160!
	// So that means that you want to break at 160, but the native textField doesn't want
	// to so as you are adding characters it will try hard to group all the &nbsp together and 
	// ruin the counting as things get out of sync. Can I add in a simple little real space
	// if I find a nbsp triggered line break? Yes, it appears so. (search 'wafer')
	// v6.3.5 This is not really successful, you keep getting the spaces added every other char,
	// sometimes.
	// Note: is 160 right or should it be a unicode equivalent??
	// v6.3.5 Current problems with splitGaps. It can do word breaks in strange places in a normal
	// line. It doesn't really measure the gap length properly to take into account the word wrap
	// at the end of the line losing you space. Three lines are displayed with a vertical gap
	// in the middle. It can line break a word with one char on the first line and the rest on 
	// the second (even though all would fit on the first). It can think that the gap is on two lines 
	// when in fact it is just on one. Last two problems are probably both due to the gap starting/
	// finishing next to the word wrapping line break.
	if (this.splitGaps) {
		var lineBreakChars = String.fromCharCode(32,9,45,160);
	} else {
		var lineBreakChars = String.fromCharCode(32,9,45);
	}
	var lastLineBreakChar = -1;
	// it is very much quicker to do substr type functions on a string copy of the text
	// rather than accessing it directly
	//trace(this.original.htmlText);
	var myString = new String(this.original.text);
	this.maxLength = myString.length;
	// lines is an array that holds the string index of where the lines break in the
	// current word wrapping scheme
	this.lines = new Array();
	// fields is an array that holds objects giving the details of each field that is found
	//myTrace("twf.buildTextAndFields, 1.endSel=" + this.fields[0].end + " url[10]=" + this.original.getTextFormat(10).url + " text=" + this.original.text );
	this.fields = new Array();
	// other variables used in looping and building
	var linesIdx = 0;
	var fieldLocation = new Object();
	var fieldDimension = new Object();
	var lastURL = "";
	var oldTextHeight = 0;

	this.holder.text = "";

	// v6.5.4.2 Yiu, for counting the offset
	delete this.aCJKRelatedShowingAnswerOffset;	
	delete this.aAccumCJKRelatedShowingAnswerOffset;
	this.aCJKRelatedShowingAnswerOffset	= new Array();	// reset the offset, it will counted and the end of this function
	this.aAccumCJKRelatedShowingAnswerOffset= new Array();

	// v6.5.4.2 Yiu, to note the cover should modify
	delete this.aCoverOffset;
	this.aCoverOffset
//	this.holder.border	= true;	// v6.5.4.2 Yiu, debug, uncomment this to show the textWithFieldBorder 

	//myTrace("set holder to empty, height=" + this.holder._height);
	// this variable holds consecutive newlines, you will probably only ever get two
	// but this seems extensible
	var foundNewLine = new Array();
	
	// loop adding each character in turn to the new textField. You can measure the height
	// change and compare it against the height of the added character. If the textField 
	// increases in height by more than this character height it means that word wrapping has just 
	// happened. So go back to the character that it happened at the record the place.
	// You can also record the line heights to get the y coordinate of each line.
	for (var i=0;i<this.maxLength; i++) {
		// what is the next character to add?
		thisChar = myString.charAt(i);
		//if (thisChar.charCodeAt(0) == 13) {
		//	myTrace("bTAF: [" + i +"] adding=ENTER");
		//} else if (thisChar.charCodeAt(0) == 9) {
		//	myTrace("[" + i +"] adding=TAB");
		//} else {
			//myTrace("[" + i +"] adding=" + thisChar + " (" + thisChar.charCodeAt(0) + ")");
		//}
		// and what is its format?
		thisTF = this.original.getTextFormat(i);
		this.holder.setNewTextFormat(thisTF);
		//myTrace("[" + i +"] adding=" + thisChar + " (" + thisChar.charCodeAt(0) + ")" + " .url=" + thisTF.url);
	
		// v6.5.4.2 Yiu, also treat the CJK Char as a break character like other lineBreaksChars, Bug ID 1370a
		var bIsLineBreakChar:Boolean;
		var bIfCJKChar:Boolean;

		bIsLineBreakChar = lineBreakChars.indexOf(thisChar) >= 0;
		bIfCJKChar = this.ifTheStringAllInCJK(thisChar);

		// should we record its index as the most recent word-wrapping character?
		if (bIsLineBreakChar == true || bIfCJKChar == true) {// yiu modified	
			lastLineBreakChar = i;
		}
		// Should we record it as a newline character?
		// And if we do, there is no point measuring its height and width, just leave
		// it to be picked up from the last char
		if (thisChar.charCodeAt(0) == 13) {
			//trace("added a newline");
			foundNewLine.push(true);
		} else {
			// we are now going to compare this character's height to others in the line
			// and look at how the textField changes in height when you add it
			// Note: in 6.0.r79 getTextExtent is considered to be unreliable wrt width
			// as it consistently reports it to be smaller than it really is.
			// And on Mac we have widly different values reported
			thisCharDimension = thisTF.getTextExtent(thisChar);
			thisCharHeight = Math.round(thisCharDimension.height / this.textExtentCorrector);
			thisCharWidth = Math.round(thisCharDimension.width / this.textExtentCorrector);
			//myTrace("bTAF: char " + thisChar + "("+thisChar.charCodeAt(0)+"), height=" + thisCharHeight + ", width=" + thisCharWidth);
		}
		
		// we want to find out about the character we are about to add so
		// add the character to the holding textField (a time consuming process)
		// but this is the only way to do it without losing earlier formatting
		// Note: according to ASDG2 (page 860) if the textField does NOT have the focus
		// the characters from replaceSel should be added before the first character, but
		// as far as I can see they are added at the end.
		//Selection.setSelection(i);
		this.holder.replaceSel(thisChar);
		thisTextHeight = this.holder.textHeight;
		
		// Note: I really don't understand, but sometimes when you add a tab
		// character it can throw you to the next line, even though the next
		// character might bring you back up again. So if this happens, try
		// to just get rid of the last line that you thought you had found.
		if (thisTextHeight < oldTextHeight) {
			//trace("something is causing TWF to fluctuate in height");
			oldTextHeight = thisTextHeight;
			// what else have you done - for instance in moving a field that was
			// split by this false line break?
			this.lines.pop();
		}

		// does the textField height change?
		if ((thisTextHeight - oldTextHeight) > 0 ) {
			//myTrace(thisChar + ": line +" + (thisTextHeight - oldTextHeight) + " char+" + thisCharHeight + " oldTextHeight=" + oldTextHeight + " textHeight=" + thisTextHeight);
			// yes, and does it change by more than the height of this character?
			if ((thisTextHeight - oldTextHeight) >= thisCharHeight) {
				// that means we word wrapped to a new line
				// OR that we were forced by the character AFTER a newline character
				// v6.5.4.2 Yiu, threat the CJK character like linebreak character first, we will take care of it at the end of this function, Bug ID 1370a
				if (foundNewLine.length>0 ||  bIfCJKChar == true) {
					linesIdx = this.lines.push({idx:i, y:thisTextHeight});
					foundNewLine.pop();
				} else {
					//myTrace("new line after llBC=" + lastLineBreakChar);
					// the first character is a special case, so if it is a llbc, then ignore it
					//if (i==0) lastLineBreakChar = -1;
					// v6.4.2.4 RC To help with Chinese texts where there are no spaces to break lines on.
					if (i==0) {
						lastLineBreakChar = -1;
					} else if (lastLineBreakChar <=0) {
						//this happens when we loop for the whole line and can't find a line break character
						//lastLineBreakChar = i;	// v6.5.4.2 Yiu Commented to solve the problem 1370
					} else if (oldlastLineBreakChar == lastLineBreakChar) {
						//this is added for line breaks for the 2nd+ lines that can't find the line break character
						//if this is not set, the lastLineBreakChar will be the same as the previous line break position
						//lastLineBreakChar = i; 	// v6.5.4.2 Yiu Commented to solve the problem 1370
					}
					oldlastLineBreakChar = lastLineBreakChar; 
					// so save the last recorded word-wrapping char as the place that it broke
					linesIdx = this.lines.push({idx:lastLineBreakChar+1, y:thisTextHeight});
					//myTrace("so push line at " + Number(lastLineBreakChar+1));
					// Slip in a wafer thin space? Or rather, change the last &nbsp; to a real space
					// v6.3.5 This simply does not work to break the line as you would expect.
					// ORG-096-E2 in AGU shows this. You get a dotted line effect as lots of
					// wafers are being added every other character after you go close to where
					// the underline starts on the line above. By changing the width of the 
					// paragraph a bit you can get rid of this effect.
					// v6.3.6 Bug causes hypenated words to lose their hyphen when split there.
					// Why? At this point holder still contains the hyphen. Try adding this
					// same wafer after the hyphen? No cannot.
					//myTrace("around line-break=" + this.holder.text.substr(i-5, 10));
					if (this.splitGaps && thisChar.charCodeAt(0) == 160) {
						Selection.setFocus(this.holder);
						Selection.setSelection(i,i+1);
						this.holder.replaceSel(" ");
					}
				}

				// and update the final text height of the previous line
				if (linesIdx>1) { // the first line is a special case
					//trace("update line " + Number(linesIdx-2) + " to height=" + oldTextHeight);
					// gh#869 usded to be this.lines[linesIdx-2].y, but if it is "2", linesIdx=2 will mean the first line but not the second line
					this.lines[linesIdx-1].y = oldTextHeight;
				}
				//trace(thisChar + " makes " + lines.length + " lines");
				// if this line break was in the middle of a field, you will have to adjust
				// the line starting index and x coordinate
				//Note: AR - changed the next condition from == to >= without testing
				//*if (fieldLocation.start >= lastLineBreakChar+1) {
				//*	//trace("start=" + fieldLocation.start + " llbc=" + Number(lastLineBreakChar+1));
				//*	fieldLocation.startLine++;
				//*}
			}
			// save the new height of the textField
			oldTextHeight = thisTextHeight;
		}
		//myTrace("after " + thisChar + " line width=" + lineWidthSoFar);
	
		//myTrace("twf.buildTextAndFields, 1.endSel=" + fieldLocation.end);
		// we are interested when the url property changes to find our fields
		//myTrace("at i=" + i + " lastURL=" + lastURL + " newURL=" + thisTF.url);
		if (thisTF.url != lastURL) {
			// it has changed and is now not empty
			if (thisTF.url != "") {
				//myTrace("it has changed and is now not empty");
				// first check to see if it was previously not empty
				// which would mean a move direct from one to another
				// so we need to close the last one first
				if (lastURL != "") {	
					//trace("514 end a field at " + i);
					fieldLocation.end = i;
					//*fieldLocation.endLine = this.lines.length-1;
					this.fields.push(fieldLocation);
				}
				// so that means a field has started
				fieldLocation = {start:i, coords:[]};
				//trace("521 start a field at " + i);
				// build the ID of the field if passed, or hold the URL
				// example url = asfunction:onClick,13|i:drag
				if (thisTF.url.indexOf("asfunction") == 0) {
					var thisParams = thisTF.url.split(",");
					var thisArgs = thisParams[1].split("|");
					fieldLocation.id = Number(thisArgs[0]);
					fieldLocation.type = thisArgs[1];
					//myTrace("found field with id=" + fieldLocation.id + " type=" + fieldLocation.type);
				} else {
					// example url = www.clarity.com.hk
					fieldLocation.url = thisTF.url;
					fieldLocation.type = "http";
					// since normal href doesn't have a field ID, use the idx
					fieldLocation.id = this.fields.length-1;
					//trace("found field with url=" + fieldLocation.url);
				}
				//trace("get line width from " + Number(lines[lines.length-1]) + " to " + Number(i));
				//*fieldLocation.startLine = this.lines.length-1;
				//trace("starting field " + thisTF.url + " on line " + fieldLocation.startLine + " at char=" + fieldLocation.start);
				lastURL = thisTF.url;
				//trace("field starts at " + thisChar + " x=" + Number(lineWidthSoFar-thisCharWidth));
			} else {
				// it has changed and is now empty, so a field has ended
				//myTrace("it has changed and is now empty");
				fieldLocation.end = i;
				//trace("546 end a field at " + i);
				//*fieldLocation.endLine = this.lines.length-1;
				this.fields.push(fieldLocation);
				fieldLocation = undefined;
				lastURL = thisTF.url;
			}
		}
	}
	//myTrace("twf.buildTextAndFields, 4.text=" + this.original.htmlText);
	// if the last character had a field, then you need to close up
	if (thisTF.url != "") {
		fieldLocation.end = this.maxLength;
		//trace("557 end a field at " + maxLength);
		//*fieldLocation.endLine = this.lines.length-1;
		this.fields.push(fieldLocation);
		//trace("close field, fieldLocation.startLine=" + fieldLocation.startLine + ", fieldLocation.endLine=" + fieldLocation.endLine);
		//trace("raw=" + this.original.htmlText);
	}
	
	//myTrace("twf.buildTextAndFields, 5.original=" + this.original.text + " endSel=" + this.fields[0].end);
	// you need to save this for use in measureFields
	this.lastTF = thisTF;
	//for (var i in this.lines) {
	//	myTrace("line " + i + " starts at char " + this.lines[i].idx + " at y=" + this.lines[i].y);
	//}
	// For debugging
	//this.showLineBreaks();
	// v6.2 change all the natural line breaks into forced ones
	//trace("before forcing line breaks, height=" + this.holder._height);
	// v6.3.6 Hyphens at the ends of lines are removed here, so you need
	// to test for them before you remove the character and replace it.
	// If you simply add in a newline, will that alter character counts and things?
	// Yes it will, so do it somewhere else. How about add in a newline as soon as you find 
	// a hyphen that ends a line? No. The problem is that spaces and other things that end 
	// a line can all be replaced by newline. But hyphen can't be replaced by a newline as
	// is bound to cause other problems. So how about NOT forcing a line-break there?
	// This seems to work. Except for a few recalcitrant hyphens. showLineBreaks later
	// indicates that all is well, but it actually isn't. The problem is deep in Flash textField.
	// It simply displays hyphens at the beginning of lines if it feels like it.
	// See /Flash/Playing/hyphenBug.fla for {failed) attempts at solving it.

	//myTrace("twf.buildTextAndFields, original=" + this.original.text);
	// v6.5.4.2 Yiu, accumlated variable for aCJKRelatedShowingAnswerOffset	
	var nCJKOffset:Number;
	var nInFieldsRange:Number;

	// v6.5.4.2 Yiu, mark down the position of the replaced word when CJK word is detected, 
	// then get rip the underline textformat of that word after all,
	// or it will cause some textformat problem

	selection.setFocus(this.holder);

	var plainText = new String(this.holder.text);
	for (var i in this.lines) {
		nCJKOffset = 0;	// v6.5.4.2 Yiu, it must be 1 or 0 for each loop
		if (this.lines[i].idx > 0) {
			if (plainText.substr(this.lines[i].idx-1,1) == "-") {
				//var selStart = this.lines[i].idx;
			} else {
				var selStart = this.lines[i].idx-1;
				selection.setSelection(selStart,this.lines[i].idx);
			//	this.holder.replaceSel(newline);
				var strMyString	= myString.charAt(selStart);
				// v6.5.4.2 Yiu, if it is a CJK character, the selected charcter shouldnt be only overwritten by newline, bug id 1370a 
				if(this.ifTheStringAllInCJK(strMyString)){	
					// v6.5.4.2 Yiu, back up the text format first
					thisTF = this.holder.getTextFormat(this.lines[i].idx-1);

					// v6.5.4.2 Yiu, replace with the word and newline, or it will overwrite the last CJK of each line 
					this.holder.replaceSel(strMyString + newline);

					// v6.5.4.2 Yiu, increase the offset 
					nCJKOffset = 1;
					nInFieldsRange = this.checkIfInFieldsrange(this.lines[i].idx-1);

					if(nInFieldsRange == -1){
						// v6.5.4.2 Yiu, apply the backuped format if the break text is not within a field
						this.holder.setTextFormat(this.lines[i].idx-1, this.lines[i].idx, thisTF);
					} else {
						// v6.5.4.2 Yiu, get the text format of the field from the other word in same field, to make it present properly
						var nGetTextFormatPos:Number;
						var bItIsTheStartChar:Boolean;
						var bItIsTheEndChar:Boolean;

						bItIsTheStartChar	= this.lines[i].idx-1 == this.fields[nInFieldsRange].start;
						bItIsTheEndChar		= this.lines[i].idx-1 == this.fields[nInFieldsRange].end;

						nGetTextFormatPos	= bItIsTheStartChar? this.fields[ninfieldsrange].start : this.fields[ninfieldsrange].end;
						thisTF			= this.holder.getTextFormat(nGetTextFormatPos);
						this.holder.setTextFormat(this.lines[i].idx-1, this.lines[i].idx, thisTF);
						this.aCoverOffset.push(nInFieldsRange);	
					}
//	debug trace
//_global.myTrace("Debug watch field range: " + this.checkifinfieldsrange(this.lines[i].idx-1));
//_global.myTrace("Debug watch text: " + strMyString);
//_global.myTrace("Debug watch text format: " + thisTF.url);
				} else {
					this.holder.replaceSel(newline);
				}
			}
		}

		// v6.5.4.2 Yiu, offset for gap fill exercise to display the answer correctly
		this.aCJKRelatedShowingAnswerOffset[i] = nCJKOffset;
		//myTrace("twf.buildTextAndFields aCJKOffset[" + i + "]=" + nCJKOffset);
	}
	//myTrace("twf.buildTextAndFields, 5.text=" + this.holder.htmlText);
	//myTrace("twf.buildTextAndFields, 4.original=" + this.original.text);

	// v6.5.4.2 Yiu, add the offset up, to accumlate the offset 
	for (var v1=0; v1<this.aCJKRelatedShowingAnswerOffset.length; ++v1) {
		this.aAccumCJKRelatedShowingAnswerOffset[v1] = 0; //ar#869
		for (var v2=v1; v2>=0; --v2){
			this.aAccumCJKRelatedShowingAnswerOffset[v1] += this.aCJKRelatedShowingAnswerOffset[v2];
			//myTrace("twf.buildTextAndFields aAccumCJKRelatedOffset[" + v1 + "]=" + this.aCJKRelatedShowingAnswerOffset[v2]);
		}
	}
	// End v6.5.4.2 Yiu, add the offset up, to accumlate the offset 

	//this.showLineBreaks();
//	trace("after forcing line breaks, height=" + this.holder._height);
	// Not a good idea to leave the focus on the holder, so set it back to original
	//Selection.setFocus(this.original); // gh#869
	
	// v6.5.4.2 Yiu, added this
	// v6.5.4.4 AR. Why? This now causes a drag at the start of a line to copy the TF.url to the whole paragraph. 
	// But what was the purpose of doing it? If I just take it out what will happen? 
	// It has been added in with the CJK stuff above. It can't possibly have worked since it is only looking at common TF.
	//myTrace("twf.buildTextAndFields, 6.text=" + this.original.htmlText);
	//this.original.setTextFormat(this.holder.getTextFormat());
	//myTrace("twf.buildTextAndFields, 7.text=" + this.original.htmlText);
	//myTrace("after btAF: text=" + this.holder.text + "");
	//myTrace("twf.buildTextAndFields, 5.original=" + this.original.text);
}
// debugging function - traces the line break characters and/or whole lines
TextWithFieldsClass.prototype.showLineBreaks = function() {
	var plainText = new String(this.holder.text);
	for (var i in this.lines) {
		var thisChar = plainText.substr(this.lines[i].idx,1);
		var lineStart = this.lines[i].idx;
		// v6.3.6 Remember/Note that i is a string (!!?) not a number
		var lineEnd = this.lines[parseInt(i)+1].idx;
		//myTrace("line[" + i + "].start=" + lineStart + " .end=" + lineEnd);
		var thisLine = plainText.substring(lineStart,lineEnd);
		//if (thisChar.charCodeAt(0) == 9) thisChar = "<tab>";
		//if (thisChar.charCodeAt(0) == 13) thisChar = "<newline>";
		//myTrace("lines[" + i + "].idx=" + this.lines[i].idx + ", .y=" + this.lines[i].y + " " + thisChar);
		myTrace("lines[" + i + "]=" + thisLine);
	}
}
// debugging function - changes natural line breaks to forced ones
// this normally embedded at the end of buildTextAndFields
/*
TextWithFieldsClass.prototype.forceLineBreaks = function() {
	Selection.setFocus(this.holder);
	for (var i in this.lines) {
		if (this.lines[i].idx > 0) {
			Selection.setSelection(this.lines[i].idx-1,this.lines[i].idx);
			this.holder.replaceSel(newline);
		}
	}
}
*/
TextWithFieldsClass.prototype.measureFields = function() {
	//myTrace("twf.measureFields");
	// when we do the width measurments, need to use margins etc.
	// Note: this assumes that the last character in the text holds the
	// indents for ALL the text.
	var thisTF = this.lastTF;
	var adjustY = 4; var adjustX = 2;
	var marginAdjust = thisTF.blockIndent + thisTF.leftMargin;
	//trace("margin adjust=" + marginAdjust);
	var myX = 0;
	// We now know the line breaks and heights, so look at widths.
	var lineStart = 0;
	for (var i=0; i<this.fields.length; i++) {
		//myTrace("check on field[" + i + "].start=" + this.fields[i].start + " .end=" + this.fields[i].end);
		// first find out which line the field starts and ends on
		for (var j=lineStart; j<this.lines.length; j++) {
			//myTrace("line[" + j + "].start=" + this.lines[j].idx);
			if (this.fields[i].start >= this.lines[j].idx) {
				this.fields[i].startLine = j;
				//myTrace("so field starts on line " + j);
			}
			if (this.fields[i].end > this.lines[j].idx) {
				this.fields[i].endLine = j;
				//myTrace("and end on line " + j);
			} else {
				lineStart = j-1;
				break;
			}
		}
		//myTrace("field " + i + " starts on line[" + this.fields[i].startLine +"] and ends on line[" + this.fields[i].endLine +"]");
		//trace("get width up to beginning of field " + i + " lineStart=" + this.lines[this.fields[i].startLine].idx + " fieldStart=" + this.fields[i].start);
		fieldDimension = this.original.getTextDimensions(this.widthCalc, this.lines[this.fields[i].startLine].idx, this.fields[i].start);
		//trace("x=" + fieldDimension.width);
		myX = fieldDimension.width + adjustX + marginAdjust;
		if (fieldDimension.tabCount) {
			// the width measurement does NOT take into account margins, so if you end up 
			// close to a tab stop, then perhaps you should actually have gone over it!
			if (fieldDimension.width == thisTF.tabStops[0] && marginAdjust>0) {
				// so measure the width without the tab, add in the margin and if this
				// figure is over the tab, then it means you should use the next one
				var widthWithoutTab = this.original.getTextDimensions(this.widthCalc, this.lines[this.fields[i].startLine].idx, this.fields[i].start-1)
				if ((widthWithoutTab.width + marginAdjust) >= thisTF.tabStops[0]) {
					//trace("adjusting due to tabs and margins");
					myX = thisTF.tabStops[1]+marginAdjust;
				}
			} 
			// the margin adjustment is not needed for anything after a tab position as
			// these are absolute
			myX -= marginAdjust;
		// Note: following is an idea to cope with lineIndent, but untested yet
		//} else {
		//	// finally, first lines might also need to adjust for lineIndent
		//	if (this.fields[i].startLine == 0 && thisTF.lineIndent > 0) {
		//		myX += thisTF.lineIndent;
		//	}
		}
		this.fields[i].coords.push({x:myX}); // the coords obj for the first line

		// If a field went over two lines:
		// some of the coordinates will be wrong and need to be recalculated
		// Note: this will ONLY work for going over 2 lines not more!
		if (this.fields[i].startLine != this.fields[i].endLine) {
			//myTrace("field " + i + " goes from line " + this.fields[i].startLine + " to " + this.fields[i].endLine);
			//myTrace("first line x=" + myX);
			this.fields[i].coords.push({x:0+adjustX+marginAdjust});
			//myTrace("second line x=" + (adjustX+marginAdjust));
			//trace("so make a second set of coords, y=" + fields[i].coords[1].y);
			// the x coord is right for the first line
			// to get the dimensions for line 1 measure the width of the bit of the field on this line
			var partialFieldStart = this.fields[i].start;
			//var partialFieldEnd = this.lines[this.fields[i].endLine].idx-1;
			var partialFieldEnd = this.lines[this.fields[i].startLine+1].idx-1;
			//trace("measure partial chars from " + partialFieldStart + " to " + partialFieldEnd);
			partialFieldDimension = this.original.getTextDimensions(this.widthCalc, partialFieldStart, partialFieldEnd);
			//this.fields[i].coords[0].w = partialFieldDimension.width;		// v6.5.4.2 Yiu changed to next line, bug id 1320a
			this.fields[i].coords[0].w = partialFieldDimension.width + this.getOffsetWithFieldStartOrEndPos(this.lines[this.fields[i].startLine+1].idx) * 15;	// v6.5.4.2 Yiu commented, Bug ID 1320a, fixing the problem that the last word failed to reponse to mouse action because of CJK character
			//myTrace("first line gap width=" + partialFieldDimension.width);
			// v6.2 You can know if some of this height is just pure line spacing
			// in which case, perhaps you don't want the coords to include it? Not sure.
			//this.fields[i].coords[0].h = partialFieldDimension.height;
			this.fields[i].coords[0].h = partialFieldDimension.height - partialFieldDimension.lineSpacing;
			// v6.2 If you are covering more than 2 lines, the middle ones cover the whole line
			var extraLines = this.fields[i].endLine - this.fields[i].startLine;
			for (var nextLine=1; nextLine<extraLines; nextLine++) {
				//myTrace("doing an extra line=" + nextLine);
				this.fields[i].coords.push({x:0+adjustX+marginAdjust}); // coords obj for extra lines
				partialFieldStart = partialFieldEnd +1;
				partialFieldEnd = this.lines[this.fields[i].startLine + nextLine +1].idx-1;
				partialFieldDimension = this.original.getTextDimensions(this.widthCalc, partialFieldStart, partialFieldEnd);
				//this.fields[i].coords[nextLine].w = partialFieldDimension.width;	// v6.5.4.2 Yiu changed to next line, bug id 1320a
				this.fields[i].coords[nextLine].w = partialFieldDimension.width + this.getOffsetWithFieldStartOrEndPos(this.lines[this.fields[i].startLine + nextLine + 1].idx) * 15;	// v6.5.4.2 Yiu commented, Bug ID 1320a, fixing the problem that the last word failed to reponse to mouse action because of CJK character
				// v6.2 as above for line spacing effect
				this.fields[i].coords[nextLine].h = partialFieldDimension.height - partialFieldDimension.lineSpacing;
				// v6.2 if line spacing is in effect, the h will not be so high, but the y IS still big. So you can't
				// use the .h to set the .y directly
				//this.fields[i].coords[nextLine].y = this.lines[this.fields[i].startLine + nextLine].y - this.fields[i].coords[nextLine].h + adjustY;
				this.fields[i].coords[nextLine].y = this.lines[this.fields[i].startLine + nextLine].y - partialFieldDimension.height + adjustY;
			}
			// to get the dimensions for last line, measure the width of the bit of the field on this line
			//myTrace("final line=" + nextLine);
			partialFieldStart = partialFieldEnd +1;
			partialFieldEnd = this.fields[i].end;
			//trace("measure partial chars from " + partialFieldStart + " to " + partialFieldEnd);
			partialFieldDimension = this.original.getTextDimensions(this.widthCalc, partialFieldStart, partialFieldEnd);
			this.fields[i].coords[nextLine].w = partialFieldDimension.width;	
			//myTrace("final line gap width=" + partialFieldDimension.width);
			// v6.2 as above for line spacing effect
			this.fields[i].coords[nextLine].h = partialFieldDimension.height - partialFieldDimension.lineSpacing;	
			// v6.2 if line spacing is in effect, the h will not be so high, but the y IS still big. So you can't
			// use the .h to set the .y directly
			//this.fields[i].coords[nextLine].y = this.lines[this.fields[i].endLine].y - this.fields[i].coords[nextLine].h + adjustY;
			this.fields[i].coords[nextLine].y = this.lines[this.fields[i].endLine].y - partialFieldDimension.height + adjustY;
			//trace("add field at y=" + this.fields[i].coords[1].y);

		} else {
			// otherwise the field is on one line and can x and w can be calculated directly
			partialFieldDimension = this.original.getTextDimensions(this.widthCalc, this.fields[i].start, this.fields[i].end);
			// v6.2 as above for line spacing effect
			this.fields[i].coords[0].h = partialFieldDimension.height - partialFieldDimension.lineSpacing;
			this.fields[i].coords[0].w = partialFieldDimension.width;
			//myTrace("add field w=" + this.fields[i].coords[0].w + "h=" + this.fields[i].coords[0].h);
	
		}
		// all lines y coordinate might have changed after being set early in the 
		// line, so update it
		// v6.2 as above for line spacing effect
		//this.fields[i].coords[0].y = this.lines[this.fields[i].startLine].y - this.fields[i].coords[0].h + adjustY;
		this.fields[i].coords[0].y = this.lines[this.fields[i].startLine].y - partialFieldDimension.height + adjustY;
	}
	// clear the original field
	this.widthCalc.text = "";
	this.original._visible = false;
	var stopTime = new Date();
//	trace("buildFields for " + this._name + " took " + (Number(stopTime.getTime()) - Number(startTime.getTime())));
}

// Cover all the fields in the text with MC that trigger callbacks to the component parent
// for onRollOver, onMouseDown and onMouseUp
TextWithFieldsClass.prototype.addFieldCovers = function() {
	//myTrace("twf.addFieldCovers for " + this.fields.length);
//	var startTime = new Date();
// v6.2 initialise the fc depth
	this.fcDepth = 9999; // maybe this should be _global.ORCHID.coverDepth
	for (var i in this.fields) {
		//trace("add field cover at " + this.fields[i][0].start + " to " + this.fields[i][0].end);
		this.addFieldCover(i);
	}
//	var stopTime = new Date();
//	trace("addFieldCovers for " + this._name + " took " + (Number(stopTime.getTime()) - Number(startTime.getTime())));
}

// for clearing up - this must be done while the fields array reflects what is on the screen
TextWithFieldsClass.prototype.removeFieldCovers = function() {
	for (var i in this.fields) {
		for (var j in this.fields[i].coords) {
			//myTrace("twf.removeFieldCovers " + i + ":"+ this.fields[i].coords[j].coverMC);
			this.fields[i].coords[j].coverMC.removeMovieClip();
		}
	}
}
// a kinder more gentle way of cleaning up by just resetting the field covers to their
// original recorded positions
TextWithFieldsClass.prototype.resetFieldCovers = function() {
	for (var i in this.fields) {
		// one field will have multiple covers if it goes over 1 line
		for (var j in this.fields[i].coords) {
			var thisCover = this.fields[i].coords[j].coverMC;
			thisCover._x = this.fields[i].coords[j].x; // * 1.05;
			thisCover._y = this.fields[i].coords[j].y; // - this.fields[i].coords[j].height;
			thisCover._width = this.fields[i].coords[j].w;
			thisCover._height = this.fields[i].coords[j].h;
		}
	}
}

// v6.2 Provide a function to disable a field
TextWithFieldsClass.prototype.disableField = function(fieldID) {
	//trace("disable field " + fieldID);
	var fieldIDX=TWF.lookupArrayItem(this.fields, fieldID, "id");
	this.fields[fieldIDX].disabled = true;
	// you can't just remove and add field covers as this will change
	// the instance name of the cover as they are incremental. This in turn
	// will break things like the dropZoneList as it saves cover names.
	// Leave it for now and handle externally. BUt one solution might be to
	// take the bit from the following code that assigns event handlers to 
	// each cover outside, so that you can add it and remove it without changing
	// the covers themselves.
	for (var j in this.fields[fieldIDX].coords) {
		thisCover = this.fields[fieldIDX].coords[j].coverMC;
		this.removeCoverFunctions(thisCover);
	}
}
TextWithFieldsClass.prototype.enableField = function(fieldID) {
	var fieldIDX=TWF.lookupArrayItem(this.fields, fieldID, "id");
	this.fields[fieldIDX].disabled = false;
	//this.removeFieldCovers();
	//this.addFieldCovers();
	for (var j in this.fields[fieldIDX].coords) {
		thisCover = this.fields[fieldIDX].coords[j].coverMC;
		this.addCoverFunctions(thisCover);
	}
}

// This function will put a MC over a field to allow it to react (and be seen if so skinned)
TextWithFieldsClass.prototype.addFieldCover = function(fieldIDX) {
	//myTrace("twf.addFieldCover for " + fieldIDX + " spanning lines=" + this.fields[fieldIDX].coords.length);
	// one field will have multiple covers if it goes over 1 line
	for (var j in this.fields[fieldIDX].coords) {
		//Note: this seems to set a conflict limit of 100 on the fields
		//var thisDepth = Number(_global.ORCHID.coverDepth)+ Number(fieldID)+ Number(j*100);
		// v6.2 trouble with this.myDepth++
		// by using this kind of incremental depth, you will keep changing the names
		// of covers as you do stuff to the twf. This seems bad. So how about starting
		// at a set point for each iteration?
		//var thisCover = this.attachMovie("fieldCover","FC"+this.myDepth++,this.myDepth);
		var thisCover = this.attachMovie("fieldCover","FC"+this.fcDepth++,this.fcDepth);
		//trace("give it callback " + this.mouseDownCallback_param);
		//trace("added FC " + thisCover);
		thisCover._x = this.fields[fieldIDX].coords[j].x; // * 1.05;
		thisCover._y = this.fields[fieldIDX].coords[j].y;// - this.fields[fieldIDX].coords[j].height;
		//myTrace("add cover x=" + this.fields[fieldIDX].coords[j].x + " y=" + this.fields[fieldIDX].coords[j].y +
		//		" w=" + this.fields[fieldIDX].coords[j].w + " h=" + this.fields[fieldIDX].coords[j].h); // +
		//		" .height=" + this.fields[fieldIDX].coords[j].height);
		// setting width and height like this distorts the fieldcover (which doesn't matter
		// in itself) but which upsets anything you attach to the cover (such as drag text);
		thisCover._width = this.fields[fieldIDX].coords[j].w;
		thisCover._height = this.fields[fieldIDX].coords[j].h;
		// use an *undocumented* parameter to let you change the alpha on the FC
		// useful for debugging and maybe some other uses?
		if (this._$coverAlpha > 0 && typeof this._$coverAlpha == "number") {
			thisCover._alpha = this._$coverAlpha;
		} else {
			thisCover._alpha = 100; //IE10+Win8 fix gh#390
		}
		// is this where we should add cursor hiding or not?
		// it might work best to always hide the cursor here and let the events
		// reset it, or you could pass a exercise level mode flag to the component
		// to work with.
		if (this.hideCursorChange) {
			thisCover.useHandCursor = false;	
		}
		// v6.2 for tabbing correction
		thisCover._focusrect = false;

		// v6.3.4 You might need to know if this field covers multiple lines
		// Save the line index in case it is useful.
		if (this.fields[fieldIDX].coords.length > 1) {
			thisCover.multiLine = j;
		} else {
			thisCover.multiLine = -1;
		}
		
		// save the cover
		this.fields[fieldIDX].coords[j].coverMC = thisCover;
		thisCover.fieldIDX = fieldIDX;
		thisCover.fieldID = this.fields[fieldIDX].id;
		thisCover.fieldType = this.fields[fieldIDX].type;
		thisCover.fieldURL = this.fields[fieldIDX].url;
		//myTrace("created cover " + thisCover + " ID=" + thisCover.fieldID+ " fieldType=" + thisCover.fieldType);
		//myTrace("created cover  for " + thisCover.fieldID+ " fieldType=" + thisCover.fieldType);
		//trace("created cover " + thisCover + " with x=" + thisCover._x + ", y=" + thisCover._y + ", width=" + thisCover._width + ", height=" + thisCover._height);

		// v6.2 Can you disable a field (temporarily?)
		if (!this.fields[fieldIDX].disabled) {
			this.addCoverFunctions(thisCover);
		}
		// v6.4.3 #errorCorrection problem#
		// When a targetGap is clicked on, I reset the fieldText from the wrong answer to spaces. This might be longer, so I refresh
		// the whole twf. This causes all the other fields to be reset. Some of them may now be real gaps, which means that the field
		// has spaces in and the answer is stored in the cover. But I have just cleared the cover in order to reset it. So I need to 
		// make sure that I reset the cover text too.
		// Where is the answer they have typed? In the full field object it is attempt.finalAnswer. Do I know that in here?
		// This function is in the loop for multi-covers which doesn't seem right. But, at least for now, you will have converted
		// multiline targets to single line gaps before this could cause an issue here.
		// Another complication is that after marking you don't want to pick up finalAnswer, you want to pick up the correct answer.
		if (this.partialRefresh == "saveCovers") {
			// Note that you HAVE to go back to the fields array at the exercise level to find out about this field
			// because the version you have in the twf is based on the asfunction in the original text, which never changes
			var me = _global.ORCHID.LoadedExercises[0];
			var thisField = me.getField(thisCover.fieldID);
			if (thisField.type=="i:gap") {
				// I don't like this because it ties TWF directly into ORCHID. But it will do for now.
				if (_global.ORCHID.session.currentItem.afterMarking) {
					var k=0;
					while (thisField.answer[k].correct == "false" &&
							k< thisField.answer.length) {
						k++;
					}
					var answerIdx = k;
					var useText = thisField.answer[answerIdx].value;
					//myTrace("save cover for " + thisField.id + "," + thisField.type + ", use preset answer of " + useText);
				} else {
					var useText = thisField.attempt.finalAnswer;
					//myTrace("save cover for " + thisField.id + "," + thisField.type + ", use typed text of " + useText);
				}
				//thisCover.setText(thisField.attempt.finalAnswer);
				thisCover.setText(useText);
			}
		}
	}
}
// This function will add event handling to the field cover
TextWithFieldsClass.prototype.addCoverFunctions = function(thisCover) {
	//myTrace("add cover functions for field " + thisCover.fieldID + " type=" + thisCover.fieldType);
	thisCover.onRollOver = function() {
		//myTrace("twf:you rolled over field " + this.fieldID + " which is " + this.fieldType);
		// callbacks from component parameter to the components' parent 
		//trace("try to run " + this._parent._parent + "." +this._parent.rollOverCallback_param);
		//this.myRollOver = eval("this._parent._parent."+this._parent.rollOverCallback_param);
		this.myRollOver = eval(this._parent.rollOverCallback_param);
		// trigger the first call to the rollOver function immediately as it has
		// already been caught by this for now
		this.myRollOver();
		// enable onMouseDown and onMouseUp functions, they will be disabled by rollOut
		this.onMouseDown = function() {
			// v6.2 Rather than drag the actual fieldCover (which I think contributes
			// to the problems of dragging from a drop), could you create an mc
			// at a higher level (which might also help when you want to drag between
			// different parts of the screen) and then drag that?
			// v6.2 the dragField is dynamic, so you need to look it up at click time
			// Note: this assumes ORCHID. Probably should create a setLinkedField function
			// so that ANY outside program can call it to then update twf.fieldCover.dragField
			// Note: an alternative is for twf to simply fire drag event on drags OR drops and
			// let the outside code figure out if there is anything in the drop to drag.
			//var dragField = _global.ORCHID.LoadedExercises[0].getField(this.fieldID).dragField;
			//myTrace("mouseDown on " + this.fieldType + " field=" + this.fieldID + " with drag=" + dragField);
			// v6.2 - also allow dragging of a drag that is now nestling in a drop
			//if (this.fieldType == "i:drag") {
			//if (this.fieldType == "i:drag" || (this.fieldType == "i:drop" && dragField > 0)) {
			if (this.fieldType == "i:drag" || this.fieldType == "i:drop"  || this.fieldType == "i:dropInsert") {
				//trace("dragField=" + this.dragField);
				//myTrace("TWF:cover:onMouseDown, set myDrag=true for " + this);
				// v6.2 - save it in the cover as difficult to look up
				//this.dragField = dragField;
				this.myDrag = true;
				// v6.2 So, don't drag this cover, let the dragEvent create one
				//this.startDrag(false);
				this.myDragEvent = eval(this._parent.dragCallback_param);
				this.myDragEvent();
			}
			
			this.myMouseDown = eval(this._parent.mouseDownCallback_param);
			this.myMouseDown();
		}
		this.onMouseUp = function() {
			//myTrace("TWF:cover.onMouseUp for " + this.fieldID);
			// v6.2 If you don't drag the cover at all, then you will not
			// ever want to do onMouseUp for a drag, so comment that code
			/*
			// v6.2 - also allow dragging of a drag that is now nestling in a drop
			//if (this.fieldType == "i:drag") {
			if (this.fieldType == "i:drag" || (this.fieldType == "i:drop" && this.dragField > 0)) {
				// v6.2 - clear up so that you don't remember the wrong drags
				// NO - this is done outside
				//if (this.dragField > 0) this.dragField = undefined;
				this.myDrag = false;
				//AR but I might not want to drag the field?
				this.stopDrag();
				//trace("dragging=" + this + " dropping=" + this._droptarget);
				myDrop = eval(this._droptarget);
				//trace("twf: dropped over field type=" + myDrop.fieldType + "(" + myDrop + ")");
				if (myDrop.fieldType.indexOf("i:",0) >= 0) {
					this.myTarget = myDrop.fieldID; //Number(myDrop.getDepth() - _global.ORCHID.coverDepth);
					//trace("twf: you came up over field (" + myDrop + ") " + this.myTarget);
					this.myDropEvent = eval(this._parent.dropCallback_param);
					this.myDropEvent();
				}
			}
			*/
			this.myMouseUp = eval(this._parent.mouseUpCallback_param);
			// is this a modified click?
			var	thisKey = undefined;
			// v6.4.2.7 Case sensitive??
			// Well, something is stopping the Key.CONTROL from being picked up within this cover if you are also in 
			// a typing box. The gapListener triggers (fieldReaction), but I just don't see the modifier right now.
			// That is because I don't trigger this onMouseUp if I am over the gap.
			//if (Key.isDown(Key.control)) {
			//	thisKey = Key.control;
			if (Key.isDown(Key.CONTROL)) {
				//myTrace("I know it is CONTROL");
				thisKey = Key.CONTROL;
			} else if (Key.isDown(Key.SHIFT)) {
				//myTrace("I know it is SHIFT");
				thisKey = Key.SHIFT;										
			}
			//myTrace("TWF:mouseUp on a " + this.fieldType + " with modKey " + thisKey);
			this.myMouseUp(thisKey);
			// v6.3 Having caught the ctrl-click on a field, you shouldn't
			// also process the TWF onMouseUp.
			// Except that for some fields I can give them a glossary. This is the opposite of the clauses
			// in fieldReaction as they will stop that taking effect, which means that this will take effect.
			// So if it is hiddenTargets or it is a drag or a highlight, do the glossary
			if (	_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets ||
				this.fieldType == "i:drag" || this.fieldType == "i:highlight") {
				//myTrace("keep going with TWF functions");
			// and EGU has no hints, so you can do the same with regular targets too
			} else if ((_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) &&
				this.fieldType == "i:target") {
			// or if you are after marking you can either give feedback or glossary
			// v6.4.2.7 With target fields you come here after marking, but with gaps you don't
			// Ah no. If you have feedback the covers remain active (and you come here), otherwise you disable them
			} else if (_global.ORCHID.session.currentItem.afterMarking) {
				// v6.4.2.7 If this is a gap, the regular glossary will not work as we don't insert the answer into holder
				// so you will have to do something - even if the best you can do is glossary for the whole phrase.
				// No good. We have already stopped this from being a gap and made it a target. Try letting field type come through...
				// No, all too much. Just leave gaps as non-glossary
				//if (this.fieldType == "i:gap" || this.fieldType == "i:dropdown" || this.fieldType == "i:targetGap"){
				//	var thisPhrase = this.getText();
				//	myTrace("hijack, as gap, send text=" + thisPhrase);
				//	_global.ORCHID.onControlClick(thisPhrase);
				//	this._parent.mouseUpKey = thisKey;
				//} else {
					//myTrace("keep going with TWF functions as after marking on " + this.fieldType);
				//}
			} else {
				// This will (possibly) stop the parent (TWF) from running its own functions
				//myTrace("tell TWF functions for " + this._parent + " with " + thisKey);
				this._parent.mouseUpKey = thisKey;
			}
		}
		/*
		// v6.3.4 If you are moving over a dropInsert you want to know which is the 
		// closest insert point, so start calculating your current position
		if (this.fieldType == "i:dropInsert" && this.myDrag == true) {
			this.onMouseMove = function() {
				myTrace("x=" + _root._xmouse + " over twf=" + this._parent);
				var markProps = {stretch:false, align:"right", offsetX:+4, oneLine:true};
				this._parent.setFieldBackground(this.fieldID, "Tick", markProps);
			}
		}
		*/
	}
	thisCover.onRollOut = function() {
		//trace("delete events for field " + this.fieldID);
		// Can I detect that if I am dragging this right now, that I don't want to 
		// do rollOut?
		//trace("OK, rollOut for " + this + " and myDrag=" + this.myDrag);
		// v6.3.5 In a temporary workround, ignore drag after marking since you won't be
		//if (this.myDrag == true) {
		if ((this.myDrag == true) &&
			!_global.ORCHID.session.currentItem.afterMarking) {
			//myTrace("should cancel mouseUp, but myDrag is true, so don't");
		} else {
			//myTrace("cancel mouseUp for " + this.fieldID);
			delete this.onMouseDown;
			delete this.onMouseUp;
			delete this.myMouseDown;
			delete this.myMouseUp;
			delete this.myDropEvent;
			delete this.myDragEvent;
			this.myRollOut = eval(this._parent.rollOutCallback_param);
			this.myRollOut();
			/*
			if (this.fieldType == "i:dropInsert") {
				// v6.3.4 Clear the position calculation events
				myTrace("remove fback " + this._parent);
				delete this.onMouseMove;
				this._parent.clearFieldBackground(this.fieldID);
			}
			*/
		//} else {
		//	trace("still dragging so no rollOut triggered");
		}
	}
	// to catch them clicking on the field and dragging and letting go outside
	// duplicate the rollOut functionality in onDragOut
	// This is also triggered if you are dragging and the mouse spurts ahead of the mc
	// or if you drag over another mc of higher order
	thisCover.onDragOut = function() {
		//trace("OK, dragOut for " + this + " and myDrag=" + this.myDrag);
		//trace("dragged out of " + this.fieldID);
		// v6.3.5 In a temporary workround, ignore drag after marking since you won't be
		//if (!this.myDrag) {
		//if (this.myDrag == true) {
		if ((this.myDrag == true) &&
			!_global.ORCHID.session.currentItem.afterMarking) {
			//myTrace("should cancel mouseUp, but myDrag is true, so don't");
		} else {
			delete this.onMouseDown;
			delete this.onMouseUp;
			this.myRollOut = eval(this._parent.rollOutCallback_param);
			this.myRollOut();
		//} else {
		//	trace("still dragging so no dragOut triggered");
		}
	}
	// v6.2 A new function for holding text in the cover. 
	// v6.3.4 Note that not all fields put text into the cover, 
	// some just keep it in the twf underneath and just use the cover
	// for event triggers.
	thisCover.setText = function(text) {
		// get the text format from the twf
		var myTF = this._parent.getFieldTextFormat(this.fieldID);
		//myTrace("twf.cover.setText:" + text + " for " + this); // + " width=" + this._width + " font=" + myTF.font + " " + myTF.size);

		var origXScale = this._xscale;
		var origYScale = this._yscale;
		// The reason for doing it is to allow you to normalise the _xscale of the text
		var contentHolder = this.createEmptyMovieClip("gapHolder",0); 
		contentHolder._focusrect = false;
		contentHolder._xscale = 10000 / origXScale;
		contentHolder._yscale = 10000 / origYScale;
		// make a textField in the gap holder to actually cope with the typing
		// it was y=-3, but this seems a trifle low
		var myX = -2; myY = -4; myW = 4; myH = 4// adjustment so that the letters in the box are over the letters in the text
		contentHolder.createTextField("gap",0,myX,myY,Number(this._width + myW) ,Number(this._height + myH)); 
		var myGap = contentHolder.gap
		//myTrace("setText.gap=" + myGap);
		myGap._focusrect = false;
		myGap.wordWrap = false;
		myGap.multiline = false;
		myGap.border = false;
		myGap.background = false;
		myGap.selectable = false;
		//myGap._xscale = myGap._yscale = 100;
		//set the leading to null so that the height of the text box is fixed no matter what the line spacing is
		myTF.leading = null;
		// v6.2 And also don't use underlining since that would duplicate the gap
		myTF.underline = false;
		myGap.setNewTextFormat(myTF);
		// v6.2 truncate the typed answer if it is too long
		// available width is myGap._width, length of text is myTF.getTextExtent(text)
		// the gutter is 2 each side for a text field
		//myTrace("textWidth=" + oldFocus.textWidth + " _width="+oldFocus._width);
		myGap.text = text;
		var cut = myGap.text.length;
		//myTrace("length=" + cut);
		while (myGap.textWidth > (myGap._width - 4)) {
			cut--;
			myGap.text = myGap.text.substr(0,cut);
		}
		//myTrace("truncate at char=" + cut);
		// v6.3.4 If this is a multiline field, you will need to put some of this text
		// into the other covers. So what are they? First you need to find out which
		// line you are currently on (and if there is truncated text to deal with)
		if ((this.multiLine >= 0) && (cut < text.length)) {
			//myTrace("twf.cover.setText.multiline field");
			var thisTWF = this._parent;
			// if you are on the last line, no need to do nice truncation
			if (this.multiLine < thisTWF.fields[this.fieldIDX].coords.length-1) {
				//myTrace("fieldIDX=" + this.fieldIDX);
				// this is truncation point, but we need to keep going to a line break character
				// although I suppose you do a real truncation on the last line.
				var llBCcut = cut;
				var lineBreakChars = String.fromCharCode(32,9,45,160);
				while (lineBreakChars.indexOf(myGap.text.charAt(llBCcut-1))<0 && llBCcut>0) {
					llBCcut--;
				}
				//myTrace("llbc at char=" + llBCcut);
				// if no line break char was found, do a brutal chop
				if (llBCcut == 0)
				{
					llBCcut = cut;
				}
				myGap.text = text.substr(0,llBCcut);
				for (var i=0; i<thisTWF.fields[this.fieldIDX].coords.length; i++) {
					//myTrace("check coords[" + i + "]");
					if (this == thisTWF.fields[this.fieldIDX].coords[i].coverMC) {
						//myTrace("this is the cover for line " + i);
						// So how much text will fit in this line?
						//myTrace("this coords.w=" + thisTWF.fields[this.fieldIDX].coords[i].w);
						//myTrace("next coords.w=" + thisTWF.fields[this.fieldIDX].coords[i+1].w);
						var nextCover = thisTWF.fields[this.fieldIDX].coords[i+1].coverMC;
						//myTrace("so trigger for " + nextCover);
						break;
					}
				}
				if (nextCover != undefined) {
					//myTrace("leftover:" + text.substr(llBCcut));
					nextCover.setText(text.substr(llBCcut));
				}
			}
		}
	}
	// v6.2 A new function for holding text in the cover, and clearing it
	thisCover.clearText = function() {
		//myTrace("twf.cover.clearText from " + this);
		this.gapHolder.removeMovieClip();
	}
	// v6.35 A new function for easily getting the text
	thisCover.getText = function() {
		return this.gapHolder.gap.text;
	}
	// v6.3.4 Functions for showing where a drop would occur between words
	thisCover.showDropPosition = function(MCLinkageID) {
		var thisTWF = this._parent;
		//myTrace("this.fieldIDX=" + this.fieldIDX);
		//myTrace("this.multiLine=" + this.multiLine);

		if (this.dropSpaces == undefined) {
			//myTrace("calc where spaces are for field " + this.fieldID);
			var fieldText = thisTWF.getFieldText(this.fieldID);
			var fieldTextTF = thisTWF.getFieldTextFormat(this.fieldID);
			//myTrace("[" + fieldText + "].size=" + fieldTextTF.size);
	
			thisTWF.createTextField("anotherWidthCalc",thisTWF.myDepth++,0,0,4,4);
			thisTWF.anotherWidthCalc.html = false;
			this.anotherWidthCalc.border = false;
			thisTWF.anotherWidthCalc.wordWrap = false; // this will keep it on one line for measuring widths
			thisTWF.anotherWidthCalc.autoSize = true;			
			thisTWF.anotherWidthCalc._visible = false; // can you hide it without effecting its value?
			thisTWF.anotherWidthCalc.setNewTextFormat(fieldTextTF);
			
			// Now find all the spaces in this text
			this.dropSpaces = new Array();
			this.dropSpaces.push(0); // x coord of starting position
			for (var i=0; i<fieldText.length; i++) {
				//myTrace("check for space=[" + fieldText.charAt(i) +"]");
				if (fieldText.charAt(i) == " ") {
					// getTextExtent just does not work for in this situation
					//this.dropSpaces.push(fieldTextTF.getTextExtent(fieldText.substr(0,i+1)).width);
					thisTWF.anotherWidthCalc.text = fieldText.substr(0,i);
					this.dropSpaces.push(thisTWF.anotherWidthCalc.textWidth);
					//myTrace("measure " + thisTWF.anotherWidthCalc.text + ": width=" + thisTWF.anotherWidthCalc.textWidth);
				}
			}
			thisTWF.anotherWidthCalc.text = fieldText;
			this.dropSpaces.push(thisTWF.anotherWidthCalc.textWidth);
			thisTWF.anotherWidthCalc.removeTextField();	
		}
		// for debug only
		//for (var i in this.dropSpaces) {
			//myTrace("space at " + this.dropSpaces[i]);
		//}
		//var myPoint = {x:_root._xmouse, y:_root._ymouse};
		//thisTWF.globalToLocal(myPoint);
		//myTrace("init, this._x=" + this._x + " this._xmouse=" + ((this._xscale/100) * this._xmouse));
		var thisX = this._x + ((this._xscale/100) * this._xmouse);
		//var initObj = {_x:myPoint.x, _y:myPoint._y};
		var initObj = {_x:thisX, _y:0};
		//this.cursor = thisTWF.TWFcanvas.attachMovie(MCLinkageID, "FCursor", thisTWF.depth++, initObj);
		// v6.4.2.8 Tick depths screwing up general canvas click, should use myDepth
		this.cursor = thisTWF.TWFcanvas.attachMovie(MCLinkageID, "FCursor", thisTWF.myDepth++, initObj);
		this.cursor._width = 10;
		//this.cursor._y += this.cursor._height
		this.onMouseMove = function() {
			// now find the closest space
			//myTrace("this._xscale=" + this._xscale + " this._xmouse=" + this._xmouse + " this._parent._xmouse=" + this._parent._xmouse);
			var thisX = (this._xscale/100) * this._xmouse;
			var i = this.dropSpaces.length;
			
			while (i-->0) {
				// what is half way between these two spaces?
				//myTrace("i=" + i + " half=" + (this.dropSpaces[i] + this.dropSpaces[i-1])/2);
				if (thisX > (this.dropSpaces[i] + this.dropSpaces[i-1])/2) {
					//myTrace("closest space to " + thisX + " is " + this.dropSpaces[i]);
					//var myPoint = {x:this._x + this.dropSpaces[i], y:0};
					this.nearestDropPosition = i;
					//this.localToGlobal(myPoint);
					//this._parent.globalToLocal(myPoint);
					this.cursor._x = this._x + this.dropSpaces[i];
					break;
				}
			}
			
		}
	}
	thisCover.hideDropPosition = function() {
		//myTrace("hide cursor over cover=" + this);
		this._parent.TWFcanvas.FCursor.removeMovieClip();
		delete this.onMouseMove;
	}

	/*
	// Unless you can attach a typing box to each cover, there doesn't seem much point
	// in doing this here. I might as well use the global version with setText above.
	thisCover.setTypingBox = function() {
		// get the text format from the twf
		var myTF = this._parent.getFieldTextFormat(this.fieldID);

		//var origXScale = this._parent._xscale;
		//var origYScale = this._parent._yscale;
		// The reason for doing it is to allow you to normalise the _xscale of the text
		//var contentHolder = this.createEmptyMovieClip("gapHolder",_global.ORCHID.selectDepth); 
		var gapHolder = this.attachMovie("fieldCover","gapHolder",_global.ORCHID.selectDepth); 
		gapHolder._x = 0;
		gapHolder._y = 0;
		gapHolder._focusrect = false;
		gapHolder._width = this._width;
		gapHolder._height = this._height;
		gapHolder._focusrect = false;
		// link the single gap back to the cover that it is currently working with
		// v6.2 I seem to do this again a little later direct to the myGap
		//gapHolder.cover = fieldCover;	
		var origXScale = fieldCover._xscale;
		var origYScale = fieldCover._yscale;
		gapHolder._xscale = 10000 / origXScale;
		gapHolder._yscale = 10000 / origYScale;
		var contentHolder = gapHolder.createEmptyMovieClip("gap",0); 
		contentHolder._focusrect = false;
		contentHolder._xscale = 10000 / origXScale;
		contentHolder._yscale = 10000 / origYScale;
		var myX = -2; myY = -4; myW = 4; myH = 4// adjustment so that the letters in the box are over the letters in the text
		contentHolder.createTextField("gap",2,myX,myY,Number(this._width + myW) ,Number(this._height + myH)); 
		myGap = contentHolder["gap"]; // was attached to _root
		// make a textField in the gap holder to actually cope with the typing
		// it was y=-3, but this seems a trifle low
		//var myX = -2; myY = -4; myW = 4; myH = 4// adjustment so that the letters in the box are over the letters in the text
		//contentHolder.createTextField("gap", 0, myX, myY, Number(this._width + myW), Number(this._height + myH)); 
		//var myGap = contentHolder.gap
		trace("type in " + myGap + " h=" + myGap._height);
		myGap._focusrect = false;
		myGap.html = false;
		myGap.wordWrap = false;
		myGap.multiline = false;
		myGap._xscale = 100;
		myGap._yscale = 100;
		myGap.border = true;
		myGap.background = true;
		myGap.backgroundColor = 0x999999;
		//set the leading to null so that the height of the text box is fixed no matter what the line spacing is
		myTF.leading = null;
		myGap.setNewTextFormat(myTF);
		myGap.selectable = true;
		myGap.text = "start";
		myGap.type = "input";
		Selection.setFocus(myGap);
		// I can type in this field due to the set focus, but cannot click on it, it seems the movie
		// behind is exercising control
	}
	*/
}
// This function will add event handling to the field cover
TextWithFieldsClass.prototype.removeCoverFunctions = function(thisCover) {
	//trace("add cover functions for field " + fieldIDX);
	delete thisCover.onMouseDown;
	delete thisCover.onMouseUp;
	delete thisCover.onRollOver;
	delete thisCover.onRollOut;
	delete thisCover.onDragOver;
	delete thisCover.onDragOut;
}
// this function returns a field cover to match a field ID
// so long as that field is used within this twf
TextWithFieldsClass.prototype.getFieldCover = function(fieldID) {
	//myTrace("getFieldCover for field=" + fieldID + " in twf=" + this);
	var fieldIDX = TWF.lookupArrayItem(this.fields, fieldID, "id");
	if (fieldIDX >= 0) {
		// note, will you ever want second instances of this field?
		return this.fields[fieldIDX].coords[0].coverMC;
	}
	return undefined;
}
// Add a particular MC BEHIND the field (using the canvas to achieve this);
TextWithFieldsClass.prototype.setFieldBackground = function(fieldID, MCLinkageID, props) {
	if (props == undefined) props={stretch:true, oneLine:false};
	//myTrace("stretch=" + props.stretch);
	//myTrace("twf:setFieldBackground on " + fieldID);
	var fieldIDX = TWF.lookupArrayItem(this.fields, fieldID, "id");
	if (fieldIDX >= 0) {
		// v6.2 Can you extend this for fields that are on more than one line?
		// Mind you, for ticks and crosses you don't want to! Just do it on the first line.
		if (props.oneLine) {
			var maxLines = 1;
		} else {
			var maxLines = this.fields[fieldIDX].coords.length;
		}
		for (var j=0; j<maxLines; j++) {
			var thisCover = this.fields[fieldIDX].coords[j].coverMC;
			var initObj = {_x:thisCover._x, _y:thisCover._y}
			//var myMarker = this.TWFcanvas.attachMovie(MCLinkageID, "FBack" + this.fieldIDX + "-" + j, this.fieldIDX, initObj);
			//myTrace("add for field " + fieldID + " at depth=" + this.depth + " name=" + "FBack" + fieldIDX + "-" + j);
			// v6.4.2.8 Tick depths screwing up general canvas click, should use myDepth
			//var myMarker = this.TWFcanvas.attachMovie(MCLinkageID, "FBack" + fieldIDX + "-" + j, this.depth++, initObj);
			var myMarker = this.TWFcanvas.attachMovie(MCLinkageID, "FBack" + fieldIDX + "-" + j, this.myDepth++, initObj);
			//trace("added marker=" + myMarker);
			// for some bizarre reason, I can set _x, _xscale in the initObj, but not _width or _height
			// v6.2 Allow the ability to display a non-stretched background
			if (props.stretch) {
				myMarker._width = thisCover._width; myMarker._height = thisCover._height;
			} else {
				// v6.2 and let the user set alignment (if not stretched)
				if (props.align == "right") {
					myMarker._x += thisCover._width - myMarker._width + props.offsetX;
				} else if (props.align == "center") {
					myMarker._x +=  props.offsetX + (thisCover._width - myMarker._width)/2;
				}
			}
			//trace("over marker with x=" + thisCover._x + ", y=" + thisCover._y + ", width=" + thisCover._width + ", height=" + thisCover._height);
		}
	}
}
// and clear it
TextWithFieldsClass.prototype.clearFieldBackground = function(fieldID) {
	var fieldIDX = TWF.lookupArrayItem(this.fields, fieldID, "id");
	if (fieldIDX >= 0) {
		for (var j=0; j<this.fields[fieldIDX].coords.length; j++) {
			//myTrace("remove from field " + fieldID + " name=" + "FBack" + fieldIDX + "-" + j);
			this.TWFcanvas["FBack" + fieldIDX + "-" + j].removeMovieClip();
		}
	}
}
// v6.4.2.7 Duplicate the above for ticks and crosses (which you don't want to merge with other backgrounds)
// Add a particular MC BEHIND the field (using the canvas to achieve this);
TextWithFieldsClass.prototype.setFieldTick = function(fieldID, MCLinkageID, props) {
	if (props == undefined) props={stretch:false, oneLine:true, offsetX:0};
	//myTrace("twf:setFieldTick on " + fieldID);
	var fieldIDX = TWF.lookupArrayItem(this.fields, fieldID, "id");
	if (fieldIDX >= 0) {
		// v6.4.2.7 Only ever put a tick on the 0 part of a field
		var j=0;
		var thisCover = this.fields[fieldIDX].coords[j].coverMC;
		var initObj = {_x:thisCover._x, _y:thisCover._y}
		//var myMarker = this.TWFcanvas.attachMovie(MCLinkageID, "FBack" + this.fieldIDX + "-" + j, this.fieldIDX, initObj);
		//myTrace("add for field " + fieldID + " at depth=" + this.depth + " name=" + "FBack" + fieldIDX + "-" + j);
		// v6.4.2.7 Try to remove it first if it already exists. Can't see why this is necessary since the name doesn't change
		// but it does appear to work.
		this.TWFcanvas["Tick" + fieldIDX + "-" + j].removeMovieClip();
		// v6.4.2.8 Tick depths screwing up general canvas click, should use myDepth
		//var myMarker = this.TWFcanvas.attachMovie(MCLinkageID, "Tick" + fieldIDX + "-" + j, this.depth++, initObj);
		//myTrace("twf.setFieldTick at depth=" + this.myDepth);
		var myMarker = this.TWFcanvas.attachMovie(MCLinkageID, "Tick" + fieldIDX + "-" + j, this.myDepth++, initObj);
		//myTrace("added tick=" + myMarker);
		// for some bizarre reason, I can set _x, _xscale in the initObj, but not _width or _height
		// v6.2 Allow the ability to display a non-stretched background
		if (props.stretch) {
			myMarker._width = thisCover._width; myMarker._height = thisCover._height;
		} else {
			// v6.2 and let the user set alignment (if not stretched)
			if (props.align == "right") {
				myMarker._x += thisCover._width - myMarker._width + props.offsetX;
			} else if (props.align == "center") {
				myMarker._x +=  props.offsetX + (thisCover._width - myMarker._width)/2;
			}
		}
	}
}
// and clear it
TextWithFieldsClass.prototype.clearFieldTick = function(fieldID) {
	var fieldIDX = TWF.lookupArrayItem(this.fields, fieldID, "id");
	if (fieldIDX >= 0) {
		// v6.4.2.7 Only ever put a tick on the 0 part of a field
		//for (var j=0; j<this.fields[fieldIDX].coords.length; j++) {
			var j=0;
			//myTrace("remove from field " + fieldID + " name=" + "FBack" + fieldIDX + "-" + j);
			this.TWFcanvas["Tick" + fieldIDX + "-" + j].removeMovieClip();
		//}
	}
}

// add a specialised function for letting you do a hittest on drop fields
TextWithFieldsClass.prototype.addDropsForHitTest = function() {
//	var startTime = new Date();
	//trace("for this twf add dropZones");
	for (var i in this.fields) {
		if (this.fields[i].type == "i:drop" || this.fields[i].type == "i:dropInsert") {
			//trace("add drop zone to list " + this.fields[i]);
			// v6.3.4 Add type to make it quick to check
			// v6.3.6 Merge exercise into main
			//_root.ExerciseHolder.dropZoneList.push({twf:this, 
			//v6.4.2 rootless
			_global.ORCHID.root.mainHolder.dropZoneList.push({twf:this, 
												   fieldID:this.fields[i].id, 
												   fieldType:this.fields[i].type,
												   cover:this.fields[i].coords[0].coverMC});
		}
	}
}

// 6.5.4.2 Yiu function for callback, ID 1223
// This function will clear the interval, which will free up any other TWF to process a ctrl-click
TextWithFieldsClass.prototype.controlKeyIntervalCallback= function(){
	clearInterval(_global.TWF.controlKeyTimeOutIntervalID);
	_global.TWF.controlKeyTimeOutIntervalID= 0;
}
// End 6.5.4.2 Yiu function for callback, ID 1223

// v6.2 Trying out ways to catch ctrl-click in the twf
// v6.3 You also have to figure out whether you are over a field (in which case ctrl-click
// might mean something different from being over a regular word).
// v6.4.2.7 Yes that above point is critical - but where is it happening? I do want to stop ctrl-click on gaps
// triggering this, for instance. Should be in addCoverFunctions which use mouseUpKey to signal that a cover caught the click.
TextWithFieldsClass.prototype.onMouseUp = function() {
	// v6.4.1 Since this triggers for every TWF, you end up clearing out the mouseUpKey
	// long before you hit the TWF it is intended for! So move this code into 
	// the conditional
	//myTrace("TWF:onMouseUp on TWF, already done key=" + this.mouseUpKey);
	//if (this.mouseUpKey != undefined) {
	//	this.mouseUpKey = undefined;
	//	return;
	//}
	// You only want to catch clicks if they are on you!
	// But this really does catch way too many TWFS!
	// v6.3.5 Including ones that are behind a scrollpane mask!
	// v6.4.2.7 And ones that are behind a PUW. No idea how to stop those from being caught.
	if (this.hitTest(_root._xmouse, _root._ymouse)) {
		// v6.4.1 Moved from above
		if (this.mouseUpKey != undefined) {
			//myTrace("TWF:onMouseUp on TWF, already done key=" + this.mouseUpKey);
			this.mouseUpKey = undefined;
			return;
		}
		//myTrace("TWF.onMouseUp on " + this);
		// v6.3.5 You want to ignore stuff that is behind the scrollpane mask
		// so get the current scrollpane yScroll and see if the y of the twf is less
		// (but reduce by 8 as you can still read a word whose twf._y is off the top
		//  by roughly this amount).
		// v6.3.5 Note you should also do this for the bottom, so check y < scroll + height
		// v6.4.2.7 But this is only caring about the top of the twf. What if the top has scrolled off screen 
		// but the bottom is still on the screen? OK. I can fix this by comparing against the bottom of the TWF
		// but what this will do is do double glossary if you click on a word in the title or scrollPane and there is some
		// word underneath it. What you should do is measure the relative y of the click within the twf, add that to the top
		// and see if that is more than the scrolled. OK, that is done.
		//myTrace("scrolled up=" + (this._parent._parent.getScrollPosition().y - 8));
		//myTrace("thisTwf up " + this._y + " mouse.y=" + this._ymouse + " text.height=" + this.holder._height);
		//if (this._y > (this._parent._parent.getScrollPosition().y - 8)) {

		// v6.5.4.2 1223 Yiu - popup windows like Recorder and Hint don't pick up ctrl-click, so text behind gets it
		// AR Rather than make these windows have TWF content, lets just ignore them. If you really want to do it
		// the solution is to put a proper TWF into the puw, not bodge it here.
		//var thisX	= 0;
		//var thisY	= 0;
		//var bIsButtonPopBox:Boolean;
		//bIsButtonPopBox	= this._parent._y >= 0;

		//if (bIsButtonPopBox){
		//	myTrace(this + " is a popup");
		//	thisX = this._xmouse + this._parent._x;	// v6.5.4.2 Yiu position should move when parent move, for hint button popbox, Bug ID 1223
		//	thisY = this._ymouse + this._parent._y;	// v6.5.4.2 Yiu position should move when parent move, for hint button popbox, Bug ID 1223
		//} else {	// It must be scrolled
		//	myTrace(this + " is not");
			thisX	= this._xmouse;
			thisY	= this._ymouse;
		//}

		// var thisX = this._xmouse; // v6.5.4.2 Yiu commented, Bug ID 1223
		// var thisY = this._ymouse; // v6.5.4.2 Yiu commented, Bug ID 1223

		//if ((this._y+this._ymouse) > (this._parent._parent.getScrollPosition().y - 8)) {	// v6.5.4.2 Yiu position should move when parent move, for hint button popbox, Bug ID 1223
		if ((this._y+thisY) > (this._parent._parent.getScrollPosition().y - 8)) {	        // v6.5.4.2 Yiu position should move when parent move, for hint button popbox, Bug ID 1223
			var obj = this.getBounds();
			//myTrace("coords are xMin=" + obj.xMin + ", ymin=" + obj.yMin + " - xMax=" + obj.xMax + ", yMax=" + obj.yMax);
			if (Key.isDown(Key.CONTROL)) {
				// v6.5.4.2 yiu prevent the dictionary run multiple times when you click the feedback box above the normal text, ID 1223
				// Do this first because even if this TWF doesn't have a ctrl-clicker, you don't want to pick up anything behind it
				if(_global.TWF.controlKeyTimeOutIntervalID != 0){
					return;  
				} else {
					// Set an interval so that you will not process any other ctrl-click whilst this is running.
					_global.TWF.controlKeyTimeOutIntervalID = setInterval(this, "controlKeyIntervalCallback", _global.TWF.controlKeyTimeOutDuration);
				}
				// End v6.5.4.2 yiu prevent the dictionary run multiple times when you click the feedback box above the normal text
				// don't bother doing anything if this component doesn't have 
				// an event that needs to be triggered
				if (this.controlClick_param == undefined) {
					myTrace("no controlClicker for this TWF");
					return;
				}
				// v6.3.5 This doesn't work for countdown as you HAVEN'T counted lines yet.
				// But if you knew the caretIndex, you could easily find the word.
				// The only way to get that is through Selection and I can't see how that 
				// would work. So I think you will have to do a line count each time they click.
				// I don't like this way of seeing if I am in a countdown much
				if (this.cdReplaceChar != undefined) {
					// first you need to build a version of lines
					//myTrace("go and bLD");
					this.buildLineDetails();
					// then you can continue with normal processing
					// No you can't. Because normal processing does word finding on 
					// original rather than on holder. I have calculated word position
					// based on holder for countdown. Maybe you can change to holder
					// for normal glossary. But countdown holder will mostly be gaps
					// so you need to find the character index and look up the word in the
					// word list. Phew.
					// Make sure you use holder rather than original in all calculations
					// as it is very different.
					var useHolder = true;
				} else {
					var useHolder = false;
				}
					
				// first find out which line you clicked on. You already know
				// line heights so this is easy.
				var thisX = this._xmouse;
				var thisY = this._ymouse;
				//trace("x=" + thisX + " y=" + thisY);
				var i = this.lines.length;
				//myTrace("this twf has " + i + " lines");
				var firstChar = 0;
				while (i--) {
					//myTrace("lines[" + i + "].idx=" + this.lines[i].idx + " y=" + this.lines[i].y);
					if (this.lines[i].y < thisY) {
						firstChar = this.lines[i+1].idx;
						var lineNum = i+1;
						break;
					}
				}
				// if I am on the last line, then lastChar is maxLength
				// otherwise it is one before the next lines starting char
				if ((i+1) < this.lines.length-1) {
					var lastChar = this.lines[i+2].idx - 1;
				} else {
					var lastChar = this.maxLength;
				}
				// v6.3.5 Can this be done on holder or must it be original?
				// It seems that holder would be OK.
				//myTrace(thisX + " along holder=" + this.holder.text.substring(firstChar, lastChar));
				//myTrace(thisX + " along original=" + this.original.text.substring(firstChar, lastChar));
				if (useHolder) {
					var thisLine = new String(this.holder.text.substring(firstChar, lastChar));
				} else {
					var thisLine = new String(this.original.text.substring(firstChar, lastChar));
				}
				//myTrace(thisX + " along line=" + thisLine);
				
				// Now call a function that turns your x click into a character position
				// I don't want to use the existing width calc field as this might be going
				// on at the same time as field covers are being recalculated
				this.createTextField("anotherWidthCalc",this.myDepth++,0,0,4,4);
				this.anotherWidthCalc.html = false;
				this.anotherWidthCalc.border = false;
				this.anotherWidthCalc.wordWrap = false; // this will keep it on one line for measuring widths
				this.anotherWidthCalc.autoSize = true;
				this.anotherWidthCalc._visible = false; // can you hide it without effecting its value?
				// Note that fcP ONLY works on original
				if (useHolder) {
					var cursorIdx = this.findCursorPosition(this.anotherWidthCalc, firstChar, lastChar, thisX, useHolder) - firstChar;
				} else {
					var cursorIdx = this.findCursorPosition(this.anotherWidthCalc, firstChar, lastChar, thisX) - firstChar;
				}
				this.anotherWidthCalc.removeTextField();

				// For countdown hints, you now need to turn this idx into a total idx
				// and look up the real word in the list.
				// I don't like this way of seeing if I am in a countdown much
				// also check if this is a real word
				//myTrace("click " + cursorIdx + " character=" + thisLine.charCodeAt(cursorIdx) + " replaceChar=" + this.cdReplaceChar);
				// problem here - if the replace char is something like . then getWordEdges is going to ignore it
				var wordEdges = this.getWordEdges(thisLine, cursorIdx);
				var foundWord = thisLine.substring(wordEdges.start, wordEdges.end);
				if (this.cdReplaceChar == undefined || (foundWord.charAt(0) != this.cdReplaceChar)) {
					//myTrace("found real word=" + foundWord);
					var realWord = true;
				} else {
					//myTrace("unguessed word at cursor=" + cursorIdx + " + lineStart=" + this.lines[lineNum].idx + " wordStart=" + wordEdges.start);
					var realWord = undefined;
					var totalIdx = this.lines[lineNum].idx + wordEdges.start;
					for (var i=0; i<this.words.length; i++) {
						if (this.words[i].start <= totalIdx && totalIdx <= this.words[i].end) {
							foundWord = this.words[i].word;
							break;
						}
					}
					//myTrace("which gives word=" + foundWord);
				}
		
				// trigger the event with the found word as parameter
				var onControlClick = eval(this.controlClick_param);
				//myTrace("controlClick on " + thisLine.substring(wordEdges.start, wordEdges.end));
				onControlClick(foundWord, realWord);
			}
		} else {
			//myTrace("ignore mouseUp on " + this); // + " mc.height=" + this._height + " text.height=" + this.holder._height);
		}
	}
}
//}
// then hunt forwards and backwards to find the word ends
// v6.3.5 It would be good to not be fooled by apostrophes - they are not the end of the word
// The rule would be - if neither side of the quote mark is a punctutation character, it is
// an apostrophe.
TextWithFieldsClass.prototype.getWordEdges = function(words, idx) {
	//myTrace("twf.getWordEdges for " + word);
	var thisEdges = new Object();
	// first go forwards
	// See comment in findWordEdges about unicode characters
	var specialEndChar = "'" + String.fromCharCode(146); // could be apostrophe
	var wordEndChar = " ,.;:!?)}]>/%+=#@&*\~" 
						+ "÷»›¶´®™˜•‰‡†…‚" // characters from ascii table
						+ String.fromCharCode(160) // &nbsp;
						+ String.fromCharCode(9) // (tab)
						+ String.fromCharCode(34)+ String.fromCharCode(148) // double quotes
						+ String.fromCharCode(13) + String.fromCharCode(10); // (cr lf)
	var checkNextChar = false;
	//trace("start at " + words.charAt(idx));
	
	// v6.4.2.7 To stop an empty gap triggering the word before (which is what happens with ctrl-click after marking)
	// Lets assume that if this is a nsbp that we are not going to do any glossary. If it is a real nbsp, not just a gap
	// then too bad - they will just try clicking further left or right I guess.
	if (words.charCodeAt(idx) == 160) {
		thisEdges.start = 0;
		thisEdges.end = 0;
		return thisEdges;
	}
	
	// are you already above an end of word char?
	while ((wordEndChar.indexOf(words.charAt(idx)) >= 0) && (idx > 0)) {
		// if so, push the start point backwards
		idx--;
	}
	//myTrace("start from " + idx + " and go forward");
	for (var testIdx=idx; testIdx<=words.length; testIdx++) {
		//trace(words.charAt(testIdx));
		// is this an apostrophe? you can tell by looking at the next char
		if (specialEndChar.indexOf(words.charAt(testIdx)) >= 0) {
			//trace("extra check on [" + words.charAt(testIdx+1) + "]");
			if (wordEndChar.indexOf(words.charAt(testIdx+1)) >= 0) {
				// so char after the apostrophe is a word ending character
				// which means this is a quote not an apostrophe and we should
				// end here.
				// since you can have double punctuation - ¿'wouldn't I say?'
				// clicking on the first one means you still need to check that
				// this really is the start (just once should be enough though)
				if (wordEndChar.indexOf(words.charAt(testIdx-1)) >= 0) {
					testIdx--;
				} 
				thisEdges.end = testIdx;
				break;
			} else {
				// the next char isn't a word ending one, so keep going
				// from the next char
				testIdx++;
			}
		} else {
			if (wordEndChar.indexOf(words.charAt(testIdx)) >= 0) {
				// since you can have double punctuation - ¿'wouldn't I say?'
				// clicking on the first one means you still need to check that
				// this really is the start (just once should be enough though)
				if (wordEndChar.indexOf(words.charAt(testIdx-1)) >= 0) {
					testIdx--;
				} 
				thisEdges.end = testIdx;
				break;
			}
		}
	}
	//myTrace("ended up at " + thisEdges.end);
	// v6.4.2.7 Don't let it go negative (can happen if you click on a gap at the begging of a line)
	if (thisEdges.end == undefined) {
		thisEdges.end = words.length;
	} else if (thisEdges.end <0) {
		// so we couldn't find any real characters, so give up
		thisEdges.start = 0;
		thisEdges.end = 0;
		return thisEdges;
	}
	//myTrace("ended up at " + thisEdges.end);

	// then go backwards
	var wordStartChar = " ({[</$#@~\*" + String.fromCharCode(9) // (tab)
						+ "'" + String.fromCharCode(34) // straight quotes
						+ "¥¢£€¿¡„‹«©" // characters from ascii table
						+ String.fromCharCode(160) // &nbsp;
						+ String.fromCharCode(13) // (cr) v6.3.5
						+ String.fromCharCode(10) // (lf)
						+ String.fromCharCode(145) // curly single opening quote
						+ String.fromCharCode(34)+ String.fromCharCode(147) // double quotes
						+ String.fromCharCode(13) + String.fromCharCode(10); // (cr lf)
	testIdx = idx+1;
	//trace("go back");
	while(testIdx--) {
		//trace(words.charAt(testIdx));
		// is this an apostrophe? you can tell by looking at the previous char
		if (specialEndChar.indexOf(words.charAt(testIdx)) >= 0) {
			//trace("extra check on [" + words.charAt(testIdx+1) + "]");
			if (wordStartChar.indexOf(words.charAt(testIdx-1)) >= 0) {
				// so char before the apostrophe is a word starting character
				// which means this is a quote not an apostrophe and we should
				// start here.
				// since you can have double punctuation - ¿'wouldn't I say?'
				// clicking on the first one means you still need to check that
				// this really is the start (just once should be enough though)
				if (wordStartChar.indexOf(words.charAt(testIdx+1)) >= 0) {
					testIdx++;
				} 
				thisEdges.start = testIdx+1;
				break;
			} else {
				// the next char isn't a word ending one, so keep going
				// from the next char
				testIdx--;
			}
		} else {
			if (wordStartChar.indexOf(words.charAt(testIdx)) >= 0) {
				// since you can have double punctuation - ¿'wouldn't I say?'
				// clicking on the first one means you still need to check that
				// this really is the start (just once should be enough though)
				if (wordStartChar.indexOf(words.charAt(testIdx+1)) >= 0) {
					testIdx++;
				} 
				thisEdges.start = testIdx+1;
				break;
			}
		}
	}
	//myTrace("started up at " + thisEdges.start);
	if (thisEdges.start == undefined) thisEdges.start = 0;
	//myTrace("started up at " + thisEdges.start);
	//myTrace("last charCode=" + words.charCodeAt(thisEdges.end-1));
	return thisEdges;
}

// This method will find which character in a string is at the cursor position.
TextWithFieldsClass.prototype.findCursorPosition = function(target_txt, start, end, cursorX, useHolder) {
	//myTrace("twf.findCursorPosition with " + target_txt);
	// if start and end are not specified, take the whole string
	// if the target is not a textField, give up!
	if (target_txt instanceof TextField) {
		target_txt.text = "";
		var thisTF = new TextFormat();
		var thisChar = "";
		// v6.3.5 Countdown uses holder rather than original. Maybe everything could
		// but I am not sure.
		if (useHolder) {
			var myString = new String(this.holder.text);
		} else {
			var myString = new String(this.original.text);
		}
		//trace("copy " + myString.substring(start, end));
		if (end == undefined) {
			end = this.length;
		}
		if (start < 0) start = 0;
		for (var i=start;i<end; i++) {
			// what is the next character to add and what is it's format?
			if (useHolder) {
				thisTF = this.holder.getTextFormat(i);
			} else {
				thisTF = this.original.getTextFormat(i);
			}
			thisChar = myString.charAt(i);
			// we want to find out about the character we are about to add
			target_txt.setNewTextFormat(thisTF);
			// add the character to the holding textField (a time consuming process)
			// but this is the only way to do it without losing earlier formatting
			//Selection.setSelection(i);
			target_txt.replaceSel(thisChar);
			// now measure the width of what we have so far
			//trace("width=" + (target_txt._width-4) + " of " + target_txt.text);
			if ((target_txt._width-4) > cursorX) {
				// we have gone past, so return the index
				return i;
			}
		}
		return end; // if you haven't found it, it must be beyond the end
	}
}
// method to set the gap splitting property - default is off
TextWithFieldsClass.prototype.setSplitGaps = function(splitGaps) {
	//myTrace("splitGaps twf = " + splitGaps);
	this.splitGaps = splitGaps;
}
// used for debugging (especially when clashes of components in different swfs).
TextWithFieldsClass.prototype.getVersion = function() {
	return this._version;
}
// v6.3.5 New set of methods to deal with TWF used in CountDown exercise
TextWithFieldsClass.prototype.setCountDownText = function(myText, textFormat) {
	
	//myTrace("setCountDownText to " + myText);	
	// put the text that you are sent into the original field for comparison
	this.original.setHtmlText(myText, textFormat);
	this.holder.html = true;
	this.holder.text = "";
	this.original._visible = false;
	
	// What character will you replace letters with? 
	// This might have been passed in settings.
	if (this.cdReplaceChar == undefined) {
		this.cdReplaceChar = "_";
	}
	
	// Next find the details of all non-avoided words in this twf.
	// This will put the original text into the holder, with correct formatting
	this.findWordEdges();

	// Now go through the text, replacing anything marked as a word
	// with underlined spaces.
	//myTrace("now replace the words");
	// have the line breaks disappeared?
	//for (var i=0; i<this.holder.text.length; i++) {
	//	if (this.holder.text.charCodeAt(i) == 13) {
	//		myTrace("after fWE, ENTER at i=" + i);
	//	}
	//}
	Selection.setFocus(this.holder);
	var delta=0; var thisDiff=0;
	for (var i=0; i< this.words.length; i++) {
		// at this point what you should edit in the array start and end 
		// depends on what you are replacing the word with. If you are going
		// to do something that doesn't use the same number of chars, then the
		// start and end should reflect the NEW start and end after replacement
		// Thus if you are going to fill with spaces, now is the time to measure
		// the width of the word and calculate the new end point
		// so what are the current char positions of this word in the text?
		// it will be the original positions moved by whatever has gone before
		this.words[i].start += delta;
		this.words[i].end += delta;
		//myTrace("word " + i + " delta=" + delta + " .start=" + this.words[i].start + " .end=" + this.words[i].end);
		wordEnd = this.words[i].end;
		//if ((this.cdReplaceChar == " ") || this.cdSameLengthGaps > 0) {
		if (this.cdSameLengthGaps > 0) {
			// do what you need to measure/replace the word
			// delta will get more pronounced with each replaced word
			// so how will this word replacement effect anything?
			thisDiff = this.cdSameLengthGaps - this.words[i].end + this.words[i].start;
			// so shift the end of this word
			this.words[i].end += thisDiff;
			delta += thisDiff;
			//myTrace("after [" + this.words[i].word + "].delta=" + delta);
		}
		Selection.setSelection(this.words[i].start, wordEnd);
		var numChars = this.words[i].end - this.words[i].start;
		this.holder.replaceSel(new Array(++numChars).join(this.cdReplaceChar));
	}
	// Since you will need it for control-clicking, create another field
	this.createTextField("cdHolder",this.myDepth++,0,0,this.holder._width,10);
	this.cdHolder.border = this.border_param;
	this.cdHolder.background = false;
	this.cdHolder.wordWrap = true;
	this.cdHolder.multiline = true;
	this.cdHolder.embedFonts = false;
	this.cdHolder.selectable = false; // there is no copy of text at present
	this.cdHolder.autoSize = this.autoSize_param;
	this.cdHolder._visible = false;
//	this.cdHolder._width = ;
	//myTrace("cdHolder.width=" + this.cdHolder._width);
}
// v6.3.5 This function needs to be called before setCountDown text
// if you plan on using the replaceChar setting
TextWithFieldsClass.prototype.setCountDownSettings = function(settings) {
	//myTrace("set countDownSettings");
	this.cdMatchCapitals = settings.matchCapitals;
	this.cdSameLengthGaps = Number(settings.sameLengthGaps);
	if (settings.replaceChar != undefined) {
		// maybe you should put a limit on the number of characters here - 1 (at most 2?)
		this.cdReplaceChar = settings.replaceChar.substr(0,1);
	} else {
		this.cdReplaceChar = "_";
	}
}
TextWithFieldsClass.prototype.wordMatch = function(word1, word2) {
	// based on capitalisation (an exercise level setting) and any 
	// other rules, are these two words the same?
	if (this.cdMatchCapitals) {
		myWord1 = word1;
		myWord2 = word2;
	} else {
		myWord1 = word1.toLowerCase();
		myWord2 = word2.toLowerCase();
	}
	// treat curly and straight apostrophe as the same
	myWord1 = TWF.convertCurlyQuote(myWord1);
	myWord2 = TWF.convertCurlyQuote(myWord2);
	//myTrace("after curly convert, myWord1=" + myWord1);
	//
	if (myWord1 == myWord2) {
		return true;
	} else {
		return false;
	}
}
TextWithFieldsClass.prototype.guessCountDownWord = function(myWord) {
	// Does this twf contain this word? First loop through the word array
	// to see if it does. For each found instance, replace the underlined spaces
	// with the word (and rearrange the remaining start indexes in the array).
	// v6.4.3 What happens if you type a phrase? It must only match against the same phrase in the text
	// so if you type "I'm fine" as the guess, then you will not match against "fine today" or "I'm a doctor".
	// So, first split our guess into separate words. In the end this will need to worry about puncutation (?)
	var guessedWords = myWord.split(" ");
	
	Selection.setFocus(this.holder);
	var counter=0;
	var delta=0;
	for (var i=0; i<this.words.length; i++) {
		// v6.4.3 Match against the first word in our phrase
		//if (this.wordMatch(this.words[i].word, myWord)) {
		if (this.wordMatch(this.words[i].word, guessedWords[0])) {
			// OK this hit the first word, what about the next word?
			var matchedAll = true;
			if (guessedWords.length>1) {
				for (var k=1; k<guessedWords.length;k++) {
					// see if the next words keep matching the phrase
					if (this.wordMatch(this.words[i+k].word,guessedWords[k])) {
					} else {
						// something didn't match so scratch the whole lot
						matchedAll = false;
						break;
					}
				}
			}
			// We know that the phrase matched, so now display all the words
			if (matchedAll) {
				for (var k=0; k<guessedWords.length;k++) {
					this.words[i+k].guessed = true;
					Selection.setSelection(this.words[i+k].start, this.words[i+k].end);
					this.holder.replaceSel(this.words[i+k].word);
					// readjust char positions if necessary
					// since not many words will be guessed correctly, this loop should not
					// be too inefficent
					// delta does not get more pronounced through the loop as you propogate its
					// effect each time.
					delta = this.words[i+k].word.length - this.words[i+k].end + this.words[i+k].start;
					if (delta != 0) {
						this.words[i+k].end += delta;
						for (var j=i+k+1; j<this.words.length;j++) {
							this.words[j].start+=delta;
							this.words[j].end+=delta;
						}
					}
				}
				counter++;
				// v6.4.3 I should increase the counter 'i' if I have matched several words, but since this is 
				// not exactly going to happen much and will have no visible impact if I don't, I will leave
				// it for now.
			}
		}
	}
	// Return the number of instances found of the word.
	return counter;
}
TextWithFieldsClass.prototype.showFullText = function(missedTF, correctTF) {
	// Display the full text, using different formatting for the words
	// that you got right and the ones you missed
	Selection.setFocus(this.holder);
	var counter=0;
	var delta=0;
	var thisDiff=0;
	for (var i=0; i<this.words.length; i++) {
		if (!this.words[i].guessed) {
			Selection.setSelection(this.words[i].start+delta, this.words[i].end+delta);
			this.holder.replaceSel(this.words[i].word);
			thisDiff = this.words[i].word.length - this.words[i].end + this.words[i].start;
			if ((typeof missedTF) == "object") { // is there a better test to do?
				this.holder.setTextFormat(this.words[i].start+delta,this.words[i].end+delta+thisDiff, missedTF);
			}
			delta+=thisDiff;
		}
	}
	// do you need to do anything with selection to clear it out at the end?
	// avoiding any black flashes on the screen?
}
//
// Based on buildTextAndFields. First, simply find what the words are and where
// they start and stop
TextWithFieldsClass.prototype.findWordEdges = function() {
	//myTrace("twf.findWordEdges");
	//	var startTime = new Date();
	var thisTF = new TextFormat();
	// it is very much quicker to do substr type functions on a string copy of the text
	// rather than accessing it directly
	//trace(this.original.htmlText);
	var myString = new String(this.original.text);
	this.maxLength = myString.length;
	// words is an array that holds the string index of where each word starts
	// and its length (and value)
	this.words = new Array();

	var specialEdgeChar = "'" + String.fromCharCode(8217); // could be an apostrophe
	var wordEdgeChar = " ({[</$#@~\*" + String.fromCharCode(9) // (tab)
						+ " ,.;:!?)}]>%+=&" 
						+ "-" + String.fromCharCode(8212) // hyphens
						+ "'" + String.fromCharCode(34) // straight quotes
						+ "¥¢£€¿¡„‹«©" // characters from ascii table
						+ "÷»›¶´®™˜•‰‡†…‚" // characters from ascii table
						+ String.fromCharCode(160) // &nbsp;
						// v6.3.5 The characters in the xml are utf-8 format.
						// fromCharCode at charCodeAt are based on unicode points
						// so 145 to 148 are NOT quotes, but control characters
						//+ String.fromCharCode(145) + String.fromCharCode(146) // curly single quote
						//+ String.fromCharCode(147) + String.fromCharCode(148) // double quotes
						+ String.fromCharCode(8216) + String.fromCharCode(8217) // curly single quote
						+ String.fromCharCode(8220) + String.fromCharCode(8221) // double quotes
						+ String.fromCharCode(13) + String.fromCharCode(10); // (cr lf)

	// start not on a word
	var onWord = false;
	var skipApostrophe = false; var skipField = false;
	//var wordStart=0; var wordEnd=0;
	for (var i=0;i<this.maxLength; i++) {

		// what is the next character to add?
		thisChar = myString.charAt(i);
		thisTF = this.original.getTextFormat(i);
		//myTrace("testing " + thisChar + " code=" + myString.charCodeAt(i));		
		// v6.3.5 Bug. I was losing the char=13 from holder.text, so although it
		// looked OK on the screen, it was not OK from the line counting point of view.
		// If you replace the 13 with newline, it appears to work. Not sure why.
		if (myString.charCodeAt(i) == 13) {
			//myTrace("fWE: ENTER at idx=" + i);
			thisChar = newline;
		}
		// add it to the text (you will replace gaps later)
		this.holder.setNewTextFormat(thisTF);
		this.holder.replaceSel(thisChar);
	
		// whilst looking for a word, go forwards until you are not on an edge char
		// or over a field (words to avoid)
		if (!onWord) {
			if (wordEdgeChar.indexOf(thisChar) < 0) {
				// mark this as the start of a new word
				var thisWords = new Object();
				thisWords.start = i;
				//trace("wordEdge start at " + i);
				onWord = true;
				// but you will skip this word if any part of it is a field
				if (thisTF.url != "") {
					skipField = true;
					//myTrace("start word at " + i + " but it is " + thisTF.url);
				} else {
					skipField = false;
					//myTrace("start word at " + i + " and not a field");
				}
			}
		} else {
			// If any part of this word has been marked as a field, then do not
			// include it in the countDown
			if (thisTF.url != "") {
				//myTrace("stayed skipped as url=" + thisTF.url);
				skipField = true
			}
			if (wordEdgeChar.indexOf(thisChar) >= 0){
				skipApostrophe = false;
				// but is this an apostrophe? you can tell by looking at the next char
				if (specialEdgeChar.indexOf(thisChar) >= 0) {
					//trace("extra check on [" + words.charAt(testIdx+1) + "]");
					if (wordEdgeChar.indexOf(myString.charAt(i+1)) < 0) {
						// the next character is not an edge, so this IS an apostrophe
						// so don't mark this as an end of word
						skipApostrophe = true;
					}
				}
				// you only write out a word that is really finished
				if (!skipApostrophe && !skipField) {
					//trace("wordEdge end at " + i);
					// so this is the end of the word, and the word is...
					thisWords.end = i;
					thisWords.word = myString.substring(thisWords.start, thisWords.end);
					this.words.push(thisWords);
				}
				// but fields still end the word edge finding bit - only apostrophe's dont'
				if (!skipApostrophe) {
					onWord = false;
				}
			}
		}
	}								
	// if you didn't get a word edge to finish with, then close up
	if (!skipApostrophe && !skipField) {
		if (thisWords.end == undefined) {
			thisWords.end = this.maxLength;
			thisWords.word = myString.substring(thisWords.start, thisWords.end);
			this.words.push(thisWords);
		}
	}
	// testing
	//for (var i in this.words) {
	//	myTrace("[" + this.words[i].word + "].start=" + this.words[i].start + " .end=" + this.words[i].end);
	//}
	//myTrace("end of findWordEdges, holder.text=" + this.holder.text);
}
// v6.3.5 Tell any one who cares which words are in your remit
TextWithFieldsClass.prototype.getWordList = function() {
	// is it worth building a new, simpler object, or just returning the whole
	// thing that I have built up internally?
	var wordList = new Array();
	for (var i in this.words) {
		// v6.4.2.7 I don't want to add anything that isn't a real word
		if (this.words[i].word == "" || this.words[i].word == null || this.words[i].word == undefined) {
			//myTrace("ignore " + this.words[i].word);
		} else {
			// v6.4.2.7 Try just sending back simple words, not objects as I don't need guessed. NO
			wordList.push({word:this.words[i].word, guessed:this.words[i].guessed});
			//wordList.push(this.words[i].word);
			//myTrace("save " + this.words[i].word);
		}
	}
	//myTrace("this list length " + wordList.length);
	return wordList;
}
// v6.3.5 A buildTextAndFields clone for use with control-click in countdown
// It is based on holder as this contains the blanks plus guessed words.
// It uses cdHolder for measuring. It also uses lines
// as this will not have been built for a countdown in any other way.
TextWithFieldsClass.prototype.buildLineDetails = function() {
	//myTrace("in bLD");
	var thisTF = new TextFormat();
	thisTF = this.holder.getTextFormat();
	//myTrace("start bld this.holder.text=" + this.holder.text);

	// initialise variables and set up starting values
	// these are the characters that you can word wrap at, we will search for them later
	// v6.3.4 Do you also need to break at underscores (95) for long gaps?
	// No, they are not in the gap, but &nbsp; comes as character code 160!
	// So that means that you want to break at 160, but the native textField doesn't want
	// to so as you are adding characters it will try hard to group all the &nbsp together and 
	// ruin the counting as things get out of sync. Can I add in a simple little real space
	// if I find a nbsp triggered line break? Yes, it appears so. (search 'wafer')
	// v6.3.5 This is not really successful, you keep getting the spaces added every other char,
	// sometimes.
	var lineBreakChars = String.fromCharCode(32,9,45);
	var lastLineBreakChar = -1;
	// it is very much quicker to do substr type functions on a string copy of the text
	// rather than accessing it directly
	//trace(this.original.htmlText);
	var myString = new String(this.holder.text);
	//myTrace("holder.text=" + myString);
	this.maxLength = myString.length;
	// lines is an array that holds the string index of where the lines break in the
	// current word wrapping scheme
	this.lines = new Array();
	// other variables used in looping and building
	var linesIdx = 0;
	var oldTextHeight = 0;

	this.cdHolder.text = "";
	//trace("set holder to empty, height=" + this.holder._height);
	// this variable holds consecutive newlines, you will probably only ever get two
	// but this seems extensible
	var foundNewLine = new Array();
	
	// loop adding each character in turn to the new textField. You can measure the height
	// change and compare it against the height of the added character. If the textField 
	// increases in height by more than this character height it means that word wrapping has just 
	// happened. So go back to the character that it happened at the record the place.
	// You can also record the line heights to get the y coordinate of each line.
	for (var i=0;i<this.maxLength; i++) {
		// what is the next character to add?
		thisChar = myString.charAt(i);
		//myTrace("add [" + thisChar + "] code=" + thisChar.charCodeAt(0));
		// and what is its format?
		thisTF = this.holder.getTextFormat(i);
		this.cdHolder.setNewTextFormat(thisTF);
	
		// should we record its index as the most recent word-wrapping character?
		if (lineBreakChars.indexOf(thisChar) >= 0) {
			lastLineBreakChar = i;
		}
		// Should we record it as a newline character?
		// And if we do, there is no point measuring its height and width, just leave
		// it to be picked up from the last char
		if (thisChar.charCodeAt(0) == 13) {
			//trace("added a newline");
			foundNewLine.push(true);
		} else {
			// we are now going to compare this character's height to others in the line
			// and look at how the textField changes in height when you add it
			thisCharDimension = thisTF.getTextExtent(thisChar);
			//thisCharHeight = thisCharDimension.height;
			thisCharHeight = thisCharDimension.height/this.textExtentCorrector;
			thisCharWidth = thisCharDimension.width/this.textExtentCorrector;
		}
		
		// we want to find out about the character we are about to add so
		// add the character to the holding textField (a time consuming process)
		// but this is the only way to do it without losing earlier formatting
		// Note: according to ASDG2 (page 860) if the textField does NOT have the focus
		// the characters from replaceSel should be added before the first character, but
		// as far as I can see they are added at the end.
		//Selection.setSelection(i);
		this.cdHolder.replaceSel(thisChar);
		thisTextHeight = this.cdHolder.textHeight;
		
		// Note: I really don't understand, but sometimes when you add a tab
		// character it can throw you to the next line, even though the next
		// character might bring you back up again. So if this happens, try
		// to just get rid of the last line that you thought you had found.
		if (thisTextHeight < oldTextHeight) {
			//trace("something is causing TWF to fluctuate in height");
			oldTextHeight = thisTextHeight;
			// what else have you done - for instance in moving a field that was
			// split by this false line break?
			this.lines.pop();
		}
		// does the textField height change?
		if ((thisTextHeight - oldTextHeight) > 0 ) {
			//myTrace(thisChar + ": line +" + (thisTextHeight - oldTextHeight) + " char+" + thisCharHeight + " oldTextHeight=" + oldTextHeight + " textHeight=" + thisTextHeight);
			// yes, and does it change by more than the height of this character?
			if ((thisTextHeight - oldTextHeight) >= thisCharHeight) {
				// that means we word wrapped to a new line
				// OR that we were forced by the character AFTER a newline character
				if (foundNewLine.length>0) {
					linesIdx = this.lines.push({idx:i, y:thisTextHeight});
					foundNewLine.pop();
				} else {
					//myTrace("new line after llBC=" + lastLineBreakChar);
					// the first character is a special case, so if it is a llbc, then ignore it
					if (i==0) lastLineBreakChar = -1;
					// so save the last recorded word-wrapping char as the place that it broke
					linesIdx = this.lines.push({idx:lastLineBreakChar+1, y:thisTextHeight})
					//myTrace("so push line at " + Number(lastLineBreakChar+1));
				}

				// and update the final text height of the previous line
				if (linesIdx>1) { // the first line is a special case
					//trace("update line " + Number(linesIdx-2) + " to height=" + oldTextHeight);
					this.lines[linesIdx-2].y = oldTextHeight;
				}
			}
			// save the new height of the textField
			oldTextHeight = thisTextHeight;
		}
		//trace("after " + thisChar + " line width=" + lineWidthSoFar);
	
	}
	
	// you need to save this for use in measureFields
	this.lastTF = thisTF;
	//for (var i in this.lines) {
	//	myTrace("line " + i + " starts at char " + this.lines[i].idx + " at y=" + this.lines[i].y);
	//}
	// v6.2 change all the natural line breaks into forced ones
	//trace("before forcing line breaks, height=" + this.holder._height);
	//this.showLineBreaks();
	//Selection.setFocus(this.cdHolder);
	//for (var i in this.lines) {
	//	if (this.lines[i].idx > 0) {
	//		Selection.setSelection(this.lines[i].idx-1,this.lines[i].idx);
	//		this.cdHolder.replaceSel(newline);
	//	}
	//}
//	trace("after forcing line breaks, height=" + this.holder._height);
	// Not a good idea to leave the focus on the holder, so set it back to original
	Selection.setFocus(this.original);
	//trace("full text=[" + this.holder.text + "]");
}
// v6.4.2.8 Can you add a background to the whole TWF?
// Add a particular MC BEHIND the field (using the canvas to achieve this);
TextWithFieldsClass.prototype.setBackground = function(MCLinkageID, props) {
	//myTrace("twf.setBackground to " + MCLinkageID + " width=" + this._width + " height=" + this.componentHeight);
	if (props == undefined) props={stretch:true, oneLine:true};
	// If the TWF contains no fields, there will be no canvas so you need to create one
	if (this.TWFcanvas == undefined ){
		var myCanvas = this.createEmptyMovieClip("TWFcanvas", this.myDepth++);
	}
	var myMarker = this.TWFcanvas.attachMovie(MCLinkageID, "TWFBackdrop", this.myDepth++);
	//myTrace("created " + myMarker);
	if (props.stretch) {
		myMarker._width = this._width; myMarker._height = this.componentHeight;
	} else {
		// v6.2 and let the user set alignment (if not stretched)
		if (props.align == "right") {
			myMarker._x += this._width - myMarker._width + props.offsetX;
		} else if (props.align == "center") {
			myMarker._x +=  props.offsetX + (this._width - myMarker._width)/2;
		}
	}
}
