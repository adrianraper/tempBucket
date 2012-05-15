// Code from Attach layer - extracted from control.fla

// v6.4.2 Use a queue for loading modules
_global.ORCHID.queue = new Object();
_global.ORCHID.queue.modules = new Object();
_global.ORCHID.queue.loadingQueue = new Array();
_global.ORCHID.queue.nowLoading = 0;
_global.ORCHID.queue.limit = 2;
myTrace("use queue of " + _global.ORCHID.queue.limit,0);
// for local you take a 2 second hit for going down to queue of 1, not much improvement over 5
// for remote it really doesn't make much difference at all

controlNS.loadMovieToHolder = function(module) {
	// can you create a queue that only has x loading at once?
	//myTrace("lMTH " + module.holderName + " now loading=" + _global.ORCHID.nowLoading);
	if (_global.ORCHID.queue.nowLoading < _global.ORCHID.queue.limit) {
		_global.ORCHID.queue.nowLoading++;
		// v6.4.2.4 You might have preset the module depths
		//this.master.createEmptyMovieClip(module.holderName, controlNS.depth++);
		controlNS.depth++;
		if (module.depth == undefined || module.depth < 0) module.depth = controlNS.depth;
		this.master.createEmptyMovieClip(module.holderName, module.depth);
		var movieLocation;
		if (module.folder==undefined) {
			movieLocation = _global.ORCHID.paths.movie;
		} else {
			movieLocation = module.folder;
		}
		// Try to let the module come from cache unless you detect a new version number
		if(_global.ORCHID.online){
			var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString(module);
		} else {
			var cacheVersion = ""
		}
		myTrace("load " + movieLocation + module.fileName + cacheVersion); 
		this.master[module.holderName].loadMovie(movieLocation + module.fileName + cacheVersion);
		// initialise queue item variables
		module.lastByteCount=0;
		module.loadingStuck=0;
		//module.tryAgain=0;
	} else {
		myTrace("queue " + module.holderName,1);
		// hold this in the queue for now
		_global.ORCHID.queue.loadingQueue.push(module);
	}
}
controlNS.loadFromQueue = function() {
	if (_global.ORCHID.queue.nowLoading < _global.ORCHID.queue.limit && 
		_global.ORCHID.queue.loadingQueue.length >0) {
		//myTrace("load from queue " + _global.ORCHID.queue.loadingQueue[0].holderName);
		this.loadMovieToHolder(_global.ORCHID.queue.loadingQueue.shift());
	} else {
		//myTrace("no space to load a new one");
	}
}
var moduleQueue = _global.ORCHID.queue.modules;
moduleQueue.licenceModule = {holderName:"licenceHolder", fileName:"licence.swf", name:"licence",
											loaded:false, tryAgain:0, acknowledged:false};
// v6.5.5.5 Security
moduleQueue.displayListModule = {holderName:"displayListHolder", fileName:"displayList.swf", name:"displayList", 
											loaded:false, tryAgain:0, acknowledged:false};
moduleQueue.objectsModule = {holderName:"objectHolder", fileName:"objects.swf", name:"objects",
											loaded:false, tryAgain:0, acknowledged:false};
moduleQueue.mainModule = {holderName:"mainHolder", fileName:"main.swf", name:"main",
											loaded:false, tryAgain:0, acknowledged:false};
moduleQueue.jukeboxModule = {holderName:"jukeboxHolder", fileName:"jukeBox.swf", name:"jukebox",
											loaded:false, tryAgain:0, acknowledged:false};
moduleQueue.videoModule = {holderName:"videoHolder", fileName:"videoPlayer.swf", name:"videoPlayer",
											loaded:false, tryAgain:0, acknowledged:false};
// v6.5.5.5 need a new video module to cope with RTMP streaming. Not just yet though!
moduleQueue.newVideoModule = {holderName:"newVideoHolder", fileName:"newVideoPlayer.swf", name:"newVideoPlayer",
											loaded:false, tryAgain:0, acknowledged:false};
// v6.5 Add separate module for displaying progress
moduleQueue.progressModule = {holderName:"progressHolder", fileName:"progress.swf", name:"progress",
											loaded:false, tryAgain:0, acknowledged:false};
moduleQueue.printingModule = {holderName:"printingHolder", fileName:"printing.swf", name:"printing",
											loaded:false, tryAgain:0, acknowledged:false};
moduleQueue.buttonsModule = {holderName:"buttonsHolder", fileName:"buttons.swf", name:"buttons",
											folder:_global.ORCHID.paths.interfaceMovies,
											loaded:false, tryAgain:0, acknowledged:false};
moduleQueue.creditsModule = {holderName:"creditsHolder", fileName:"credits.swf", name:"credits",
											folder:_global.ORCHID.paths.interfaceMovies,
											loaded:false, tryAgain:0, acknowledged:false};
moduleQueue.tlcModule = {holderName:"tlcController", fileName:"onEnterFrame.swf", name:"onEnterFrame",
											loaded:false, tryAgain:0, acknowledged:false,
											depth:100};
if (_global.ORCHID.commandLine.scorm) {
	moduleQueue.scormModule = {holderName:"scormHolder", fileName:"scorm.swf", 
											loaded:false, tryAgain:0, acknowledged:false};
}
											
// to allow you to see load time
_global.ORCHID.queue.startTime = new Date().getTime();

// need to count the modules as it is not an array
_global.ORCHID.queue.totalModules=0;
for (var i in moduleQueue) {
	_global.ORCHID.queue.totalModules++
}

//
//load them up - either in a loop or manually if you want to control order more easily
//for (var i in _global.ORCHID.modules) {
//	controlNS.loadMovieToHolder(_global.ORCHID.modules[i]);
//}
controlNS.loadMovieToHolder(moduleQueue.licenceModule);
// v6.5.5.5 Security
controlNS.loadMovieToHolder(moduleQueue.displayListModule);
// if you are in an LMS, get going on talking to it
if (_global.ORCHID.commandLine.scorm) {
	controlNS.loadMovieToHolder(moduleQueue.scormModule);
}
controlNS.loadMovieToHolder(moduleQueue.objectsModule);
controlNS.loadMovieToHolder(moduleQueue.mainModule);
// v6.4.2.4 For the progress bar to be visible, it has to be loaded to a higher
// depth than buttons. But moving this to later in the queue
// won't guarantee this. Perhaps you can force the depths no matter what
// order they are loaded in?
controlNS.loadMovieToHolder(moduleQueue.tlcModule);
controlNS.loadMovieToHolder(moduleQueue.printingModule);
controlNS.loadMovieToHolder(moduleQueue.buttonsModule);
controlNS.loadMovieToHolder(moduleQueue.jukeboxModule);
controlNS.loadMovieToHolder(moduleQueue.videoModule);
// v6.5.5.5 need a new video module to cope with RTMP streaming. Not just yet though!
controlNS.loadMovieToHolder(moduleQueue.newVideoModule);
// v6.5 Add separate module for displaying progress
controlNS.loadMovieToHolder(moduleQueue.progressModule);
controlNS.loadMovieToHolder(moduleQueue.creditsModule);

// Code from Loading layer - extracted from control.fla
// check to see how the loading is going, and manage the queue

// This function is called by each module once it has done some stuff so that
// we know they can really work.
controlNS.remoteOnData = function(moduleName) {
	myTrace(moduleName + " has initialised",1);
	_global.ORCHID.queue.modules[moduleName].acknowledged = true;
}
// once a module loads, it asks the queue to start loading the next
controlNS.nextLoadingQueue = function() {
	if (_global.ORCHID.queue.loadingQueue.length >0) {
		this.loadFromQueue();
	}
}
// this function works in a loop queueing modules and checking to see how ones in
// the queue are loading. 
controlNS.checkLoadingProgress = function() {
	var thisMC;
	var stillWaiting = false;
	var myModule;
	for (var i in _global.ORCHID.queue.modules) {
		myModule=_global.ORCHID.queue.modules[i];
		// if this module has not been marked as loaded or failed, need to check on it
		if (not (myModule.loaded || myModule.failed)) {
			//myTrace("for " + myModule.holderName + " got loaded=" + myModule.loaded + " failed=" + myModule.failed);
			thisMC = this.master[myModule.holderName];
			// anything that hasn't started loading can't be checked on
			if (thisMC != undefined) {
				// v6.4.2.1 Warning. I am receiving getBytesTotal=-1 immediately, yet the file
				// is actually loading. This is when running from the internet, not locally.
				// Flashcoders suggests that this might happen between the old mc being removed
				// and the new one being loaded. The docs (Moock) are clear that for createEmptyMovieClip
				// the getBytesTotal will be 0 and -1 only means URL not found, but comments suugest
				// that it also depends on the platform. Yes. If I remove the -1 check, I still see
				// 0 of -1 in the debug line before it then immediately starts loading. So this 
				// cannot be relied on. How else to tell if the file is not there? You could let
				// the loadingStuck catch it, it is only that this takes a while. Otherwise you
				// would have to play with a few counts of -1??
				// Note: this is where I should check to see if a module is stuck whilst loading
				// although I doubt that that really happens much. If the getBytesLoaded doesn't
				// change for 20 loops in a row (probably 5 seconds), start loading it again. But
				// only do that once.
				// v6.4.2.4 But on a slow connection you will get stuck mid-loading for 5 seconds
				// So once I know that the module is loading, perhaps I should do a much higher
				// stuck threshold. It is only if the getBytesTotal sticks at 0 that I might
				// be trying to get something that doesn't exist.
				myTrace(thisMC + " loaded " + thisMC.getBytesLoaded() + " of " + thisMC.getBytesTotal());
				if (thisMC.getBytesLoaded() > myModule.lastByteCount) {
					myModule.lastByteCount = thisMC.getBytesLoaded();
					// since you have got a little bit, release the stuck counter
					myModule.loadingStuck=0;
				} else {
					myModule.loadingStuck++;
				}
			}
			// has this module completed loading?
			if ((thisMC.getBytesLoaded() >= thisMC.getBytesTotal()) &&
				 thisMC.getBytesTotal() > 10) {
				myModule.loaded = true;
				myTrace("loaded " + myModule.fileName);
				myModule.lastByteCount = thisMC.getBytesTotal();
				// increase the loaded percentage
				//myTrace("inc % by " + Math.round(100 / _global.ORCHID.queue.totalModules));
				incPercentage(Math.round(100 / _global.ORCHID.queue.totalModules));
				// clear out of the queue
				myModule.loadingStuck=0;
				_global.ORCHID.queue.nowLoading--;
				this.nextLoadingQueue();
			// did it fail, no such URL, or get stuck whilst loading?
			// v6.4.2.1 Temporarily ignore getBytesTotal=-1 to see what happens
			//} else if (thisMC.getBytesTotal() == -1 || myModule.loadingStuck>20) {
			// v6.4.2.4 First check is when we have a no real getBytesTotal
			// second check is when we know we have got something, but it is really stuck
			} else if ((myModule.loadingStuck>20 && thisMC.getBytesTotal() < 10) ||
						(myModule.loadingStuck>100)) {
				// so try again (once) as it appears to have failed to load from URL
				// if you have already tried again once, give up (an error will be caught later)
				if (myModule.tryAgain >0) {
					myModule.failed = true;
					myTrace("failed to load " + myModule.holderName + " after " + myModule.loadingStuck + " stuck loops.",0);
				} else {
					myTrace("try loading " + myModule.holderName + " again",0);
					myModule.tryAgain++;
					myModule.loadingStuck=0;
					// the moment you have to do a reload, set the queue down to 1
					_global.ORCHID.queue.limit = 1;
					// you might prefer to reload in the existing mc to avoid depth complication?
					this.master[myModule.holderName].removeMovieClip();
					this.loadMovieToHolder(myModule);
				}
				_global.ORCHID.queue.nowLoading--;
				this.nextLoadingQueue();
			}
			stillWaiting = true;
		}
	}
	// once everything has loaded or failed, see if the loaded ones have acknowledged
	// Since acknowledgement is asynch, you might get .loaded or .acknowledged first
	// the trace shows both happening. It would be ideal to wait a little while for
	// .acknowledged before you reload or doing else silly.
	if (not stillWaiting) {
//		myTrace("check any failed or not acknowledged");
		for (var i in _global.ORCHID.queue.modules) {
			myModule=_global.ORCHID.queue.modules[i];
			// if it is not acknowledged
			if (myModule.acknowledged == false  && myModule.failed == false) {
				// wait a little longer?
				//myTrace("waiting for " + myModule.holderName + " to acknowledge, " + myModule.loadingStuck);
				if (myModule.loadingStuck<10) {
					myModule.loadingStuck++
					stillWaiting = true;
				//no, OK, lets try again then
				} else {
					// so try again (once) as it appears to have loaded, but not acknowledged
					myTrace(i + " loaded but not initialised",0);
					if (myModule.tryAgain==0) {
						myModule.tryAgain++;
						myModule.loadingStuck=0;
						myModule.loaded = false;
						// the moment you have to do a reload, set the queue down to 1
						_global.ORCHID.queue.limit = 1;
						this.master[myModule.holderName].removeMovieClip();
						this.loadMovieToHolder(myModule);
						stillWaiting = true;
						bar.loadStatus.text = "Trying again...";
					}
				}
			}
		}
	}
	// If you can get through the whole loop without triggering anything to happenit
	// means we have either given up or are ready to go.
	if (not stillWaiting) {
		var missingName = "";
		for (var i in _global.ORCHID.queue.modules) {
			myModule=_global.ORCHID.queue.modules[i];
			if (not (myModule.loaded && myModule.acknowledged)) {
				missingName = missingName + myModule.holderName + "; "
			}
		}
		// v6.5.5.1 For measuring performance
		_global.ORCHID.timeHolder.programLoaded = new Date().getTime();
		myTrace("timer:programLoaded=" + _global.ORCHID.timeHolder.programLoaded);
		var timeTaken = Math.round((_global.ORCHID.timeHolder.programLoaded - _global.ORCHID.queue.startTime) / 1000);
		myTrace("loading finished in " + timeTaken + "s",0);
		clearInterval(this.intervals.checkLoadingInt);
		delete _global.ORCHID.queue;
		if (missingName == "") {
			//myTrace("done as much as I will");
			// Off you go to the main events frame
			// Odd - if I run this here I get a real mess of things, this interval seems
			// to keep running, everything clogs up. But if I use a button to trigger it
			// everything is fine. Try simply putting in an intermediate call to get me out
			// of this function. That also seems fine. Try original line again? Oh, now that is
			// fine too. What else did I do??
			// v6.4.2.4 Later, if I load queryProjector it clashes levels with credits.swf
			// So bump up the controlNS.depth a bit now.
			controlNS.depth+=10;
			this.startTheProgram();
			//this.master.tmpStartTheProgram.onRelease();
		} else {
			var errObj = {literal:"cannotLoadModules", detail:missingName};
			this.sendError(errObj);
		}
	}
}
//tmpStartTheProgram.onRelease = function() {
//	myTrace("click to start");
//	controlNS.startTheProgram();
//}
// v6.3.6 Use an object to gather together any intervals used in this frame
controlNS.intervals = new Object();
controlNS.intervals.checkLoadingInt = setInterval(controlNS, "checkLoadingProgress", 250);

// v6.4.2.8 Note that we pause at the end of this frame waiting for this callback to complete. It can easily take
// the full timeout allotted if it is a laptop that thinks it has internet, but hasn't. The simplest might be to
// just move this chunk to frame 3 where it can happily take as long as it wants.

