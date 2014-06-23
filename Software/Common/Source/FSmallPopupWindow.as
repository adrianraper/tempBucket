#initclip

function SmallPopupWindowClass() {
	this.init();
}
// inherit from MovieClip
SmallPopupWindowClass.prototype = new MovieClip();

// initialise
SmallPopupWindowClass.prototype.init = function() {
	this._version = "6.5.5.8";
	//myTrace("SPUW init at " + this._version);

	// v6.4.2.7 CUP update - allow branding, usually passed when component created
	if (this.branding == undefined) this.branding = "Clarity/AP";

	this.hasTitle = false;
	this.hasCloseButton = false;
	this.hasResizeButton = false;
	// these can be overridden by using setMax and setMin
	this.minWidth = 40;
	this.minHeight = 40;
	this.maxWidth = 700;
	this.maxHeight = 500

	if (this.borderSpacer == undefined) {
		this.borderSpacer = 8; 
	}

	// start the depth count
	this.depth = 0;

	// anti-distortion
	this.boundingBox_mc._visible = false;
	this.myWidth = this._width;
	this.myHeight = this._height;
	this._xscale = this._yscale = 100;

	// create a background - the canvas
	//this.createEmptyMovieClip("canvas", this.depth++);
	// Use a new version of GlassTile to get the nine images to stretch nicely	
	this.canvas = this.attachMovie("FNineSectionsSymbol", "canvas", this.depth++);
	
	// create the content holder
	this.createEmptyMovieClip("content",this.depth++);	
	
	// to handle events
	this.controller = this;
	this.boundingBox_mc.controller = this;
	this.canvas.controller = this;
	
	// to stop anything underneath having an impact
	// v6.5.5.8 You close this window by clicking on it - I am not going to show a fat fingerl
	// Actually, clicking anywhere on the screen is all I want to remove the window as this will get rid of it when I click on another field or button
	// You also put this function on the scrollPane for continuous clicking
	//this.canvas.onRelease = this.closePane;
	this.canvas.onRelease = function() {};
	this.canvas.useHandCursor = false;
	// create an overlay - then need to put something invisible in it.
	//this.createEmptyMovieClip("overlay",this.depth++);	
	//this.overlay.onRelease = this.closePane;

	this.closeListener = new Object();
	this.closeListener.controller = this;
	this.closeListener.onMouseDown = function() {
		//myTrace("mouseDown in closeListener");
		Mouse.removeListener(this);
		this.controller.closePane();
	}

}
// set what happens when enabled or disabled
SmallPopupWindowClass.prototype.setEnabled = function(enabled) {
	if (enabled) {
		//myTrace("SPUW.call display");
		this.display();
		this._visible = true;
		// v6.5.5.8 Add a listener to pick up any click on screen
		Mouse.addListener(this.closeListener);
	} else {
		this._visible = false;
	}
}
// allow the use of a close button
SmallPopupWindowClass.prototype.setCloseButton = function(enabled) {
	if (enabled) {
		// add the button component and associate it with the close button mc
		var closeButton = this.attachMovie("FGraphicButtonSymbol", "closeButton", this.depth++, {controller:this});
		closeButton.setTarget("exitSmallFBBtn");
		closeButton.setReleaseAction(this.closePane);
	}
	this.hasCloseButton = enabled;
}
// max and min sizes for the window (if resizing)
SmallPopupWindowClass.prototype.setMaxSize = function(w, h) {
	// add some smallest numbers to stop errors
	var theMin = 40;
	if (w < theMin || h < theMin) {
		w = theMin; h = theMin;
	}
	this.maxWidth = w;
	this.maxHeight = h;
}
SmallPopupWindowClass.prototype.setMinSize = function(w, h) {
	// add some smallest numbers to stop errors
	var theMin = 40;
	if (w < theMin || h < theMin) {
		w = theMin; h = theMin;
	}
	this.minWidth = w;
	this.minHeight = h;
}
// and add event handlers
SmallPopupWindowClass.prototype.setCloseHandler = function(newHandler) {
	this.closeHandler = newHandler;
};
// set colours and styles
SmallPopupWindowClass.prototype.setStyles = function(styleObj) {
	for (var i in styleObj) {
		// for now just let ANY property be overwritten this way
		// but it would be good to only do it for the colour/style stuff
		this[i] = styleObj[i];
	}
}
// set colours and styles
SmallPopupWindowClass.prototype.setContentBorder = function(enabled) {
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

// kinder routine to set the size based on the content
// it is kind of approx though as once you have found the w and h
// you want, you will put it through setSize which will alter
// content size exactly how it wants.
SmallPopupWindowClass.prototype.setContentSize = function(w, h) {
	// add some smallest numbers to stop errors
	var theMin = 10;
	if (w < theMin || h < theMin) {
		w = theMin; h = theMin;
	}
	// how much space to allow horizontally?
	var wBuffer = 2 * this.borderSpacer;
	// and vertically
	//myTrace("request h=" + h);
	var hBuffer = 4 * this.borderSpacer;
	myTrace("spuw:setContentSize: w=" + w + ", h=" + h);
	this.setSize(Number(w)+Number(wBuffer), Number(h)+Number(hBuffer));
}
// set the overall size and calculate the other sizes
SmallPopupWindowClass.prototype.setSize = function(w, h) {
	myTrace("spuw:setSize w=" + w + ", h=" + h);
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
	
	// Tell the bounding box to change (that has the 9-sections background on it)
	//this.canvas.setSize(w,h);
	this.canvas.setSize(w,40);
	
	this.format();
}
// ask to draw the window
SmallPopupWindowClass.prototype.display = function() {
	//myTrace("puw:display");
	this.draw();
}
// send back the mc that is the content container
// note: this could be modified if you do a setScrollContent
// so that you only have one get function
SmallPopupWindowClass.prototype.getContent = function() {
	return this.content;
}
// and its size
SmallPopupWindowClass.prototype.getContentSize = function() {
	return {width:this.content.myWidth, height:this.content.myHeight};
}
// AP: try to let the use keys to close the box or choose buttons
SmallPopupWindowClass.prototype.setKeys = function(keyArray) {
	// add a listener to pick up key strokes
	this.onKeyUp = function () {
		var thisKey = Key.getCode();
		//this.setPaneTitle("you pressed key " + thisKey);
		for (var i in keyArray) {
			for (var j in keyArray[i].key) {
				if (thisKey == keyArray[i].key[j]){
					//myTrace("matched key array=" + i);
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
SmallPopupWindowClass.prototype.setScrollContent = function(target) {
	myTrace("spuw:setScrollContent");
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
	// v6.5.5.8 Need to allow clicking on this content
	this.content.scrollPane_mc.onRelease = this.closePane;
}
// and send back the container for someone to populate
SmallPopupWindowClass.prototype.getScrollContent = function() {
	return this.content.scrollPane_mc.getScrollContent();
}
// 'inherit' from dragpane
SmallPopupWindowClass.prototype.setStyleProperty = function(propName, value, isGlobal)
{
	this.content.scrollPane_mc.setStyleProperty(propName, value, isGlobal);
};
// Pass through to the scroll pane
SmallPopupWindowClass.prototype.setSmallScroll = function(x, y){
	this.content.scrollPane_mc.setSmallScroll(x, y);
}

// ==============
// hidden classes
// ==============

// This is the main formatting function. It doesn't draw anything
// just calculates the coordinates and dimensions.
SmallPopupWindowClass.prototype.format = function() {
	//myTrace("spuw:format");
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
		} else if (this.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
			this.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
			this.closeButton._x = this.myWidth - closeDims.width;
			this.closeButton._y = 0;
		} else {
			this.closeButton._x = this.myWidth - closeDims.width - this.borderSpacer;
			this.closeButton._y = this.borderSpacer;
		}
		// apply some constraints
		this.closeButton._x = Math.max(this.closeButton._x, 0);
		this.closeButton._y = Math.max(this.closeButton._y, 0);
	}
	var titleSpace = 0;

	// finally the content
	// v6.5.5.8 It simply looks better with less border
	//this.content._x = this.borderSpacer;
	this.content._x = math.floor(this.borderSpacer * 0.5);
	this.content._y =0;
	//this.content._y = 0;
	//this.content._y = this.borderSpacer;
	this.content.myWidth = this.myWidth - (2 * this.borderSpacer);
	this.content.myHeight = this.myHeight - (2 * this.borderSpacer);
	//myTrace("spuw:format: mainWidth=" + this.myWidth + " contentWidth=" + this.content.myWidth);
	var scrollContent = this.content.scrollPane_mc;
	if (scrollContent != undefined) {
		//myTrace("spuw:i have scrollpane");
		scrollContent._x = this.borderSpacer;
		scrollContent._y = this.borderSpacer;
		//scrollContent._y = 0;
		// v6.3.5 Some spacing for the scrolling content
		// v6.5.5.8 I really don't want a scrollPane for small feedback
		scrollContent.vscroll=scrollContent.hscroll=false;
		
		var w = this.content.myWidth - (2 * this.borderSpacer);
		var h = this.content.myHeight - (2 * this.borderSpacer);
		//var w = this.content.myWidth;
		//var h = this.content.myHeight;
		// apply some constraints
		w = Math.max(w, 10);
		h = Math.max(h, 10);
		scrollContent.setSize(w, h);
		scrollContent.refreshPane();
	}
	//myTrace("titleSpace=" + titleSpace);
	//myTrace("buttonsSpace=" + buttonSpace);
	// v6.5.5.8 make the overlay mimic the canvas size
	//this.overlay._width = this.canvas._width;
	//this.overlay._height = this.canvas._height;
}
// This is the function that actually draws the window
SmallPopupWindowClass.prototype.draw = function() {
	//myTrace("SPUW draw");
	
	// draw the canvas
	this.drawCanvas(0, 0, this.myWidth, this.myHeight, this.radius);
	
	// draw the content
	//this.content._visible = true;

	// draw the controls
	if (this.hasCloseButton) {
		this.closeButton.setEnabled(true);
	}

	// draw the buttons
	for (var i=0; i<this.numButtons; i++) {
		this["button"+i].setEnabled(true);
	}
}
// then closing
SmallPopupWindowClass.prototype.closePane = function(noAction) {
	//AP you will ALWAYS close the pane after clicking here
	// so the closeHandler function usually equates to one of the buttons
	if (noAction != false) {
		this.controller.closeHandler(this.controller);
	}
	this.controller.removeMovieClip();
}
// to draw the background on the canvas
SmallPopupWindowClass.prototype.drawCanvas = function(x, y, w, h, r) {
	//this.canvas.clear();
	// Put the nine sections of the image onto the canvas
	// Can we copy code from GlassTile?
	this.canvas.setSize(w,h);
}
// useful for debugging
SmallPopupWindowClass.prototype.getVersion = function() {
	//myTrace("get version");
	return this._version;
}

Object.registerClass("FSmallPopupWindowSymbol", SmallPopupWindowClass);
#endinitclip
