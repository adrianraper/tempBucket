function SubMenuClass() {
	this.init();
}
// inherit from MovieClip
SubMenuClass.prototype = new MovieClip();

// initialise
SubMenuClass.prototype.init = function() {
	//myTrace("setting up a subMenu " + this);
	
	// anti-distortion
	this.componentWidth = this._width;
	this.componentHeight = this._height;
	this._xscale = this._yscale = 100;

	// try to set good default tab behaviour
	this.tabChildren = false;
	this.tabEnabled = true;

	this.componentDepth = 0
	// v6.5.5.8
	// v6.5.5.8 CP has distinctive menus
	// v6.5.6.4 New SSS
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		this.boundingBox = this.attachMovie("subMenuBackground", "boundingBox", this.componentDepth++);
		// And on top of this we need a canvas that we can put the images on
		var canvas = this.createEmptyMovieClip("canvas",this.componentDepth++);
	} else {
		this.boundingBox = this.attachMovie("FGlassTileSymbol", "boundingBox", this.componentDepth++);
	}
	//this.setColour(0xffcc00);
	
	// for item positioning
	this.items = new Array;
	// v6.4.1 different layout due to scroll pane
	this.itemBottom = 14;
	this.itemSpacer = 2;
	this.itemDepth = 1;
	// v6.5.5.8 CP has distinctive menus
	// v6.5.6.4 New SSS
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		// Set the top and left for the exercise items
		this.itemTop = 134;
		this.itemMargin = 30;
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		// Set the top and left for the exercise items
		this.itemTop = 96;
		this.itemMargin = 43;
		this.itemSpacer = 3;
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		// Set the top and left for the exercise items
		this.itemTop = 45;
		this.itemMargin = 300;
		this.itemSpacer = 6;
	} else {
		this.itemTop = 10;
		this.itemMargin = 6;
	}
	
	this.boundingBox.onRelease = function() {};
	this.boundingBox.useHandCursor = false;
	this.boundingBox.onRollOut = function() {
		// delay the coordinate check a fraction as rollOut always triggers correctly
		// but it quite often thinks the mouse is still over the box
		// v6.4.1 Too unreliable, I think due to the menuItems causing rollOut to trigger
		// when you are clearly still over the bounding box. This happens when a mc over another
		// also has onRollOver and Out functions assigned. Do it with onMouseMove?
		this.checker = function() {
			clearInterval(this.checkInt);
			if (!this.hitTest(_root._xmouse, _root._ymouse, false)) {
				//trace("good rollOut");
				this.disappear = function(t, b, c, d) {
					clearInterval(this.hideInt);
					this._parent._visible = false;
					// v6.4.2.7 Remove the key listener added in menu.as when the menu is displayed
					//myTrace("remove listener from " + this._parent);
					Key.removeListener(this._parent.menuListener);
					// v6.5.6.5 To get rid of demo warning when menu closes
					//myTrace("bye bye the menu, so hide the demo warning");
					menuDemoHide();
				}
				this.hideInt = setInterval(this, "disappear", 500, t, b, c, d);		
			} else {
				//trace("but still over " + this);
			}
		}
		this.checkInt = setInterval(this, "checker", 250);
	}
	this.boundingBox.onRollOver = function() {
		clearInterval(this.hideInt);
		clearInterval(this.checkInt);		
	}

	// v6.4.1 Add in a scroll pane, whether or not we will use it.
	this.scrollPane = this.attachMovie("FScrollPaneSymbol", "scrollPane", this.componentDepth++);
	this.scrollPane._x = this.itemMargin;
	this.scrollPane._y = this.itemTop;
	this.scrollPane.setBorder(false);
	this.scrollPane.setHScroll(false);
	this.scrollPane.setVScroll(false);

	// v6.4.1 Whilst it appears that it would be neat to do it like this, you get problems with
	// fonts disappearing if you set scroll content like this. The long lesson from Orchid
	// is that you ues blob to set the content then add to it after getScrollContent.
	//this.scrollPane.setScrollContent(this.contentHolder); 
	this.scrollPane.setScrollContent("blob");
	this.contentHolder = this.scrollPane.getScrollContent();
	
	// v6.4.1 different layout due to scroll pane, set some defaults
	// v6.5.5.8 CP has distinctive menus
	// v6.5.6.4 New SSS
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		this.maxWidth = 421;
		this.maxHeight = 294;
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		this.maxWidth = 200;
		this.maxHeight = 250;
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		this.maxWidth = 558;
		this.maxHeight = 475;
	} else {
		this.maxWidth = 300;
		this.maxHeight = 400;
	}
}
// v6.4.1 New function used in layout
SubMenuClass.prototype.setMaxSize = function(maxW, maxH) {
	this.maxWidth = maxW;
	this.maxHeight = maxH;
}
// v6.4.1 There needs to be a maximum height after which scrolling kicks in
// But you don't set that here as this is only called externally as a rough guide
// before you know how many items are in it. this.format is the key place.
// (But the function is critically called internally and accurately).
// w and h are the total external dimensions, so reduce to find the scroll pane dimensions
SubMenuClass.prototype.setSize = function(w, h) {
	if (h > this.maxHeight) {
		h = this.maxHeight;
	}
	if (w > this.maxWidth) {
		w = this.maxWidth;
	}
	this.componentWidth = w;
	this.componentHeight = h;
	//myTrace("set subMenu size to (" + w + "," + h +")");
	this.boundingBox.setSize(w, h);
	// v6.5.5.8 CP has distinctive menus
	// v6.5.6.4 New SSS
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		var paneW = 180;
		var paneH = h - (this.itemTop + this.itemBottom);
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		var paneW = 200;
		var paneH = h - (this.itemTop + this.itemBottom);
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		var paneW = 246;
		var paneH = h - (this.itemTop + this.itemBottom);
	} else {
		var paneW = w - (2*this.itemMargin);
		var paneH = h - (this.itemTop + this.itemBottom);
	}
	this.scrollPane.setSize(paneW, paneH);
}
SubMenuClass.prototype.getSize = function() {
	return {width:this.componentWidth, height:this.componentHeight };
}
SubMenuClass.prototype.setColour = function(c) {
	//myTrace("set colour to " + c + " of " + this.boundingBox);
	// v6.4.1 Scroll pane will need to be the same colour
	//this.backgroundColour = c;
	this.boundingBox.setColour(c);
	this.scrollPane.setStyleProperty("background", c);
}
SubMenuClass.prototype.addItem = function(item) {
	//myTrace("add item " + item.caption + " id=" + item.id + " action=" + item.fileName);
	//myTrace("add item " + item.caption + " example=" + item.example);
	// v6.4.3 use filename not action
	//var initObj = {id:item.id, action:item.action};
	// v6.5.4.1 case sensitive variable name
	//var initObj = {id:item.id, action:item.filename};
	// v6.5.5.8 Add extra information for Clear Pronunciation
	//var initObj = {id:item.id, action:item.fileName};
	var initObj = {id:item.id, action:item.fileName, example:item.example};
	/*
	var thisItem = this.attachMovie("menuItem","item"+item.id,this.itemDepth++,initObj);
	thisItem.id = item.id;
	thisItem.action = item.action;
	thisItem.caption.text = item.caption;
	//myTrace("itemID=" + thisItem.id);
	thisItem.onRelease = function() {
		myTrace("clicked id=" + this.id);
		_root.controlNS.onMenuPress(this.id, this.action);
	}
	*/
	menuClick = function() {
		//myTrace("clicked " + this.id + " on " + this.action); 
		// v6.4.1 Added in the contentHolder in the scrollPane
		//this._parent._visible = false;
		this._parent._parent._parent._visible = false;
		_global.ORCHID.root.controlNS.onMenuPress(this.id, this.action);
	}
	menuDemoClick = function() {
		//myTrace("clicked " + this);
		_global.ORCHID.root.buttonsHolder.MessageScreen.demoWarning.notInDemo._visible = true;
	}
	// v6.5.6.5 Get rid of demo warning when menu hides
	menuDemoHide = function() {
		//myTrace("clicked " + this);
		_global.ORCHID.root.buttonsHolder.MessageScreen.demoWarning.notInDemo._visible = false;
	}
	// v6.5.5.8 Clear Pronunciation has more menu options
	menuRollOver = function() {
		//myTrace("menuItemRollOver for " + this.example + " on " + this._parent._parent._parent);
		//myTrace("3=" +this._parent._parent._parent.getEnabled() + " 2=" +this._parent._parent.getEnabled() + " 1=" +this._parent.getEnabled()  + " 0=" +this.getEnabled());
		// call the function on the subMenu (which is three levels up)
		this._parent._parent._parent.showExerciseExample(this.example);
	}
	// v6.4.1 Add into the content holder in the scroll pane rather than the root
	//var thisItem = this.attachMovie("FGraphicButtonSymbol","item"+item.id,this.itemDepth++,initObj);
	// v6.5.6.4 New SSS Note that the colour of the text of the exercise name is IN the menuItemBtn in the fla!
	var thisItem = this.contentHolder.attachMovie("FGraphicButtonSymbol","item"+item.id,this.itemDepth++,initObj);
	thisItem.setTarget("menuItemBtn");

	// v6.4.3 Adding the 'done' indicator - at present this is the bar, but it might be much more sensible to just have a tick
	// Or you could just make it part of the menuItemBtn mc - that way it is more interface specific. Except that because
	// the menuItemBtn goes through FGraphicButton, I can't directly call things like updateProgress on the indicator.
	// So make a second component, one for main menus and one for submenu items. I could put a holder in for x, y settings I suppose
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) {
		var initObj = {height:12, width:8, lineThick:1, doneFill:0xEC1C24};
	// v6.5.4.1 Active Reading
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ar") >= 0) {
		var initObj = {height:12, width:8, lineThick:1, doneFill:0xEAD546}; 
	// v6.5.5.5 English for Hotel Staff
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("sky/efhs") >= 0) {
		var initObj = {height:12, width:8, lineThick:1, doneFill:0xAD002B}; 
	// v6.5.6.6 Access UK
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("york/auk") >= 0) {
		var initObj = {height:12, width:8, lineThick:1, doneFill:0x383838}; 
	// v6.5.5.8 Clear Pronunciation
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		var initObj = {height:12, width:12, lineThick:1, doneFill:0x1E4447, allFill:0xFFFFFF, outFill:0xFFFFFF, _y:3}; 
	// v6.5.5.8 Clear Pronunciation 2
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		var initObj = {height:12, width:12, lineThick:1, doneFill:0x1E4447, allFill:0xFFFFFF, outFill:0xFFFFFF, _y:0}; 
	// v6.5.6.4 New SSS
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		var initObj = {_y:8};
	} else {
		var initObj = {height:12, width:8, lineThick:1};
	}

	// v6.5.6.5 For disabled demo items, hide the progress indicator
	if ((item.enabledFlag & _global.ORCHID.enabledFlag.disabled) && 
		(_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("demo")>=0)) {
			//myTrace("no indicator as disabled demo");
	} else {
		var thisProgressIndicator = thisItem.attachMovie("FSubProgressIndicatorSymbol", "progressIndicator", 1, initObj);
		//myTrace("add indicator=" + thisProgressIndicator); 
	}
			
	// v.3.4 Allow items to be present but disabled (mostly for demo menus)
	// v6.4.2.7 Can you be more specific? So if it is a demo, give a message when you click?
	if (item.enabledFlag & _global.ORCHID.enabledFlag.disabled) {
		//myTrace("set " + item.caption + " to disabled");
		if (_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("demo")>=0) {
			// v6.5.6.5 For CP and SSSV9 demo, can you show the thumbnails on mouseOver even for disabled items?
			// Yes, but you HAVE to call this before you disable the item.
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
				_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0 ||
				_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
				//myTrace("disabled, but allow rollOver");
				thisItem.setRollOverAction(menuRollOver);
			}
			thisItem.setEnabled(false);
			thisItem.onRelease = menuDemoClick;
		} else {
			thisItem.setEnabled(false);
		}
	} else {
		// v6.5.5.8 Clear Pronunciation has more menu options
		// v6.5.6.4 New SSS
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			thisItem.setRollOverAction(menuRollOver);
		}
		thisItem.setReleaseAction(menuClick);
	}
	// v6.5.6.4 New SSS
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		thisItem.fixedWidth=true;
	}
	//myTrace("setting label to " + item.caption);
	thisItem.setLabel(item.caption);
	this.items.push({id:item.id, mc:thisItem});
}

