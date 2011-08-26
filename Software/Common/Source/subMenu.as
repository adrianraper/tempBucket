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
	this.boundingBox = this.attachMovie("FGlassTileSymbol", "boundingBox", this.componentDepth++);
	//this.setColour(0xffcc00);
	
	// for item positioning
	this.items = new Array;
	this.itemTop = 10;
	// v6.4.1 different layout due to scroll pane
	this.itemBottom = 14;
	this.itemSpacer = 2;
	this.itemMargin = 6;
	this.itemDepth = 1;
	
	this.boundingBox.onRelease = function() {
	};
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
	this.maxHeight = 400;
	this.maxWidth = 300;
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
	//trace("set subMenu size to (" + w + "," + h +")");
	this.boundingBox.setSize(w, h);
	var paneW = w - (2*this.itemMargin);
	var paneH = h - (this.itemTop + this.itemBottom);
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
	//myTrace("add item " + item.caption + " id=" + item.id);
	// v6.4.3 use filename not action
	//var initObj = {id:item.id, action:item.action};
	// v6.5.4.1 case sensitive variable name
	//var initObj = {id:item.id, action:item.filename};
	var initObj = {id:item.id, action:item.fileName};
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
	// v6.4.1 Add into the content holder in the scroll pane rather than the root
	//var thisItem = this.attachMovie("FGraphicButtonSymbol","item"+item.id,this.itemDepth++,initObj);
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
	} else {
		var initObj = {height:12, width:8, lineThick:1};
	}
	var thisProgressIndicator = thisItem.attachMovie("FSubProgressIndicatorSymbol", "progressIndicator", 1, initObj);
			
	// v.3.4 Allow items to be present but disabled (mostly for demo menus)
	// v6.4.2.7 Can you be more specific? So if it is a demo, give a message when you click?
	if (item.enabledFlag & _global.ORCHID.enabledFlag.disabled) {
		//myTrace("set " + item.caption + " to disabled");
		if (_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("demo")>=0) {
			thisItem.setEnabled(false);
			thisItem.onRelease = menuDemoClick;
		} else {
			thisItem.setEnabled(false);
		}
	} else {
		thisItem.setReleaseAction(menuClick);
	}
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
		//myTrace("update progress to " + scaffoldSubList[i].progress.numExercisesDone[0] + " of " + scaffoldSubList[i].progress.numExercises); 
		this.items[i].mc.progressIndicator.setProgress(scaffoldSubList[i].progress.numExercisesDone[0], scaffoldSubList[i].progress.numExercises);
		// and position it (difficult to do on the interface, which is a shame)
		// But setting _x to the left impacts the position of the whole menuItem which is not what I want
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/xx") >= 0) {
		} else {
			this.items[i].mc.progressIndicator._y=2;
		}
	}
	var depth = this.items[numItems-1].mc._y + itemH + (this.itemTop + this.itemBottom);
	this.setSize(itemW, depth);
	//myTrace("menu width=" + itemW);
	this.scrollPane.refreshPane();
}
//
// end of component