// v6.4.2.7 Add a check to see if you are connected to the internet at the moment. Will be used later for
// weblinks (pick up from CD if not connected) etc
// v6.5.5.8 Since this only works with mdm, there is a more general way happening earlier (controlFrame2) which works with all.
/*
var address = "www.ClarityEnglish.com"; 
var timeout = "5000"; 
_global.ORCHID.projector.callbacks.getInternetConnection = function(value) {
	myTrace("internet connection=" + value);
	if (value || value.toLowerCase()=="true") {
		_global.ORCHID.projector.internetConnection = true;
	} else {
		_global.ORCHID.projector.internetConnection = false;
	}
}
mdm.checkconnection_ping(address,timeout,_global.ORCHID.projector.callbacks.getInternetConnection); 
myTrace("checking internet connection");
*/
// I don't think I use the old name at all now, but just in case...
_global.ORCHID.projector.internetConnection = _global.ORCHID.commandLine.isConnected;

// Code from Events layer - extracted from control.fla
// *****
// PROCEDURE EVENTS //
// *****
//if (_global.ORCHID.licenceModuleLoaded) {
//if(_global.ORCHID.NumberOfModulesLoaded >= _global.ORCHID.KeyModules) {
//v6.4.2. rootless
//_$startTheProgram = function() {
controlNS.startTheProgram = function() {
	myTrace("startTheProgram");
	// v6.3 Allow possibility of a sting going first
	if (typeof loadSting == "function") {
		//myTrace("loadSting is a function, so run it");
		loadSting();
	} else {
		//myTrace("loadSting is not here, so run initView");
		controlNS.initView();
		controlNS.confirmLicence();
	}
	//loadIntro();
}
// v6.4.2 Remove the waitForStart function from here and put it
// into the loading frame with the stuff that measures loading.
// Once everything is loaded it will call startTheProgram

