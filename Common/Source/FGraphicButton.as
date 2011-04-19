#initclip
function GraphicButtonClass() {
	this.init();
}
// inherit from MovieClip
GraphicButtonClass.prototype = new MovieClip();

// initialise
GraphicButtonClass.prototype.init = function() {
	//trace("setting up a graphic button");
	// the default target
	this.defaultTarget = "GTC_BoundingBox";
	
	// anti-distortion
	this.boundingBox_mc._visible = false;
	this.componentWidth = this._width;
	this.componentHeight = this._height;
	this._xscale = this._yscale = 100;

	// try to set good default tab behaviour
	this.tabChildren = false;
	this.tabEnabled = true;

	// set the target if it is different from design time
	if (this.target_param != this.defaultTarget) {
		//trace("setting target to " + this.target_param);
		this.setTarget(this.target_param);
	}
	
	// make the mc behave like a button
	this.setAction();
	this.componentEnabled = true;
	
	// initial caption (in case one is not set by the code)
	if (this.caption_param != "") {
		this.setLabel(this.caption_param);
	}
	// v6.5 Mac problem
	if (System.capabilities.os.toLowerCase().indexOf("mac")==0) {
		this.textExtentCorrector = 20; // What is this value? web seems to suggest twips, but it is not truly accurate
	} else {
		this.textExtentCorrector = 1;
	}
	
	// v6.5.4.3 It will be useful to keep the caption width after measuring it
	this.measuredCaptionWidth=0;
	// v6.5.4.3 To allow caption alignment - pick up from .fla
	this.originalCaptionWidth=0;
	this.originalCaptionHeight=0;
	this.originalCaptionY=0;

}
// attach the required mc to this "button"
GraphicButtonClass.prototype.setTarget = function(myTarget) {
	//trace("attach " + myTarget + " to button");
	this.attachMovie(myTarget, "target", 0);
	//v6.4.1 Might need to know about original size
	this.originalWidth = this.target._width;
	//v6.4.1 Now, if you setEnable to false, it appears to 0 the height for the future?!
	this.target._xscale=100;
	this.target._yscale=100;
	
	// v6.5.4.3 To allow caption alignment - pick up from .fla
	this.originalCaptionWidth=this.target.caption._width;
	this.originalCaptionHeight=this.target.caption._height;
	this.originalCaptionY=this.target.caption._y;
	//myTrace("setTarget, caption width=" + this.originalCaptionWidth + " height=" + this.originalCaptionHeight);
}
// v6.3.6 How about if this is an external mc, not in the library?
GraphicButtonClass.prototype.setExternalTarget = function(myTarget) {
	var thisMC = this.createEmptyMovieClip("target", 0);
	//myTrace("attach myTarget to " + thisMC);
	thisMC.loadMovie(myTarget);
}
// the size is really the target size, can't use _width and _height
GraphicButtonClass.prototype.getSize = function() {
	//trace("attach " + myTarget + " to button");
	//myTrace("button.width=" + this.target._width + " button.height=" + this.target._height);
	return {width:this.target._width, height:this.target._height};
}
// set what happens when enabled or disabled
GraphicButtonClass.prototype.setEnabled = function(enabled) {
	if (enabled) {
		this.target.gotoAndStop("up");
		// it is possible that setting to disabled will have lost the label
		// in which case setting to enabled should restore it.
		if (this.componentLabel != undefined) {
			this.setLabel(this.componentLabel, this.componentTF);
		}
		this.setAction();
		if ((typeof this.componentRelease) == "function") {
			//trace("use the saved release action");
			this.setReleaseAction(this.componentRelease);
		}
	} else {
		this.target.gotoAndStop("disabled");
		this.disableAction();
	}
	this.componentEnabled = enabled;
}

// v6.5.1 Yiu
GraphicButtonClass.prototype.setVisible	= function(visible)
{
	this.target._visible	= visible;
}

