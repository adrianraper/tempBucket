// v6.3.4 New
menuNS.displaySubMenu = function() {
	//myTrace("displaySubMenu, enabledFlag= " + this.enabledFlag + ", id=" + this.id + ", caption=" + this.caption + ", unit=" + this.unit);
	// v6.3.3 Add the reference in here to the new interface holder
	// v6.3.6 Add ability to hold a scrolling screen of units
	var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
	if (menuContainer == undefined) {
		menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen;
	}
	// is this the first time to display?
	if (menuContainer.menuList == undefined) {
		menuContainer.menuList = new Array();
	}
	//myTrace("display sub menu for " + this.id);
	// has the sub menu already been created?
	var displayed = false;
	for (var i in menuContainer.menuList) {
		//myTrace("check on " + menuContainer["sub"+menuContainer.menuList[i]]);
		if (menuContainer.menuList[i] == "subMenu"+this.id) {
			menuContainer["subMenu"+this.id]._visible = true;
			displayed = true;
		} else {
			menuContainer[menuContainer.menuList[i]]._visible = false;
		}
	}
	if (!displayed) {
		var menuItems = _global.ORCHID.menuXML.getMenuItemByID(this.id);
		// v6.5.2 What about units where the first exercise is autoplay? Don't want any kind of display thank you very much
		if (menuItems[0].enabledFlag & _global.ORCHID.enabledFlag.autoplay) {
			myTrace("first exercise is autoplay " + thisItem.id);
			var thisItem = menuItems[0];
			//_global.ORCHID.root.controlNS.onMenuPress(thisItem.id, thisItem.filename);
			_global.ORCHID.root.controlNS.onMenuPress(thisItem.id, thisItem.fileName);
			// any need to keep going?
			return;
		}
		var thisSub = menuContainer.attachMovie("FSubMenuSymbol", "subMenu"+this.id, menuNS.depth++);
		var menuDim = this.getSize();
		// v6.3.4 This really needs to be set in the buttons somehow
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ro") >= 0) {
			thisSub._x = Math.floor(this._x + (menuDim.width * 0.45));
			thisSub._y = Math.floor(this._y + (menuDim.height * 0.35));
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) {
			thisSub._x = Math.floor(this._x + (menuDim.width * 0.45));
			thisSub._y = Math.floor(this._y + (menuDim.height * 0.35));
		// v6.5.6.4 New SSS
		//} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("Clarity/SSS") >= 0) {
		//	thisSub._x = Math.floor(this._x + (menuDim.width * 0.95));
		//	thisSub._y = Math.floor(this._y + (menuDim.height * 0));
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			thisSub._x = Math.floor(this._x - 30);
			thisSub._y = Math.floor(this._y - 30);
		} else {
			thisSub._x = Math.floor(this._x + (menuDim.width * 0.45));
			thisSub._y = Math.floor(this._y + (menuDim.height * 0.35));
		}
		// v6.5.5.8 CP has distinctive menus
		// v6.5.6.4 New SSS
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
			thisSub.setSize(421,294);
		} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			thisSub.setSize(558,475);
		} else {
			thisSub.setSize(200,100);
		}
		//v6.3.6 Change to style branding
		//if (_global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.tileColour != undefined) {
		//	thisSub.setColour(_global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.tileColour);
		//}
		// v6.5.6.4 New SSS
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			// I want it to be transparent
			//thisSub.setColour(0xFFFFFF);
		} else {
			if (_global.ORCHID.root.buttonsHolder.buttonsNS.interface.tileColour != undefined) {
				thisSub.setColour(_global.ORCHID.root.buttonsHolder.buttonsNS.interface.tileColour);
			}
		}
		// v6.3.5 What to do about units that have no exercises?
		//myTrace("menuItems.length=" + menuItems.length);
		if (menuItems.length == 0 || menuItems == undefined) {
			menuItems = new Array();
			//myTrace("add a blank caption");
			menuItems.push({caption:_global.ORCHID.literalModelObj.getLiteral("noExercise", "messages"), enabledFlag:_global.ORCHID.enabledFlag.disabled});
		}

		for (var i=0; i<menuItems.length; i++) {
			thisSub.addItem(menuItems[i]);
		};
		// v6.4.3 Can I also show whether or not this exercise has already been completed?
		//myTrace("call to format subMenu for " + this.id);
		var scaffoldSubList = _global.ORCHID.course.scaffold.getItemExercises(this.id);
		//thisSub.formatItems();
		thisSub.formatItems(scaffoldSubList);
		
		// v6.5.5.8 Clear Pronunciation has distinctive menus
		// v6.5.6.4 New SSS
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
			_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
				
			var scaffoldSubMenu = _global.ORCHID.course.scaffold.getObjectByID(this.id);
			// Note that SSS doesn't use a title caption or progress
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
				//myTrace("scaffold progress = " + scaffoldSubMenu.progress.numExercisesDone[0]);
				var progressPercent = 100 * scaffoldSubMenu.progress.numExercisesDone[0] / scaffoldSubMenu.progress.numExercises;
				// Rounding function
				var dec=Math.pow( 10, 0);
				progressPercent = Math.round(progressPercent*dec)/dec;
				var substList = [{tag:"[x]", text:progressPercent}];
				var progressCaption = _global.ORCHID.root.objectHolder.substTags(_global.ORCHID.literalModelObj.getLiteral("yourCompletion", "labels"), substList);
				//myTrace("progressCaption=" + progressCaption);
				// You can either shave the caption (which looks like Unit 1: Fill/Pill), or you can hope the unit number is corrrectly set.
				//var titleCaption = this.caption;
				// Introduction (unit 25) gets the name from caption. Or rather it has no name.
				if (this.unit>0 && this.unit<=25) {
					var titleCaption = "Unit " + this.unit;
				} else {
					//var titleCaption = this.caption;
					var titleCaption = "";
				}
				thisSub.setUnitTitles(titleCaption, progressCaption);
				// v6.5.5.8 Now move this left a bit so you can add a close button
				//var initObj = {height:13, width:13, lineThick:1, outFill:0xFFFFFF, allFill:0xFFFFFF, doneFill:0x1E4447, _x:390, _y:8}; 
				var initObj = {height:13, width:13, lineThick:1, outFill:0xFFFFFF, allFill:0xFFFFFF, doneFill:0x1E4447, _x:300, _y:10}; 
				if (scaffoldSubMenu.progress.numExercisesDone[0]==0 || scaffoldSubMenu.progress.numExercisesDone[0]==undefined) {
				} else {
					thisSub.attachMovie("FProgressIndicatorSymbol", "progressIndicator", menuNS.depth++, initObj);
					thisSub.progressIndicator.setProgress(scaffoldSubMenu.progress.numExercisesDone[0], scaffoldSubMenu.progress.numExercises);
				}
			}			
			// Get the images to display from the scaffold
			//myTrace("image1 is " + scaffoldSubMenu.image1 + " for " + scaffoldSubMenu.caption);
			var mediaItem1 = scaffoldSubMenu.image1;
			// v6.5.6.4 New SSS only has 1 image, but a null should be fine
			var mediaItem2 = scaffoldSubMenu.image2;
			thisSub.setUnitImages(mediaItem1, mediaItem2);
			// And add in a close Button
			thisSub.setCloseButton(true, menuNS.depth++); 
		}
		
		// v6.5.6.4 New SSS, has a fixed menu size and position
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			// I want to express these coords as absolute
			var refPoint = new Object();
			refPoint.x=100;
			refPoint.y=100;
			//myTrace("menuContainer.x=" + menuContainer._x + " .y=" + menuContainer._y);
			menuContainer.globalToLocal(refPoint);
			thisSub._x = refPoint.x;
			thisSub._y = refPoint.y; 
			//myTrace("thisSub.x=" + thisSub._x + " .y=" + thisSub._y);
		} else {

			// v6.4.2.8 Need to make sure that this doesn't go off the screen. 
			var subMenuDim = thisSub.getSize();
			// Since courseMenu might not be at (0,0) we need to make the point global
			var refPoint = new Object();
			refPoint.x=0;refPoint.y=0;
			thisSub.localToGlobal(refPoint);
			//myTrace("thisSub.items=" + menuItems.length);
			//myTrace("thisSub.width=" + subMenuDim.width + " .height=" + subMenuDim.height); 
			//myTrace("thisSub.globalX=" + refPoint.x + " .localX=" + thisSub._x + " .stage=" + Stage.width); 
			//if (thisSub._x + subMenuDim.width > Stage.width) {
			if (refPoint.x + subMenuDim.width > Stage.width) {
				// v6.5.5.8 Missing minus in the equation
				//thisSub._x = Stage.width - subMenuDim.width - 10 (refPoint.x - thisSub._x);
				thisSub._x = Stage.width - subMenuDim.width - 10 - (refPoint.x - thisSub._x);
				//myTrace("shift x to =" + thisSub._x); 
			}
			//if (thisSub._y + subMenuDim.height > Stage.height) {
			// v6.5.5.8 Lets measure it a little away from the edge
			//if (refPoint.y + subMenuDim.height > Stage.height) {
			if (refPoint.y + subMenuDim.height > Stage.height - 10) {
				thisSub._y = Stage.height - subMenuDim.height - 10 - (refPoint.y-thisSub._y);
			}
		}
		// add it to the list so you don't create it again
		//myTrace("add " + this.id + " to " + menuContainer.menuList.toString());
		menuContainer.menuList.push("subMenu"+this.id);
		
		// v6.4.2.7 Can I listen for Esc key to clear this menu?
		thisSub.menuListener = new Object();
		thisSub.menuListener.thisSub = thisSub;
		thisSub.menuListener.onKeyDown = function () {
			if (Key.getAscii() == Key.ESCAPE) {
				//myTrace("esc the menu, I am " + thisSub);
				Key.removeListener(thisSub.menuListener);
				thisSub._visible = false;
			}
		}
		// v6.4.2.7 Can I listen for Esc key to clear this menu?
		Key.addListener(thisSub.menuListener); 
		//myTrace("add a key listener to " + thisSub);
		
	}
}
// v6.3.4 New
menuNS.internalDisplayMainMenu = function(items, progressItems) {
	// v6.3.3 Add the reference in here to the new interface holder
	// v6.3.6 Add ability to hold a scrolling screen of units
	var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
	if (menuContainer == undefined) {
		menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen;
	}
	
	//v6.3.6 Tried a scrollPane, but don't like it (no transparency, stilted, scrollbar clashes with depths)
	//var menuHolder = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
	//menuHolder.setSize(500,300);
	//menuHolder.setScrollContent("blob");
	//var menuContainer = menuHolder.getScrollContent();
	
	//v6.3.6 Set max and min for currently displayed menus. Use an outline in menuScreen
	// if the x and y of any menu are within this shape, they will be shown
	var menuOutline = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsOutline;
	//myTrace("menuOutline=" + menuOutline);
	if (menuOutline == undefined) {
		// if no outline (most likely) - set the whole stage to avoid any scrolling
		menuContainer.leftX = 0;
		menuContainer.rightX = _global.ORCHID.root.buttonsHolder.MenuScreen._width;
		menuContainer.topY = 0;
		menuContainer.bottomY = _global.ORCHID.root.buttonsHolder.MenuScreen._height;
		menuContainer.vScrollAmount = _global.ORCHID.root.buttonsHolder.MenuScreen._height;
	} else {
		menuOutline._visible = false; // this is now done in screens (But it doesn't work?)
		menuContainer.leftX = menuOutline._x;
		menuContainer.topY = menuOutline._y;
		menuContainer.rightX = menuOutline._x + menuOutline._width;
		menuContainer.bottomY = menuOutline._y + menuOutline._height;
		//myTrace("outline x=" + menuContainer.leftX + ", y=" + menuContainer.topY + ", right=" + menuContainer.rightX + ", bottom=" + menuContainer.bottomY);
		// hardcoded for starters. This is one row depth in APO. What about TB etc?
		// I guess that in the absence of any animated effect, one row is easiest on the eye
		// So can I measure the depth between one row and the next? 
		// You cannot just assume it is difference between 0 and 1, or 0 and 5.
		// So either need to measure target height, or loop until the difference is reasonable?
		// A menu like TB is all over the place. But I suppose we could diddle with it so it is OK.
		//menuContainer.vScrollAmount = 160; 
		menuContainer.vScrollAmount = 20; 
		for (var i=1; i<items.length; i++) {
			var thisDiff = (items[i].y - items[0].y);
			if (thisDiff > 20) {
				menuContainer.vScrollAmount = thisDiff;
				break;
			}
		}
		myTrace("use vScrollAmount=" + menuContainer.vScrollAmount);
	}
	menuContainer.unitsScroll = false;	
	//v6.4.1 Init for a new course
	//if (menuContainer.vscroll == undefined) menuContainer.vscroll = 0;
	menuContainer.vscroll = 0;
	
	// v6.3.6 Is this an old layout menu, now needing to fit the new layout?
	//myTrace("x and y of menu 1 are " + items[0].x + ", " + items[0].y);
	if (_global.ORCHID.session.version.atLeast("6.4")) {
		_global.ORCHID.root.buttonsHolder.MenuScreen.oldMenuLayout = false;
	} else {
		// so not a new layout, does it match the expected old layout coordinates?
		if (items[0].x == 25 && items[0].y == 40) {
			myTrace("this is an old menu layout, rearrange it");
			_global.ORCHID.root.buttonsHolder.MenuScreen.oldMenuLayout = true;
		} else {
			_global.ORCHID.root.buttonsHolder.MenuScreen.oldMenuLayout = false;
		}
	}
	for (var i in items) {
		// v6.3.6 Rearrange coordinates
		if (_global.ORCHID.root.buttonsHolder.MenuScreen.oldMenuLayout) {
			if (i > 4) {
				items[i].y = 230
			} else {
				items[i].y = 70
			}
			if (i == 0 || i == 5) items[i].x = 24;
			if (i == 1 || i == 6) items[i].x = 156;
			if (i == 2 || i == 7) items[i].x = 288;
			if (i == 3 || i == 8) items[i].x = 420;
			if (i == 4 || i == 9) items[i].x = 552;
			//myTrace("i=" + i + ", x changed to " + items[i].x + " and y to " + items[i].y);
		}
		// v6.3.6 Do you have any need for scrolling?
		//myTrace(i + " y=" + items[i].y + " bottom=" + menuContainer.bottomY); 
		if (items[i].y > menuContainer.bottomY) {
			menuContainer.unitsScroll = true;
		}
		//myTrace("add menu with id=" + items[i].id +  " + picture " + items[i].picture);
		if (menuContainer["mainMenu"+items[i].id] == undefined) {
			var thisMenu = menuContainer.attachMovie("FGraphicButtonSymbol", "mainMenu"+items[i].id, menuNS.depth++);
			//myTrace("added menu at depth " + menuNS.depth);
			// you can either display library movies or straight pictures
			// v6.3.6 To let this new interface work with older APO created courses, we need
			// to convert Menu-BC- into Menu-APL-. Then remember that Menu-BC- cannot be used
			// again! Mind you, to handle this fully you will need to edit the x,y coordinates
			// from menu.xml as well. Shouldn't be too bad. Need a clean way to know you have an
			// old layout. That is done in a separate conditional after the name handling since
			// it is independent of that.
			if (items[i].picture.indexOf(".") > 0) {
				// v6.3.4 Special override for APO to avoid having to alter teacher code for now
				// This will turn Menu-BC-x.swf into Menu-BC-x to be read from the library
				if (items[i].picture.indexOf("Menu-BC-") == 0) {
					//thisMenu.setTarget(items[i].picture.substr(0,items[i].picture.indexOf(".")));
					//myTrace("override menu target from " + items[i].picture + " to Menu-APL-" + items[i].picture.substring(8,items[i].picture.indexOf(".")));
					thisMenu.setTarget("Menu-APL-" + items[i].picture.substring(8,items[i].picture.indexOf(".")));
				} else {
					//myTrace("try to load ext menu=" + _global.ORCHID.paths.brandMovies + items[i].picture);
					// v6.3.5 Update paths folder name
					//thisMenu.setTarget(_global.ORCHID.paths.root + _global.ORCHID.paths.brand + items[i].picture);
					thisMenu.setExternalTarget(_global.ORCHID.paths.brandMovies + items[i].picture);
				}
			} else {
				if (items[i].picture.indexOf("Menu-BC-") == 0) {
					//myTrace("override menu target from " + items[i].picture + " to Menu-APL-" + items[i].picture.substring(8));
					thisMenu.setTarget("Menu-APL-" + items[i].picture.substring(8));
				} else {
					//myTrace("use menu target " + items[i].picture);
					thisMenu.setTarget(items[i].picture);
				}
			}
			
			//myTrace("set caption to " + items[i].caption);
			//thisMenu.setLabel(items[i].caption);
			//thisMenu._x = items[i].x;
			//thisMenu._y = items[i].y;
			thisMenu.id = items[i].id;
			// v6.5.4.1 Add unit number
			//myTrace("menu item unit=" + items[i].unit);
			thisMenu.unit = items[i].unit;
			//thisMenu.target.caption.multiline = false;
			//thisMenu.target.caption.wordWrap = false;
			// v6.4.2.5 Pass the enabledFlag to the release action
			thisMenu.enabledFlag = items[i].enabledFlag;
			// v6.5.5.8 CP also wants the menu caption
			thisMenu.caption = items[i].caption;
			// v6.3.6 Add Menu namespace
			//thisMenu.setReleaseAction(displaySubMenu);
			// v6.4.2.5 Or leave the menu inactive if disabled? Yes, this seems to work
			if (thisMenu.enabledFlag & _global.ORCHID.enabledFlag.disabled) {
				//myTrace("disabled menu " + items[i].caption);
				thisMenu.setEnabled(false);
			} else {
				thisMenu.setReleaseAction(MenuNS.displaySubMenu);
			}
			// v6.4.3 Add the progress indicator to the menu items here?
			//myTrace("add progress indicator for menu " + i);
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) {
				var initObj = {height:23, width:12, lineThick:1, doneFill:0xEC1C24};
				//var initObj = {height:23, width:12, lineThick:1, doneFill:0xEC1C24, _x:-20}; 
			// v6.5.6 Study Skills Success
			// v6.5.6.4 New SSS
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
				var initObj = {height:28, width:11, lineThick:1, doneFill:0x371987, _x:-48, _y:14};
			// v6.5.4.1 Active Reading
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ar") >= 0) {
				var initObj = {height:28, width:14, lineThick:1, doneFill:0xED2024, _x:-18, _y:6}; 
			// v6.5.4.1 Clarity English Success
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ces") >= 0) {
				var initObj = {height:23, width:10, lineThick:1, doneFill:0xE93938, _x:-16, _y:2}; 
			// v6.5.5.5 Clear Pronunciation
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
				var initObj = {height:13, width:13, lineThick:1, outFill:0xFFFFFF, allFill:0xFFFFFF, doneFill:0x1E4447, _x:-18, _y:6}; 
			// v6.5.5.5 English for Hotel Staff
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("sky/efhs") >= 0) {
				var initObj = {height:23, width:10, lineThick:1, doneFill:0xAD002B, _x:0, _y:2};
			} else {
				var initObj = {height:23, width:12, lineThick:1};
			}
			// v6.4.3 I can't do onRollOver when the progInd is part of the menu button. Don't know why not, although
			// I am sure that it is to do with graphicButton.
			// Try making it at the same level. Well, onRollOver works, but only get one! And menu coords are not set yet. So go back.
			// v6.5.5.8 Clear Pronunciation wants no progress indicator if 0% or if it is the introduction unit
			//myTrace("progress, ex=" + progressItems[i].numExercisesDone[0]);
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 &&
				((progressItems[i].numExercisesDone[0]==0 || progressItems[i].numExercisesDone[0]==undefined) ||
				(thisMenu.unit<1 || thisMenu.unit>25))) {
			} else {
				thisMenu.attachMovie("FProgressIndicatorSymbol", "progressIndicator", menuNS.depth++, initObj);
				//initObj._x = thisMenu._x;
				//initObj._y = thisMenu._y;
				//menuContainer.attachMovie("FProgressIndicatorSymbol", "progressIndicator", menuNS.depth++, initObj);
				// and update it straight away?
				//myTrace("update menu progress to " + progressItems[i].numExercisesDone[0] + " of " + progressItems[i].numExercises); 
				thisMenu.progressIndicator.setProgress(progressItems[i].numExercisesDone[0], progressItems[i].numExercises);
				//myTrace("added pInd at depth " + menuNS.depth);
				//myTrace("I have onRollOver=" + thisMenu.progressIndicator.onRollOver);
				//thisMenu.progressIndicator.onRollOver = function() {
				//	_global.myTrace("you completed " + this.completed + " out of " + this.total);
				//}
			}
			
		} else {
			//myTrace("menu with name " + items[i].id + " already exists");
		}
		//myTrace("width=" + menuContainer["mainMenu"+items[i].id]._width + " scale=" + menuContainer["mainMenu"+items[i].id]._xscale);
	}
	
	if (menuContainer.unitsScroll) {

		myTrace("this menu needs scrolling",1);
		menuOutline._visible = true; 
		menuContainer.scrollDown = function(){
			var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
			if (menuContainer == undefined) {
				menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen;
			}
			//myTrace("scrollDown from this=" + menuContainer);
			menuContainer.vscroll += menuContainer.vScrollAmount;
			menuContainer.drawItems();
		}
		menuContainer.scrollUp = function(){
			var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
			if (menuContainer == undefined) {
				menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen;
			}
			//myTrace("scrollUp");
			menuContainer.vscroll -= menuContainer.vScrollAmount;
			menuContainer.drawItems();
		}
		_global.ORCHID.root.buttonsHolder.MenuScreen.unitsScrollDown_pb.setReleaseAction(menuContainer.scrollDown);
		_global.ORCHID.root.buttonsHolder.MenuScreen.unitsScrollUp_pb.setReleaseAction(menuContainer.scrollUp);		
		//_global.ORCHID.root.buttonsHolder.MenuScreen.unitsScrollDown_pb.setEnabled(true);
		//_global.ORCHID.root.buttonsHolder.MenuScreen.unitsScrollUp_pb.setEnabled(true);		
	}
	menuContainer.drawItems = function() {
		//myTrace("drawItems, vscroll=" + this.vscroll);
		var canScrollUp = false;
		var canScrollDown = false
		//myTrace("unitsHolder at x=" + this._x + ", y=" + this._y + " " + this);
		for (var i in items) {
			if (items[i].x >= this.leftx && 
				items[i].y >= (this.topy + this.vscroll) && 
				items[i].x <= this.rightx && 
				items[i].y <= (this.bottomy + this.vscroll)) {
				// OK to display
				var thisMenu = this["mainMenu"+items[i].id];
				//myTrace("menu at x=" + items[i].x + ", y=" + items[i].y + " " + items[i].caption);
				// v6.5.5.5 It will be much much easier to layout menus if the x and y are relative to unitsHolder
				// Oh, they are! Its just that CP had two instances of unitsHolder.
				thisMenu._x = items[i].x;
				thisMenu._y = items[i].y - this.vscroll;
				thisMenu._visible = true;
				//myTrace("show menu id=" + items[i].id);
			} else {
				// don't display this unit
				//myTrace("hide menu id=" + items[i].id + "x=" + items[i].x + " y=" + items[i].y + " left=" + this.leftx + " top=" + this.topy);
				//menuContainer["mainMenu"+items[i].id].setEnabled(false);
				this["mainMenu"+items[i].id]._visible = false;
			}
			// will there be any further scrolling down?
			if (items[i].y > this.bottomY + this.vscroll) {
				canScrollDown = true;
			}
			// and up?
			if (this.vscroll > 0) {
				canScrollUp = true;
			}
		}
		if (canScrollDown) {
			_global.ORCHID.root.buttonsHolder.MenuScreen.unitsScrollDown_pb.setEnabled(true);
		} else {
			_global.ORCHID.root.buttonsHolder.MenuScreen.unitsScrollDown_pb.setEnabled(false);
		}
		if (canScrollUp) {
			_global.ORCHID.root.buttonsHolder.MenuScreen.unitsScrollUp_pb.setEnabled(true);
		} else {
			_global.ORCHID.root.buttonsHolder.MenuScreen.unitsScrollUp_pb.setEnabled(false);
		}
	}
	// call it for the first time
	menuContainer.drawItems();
	
	// v6.3.6 Don't like the scrollpane method
	//menuHolder.refreshPane();
	//menuHolder.setVScroll("auto");
	//menuHolder.setHScroll(false);
	// This is a bodge to get captions accepted after the target has time to load
	// v6.3.6 It does not work for externally loaded menus, just not enough time.
	// Push from 500 to 1000 as a temp bodge on the bodge.
	var delayedCaptions = function() {
		clearInterval(delayedCaptionsInt);
		var captionTF = new TextFormat();
		for (var i in items) {
			var thisMenu = menuContainer["mainMenu"+items[i].id];
			thisMenu.setAutosize(true);
			//myTrace("set caption to " + items[i].caption + " position=" + items[i].captionPosition);
			if (items[i].captionPosition == "bc") {
				captionTF.align = "center";
			} else if (items[i].captionPosition == "br") {
				captionTF.align = "right";
			} else {
				captionTF.align = "left";
			}
			// v6.4.3 Tense Buster captions, some have brackets that would be nice on a second line
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) {
				var foundBracket = items[i].caption.indexOf("(");
				if (foundBracket>0) {
					items[i].caption = items[i].caption.substr(0,foundBracket) + newline + items[i].caption.substring(foundBracket);
				}
			// v6.5.5.0 And CCCS has Unit 1 How to be angry (or something like that), so put a new line to replace the second space.
			} else if ((_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("futureperfect/cccs") >= 0) &&
					(items[i].caption.toLowerCase().indexOf("unit")==0))	{
				var foundSecondSpace = items[i].caption.indexOf(" ",5);
				if (foundSecondSpace>0) {
					items[i].caption = items[i].caption.substr(0,foundSecondSpace) + newline + items[i].caption.substring(foundSecondSpace+1);
				}
			}				
			thisMenu.setLabel(items[i].caption, captionTF);
			// v6.5.4.3 Active Reading menu captions really want to vertical align to the centre, so that if we get two lines
			// then it will shift up a bit. This should be done in the button class based on a new parameter.
			// The default will be to not move it, which will match all other titles. It could be based on captionPosition at some point
			// This is all done in the buttons.fla with a call to setCaptionVerticalAlign on the frames of the target button mc.
			//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ar") >= 0) {
				//thisMenu.setCaptionVerticalAlign("centre");
				//thisMenu.setAutosize(true);
			//}
			
			// the GraphicButtonClass doesn't support the following method
			// and this is used in all ClarityEnglish programs.
			thisMenu.setCaptionPosition(items[i].captionPosition);
			thisMenu.setAlt(items[i].alt);
		}
	}
	// v6.4.2.6 Try not delaying for internal menus
	if (items[i].picture.indexOf(".") > 0) {
		var delayedCaptionsInt = setInterval(delayedCaptions, 1000);
	} else {
		delayedCaptions();
	}
	// v6.5.5.8 For Clear Pronunciation
	menuContainer.easeVert = function(from, to) {
		//myTrace("start ease for " + this);
		var startTime = new Date().getTime();
		var b = from;
		var c = to-from;
		var d = 1500;
		// this._y = to; return; // use this line to test that without easing everything is OK
		if (c == 0) {
			// trace("no need to move " + this);
			return;
		}
		this.easer = function(startTime, b, c, d) {
			var t = Math.floor(new Date().getTime()-startTime);
			//myTrace("in menuItem.easeVert with t=" + t + " b=" + b + " c=" + c + " d=" + d);
			if (t>=d) {
				clearInterval(this.easeItemInt);
				t = d;
				// set the final call at the end of the duration
			}
			//this._y = _global.ORCHID.easeOutQuad(t, b, c, d);
			// What sort of motion do you want?
			//this.vscroll = _global.ORCHID.easeOutQuad(t, b, c, d);
			this.vscroll = _global.ORCHID.easeInOutQuad(t, b, c, d);
			//this.vscroll = _global.ORCHID.easeInOutExpo(t, b, c, d);
			// this.vscroll = _global.ORCHID.easeOutBack(t, b, c, d);  // this is awful!
			this.drawItems();
		};
		this.easeItemInt = setInterval(this, "easer", 100, startTime, b, c, d);
		// this._y = to;
	};

}
/*
// v6.4.3 For adding in the progress indicator
menuNS.updateProgress = function(progress) {
	//myTrace("b:updateProgress, length=" + progress.length);
	// assume that the progress items are in the same order as the original menu items
	for (var i=0; i<this.menuItems.length; i++) {
		//myTrace("for menu=" + this.menuItems[i] + " progress=" + progress[i].numExercisesDone[0] + "/" + progress[i].numExercises);
		//trace("call on " + this.menuItems[i].progressIndicator + " through " + this.menuItems[i].progressIndicator.setProgress);
		//this.menuItems[i].displayProgress(progress[i].numExercisesDone, progress[i].numExercises);
		this.menuItems[i].progressIndicator.setProgress(progress[i].numExercisesDone[0], progress[i].numExercises);
		// v6.2 Now dig deeper so that you can show which exercises have been done
		//trace("get scaffold for item=" + progress[i].id);
		// just save the scaffold id onto each menu item for later interrogation of the scaffold
		//trace("menuItems.id was " + this.menuItems[i].id);
		this.menuItems[i].id = progress[i].id;
	}
}
*/
menuNS.displayMainMenu = function() {
	//trace("display main menu");
	// v6.3.4 Moved from view.as as not all menus want to do this
	var menuItems = _global.ORCHID.menuXML.getMenuItemByID(_global.ORCHID.course.scaffold.id);
	//for (var i in menuItems) {
	//	myTrace(menuItems[i].caption + " id=" + menuItems[i].id);
	//};
	var progressItems = _global.ORCHID.course.scaffold.getItemsByID(_global.ORCHID.course.scaffold.id);
	// v6.3.6 Add NS
	// v6.4.2.7 CUP menu merging
	// At this point, if I have a custom build menu, I can call that instead. It is assumed that the code
	// is in buttons.fla
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		_global.ORCHID.root.buttonsHolder.displayMainMenu(menuItems, progressItems); 
	} else {
		menuNS.internalDisplayMainMenu(menuItems, progressItems);
	}
}