// the controller starts things going once the licence module is loaded
//myTrace("call $startTheProgram");
controlNS.confirmLicence = function() {
	//trace("in confirm licence");
	// this licence interval isn't set (at least in control or licence)?
	//clearInterval(controlNS.intervals.licenceIntID);
	//v6.4.2 rootless
	_global.ORCHID.root.licenceHolder.licenceNS.getConfirmLicence();
}
// v6.3 If there is a 'sting' animated intro that runs before anything else
// (EGU 1.1) then start it here at the highest visible plane and wait for it to finish
// Then you need to unload it when it has finished. If it is not intensive you could run
// it from buttons itself as being less intrusive.
// It will send back the call to stingFinished when done.
// Comment out this function if you don't want to have a sting here
// You can't base it on brand as the licence file has not been read yet - sadly
// v6.3.2 If you do this here, then if the computer is slow it seems that you can 
// display the login screen before the sting kicks in, so you get a nasty flash.
// Could this be moved to the end of attach frame? Or even earlier?
/*
loadSting = function() {
	//if (loadStingID >= 0) clearInterval(loadStingID);	
	myTrace("loadSting");
	_root.createEmptyMovieClip("stingHolder", _root.controlNS.depth++);
	myTrace("load " + _global.ORCHID.paths.root  + _global.ORCHID.paths.brand  + "CUPsting.swf");
	_root.stingHolder.loadMovie(_global.ORCHID.paths.root  + _global.ORCHID.paths.brand + "CUPsting.swf");
	_root.stingFinished = function() {
		myTrace("stingFinished");
		_root.stingHolder.unloadMovie();
		// Whilst you can do initView while a sting is running, it doesn't really
		// save much time. It would be worth doing if you could do more and then stop
		// at something like getScaffold (which seems to be the really intensive bit).
		_root.controlNS.initView();
		_root.controlNS.confirmLicence();
	}
}
*/
controlNS.initView = function() {
	//myTrace("initView, buttonsModuleLoaded=" + _global.ORCHID.buttonsModuleLoaded);
	// v6.3.6 Interface branding is now governed by the buttons module rather than
	// the licence file.
	_global.ORCHID.setBrandStyles(_global.ORCHID.root.buttonsHolder.buttonsNS.branding);
	
	// 6.0.4.0, AM: initialize the view object and literalModel object
	// 6.0.4.0 use view object to control interface
	// literalModel to store the language in interface
	// Pull the literals file from the main movie folder
	// v6.4.3 Sharing _global across different Flash versions. Had to remove it from pure _global;
	//_global.ORCHID.viewObj = new View();
	_global.ORCHID.viewObj = new _global.ORCHID.root.objectHolder.View();
	
	// v6.3.5 Move literals to the same folder as buttons as this is really a 
	// brand specific set of data
	//_global.ORCHID.literalModelObj = new LiteralModel(_global.ORCHID.paths.movie + "literals.xml", "EN");
	// start with English encoding
	// v6.3.5 Unless the command line suggested otherwise
	if (_global.ORCHID.commandLine.language == undefined) {
		var thisLang = "EN";
	} else {
		// v6.4.2 Also allow a language list, here just take the first one
		if (_global.ORCHID.commandLine.language.indexOf("*") >0) {
			var thisLang = _global.ORCHID.commandLine.language.split("*")[0]
		} else {
			var thisLang = _global.ORCHID.commandLine.language.split(",")[0];
		}
	}
	myTrace("load literals from " + _global.ORCHID.paths.interfaceMovies + "literals.xml, lang=" + thisLang,1);
	// v6.4.3 Sharing _global across different Flash versions. Had to remove it from pure _global;
	//_global.ORCHID.literalModelObj = new LiteralModel(_global.ORCHID.paths.interfaceMovies + "literals.xml", thisLang);
	_global.ORCHID.literalModelObj = new _global.ORCHID.root.objectHolder.LiteralModel(_global.ORCHID.paths.interfaceMovies + "literals.xml", thisLang);
	_global.ORCHID.literalModelObj.addListener(_global.ORCHID.viewObj);
	// v6.4.2.6 Move the literal loading earlier, as a temp move before making it a fully dependent load
	// It happens, exceedingly rare, that the literals are not loading before all modules are, so you see rubbish on screen. How to stop that?
	// Can I catch the literalsLoaded event here as well, and not go on with out it? Or can I just use LiteralModelObj.loaded?
	/*
	_global.ORCHID.literalModelObj.addListener(this);
	this.literalEvent = function(event, success) {
	//myTrace("viewObj: literalEvent - " + event);
	switch (event) {
		case "onLiteralLoad":
			myTrace("control3.onLiteralLoad with success=" + sucess);
			// Release the locking variable
		default:
	}
	*/
	//trace("call to load literals");
	_global.ORCHID.literalModelObj.loadData();
	//trace("start attaching all the screens");
	myTrace("base screen at depth " + _global.ORCHID.root.buttonsHolder.buttonsNS.depth);
	_global.ORCHID.root.buttonsHolder.attachMovie("BaseScreen", "BaseScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	_global.ORCHID.root.buttonsHolder.attachMovie("IntroScreen", "IntroScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	_global.ORCHID.root.buttonsHolder.attachMovie("LoginScreen", "LoginScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	_global.ORCHID.root.buttonsHolder.attachMovie("RegisterScreen", "RegisterScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	_global.ORCHID.root.buttonsHolder.attachMovie("PasswordScreen", "PasswordScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	_global.ORCHID.root.buttonsHolder.attachMovie("CourseListScreen", "CourseListScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	_global.ORCHID.root.buttonsHolder.attachMovie("MenuScreen", "MenuScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	_global.ORCHID.root.buttonsHolder.attachMovie("ExerciseScreen", "ExerciseScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	// The combo box to select screen language is moved to LoginScreen
	//_global.ORCHID.root.buttonsHolder.attachMovie("LiteralScreen", "LiteralScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	// v6.2 the random test screen is now created dynamically
	//_root.creationHolder.attachMovie("RandomTestScreen", "RandomTestScreen", _root.creationHolder.creationNS.depth++);
	// v6.3.3 Use a special screen for progress
	// v6.3.6 No longer use progressScreen, simple messageScreen
	//_root.buttonsHolder.attachMovie("ProgressScreen", "ProgressScreen", _root.buttonsHolder.buttonsNS.depth++);
	// v6.3.3 Use a special screen for test making
	_global.ORCHID.root.buttonsHolder.attachMovie("TestScreen", "TestScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	// v6.3.4 Use a special screen for any other kind of popUp (feedback, scratching, messages)
	// v6.3.4 Due to problems with it being overwritten at 'some' point if you use 110, try
	// just using the next depth at this point.
	//_root.buttonsHolder.createEmptyMovieClip("MessageScreen", _global.ORCHID.MsgBoxDepth);
	_global.ORCHID.root.buttonsHolder.createEmptyMovieClip("MessageScreen", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++);
	//to define functions for the screens attached
	#include "Source/Screen.as"
	#include "Source/ViewReaction.as"
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.BaseScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.IntroScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.LoginScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.RegisterScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.PasswordScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.CourseListScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.MenuScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.ExerciseScreen);
	// The combo box to select screen language is moved to LoginScreen
	//_global.ORCHID.viewObj.screens.push(_root.buttonsHolder.LiteralScreen);
	// v6.2 the random test screen is now created dynamically
	//_global.ORCHID.viewObj.screens.push(_root.creationHolder.RandomTestScreen);
	//_global.ORCHID.viewObj.screens.push(_root.buttonsHolder.ProgressScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.TestScreen);
	_global.ORCHID.viewObj.screens.push(_global.ORCHID.root.buttonsHolder.MessageScreen);
	//trace("call to clear the screens");
	_global.ORCHID.viewObj.clearAllScreens();
	//trace("call to load literals");
	// v6.4.2.6 Move to earlier loading
	//_global.ORCHID.literalModelObj.loadData();
	// v6.2 use a proper base screen from buttons
	//myTrace("call to display the base screen");
	_global.ORCHID.viewObj.displayScreen("BaseScreen");
	//v6.3.4 trouble is that I now want intro screen to be dependent on the licence file
	// so I need to move it
	//_global.ORCHID.viewObj.displayScreen("IntroScreen");
	//_root.buttonsHolder.introFinished = function() {
	//	this._introFinished = true;
	//}	
	
	// v6.5 We have now added in a progressModule extra loaded swf. But this can contain an interface, so unload it here?
	// All we wanted to do by loading it earlier was to get it in cache.
	// v6.5.4.3 Just in case we have a progress harness instead of the real thing
	_global.ORCHID.root.progressHarness = _global.ORCHID.root.progressHolder.progressNS.harness;
	_global.ORCHID.root.progressHolder.removeMovieClip();
}

// the licence control triggers this event once it has been confirmed.
// Make sure that the objects module is loaded by this point as we are about to make use
// of it.
// 6.0.6.0 Extra step to allow database connection after licence file reading
// v6.5.5.1 Ideally I would run getRMSettings before this as I may be getting licence details from the database rather than a file
controlNS.setConfirmLicence = function (institutionName, errObj) {
	// At this point you now know all the details held in the licence file
	// v6.5.5.1 I need to display intro earlier as the animation plays before we come here.
	// so you can ask the intro screen to display (as it might be dependent on the licence)
	//_global.ORCHID.viewObj.displayScreen("IntroScreen");
	//myTrace("confirm licence " + _global.ORCHID.root.licenceHolder.licenceNS.product + " licenced to " + _global.ORCHID.root.licenceHolder.licenceNS.institution,0);
	// v6.4.2.4 Trigger the institution name onto the screen as it might not have been
	// read when you are doing the regular introScreen processing.
	//_global.ORCHID.root.buttonsHolder.IntroScreen.setLiterals();

	// v6.3.2 Is there any overriding of source file location?
	// No, too late since all the files are already loaded!
	/*
	if (_root.licenceHolder.licenceNS.remoteServer != undefined) {
		myTrace("overwrite source=" + _root.licenceHolder.licenceNS.remoteServer);
		_global.ORCHID.paths.source = _root.licenceHolder.licenceNS.remoteServer;
	}
	*/
	// 6.0.7.0 display the demo logo if it is a demo version
	myTrace("productType=" + _global.ORCHID.root.licenceHolder.licenceNS.productType);
	if(_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase() == "demo") {
		// v6.3.4 Attach it from buttons rather than branding
		_global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("demoWarning","demoWarning",0);
		// v6.4.2.8 Add a note about exercises that are not in the demo
		_global.ORCHID.root.buttonsHolder.MessageScreen.demoWarning.notInDemo._visible = false;
		myTrace("adding literal for notInDemo as " + _global.ORCHID.literalModelObj.getLiteral("notInDemo", "messages"));
		_global.ORCHID.root.buttonsHolder.MessageScreen.demoWarning.notInDemo.notInDemo_lbl.text = _global.ORCHID.literalModelObj.getLiteral("notInDemo", "messages");
		//_root.brandingHolder.demoLogo._visible = true;
	} else if(_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase() == "review") {
		// v6.3.4 Attach it from buttons rather than branding
		_global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("reviewWarning","reviewWarning",0);
		//_root.brandingHolder.reviewLogo._visible = true;
	// v6.5.5.5 For betas
	} else if(_global.ORCHID.root.licenceHolder.licenceNS.productType.toLowerCase() == "beta") {
		// v6.3.4 Attach it from buttons rather than branding
		_global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("betaWarning","betaWarning",0);
		//_root.brandingHolder.reviewLogo._visible = true;
	// v6.4.2.4 Make the registration 30 day warning in addition to the demo tag not OR
	//} else if(_global.ORCHID.root.licenceHolder.licenceNS.registrationDate == undefined || _global.ORCHID.root.licenceHolder.licenceNS.registrationDate == "") {
	} else {
		//_root.brandingHolder.demoLogo.removeMovieClip();
	}
	// v6.5.5.1 use licence start date for db information
	if(	(_global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate == undefined || _global.ORCHID.root.licenceHolder.licenceNS.licenceStartDate == "") &&
		(_global.ORCHID.root.licenceHolder.licenceNS.registrationDate == undefined || _global.ORCHID.root.licenceHolder.licenceNS.registrationDate == "")) {
		//myTrace("registration date is empty, installation date=" + _root.licenceHolder.licenceNS.installationDate);
		// only display the warning if there is no other licence error
		if (errObj == undefined) {
			// v6.5 Switch to no entry for unregistered licences. This should only impact network copies
			errObj = {literal:"notActivated"};
			/*
			// if today is too far past the installation date (1 month), then
			// the registration warning becomes a licence error			
			// v6.3 A function for turning a Clarity standard date into a Flash date object
			var formatDateForFlash = function(dateString) {
			// assume YYYY-MM-DD HH:MM:SS
				var mainParts = dateString.trim("both").split(" ");
				var datePart = mainParts[0].split("-");
				var timePart = mainParts[1].split(":");
				var thisDate = new Date(datePart[0], datePart[1]-1, datePart[2], timePart[0], timePart[1], timePart[2]);
				//myTrace("the date I made was " + thisDate.toString());
				return thisDate;
			}
			
			// v6.4.2.7 We no longer write the installation date into the file if as all licence stuff is done during the registration program
			// So we don't know how long it has been unregistered for.
			var installDate = formatDateForFlash(_global.ORCHID.root.licenceHolder.licenceNS.installationDate);
			//myTrace("install date =" + installDate + " as seconds=" + installDate.getTime());
			var timeNow = new Date().getTime();
			// 1 month = ...
			//if (timeNow > (installDate.getTime() + (1000 * 60 * 60 * 24 * 31))) {
			//	myTrace("the program has been unregistered for more than a month",0);
			//	errObj = {literal:"notRegisteredTooLong", detail:_global.ORCHID.root.licenceHolder.licenceNS.installationDate};
			//} else {
				myTrace("show the registration warning");
				// v6.3.5 If you are running Author Plus, then it is the authoring side that should
				// be activated, so don't show a message here on the student side
				// v6.4.2.7 No, this is no longer true - I want this message on the student side to get action
				//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("APP") < 0 && 
				//   _global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("APL") < 0  && 
				//  _global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("APO") < 0) {
					// v6.3.4 Attach it from buttons rather than branding
					myTrace("activation warning as branding=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
					_global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("registrationWarning","registrationWarning",0);
					//_root.brandingHolder.registrationWarning._visible = true;
					this.sendWarning("notActivated");
				//}
			//}
			*/
		}
	}
	// what do you know about the client/machine?
	// v6.3.5 FSP moves to ZINC
	//if (_global.ORCHID.projector.name == "FlashStudioPro") {
	if (_global.ORCHID.projector.name == "MDM") {
		//_global.ORCHID.projector.cdDrive = _root.FSPcddrive;
		//_global.ORCHID.projector.ipAddress = _root.FSPip;
		//_global.ORCHID.projector.machineID = _root.FSPmachineID;
		// Now done earlier.
		//myTrace("CD drive=" + _root.FSPcddrive);
		myTrace("IP address=" + _global.ORCHID.projector.ipAddress + ", machineID=" + _global.ORCHID.projector.machineID,1);
	} else if (_global.ORCHID.commandLine.ip != undefined || _global.ORCHID.commandLine.ip != "") {
		_global.ORCHID.projector.ipAddress = _global.ORCHID.commandLine.ip
	}
		
	// v6.3.3 See if there needs to be a match between licence and computer
	// This is ignored if the licence file does not record serial number
	if (_global.ORCHID.root.licenceHolder.licenceNS.control.hdSerial != undefined &&
		_global.ORCHID.root.licenceHolder.licenceNS.control.hdSerial != _global.ORCHID.projector.machineID) {
		// myTrace("licence HDserial=" + _root.licenceHolder.licenceNS.control.hdSerial + " actual HDserial=" + _global.ORCHID.projector.machineID);
		errObj = {literal:"wrongComputer"};
	}
	// v6.3.4 See if there needs to be a match between licence and IP range
	// This is ignored if the licence file does not record IP range
	// v6.4.1.5 Add in referrer URL as valid request
	// If both present, just one needs to match, not both.
	// v6.5.6.3 Nice to differentiate which check you fail
	var checkIPRequest = false;
	var checkRURequest = false;
	var checkLicenceRequest = false;
	var requestIPOK = false;
	var requestRUOK = false;
	var requestLicenceOK = false;
	if (_global.ORCHID.root.licenceHolder.licenceNS.control.IPrange != undefined) {
		checkIPRequest = true;
		checkLicenceRequest = true;
		myTrace("check IP range",1);
		if (_global.ORCHID.root.licenceHolder.licenceNS.inIPRange(_global.ORCHID.projector.ipAddress, _global.ORCHID.root.licenceHolder.licenceNS.control.IPrange)) {
			myTrace("success with " + _global.ORCHID.projector.ipAddress);
			requestIPOK = true;
			requestLicenceOK = true;
		}
	}
	if (_global.ORCHID.root.licenceHolder.licenceNS.control.RUrange != undefined) {
		checkRURequest = true;
		checkLicenceRequest = true;
		myTrace("check referrer range",1);
		if (_global.ORCHID.root.licenceHolder.licenceNS.inRURange(_global.ORCHID.commandLine.referrer, _global.ORCHID.root.licenceHolder.licenceNS.control.RUrange)) {
			myTrace("success with " + _global.ORCHID.commandLine.referrer);
			requestRUOK = true;
			requestLicenceOK = true;
		}
	}
	// v6.5.6.3 You are supposed to be able to get in through EITHER, not needing both!
	// So add an outside condition checking both
	if (checkLicenceRequest && !requestLicenceOK) {
		if (checkIPRequest && !requestIPOK) {
			myTrace("licence IPrange=" + _global.ORCHID.root.licenceHolder.licenceNS.control.IPrange + " actual ipAddress=" + _global.ORCHID.projector.ipAddress,1);
			// v6.4.2.7 Try to let the user know some more information to help debug
			errObj = {literal:"wrongIP", detail:_global.ORCHID.projector.ipAddress};
		} else if (checkRURequest && !requestRUOK) {
			myTrace("licence RUrange=" + _global.ORCHID.root.licenceHolder.licenceNS.control.RUrange + " actual referrer=" + _global.ORCHID.commandLine.referrer,1);
			// v6.4.2.7 Try to let the user know some more information to help debug
			errObj = {literal:"wrongRU", detail:_global.ORCHID.commandLine.referrer};
		}
	}
	// v6.3.5 See if there needs to be a match between licence and host server
	// This is ignored if the licence file does not specify the host server
	// v6.4.2 AR make it case insensitive
	if (_global.ORCHID.root.licenceHolder.licenceNS.control.server != undefined &&
		_global.ORCHID.root.licenceHolder.licenceNS.control.server.toLowerCase() != _global.ORCHID.commandLine.server.toLowerCase()) {
		myTrace("licence host=" + _global.ORCHID.root.licenceHolder.licenceNS.control.server + " actual server=" + _global.ORCHID.commandLine.server,2);
		errObj = {literal:"wrongServer", detail:_global.ORCHID.root.licenceHolder.licenceNS.control.server};
	}
	
	// v6.5.4.1 Licence server matches either just the hostname, or the hostname and IP
	// Comes from the licence in two parts, hostname and, optional, IP address.
	// If you have the IP address listed, then licence.as will already have asked MDM for the IP translation
	// First of all, confirm that the licence path contains the licenceServer string
	if (_global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.name != undefined) {
		if (_global.ORCHID.commandLine.licence.toLowerCase().indexOf(_global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.name.toLowerCase())<0) {
			myTrace("licence required path=" + _global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.name + " actual path=" + _global.ORCHID.commandLine.licence,2);
			errObj = {literal:"wrongServer", detail:_global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.name};
		} else {
			myTrace("licence server name matched on " + _global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.name);
			// If it does and we have an IP, match it. Except that you can't do this here as we may not know the mdm got ip address yet.
			// So the call to the error will have to be done in licence in teh mdm callback.
			/*
			if (_global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.IP != undefined) {
				if (_global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.IP!=_global.ORCHID.projector.serverIPAddress) {
					myTrace("licence required IP=" + _global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.IP + " actual IP=" + _global.ORCHID.projector.serverIPAddress,2);
					errObj = {literal:"wrongServer", detail:_global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.IP};
				}
			} else {
				myTrace("licence server matched on " + _global.ORCHID.root.licenceHolder.licenceNS.control.licenceServer.name);
			}
			*/
		}
	} 
	
	// v6.4.3 Is there a protection method that needs something special?
	// This is used currently just for SecuRom that cannot protect this file directly
	if (_global.ORCHID.root.licenceHolder.licenceNS.protection == "SecuROM" &&
		_global.ORCHID.commandLine.protectionParameter != "opi87134509873149087hgr") {
		// myTrace("licence protection=" + _root.licenceHolder.licenceNS.protection);
		errObj = {literal:"wrongStartProgram"};
	}
	
	// v6.5.4.8 If there is no rootID from teh licence, but there is one from commandLine/location, then use that
	if (_global.ORCHID.root.licenceHolder.licenceNS.central.root == undefined && _global.ORCHID.commandLine.rootID.length>0) {
		_global.ORCHID.root.licenceHolder.licenceNS.central.root = _global.ORCHID.commandLine.rootID;
		myTrace("use rootID from commandLine = " + _global.ORCHID.root.licenceHolder.licenceNS.central.root);
	}
	
	// once the licence is confirmed, find all the program settings
	if (errObj == undefined) {		
		//myTrace("scripting with " + _root.licenceHolder.licenceNS.scripting)
		// v6.2 Now that you know the branding from the licence, set some styles
		// v6.3.6 This is now moved to the top of initView as branding comes from
		// buttons module rather than the licence.
		//_global.ORCHID.setBrandStyles(_root.licenceHolder.licenceNS.branding);
		// 6.0.6.0 connect to the database
		// v6.4.2 Main is now waited for before starting anything
		
		// v6.5.5.1 I want to run getRMSettings before I call confirmLicence as this might get licence info.
		// So now I want to simply go back to where I was called from (controlFrame3.checkAccess)
		myTrace("end of confirm licence to " + _global.ORCHID.root.licenceHolder.licenceNS.institution);
		// v6.5.5.1 I am now confident I know all the licence details, so..
		_global.ORCHID.root.buttonsHolder.IntroScreen.setLiterals();
		//_global.ORCHID.root.mainHolder.dbInterfaceNS.connect();
		return true;
		
	} else {
		// v6.2 How do you convey this licence file failure to the student?
		// is the view object loaded yet?
		// v6.5.5.5 You also need to stop the normal processing from happening
		this.sendError(errObj);
		myTrace("sorry, the licence control does not let you pass, code=" + errObj.literal,0);
		return false;
	}
}
// v6.2
// send errors in the licence file to the user
//v6.4.2 rootless
controlNS.sendError= function(errObj) {
	// v6.5.6 To remove any progress bar that was left displayed
	var myController = _global.ORCHID.root.tlcController;
	myController.setEnabled(false);
	
	//myTrace("sendError this=" + this.whoami); // this is controlNS
	// since this is the end of everything, stop any intervals running
	for (var i in this.intervals) {
		clearInterval(this.intervals[i]);
	}
	var initObj = {_x: 200, _y: 220};
	//v6.4.2 rootless
	//_root.errMsgBox.removeMovieClip();
	//var myMsgBox = _global.ORCHID.root.attachMovie("FMessageBoxSymbol", "errMsgBox", _global.ORCHID.root.controlNS.depth++, initObj);
	_global.ORCHID.root.errMsgBox.removeMovieClip();
	var myMsgBox = _global.ORCHID.root.attachMovie("FMessageBoxSymbol", "errMsgBox", this.depth++, initObj);
	//v6.3.3 If the licence does not exist or has no branding item, put up a special heading
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding == undefined) {
		myMsgBox.setTitle("Licence problem");
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/EGU") >= 0) {
		myMsgBox.setTitle("English Grammar in Use");
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/AGU") >= 0) {
		myMsgBox.setTitle("Advanced Grammar in Use");
	} else {
		//v6.4.2 Why not set the title to be the institution name from the licence?
		//myMsgBox.setTitle(_global.ORCHID.root.licenceHolder.licenceNS.product);
		myMsgBox.setTitle("Licence: " + _global.ORCHID.root.licenceHolder.licenceNS.institution);
	}
	// Ahh, maybe I haven't loaded the literals yet!
	//var sorryMsg = _global.ORCHID.literalModelObj.getLiteral("licenceBlock", "messages");
	//var detailMsg = _global.ORCHID.literalModelObj.getLiteral(errObj.literal.split("[x]").join(errObj.detail), "messages");
	var sorryMsg = "Sorry, the licence will not let you run the program.";
	if (errObj.literal == "licenceExpired") {
		var detailMsg = "The licence has expired (on [x]).";
	} else if (errObj.literal == "licenceAltered") {
		var detailMsg = "The licence has been altered or corrupted.";
	} else if (errObj.literal == "notRegisteredTooLong") {
		var noSorry = true;
		// v6.4.2.4 Why would you treat AP differently? Is it to do with APL?
		// But you do want to treat network and online versions differently
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity/AP") >= 0) {
		//	var detailMsg = "This account has not been activated yet. Please check the instructions in your Author Plus registration email.";
		//} else {
		if (_global.ORCHID.projector.name == "MDM") {
			//var detailMsg = "This program has been unregistered for too long (since [x]). Please use register.exe to activate it.";
			var detailMsg = "This program is unregistered. Please use register.exe to activate it.";
		} else {
			var detailMsg = "This account has not been activated yet. Please check the instructions in your welcome email.";
		}
		//}
	} else if (errObj.literal == "wrongComputer") {
		var detailMsg = "The licence has been registered on a different computer.";
	} else if (errObj.literal == "wrongIP") {
		var detailMsg = "The program can only be run from a limited range of computers or websites. Your IP is [x]";
	} else if (errObj.literal == "wrongRU") {
		var detailMsg = "The program can only be run from a limited range of websites.";
	} else if (errObj.literal == "wrongServer") {
		var detailMsg = "The licence can only run from server [x].";
	} else if (errObj.literal == "notInSCORM") {
		var noSorry = true;
		var detailMsg = "This course should be run from an LMS, but the SCORM settings are not running.";		
	} else if (errObj.literal == "blockedAccess") {
		var noSorry = true;
		var detailMsg = "This application has been blocked from your website link. Please start from www.ClarityEnglish.com";
	} else if (errObj.literal == "licenceMissing") {
		var noSorry = true;
		var detailMsg = "The licence can't be found. Some webservers hide licence.ini. Try renaming to licence.txt and restart.";
	// v6.4.2.4 Match the licence against the content
	} else if (errObj.literal == "mismatchLicenceContent") {
		var noSorry = true;
		var detailMsg = "The licensed program is [x] but the content comes from another title and requires a different licence.";
	// v6.4.2.4 Match the licence and against the interface
	} else if (errObj.literal == "mismatchLicenceInterface") {
		var noSorry = true;
		var detailMsg = "The licensed program is [x] but the interface comes from another title and requires a different licence.";
	// v6.5 An unregistered licence is now an error
	} else if (errObj.literal == "notActivated") {
		var noSorry = true;
		var detailMsg = "You need to register this program. Please read the installation instructions to see how to complete the registration.";
	} else if (errObj.literal == "dbMissing") {
		var noSorry = true;
		var detailMsg = "Database connection problem: [x]";
	} else if (errObj.literal == "noDBConnection") {
		var noSorry = true;
		var detailMsg = "The database cannot be read, please try again later or contact your support team. [x]";
	} else if (errObj.literal == "dbError") {
		var noSorry = true;
		var detailMsg = "The database is badly damaged, it says: [x]";
	} else if (errObj.literal == "cannotLoadXML") {
		var noSorry = true;
		var detailMsg = "[x] cannot be read, please contact your support team.";
	} else if (errObj.literal == "cannotLoadModules") {
		myMsgBox.setTitle("Downloading has stopped");
		var noSorry = true;
		myTrace("loading problem");
		//var detailMsg = "[x] cannot be read. Please try again or contact your support team.";
		var detailMsg = "There is a connection problem. Please reload this page, pressing F5 usually works, or contact your support team.";
		debugNote.text = "Technical note: [x]".split("[x]").join(errObj.detail);
	// v6.4.3 SecuROM protection has been skipped
	} else if (errObj.literal == "wrongStartProgram") {
		myMsgBox.setTitle("Start sequence");
		var noSorry = true;
		myTrace("wrong start program");
		var detailMsg = "This program must be run by double-clicking the Start.exe file. Please try again from the CD.";
	// v6.5.4.5 AR What if we have blocked all courses?
	} else if (errObj.literal == "noAuthorisedCourses") {
		var noSorry = true;
		//var detailMsg = _global.ORCHID.literalModelObj.getLiteral("noAuthorisedCourses", "messages");
		var detailMsg = "This content is not available to your group. Please contact your administrator.";
	// v6.5.4.3 Yiu, account expiry, show the error message
	} else if(errObj.literal == "AccountExpired"){
		var noSorry	= true;
		var detailMsg	= errObj.detail;
	// v6.5.5.2 Account not yet started
	} else if(errObj.literal == "AccountNotStarted"){
		var noSorry	= true;
		var detailMsg	= errObj.detail;
	// v6.5.5.2 Account not accepted terms and conditions
	} else if(errObj.literal == "TermsConditions"){
		var noSorry	= true;
		var detailMsg	= errObj.detail;
	// v6.5.4.3 Yiu, duplicate licence ID
	// v6.5.5.0 Change name to instance.
	// v6.5.5.0 Also need to explain more about this.
	//} else if(errObj.literal == "LicenceIDNotMatch"){
	} else if(errObj.literal == "InstanceIDNotMatched"){
		var noSorry	= true;
		var detailMsg	= errObj.detail;
	} else if(errObj.literal == "NoAccount"){
		var noSorry	= true;
		var detailMsg	= errObj.detail;
	// v6.5.5.6 For non-payment
	} else if(errObj.literal == "accountSuspendedNonPayment"){
		var noSorry	= true;
		var detailMsg	= errObj.detail;
	// v6.5.5.9 For trying to run more courses than you are allowed to
	} else if(errObj.literal == "courseLimitReached"){
		var noSorry	= true;
		var detailMsg	= _global.ORCHID.literalModelObj.getLiteral(errObj.literal, "messages").split("[courseLimit]").join(errObj.detail);
	// v6.5.6 For multiple users on a preset login
	} else if(errObj.literal == "multipleUsers"){
		var noSorry	= true;
		var detailMsg	= _global.ORCHID.literalModelObj.getLiteral("multipleUsers", "messages");
	}

	if (noSorry) {
		//myMsgBox.setMessage(detailMsg.split("[x]").join(errObj.detail));
		var fullText = detailMsg.split("[x]").join(errObj.detail);
	} else {
		//myMsgBox.setMessage(sorryMsg + " " + detailMsg.split("[x]").join(errObj.detail));
		var fullText = sorryMsg + " " + detailMsg.split("[x]").join(errObj.detail);
	}
	// v6.4.2.7 Deepen to allow error messages to spread out
	if (fullText.length > 180) {
		//myTrace("long msg so big box");
		myMsgBox.setSize(400, 300);
	} else {
		//myTrace("neat little box");
		myMsgBox.setSize(350, 200);
	}
	myMsgBox.setMessage(fullText);
	//myMsgBox.setButtons([_global.ORCHID.literalModelObj.getLiteral("exit", "buttons")]);
	myMsgBox.setButtons(["Exit"]);
	myMsgBox.setIcon("error");
	this.errorHandler = function(component, buttonIndex) {
		myTrace("try to exit the program");
		//Key.removeListener(myMsgBox);
		//v6.4.2 rootless
		//_root.controlNS.startExit(true);
		// v6.5.4.5 Errors may come after login now with blocked usernames, so try to logout properly if you have a session ID
		if (_global.ORCHID.session.sessionID > 0) {
			myTrace("error, do session exit");		
			_global.ORCHID.session.exit()
		} else {
			this.startExit(true);
		}
	}
	// set a dummyHandler to ActivateHandler as the defaultActivateHandler is swapDepth(0)
	myMsgBox.setActivateHandler("dummyHandler", this);
	myMsgBox.setCloseHandler("errorHandler", this);
}
// v6.3
// show registration warning to the user
//v6.4.2 rootless
//_$sendWarning= function(warningType) {
controlNS.sendWarning= function(warningType) {
	var initObj = {_x: 170, _y: 200};
	_global.ORCHID.root.errMsgBox.removeMovieClip();
	var myMsgBox = _global.ORCHID.root.attachMovie("FMessageBoxSymbol", "errMsgBox", this.depth++, initObj);
	//v6.3.3 If the licence does not exist or has no branding item, put up a special heading
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding == undefined) {
		myMsgBox.setTitle("Licence problem");
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		myMsgBox.setTitle("English Grammar in Use");
	} else {
		myMsgBox.setTitle(_global.ORCHID.root.licenceHolder.licenceNS.product);
	}
	// Ahh, maybe I haven't loaded the literals yet!
	//var sorryMsg = _global.ORCHID.literalModelObj.getLiteral("licenceBlock", "messages");
	//var detailMsg = _global.ORCHID.literalModelObj.getLiteral(errObj.literal.split("[x]").join(errObj.detail), "messages");
	if (warningType == "notActivated") {
		var sorryMsg = "This is an unregistered copy. Please register as soon as possible.";
	}else if (warningType == "passwordChanged") {
		var sorryMsg = "Your password has been successfully changed.";
	}
	myMsgBox.setMessage(sorryMsg);
	myMsgBox.setSize(350, 150);
	//myMsgBox.setButtons([_global.ORCHID.literalModelObj.getLiteral("exit", "buttons")]);
	//myMsgBox.setButtons(["OK", "Help"]);
	// v6.3.1 Where does help go??
	myMsgBox.setButtons(["OK"]);
	myMsgBox.setIcon("warning");
	// YOu don't actually have to do anything, just make sure they read the warning
	this.warningHandler = function(component, buttonIndex) {
		if (buttonIndex == 1) {
		} else {
			//myTrace("clicked button " + buttonIndex);
			//Key.removeListener(myMsgBox);
		}
	}
	// set a dummyHandler to ActivateHandler as the defaultActivateHandler is swapDepth(0)
	myMsgBox.setActivateHandler("dummyHandler", this);
	myMsgBox.setCloseHandler("warningHandler", this);
}
controlNS.sendNotice= function(noticeObject) {
	var initObj = {_x: 170, _y: 200};
	_global.ORCHID.root.errMsgBox.removeMovieClip();
	var myMsgBox = _global.ORCHID.root.attachMovie("FMessageBoxSymbol", "errMsgBox", this.depth++, initObj);
	//v6.3.3 If the licence does not exist or has no branding item, put up a special heading
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding == undefined) {
		myMsgBox.setTitle("Licence problem");
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		myMsgBox.setTitle("English Grammar in Use");
	} else {
		myMsgBox.setTitle(_global.ORCHID.root.licenceHolder.licenceNS.product);
	}
	// Ahh, maybe I haven't loaded the literals yet!
	//var sorryMsg = _global.ORCHID.literalModelObj.getLiteral("licenceBlock", "messages");
	//var detailMsg = _global.ORCHID.literalModelObj.getLiteral(errObj.literal.split("[x]").join(errObj.detail), "messages");
	//if (noticeObject.type == "passwordChanged") {
	//	//var msgText = "Your password has been successfully changed.";
	//}

	// v6.5.6 Surely we have loaded literals at this point?
	if (noticeObject.literal == "noVisibleCourses") {
		noticeObject.detail = "All the courses have been been hidden, please check with your teacher. Results Manager can be used to show content.";
	} else if (noticeObject.literal == "noCourses") {
		noticeObject.detail = "There are no courses available for you, please check with your teacher.";
	}
	myMsgBox.setMessage(noticeObject.detail);
	myMsgBox.setSize(350, 150);
	myMsgBox.setButtons(["OK"]);
	myMsgBox.setIcon("info");
	// YOu don't actually have to do anything, just make sure they read the warning
	this.noticeHandler = function(component, buttonIndex) {
		if (buttonIndex == 1) {
		} else {
			//myTrace("clicked button " + buttonIndex);
			//Key.removeListener(myMsgBox);
		}
	}
	// set a dummyHandler to ActivateHandler as the defaultActivateHandler is swapDepth(0)
	myMsgBox.setActivateHandler("dummyHandler", this);
	myMsgBox.setCloseHandler("noticeHandler", this);
}

// 6.0.6.0 Extra step to allow database connection after licence reading
// 6.0.5.0 pass back new parameters from the licence
controlNS.dbConnected = function(errObj) {
	// once the database is connected, find all the program settings
	//myTrace("control:dbConnected this=" + this.whoami); // this=proxy root!
	if (errObj == undefined) {
		var getSettings = function() {
			//myTrace("getSettings this=" + this.whoami); // this=??
			if ((_global.ORCHID.dbInterface.dbConnection != undefined)) {
				clearInterval(controlNS.intervals.dbWaitIntID);
				controlNS.readProgramSettings();
			} else {
				myTrace("waiting for dbConnection in dbConnected",1);
			}
		}
		// you need to be sure that the object and db module is loaded before doing this
		if ((_global.ORCHID.dbInterface.dbConnection != undefined)) {
			getSettings();
		} else {
			controlNS.intervals.dbWaitIntID = setInterval(getSettings, 1000);
		}	
	} else {
		myTrace("sorry, the database could not be connected, code=" + errObj,0);
	}
}
controlNS.readProgramSettings = function() {
	//v6.4.2.1 Show the licence name. Can't do it earlier, as likely literals not yet loaded.
	//_global.ORCHID.viewObj.showLicenceName();
	
	// v6.5.5.1 Moved from inside confirmLicence to here - I don't think it is dependent on the licence
	// so you can ask the intro screen to display (as it might be dependent on the licence)
	_global.ORCHID.viewObj.displayScreen("IntroScreen");
	//myTrace("confirm licence " + _global.ORCHID.root.licenceHolder.licenceNS.product + " licenced to " + _global.ORCHID.root.licenceHolder.licenceNS.institution,0);
	// v6.4.2.4 Trigger the institution name onto the screen as it might not have been
	// read when you are doing the regular introScreen processing.
	// v6.5.5.1 and it sill might not if coming from getRMSettings
	//_global.ORCHID.root.buttonsHolder.IntroScreen.setLiterals();
	
	//myTrace("control: now get program settings from " + _global.ORCHID.paths.root + "settings.ini");
	//myTrace("readProgSet this=" + this.whoami); // again, proxy root
	var internalReadProgramSettings = function() {
		// v6.3.6 Remove login into merged main
		 //_global.ORCHID.loginModuleLoaded) {
		//myTrace("intReadProgSet this=" + this.whoami); // nothing

		// v6.4.2 Different loading counting method
		//if ((_global.ORCHID.commandLine.scorm == Boolean(_global.ORCHID.scormModuleLoaded)) &&
		//	 _global.ORCHID.mainModuleLoaded) {
		// IF you are using SCORM, then make sure module is loaded. If you aren't just do it.
		// v6.4.2 All modules will be loaded for sure now, so nothing to wait for
		//if ((_global.ORCHID.commandLine.scorm &&_global.ORCHID.isModuleLoaded("scormModule")) ||
		//	(_global.ORCHID.commandLine.scorm == false)) {
			
		clearInterval(controlNS.intervals.settingsIntID);
		_global.ORCHID.programSettings = new objectHolder.ProgramSettingsObject();
		// create a callback function for once it is loaded
		_global.ORCHID.programSettings.onLoad = function() {
			myTrace("control.programSettings.onLoad callback");
			// v6.3.4 If there is an animated intro, let that trigger the 
			// continuation.
			// It is hoped that the buttons.swf will set the following to true
			// so that we know an animation is happening.
			if (_global.ORCHID.root.buttonsHolder.buttonsNS.animatedIntro) {
			//myTrace("animatedIntro=" + _global.ORCHID.root.buttonsHolder.buttonsNS.animatedIntro + " scorm=" + _global.ORCHID.commandLine.scorm + " username=" + _global.ORCHID.commandLine.userName + ".")
				myTrace("pause here waiting for intro",0);
				// set a timer so that if for some reason the intro doesn't send the right
				// event you will not wait forever. How long is reasonable, 15 secs?
				// You need to work out how to clear the interval once it is set.
				goAnyway = function() {
					myTrace("animated intro didn't send end event");
					clearInterval(controlNS.intervals.animatedIntroInt);
					// v6.3.5 Add in extra check on access control, so that will trigger readUser
					//_$readUser();
					controlNS.animatedIntroEnd();
				}
				controlNS.intervals.animatedIntroInt = setInterval(goAnyway, 15000);
			} else {
				myTrace("no intro pause");
				// once the program settings are loaded, get the user information
				// v6.3.5 Add in extra check on access control, so that will trigger readUser
				//_$readUser();
				//myTrace("before checkAccess this=" + this.whoami);
				controlNS.checkAccess();
			}
		}
		//myTrace("ask prog set to load");
		// v6.5.6 For SCORM (HCT) we might not know which account we are working in. 
		//	In which case we don't want to do getRMSettings first, we want to do a getGlobalUser first.
		// 	Since this will be based on a unique student ID, if we find the user we can then get the root from membership.
		//	I don't want to do this in general cases. And if I don't find the user, I will add them to a common account.
		// v6.5.6. Actually I think a better approach is to use groupedRoots from licence and SCORM to do this all within regular startUser.
		// Mind you this approach is good in that it does getRMSettings correctly. Hmm. I could leave it for the single specific instance of HCT...
		// But this would not be good as some HCT accounts have loginOption=1, which could easily cause duplicate studentIDs to be used.
		// So lets stick with forcing the getRMSettings to come from the default root, and just pick up the user from the actual root.
		/*
		myTrace("checking up on: id=" + _global.ORCHID.commandLine.studentID + " prefix=" + _global.ORCHID.commandLine.prefix);	
		if (_global.ORCHID.commandLine.scorm && 
			_global.ORCHID.commandLine.prefix=="DEMO" && 
			_global.ORCHID.commandLine.studentID!=undefined) {
			myTrace("lets try and find the student first");
			controlNS.findGlobalStudent();
		} else {
			_global.ORCHID.programSettings.load();
		}
		*/
		_global.ORCHID.programSettings.load();
		//} else {
		//	myTrace("waiting for scorm module to load",1);
		//}
	}
	// v6.3.3 You need to check that the scorm module is loaded (if this is what you are using)
	//myTrace("scorm=" + _global.ORCHID.commandLine.scorm + " and sML=" + _global.ORCHID.scormModuleLoaded);
	//myTrace("together=" + (_global.ORCHID.commandLine.scorm == Boolean(_global.ORCHID.scormModuleLoaded)));
	// v6.4.2 Different loading counting method
	//if ((_global.ORCHID.commandLine.scorm == Boolean(_global.ORCHID.scormModuleLoaded)) &&
	//	_global.ORCHID.mainModuleLoaded) {
	// IF you are using SCORM, then make sure module is loaded. If you aren't just do it.
	// v6.4.2 All modules will be loaded for sure now, so nothing to wait for
	//if ((_global.ORCHID.commandLine.scorm &&_global.ORCHID.isModuleLoaded("scormModule")) ||
	//	(_global.ORCHID.commandLine.scorm == false)) {
		//myTrace("go now");
	internalReadProgramSettings();
	//} else {
		//myTrace("go later");
	//	controlNS.intervals.settingsIntID = setInterval(internalReadProgramSettings, 1000);
	//}
}
// v6.5.6 Specifically for HCT SCORM now where we want to match the studentID if possible, otherwise add to a common root
controlNS.findGlobalStudent = function() {
	
	var thisDB = new _global.ORCHID.root.mainHolder.dbQuery();
	thisDB.queryString = '<query method="getGlobalUser" ' + 
					// For testing purposes as Moodle doesn't really send back the studentID from the database
					'studentID="' + _global.ORCHID.commandLine.studentID + '" ' + 
					//'studentID="P574528(8)" ' + 
					'password="$!null_!$" ' + 
					'loginOption="2" ' + 
					// You can't send this as you don't know it yet! Lets assume it is 5
					'databaseVersion="5" ' +
					'cacheVersion="' + new Date().getTime() + '"/>';
	thisDB.xmlReceive = new XML();
	thisDB.xmlReceive.master = this;
	thisDB.xmlReceive.onLoad = function(success) {
		myTrace("back to getGlobalUser from db with " + this.toString());

		//myTrace("return node=" + this.toString());
		for (var node in this.firstChild.childNodes) {
			var tN = this.firstChild.childNodes[node];
			//sendStatus("node=" + tN.toString());
			// is there a an error node?
			if (tN.nodeName == "err") {
				// 206 is no such user. That's fine. It means we will use the common account to add this user to
				myTrace("error: " + tN.firstChild.nodeValue + " (code=" + tN.attributes.code + ")")
			// we are expecting to get back a user node
			} else if (tN.nodeName == "user") {
				// parse the returned XML to get user details
				_global.ORCHID.root.licenceHolder.licenceNS.central.root = tN.attributes.rootID;
				// overrule the common prefix that we were using
				_global.ORCHID.commandLine.prefix = undefined;
				
			// anything we didn't expect?
			} else {
				myTrace(tN.nodeName + ": " + tN.firstChild.nodeValue)
			}
		}
		
		// At the end we will get on with the normal stuff
		_global.ORCHID.programSettings.load();
	}
	thisDB.runQuery();
}
// v6.3.5 Avoid hardcoding real function names into animated intro
// So this function name (assumed on root, but shouldn't be) will be called
// at the end of the animation in the introduction.
controlNS.animatedIntroEnd = function() {
	myTrace("animatedIntroEnd");
	controlNS.checkAccess();
	// v6.3.6 Since it is theoretically possible to be sent here by the real animation
	// after the interval for goAnyway triggered, I should only let the work be done
	// once. It seems easiest to do that by removing this function after it has called
	// access.
	delete controlNS.animatedIntroEnd;
}
// v6.3.5 Before you go to read user, you should add in a check based on access control
controlNS.checkAccess = function() {
	
	//myTrace("checkAccess this=" + this.whoami); // back to controlNS!
	var internalCheckAccess = function() {
		// v6.3.4 You can't keep going until the program settings are complete
		// I am not sure if the dbConnection is still a valid check
		// v6.5.6.4 Also wait for literals to be loaded here. 
		myTrace("Testing to see if literals loaded=" + _global.ORCHID.literalModelObj.loaded);
		if (_global.ORCHID.dbInterface.dbConnection != undefined &&
			_global.ORCHID.programSettings.loginOption != undefined &&
			_global.ORCHID.literalModelObj.loaded) {
			//myTrace("checkAccess");
			//trace("control: getDB=" + _global.ORCHID.dbInterface.getDB);
			// in case you came from animated intro, no need to leave the failsafe running
			clearInterval(controlNS.intervals.animatedIntroInt);
			clearInterval(controlNS.intervals.checkAccessIntID);
				
			// v6.5.5.1 At this point I want to add confirmLicence before going on
			// v6.5.5.5 And I want to stop if this fails!
			if (!_global.ORCHID.root.controlNS.setConfirmLicence(_global.ORCHID.root.licenceholder.licenceNS.institution, undefined)) {
				myTrace("back to checkAccess but licence failed");
				return;
			};
			myTrace("back to checkAccess after confirmLicence was successful");
	
			// v6.3.5 After lots of checking you will either go on, or stop
			var goOn = function() {
				//v6.4.3 Pause in case SCORM is struggling to keep up
				// No - should be safe to do it a little later
				// so long as you pick up the name early on
				if (_global.ORCHID.commandLine.scorm) {
					controlNS.pauseForSCORM();
				} else {
					controlNS.readUser();
				}
			}
			var stopHere = function() {
				var errObj = {literal:"blockedAccess"};
				controlNS.sendError(errObj);
			}
			
			// v6.3.5 Do you need to check access?
			//myTrace("control access=" + _root.licenceholder.licenceNS.control.access);
			if (_global.ORCHID.root.licenceholder.licenceNS.control.access == 1) {
				// and if you do, is it encrypted?
				if (_global.ORCHID.root.licenceholder.licenceNS.control.encryption == 1) {
					// so that means I need to use the encryption key to decrypt entrypass
					var sender = new LoadVars();
					var loader = new LoadVars();
					loader.goOn = goOn;
					loader.stopHere = stopHere;
					loader.onLoad = function(success) {
						if (success) {
							//myTrace("decrypted value = " + this.result);
							if (this.result == _global.ORCHID.root.licenceholder.licenceNS.serialNumber) {
								//myTrace("matches serial number, so go on");
								this.goOn();
							} else {
								this.stopHere()
							}
						} else {
							//myTrace("fail from sendAndLoad");
							this.stopHere()
						}
					}
					sender.x = _global.ORCHID.commandLine.entryPass;
					sender.y = _global.ORCHID.root.licenceholder.licenceNS.control.decryptKey;
					//myTrace("decrypt " + sender.x + " using key=" + sender.y);
					sender.sendAndLoad("/function/decryptFromFlash.asp", loader, "POST");
				} else {
					// plain text checking
					if (_global.ORCHID.commandLine.entryPass == _global.ORCHID.root.licenceholder.licenceNS.serialNumber) {
						goOn();
					} else {
						stopHere();
					}
				}
			} else {
				// no access control
				goOn();
			}
			
		} else if (waitingRMCount > 20) {
			clearInterval(controlNS.intervals.animatedIntroInt);
			clearInterval(controlNS.intervals.checkAccessIntID);
			errObj = {literal:"noDBConnection"};
			controlNS.sendError(errObj);
			//myTrace("Sorry, the database cannot be read, code=" + errObj.literal);
			
		} else {
			// v6.3.4 You might want to put an error trap here as you might be in 
			// a loop waiting for the first db call (getRMSettings) if it has gone
			// wrong.
			myTrace("waiting for rm settings to load",0);
			waitingRMCount++;
		}
	}
	// 6.0.5.0 slightly different alert when db is loaded
	//if (_global.ORCHID.databaseModuleLoaded) {
	// v6.5.6.4 Can I also pause unless literals is loaded here?
	if (_global.ORCHID.dbInterface.dbConnection != undefined &&
		_global.ORCHID.programSettings.loginOption != undefined &&
		_global.ORCHID.literalModelObj.loaded) {
		myTrace("directly ready to checkAccess");
		internalCheckAccess();
	} else {
		myTrace("must wait before doing checkAccess/checkLiterals");
		controlNS.intervals.checkAccessIntID = setInterval(internalCheckAccess, 500);
		var waitingRMCount = 0;
	}
}
//v6.4.3 Pause to allow SCORM to finish getting all the info that it needs
controlNS.pauseForSCORM = function() {
	var internalPause = function() {
		// v6.4.3 You can't keep going until all SCORM variables are read
		if (waitingSCORMCount > 20) {
			myTrace("give up waiting for SCORM settings",0);
			clearInterval(controlNS.intervals.pauseSCORMIntID);
			controlNS.readUser();
		} else if (_global.ORCHID.root.scormHolder.scormNS.stillLoading &&
			_global.ORCHID.commandLine.scorm) {
			myTrace("waiting for SCORM settings to load",0);
			waitingSCORMCount++;
		} else {
			clearInterval(controlNS.intervals.pauseSCORMIntID);
			controlNS.readUser();
		}
	}
	if (_global.ORCHID.root.scormHolder.scormNS.stillLoading &&
		_global.ORCHID.commandLine.scorm) {
		myTrace("must wait for SCORM");
		controlNS.intervals.pauseSCORMIntID = setInterval(internalPause, 500);
		var waitingSCORMCount = 0;
	} else {
		myTrace("SCORM all loaded");
		controlNS.readUser();
	}
}
controlNS.readUser = function() {
	//myTrace("read user this=" + this.whoami);
	// v6.3.4 In case there was an animated intro that you were checking on
	// This function will have been called by the animated intro, but that might
	// have come more quickly than it should. So you need to know that you are
	// ready to run readUser and hover until you are if you aren't. If you see what I mean.
	// v6.3.5 The access check will now wait for rm settings, so no need to do that here
	myTrace("control: now get user information");
	// I need to check that the database module has been loaded before I can read user
	// No, not any more as checkAccess has done that
	var internalReadUser = function() {
		// this uses an object loaded in the login module for communication
		// 6.0.5.0 reduce the pointers to the user object
		//thisUser = new objectHolder.UserObject();
		_global.ORCHID.user = new objectHolder.UserObject();
		// 6.0.4.0, user object broadcast event to viewObj
		// instead of changing interface directly
		_global.ORCHID.user.addListener(_global.ORCHID.viewObj);
		// getting a user involves GUI and database reads and writes
		// v6.3.1 remove the progress bar and the download note
		incPercentage(100);
		bar.removeMovieClip();
		downloadNote._visible = false;
		progressCaption.removeTextField();
		_global.ORCHID.user.onLoad = function() {
			// 6.0.5.0 reduce the pointers to the user object
			//_global.ORCHID.user = this;
			//var mySession = _global.ORCHID.session;
			// Note: getting user and course are independent, so could be done together
			// once the user settings are loaded, get the course
			// 6.0.6.0 session count comes later
			//myTrace("welcome " + this.name + " from " + this.country + ", this is your " + this.sessionCount + " session.");
			myTrace("welcome " + this.name + " from " + this.country,1); // + ", this is your " + this.sessionCount + " session.");
			// v6.4.4 MGS. I now know the MGS - if there is one, so I can work out the course.xml
			// file that I commented out in Frame 2 init.
			// course.xml will be picked up from the MGS + Title
			// eg: /SAY1AC/TenseBuster.
			if (this.MGSName == undefined) {
				myTrace("no MGS from database so try commandLine");
				var thisMGSName = _global.ORCHID.commandLine.MGSName;
			} else {
				var thisMGSName = this.MGSName;
			}
			if (thisMGSName == undefined) {
				// No MGS set, so pick up course.xml from the content folder
				myTrace("you have no MGS");
				var thisContentPath = _global.ORCHID.paths.content;
				// v6.4.2.5 Also save in the MGS path so you can freely use it anytime
				_global.ORCHID.paths.MGS = _global.ORCHID.paths.content;
			} else {
				myTrace("your MGS name is " + thisMGSName);
				// Maybe this line should be part of user - maybe not.
				//var thisProductShortName = _global.ORCHID.root.licenceHolder.licenceNS.product.split(" ").join("");
				// do you need to massage this at all? Many variations of Author Plus?
				//if (thisProductShortName.indexOf("AuthorPlus")>=0) {
				//	thisProductShortName = "AuthorPlus";
				//}												 
				// MGS Root might come from the command line or location.ini, in which case it overrides
				// anything else. At present it cannot come from the database.
				// The default is to use the parent of the content folder.
				// And you can assume (gulp) that the content folder is based on the product name
				// /Content/AuthorPlus
				// v6.4.2.5 Assume that we will parse content path and put MGS root after /Content folder (or at the end if no /Content)
				// v6.4.2.6 MGSRoot passed from location or command line will be fully specified
				//if (_global.ORCHID.commandLine.MGSRoot == undefined) {
					var thisMGSRoot = _global.ORCHID.paths.content;
				//} else {
				//	var thisMGSRoot = _global.ORCHID.commandLine.MGSRoot;
				//}
				// v6.4.2.5 Can't search for Content with slash as it might be the other slash
				//var thisMGSParts = thisMGSRoot.split(_global.ORCHID.functions.addSlash("Content"));
				var thisMGSParts = thisMGSRoot.split("Content");
				// If we found /Content, slip /Spaces/[MGSName] in the middle.
				if (thisMGSParts.length>1){
					// Note that we might have found more than one Content - in which we are adding Spaces after the first one
					//_global.ORCHID.paths.MGS = thisMGSParts[0] + _global.ORCHID.functions.addSlash("Content") + _global.ORCHID.functions.addSlash("Spaces") + _global.ORCHID.functions.addSlash(thisMGSName) + thisMGSParts.slice(1).join(addSlash("Content"));
					// v6.4.2.6 We might have passed MGSRoot from the command line or read it from location.ini
					if (_global.ORCHID.commandLine.MGSRoot == undefined) {
						_global.ORCHID.paths.MGS = thisMGSParts[0] + _global.ORCHID.functions.addSlash("Content") + _global.ORCHID.functions.addSlash("Spaces") + thisMGSName + thisMGSParts.slice(1).join(addSlash("Content"));
					} else {
						_global.ORCHID.paths.MGS = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.MGSRoot) + thisMGSName + thisMGSParts.slice(1).join(addSlash("Content"));
					}
				// If we didn't, then add it to the end
				} else {
					// v6.4.2.6 We might have passed MGSRoot from the command line or read it from location.ini
					if (_global.ORCHID.commandLine.MGSRoot == undefined) {
						_global.ORCHID.paths.MGS = _global.ORCHID.functions.addSlash(thisMGSParts[0]) + _global.ORCHID.functions.addSlash("Spaces") + _global.ORCHID.functions.addSlash(thisMGSName);
					} else {
						_global.ORCHID.paths.MGS = _global.ORCHID.functions.addSlash(_global.ORCHID.commandLine.MGSRoot) + _global.ORCHID.functions.addSlash(thisMGSName);
					}
				}
				// MGS has been set, so this will be used to get course.xml
				// first save it in the paths object;
				//_global.ORCHID.paths.MGS = _global.ORCHID.functions.addSlash(thisMGSRoot) + _global.ORCHID.functions.addSlash(thisMGSName) + _global.ORCHID.functions.addSlash(thisProductShortName);
				myTrace("final MGS is " + _global.ORCHID.paths.MGS);
				var thisContentPath = _global.ORCHID.paths.MGS;
			}
			// v6.3.6 And what controls the courses?
			if (_global.ORCHID.commandLine.courseFile == undefined) {
				//_global.ORCHID.paths.courseFile = _global.ORCHID.paths.content + "course.xml";
				_global.ORCHID.paths.courseFile = thisContentPath + "course.xml";
			} else {
				// is the courseFile a file name or a full path?
				if ((_global.ORCHID.commandLine.courseFile.indexOf("/") < 0) && 
					(_global.ORCHID.commandLine.courseFile.indexOf("\\") < 0)) {
					_global.ORCHID.paths.courseFile = thisContentPath + _global.ORCHID.commandLine.courseFile;
				} else {
					if (_global.ORCHID.projector.name == "MDM") {
						_global.ORCHID.paths.courseFile = _global.ORCHID.paths.root + _global.ORCHID.commandLine.courseFile;
					} else {
						_global.ORCHID.paths.courseFile = _global.ORCHID.commandLine.courseFile;
					}
				}
				// was the filetype forgotten?
				if (_global.ORCHID.paths.courseFile.indexOf(".") <0) {
					_global.ORCHID.paths.courseFile += ".xml";
				}
			}
			myTrace("the course index is: " + _global.ORCHID.paths.courseFile,0);
			// v6.5.5.1 For measuring performance. No, not an interesting time.
			//_global.ORCHID.timeHolder.beginReadCourse = new Date().getTime();
			
			controlNS.readCourse();
		}
		_global.ORCHID.user.load();
	}
	// v6.3.5 If this is running from a v2 licence file AND the password was
	// sent in the command line, you need to decrypt it before later usage.
	// Is it safe to do this asynch call here at the beginning of readUser?
	// Will there be enough time before I
	// need to check the password elsewhere? NO it is not. So use this to call readUser.
	if (_global.ORCHID.root.licenceholder.licenceNS.control.encryption == 1 &&
		_global.ORCHID.commandLine.password != undefined) {
		//myTrace("decrypt password");
		// so that means I need to use the encryption key to decrypt the password
		var sender = new LoadVars();
		var loader = new LoadVars();
		loader.onLoad = function(success) {
			if (success) {
				//myTrace("decrypted value = " + this.result);
				// overwrite the encrypted password with the decryption
				//myTrace("setting password to " + this.result);
				_global.ORCHID.commandLine.password = this.result;
			}
			// if you have not successfully decrypted the password, they will simply
			// have to type it anyway.
			//v6.4.2 rootless
			///readUser();
			internalReadUser();
		}
		sender.x = _global.ORCHID.commandLine.password;
		sender.y = _global.ORCHID.root.licenceholder.licenceNS.control.decryptKey;
		myTrace("decrypt " + sender.x + " using key=" + sender.y);
		sender.sendAndLoad("/function/decryptFromFlash.asp", loader, "POST");
	} else {
		internalReadUser();
	}
}

