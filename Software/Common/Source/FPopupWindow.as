#initclip

function PopupWindowClass() {
	this.init();
}
// inherit from MovieClip
PopupWindowClass.prototype = new MovieClip();

// initialise
PopupWindowClass.prototype.init = function() {
	this._version = "6.4.2.7";

	// v6.4.2.7 CUP update - allow branding, usually passed when component created
	if (this.branding == undefined) this.branding = "Clarity/AP";

	// create the rectangle drawing function (from ric ewing)
	this.drawRect = function(x, y, w, h, cornerRadius) {
		// ==============
		// mc.drawRect() - by Ric Ewing (ric@formequalsfunction.com) - version 1.1 - 4.7.2002
		// 
		// x, y = top left corner of rect
		// w = width of rect
		// h = height of rect
		// cornerRadius = [optional] radius of rounding for corners (defaults to 0)
		// ==============
		if (arguments.length<4) {
			return;
		}
		// Clarity - set a minimum to avoid drawing errors
		if (w < 10 || h < 10) {
			return;
		}
		// Clarity - try to start cleanly
		this.moveTo(0, 0);
		
		// if the user has defined cornerRadius our task is a bit more complex. :)
		if (cornerRadius>0) {
			// init vars
			var theta, angle, cx, cy, px, py;
			// make sure that w + h are larger than 2*cornerRadius
			if (cornerRadius>Math.min(w, h)/2) {
				cornerRadius = Math.min(w, h)/2;
			}
			// theta = 45 degrees in radians
			theta = Math.PI/4;
			// draw top line
			this.moveTo(x+cornerRadius, y);
			this.lineTo(x+w-cornerRadius, y);
			//angle is currently 90 degrees
			angle = -Math.PI/2;
			// draw tr corner in two parts
			cx = x+w-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			px = x+w-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
			py = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
			this.curveTo(cx, cy, px, py);
			angle += theta;
			cx = x+w-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			px = x+w-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
			py = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
			this.curveTo(cx, cy, px, py);
			// draw right line
			this.lineTo(x+w, y+h-cornerRadius);
			// draw br corner
			angle += theta;
			cx = x+w-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			cy = y+h-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			px = x+w-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
			py = y+h-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
			this.curveTo(cx, cy, px, py);
			angle += theta;
			cx = x+w-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			cy = y+h-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			px = x+w-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
			py = y+h-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
			this.curveTo(cx, cy, px, py);
			// draw bottom line
			this.lineTo(x+cornerRadius, y+h);
			// draw bl corner
			angle += theta;
			cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			cy = y+h-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			px = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
			py = y+h-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
			this.curveTo(cx, cy, px, py);
			angle += theta;
			cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			cy = y+h-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			px = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
			py = y+h-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
			this.curveTo(cx, cy, px, py);
			// draw left line
			this.lineTo(x, y+cornerRadius);
			// draw tl corner
			angle += theta;
			cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			px = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
			py = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
			this.curveTo(cx, cy, px, py);
			angle += theta;
			cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
			px = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
			py = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
			this.curveTo(cx, cy, px, py);
		} else {
			// cornerRadius was not defined or = 0. This makes it easy.
			this.moveTo(x, y);
			this.lineTo(x+w, y);
			this.lineTo(x+w, y+h);
			this.lineTo(x, y+h);
			this.lineTo(x, y);	
		}
		// clarity - tidy up?
		this.moveTo(0,0);
	}
	//trace("init for " + this);
	// drawing defaults - if not set by init properties sent to component
	// initial caption (in case one is not set by the code)
	// Note: I would imagine you would put all of this into an include
	// so that different programs can have different settings without
	// needing to come into the component each time
	//#include buttonsPW-APO.as;
	// or it could be some movie just in the base of APO that acts as a super class
	// to this (and any other of my components) - would that work?
	// v6.3.6 This is now done in setBrandStyles in styleProcessing.as
	//var mainColour = 0x08147B; // APL
	//var mainColour = 0x10494A; // RO
	//var lineColour = 0x0E24C0; // APL
	//var lineColour = 0xACB088; // RO
	var mainColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.tileColour;
	var lineColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.lineColour;
	var lineThickness = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.lineThickness;
	var fillColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.fillColour;
	var titleFontColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFontColour;
	
	if (this.canvasLineThickness == undefined) {
		this.canvasLineThickness = lineThickness;
	}
	if (this.canvasLineColour == undefined) {
		this.canvasLineColour = lineColour;
	}
	if (this.canvasFillColour == undefined) {
		this.canvasFillColour = mainColour;
	}
	if (this.canvasFillAlpha == undefined) {
		this.canvasFillAlpha = 100;
	}
	if (this.titleLineThickness == undefined) {
		// v6.5.5.8 Clear Pronunciation customisation
		if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0 ){
			this.titleLineThickness = 0;
		} else {
			this.titleLineThickness = lineThickness;
		}
	}
	if (this.titleLineColour == undefined) {
		// v6.5.5.8 Clear Pronunciation customisation
		if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
			//this.titleLineColour = 0x1B2728;
			this.titleLineColour = 0x1B0028;
		} else {
			this.titleLineColour =  mainColour;
		}
	}
	if (this.titleFillColour == undefined) {
		// v6.5.5.8 Clear Pronunciation customisation
		if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0){
			this.titleFillColour = 0x1B2728;
		} else if (this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			this.titleFillColour = 0x31376D; // This is the top of the PUW
			//this.titleFillColour = 0xFF0000;
		} else if (this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			this.titleFillColour = 0x886BE8;
		} else {
			this.titleFillColour = mainColour;
		}
	}
	if (this.titleFillAlpha == undefined) {
		this.titleFillAlpha = 100;
	}
	if (this.titleTF == undefined) {
		this.titleTF = new TextFormat();
		this.titleTF.font = "Verdana,Helvetica,_sans";
		this.titleTF.size=12;
		this.titleTF.bold=true;
		this.titleTF.color=titleFontColour;
	}
	if (this.contentLineThickness == undefined) {
		this.contentLineThickness = lineThickness;
	}
	if (this.contentLineColour == undefined) {
		this.contentLineColour = lineColour;
	}
	if (this.contentFillColour == undefined) {
		this.contentFillColour = fillColour;
	}
	if (this.contentFillAlpha == undefined) {
		this.contentFillAlpha = 100;
	}
	if (this.radius == undefined) {
		if (this.branding.indexOf("CUP/GIU") >= 0) {
			this.radius = 16; // default radius for corners
		// v6.5.5.8 Clear Pronunciation customisation
		// v6.5.6.4 New SSS
		} else if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0 || 
			this.branding.toLowerCase().indexOf("clarity/cp2") >= 0 ||
			this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			this.radius = 0; // default radius for corners
		} else {
			this.radius = 10; // default radius for corners
		}
	}
	if (this.borderSpacer == undefined) {
		// v6.4.2.7 Build the window based on branding
		//if (this.branding.indexOf("CUP/GIU") >= 0) {
		//	this.borderSpacer = 10; 
		//} else {
		// v6.5.6.4 New SSS
		if (this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			this.borderSpacer = 4; 
		// v6.5.5.8 Clear Pronunciation customisation
		} else if (this.radius<10) {
			this.borderSpacer = 8; 
		} else {
			this.borderSpacer = this.radius / 2; 
		}
	}
	// default content format
	var thisTF = new TextFormat();
	thisTF.font = "Verdana,Helvetica,_sans";
	thisTF.size = 12;
	
	// layout defaults
	// v6.5.6.4 New SSS
	if (this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		this.titleMinHeight = 36;
		// v6.5.5.8 Clear Pronunciation customisation
	} else if (this.radius<10) {
		this.titleMinHeight = 36;
	} else {
		this.titleMinHeight = this.radius * 2;
	}
	this.hasTitle = false;
	this.hasCloseButton = false;
	this.hasResizeButton = false;
	this.hasContentBorder = true;
	this.hasSeparator = false;
	// these can be overridden by using setMax and setMin
	this.minWidth = 40;
	this.minHeight = 40;
	this.maxWidth = 700;
	this.maxHeight = 500
	
	// anti-distortion
	this.boundingBox_mc._visible = false;
	this.myWidth = this._width;
	this.myHeight = this._height;
	this._xscale = this._yscale = 100;

	// start the depth count
	this.depth = 0;

	// v6.4.2.7 Build the window based on branding
	if (this.branding.indexOf("CUP/GIU") >= 0) {
		this.attachMovie("dragPaneBackground", "canvas", this.depth++);
		this.attachMovie("dragPaneTitleArea", "title", this.depth++); // this already includes the title_txt textField
		//this.attachMovie("dragPaneSpace", "content", this.depth++);
		// create the content holder
		this.createEmptyMovieClip("content",this.depth++);	
		this.content.drawRect = this.drawRect;
		//this.attachMovie("fullSeparator", "separator_mc", this.depth++, {controller:this});
	} else {
		// create the canvas on which to create the window
		this.createEmptyMovieClip("canvas",this.depth++);
		// and prepare it to load/draw the graphics
		this.canvas.drawRect = this.drawRect;
		//this.canvas.clear();
	
		// create the mc on which to create the title
		this.createEmptyMovieClip("title",this.depth++);	
		this.title.drawRect = this.drawRect;
		//this.title.clear();
		// title text goes in the title mc, just a little bit in from the left
		// v6.5.5.8 Why do we set it at min height I wonder? Doesn't work for CP anyway where I just want one line
		// v6.5.6.4 new SSS
		//if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0 ) {
			this.title.createTextField("title_txt", this.depth++, this.borderSpacer, 0, this.myWidth, 20);
		} else if (this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			this.title.createTextField("title_txt", this.depth++, 4*this.borderSpacer, 3*this.borderSpacer, this.myWidth, 20);
		} else {
			this.title.createTextField("title_txt", this.depth++, this.borderSpacer, 0, this.myWidth, this.titleMinHeight);
		}
		this.title.title_txt.setNewTextFormat(this.titleTF);
		this.title._visible = false;
		
		// create the content holder
		this.createEmptyMovieClip("content",this.depth++);	
		this.content.drawRect = this.drawRect;
		//this.content.clear();
	}
	
	// to handle events
	this.controller = this;
	this.boundingBox_mc.controller = this;
	this.title.controller = this;
	this.canvas.controller = this;
	this.title.onPress = this.titleTrackBegin;
	this.title.onRelease = this.titleTrackEnd;
	this.title.onReleaseOutside = this.titleTrackEnd;
	
	// to stop anything underneath having an impact
	this.canvas.onRelease = function() {};
	this.canvas.useHandCursor = false;
}
// set what happens when enabled or disabled
PopupWindowClass.prototype.setEnabled = function(enabled) {
	if (enabled) {
		this.display();
		this._visible = true;
	} else {
		this._visible = false;
	}
}
// allow the use of a close button
PopupWindowClass.prototype.setCloseButton = function(enabled) {
	if (enabled) {
		// add the button component and associate it with the close button mc
		var closeButton = this.attachMovie("FGraphicButtonSymbol", "closeButton", this.depth++, {controller:this});
		//closeButton.setEnabled(false);
		// v6.5.5.8 Clear Pronunciation customisation
		// v6.5.6.4 New SSS
		if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0){
			//closeButton.setTarget("exitPUWBtn");
			closeButton.setTarget("exitBtn");
		} else if (this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			closeButton.setTarget("exitPUWBtn");
			//closeButton.setTarget("exitBtn");
		} else {
			closeButton.setTarget("exitBtn");
		}
		closeButton.setReleaseAction(this.closePane);
	}
	this.hasCloseButton = enabled;
}
// and a resize button
PopupWindowClass.prototype.setResizeButton = function(enabled) {
	if (enabled) {
		//var resizeButton = this.attachMovie("FGraphicButtonSymbol", "resizeButton", this.depth++, {controller:this});
		var resizeButton = this.attachMovie("ResizeGrip", "resizeButton", this.depth++, {controller:this});
		//resizeButton.setEnabled(false);
		//resizeButton.setTarget("resizeBtn");
		//resizeButton.setPressAction(this.resizeTrackBegin);
		resizeButton.onPress = this.resizeTrackBegin;
		resizeButton.onRelease = this.resizeTrackEnd;
		resizeButton.onReleaseOutside = this.resizeTrackEnd;
		// v6.4.2.7 Build the window based on branding
		//if (this.branding.indexOf("CUP/GIU") >= 0) {
			//myTrace("I want resize onRollOver");
			resizeButton.onRollOver = this.setResizeCursor;
			resizeButton.onRollOut = this.restoreCursor;
			this.attachMovie("ResizeCursor", "resizeCursor_mc", this.depth++, {controller:this});
			this.resizeCursor_mc._visible = false;
		//}
		//myTrace("add resize button");
		// create a outline mc to go over everything else for resize visuals
		this.createEmptyMovieClip("outline",this.depth++);	
		this.outline.drawRect = this.drawRect;
		//this.outline.clear();
		//this.outline._visible = false;		
	}
	this.hasResizeButton = enabled;
}
// max and min sizes for the window (if resizing)
PopupWindowClass.prototype.setMaxSize = function(w, h) {
	// add some smallest numbers to stop errors
	var theMin = 40;
	if (w < theMin || h < theMin) {
		w = theMin; h = theMin;
	}
	this.maxWidth = w;
	this.maxHeight = h;
}
PopupWindowClass.prototype.setMinSize = function(w, h) {
	// add some smallest numbers to stop errors
	var theMin = 40;
	if (w < theMin || h < theMin) {
		w = theMin; h = theMin;
	}
	this.minWidth = w;
	this.minHeight = h;
}
// and add event handlers
PopupWindowClass.prototype.setCloseHandler = function(newHandler) {
	this.closeHandler = newHandler;
};
// and resizing
PopupWindowClass.prototype.setResizeHandler = function(newHandler) {
	this.resizeHandler = newHandler;
};
// set colours and styles
PopupWindowClass.prototype.setStyles = function(styleObj) {
	for (var i in styleObj) {
		// for now just let ANY property be overwritten this way
		// but it would be good to only do it for the colour/style stuff
		this[i] = styleObj[i];
	}
}
// set colours and styles
PopupWindowClass.prototype.setContentBorder = function(enabled) {
	//v6.3.6 There are two borders at play. The coloured one round the whole content bit.
	// and the square one that is part of the scrollPane. This function should really
	// just be used to control the scrollPane part. The other part is interface specific
	// and is set on or off in the init.
	//this.hasContentBorder = enabled;
	//myTrace("PUW setContentBorder=" + enabled);
	// v6.4.2.7 But you might not have a scroll pane, just a content
	if (this.content.scrollPane_mc==undefined) {
		this.content.setBorder(enabled);
	} else {
		this.content.scrollPane_mc.setBorder(enabled);
	}
}
// input a title
PopupWindowClass.prototype.setTitle = function(titleText, titleTF) {
	if (titleTF != undefined) {
		this.title.title_txt.setNewTextFormat(titleTF);
	}
	this.hasTitle = true;
	this.title.title_txt.text = titleText;
	//myTrace("set title to " + this.title.title_txt.text);
}
// v6.5 new routine, in case anyone wants it
PopupWindowClass.prototype.getTitle = function() {
	return this.title.title_txt.text;
}

