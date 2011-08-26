// these are the functions that need to be run on each menu item - main and sub
// If we were using components, they would be in the constructor function
// of the component, but set like this for development speed (?!)
this.mainMenuSetup = function(main) {
	//myTrace("theMenu:setting up functions for main=" + main);
	main.setOver = function() {
		//trace("current menu=" + this._parent.currentMenu);
		this._parent.menuItems[this._parent.currentMenu].reset();
		this.gotoAndStop("rollOver");
		//this.caption.textColor = 0xFFFFFF; // EGU, ESG
		this.caption.textColor = 0x8b5a01; // AGU
	};
	main.setOut = function() {
		//myTrace("menu:main.setOut");
		this.gotoAndStop("rollOut");
		//this.caption.textColor = 0x00719C; // EGU
		//this.caption.textColor = 0xBF4718; // ESG
		this.caption.textColor = 0x006633; // AGU
		this.subMenu._visible = false;
	};
	main.onRollOver = function() {
		//myTrace("menu:main.onRollOver");
		this.setOver();
	};
	main.onRollOut = function() {
		//myTrace("menu:main.onRollOut");
		this.setOut();
	};
	main.setCaption = function(text) {
		//trace("in menu setCaption");
		this.caption.text = text;
		this.setOut();
	};
	main.onRelease = function() {
		//myTrace("main.onRelease");
		this.gotoAndStop("selected");
		this.caption.textColor = 0xFFFFFF; // AGU
		delete this.onRollOut;
		delete this.onRollOver;
		this.subMenu._visible = true;
		this.subMenu._x = this._x + 50;
		// You need to see if it goes off the bottom of the screen before
		// deciding whether to show it up or down
		//trace("subMenu._height=" + this.subMenu._height + " and this._y=" + this._y);
		//trace("stage height=" + Stage.height + " _root._height=" + _root._height);
		if ((this.subMenu._height + this._y) > 575) {
			if (this.subMenu._height > this._y) {
				// it cannot fit up OR down, so put it down as far as you can
				this.subMenu._y = 575 - this.subMenu._height - 10;
			} else {
				//trace("go up");
				this.subMenu._y = this._y - this.subMenu._height + 10;
			}
		} else {
			//trace("go down");
			this.subMenu._y = this._y + 15;
		}
		//var myPoint = new Object();
		//myPoint.x = 0;
		//myPoint.y = 0;
		//this.subMenu.localToGlobal(myPoint);
		//myTrace("set subMenu global x=" + myPoint.x  + " y=" + myPoint.y);
		this.onMenuSelect(this);
	};
	main.reset = function() {
		this.onRollOut = this.setOut;
		this.onRollOver = this.setOver;
		//myTrace("menu:main.reset");
		this.setOut();
		this.subMenu._visible = false;
		//myTrace("main.reset.hide chooser for " + this._parent);
		this._parent.exChooser._visible = false;
		// v6.5 resetting selected items - trying to clear out what happened in the sub menu
		var subMenu = this._parent;
		//var subMenu = this;
		//myTrace("main.reset.selectedItem for " + subMenu);
		subMenu.selectedItem = undefined;
	};
	main.setSubMenu = function(menuMC) {
		//trace("in setSubMenu");
		this.subMenu = menuMC;
	};
	main.setSizeSubMenu = function(w, h) {
		var thisBounds = this.subMenu.getBounds();
		if (w == undefined) {
			this.subMenu.menuBackground._width = thisBounds.width+10;
		} else {
			this.subMenu.menuBackground._width = w;
		}
		if (h == undefined) {
			this.subMenu.menuBackground._height = thisBounds.height+2+23;
		} else {
			this.subMenu.menuBackground._height = w;
		}
	};
	//main.displayProgress = function(x,y) {
	//	//trace("displayProgress for " + this + " at " + Math.round(100*x/y) +"%");
	//	this.progressIndicator.bar._yscale = Math.round(100*x/y);
	//	//this.progressIndicator.bar._y = 
	//};
}
this.subMenuSetup = function(menuItem) {
	//trace("subMenuSetup for item " + menuItem);
	menuItem.setCaption = function(text, unitNum) {
		//trace("set menuItem caption to " + text + " for " + this);
		this.caption.html = true;
		this.caption.multiline = true;
		this.caption.wordWrap = true;
		this.caption.autosize = true;
		this.caption.htmlText = text;
		// v6.5
		this.unitBackdrop._height = this.caption.textHeight + 2;
		//myTrace("menu:subMenuSetup");
		this.setOut();
	//};
	//menuItem.setUnit = function(text) {
		if (unitNum != undefined) {
			this.unitNumber.text = unitNum;
		} else {
			this.unitNumber.text = "";
			this.caption._x = this.unitNumber._x;
		}
	};
	var unitColor = new Color(menuItem.unitBackdrop);
	var unitTF = new TextFormat();
	menuItem.setOver = function() {
		// trace("in setOver");
		// v6.5 CUP \
		//myTrace("setOver for " + this.caption.text + " action:" + this.action + " color:" + unitColor);
		if (this.active == true || _root.licenceHolder.licenceNS.productType.toLowerCase() != 'demo') {
			if (this.action != undefined) {
				//myTrace("setOver for an action item");
				unitTF.underline = true;
				this.caption.setTextFormat(unitTF);
			} else {
				//myTrace("setOver for an menu");
				//var unitColor = new Color(this.unitBackdrop);
				//unitColor.setRGB(0x0096C6); // EGU
				//unitColor.setRGB(0x0096C6); // ESG
				unitColor.setRGB(0x006633); // AGU
				this.caption.textColor = 0xFFFFFF;
			}
		}
	};
	menuItem.setOut = function() {
		// trace("in setOut");
		//myTrace("menu:menuItem.setOut");
		if (this.active == true || _root.licenceHolder.licenceNS.productType.toLowerCase() != 'demo') {
			if (this.action != undefined) {
				//trace("setOver for an action item");
				unitTF.underline = false;
				this.caption.setTextFormat(unitTF);
			} else {
				unitColor.setRGB(0xFFFFFF);
				this.caption.textColor = 0x000000;
				// this.unitCaption.textColor = 0x00719C;
			}
		}
	};
	// v6.5 CUP demo
        menuItem.setInactive = function () {
		//myTrace("setInactive for " + this.caption.text);
		this.caption.textColor = 10066329;
		this.unitNumber.textColor = 10066329;
        };
	menuItem.onRollOver = function() {
		//myTrace("menu:menuItem.onRollOver");
		this.setOver();
	};
	menuItem.onRollOut = function() {
		//myTrace("menu:menuItem.onRollOut");
		this.setOut();
	};
	menuItem.onRelease = function() {
		// v6.5 Can I detect if this item has already been clicked? Double clicking items causes problems with the chooser
		//myTrace("menuItem.onRelease for " + this);
		delete this.onRollOut;
		delete this.onRollOver;
		//unitColor.setRGB(0xADD7E7); // EGU
		//unitColor.setRGB(0xADD7E7); // ESG
		// v6.5
		if (this.active == true || _root.licenceHolder.licenceNS.productType.toLowerCase() != 'demo') {
			// v6.5 Since seems difficult to clear this later, don't set the seleted menuItem to any colour
			unitColor.setRGB(0xFFFFFF); // EGU
			//unitColor.setRGB(0xADD7E7); // AGU
			this.caption.textColor = 0x000000;
		}
		this.onMenuSelect(this);
	};
	menuItem.reset = function() {
		this.onRollOut = this.setOut;
		this.onRollOver = this.setOver;
		this.setOut();
		// v6.5 resetting selected items - I never seem to come in here
		//var subMenu = this._parent;
		//if (subMenu.selectedItem == this) {
		//	myTrace("menuItem.reset.selectedItem from " + this);
		//	subMenu.selectedItem = undefined;
		//}
	};
	menuItem.easeVert = function(from, to) {
		// trace("start ease for " + this);
		var startTime = new Date().getTime();
		var b = from;
		var c = to-from;
		var d = 300;
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
			this._y = _global.ORCHID.easeOutQuad(t, b, c, d);
		};
		this.easeItemInt = setInterval(this, "easer", 100, startTime, b, c, d);
		// this._y = to;
	};
};
// v6.4.2.7 CUP menu merge
// change _root.menuHolder.menuNS to _global.ORCHID.root.buttonsHolder throughout
var menuItems = new Array();
var initObj = new Object();
this.menuReset = function() {
	//myTrace("b:reset the menu");
	for (var i in this.menuItems) {
		this.menuItems[i].reset();
		this.subMenu._visible = false;
	}
	//myTrace("menuReset.make chooser invisible for " + this);
	this.exChooser._visible = false;
}
this.menuSelect = function(scope) {
	//trace("selected menu " + scope + " in this=" + this);
	for (var i in this._parent.menuItems) {
		if (scope != this._parent.menuItems[i]) {
			// trace(menuItems[i] + " is not the same so reset it");
			this._parent.menuItems[i].reset();
		} else {
			//trace("rearrange subMenu="+this.subMenu);
			this._parent.currentMenu = i;
			this.subMenu.arrange();
			//trace("menuItem.id=" + this._parent.menuItems[i].id);
			var scaffoldSubList = _global.ORCHID.course.scaffold.getItemExercises(this._parent.menuItems[i].id);
			this.subMenu.progress(scaffoldSubList);
		}
	}
	//myTrace("menuSelect.make chooser invisible for " + this);
	this._parent.exChooser._visible = false;
};
this.subMenuSelect = function(scope) {
	//myTrace("you clicked " + scope);
	// is this an action?
	if (scope.action) {
		// v6.2 How to refer nicely back to the top level?
		// I was hoping that menuNS would be defined, but it seems it isn't.
		//trace("menuNS=" + menuNS.moduleName + ", try " + this._parent._parent._parent);
		//this._parent._parent._parent.menuRequest(scope.id);
		// v6.3.4 this function is still in menuHolder
		_global.ORCHID.root.buttonsHolder.menuRequest(scope.id);
		return;
	}
	// so display the menu options and arrange the rest of this menu
	var subMenu = this._parent;
	// v6.5 Can I detect if this menu item is already selected? In which case do nothing
	var menuHolder = subMenu._parent;
	if (menuHolder.selectedItem == scope) {
		myTrace("this is already selected, so out");
		return;
	} else {
		menuHolder.selectedItem = scope;
		//myTrace("subMenuSelect.set selectedItem for " + menuHolder);
	}
	for (var i in subMenu.menuItems) {
		if (scope != subMenu.menuItems[i]) {
			//myTrace(menuItems[i] + " is not this scope, so reset it");
			subMenu.menuItems[i].reset();
		}
	}
	subMenu.arrange(scope);
};
// v6.5 CUP demo
this.demoItemSelect = function (scope) {
	//myTrace("demoItemSelect click on " + this + ":" + this._parent._parent.notInDemoWarning);
	// this is _level0.buttonsHolder.MenuScreen.menu.mySub0.item3
	this._parent._parent.notInDemoWarning._visible = true;
	this._parent._parent.notInDemoWarning.gotoAndPlay(1);
};
this.subMenuGetBounds = function() {
	var tmI = this.menuItems[this.menuItems.length-1];
	// trace("getBounds using " + tmI);
	return {width:tmI._width, height:tmI._y+tmI._height};
};
this.subMenuArrange = function(target) {
	// trace("in arrange for " + this);
	// this function goes through all the menu items setting their y coord
	// if you hit the selected one (target), then add the exercise chooser in and move ones
	// below it down.
	// v6.5 Surely this should be defined here, not in the middle of the loop/condition?
	// except that we were relying on chooser being undefined for some situations (like at the beginning)
	//var chooser = this._parent.exChooser;
	var lastBottom = 0;
	for (var i = 0; i<this.menuItems.length; i++) {
		var oldPosition = Math.round(this.menuItems[i]._y);
		var newPosition = lastBottom+2;
		// For some reason adding the progIndicator increases the height on the second
		// time you click on a menu. Why? Avoid by measuring caption height?
		//lastBottom = newPosition+Math.round(this.menuItems[i]._height);
		lastBottom = newPosition+Math.round(this.menuItems[i].caption._height);
		if (target != undefined) {
			// v6.5 Do not call easeVert if it is already running - or is it better to clear the interval?
			if (this.menuItems[i].easeItemInt <> undefined) {
				clearInterval(this.menuItems[i].easeItemInt);
			}
			this.menuItems[i].easeVert(oldPosition, newPosition);
			if (this.menuItems[i] == target) {
				// trace("found target=" + target);
				var chooser = this._parent.exChooser;
				//myTrace("subMenuArrange.link chooser to item");
				// trace("add chooser=" + this._parent);
				chooser._visible = false;
				chooser.item = {ex1:target.ex1, ex2:target.ex2};
				chooser.ex1Tick._visible = Boolean(target.ex1Done);
				chooser.ex2Tick._visible = Boolean(target.ex2Done);
				chooser._x = this._x + this.menuItems[i]._x; // +10;
				chooser._y = this._y+lastBottom;
				// chooser._visible = true;
				lastBottom += 23;
			}
		} else {
			// trace("setting with no target for " + this.menuItems[i]);
			//myTrace("subMenuArrange.undefined link chooser to item");
			this.menuItems[i]._y = newPosition;
		}
	}
	//myTrace("subMenuArrange.easeVisible for " + chooser);
	//if (target != undefined) {
		// v6.5 Only do the easing if you are not already running it
		if (chooser.easeInt == undefined) {
			chooser.easeVisible();
		}
	//}
	// _visible = true;
};
this.subMenuProgress = function(scaffoldSubList) {
	//myTrace("updating submenu progress");
	// For now base this on the known menu structure, but you could do some checking
	// as the .id, .ex1 and .ex2 should match the scaffold[].id
	// First is the study guide exercise
	// v6.3 Deal with multiple users
	//this.menuItems[0].idDone = scaffoldSubList[0].progress.numExercisesDone;
	this.menuItems[0].idDone = scaffoldSubList[0].progress.numExercisesDone[0];
	var	thisProg = this.menuItems[0].attachMovie("FProgressIndicatorSymbol", "progressIndicator", 0, {height:15, width:8, _x:1, _y:1, lineThick:1});
	thisProg.setProgress(scaffoldSubList[0].progress.numExercisesDone[0], 1);
	//trace(this.menuItems[0].caption.text + " done=" + this.menuItems[0].idDone);
	// Then the rest are in threes (ex1, ex2 and ex3) in the scaffold but twos in the menu (ex1, ex2)
	var count = 1;
	for (var i = 1; i<this.menuItems.length; i++) {
//	for (var j in scaffoldSubList) {
		this.menuItems[i].ex1Done = scaffoldSubList[count++].progress.numExercisesDone[0];
		this.menuItems[i].ex2Done = scaffoldSubList[count++].progress.numExercisesDone[0];
		//myTrace(this.menuItems[i].caption.text + " ex2Done=" + this.menuItems[i].ex2Done);
		count++; // to ignore the third exercise
		thisProg = this.menuItems[i].attachMovie("FProgressIndicatorSymbol", "progressIndicator", 0, {height:15, width:8, _x:1, _y:1, lineThick:1});
		thisProg.setProgress(this.menuItems[i].ex1Done + this.menuItems[i].ex2Done, 2);
	}
}
//myTrace("root.attach chooser to 999");
this.attachMovie("exChooser", "exChooser", 999, {_visible:false});
//this.exItemSetup(this.exChooser.ex1);
//this.exItemSetup(this.exChooser.ex2);
//this.exChooser.ex1.setLabel("Faust exercise");
//this.exChooser.ex2.setLabel("Second exercise");
this.exChooser.ex1.onRelease = function() {
	myTrace("requestMenu from " + this._parent._parent._parent + " ex1=" + this._parent.item.ex1);
	//this._parent._parent._parent.menuRequest(this._parent.item.ex1);
	// v6.3.4 this function is still in menuHolder
	//_global.ORCHID.root.buttonsHolder.menuRequest(this._parent.item.ex1);
	_global.ORCHID.root.buttonsHolder.menuRequest(this._parent.item.ex1);
}
this.exChooser.ex2.onRelease = function() {
	//trace("chooser button=" + this + " ex2=" + this._parent.item.ex2);
	//this._parent._parent._parent.menuRequest(this._parent.item.ex2);
	// v6.3.4 this function is still in menuHolder
	_global.ORCHID.root.buttonsHolder.menuRequest(this._parent.item.ex2);
}
this.exChooser.reset = function() {
//	this.ex1.reset();
//	this.ex2.reset();
};
this.exChooser.easeVisible = function() {
	// don't use visible easing - it doesn't look good. Instead just switch it on after a delay
	// v6.5 But if I double click too much I can end up firing this twice so the interval gets lost and just keeps going.
	this.easer = function() {
		clearInterval(this.easeInt);
		this.easeInt = undefined;
		this._visible = true;
	};
	this.easeInt = setInterval(this, "easer", 500);
};