controlNS.readCourse = function() {
	myTrace("control: now get scaffold information");
	// I need to check that the database module has been loaded before I can read the course
	var internalReadCourse = function() {
		// v6.5.5.6 It seems that now would be a good time to call startSession for title based sessions
		// I don't think you really need to wait for anything at this point.
		// this will callback to controlNS.setProgress to keep going
		//_global.ORCHID.session.startSession();
		
		// 6.0.5.0 slightly different alert when db is loaded
		//if (_global.ORCHID.databaseModuleLoaded) {
		if (_global.ORCHID.dbInterface.dbConnection != undefined) {
			clearInterval(controlNS.intervals.courseIntID);
				// 6.0.2.0 remove connections
				//sender = new LocalConnection();
				//sender.send("courseModule", "createCourse");
				//delete sender;
				// 6.0.4.0 use view object to display course menu
				//_root.scaffoldHolder.scaffoldNS.createCourse();
				_global.ORCHID.viewObj.displayScreen("CourseListScreen");
			// this uses an object loaded in the scaffold module for communication
			//thisCourse = new objectHolder.CourseObject();
			//thisCourse.oops = "Adrian";
			//thisCourse.onLoadScaffold = function() {
			//	// once the scaffold is loaded, get the progress
			//	myTrace("control: now get progress information");
			//	this.onLoadProgress = function() {
			//		// once the progress has been loaded save the object globally
			//		_global.ORCHID.course = this;
			//		// and go on to display the menu
			//		_$displayButtons();
			//		_$displayMenu();
			//	}
			//	this.loadProgress();
			//}
			//thisCourse.loadScaffold();
			// 6.0.2.0 try to do this here
			//_$displayButtons();
		} else {
			myTrace("waiting for dbConnection",1);
		}
	}
	// 6.0.5.0 slightly different alert when db is loaded
	//if (_global.ORCHID.databaseModuleLoaded) {
	if (_global.ORCHID.dbInterface.dbConnection != undefined) {
		internalReadCourse();
	} else {
		controlNS.intervals.courseIntID = setInterval(internalReadCourse, 1000);
	}
}
// 6.0.6.0 Add extra call to insert a session record once the course is 
// chosen
controlNS.setCourse = function(menuRootItems) {
	// 6.0.6.0 I am not sure what menuRootItems contains, so just leave it alone!
	_global.ORCHID.menuRootItems = menuRootItems;
	// 6.0.6.0 First write a session record for the chosen course
	//myTrace("your chosen course is " + _global.ORCHID.session.courseName);
	// v6.5.5.6 Remove this call and put it after user login for title based sessions
	// this.setProgress();
	_global.ORCHID.session.startSession();
	// this will callback to controlNS.setProgress to keep going
}
// 6.0.6.0 Once the session record is written, you can get progress for this course
controlNS.setProgress = function() {
	var courseModule = _global.ORCHID.course;
	courseModule.onLoadProgress = function() {
		// once the progress has been loaded save the object globally
		
		// v6.4.2.8 At this point I want to do a quick race through the scaffold summarising
		// the everyone information at the course/unit/xxx level. 
		myTrace("summariseEveryoneInformation");
		//_global.ORCHID.course.scaffold.summariseEveryoneInformation();
		_global.ORCHID.course.scaffold.summariseInformation(2);
		
		// and go on to display the menu
		//myTrace("course.onLoadProgress this=" + this.whoami);
		controlNS.displayButtons();
		// 6.0.2.0 do this after setting the buttons in case the
		// stateInit calls clash
		//_$displayMenu();
	}
	courseModule.loadProgress();
}