// kinder routine to set the size based on the content
// it is kind of approx though as once you have found the w and h
// you want, you will put it through setSize which will alter
// content size exactly how it wants.
PopupWindowClass.prototype.setContentSize = function(w, h) {
	// add some smallest numbers to stop errors
	var theMin = 10;
	if (w < theMin || h < theMin) {
		w = theMin; h = theMin;
	}
	// how much space to allow horizontally?
	var wBuffer = 4 * this.borderSpacer;
	// do you need to worry about a scrollbar?
	//myTrace("vscroll=" + this.content.scrollPane_mc.vScroll);
	// v6.4.1 But you might not even have a scroll pane, so check first
	if (this.content.scrollPane_mc != undefined &&
		this.content.scrollPane_mc.vScroll != "false") {
		//myTrace("pane (might) got scrollbar so make whole thing wider");
		//v6.3.5 Trial and error shows this to be a good width.
		wBuffer += 25;
	}
	// and vertically
	//myTrace("request h=" + h);
	var hBuffer = 6 * this.borderSpacer;
	if (this.hasTitle) {
		hBuffer += this.titleMinHeight + this.borderSpacer;
		//myTrace("add space for title=" + this.titleMinHeight + this.borderSpacer);
	}
	if (this.numButtons > 0) {
		hBuffer += this.button0.getSize().height + this.borderSpacer;
		//myTrace("add space for buttons=" + this.button0.getSize().height + this.borderSpacer);
	}
	//myTrace("puw:sCS:wBuffer=" + wBuffer + ", hBuffer="+ hBuffer + ", w=" + w + ", h=" + h);
	this.setSize(Number(w)+Number(wBuffer), Number(h)+Number(hBuffer));
}
// set the overall size and calculate the other sizes
PopupWindowClass.prototype.setSize = function(w, h) {
	//myTrace("puw:setSize w=" + w + ", h=" + h);
	if (this.maxWidth != undefined && w > this.maxWidth) {
		w = this.maxWidth;
	}
	if (this.maxHeight != undefined && h > this.maxHeight) {
		h = this.maxHeight;
	}
	if (this.minWidth != undefined && w < this.minWidth) {
		w = this.minWidth;
	}
	if (this.minHeight != undefined && h < this.minHeight) {
		h = this.minHeight;
	}
	this.myWidth = w;
	this.myHeight = h;
	this.format();
}
// ask to draw the window
PopupWindowClass.prototype.display = function() {
	//myTrace("puw:display");
	this.draw();
}
// allow or disallow dragging of the window
PopupWindowClass.prototype.setDrag = function(enabled) {
	if (!enabled) {
		delete this.title.onPress;
		delete this.title.onRelease;
		delete this.title.onReleaseOutside;
	}
}
// send back the mc that is the content container
// note: this could be modified if you do a setScrollContent
// so that you only have one get function
PopupWindowClass.prototype.getContent = function() {
	return this.content;
}
// and its size
PopupWindowClass.prototype.getContentSize = function() {
	return {width:this.content.myWidth, height:this.content.myHeight};
}
// and the title size
PopupWindowClass.prototype.getTitleSize = function() {
	return {width:this.title.myWidth, height:this.title.myHeight};
}
// add buttons (along with events to trigger)
PopupWindowClass.prototype.setButtons = function(buttonArray) {
// AP let buttons be added to the bottom of the pane
// Note: it is assumed that all buttons do something then close the pane
// use setCloseHandler to make the close button do one of the buttons if wanted
// v6.2 No, some buttons (such as print) shouldn't close the window
	this.numButtons = buttonArray.length;
	//myTrace("PUW.add " + this.numButtons + " buttons");
	//var minButtonWidth = 80;
	//var buttonHeight = 20;
	// if you don't fix this level, then if you run setButtons again on the same
	// pane you will end up with spurious ones
	this.level = 999;
	for (i=0; i<this.numButtons; i++) {
		var button_mc = this.attachMovie("FGraphicButtonSymbol", "button"+i, this.level++, {controller:this});
		button_mc.setEnabled(false);
		//trace("add button " + button_mc);
		// v6.4.2.7 Build the window based on branding
		if (this.branding.indexOf("CUP/GIU") >= 0) {
			button_mc.setTarget("paneBtn");
		} else {
			button_mc.setTarget("halfBtn");
		}
		//var thisWidth = Math.max(this.labelFormat.getTextExtent(buttonArray[i].caption).width + (this.borderSpacer*2), this.minButtonWidth);
		//trace(button_mc + "._width=" + thisWidth);
		//button_mc.setSize(thisWidth, buttonHeight);
		// v6.4.3 Although Tense Buster's halfBtn has canShrink set in the mc, this isn't picked up by setLabel
		// v6.5.5.3 Add Its Your Job to have shrinking buttons
		if ((this.branding.toLowerCase().indexOf("clarity/tb") >= 0) ||
			(this.branding.toLowerCase().indexOf("clarity/iyj") >= 0)){
			// so give it a helping hand
			button_mc.target.canShrink = true;
		}
		//if (this.branding.toLowerCase().indexOf("clarity/sss") >= 0){
		//	button_mc.target.canExpand = true;
		//}
		//myTrace("PUW.button caption=" + buttonArray[i].caption);
		button_mc.setLabel(buttonArray[i].caption, this.labelFormat);
		// don't use the setReleaseAction of the glassTile, just set it here
		// so that you can add to it a close function for the pane
		if (buttonArray[i].noClose == true) {
			//myTrace("a button with no close action=" + buttonArray[i].caption);
			button_mc.onRelease = function() {
				//myTrace("this is a button with no close action");
				this.setReleaseAction(this.controller);
			}
		} else {
			button_mc.onRelease = function() {
				this.setReleaseAction(this.controller);
				// close the pane, but don't trigger the closeHandler as you 
				// will likely get double effect from the button
				this.controller.closePane(false); 
			}
		}
		button_mc.setReleaseAction = buttonArray[i].setReleaseAction;
	}
}
// AP: try to let the use keys to close the box or choose buttons
PopupWindowClass.prototype.setKeys = function(keyArray) {
	// add a listener to pick up key strokes
	this.onKeyUp = function () {
		var thisKey = Key.getCode();
		//this.setPaneTitle("you pressed key " + thisKey);
		for (var i in keyArray) {
			for (var j in keyArray[i].key) {
				if (thisKey == keyArray[i].key[j]){
					//trace("matched key array=" + i);
					keyArray[i].setReleaseAction(this);
					//this.removeMovieClip();
					this.controller.closePane();
				}
			}
		}			
	}
	Key.addListener(this);
}
// scroll pane functions
// sometimes you want the window to include a scrollPane for the content to sit in
// Rather than have to do that outside, you can do it here
PopupWindowClass.prototype.setScrollContent = function(target) {
	if (this.content.scrollPane_mc == undefined) {
		// first add the scrollPane to the component
		this.content.attachMovie("FScrollPaneSymbol", "scrollPane_mc", this.depth++, {controller:this});
		// set some properties
		this.content.scrollPane_mc.setDragContent(false);
		// don't ever want the horizontal scroller
		this.content.scrollPane_mc.setHScroll(false);
		// not sure whether you want the vertical scroller to auto, or always on?
		this.content.scrollPane_mc.setVScroll("auto");
	}
	// and attach the content
	this.content.scrollPane_mc.setScrollContent(target);
	// once you have decided to use this type of content, the original
	// getContent should be modified so that it returns this one
	// We are not allowing scroll content to be removed.
	this.getContent = this.getScrollContent;
}
// and send back the container for someone to populate
PopupWindowClass.prototype.getScrollContent = function() {
	return this.content.scrollPane_mc.getScrollContent();
}
// 'inherit' from dragpane
PopupWindowClass.prototype.setStyleProperty = function(propName, value, isGlobal)
{
	this.content.scrollPane_mc.setStyleProperty(propName, value, isGlobal);
};
// Pass through to the scroll pane
PopupWindowClass.prototype.setSmallScroll = function(x, y){
	this.content.scrollPane_mc.setSmallScroll(x, y);
}