// v6.4.3 Now pass the scaffold so you can display whether exercises have been completed or not
//SubMenuClass.prototype.formatItems = function() {
SubMenuClass.prototype.formatItems = function(scaffoldSubList) {
	var numItems = this.items.length;
	var itemDim = this.items[0].mc.getSize();
	// v6.4.1 different layout due to scroll pane
	var itemW = itemDim.width + (2*this.itemMargin);
	//var itemW = itemDim.width;
	//myTrace("menu item width=" + itemDim.width + ", 2*margin=" + (2*this.itemMargin));
	var itemH = itemDim.height;
	// v6.4.1 Cope with scroll bar if necessary
	// First, how big would you need to be if no scrolling?
	var totalH = numItems * (itemH + this.itemSpacer) + this.itemTop + this.itemBottom;
	// So, do you need to scroll?
	//trace("totalH=" + totalH);
	if (totalH > this.maxHeight) {
		this.scrollPane.setVScroll(true);
		itemW += 16;
	} else {
		this.scrollPane.setVScroll(false);
	}
	// v6.4.1 menuItems fit snuggly in the scroll pane
	var thisTop = 0;
	var thisLeft = 0;
	for (var i=0; i<numItems; i++) {
		this.items[i].mc._x = thisLeft;
		this.items[i].mc._y = (i * (itemH + this.itemSpacer)) + thisTop;
		// v6.4.3 Updating the 'done' indicator - at present this is the bar, but it might be much more sensible to just have a tick
		// or some other kind of on/off indicator.
		//_global.myTrace("subItem " + i + " done=" + scaffoldSubList[i].progress.numExercisesDone[0]); 
		//myTrace("indicator in item = " + this.items[i].mc.progressIndicator);
		this.items[i].mc.progressIndicator.setProgress(scaffoldSubList[i].progress.numExercisesDone[0], scaffoldSubList[i].progress.numExercises);
		// and position it (difficult to do on the interface, which is a shame)
		// But setting _x to the left impacts the position of the whole menuItem which is not what I want
		// v6.5.6.4 New SSS Elsewhere I set the x for the blob in SSS, so don't override it here
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		} else {
			this.items[i].mc.progressIndicator._y=2;
		}
		//myTrace("update progress to " + scaffoldSubList[i].progress.numExercisesDone[0] + " of " + scaffoldSubList[i].progress.numExercises + " x=" + this.items[i].mc.progressIndicator._x + " y=" + this.items[i].mc.progressIndicator._y); 
	}
	var depth = this.items[numItems-1].mc._y + itemH + (this.itemTop + this.itemBottom);
	// v6.5.5.8 CP has distinctive menus
	// v6.5.6.4 New SSS
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		// The menu never changes size
	} else {
		this.setSize(itemW, depth);
	}
	//myTrace("menu width=" + itemW);
	this.scrollPane.refreshPane();
}
// v6.5.5.8 Clear Pronunciation has special features
// v6.5.6.4 New SSS
SubMenuClass.prototype.setUnitTitles =function(unitCaption, progressCaption) {
	//myTrace("trying to set unit caption to " + this);
	this.boundingBox.unitCaption.text = unitCaption;
	this.boundingBox.progressCaption.text = progressCaption;
}
SubMenuClass.prototype.setUnitImages =function(image1, image2) {
	//var mediaDepth = Number(_global.ORCHID.mediaDepth);
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		// Images
		// gh#869 for unification change filename to fileName
		var mediaItem1 = {fileName:image1};
		var mediaItem2 = {fileName:image2};
	
		var myFile1 = _global.ORCHID.root.objectHolder.getFullMediaPath(mediaItem1);
		var initObj1 = {jbURL:myFile1, jbStretch:false, jbMediaType:"picture", _x:20, _y:51 };
		var myFile2 = _global.ORCHID.root.objectHolder.getFullMediaPath(mediaItem2);
		var initObj2 = {jbURL:myFile2, jbStretch:false, jbMediaType:"picture", _x:200, _y:51};
							
		//myTrace("add unit pictures " + myFile1 + ", " + myFile2);
		// v6.5.5.8 If these are swf animations, they play but don't react to mouse over
		// image1Holder is hardcoded onto subMenuBackground mc in buttons CP.fla
		// How about I add them to the content rather than the background? You get odd x and y, but the animation reacts to the mouse.
		// What is on top of the bounding box? Nothing, but we set all sorts of onRollOver that I guess disable it and stuff on it.
		//var image1Holder = this.contentHolder.createEmptyMovieClip("imageHolder1", this.itemDepth++);
		//var myPicture2 = this.boundingBox.image2Holder.attachMovie("mediaHolder", "MediaHolder2", mediaDepth++, initObj2);
		// v6.5.6 I wonder if this is the same as the thumbnail? SHouldn't be since it is only run once
		var myPicture1 = this.canvas.attachMovie("mediaHolder", "MediaHolder1", this.itemDepth++, initObj1);
		var myPicture2 = this.canvas.attachMovie("mediaHolder", "MediaHolder2", this.itemDepth++, initObj2);
		
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		// Images
		var mediaItem1 = {filename:image1};
	
		var myFile1 = _global.ORCHID.root.objectHolder.getFullMediaPath(mediaItem1);
		var initObj1 = {jbURL:myFile1, jbStretch:false, jbMediaType:"picture", _x:26, _y:54 };
							
		var myPicture1 = this.canvas.attachMovie("mediaHolder", "MediaHolder1", this.itemDepth++, initObj1);
		
	// v6.5.6.4 New SSS
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		// Images
		var mediaItem1 = {filename:image1};
	
		var myFile1 = _global.ORCHID.root.objectHolder.getFullMediaPath(mediaItem1);
		var initObj1 = {jbURL:myFile1, jbStretch:false, jbMediaType:"picture", _x:20, _y:0 };
							
		//myTrace("add unit pictures " + myFile1 + ", " + myFile2);
		var myPicture1 = this.canvas.attachMovie("mediaHolder", "MediaHolder1", this.itemDepth++, initObj1);
	}
}
// v6.5.6.4 New SSS
SubMenuClass.prototype.showExerciseExample =function(example) {
	//var mediaDepth = Number(_global.ORCHID.mediaDepth);
	//myTrace("showExerciseExample for " + example);
	
	// Images
	// gh#869
	var mediaItem1 = {fileName:example};

	var myFile1 = _global.ORCHID.root.objectHolder.getFullMediaPath(mediaItem1);
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		var initObj1 = {jbURL:myFile1, jbStretch:false, jbMediaType:"picture", _x:236, _y:142};
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		var initObj1 = {jbURL:myFile1, jbStretch:false, jbMediaType:"picture", _x:280, _y:96}; 
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		var initObj1 = {jbURL:myFile1, jbStretch:false, jbMediaType:"picture", _x:40, _y:150}; 
	}
	
	//myTrace("trying to add picture " + myFile1 + " at x=" + initObj1._x);
	//var myPicture1 = this.boundingBox.exampleHolder.attachMovie("mediaHolder", "MediaHolder1", mediaDepth++, initObj1);
	// v6.5.6 If you are loading content from another domain, what happens is that the first thumbnail stays visible.
	// It's fine if content and swf are in the same domain. Very odd.
	// So get the depth of the existing image, if there is one.
	if (this.canvas.MediaHolder3) {
		var thumbnailDepth = this.canvas.MediaHolder3.getDepth();
	} else {
		var thumbnailDepth = this.itemDepth++;
	}
	//var myPicture1 = this.canvas.attachMovie("mediaHolder", "MediaHolder3", this.itemDepth++, initObj1);
	var myPicture1 = this.canvas.attachMovie("mediaHolder", "MediaHolder3", thumbnailDepth, initObj1);
}