controlNS.displayButtons = function() {
	//myTrace("control: now display buttons");
	// if you put up a warning on the control screen, remove it now
	_global.ORCHID.root.warning.removeTextField();
	
	// I need to check that the buttons module has been loaded before I can display it
	var internalDisplayButtons = function() {
		// v6.4.2 buttons is loaded before anything else happens
		//if (_global.ORCHID.buttonsModuleLoaded && _global.ORCHID.jukeboxModuleLoaded) {
		// v6.4.2 All modules will be loaded for sure now
		//if (_global.ORCHID.isModuleLoaded("jukeboxModule")) {
		// v6.5.6.4 But can I check here if literals is loaded?
		// No, not here as this doesn't seem to be called anymore!
			clearInterval(controlNS.intervals.buttonsIntID);
			// this uses local connection to ask the menu to display
			// 6.0.2.0 remove connections
			//sender = new LocalConnection();
			//sender.send("buttonsModule", "setState", "base");
			//delete sender;
			// 6.0.2.0 need to wait for stateInit("base") to finish before displaying menu
			_global.ORCHID.root.buttonsHolder.buttonsNS.setStateCallback = function() {
				//myTrace("finally can do menu from this=" + this.whoami);
				controlNS.displayMenu();
				//trace("this=" + this.moduleName);
				delete this.setStateCallback;
			}
			// 6.0.4.0, AM: no need to setState, just display the menu directly
			//_root.buttonsHolder.buttonsNS.setState("base");
			//myTrace("call displayMenu");
			controlNS.displayMenu();
		//} else {
		//	myTrace("waiting for jukebox to load",2);
		//}
	}
	// v6.4.2 buttons is loaded before anything else happens
	//if (_global.ORCHID.buttonsModuleLoaded && _global.ORCHID.jukeboxModuleLoaded) {
	// v6.4.2 All modules will be loaded for sure now
	//if (_global.ORCHID.isModuleLoaded("jukeboxModule")) {
	//if (_global.ORCHID.buttonsModuleLoaded) {
	// v6.5.6.4 Use this to wait for literals to be loaded please
		internalDisplayButtons();
	//} else {
	//	controlNS.intervals.buttonsIntID = setInterval(internalDisplayButtons, 1000);
	//}
}