// ==============
// hidden classes
// ==============

// This is the main formatting function. It doesn't draw anything
// just calculates the coordinates and dimensions.
PopupWindowClass.prototype.format = function() {
	//myTrace("puw:format");
	// layout the controls
	if (this.hasCloseButton) {
		// put it in top right corner
		var closeDims = this.closeButton.getSize();
		//myTrace("close button=" + this.closeButton + " .getSize=" + this.closeButton.getSize);
		//myTrace("closeDims.width=" + closeDims.width + ", .height=" + closeDims.height);
		//myTrace("main.width=" + this.myWidth + ", close.width=" + closeDims.width + ", border=" + this.borderSpacer);
		// v6.4.2.7 Build the window based on branding
		if (this.branding.indexOf("CUP/GIU") >= 0) {
			this.closeButton._x = this.myWidth - closeDims.width - (2*this.borderSpacer);
			this.closeButton._y = this.borderSpacer;
		// v6.5.5.8 Clear Pronunciation customisation
		} else if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0 ){
			this.closeButton._x = this.myWidth - closeDims.width - 4;
			this.closeButton._y = 8;
		// v6.5.6.4 New SSS
		} else if (this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			this.closeButton._x = this.myWidth - closeDims.width - 4;
			this.closeButton._y = 8;
		} else {
			this.closeButton._x = this.myWidth - closeDims.width - this.borderSpacer;
			this.closeButton._y = this.borderSpacer;
		}
		// apply some constraints
		this.closeButton._x = Math.max(this.closeButton._x, 0);
		this.closeButton._y = Math.max(this.closeButton._y, 0);
	}
	if (this.hasResizeButton) {
		// put it in bottom right corner
		// v6.4.2.7 Build the window based on branding
		if (this.branding.indexOf("CUP/GIU") >= 0) {
			this.resizeButton._x = this.myWidth - this.resizeButton._width;
			this.resizeButton._y = this.myHeight - this.resizeButton._height;
		} else {
			var resizeDims = this.resizeButton.getSize();
			//var resizeDims = {width:this.resizeButton._width, height:this.resizeButton._height};
			//this.resizeButton._y = this.myHeight - resizeDims.height - (this.canvasLineThickness-1);
			this.resizeButton._x = this.myWidth - resizeDims.width;
			this.resizeButton._y = this.myHeight - resizeDims.height;
		}
		// apply some constraints
		this.resizeButton._x = Math.max(this.resizeButton._x, 0);
		this.resizeButton._y = Math.max(this.resizeButton._y, 0);
	}
	// layout the title
	if (this.hasTitle) {
		// a close button reduces the title space, you have already got its dims
		if (this.hasCloseButton) {
			var closeborderHSpacer = closeDims.width + this.borderSpacer;
			var closeborderVSpacer = closeDims.height;
		} else {
			var closeborderHSpacer = 0;
			var closeborderVSpacer = 0;
		}
		// set the coords of the title mc
		// v6.5.5.8 Clear Pronunciation customisation
		// v6.5.6.4 New SSS
		//if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0 || 
			this.branding.toLowerCase().indexOf("clarity/cp2") >= 0 || 
			this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			this.title._x = 0;
			this.title._y = 0;
			// and what will its dims be?
			if (this.hasCloseButton) {
				//this.title.myWidth = this.myWidth - 80;
				this.title.myWidth = this.myWidth;
			} else {
				this.title.myWidth = this.myWidth;
			}
		} else {
			this.title._x = this.borderSpacer;
			this.title._y = this.borderSpacer;
			// and what will its dims be?
			this.title.myWidth = this.myWidth - (2 * this.borderSpacer) - closeborderHSpacer;
		}
		this.title.myWidth = Math.max(this.title.myWidth, 10);
		// make the text field the same width
		this.title.title_txt._width = this.title.myWidth;
		this.title.myWidth = Math.max(this.title.myWidth, 10);
		// make the text field the same width
		this.title.title_txt._width = this.title.myWidth;
		// at least the same height as the close button?
		this.title.myHeight = Math.max(this.titleMinHeight, closeborderVSpacer);
		// then do you need to vertically centre the text?
		// v6.5.5.8 It seems we don't know the text height yet.
		//myTrace("myHeight=" + this.title.myHeight + " title_txt._height=" + this.title.title_txt._height);
		this.title.title_txt._y = (this.title.myHeight - this.title.title_txt._height) /2;
		var titleSpace = this.title._y + this.title.myHeight + this.borderSpacer;
	} else {
		var titleSpace = this.borderSpacer;
	}
	titleSpace = Math.max(titleSpace, 0);
	// normal number of buttons
	// v6.5.6.4 But SSS progress has 4 buttons!
	//if (this.numButtons > 0 && this.numButtons <= 3) {
	///myTrace("sss with nuttons=" + this.numButtons);
	if (this.numButtons > 0 && this.numButtons <= 4) {
		// No, not all buttons will be the same width
		var buttonDims = this.button0.getSize();
		var buttonSpace = buttonDims.height + (this.borderSpacer * 2)
		if (this.resizable) {
			// v6.4.2.7 CUP rearrange
			//var availableWidth = this.resizeGrip_mc._x;
			var availableWidth = this.resizeButton._x;
		} else {
			var availableWidth = this.myWidth;
		}
		// v6.5.6.4 New SSS wants the buttons to fill the available space.
		if (this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
			this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			for (i=0; i<this.numButtons; i++) {
				var button_mc = this["button"+i];
				var buttonWidth = Math.ceil((availableWidth - this.borderSpacer*2)/this.numButtons);
				button_mc.setFixedWidth(buttonWidth);
				//myTrace("expand button to " + buttonWidth + ":" + button_mc.getSize().width);
			}
		}
		// v6.5.5.8
		var buttonsUsedSpace = 0;
		for (i=0; i<this.numButtons; i++) {
			var button_mc = this["button"+i];
			var thisButtonWidth = button_mc.getSize().width;
			// v6.5.5.8 Clear Pronunciation customisation
			if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0 ) {
				// Just left align buttons with a little space between, but note that second button has i=2, third button has i=1
				if (i==0) { // first button is always left aligned
					button_mc._x = this.borderSpacer;
					buttonsUsedSpace+=button_mc._x + thisButtonWidth + this.borderSpacer;
				} else if (i==2) { // second button is just to the right
					button_mc._x = buttonsUsedSpace;
					buttonsUsedSpace+=thisButtonWidth + this.borderSpacer;
				} else if (i==1) { // third button is just to the right of that
					button_mc._x = buttonsUsedSpace;
					buttonsUsedSpace+=thisButtonWidth + this.borderSpacer;
				}
			} else {
				if (this.numButtons==4) {
					if (i==0) { // first button is always left aligned
						button_mc._x = this.borderSpacer;
						buttonsUsedSpace+=button_mc._x + thisButtonWidth;
					} else if (i==1) { // second button is right aligned to the centre
						button_mc._x = buttonsUsedSpace;
						buttonsUsedSpace+=thisButtonWidth;
					} else if (i==2) { // second button is right aligned to the centre
						button_mc._x = buttonsUsedSpace;
						buttonsUsedSpace+=thisButtonWidth;
					} else if (i==3) { // 4th button is right aligned
						//button_mc._x = availableWidth - buttonDims.width - this.borderSpacer;
						button_mc._x = availableWidth - thisButtonWidth - this.borderSpacer;
					}
					//myTrace("button " + i + " x=" + button_mc._x + " y=" + button_mc._y);
				} else {
					if (i==0) { // first button is always left aligned
						button_mc._x = this.borderSpacer;
					} else if (i==2) { // second button is centre aligned
						//button_mc._x = (availableWidth - buttonDims.width)/2;
						button_mc._x = (availableWidth - thisButtonWidth)/2;
					} else if (i==1) { // third button is right aligned
						//button_mc._x = availableWidth - buttonDims.width - this.borderSpacer;
						button_mc._x = availableWidth - thisButtonWidth - this.borderSpacer;
					}
				}
			}
			// v6.4.2.7 Build the window based on branding
			if (this.branding.indexOf("CUP/GIU") >= 0) {
				//button_mc._y = this.myHeight - buttonDims.height - 10;
				button_mc._y = this.myHeight - buttonDims.height - (1.5*this.borderSpacer);
			} else {
				button_mc._y = this.myHeight - buttonDims.height - (1*this.borderSpacer);
			}
			// apply some constraints
			button_mc._x = Math.max(button_mc._x, 0);
			button_mc._y = Math.max(button_mc._y, 0);
		}
		//myTrace("buttons height=" + buttonDims.height);
	// for now don't worry about more than 3 buttons!
	} else {
		// v6.4.2.7 Build the window based on branding
		if (this.branding.indexOf("CUP/GIU") >= 0) {
			var buttonSpace = 2*this.borderSpacer;
		} else {
			var buttonSpace = this.borderSpacer;
		}
	}
	//myTrace("button space=" + buttonSpace);
	buttonSpace = Math.max(buttonSpace, 0);

	// finally the content
	this.content._x = this.borderSpacer;
	this.content._y = titleSpace;
	this.content.myWidth = this.myWidth - (2 * this.borderSpacer);
	this.content.myHeight = this.myHeight - titleSpace - buttonSpace;
	//myTrace("format: mainWidth=" + this.myWidth + " contentWidth=" + this.content.myWidth);
	var scrollContent = this.content.scrollPane_mc;
	if (scrollContent != undefined) {
		scrollContent._x = this.borderSpacer;
		scrollContent._y = this.borderSpacer;
		// v6.3.5 Some spacing for the scrolling content
		var w = this.content.myWidth - (2 * this.borderSpacer);
		var h = this.content.myHeight - (2 * this.borderSpacer);
		// v6.3.5 and what about the scroll bar itself?
		/*
		myTrace("format, vscroll=" + scrollContent.vscroll);
		if (scrollContent.vscroll != "false") {
			w -= 15;
			myTrace("content perhaps scrollbar, content.myW=" + this.content.myWidth + " scroll.w=" + w);
		}
		*/
		// apply some constraints
		w = Math.max(w, 10);
		h = Math.max(h, 10);
		scrollContent.setSize(w, h);
		scrollContent.refreshPane();
	}
	//myTrace("titleSpace=" + titleSpace);
	//myTrace("buttonsSpace=" + buttonSpace);
}
// This is the function that actually draws the window
PopupWindowClass.prototype.draw = function() {
	//myTrace("draw");	
	// draw the canvas
	this.drawCanvas(0, 0, this.myWidth, this.myHeight, this.radius);

	// draw the title
	if (this.hasTitle) {
		//myTrace("title box w=" + this.title.myWidth + ", h=" + this.title.myHeight);
		this.drawTitleBox(0, 0, this.title.myWidth, this.title.myHeight,
						  this.radius*0.75)
		this.title._visible = true;
		//myTrace("title=" + this.title.title_txt.text);
	} else {
		this.title._visible = false;
	}

	// draw the content
	// v6.4.2.7 Build the window based on branding
	if (this.branding.indexOf("CUP/GIU") >= 0) {
		this.content.myWidth-=(this.borderSpacer/2);
	}
	this.drawContentBox(0, 0, this.content.myWidth, this.content.myHeight, 
					this.radius*0.75);
	this.content._visible = true;

	// draw the controls
	if (this.hasCloseButton) {
		this.closeButton.setEnabled(true);
	}
	if (this.hasResizeButton) {
		this.resizeButton.setEnabled(true);
	}
	
	// v6.4.2.7 Separator
	if (this.hasSeparator) {
		//this.drawSeparator(0, this.separatorY, this.content.myWidth, 1);
		this.separator_mc._x = this.content._x;
		this.separator_mc._width = this.content.myWidth;
		this.separator_mc._visible = true;
		this.separator_mc._yscale = 1;
	}
	
	// draw the buttons
	for (var i=0; i<this.numButtons; i++) {
		this["button"+i].setEnabled(true);
	}
}
// for event handling, first of all dragging (tracking)
PopupWindowClass.prototype.titleTrackBegin = function() {
	//trace("start drag");
	this.controller.startDrag();
};
PopupWindowClass.prototype.titleTrackEnd = function() {
	this.controller.stopDrag();
	// v6.2 Don't let the pane be dragged off the screen
	//trace("stop drag with _x=" + this.controller._x + " this=" + this.controller);
	if (this.controller._x < 10) this.controller._x = 10;
	if (this.controller._y < 10) this.controller._y = 10;
	//trace("stage.width = " + stage.width + ", x=" + this.controller._x);
	if (this.controller._x > (Stage.width-50)) {
		//trace("too far right");
		this.controller._x = (Stage.width-50)
	}
	if (this.controller._y > (Stage.height-50)) this.controller._y = (Stage.height-50);
}

