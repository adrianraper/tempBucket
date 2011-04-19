
this.setMask(mask);

totalNoOfSegments = 0;
for (var i in this) {
	if (i.substr(0, 7)=="segment") {
		totalNoOfSegments++;
	}
}
noOfLoadedSegment = 0;
selectedIndex = 1;

setSegmentLabel = function(index:Number, label:String) : Void {
	this["segment"+index].setLabel(label);
}

moveSegments = function(index:Number) : Void {
	if (index>1) {
		if (selectedIndex > index) {
			for (var i=totalNoOfSegments; i>index; i--) {
				this["segment"+i].closeSegment();
			}
		} else if (selectedIndex < index) {
			for (var i=1; i<=index; i++) {
				this["segment"+i].openSegment();
			}
		}
	} else {
		for (var i=totalNoOfSegments; i>1; i--) {
			this["segment"+i].closeSegment();
		}
	}
	selectedIndex = index;
}

assignSegment = function(index:Number, idName:String) : Void {
	this["segment"+index].contentHolder.setMovieClip(idName);
}

changeSegment = function(index:Number, showNames, hideNames:Array) : Void {
	this["segment"+index].contentHolder.showMovieClip(showNames);
	this["segment"+index].contentHolder.hideMovieClip(hideNames);
}

onSegmentLoaded = function() : Void {
	noOfLoadedSegment++;
	if (noOfLoadedSegment>=totalNoOfSegments) {
		onAllSegmentsLoaded();
	}
}

onAllSegmentsLoaded = function() : Void {
	for (var i=totalNoOfSegments; i>0; i--) {
		this["segment"+i].index = i;
	}
	NNW.screens.acds.onAccordionLoaded(this._name);
}