controlNS.displayMenu = function() {
	//myTrace("control: now display menu information");
	//myTrace("at this point, projector=" + _global.ORCHID.projector.name + " and ocx=" + _global.ORCHID.projector.ocxLoaded);
	// I need to check that the menu module has been loaded before I can display it
	// v6.4.2 If running SCORM then getting variables might still be going on, so wait
	var internalDisplayMenu = function() {
		// v6.3.6 Merge menu into main
		// v6.4.2 Don't start anything until main is loaded
		//if (_global.ORCHID.mainModuleLoaded) {
		// v6.4.2 Don't start anything until SCORM loading is complete
		if (_global.ORCHID.commandLine.scorm && scormNS.stillLoading) {
			myTrace("waiting for scorm settings to load",1);
		} else {
			clearInterval(controlNS.intervals.menuIntID);
			
			// v6.3.5 Now would be a good first time to check up on lc recording
			// so that it is ready for when the exercise screen first displays
			//v6.4.3 But you don't need to do this if running in ZINC
			// v6.5.3 I don't see why we wait for the menu before doing this - why not as early as possible?
			// v6.5.1 Yiu - now need to always check as ocx will be phased out
			//if (_global.ORCHID.projector.name != "MDM") {
			//	_global.ORCHID.root.controlNS.testClarityRecorder();
			//}
			
			// clear the introduction graphics
			//myTrace("Clear intro from " + _root.introHolder);
			//_root.introHolder.removeMovieClip();
			//sender.send("introModule", "clearIntro", "_root.introHolder");
			// call up the menu
			//sender.send("menuModule", "displayMainMenu");
			//var Items = _global.ORCHID.course.scaffold.getItemsByID(_global.ORCHID.course.scaffold.id);
			//var menuItems = _global.ORCHID.menuXML.getMenuItemByID(_global.ORCHID.course.scaffold.id);
			//trace("got main menu items (" + menuItems.length + ")");
			//_root.menuHolder.addMenuEventListener(controlNS);
			//_root.menuHolder.displayMainMenu(menuItems, "menu.txt", progressItems);
			// also set up the buttons for the menu
			// 6.0.2.0 remove connections
			//sender.send("buttonsModule", "setState", "menu");
			//delete sender;
			// 6.0.4.0, AM: use view object to control interface
			//_root.buttonsHolder.buttonsNS.setState("menu");
			//_global.ORCHID.viewObj.clearAllScreens();
			
			// v6.5.5.2 End the performance measuring
			myTrace("timeHolder.log.endOfFullyLoadedScores");
			_global.ORCHID.timeHolder.unitMenuLoaded = new Date().getTime();
			
			// v6.5.5.1 For measuring performance - now write out the log as the most critical stuff has been done already
			// 600 is the log code for Orchid performance. Need a constants file somewhere to share with all apps.
			// v6.5.5.2 I only want to write this out once, yet this function is called each time I choose a course.
			// So initialise one of the key variables here so I don't call it again.
			if (_global.ORCHID.timeHolder.programStart>0 && _global.ORCHID.programSettings.databaseVersion>1) {
				_global.ORCHID.root.mainHolder.logNS.sendLog(_global.ORCHID.timeHolder.toString(), 600);
				_global.ORCHID.timeHolder.programStart = -1;
			}
			
			// v6.3.3 This might be the right point to decide if the menu should indeed be
			// shown, or whether we actually know the first exercise to display
			if (_global.ORCHID.commandLine.scorm) {
				myTrace("scorm, so see what exercise to start with");
				_global.ORCHID.root.scormHolder.scormNS.getStartingID();
			// v6.3.5 Not only SCORM can send in starting points - APL will as well
			//} else if (_global.ORCHID.commandLine.startingPoint != undefined) {
			} else if (_global.ORCHID.commandLine.startingPoint.length>0) {
				myTrace("startingPoint=" + _global.ORCHID.commandLine.startingPoint,1);
				//v6.4.2 rootless
				//controlNS.startingDirect();
				controlNS.startingDirect();
			} else {
				_global.ORCHID.viewObj.displayScreen("MenuScreen");
			}
		}
	}
	// v6.3.6 Merge menu into main
	// v6.4.2 Don't start anything until main is loaded
	//if (_global.ORCHID.mainModuleLoaded) {
	if (_global.ORCHID.commandLine.scorm && scormNS.stillLoading) {
		controlNS.intervals.menuIntID = setInterval(internalDisplayMenu, 500);
	} else {
		internalDisplayMenu();
	}
}

controlNS.createExercise = function (exerciseIDs, randomMode) {
	myTrace("control: now read the exercise " + exerciseIDs.caption);
	// given a range of exercise IDs and a creation mode, build the exercise
	// 6.0.2.0 remove connections
	//sender = new LocalConnection();
	//sender.send("creationModule", "createExercise", exerciseIDs, randomMode);
	//delete sender;
	// v6.3.3 Since this call has an incorrect number of parameters for random mode
	// I assume that this call is only ever made for single exercises.
	// v6.3.6 Merge creation into main
	_global.ORCHID.root.mainHolder.creationNS.createExercise(exerciseIDs, randomMode);
}
controlNS.directExercise = function (thisID) {
	myTrace("direct start exercise:" + thisID);
	var item = _global.ORCHID.course.scaffold.getObjectByID(thisID);
	//myTrace("found item, action=" + item.action);
	if (item != null) {
		_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
		_global.ORCHID.root.mainHolder.creationNS.createExercise(item);
	}
}

// this function might not be the only one to display exercises
controlNS.displayExercise = function (currentExercise) {
	// 6.0.2.0 remove connections
	//myTrace("control: now display the exercise");
	//sender = new LocalConnection();
	//sender.send("menuModule", "clearMenu");
	//delete sender;
	// v6.3.6 Merge menu to main
	_global.ORCHID.root.mainHolder.menuNS.clearMenu();
	// display the current exercise
	// 6.0.2.0 remove connections
	//sender = new LocalConnection();
	//sender.send("exerciseModule", "displayExercise", currentExercise);
	//delete sender;
	//v6.4.1.4 This doesn't exist - ???
	//_root.exerciseModule.exerciseNS.displayExercise(currentExercise);
	// should be.. but perhaps it is done else where now?
	//_root.mainHolder.exerciseNS.displayExercise(currentExercise);
	//myTrace("comment out displayExercise");
}
//AR I don't think navigate is used any more, must be done somewhere else
//controller.getNextExercise = function (exerciseID) {
//// 	6.0.2.0 remove connections
////	sender = new LocalConnection();
////	sender.send("navigateModule", "getNextExercise", exerciseID);
////	delete sender;
//	_root.navigateModule.navigateNS.getNextExercise(exerciseID);
//}
controlNS.selectUnits = function () {
// 	6.0.2.0 remove connections
	//sender = new LocalConnection();
	//sender.send("menuModule", "selectUnits");
	//delete sender;
	// v6.3.6 Merge menu into main
	_global.ORCHID.root.mainModule.menuNS.selectUnits();
}
//AR I don't think navigate is used any more, must be done somewhere else
//controller.getValidExerciseIDs = function (unitIDs) {
//// 	6.0.2.0 remove connections
////	sender = new LocalConnection();
////	sender.send("navigateModule", "getValidExerciseIDs", unitIDs);
////	delete sender;
//	_root.menuModule.menuNS.selectUnits();
//}
controlNS.displayProgress = function () {
// 	6.0.2.0 remove connections
	//myTrace("control: now display the progress so far");
	//sender = new LocalConnection();
	//sender.send("progressModule", "displayProgress");
	//delete sender;
	_global.ORCHID.root.progressModule.progressNS.displayProgress();
}
//v6.4.2 This is called from the subMenu component in buttons.
controlNS.onMenuPress = function(id, action, itemObj) {
	//myTrace("onMenuPress " + id + " " + action);
	if (action != "" && action != null) {
		//v6.3.4 Can you pass a proper scaffold object from the menu?
		if (itemObj == undefined) {
			itemObj = _global.ORCHID.course.scaffold.getObjectByID(id);
		}
		//trace("got this ex as id=" + itemObj.id);
		// v6.2 At this point, can I also quickly get the previous and next exercises?
		//trace("old next=" + _global.ORCHID.session.nextItem.id + " old previous=" + _global.ORCHID.session.previousItem.id);
		_global.ORCHID.session.nextItem = _global.ORCHID.course.scaffold.getNextItemID(itemObj.ID);
		_global.ORCHID.session.previousItem = _global.ORCHID.course.scaffold.getPreviousItemID(itemObj.ID);
		//trace("new next=" + _global.ORCHID.session.nextItem.id + " new previous=" + _global.ORCHID.session.previousItem.id);
		//trace("got next id=" + _global.ORCHID.session.nextItem.id);
		this.createExercise(itemObj);
		// This screen stuff moved into creation.createExercise so that other forms
		// of exercise creation (specifically tests) can do it as well
		// // this is where you should remove the menu to get a clean switch
		// v6.5.3 If you are generating a test direct from the menu, it can take a while to get to the end of processExercise
		// which is when you normally clear the menu and display the exercise. So experiment with clearing here so that
		// you can just leave a progress bar...
		_global.ORCHID.root.mainHolder.menuNS.clearMenu();
		//_root.menuHolder.clearMenu();
		//_global.ORCHID.viewObj.clearAllScreens();
		//_global.ORCHID.viewObj.displayScreen("ExerciseScreen");
	} else {
		var items = _global.ORCHID.menuXML.getMenuItemByID(id);
		//myTrace("submenu with items");
		var progressItems = _global.ORCHID.course.scaffold.getItemsByID(id);
		// v6.2 are you telling me that we read the submenu text settings file EVERY time?!
		// well, no the function will not do it twice - but what a way - PHEW, it's a stinker.
		// v6.3.6 Merge menu to main
		_global.ORCHID.root.mainHolder.displaySubMenu(items, _global.ORCHID.paths.root + _global.ORCHID.paths.subCourse+"subMenu.txt", progressItems);
	}
}
//v6.3.6 Allow possibility that you are exiting with an error
// At present, this is just passed to SCORM to let it avoid data saving
// It will just to commit etc.
controlNS.startExit = function(withError) {
	
	//v6.5.5.2 If you exit from here without writing the performance log (you didn't choose a course) - do it here
	if (_global.ORCHID.timeHolder.programStart>0 && _global.ORCHID.programSettings.databaseVersion>1) {
		_global.ORCHID.root.mainHolder.logNS.sendLog(_global.ORCHID.timeHolder.toString(), 600);
		_global.ORCHID.timeHolder.programStart = -1;
	}
	
	// v6.3.5 You will have already done this for a regular exit, but not for
	// unexpected exits, so it won't hurt to do it again.
	_global.ORCHID.viewObj.hideAllScreens();
	// v6.2 - have exit functions on a separate screen
	// v6.2.1 But this means that it is difficult to use loaded scripts, so stay here
	// to do anything other than run the credits and close the screen
	// Actually, just do them in view.as before you call this function
	// v6.3 This does mean that projector exitHandler is only doing visual stuff
	// as all it does is simply gotoAndRun a frame name. Never mind.
	// v6.3.1 To fix the bug whereby FSP gives a Windows crash after exit, you need
	// to remove the ocx in this frame, not in the next one. I guess it is because
	// otherwise the swf is unloaded before the ocx finishes unloading and you get
	// the memory abuse. Of course you cannot catch the Windows exit click here, but
	// for some reason this does not crash the projector anyway.
	if (_global.ORCHID.projector.ocxLoaded) {
		//fscommand("flashstudio.traperrors");
		// Is it possible that the loadMovie command that comes next will stop the
		// following working as it won't have finished yet? 
		myTrace("remove ocx as it is loaded id=" + _global.ORCHID.projector.variables.ocxID);
		// v6.3.5 FSP to ZINC
		//_global.ORCHID.projector.variables.id = "0";
		// v6.5.5.9 Remove all references to the old ocx
		//mdm.activex_close(_global.ORCHID.projector.variables.ocxID); 
		_global.ORCHID.projector.ocxLoaded = false;
	}
	
	//v6.4.2 Close preview's local connection
	this.receiveConn.close();
	this.receiveConn = undefined;
	//
	if (_global.ORCHID.commandLine.scorm) {
		myTrace("call to SCORM exit (error=" + withError + ")");
		_global.ORCHID.root.SCORMHolder.scormNS.exit(withError);
	} else {
		// v6.4.2.4 HELP. Within MDM I no longer have creditsHolder defined!
		// Solved by correct loading.
		myTrace("go to exit frame");
		// But is it possible that you have not yet set _global.ORCHID.root to the _root.
		// No - I get caught here, but _global.ORCHID.root is set to _level0.
		// Don't see why I can't go to the frame - but I don't.
		//myTrace("_global.ORCHID.root=" + _global.ORCHID.root);
		if (_global.ORCHID.root.creditsHolder == undefined) {
			// it seems that network version can get stuck and never get to credits
			mdm.exit();
		} else {
			if (_global.ORCHID.root == undefined) {
				_level0.gotoAndStop("exit");
			} else {
				_global.ORCHID.root.gotoAndStop("exit");
			}
		}
	}
}
// v6.3.5 FSP to ZINC
// Now that the proper exit function is defined, update the Zinc exit strategy
// But is this overwriting the first one properly? Yes it is.
_global.ORCHID.root.onAppExit = function() { 
	// v6.4.2.4 Add in an impatience clause!
	if (_global.ORCHID.getMeOut == undefined) {
		_global.ORCHID.getMeOut=0;
	} else if (_global.ORCHID.getMeOut>1) {
		myTrace("impatient");
		mdm.exit();
	}
	//_global.ORCHID.viewObj.hideAllScreens();
	// It would be better to do session.exit, but only if you have started the session!
	if (_global.ORCHID.session.sessionID > 0) {
		myTrace("new onAppExit, do session exit");		
		_global.ORCHID.session.exit()
	} else {
		myTrace("new onAppExit, do quick exit");
		_global.ORCHID.root.controlNS.startExit();
	}
	_global.ORCHID.getMeOut++;
} 