// 6.5.4.2 Yiu make a TextWithFields invisible to the orginal text, just want to activate the dictionary function, ID 1223
// v6.5.4.3 AR This was not necessary for the fix - remove in case it causes anything else to go wrong
/*
PopupWindowClass.prototype.initTextFieldForDictionaryCheck	= function(){
	if (!this.controller.content.tempTextBox)
	{
		var myInitObject = {_x:adjustedX, _y:myTop, border_param:false, autosize_param:true}
		myInitObject.noProcessing_param = true;
		
		var contentHolder	= this.controller.content;
		var mo 			= contentHolder.createEmptyMovieClip("tempMovieClip", contentHolder.getNextHighestDepth());

		var me 			= contentHolder.attachMovie(	"FTextWithFieldsSymbol", 
									"tempTextBox", 
									mo.getNextHighestDepth(), 
									myInitObject);
											
		me.setSize(	this.controller.content.list_txt._width, 
				this.controller.content.list_txt._height);

		var eventNames = {	rollOver:"_global.ORCHID.fieldRollOver", 
					rollOut:"_global.ORCHID.fieldRollOut", 
					mouseDown:"_global.ORCHID.fieldMouseDown", 
					mouseUp:"_global.ORCHID.fieldMouseUp", 
					drag:"_global.ORCHID.fieldDrag", 
					drop:"_global.ORCHID.fieldDrop",
					controlClick:"_global.ORCHID.onGlossary",
					heightChange:"_global.ORCHID.heightChange"};
		me.setEvents(eventNames);
		
		me.setHtmlText(this.controller.content.list_txt.text, this.controller.content.list_txt.getTextFormat()); 
		me.original.text		= this.controller.content.list_txt.text;
		me.original._visible		= false;
		
		me.maxLength	= this.controller.content.list_txt.text.length;
		me.addDropsForHitTest();
		
		me.original.setTextFormat(this.controller.content.list_txt.getTextFormat());
		me.refresh();
		
		mo._x	= this.controller.content.list_txt._x;
		mo._y	= this.controller.content.list_txt._y;
		me._x	= this.controller.content.list_txt._x;
		me._y	= this.controller.content.list_txt._y;
		
		me._visible	= false;
	}
}
*/
// 6.5.4.2 Yiu make a TextWithFields invisible to the orginal text, just want to activate the dictionary function, ID 1223