menuNS.clearMenu = function() {
	//myTrace("clear the menu");
	// v6.4.2.7 CUP menu merging
	// At this point, if I have a custom build menu, I can call that instead. It is assumed that the code
	// is in buttons.fla
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		var menuRoot = _global.ORCHID.root.buttonsHolder.MenuScreen;
		menuRoot.menu._visible = false;
		// clear all the submenus
		menuRoot.menu.menuReset();
	} else {
		// v6.3.6 Add ability to hold a scrolling screen of units
		//var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen;
		var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
		if (menuContainer == undefined) {
			menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen;
		}
		for (var i in menuContainer) {
			if (((menuContainer[i]._name.indexOf("mainMenu") >= 0) ||
				 (menuContainer[i]._name.indexOf("subMenu") >= 0)) &&
				(typeof menuContainer[i] == "movieclip")) {
				//myTrace("remove " + _global.ORCHID.root.buttonsHolder.MenuScreen[i]._name);
				 menuContainer[i].removeMovieClip();
			}
		}
		menuContainer.menuList = undefined;
	}
	// v6.5.5.5 Specially for Military Test that has an audio on the menu screen that you need to stop before you go on.
	// I can't think of any other audio that might be playing intentionally whilst you move from menu to anything else?
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/placementtest") >= 0) {
		stopAllSounds();
	}
}