// this function is a callback from the database clean up triggered by .exit
controlNS.userStopped = function () {
	// run the closing animation/credits/weblink
	// (it would be good if this had been pre-loaded during a quiet moment earlier)
	// and remember that this is loading into the top level, so it will remove
	// everything loaded (including the myTrace box)
	//_root.loadMovie(_global.ORCHID.paths.movie + "byebye.swf");
	// there is no other real clean up to do!
}
// used for timing exercises
_global.ORCHID.startTime = new Date().getTime();
/*
// v6.5.5.9 This is the culprit for trying to launch the old ClarityRecorder
// v6.5.5.4 Phase this Yiu code out
_global.ORCHID.recorderPath	= new String();
controlNS.getRecorderPath = function() {
	var strResult:String;
	var nTarIndex:Number;
	
	strResult	= _global.ORCHID.paths.root;

	strResult 	= strResult.substr(0, strResult.length - 1);
	nTarIndex	= strResult.lastIndexOf("\\");
	
	strResult 	= strResult.substring(0, nTarIndex + 1) + "Recorder\\ClarityRecorder.exe";
	return strResult;
}

// v6.5.5.4 Phase this Yiu code out
controlNS.tryToOpenRecorderWithZinc	= function() {
	if (mdm)
	{
		var strTargetPath:String;
		
		strTargetPath					= _global.ORCHID.getRecorderPath();
		_global.ORCHID.recorderPath		= strTargetPath;
		
		mdm.fileexists(strTargetPath, controlNS.mdmFileExistsCallback);
	}
}

// v6.5.5.4 Phase this Yiu code out
controlNS.mdmFileExistsCallback	= function(result)
{	
	if(result	== "true" || result == true)
		mdm.exec(_global.ORCHID.recorderPath);
}

// v6.5.5.4 Phase this Yiu code out
_global.ORCHID.getRecorderPath = controlNS.getRecorderPath;
_global.ORCHID.tryToOpenRecorderWithZinc	= controlNS.tryToOpenRecorderWithZinc;
*/

// setup the local connection for the Clarity Recorder
// v6.3.4 If you are in a browser, you might be able to use the ClarityRecorder 
// through localConnection. 
//controlNS.testClarityRecorder = function(recorderController) {
controlNS.testClarityRecorder = function() {
	myTrace("testing clarityRecorder=" + recorderController);
	// v6.5.5.3 If you have already loaded the ocx, then just use that
	if (_global.ORCHID.projector.ocxLoaded) {
	} else {
		if (_global.ORCHID.recorderConn == undefined) {
			_global.ORCHID.recorderConn = new LocalConnection();
			// create a method for catching a later broadcast that the sound has 
			// finished playing - and pass the info to the recorder controller
			// NOTE: This scenario doesn't work in IE, some strange scope changing stuff happens
			// so for now I will simply time the record-stop length to get my play time.
			//_global.ORCHID.recorderConn.recordController = recorderController;
			//myTrace("saved as " + _global.ORCHID.recorderConn.recordController);
			//_global.ORCHID.recorderConn.stoppedPlaying = function() {
			//	myTrace("received stoppedPlaying event"); //, send msg to " + _global.ORCHID.recorderConn.recordController);
			//	_global.ORCHID.recorderConn.recordController.onPlayFinished();		
			//}
			// a method that will listen for the Clarity Recorder loaded event - this happens if the recorder starts whilst Orchid is running.
			_global.ORCHID.recorderConn.onLoad = function() {
				myTrace("1. Clarity Recorder through localConnection");
				_global.ORCHID.projector.lcLoaded 	= true;
				_global.ORCHID.projector.ocxLoaded	= false;	// v6.5.1 Yiu set ocxLoaded to false while lcLoaded is true
				// v6.5.5.8 Take this out as it is done in setVersion
				//_global.ORCHID.root.buttonsHolder.ExerciseScreen.resetRecorderBtns();
				// I don't need my general status checking anymore
				delete _global.ORCHID.recorderConn.onStatus;
				// Ask for the version in case that has an impact on the interface
				_global.ORCHID.recorderConn.send("_clarityRecorder", "getVersion");

				// I am struggling to set this here. It appears not to work for IE!
				// Or rather it seems to work here in that this trace is fine, but the _global
				// value is simply not set elsewhere!
				//myTrace("received onLoad event so set lcLoaded=" + _global.ORCHID.projector.lcLoaded);
				
				// v6.5.5.9 You might have started the recorder through an MDM badger, in which case lets kill that window
				// Of course, if they choose the browser option at the bottom of the badger, when Recorder starts, this kicks in a kills the window!
				// Somehow we have to detect the difference between them installing AIR recorder from badger and them running the swf.
				//myTrace("are you from mdm badger? " + _global.ORCHID.projector.name + ", " + _global.ORCHID.projector.badgerStarted);
				if (_global.ORCHID.projector.name == "MDM" && _global.ORCHID.projector.badgerStarted) {
					myTrace("from mdm badger, so close window");
					_global.ORCHID.projector.badgerStarted = false;
					// TODO Probably need mdm exception handling round here in case the user has already shut the window.
					mdm.exec_adv_close();
				}
			}
			
			// v6.5.1 Yiu receiving recorder exit message
			_global.ORCHID.recorderConn.recorderClosed = function() {
				myTrace("recorder just told us it was closing");
				_global.ORCHID.projector.lcLoaded = false;
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.resetRecorderBtns();
				// so why send a message back to the recorder? Is it waiting?
				//_global.ORCHID.recorderConn.send("_clarityRecorder", "cmdRecorderAlreadyClosed");
			}
			
			// v6.5.1 Yiu to distingish between recorder version 1 & 2
			//_global.ORCHID.recorderConn.recorderV2 = function() {
			_global.ORCHID.recorderConn.setVersion = function(versionNumber) {
				myTrace("Clarity Recorder is v" + versionNumber);
				if (parseInt(versionNumber)>2) {
					myTrace("so set isRecorderV2 to true");
					_global.ORCHID.projector.isRecorderV2 = true;
				}
				// v6.5.5.5 Add this in because it might change the interface
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.resetRecorderBtns();

			}
			// v6.5.5.7 If we have asked nicely, then the recorder will tell us if it is open for comparison
			// if it is, then lets trigger the compareWaveforms button
			_global.ORCHID.recorderConn.openForCompare = function() {
				myTrace("Recorder tells me it is open for compare, so lets do it");
				_global.ORCHID.viewObj.cmdCompareWaveforms();
			}
			// v6.5.5.7 React to a notification that playing is complete
			_global.ORCHID.recorderConn.playingComplete = function() {
				myTrace("Recorder tells me it has finished playing");
				_global.ORCHID.viewObj.onPlayFinished();
			}
			// v6.5.5.7 React to a notification that playing is complete
			_global.ORCHID.recorderConn.recordingComplete = function() {
				myTrace("Recorder tells me it has finished recording");
				_global.ORCHID.viewObj.onRecordFinished();
			}
			
			// v6.3.6 Also setup events that can be triggered by the recorder
			// starting and stopping midstream
			_global.ORCHID.recorderConn.onStop = function(infoObject) {
				if (infoObject.level == "status") {
					
					_global.ORCHID.projector.lcLoaded = false;
					if (xx) { // are you currently in an exercise?
						// turn off the recorder (means switch back to instruction button)
					} 
				}
			}
			_global.ORCHID.recorderConn.onStart = function(infoObject) {
				if (infoObject.level == "status") {
					_global.ORCHID.projector.lcLoaded 	= true;
					_global.ORCHID.projector.ocxLoaded	= false;	// v6.5.1 Yiu set ocxLoaded to false while lcLoaded is true
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.resetRecorderBtns();
					if (xx) { // are you currently in an exercise?
						// turn on the recorder (means switch back to instruction button)
					} 
				}
			}
			// set up permissions
			_global.ORCHID.recorderConn.allowDomain = function(domain) {
				//myTrace("message from " + domain);
				return true;
			}
			// set up a listening connection with a particular channel name
			_global.ORCHID.recorderConn.connect("_clarityAPO");
			myTrace("1. test the recorder lc connection");
			// set the first time expectation
			//myTrace("first time test, so set lcLoaded=false");
			//_global.ORCHID.projector.lcLoaded = false;
		} else {
			// you might have swapped recorder controllers
			//_global.ORCHID.recorderConn.recordController = recorderController;
		}
		// v6.5.5.8 This is fine, except that it is quite possible to close the Recorder without triggering an exit method
		// So then Orchid will think that the Recorder is still running, yet it isn't. So this function should always do a full test.
		// But I want to do button resetting, so maybe have a simpler function
		if (_global.ORCHID.projector.lcLoaded == false) {
			var testConnection = function() {
				myTrace("controlFrame3.testConnection");
				// v6.5.5.3 There is no such method in the new recorder. Mind you that wouldn't matter as onStatus doesn't care.
				_global.ORCHID.recorderConn.send("_clarityRecorder", "getActive");
				// So try asking for the version. We can do this later.
				//_global.ORCHID.recorderConn.send("_clarityRecorder", "getVersion");
				// The following function is triggered by something happening in response to our last send. I think.
				// "The onStatus handler for Local Connections is invoked upon the sending Local Connection after a send command."
				// 'status' means that the command was sent (but not necessarily successful run as a method)
				// 'error' means the connection is not working
				_global.ORCHID.recorderConn.onStatus = function(infoObject) {
					if (infoObject.level == "status") {
						myTrace("2. Clarity Recorder through localConnection", 1);
						_global.ORCHID.projector.lcLoaded = true;
						_global.ORCHID.projector.ocxLoaded = false;	// v6.5.1 Yiu set ocxLoaded to false while lcLoaded is true
						// See the version in case that has an impact on the interface
						_global.ORCHID.recorderConn.send("_clarityRecorder", "getVersion");
						//_global.ORCHID.root.buttonsHolder.ExerciseScreen.resetRecorderBtns();
						delete _global.ORCHID.recorderConn.onStatus;
					} else {
						// if the connection could not be made leave it running in case
						// the user manages to get it going.
						//delete _global.ORCHID.recorderConn;
						// Since you don't think you can run the recorder, show the
						// setup button (if you were sent a control)
						// v6.5.5.9 Remove this old Yiu code
						//_global.ORCHID.tryToOpenRecorderWithZinc();
						
						/* v6.5.1 Yiu disabled it, because the recorder may not open that fast right after tryToOpenRecorderWithZinc
						if (_global.ORCHID.projector.lcLoaded)
						{
							myTrace("can use ClarityRecorder",1);
							delete _global.ORCHID.recorderConn.onStatus;
						} else {
							myTrace("cannot use ClarityRecorder");
						}
						 
						 */
						//recorderController.setup_pb.setEnabled(true);
						//recorderController.record_pb.setEnabled(false);
					}
				}
			}
			myTrace("2. test the recorder lc connection");
			testConnection();
		}
	}
}
controlNS.retestClarityRecorder = function() {
	myTrace("re-testing clarityRecorder");
	// v6.5.5.3 If you have already loaded the ocx, then just use that
	if (_global.ORCHID.projector.ocxLoaded) {
	// What I care about is that the recorder was loaded and has slunk away. So only check if you think it should be working.
	} else if (_global.ORCHID.projector.lcLoaded) {
		// v6.5.5.3 There is no such method in the new recorder. Mind you that wouldn't matter as onStatus doesn't care.
		_global.ORCHID.recorderConn.onStatus = function(infoObject) {
			myTrace("3. Clarity Recorder through localConnection, status=" + infoObject.level, 1);
			if (infoObject.level == "status") {
				_global.ORCHID.projector.lcLoaded = true;
			} else {
				_global.ORCHID.projector.lcLoaded = false;
				// Because it might have taken several seconds for an error to come back, we do need to redo this here
				// as the screen is probably otherwise displayed already.
				_global.ORCHID.root.buttonsHolder.ExerciseScreen.resetRecorderBtns();
			}
			delete _global.ORCHID.recorderConn.onStatus;
			// I don't think you should do this here as exercise display always does it
		}
		_global.ORCHID.recorderConn.send("_clarityRecorder", "getActive");
	}
}
// v6.5.3 I don't see why we wait for the menu before doing this - why not as early as possible?
// this was in the displayInternalMenu function - try it here.
_global.ORCHID.root.controlNS.testClarityRecorder();

