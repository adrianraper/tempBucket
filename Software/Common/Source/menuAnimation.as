// Functions for the tab butons
// This is a shared file, yet is totally specific to CP2...
// Actually, CP2 is the first time it has been a shared file. For the next one you will need to add branding conditionals.

function showMenu(tabNumber, animated) {
	var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
	//var menuOutline = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsOutline;

	if (menuContainer == undefined) {
		menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen;
	}
	
	// No need to do anything if you click on the open tab
	// Ah, but bookmark changes before you come here - it shouldn't.
	//if (bookmark == tabNumber)	return;
	//myTrace("bookmark=" + bookmark + ' and tab=' + tabNumber);
	
	// v6.5.6.6 Accordion like control
	//var yorigin = 156;
	var yorigin = 236;
	var ysmall = 33;
	var ybig = 192;
	var ystart = yend = 0;
	//myTrace("click tabby " + tabNumber);
	accTabs = new Array(cmdMenu1, cmdMenu2, cmdMenu3, cmdMenu4, cmdMenu5);
	accTabs[0]._y = accTabs[0]._yend = yorigin;
	
	for (var i=1; i<=4;i++) {
		ystart = accTabs[i]._y;
		if (i==tabNumber) {
			ymove = ybig;
		} else {
			ymove = ysmall;
		}
		// use a fake end holder, the easing will move the real ._y as it goes
		accTabs[i]._yend = accTabs[i-1]._yend + ymove;
		//myTrace("tab=" + Number(i+1) + " start=" + ystart + " end=" + accTabs[i]._yend);
		if (accTabs[i].easeItemInt <> undefined) {
			clearInterval(accTabs[i].easeItemInt);
		}
		accTabs[i].easeVert(ystart, accTabs[i]._yend);
	}
	
	// Sadly you can't just move the menuOutline as it is set at the beginning, before you do any scrolling.
	// Try to set menuContainer directly
	//myTrace("menuOutline starts at " + menuOutline._y);
	cmdMenuInstruction._visible = false;
	_global.ORCHID.root.buttonsHolder.MenuScreen.animatedUnitPanel._height = 350;
	myTrace("set block height to 350");
	switch (tabNumber) {
		case 1:
			menuContainer.vscroll = 0; 
			menuContainer.topY = 220;
			//menuContainer.topY = 140;
			break;
		case 2:
			// a little less than a full screen as it starts further down
			menuContainer.vscroll = 167; 
			menuContainer.topY = 253;
			//menuContainer.topY = 173;
			break;
		case 3:
			menuContainer.vscroll = 334; 
			menuContainer.topY = 286;
			break;
		case 4:
			menuContainer.vscroll = 701; 
			menuContainer.topY = 319;
			break;
		case 5:
			menuContainer.vscroll = 868; 
			menuContainer.topY = 352;
			// There is a special case that if all items were closed and you click on the last item
			// there will be no animation, so you want to see exercises immediately
			//myTrace("tab=" + Number(i+1) + " start=" + accTabs[tabNumber-1]._y + " end=" + accTabs[tabNumber-1]._yend);
			if (accTabs[tabNumber-1]._y==accTabs[tabNumber-1]._yend) {
				animated=false;
				menuContainer._visible = true;
			}
			break;
		case -1:
			myTrace("starting with tab=-1");
			menuContainer.vscroll = 0; 
			menuContainer.topY = 0;
			// Hide the details and show the instruction graphic
			cmdMenuInstruction._visible = true;
			menuContainer._visible = false;
			// If we are starting with everything hidden, make the panel smaller too
			_global.ORCHID.root.buttonsHolder.MenuScreen.animatedUnitPanel._height = 190;
			break;
	}
	menuContainer.bottomY = menuContainer.topY + 180;
	//myTrace("menuOutline ends at " + menuOutline._y);
	
	//myTrace("vscroll=" + menuContainer.vscroll);
	menuContainer.drawItems();
	// Save this tab
	bookmark=tabNumber;
	
	// Hide the menu container until the tabs have eased into place
	if (animated) {
		// v6.5.6.5 If you click too quickly on the items, you come in here before the last interval is complete
		// This ends up showing the menuContainer too quickly.
		if (this.menuContainerInt) {
			clearInterval(this.menuContainerInt);
		}
		menuContainer._visible = false;
		this.reshowMenu = function() {
			var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
			menuContainer._visible = true;
			clearInterval(this.menuContainerInt);
		}
		this.menuContainerInt = setInterval(this, "reshowMenu", 700);
	}

}
// This function is also called from MenuScreen.displayScreen()
// No, because I don't want any scrolling with that one, so have a different version
function bookmarkMenu(tabNumber) {
	//if (tabNumber) bookmark = tabNumber;
	//showMenu(bookmark, true);
	showMenu(tabNumber, true);
}
function bookmarkMenuDirect() {
	showMenu(bookmark, false);
}