// allow the use of a close button
SubMenuClass.prototype.setCloseButton = function(enabled, depth) {
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		if (enabled) {
			// add the button component and associate it with the close button mc
			var closeButton = this.attachMovie("FGraphicButtonSymbol", "closeButton", depth);
			//closeButton.setEnabled(false);
			closeButton.setTarget("exitBtn");
			closeButton.setReleaseAction(this.closePane);

			// put it in top right corner
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
				closeButton._x = 394;
				closeButton._y = 6;
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
				closeButton._x = 436;
				closeButton._y = 6;
			} else {
				// New SSS
				closeButton._x = 527;
				closeButton._y = 0;
			}
		}
		this.hasCloseButton = enabled;
	}
}
// and add event handlers
SubMenuClass.prototype.setCloseHandler = function(newHandler) {
	this.closeHandler = newHandler;
};
SubMenuClass.prototype.closePane = function(noAction) {
	var thisSub = this._parent;
	//myTrace("subMenu closePane=" + thisSub);
	clearInterval(thisSub.hideInt);
	clearInterval(thisSub.checkInt);
	thisSub._visible = false;
	// v6.4.2.7 Remove the key listener added in menu.as when the menu is displayed
	Key.removeListener(thisSub._parent.menuListener);
	// v6.5.6.5 Hide the demo warning when menu closes
	//myTrace("closing the menu, so hide the demo warning");
	menuDemoHide();
}
//
// end of component