// functions to populate the menu structures
menuInit = function (menu, initObj) { 
	//myTrace("b:menuInit for " + menu);
	this.mainMenuSetup(menu);
	menu.setCaption(initObj.caption);
	menuItems.push(menu);
	menu.onMenuSelect = this.menuSelect;
	menu.setSubMenu(initObj.subMenu);
	menu.setSizeSubMenu();
};
subMenuInit = function (subMenu, initArray) { 
	//myTrace("subMenuInit");
	//trace("subMenuInit for " + subMenu);
	subMenu.menuItems = new Array();
	for (var i = 0; i<initArray.length; i++) {
		var menuItem = subMenu.attachMovie("menuItem", "item"+i, i);
		this.subMenuSetup(menuItem);
		subMenu.menuItems.push(menuItem);
		menuItem._x = 5;
		//menuItem.setUnit(initArray[i].unit);
		menuItem.setCaption(initArray[i].caption, initArray[i].unit);
		menuItem.action = initArray[i].action;
		menuItem.ex1 = initArray[i].ex1;
		menuItem.ex2 = initArray[i].ex2;
		menuItem.id = initArray[i].id;
		// v6.5 CUP demo
		//menuItem.onMenuSelect = this.subMenuSelect;
		if (initArray[i].active == true) {
			menuItem.active = true;
			menuItem.onMenuSelect = this.subMenuSelect;
			//myTrace(initArray[i].caption + " is active");
		} else {
			menuItem.setInactive();
			menuItem.onMenuSelect = this.demoItemSelect;
			//myTrace(initArray[i].caption + " is inactive");
		}
	}
	subMenu.arrange = this.subMenuArrange;
	subMenu.arrange();
	subMenu.getBounds = this.subMenuGetBounds;
	subMenu.progress = this.subMenuProgress;
};
// the "progress" array here is made up of the full scaffold items for the top level menu
this.updateProgress = function(progress) {
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

// first attach the submenus that you need
//trace("loading theMenu");
this.depth = 0;

this.setup = function(items, progress) {
	//myTrace("theMenu:setup for the menu, items.length=" + items.length);
	for (var i=0; i<items.length;i++) {
		//trace("item=" + items[i].caption + ", id=" + items[i].id + ", x=" + items[i].x);
		var thisMenu = this.attachMovie("mainMenuItem","myItem" + i,this.depth++);
		//myTrace("add " + items[i].caption + " at depth=" + this.depth + " progress=" + progress.length);
		thisMenu.attachMovie("FProgressIndicatorSymbol", "progressIndicator", 0, {height:23, width:12, lineThick:1});
		// make sure that sub menus are all above the mainMenuItems
		var newDepth = Number(items.length)+Number(this.depth);
		var thisSub = this.attachMovie("subMenu", "mySub" + i, newDepth, {_visible:false});
		//myTrace("add sub at depth=" + newDepth);
		subMenuInit(thisSub, this.subMenuData[i]);
		//myTrace("in subMenu " + thisSub);
		thisMenu._x = items[i].x;
		thisMenu._y = items[i].y - 10;// Move up a bit as screen not so deep now
		//thisMenu._y = items[i].y + 10;// Move up a bit as screen not so deep now
		//trace(thisMenu + " at x=" + thisMenu._x + " y=" + thisMenu._y);
		items[i].subMenu = thisSub;
		menuInit(thisMenu, items[i]);
		// now try to get data for this subMenu
		// the following call works, but is far too slow
		// _global.ORCHID.menuXML.getMenuItemByID(items[i].id)
		/*
		initArray = new Array();
		for (var j=0; j<subItems.length; j++) {
			//trace("subItem=" + subItems[j].caption + ", id=" + subItems[j].id);
			if (subItems[j].action == undefined) {
				// the following works but is far too slow
				//var exItems = _global.ORCHID.menuXML.getMenuItemByID(subItems[j].id);
				// we know that this is in the form Exercise 1, Exercise 2, Test questions
				//trace("exItem=" + exItems[0].caption + ", id=" + exItems[0].id);
				//trace("exItem=" + exItems[1].caption + ", id=" + exItems[1].id);
				initArray.push({unit:1, caption:subItems[j].caption, ex1:subItems[j].ex1, ex2:subItems[j].ex2});
			} else {
				// this is an exercise, so push it
				initArray.push({caption:subItems[j].caption, action:true, id:subItems[j].id});
			}
		}
		*/
	}
	//trace("finished loading the menu");
	//v6.3.4 copied from menu.swf (can't do it there due to attachMovie sloth)
	//myTrace("extra call to updateProgress");
	this.updateProgress(progress);
}
// Note that the actual data for the menu items is in theMenu mc in the buttons.fla