GraphicButtonClass.prototype.setAction = function() {
	this.onRollOver = function() {
		//myTrace("gb:roll over");
		this.target.gotoAndStop("over");
		this.target.caption.text = this.componentLabel;
		this.onPress = function() {
			this.target.gotoAndStop("down");
			this.target.caption.text = this.componentLabel;
			// v6.3.5 If the button is somehow involved in dragging you will
			// want to capture the press action (as well as doing graphic stuff)
			if ((typeof this.componentPress) == "function") {
				this.componentPress();
			}
		}
		this.onMouseUp = function() {
			//trace("mouse up");
			//this.target.gotoAndStop("over");
			this.target.gotoAndStop("up");
			this.target.caption.text = this.componentLabel;
		}
		this.onDragOut = function() {
			//delete this.onMouseUp;
			this.target.gotoAndStop("up");
			this.target.caption.text = this.componentLabel;
			delete this.onMouseUp;
		}
		this.onDragOver = function() {
			this.target.gotoAndStop("down");
			this.target.caption.text = this.componentLabel;
			// reestablish mouse up
			this.onMouseUp = function() {
				//trace("mouse up");
				this.target.gotoAndStop("over");
				this.target.caption.text = this.componentLabel;
			}
		}
		this.onRollOut = function() {
			this.target.gotoAndStop("up");
			this.target.caption.text = this.componentLabel;
			//myTrace("caption still=" +  this.target.caption.text + " multiLine=" + this.target.caption.multiline);
			delete this.onDragOut;
			delete this.onDragOver;
			delete this.onMouseUp;
			delete this.onPress;
		}
	}
}
GraphicButtonClass.prototype.disableAction = function() {
	//trace("deleting rollOver");
	delete this.onRollOver;
	delete this.onRollOut;
	delete this.onPress;
	delete this.onRelease;
	delete this.onMouseUp;
}
// ======
// Public functions for button behaviour
// ======
GraphicButtonClass.prototype.setReleaseAction = function(myFunc) {
	//trace("setting onRelease for " + this);
	this.componentRelease = myFunc;
	this.onRelease = function() {
		//this.target.gotoAndStop("over");
		//this.componentRelease();
		// Can I pass a reference to myself?
		this.componentRelease(this);
	};
}
GraphicButtonClass.prototype.setPressAction = function(myFunc) {
	//trace("setting onRelease for " + this);
	this.componentPress = myFunc;
	this.setAction();
}
// label functions
GraphicButtonClass.prototype.setLabel = function(labelText, labelTextFormat) {
	//myTrace("setting label to " + labelText + " multiline=" + this.target.caption.multiline);
	// v6.4.1 How about skipping the label setting for a disabled button?
	// No, I might still want to see and change the label
	this.componentLabel = labelText;
	this.target.caption.text = this.componentLabel;
	// v6.5.5.2 Maybe this should be the other way round. First see if you pass a TF and use that. Otherwise use the one from the screen component.
	// Problem is that if you have a different TF in up and disabled, i seem to lose disabled format. Sometimes.
	if (labelTextFormat instanceof TextFormat) {
		var thisTF = labelTextFormat;
		//myTrace("use passed.TF, align=" + thisTF.align + ", font=" + thisTF.font + ", bold=" + thisTF.bold);
	//} else if (this.componentTF instanceof TextFormat) {
	//	var thisTF = this.componentTF;
	//	myTrace("use component.TF, align=" + thisTF.align + ", font=" + thisTF.font + ", bold=" + thisTF.bold);
	} else {
		// v6.4.2.8 Not being picked up?
		//this.componentTF = this.target.caption.getTextFormat();
		this.componentTF = this.target.caption.getTextFormat(0);
		//this.componentTF = this.target.caption.getNewTextFormat();
		var thisTF = this.componentTF;
		//myTrace("use " + this.componentLabel + "'s TF, align=" + thisTF.align + ", font=" + thisTF.font + ", size=" + thisTF.size);
	}
	this.target.caption.setTextFormat(thisTF);
	//} else {
	//	var labelTextFormat = new TextFormat();
	//	labelTextFormat.align = "center";
	//	labelTextFormat.font = "Verdana,Helvetica,_sans";
	//	labelTextFormat.size=10;
	// v6.3.5 What about giving the possibility of changing the button
	// width? Different targets might not support it of course, and if
	// autosize is on, no need to bother. Also, only do it for single line captions.
	//myTrace("button label " + labelText + " width=" + thisTF.getTextExtent(labelText).width);
	// v6.4.1 Note that if you stretch the target, the target.caption._width does NOT change
	// so try using textWidth
	// v6.4.2.7 Increase the margin (especially for SSS)
	//var textMargin = 12;
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sss") >= 0) {
		var textMargin = 24;
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) {
		var textMargin = 18;
	} else {
		var textMargin = 20;
	}
	// v6.4.2.7 You have to distrust getTextExtent if you have a dynamic text field, espeically with Verdana. (15%?)
	// It might work better if you always left align before measuring
	//thisTF.align = "left";
	// v6.5 Mac gets this very wrong. It might be better to use textWidth on a calculator textField, but try this first
	//var measuredCaptionWidth = (thisTF.getTextExtent(labelText).width * 1.12) + textMargin;
	var thisCaptionDimensions = thisTF.getTextExtent(labelText);
	thisCaptionWidth = thisCaptionDimensions.width/this.textExtentCorrector;
	//myTrace("caption width=" + thisCaptionDimensions.width + " height=" + thisCaptionDimensions.height);
	this.measuredCaptionWidth = (thisCaptionWidth * 1.12) + textMargin;
	//if ((thisTF.getTextExtent(labelText).width > (this.target.caption._width - textMargin)) &&
	//if ((measuredCaptionWidth > this.target.caption._width) &&
	// What about shrinking to short text? Only if allowed, of course!
	// I am putting canShrink into the target button MC. Only doing it for halfBtn right now.
	// But note that it doesn't get picked up correctly for buttons that are added to popup window. Too quick?
	//if ((measuredCaptionWidth > this.originalWidth) &&
	if (this.target.canShrink) {
		//myTrace("can shrink " + labelText + " w=" + measuredCaptionWidth + "original=" + this.originalWidth);
	} else {
		//myTrace("no shrink " + labelText + " w=" + measuredCaptionWidth + "original=" + this.originalWidth);
	}
	if (((this.measuredCaptionWidth > this.originalWidth) || this.target.canShrink) &&
		(this.target.caption.multiline == false)){
		//myTrace(labelText + "=" + measuredCaptionWidth + " caption.width=" + this.target.caption._width);
		// the following function is NOT picked up if put in scripts layer of button mc.
		// Why not?
		//myTrace("call " + this.target.stretchMe);
		//this.target.stretchMe(thisTF.getTextExtent(labelText).width);
		// Just stretch it here then, this doesn't do any checking of max width
		// for rogue editing of literals.xml
		// v6.4.2.7 Tb had autosize which stopped this line working. Also keep the width a whole number - just neater
		// v6.4.2.8 If you call this twice the caption width will have changed, to it cannot work.
		//var extraSpace = this.originalWidth - this.target.caption._width; // original margins
		var extraSpace = 0;
		//myTrace("extraSpace=" + extraSpace);
		// v6.4.2.8 Fancy buttons might have a left, centre and right sections to make the stretching perfect
		//var targetWidth = Math.ceil(thisTF.getTextExtent(labelText).width + textMargin + extraSpace);
		//var targetWidth = Math.ceil(measuredCaptionWidth + textMargin + extraSpace);
		var targetWidth = Math.ceil(this.measuredCaptionWidth + extraSpace);
		//var targetWidth = Math.ceil(measuredCaptionWidth + textMargin);
		//myTrace(labelText + " targetWidth=" + targetWidth);
		if (this.target.leftSection == undefined) {
			this.target._width = targetWidth;
		} else {
			//myTrace("button has sections, left.width=" + this.target.leftSection._width);
			this.target.leftSection._x = 0;
			this.target.centreSection._x = Math.floor(this.target.leftSection._width);
			//myTrace(labelText + " left.w=" + this.target.leftSection._width + " right.w=" + this.target.rightSection._width);
			this.target.centreSection._width = targetWidth - (this.target.leftSection._width + this.target.rightSection._width);
			//myTrace(labelText + " target.w=" + targetWidth + " centre.w" + this.target.centreSection._width);
			//myTrace("centre.width=" + this.target.centreSection._width);
			this.target.rightSection._x = Math.floor(this.target.centreSection._x + this.target.centreSection._width);
			//myTrace(labelText + " centre.x=" + this.target.centreSection._x + " right.x=" + this.target.rightSection._x);
			this.target.caption._width = this.measuredCaptionWidth;
			// v6.4.2.8 And this one for when you are stretching the centre section only
			//this.target.centreSection._xscale = 100;
			//this.target.leftSection._xscale = 100;
			//this.target.rightSection._xscale = 100;
			this.target.caption._xscale = 100;
			this.target._xscale = 100;
			// Having done this, you might need to reset the stretch coordinates for the initial display
			// (this is a function in the .fla that moves the graphics over the sections I positioned above)
			this.target.resetStretch();
		}
		// v6.4.1 This line seems essential to stop height going to 0
		this.target._yscale = 100;
		//myTrace("so stretch button to target.width" + targetWidth + ", target.height=" + this.target._height);
		this.stretched = true;
		// this will also leave the buttons misaligned.
	} else {
		//v6.4.1 AND it didn't go down if the language is changed to a smaller one.
		//myTrace("original width=" + this.originalWidth + ", stretched=" + this.stretched);
		if (this.stretched) {
			// v6.4.1 OK, this line will screw up future button height IF you get a setEnabled false
			this.target._width = this.originalWidth;
			// v6.4.1 Add it here as well for safety sake
			this.target._yscale = 100;
			this.stretched = false;		
		}
		// v6.5 My countdown stats button is reporting target._width=0 at this point. Why?
		if (this.target._width <= 0) {
			this.target._width = this.originalWidth;
			// v6.4.1 Add it here as well for safety sake
			this.target._yscale = 100;
		}
		//myTrace(this + " target.height=" + this.target._height + " target.width=" + this.target._width + ", originalWidth=" + this.originalWidth);
	}
}
// alt-label functions
// will only work for special targets
GraphicButtonClass.prototype.setAlt = function(labelText, labelTextFormat) {
	//myTrace("setting label of " + this + " to " + labelText);
	this.componentAlt = labelText;
	//trace("setLabel of " + this.target + " is " + typeof this.target.setLabel);
	//trace("caption of " + this.target + " is " + typeof this.target.caption_txt);
	this.target.altText = this.componentAlt;
}

