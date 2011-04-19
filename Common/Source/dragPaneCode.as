myTrace("dragPaneCode from " + this);
// init functions
separator_mc._visible = false;

// public functions to control the pane
setPaneTitle = function(titleText) {
	this.title_mc.title_txt.text = titleText;
}
// v6.4.2.7 CUP merge
setTitle = function(titleText) {
	setPaneTitle(titleText);
}

setCloseHandler = function(newHandler) {
	this.closeHandler = newHandler;
}
setButtons = function(buttonArray) {
	if (buttonArray.length > 0) {
	} else {
		//myTrace("no buttons, so increase size");
		this.space_mc.setSize(469,186);
		return;
	}
	for (var i in buttonArray) {
		this["button"+i].setTarget("paneBtn"); 
		this["button"+i].setLabel(buttonArray[i].caption);
		//myTrace("add caption " + buttonArray[i].caption + " to " + this["button"+i]);
		/*
		if (buttonArray[i].noClose == true) {
			myTrace("a button with no close action=" + buttonArray[i].caption);
			this["button"+i].onRelease = function() {
				//myTrace("this is a button with no close action");
				this.setReleaseAction(this._parent);
			}
		} else {
			myTrace("a button with a close action=" + buttonArray[i].caption);
			this["button"+i].onRelease = function() {
				myTrace("a button with a close action=" + buttonArray[i].caption);
				this.setReleaseAction(this._parent);
				this._parent.closeHandler();
			}
		}
		*/
		this["button"+i].setReleaseAction(buttonArray[i].setReleaseAction);
	}
}
getScrollContent = function() {
	return this.contentHolder;
}
hasSeparator = function(y) {
	this.separator_mc._y = y;
	this.separator_mc._visible = true;
}
setKeys = function(keyArray) {
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
				}
			}
		}			
	}
	Key.addListener(this);
}
// stop any mc under the pane reacting to the mouse
this.backdrop.onRelease = function() {};
this.backdrop.useHandCursor = false;

// let all components have a means of refering to the whole thing
this.title_mc.controller = this;
this.close_mc.controller = this;

// functions for dragging
titleTrackBegin = function(x, y) {
	myTrace("start dragging " + this.controller);
	this.controller.startDrag();
};
titleTrackEnd = function(x, y) {
	this.controller.stopDrag();
	// v6.2 Don't let the pane be dragged off the screen
	//trace("stop drag with _x=" + this.controller._x + " this=" + this.controller);
	if (this.controller._x < 10) this.controller._x = 10;
	if (this.controller._y < 10) this.controller._y = 10;
	if (this.controller._x > (Stage.height-10)) this.controller._x = (Stage.height-10);
	if (this.controller._y > (Stage.width-10)) this.controller._y = (Stage.width-10);
};
title_mc.onPress = titleTrackBegin;
title_mc.onRelease = titleTrackEnd;
title_mc.onReleaseOutside = titleTrackEnd;

// functions for closing
closePane = function() {
	this.controller.closeHandler(this);
	// v6.4.2.7 CUP merge - we now close the pane with this function (unless otherwise stipulated)
	//this.controller.removeMovieClip();
	myTrace("in dragPane.closePane for controller " + this.controller + " or " + this); 
	this.controller._visible = false;
};
close_mc.onRelease = closePane;
stop();