// 6.0.2.0 AR move connect until after methods have been defined
//controller.connect("controlConnection");

// v6.3.5 A function for direct ways to start APO
controlNS.startingDirect = function() {
	
	myTrace("startingDirect from " + _global.ORCHID.commandLine.startingPoint,0);
	// first ask LMS for the starting point (expecting "unit:u1" or "ex:e103")
	//v6.4.2 or now, generic id:1123091230
	//v6.5.6 But RM is all old-fashioned about unit ids. So you might still need unit:1 as opposed to id:1010101010
	var startInfo = _global.ORCHID.commandLine.startingPoint.split(":");
	var startingType = startInfo[0];
	var startingID = startInfo[1];
	
	// if scorm doesn't want to start at a particular place
	if (startingID == undefined || startingType == "menu") {
		// so we are just going to let APO display the menu in the normal way
		//myTrace("LMS says menu please");
		_global.ORCHID.viewObj.displayScreen("MenuScreen");
		
	// otherwise, what does scorm want us to do?
	} else {
		// figure out if we need to work out the first exercise in the unit
		//v6.4.2 See comment below about unit and id
		//if (startingType == "unit") {
		if (startingType == "unit" || startingType == "id") {
			//myTrace("LMS says unit=" + startingID,0);
			// v6.3.6 When Doris changes to ClarityUniqueID, you will need a new
			// way of getting the item based on the unit number rather than the id
			//var itemList = _global.ORCHID.course.scaffold.getItemsByUnit(startingID);
			// v6.5.6 If we are starting with unit and it is a small number, then we are using the old style unit rather than real ID
			// 1000 is arbitrary, I don't suppose there are any units more than about 25.
			if (startingID<1000) {
				var unitItem = _global.ORCHID.course.scaffold.getObjectByUnitID(startingID);
				myTrace("starting from old unit number " + startingID + " which has a real ID of " + unitItem.id);
				startingID = unitItem.id;
			}
			var itemList = _global.ORCHID.course.scaffold.getItemsByID(startingID);
			var thisScaffoldItem = itemList[0];
		// if it is an exercise, just use that
		} else if (startingType == "ex") {
			//myTrace("LMS says exercise=" + startingID);
			var thisScaffoldItem = _global.ORCHID.course.scaffold.getObjectByID(startingID);
		}
		// once you have the exercise ID, send it to the normal exercise creation point
		//myTrace("so that is exercise " + thisScaffoldItem.id);
		// v6.3.4 Any starting point that doesn't match a proper scaffold id
		// will come back as null. So in that case start from the menu.
		if (thisScaffoldItem == null) {
			myTrace("not a valid starting point",0);
			_global.ORCHID.viewObj.displayScreen("MenuScreen");
		} else {
			// v6.5.6.4 For any unit that starts direct, we don't want to see the Menu button (SCORM does this already)
			// And for any exercise that starts direct we don't want forward/back buttons and moveExercise should also quit.
			// Buttons handled in screen.as. MoveExercise is in view.as
			_global.ORCHID.root.controlNS.createExercise(thisScaffoldItem);		
		}
	}	
}

/*
// OLD CODE from attach layer in frame 3
//
var movieLocation = _global.ORCHID.paths.movie;

//count the number of modules loaded
//_global.ORCHID.TotalNumberOfModules = 13;
_global.ORCHID.NumberOfModules = 0; // these modules will be tested for individually if necessary
_global.ORCHID.NumberOfModulesLoaded = 0;
// it would be nice to know what has NOT loaded
// v6.4.2 consolidate use of this array for names and load status
_global.ORCHID.moduleNames = new Array();

// v6.3.6 Merge several of the modules together to see if that will help 
// remove some of the freezing whilst initial loading. First phase will
// be the ones that have nothing in the library and don't change much.
// Main = creation, dbInterface, exercise, glossary, login, menu

//Controller Object to enable communications between different movies
// 6.0.2.0 remove connection
//controller = new LocalConnection();
// v6.0.2.0 Move the connect statement to after all methods have been defined
//controller.connect("controlConnection");

//create empty movie clips to contain different modules
//each one is loaded and sent an "initialise" method
_global.controllerContainer = this;
var containerDepth = 1;

// the licence module will check to see if the program can be run
this.createEmptyMovieClip("licenceHolder", controlNS.depth++);
this.licenceHolder._x = 0;
this.licenceHolder._y = 0;
// You cannot use onData in this way as loading the .swf clears out any functions/variables
// already set on the MC. Therefore, each .swf will run initialise itself and the controller
// is not allowed to call a method in a module until that module has sent back an event saying
// it has been fully loaded!
//this.licenceHolder.onData = function () {
//	myTrace("licence.swf loaded");
//	initLicence = new LocalConnection();
//	initLicence.send("licenceConnection", "initialise");
//	delete initLicence;
//};
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("licence");
}else{
   var cacheVersion = ""
}
//myTrace("load " + "licence.swf" + cacheVersion);
//_global.ORCHID.NumberOfModules++;
// v6.4.2 consolidate use of this array for names and load status
//_global.ORCHID.moduleNames.push("licenceModule");
_global.ORCHID.moduleNames.push({name:"licenceModule", loaded:false});
this.licenceHolder.loadMovie(movieLocation + "licence.swf" + cacheVersion);

// this module contains the objects and scripts for the rest of Orchid
this.createEmptyMovieClip("objectHolder", controlNS.depth++);
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("objects");
}else{
   var cacheVersion = ""
}
//myTrace("load " + "objects.swf" + cacheVersion);
//_global.ORCHID.NumberOfModules++;
// v6.4.2 consolidate use of this array for names and load status
_global.ORCHID.moduleNames.push({name:"objectsModule", loaded:false});
this.objectHolder.loadMovie(movieLocation + "objects.swf" + cacheVersion);

// v6.3.6 Merge database to main (and change name)

this.createEmptyMovieClip("buttonsHolder", controlNS.depth++);
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("buttons");
}else{
   var cacheVersion = ""
}
//myTrace("load " + "buttons.swf, depth=" + controlNS.depth);
//_global.ORCHID.NumberOfModules++;
// v6.3.4 buttons might be in a special brand folder
// v6.3.5 Change the name of the path
//if (_global.ORCHID.paths.brandMovies == undefined) {
//if (_global.ORCHID.paths.interfaceMovies == undefined) {
//	_global.ORCHID.paths.interfaceMovies = movieLocation;
//}
//myTrace("load buttons from " + movieLocation);
// v6.4.2 consolidate use of this array for names and load status
_global.ORCHID.moduleNames.push({name:"buttonsModule", loaded:false});
this.buttonsHolder.loadMovie(_global.ORCHID.paths.interfaceMovies + "buttons.swf" + cacheVersion);

// v6.2 The intro stuff has gone into buttons

// v6.3.6 Remove login into merged main
// v6.2 There is nothing done in scaffold holder anymore

//this.createEmptyMovieClip("navigationHolder", containerDepth++);
//this.navigationHolder.loadMovie(movieLocation + "navigation.swf");

// v6.3.6 Merge menu into main
// v6.3.6 Remove creation into merged main

this.createEmptyMovieClip("mainHolder", controlNS.depth++);
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("main");
}else{
   var cacheVersion = ""
}
//myTrace("load " + "main.swf" + cacheVersion);
//_global.ORCHID.NumberOfModules++;
// v6.4.2 consolidate use of this array for names and load status
_global.ORCHID.moduleNames.push({name:"mainModule", loaded:false});
this.mainHolder.loadMovie(movieLocation + "main.swf" + cacheVersion);

// v6.3.6 Remove exercise into merged main
this.createEmptyMovieClip("jukeboxHolder", controlNS.depth++);
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("jukebox");
}else{
   var cacheVersion = ""
}
//myTrace("load " + movieLocation + "jukeBox.swf" + cacheVersion);
//_global.ORCHID.NumberOfModules++;
// v6.4.2 consolidate use of this array for names and load status
_global.ORCHID.moduleNames.push({name:"jukeboxModule", loaded:false});
this.jukeboxHolder.loadMovie(movieLocation + "jukeBox.swf" + cacheVersion);

//v6.4.2 Always bring in video player so that it is ready in cache if you need it later
this.createEmptyMovieClip("videoHolder", controlNS.depth++);
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("video");
}else{
   var cacheVersion = ""
}
//myTrace("load " + movieLocation + "jukeBox.swf" + cacheVersion);
// But treat it differently as it will be loaded many times
//_global.ORCHID.NumberOfModules++;
//_global.ORCHID.moduleNames.push("videoModule");
this.videoHolder.loadMovie(movieLocation + "videoPlayer.swf" + cacheVersion);

// v6.3.6 Remove progress, it had no functions or anything in it any more
// I suspect that the brand holder should load the intro
// and quite possibly the buttons as well.
// v6.2 yes, the intro has gone into buttons
// v6.3.4 And now the warnings and sounds have gone into buttons as well

// v6.3.6 Remove glossary into merged main

// A movie that has printing functions - now this is a v7 flash file
// so if you are running v6 player it will not load. Which doesn't matter
// so long as you don't wait for it.
this.createEmptyMovieClip("printingHolder", controlNS.depth++);
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("printing");
}else{
   var cacheVersion = ""
}
//myTrace("load " + "printing.swf" + cacheVersion);
//_global.ORCHID.NumberOfModules++;
// v6.4.2 consolidate use of this array for names and load status
_global.ORCHID.moduleNames.push({name:"printingModule", loaded:false});
this.printingHolder.loadMovie(movieLocation + "printing.swf" + cacheVersion);

// v6.3.5 I want the closing credits to be loaded here rather than later.
// They go in the same folder as buttons
this.createEmptyMovieClip("creditsHolder", controlNS.depth++);
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("credits");
}else{
   var cacheVersion = ""
}
//myTrace("load " + "credits.swf" + cacheVersion);
//_global.ORCHID.NumberOfModules++;
// v6.4.2 consolidate use of this array for names and load status
_global.ORCHID.moduleNames.push({name:"creditsModule", loaded:false});
this.creditsHolder.loadMovie(_global.ORCHID.paths.interfaceMovies + "credits.swf" + cacheVersion);

// v6.3.3 A movie to control SCORM communication
if (_global.ORCHID.commandLine.scorm) {
	this.createEmptyMovieClip("scormHolder", controlNS.depth++);
	if(_global.ORCHID.online){
	   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("scorm");
	}else{
	   var cacheVersion = ""
	}
	//myTrace("load " + "scorm.swf" + cacheVersion);
	//_global.ORCHID.NumberOfModules++;
	// v6.4.2 consolidate use of this array for names and load status
	_global.ORCHID.moduleNames.push({name:"scormModule", loaded:false});
	this.scormHolder.loadMovie(movieLocation + "scorm.swf" + cacheVersion);
}
// v6.3.4 Move the onEnterFrame controller to always be loaded just the once
// v6.4.2 Why is this done slightly differently?
//var myController = this.createEmptyMovieClip("tlcController", controlNS.depth++);
this.createEmptyMovieClip("tlcController", controlNS.depth++);
if(_global.ORCHID.online){
   var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("onEnterFrame");
}else{
	var cacheVersion = ""
}
//myController.loadMovie(movieLocation + "onEnterFrame.swf" + cacheVersion);
this.tlcController.loadMovie(movieLocation + "onEnterFrame.swf" + cacheVersion);

//v6.4.2 Consolidated way of counting loaded modules
_global.ORCHID.NumberOfModules = _global.ORCHID.moduleNames.length;
_global.ORCHID.isModuleLoaded = function(modName) {
	var me = _global.ORCHID.moduleNames;
	for (var i in me) {
		if (me[i].name == modName && me[i].loaded) {
			return true;
		} 
	}
	return false;
}
//myTrace("done attach script");
*/
/*
// OLD CODE from attach layer in frame 3
//
//AM: Start the program only after all KEY modules are loaded.
// v6.3.5 Don't wait for ever. Show the user why not it is loading.
// v6.4.2 rootless
//_$waitForStart = function() {
// v6.4.2 Should I wait for ALL modules to load?? Try just adding in 'main' to the list
controlNS.waitForStart = function() {
	// v6.4.2 Change module loaded and reporting method
	//if(_global.ORCHID.licenceModuleLoaded &&
	 //  _global.ORCHID.buttonsModuleLoaded &&
	 //  _global.ORCHID.objectModuleLoaded) {
	if(_global.ORCHID.isModuleLoaded("licenceModule") &&
	   _global.ORCHID.isModuleLoaded("buttonsModule") &&
	   _global.ORCHID.isModuleLoaded("mainModule") &&
	   _global.ORCHID.isModuleLoaded("objectsModule")) {
	   //_global.ORCHID.brandingModuleLoaded) {
		//myTrace("all key modules loaded");
		clearInterval(controlNS.intervals.startIntID);
		//_$startTheProgram();
		this.startTheProgram();
	} else {
		myTrace(_global.ORCHID.NumberOfModulesLoaded + " out of " + _global.ORCHID.NumberOfModules + " modules loaded.");
	}
	// 10 times through the loop is 10 seconds 
	// 300 times is 5 minutes - seems enough!
	if (_global.ORCHID.moduleWaitingLoop > 300) {
		//myTrace("enough already");
		clearInterval(controlNS.intervals.startIntID);
		var missingName = "";
		for (var i in _global.ORCHID.moduleNames) {
			if (!_global.ORCHID.moduleNames[i].loaded) {
				missingName+= _global.ORCHID.moduleNames[i].name + "; ";
			}
		}
		var errObj = {literal:"cannotLoadModules", detail:missingName};
		this.sendError(errObj);
	}		
	_global.ORCHID.moduleWaitingLoop++;
}
_global.ORCHID.moduleWaitingLoop = 0;
//v6.4.2 rootless
controlNS.intervals.startIntID = setInterval(controlNS, "waitForStart", 1000);
*/

/*
//List of methods that the controller will react to when called by the modules
// used for intra-module communication, principally modules requesting services
// or notifiying others that they have finished
// message centre - methods called from modules
// 6.0.2.0 replace connections with direct function calls

controlNS.remoteOnData = function(moduleName) {
	myTrace(moduleName + " has initialised",1);
	// v6.4.2 consolidate use of this array for names and load status
	//_global.ORCHID[moduleName + "Loaded"] = true;
	//incPercentage(Math.round(100 / _global.ORCHID.NumberOfModules));
	//_global.ORCHID.NumberOfModulesLoaded++;
	// just in case, add in a div by zero check
	if (_global.ORCHID.NumberOfModules > 0) {
		incPercentage(Math.round(100 / _global.ORCHID.NumberOfModules));
	}
	// remove it from the list (just to help if they don't all get loaded)
	// v6.4.2 No, just update the status
	var loadedSoFar = 0
	for (var i in _global.ORCHID.moduleNames) {
		// v6.4.2 consolidate use of this array for names and load status
		if (_global.ORCHID.moduleNames[i].name == moduleName) {
			_global.ORCHID.moduleNames[i].loaded = true;
		}
		if (_global.ORCHID.moduleNames[i].loaded) loadedSoFar++;
		//myTrace(_global.ORCHID.moduleNames[i].name + ".loaded=" + _global.ORCHID.moduleNames[i].loaded);
	}
	_global.ORCHID.NumberOfModulesLoaded = loadedSoFar;
	
	//trace("now loaded " + _global.ORCHID.NumberOfModulesLoaded + " modules");
	// you can now use things like _global.ORCHID.licenceModuleLoaded=true as a test to see
	// if a module is ready to take messages!
}
*/
