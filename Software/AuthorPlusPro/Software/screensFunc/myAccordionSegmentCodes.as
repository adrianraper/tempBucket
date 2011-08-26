
status = "open";
index = 0;

onEnterFrame = function() : Void {
	_parent.onSegmentLoaded();
	delete onEnterFrame;
}

header.useHandCursor = false;
header.onRelease = function() : Void {
	onHeaderClick();
}

setLabel = function(l:String) : Void {
	label.text = l;
}

contentHolder.setMovieClip = function(idName:String) : Void {
	this.attachMovie(idName, idName, this.getNextHighestDepth());
}

contentHolder.hideMovieClip = function(idNames:Array) : Void {
	for (var i in idNames) {
		this[idNames[i]]._visible = false;
	}
}

contentHolder.showMovieClip = function(idNames:Array) : Void {
	for (var i in idNames) {
		this[idNames[i]]._visible = true;
	}
}

onHeaderClick = function() : Void {
	//trace(index+" : "+status);
	_parent.moveSegments(index);
}

closeSegment = function() : Void {
	//trace('close '+index);
	if (status=="open") {
		gotoAndPlay("close");
		status = "close";
	}
}

openSegment = function() : Void {
	//trace('open '+index);
	if (status=="close") {
		gotoAndPlay("open");
		status = "open";
	}
}
