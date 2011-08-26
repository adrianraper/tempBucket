this.menuBackground.onRelease = function() {
	myTrace("subMenu.menuBackground.onRelease");
};
this.menuBackground.useHandCursor = false;
this.menuBackground.onRollOut = function() {
	// this gets triggered when you go over a button that is within the background 
	//myTrace("menuBackground.onRollOut");
	// so you only set the hiding function if you are really outside the area
	
	if (this.hitTest(_root._xmouse, _root._ymouse, false)) {
		//myTrace("still over with mouse.x=" + _root._xmouse+ ", y=" + _root._ymouse);
	} else {
		//myTrace("leaving subMenu mouse.x=" + _root._xmouse+ ", y=" + _root._ymouse);
		//myTrace("subMenu global x=" + myPoint.x  + " y=" + myPoint.y + " w=" + this._width + " h=" + this._height);
		this.disappear = function(t, b, c, d) {
			//trace("hide it now");
			clearInterval(this.hideInt);
			// hide the subMenu
			this._parent._visible = false;
			// clear the selected main menu
			this._parent._parent.menuItems[this._parent._parent.currentMenu].reset();
		}
		this.hideInt = setInterval(this, "disappear", 500, t, b, c, d);		
	}
}
this.menuBackground.onRollOver = function() {
	//myTrace("menuBackground.onRollOver clear the hiding");
	clearInterval(this.hideInt);
	//this._xscale = this._yscale = 100;
}
