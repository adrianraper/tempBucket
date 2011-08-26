// this code demonstrates use of ACK and tlc
// the resumeLoop iteration comes from the onEnterFrame onClipEvent

	// ******
	// Create the tlc settings
	// ******
	_global.tlc = {timeLimit:1000, 		// How long to spend in one iteration? (don't go near 15 seconds!)
					maxLoop:xxx, 	// The end of your loop
					i:0,			// The start of your loop
					proportion:100, 	// If this is multi-step process, what % is spent on this step?
					startProportion:0,	// What is the starting % for this step?
					stuffAfterCallback:callBack}; // What function to call when you are finished?
	var tlc = _global.tlc;

	tlc.controller = _root.tlcController; // then point to a movie clip that you expect to exist
							// that contains the progress bar and onEnterFrame code
	if (typeof tlc.controller == "movieclip") {
		//trace("controller already exists");
	} else {		
		var myController = _root.createEmptyMovieClip("tlcController", _global.tlcLoadingDepth);
		myController.loadMovie(_global.tlcPath + "onEnterFrame.swf");
		myController._x = myController._y = 10;
		tlc.controller = myController;
	}
	tlc.updateProgressBar = function(pc){
		this.controller.setPercentage(this.startProportion + Math.floor(pc));
	}

	// ******
	// this is the data that is the core of the loop, you need to save as part of the tlc object
	// so that it is available in the loop and callback
	// ******
	tlc.xx = xx;
	
	// define the resumeLoop method
	tlc.resumeLoop = function(firstTime) {
		var startTime = getTimer();
		var i = this.i;
		var max = this.maxLoop;
		var timeLimit = this.timeLimit;
		while (getTimer()-startTime <= timeLimit && i<max && !firstTime) {
			// ******
			// this is stuff in a loop that you want to do
			// ******
			this.xx[i] = xx;
			// ******
			// update i at the end of the loop
			// ******
			i++;
		}
		if (i < max) {
			this.updateProgressBar((i/max) * this.proportion); 
			this.i = i;
		} else if (i == max || max == undefined) {
			this.i = max+1; // just in case this is run beyond the limit
			this.updateProgressBar(this.proportion); 
			// get rid of the resumeLoop as you have finished it
			var stopTime = new Date().getTime();
			delete this.resumeLoop;
			this.stuffAfterCallBack();
			// if this is now at 100%, get rid of the tlc
			if (Number(this.proportion + this.startProportion) >= 100) {
				this.controller.removeMovieClip();
			}
		}
		
	}
	// finally start off the looping (with a firstTime flag if using tlc)
	//trace("first call to resumeLoop");
	if (tlc.proportion > 0) {
		tlc.resumeLoop(true);
	} else {
		tlc.resumeLoop();
	}