// The special buttons that act like tabs
cmdMenu1.setLabel("ConsonantCluster");
cmdMenu2.setLabel("WordStress");
cmdMenu3.setLabel("ConnectedSpeech");
cmdMenu4.setLabel("SentenceStress");
cmdMenu5.setLabel("Intonation");
function showMenu1() {
	bookmarkMenu(1);
}
function showMenu2() {
	bookmarkMenu(2);
}
function showMenu3() {
	bookmarkMenu(3);
}
function showMenu4() {
	bookmarkMenu(4);
}
function showMenu5() {
	bookmarkMenu(5);
}
cmdMenu1.setReleaseAction(showMenu1);
cmdMenu2.setReleaseAction(showMenu2);
cmdMenu3.setReleaseAction(showMenu3);
cmdMenu4.setReleaseAction(showMenu4);
cmdMenu5.setReleaseAction(showMenu5);

// This function is called from displayMenu to make sure we return to the last used tab
// which tab do you want to start on?
// Or do you actually want to start with all sections hidden?
// If you are in the demo, then we DO start with something open. But we don't know that yet.
//myTrace('menu, demo=' + _global.ORCHID.root.licenceHolder.licenceNS.productType);
//if (_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase().indexOf("demo") >= 0) {
//	var bookmark = 3;
//	_global.ORCHID.root.buttonsHolder.MenuScreen.cmdMenu3.setTarget('connectedSpeechBtnDemo');
//} else {
	//var bookmark = 1;
	var bookmark = -1;
//}
// Initially hide the little instruction
cmdMenuInstruction._visible = false;

// easing of tabStops
cmdMenuEaseVert = function(from, to) {
	//myTrace("start ease for " + this);
	var startTime = new Date().getTime();
	var b = from;
	var c = to-from;
	var d = 600;
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
		// ease-out quad seems to work better
		this._y = _global.ORCHID.easeOutQuad(t, b, c, d);
		// What sort of motion do you want?
		//this.vscroll = _global.ORCHID.easeOutQuad(t, b, c, d);
		//this.vscroll = _global.ORCHID.easeInOutQuad(t, b, c, d);
		//this._y = _global.ORCHID.easeInOutQuad(t, b, c, d);
		//this.vscroll = _global.ORCHID.easeInOutExpo(t, b, c, d);
		// this.vscroll = _global.ORCHID.easeOutBack(t, b, c, d);  // this is awful!
		//this.drawItems();
	};
	this.easeItemInt = setInterval(this, "easer", 50, startTime, b, c, d);
	// this._y = to;
};
cmdMenu1.easeVert = cmdMenuEaseVert;
cmdMenu2.easeVert = cmdMenuEaseVert;
cmdMenu3.easeVert = cmdMenuEaseVert;
cmdMenu4.easeVert = cmdMenuEaseVert;
cmdMenu5.easeVert = cmdMenuEaseVert;

// v6.5.5.5 Special for chart button, link to a pdf in shared media
chart_pb.onRelease = function() {
	//myTrace("click chart from buttonsCP.menuScreen.fla");
	var thisMedia = _global.ORCHID.viewObj.checkWeblink('#sharedMedia#phonemicChart.pdf')
	//myTrace("link to=" + thisMedia);
	getURL(thisMedia, "_blank");
}
// and set the label, but I doubt you can do this as the literals is probably not loaded yet.
//chart_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("chart", "buttons"));
chart_pb.setLabel("Phonemic chart");

// Need to override some other standard stuff?
stop();