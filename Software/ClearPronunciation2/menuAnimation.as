// Functions for the tab butons

function showMenu(tabNumber, animated) {
	var menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsHolder;
	//var menuOutline = _global.ORCHID.root.buttonsHolder.MenuScreen.unitsOutline;

	if (menuContainer == undefined) {
		menuContainer = _global.ORCHID.root.buttonsHolder.MenuScreen;
	}
	// v6.5.6.6 Accordion like control
	var yorigin = 156;
	var ysmall = 33;
	var ybig = 240;
	var ystart = yend = 0;
	myTrace("click tab" + tabNumber);
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
	switch (tabNumber) {
		case 1:
			menuContainer.vscroll = 0; 
			menuContainer.topY = 220;
			break;
		case 2:
			// a little less than a full screen as it starts further down
			menuContainer.vscroll = 167; 
			menuContainer.topY = 253;
			break;
		case 3:
			menuContainer.vscroll = 334; 
			menuContainer.topY = 286;
			break;
		case 4:
			menuContainer.vscroll = 701; 
			break;
		case 5:
			menuContainer.vscroll = 1020; 
			break;
	}
	myTrace("menuOutline ends at " + menuOutline._y);
	
	//myTrace("vscroll=" + menuContainer.vscroll);
	menuContainer.drawItems();
	// Save this tab
	bookmark=tabNumber;

	/*
	//myTrace("scrollDown from this=" + menuContainer);
	// v6.5.5.8 I want to have a scrolling transition.
	switch (tabNumber) {
		case 2:
			var startVScroll = menuContainer.vscroll;
			var endVScroll = 400;
			// It would be nice to only scroll one screen in whatever direction.
			// But this is a bit tricky as if you just set startVScroll to one screen
			// off, you suddenly see a new screen scrolling away. So leave it for now.
			//if (startVScroll<endVScroll) {
			//	startVScroll=endVScroll-400
			//} else {
			//	startVScroll=endVScroll+400
			//}
			if (animated) {
				// Copied from EGUMenus
				if (menuContainer.easeItemInt <> undefined) {
					clearInterval(menuContainer.easeItemInt);
				}
				//myTrace("start easing");
				menuContainer.easeVert(startVScroll, endVScroll);
			} else {
				menuContainer.vscroll = endVScroll; 
			}
			menuContainer.drawItems();
			cmdMenu1.setTarget("consonantclusterBtn-selected");	
			cmdMenu2.setTarget("wordstressBtn");
			cmdMenu3.setTarget("connectedspeechBtn");
			cmdMenu4.setTarget("sentencestressBtn");
			cmdMenu5.setTarget("intonationBtn");
			// Save this tab
			bookmark=2;
			break;
		case 3:
			var startVScroll = menuContainer.vscroll;
			var endVScroll = 0;
			if (animated) {
				// Copied from EGUMenus
				if (menuContainer.easeItemInt <> undefined) {
					clearInterval(menuContainer.easeItemInt);
				}
				//myTrace("start easing");
				menuContainer.easeVert(startVScroll, endVScroll);
			} else {
				menuContainer.vscroll = endVScroll; 
			}
			menuContainer.drawItems();
			cmdMenu1.setTarget("consonantclusterBtn");	
			cmdMenu2.setTarget("wordstressBtn-selected");
			cmdMenu3.setTarget("connectedspeechBtn");
			cmdMenu4.setTarget("sentencestressBtn");
			cmdMenu5.setTarget("intonationBtn");
			// Save this tab
			bookmark=3;
			break;
		case 4:
			var startVScroll = menuContainer.vscroll;
			var endVScroll = 0;
			if (animated) {
				// Copied from EGUMenus
				if (menuContainer.easeItemInt <> undefined) {
					clearInterval(menuContainer.easeItemInt);
				}
				//myTrace("start easing");
				menuContainer.easeVert(startVScroll, endVScroll);
			} else {
				menuContainer.vscroll = endVScroll; 
			}
			menuContainer.drawItems();
			cmdMenu1.setTarget("consonantclusterBtn");	
			cmdMenu2.setTarget("wordstressBtn");
			cmdMenu3.setTarget("connectedspeechBtn-selected");
			cmdMenu4.setTarget("sentencestressBtn");
			cmdMenu5.setTarget("intonationBtn");
			// Save this tab
			bookmark=4;
			break;
		default:
			var startVScroll = menuContainer.vscroll;
			var endVScroll = 0;
			if (animated) {
				// Copied from EGUMenus
				if (menuContainer.easeItemInt <> undefined) {
					clearInterval(menuContainer.easeItemInt);
				}
				//myTrace("start easing");
				menuContainer.easeVert(startVScroll, endVScroll);
			} else {
				menuContainer.vscroll = endVScroll; 
			}
			menuContainer.drawItems();
			cmdMenu1.setTarget("consonantclusterBtn");	
			cmdMenu2.setTarget("wordstressBtn");
			cmdMenu3.setTarget("connectedspeechBtn");
			cmdMenu4.setTarget("sentencestressBtn-selected");
			cmdMenu5.setTarget("intonationBtn");
			// Save this tab
			bookmark=1;
			break;
	}
	*/
}
// This function is also called from MenuScreen.displayScreen()
// No, because I don't want any scrolling with that one, so have a different version
function bookmarkMenu(tabNumber) {
	if (tabNumber) bookmark = tabNumber;
	showMenu(bookmark, true);
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
var bookmark = 1;

// easing of tabStops
cmdMenuEaseVert = function(from, to) {
	//myTrace("start ease for " + this);
	var startTime = new Date().getTime();
	var b = from;
	var c = to-from;
	var d = 500;
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
		//this.vscroll = _global.ORCHID.easeInOutQuad(t, b, c, d);
		this._y = _global.ORCHID.easeInOutQuad(t, b, c, d);
		//this.vscroll = _global.ORCHID.easeInOutExpo(t, b, c, d);
		// this.vscroll = _global.ORCHID.easeOutBack(t, b, c, d);  // this is awful!
		//this.drawItems();
	};
	this.easeItemInt = setInterval(this, "easer", 100, startTime, b, c, d);
	// this._y = to;
};
cmdMenu1.easeVert = cmdMenuEaseVert;
cmdMenu2.easeVert = cmdMenuEaseVert;
cmdMenu3.easeVert = cmdMenuEaseVert;
cmdMenu4.easeVert = cmdMenuEaseVert;
cmdMenu5.easeVert = cmdMenuEaseVert;

// v6.5.5.5 Special for chart button, link to a pdf in shared media
chart_pb.onRelease = function() {
	myTrace("click chart from buttonsCP.menuScreen.fla");
	var thisMedia = _global.ORCHID.viewObj.checkWeblink('#sharedMedia#phonemicChart.pdf')
	//myTrace("link to=" + thisMedia);
	getURL(thisMedia, "_blank");
}
// and set the label, but I doubt you can do this as the literals is probably not loaded yet.
//chart_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("chart", "buttons"));
chart_pb.setLabel("Phonemic chart");

// Need to override some other standard stuff?
stop();