// label functions
GraphicButtonClass.prototype.setAutosize = function(enabled) {
	//myTrace("setting label of " + this + " to " + labelText);
	this.target.caption.autoSize = enabled;
}
// send back to caller
GraphicButtonClass.prototype.getEnabled = function() {
	return this.componentEnabled;
}
// v6.5.4.3 Vertical alignment of the caption - has to take place after the label is set
// This is called direct from within any button that wants to use it (currently ActiveReading unit names)
GraphicButtonClass.prototype.setCaptionVerticalAlign = function(alignment) {
	// If caption is single line, nothing to do
	//myTrace("button: multiline=" + this.target.caption.multiline + " autosize=" + this.target.caption.autoSize);
	if (this.target.caption.multiline == true) {
		// See if the caption fits onto one line, if yes, nothing to do.
		//myTrace( this.target.caption.text + " measured=" + this.measuredCaptionWidth + " width=" + this.originalCaptionWidth);
		if (this.measuredCaptionWidth > this.originalCaptionWidth) {
			// But if it doesn't, then we want to shift the caption up a bit so that it is centered where a single line is centered.
			//myTrace("measured=" + this.target.caption._height + " original=" + this.originalCaptionHeight);
			var thisShift = math.floor((this.target.caption._height - this.originalCaptionHeight)/2);
			//myTrace("v.align " +this.target.caption.text+ " by " + thisShift);
			this.target.caption._y = this.originalCaptionY - thisShift; 
		}
	}
}
//
// end of component
Object.registerClass("FGraphicButtonSymbol", GraphicButtonClass);
#endinitclip