PopupWindowClass.prototype.resizeTrackBegin = function() {
	//myTrace("begin resize");
	//Mouse.hide();
	// v6.4.2.7 Build the window based on branding
	if (this.branding.indexOf("CUP/GIU") >= 0) {
		//this.controller.resizeCursor_mc._visible = true;
		this.controller.setResizeCursor();
	}
	this.anchorX = this._xmouse;
	this.anchorY = this._ymouse;
	
	// maybe disable the content/title/buttons so you can just drag the
	// box outline.
	this.controller.canvas._alpha = 90;
	this.controller.content._alpha = 90;
	this.controller.title._alpha = 90;
	this.controller.outline._visible = true;
		
	this.onMouseMove = function() {
		// v6.4.2.7 Build the window based on branding
		if (this.branding.indexOf("CUP/GIU") >= 0) {
			this.controller.dragResizeCursor();
		}
		var newWidth = this.controller.myWidth+(this._xmouse-this.anchorX);
		var newHeight = this.controller.myHeight+(this._ymouse-this.anchorY);
		if (newHeight < this.controller.minHeight) {
			newHeight = this.controller.minHeight;
		}
		if (newWidth < this.controller.minWidth) {
			newWidth = this.controller.minWidth;
		}
		if (newHeight > this.controller.maxHeight) {
			newHeight = this.controller.maxHeight;
		}
		if (newWidth > this.controller.maxWidth) {
			newWidth = this.controller.maxWidth;
		}
		// instead of redrawing the whole thing, why not just
		// try to do the outline?
		//this.controller.setSize(newWidth, newHeight);
		this.controller.drawOutlineBox(0, 0, newWidth, newHeight, this.controller.radius);
	}
	// Use the existing one, but add in third (just starting) parameter
	//this.controller.resizeHandler({width:0, height:0}, true);
}
PopupWindowClass.prototype.resizeTrackEnd = function() {
	//myTrace("PUW end resize");
	// v6.4.2.7 Build the window based on branding
	if (this.branding.indexOf("CUP/GIU") >= 0) {
		this.controller.restoreCursor();
	}
	this.onMouseMove = null;
	// redraw the window
	//myTrace("endResize, outline._width=" + this.controller.outline._width);
	this.controller.setSize(this.controller.outline._width, this.controller.outline._height);
	this.controller.display();
	
	// send an event that you need to resize the contents (along with the new size object)
	this.controller.resizeHandler(this.controller.getContentSize());
	// undo the hiding you did earlier
	this.controller.canvas._alpha = 100;
	this.controller.content._alpha = 100;
	this.controller.title._alpha = 100;
	this.controller.outline._visible = false;
}
// then closing
PopupWindowClass.prototype.closePane = function(noAction) {
	//AP you will ALWAYS close the pane after clicking here
	// so the closeHandler function usually equates to one of the buttons
	if (noAction != false) {
		this.controller.closeHandler(this.controller);
	}
	this.controller.removeMovieClip();
}
// then resizing
PopupWindowClass.prototype.resizePane = function() {
	// do what you need to cope with resizing
	// then call the event handler
	this.controller.resizeHandler(this.controller);
}
// to draw the background on the canvas
PopupWindowClass.prototype.drawCanvas = function(x, y, w, h, r) {
	// v6.4.2.7 Build the window based on branding
	if (this.branding.indexOf("CUP/GIU") >= 0) {
		//this.title._x = x;
		//this.title._y = y;
		this.canvas._width = w;
		this.canvas._height = h;
	} else {
		this.canvas.clear();
		this.canvas.lineStyle(this.canvasLineThickness, this.canvasLineColour);
		this.canvas.beginFill(this.canvasFillColour, this.canvasFillAlpha);
		this.canvas.drawRect(x, y, w, h, r);
	}
	//myTrace("drawCanvas(" + x + ", " + y + ", " + w + ", " + h + ", " + r + ")");
}
// to draw the title bar
PopupWindowClass.prototype.drawTitleBox= function(x, y, w, h, r) {
	//myTrace("drawTitle(" + x + ", " + y + ", " + w + ", " + h + ", " + r + ")");
	// v6.4.2.7 Build the window based on branding
	if (this.branding.indexOf("CUP/GIU") >= 0) {
		// The title will never be scaled
		//this.title._x = x;
		//this.title._y = y;
		//this.title._width = w;
		//this.title.title_txt._xscale = 100;
		//this.title._height = h;
	} else {
		this.title.clear();
		this.title.lineStyle(this.titleLineThickness, this.titleLineColour);
		this.title.beginFill(this.titleFillColour, this.titleFillAlpha);
		this.title.drawRect(x, y, w, h, r);
	}
	// for CP I also want a second title rectangle over at the right to give a nice effect
	if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		this.title.lineStyle(this.titleLineThickness, 0x1E4447);
		this.title.beginFill(0x1E4447, this.titleFillAlpha);
		this.title.drawRect((w-80),y,80,h,r);
	}
	// v6.5.6.4 for SSS I want a gradient rectangle (or at least just a purple one)
	if (this.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		// But for instant marking I want different colours for right and wrong
		//this.title.lineStyle(this.titleLineThickness, 0x4E2D94);
		//this.title.lineStyle(this.titleLineThickness, titleBarFillColour);
		//this.title.beginFill(titleBarFillColour, this.titleFillAlpha);
		//this.title.drawRect(x,y,w,h,0);
	}
			
}
// to draw the content holder
PopupWindowClass.prototype.drawContentBox= function(x, y, w, h, r) {
	this.content.clear();
	//trace("call draw(" + x + ", " + y + ", " + w + ", " + h + ", " + r + ")");
	if (this.hasContentBorder) {
		var lineAlpha = 100;
	} else {
		var lineAlpha = 0;
	}
	this.content.lineStyle(this.contentLineThickness, this.contentLineColour, lineAlpha);
	this.content.beginFill(this.contentFillColour, this.contentFillAlpha);
	this.content.drawRect(x, y, w, h, r);
	//myTrace("drawContent(" + x + ", " + y + ", " + w + ", " + h + ", " + r + ")");
}
// to draw an outline
PopupWindowClass.prototype.drawOutlineBox = function(x, y, w, h, r) {
	//myTrace("drawOutlineBox w=" + w);
	//trace("call draw(" + x + ", " + y + ", " + w + ", " + h + ", " + r + ")");
	this.outline.clear();
	this.outline.lineStyle(this.canvasLineThickness, this.canvasLineColour);
	this.outline.beginFill(0xCCCCCC, 25);
	this.outline.drawRect(x, y, w, h, r);
	//myTrace("drawOutline(" + x + ", " + y + ", " + w + ", " + h + ", " + r + ")");
}
// useful for debugging
PopupWindowClass.prototype.getVersion = function() {
	//myTrace("get version");
	return this._version;
}
// v6.4.2.7 And a separator
// function to use the separator and place it - only valid for CUP I think
// Note this cannot be called hasSeparator - it will not be called if it is. I suppose because it is also a property.
PopupWindowClass.prototype.setSeparator = function(y) {
	//myTrace("set separator y=" + y);
	// v6.4.2.7 Build the window based on branding
	if (this.branding.indexOf("CUP/GIU") >= 0) {
		if (this.separator_mc == undefined) {
			this.attachMovie("fullSeparator", "separator_mc", this.depth++, {controller:this});
		}
		this.hasSeparator = true;
		//this.separator_mc._visible = true;
		//this.separator_mc._x = this.content._x;
		this.separator_mc._y = y;
		//this.separator_mc._width = this.content._width;
		//this.separatorY = y;
	} else {
		this.content.lineStyle(this.contentLineThickness, this.contentLineColour, 100);
		//this.content.beginFill(this.contentFillColour, this.contentFillAlpha);
		this.content.moveTo(0, y);
		this.content.lineTo(this.content._width, y);
		myTrace("separator lineTo " + this.content._width + ", " + y);
	}
};
// v6.4.2.7 If we want to use a resize cursor
PopupWindowClass.prototype.setResizeCursor = function() {
	//myTrace("setResizeCursor");
	this.controller.resizeCursor_mc._x = this.controller._xmouse-10;
	this.controller.resizeCursor_mc._y = this.controller._ymouse-10;
	this.controller.resizeCursor_mc._visible = true;
	this.onMouseMove = this.controller.dragResizeCursor;
	Mouse.hide();
};
PopupWindowClass.prototype.restoreCursor = function() {
	//myTrace("restoreCursor");
	this.controller.resizeCursor_mc._visible = false;
	this.onMouseMove = null;
	Mouse.show();
};
PopupWindowClass.prototype.dragResizeCursor = function() {
	//myTrace("dragResizeCursor");
	this.controller.resizeCursor_mc._visible = true;
	this.controller.resizeCursor_mc._x = this.controller._xmouse-10;
	this.controller.resizeCursor_mc._y = this.controller._ymouse-10;
};

Object.registerClass("FPopupWindowSymbol", PopupWindowClass);
#endinitclip
