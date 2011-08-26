// constructor for the jukeBox class
function jukeBox(interface, initObj) {
	// v6.4.2.5 Should I do this in initProperties so that it really does get cleared out?
	// Hmm, no, that seems to break the connection between the control buttons
	this._JB = new Object();
	myTrace("constructor for jukebox with interface=" + interface.getDepth());
	// when you load the jukebox, link up the interface and code
	this.interface = interface;
	this.initButtons();
	// initialise properties if these are passed
	this.initProperties(initObj);
	//trace("in JB, media is " + this._JB.mediaType + " - " + this._JB.myURL);
	//start with the controls invisible
	this.interface.controls.enabled = false;
	this.interface.controls._visible = false;
	//6.0.4.0, AM: move the jb_holder from buttons.swf to jukebox.swf
	this.interface.jb_holder._visible = false;
}

var showOutside = function() {
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		this.outside._alpha = 100;	
	} else {
		this.outside._alpha = 100;	
	}
}
var hideOutside = function() {
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		this.outside._alpha = 0;	
	} else {
		this.outside._alpha = 0;	
	}
}
jukeBox.prototype.initButtons = function() {
	
	var myInt = this.interface.controls;
	// v6.5.6.4. New SSS. Customise most of the audio controller. Except that init is called during initial loading and you don't know branding yet.
	// So move this to setColour.
	//myTrace("branding=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
	myInt.jbPlay.ControlText.text = "4";
	myInt.jbPause.ControlText.text = ";";
	myInt.jbStop.ControlText.text = "<";
	myInt.jbRewind.ControlText.text = "7";
	myInt.jbStartAgain.ControlText.text = "9";
	myInt.jbRecord.ControlText.text = "=";
	///myTrace("not sss, so white text");
	var textColour = 0xFFFFFF;
	var recordingTextColour = 0xFF0000;
	// The stop button seems too big when it is on TB Button. And others
	/*
	var myTF = new TextFormat();
	myTF.size = 14;
	myInt.jbStop.ControlText.setTextFormat(myTF);
	myTF.size = 16;
	myInt.jbPause.ControlText.setTextFormat(myTF);
	myInt.jbStartAgain.ControlText.setTextFormat(myTF);
	myInt.jbRewind.ControlText.setTextFormat(myTF);
	//myInt.jbStop.ControlText._x+=1;
	myInt.jbStop.ControlText._y+=1;
	myInt.jbPause.ControlText._y+=1;
	//myInt.jbStartAgain.ControlText._y+=1;
	*/
	myInt.jbPlay.ControlText.textColor = textColour;
	myInt.jbPause.ControlText.textColor = textColour;
	myInt.jbStop.ControlText.textColor = textColour;
	myInt.jbRewind.ControlText.textColor  = textColour;
	myInt.jbStartAgain.ControlText.textColor  = textColour;
	myInt.jbRecord.ControlText.textColor = recordingTextColour;
	myInt.jbPlay.onRollOver = showOutside;
	myInt.jbPause.onRollOver = showOutside;
	myInt.jbStop.onRollOver = showOutside;
	myInt.jbRewind.onRollOver = showOutside;
	myInt.jbStartAgain.onRollOver = showOutside;
	myInt.jbRecord.onRollOver = showOutside;
	myInt.jbPlay.onRollOut = hideOutside;
	myInt.jbPause.onRollOut = hideOutside;
	myInt.jbStop.onRollOut = hideOutside;
	myInt.jbRewind.onRollOut = hideOutside;
	myInt.jbStartAgain.onRollOut = hideOutside;
	myInt.jbRecord.onRollOut = hideOutside;
}
jukeBox.prototype.initProperties = function(initObj) {
	//myTrace("jb.initProperties for " + initObj.jbURL);
	// v6.4.2.5 Should I do this here so that it really does get cleared out?
	// Hmm, no, that seems to break the connection between the control buttons
	//this._JB = new Object();
	
	if (initObj.jbURL == undefined) { 
		//myURL = "BalancingAct.mp3"; 
	} else {
		// v6.2 If you are setting properties for the media that is already playing
		// then this means stop. So is this call for the same media as the last call?
		// v6.3.4 This is causing lots of problems, stop it??
		/*
		if (this._JB.myURL == initObj.jbURL) {
			myTrace("this call is for the same media as the last call");
			//trace("target=" + this._JB.myTarget);
			// is it a sound that is still playing?
			if (this.s.position < this.s.duration){
				// in which case just stop it
				myTrace("stop (clear) as the sound is still running");
				//this.stop();
				// but I need to completely clear this as well so that I
				// don't think that I am still playing next time.
				this.clearMedia();
				return false;
			} else if ((this._JB.myTarget._currentFrame > 1) && 
						(this._JB.myTarget._currentFrame < this._JB.myTarget._totalFrames)) {
				//trace("stop as at " + this._JB.myTarget._currentFrame + "/" + this._JB.myTarget._totalFrames);
				this.stop();
				return false;
			}
		}
		*/
		this._JB.myURL = initObj.jbURL;
		//trace("initObj.jbMediaType=" + initObj.jbMediaType);
		//AR try moving this to the end so that it can overwrite other properties
		//trace("call setMediaType from initProperties");
		//this.setMediaType(initObj.jbMediaType);
	};
	if (initObj.jbName == undefined) {
	} else {
		this._JB.myName = initObj.jbName;
	};
	//v6.4.1 Hold the ID as well to allow swapping to be picked up
	if (initObj.jbID == undefined) {
	} else {
		this._JB.myID = initObj.jbID;
	};
	//v6.4.1 Hold the associated player as well
	//myTrace("jb:initProps:associatedPlayer=" + initObj.associatedPlayer);
	// v6.4.2.5 I want it to be undefined if I am not passing anything
	//if (initObj.associatedPlayer == undefined) {
	//} else {
		this._JB.associatedPlayer = initObj.associatedPlayer;
	//};
	this._JB.myAutoPlay = false; 
	if (initObj.jbAutoPlay == "true" || initObj.jbAutoPlay == true) { 
		this._JB.myAutoPlay = true; 
		//trace("it is an autoplay media file");
	};
	this._JB.myStreaming = false; // the default should be streaming?
	if (initObj.jbStreaming == "true" || initObj.jbStreaming == true) { 
		this._JB.myStreaming = true; 
	};
	this._JB.myShowName = false; 
	if (initObj.jbShowName == "true" || initObj.jbShowName == true) { 
		myShowName = true;
	}
	this._JB.myRecording = false; 
	if (initObj.jbRecording == "true" || initObj.jbRecording == true) { 
		this._JB.myRecording = true;
	}
	if (initObj.jbWidth == undefined) { 
		this._JB.myWidth = 0; 
	} else {
		this._JB.myWidth = Number(initObj.jbWidth); 
		//trace("picture requested width=" + this._JB.myWidth);
	};
	if (initObj.jbHeight == undefined) { 
		this._JB.myHeight = 0; 
	} else {
		this._JB.myHeight = Number(initObj.jbHeight); 
	};
	if (initObj.jbDisplayX == undefined) { 
		this._JB.displayX = undefined; 
	} else {
		this._JB.displayX = Number(initObj.jbDisplayX); 
	};
	if (initObj.jbDisplayY == undefined) { 
		this._JB.displayY = undefined; 
	} else {
		this._JB.displayY = Number(initObj.jbDisplayY); 
	};
	this._JB.displayAnchor = initObj.jbDisplayAnchor; 
	if (this._JB.myShowName == false) { 
		this.inteface.controls.jbFileName._visible = false; 
	} else {
		this.jbFileName.text = myURL;	
	}
	if (this._JB.myRecording == false) { 
		this.interface.controls.jbRecord._visible = false; 
		// Note: this is NOT the way to set the size!
		//this.interface.controls.background._width = 170;
	};
	// the jukebox can put the media in an independent MC, 
	// a drag pane under it's control or a simple MC under it's control
	if (typeof initObj.jbTarget == "movieclip") { 
		this._JB.myTarget = initObj.jbTarget;
		this._JB.targetType = "external";
	} else if (typeof initObj.jbTarget == "string" && initObj.jbTarget.indexOf("drag") >= 0) {
		// mediaPane is not created until needed, so this statement is valueless
		//this._JB.myTarget = this.interface.mediaPane; 
		this._JB.myTarget = undefined; 
		this._JB.targetType = "drag";
	} else {
		//myTrace("using target of jb internal mediaHolder");
		this._JB.myTarget = this.interface.mediaHolder; 
		this._JB.targetType = "mc";
	}
	// v6.3.5 Can trigger a end event back to the calling object
	if (initObj.jbEndEventTarget == undefined) {
	} else {
		this._JB.jbEndEventTarget = initObj.jbEndEventTarget;
	};
	if (initObj.jbEndEvent == undefined) {
	} else {
		this._JB.jbEndEvent = initObj.jbEndEvent;
	};
	
	// v6.4.1 For video slider
	if (initObj.jbDuration == undefined) {
	} else {
		this._JB.myDuration = initObj.jbDuration;
	};
	//myTrace("initProps, myTarget=" + this._JB.myTarget);
	// moved to the end, so that properties can be overwritten
	//trace("call setMediaType from initProperties");
	this.setMediaType(initObj.jbMediaType);
	//trace("after initProps targetType=" + this._JB.targetType);
	//trace("so targetType = " + this._JB.targetType);

	// finally, if there is a media file to play
	// prepare it. AR What? this call seems stupid - how can you prepare
	// a file that is undefined?
	// v6.4.2.4 So comment it out
	//if (this._JB.myURL == undefined) { 
	//	this.prepareJukeBox();
	//}
	return true;
}
jukeBox.prototype.setMediaType = function(value) {
	//trace("setMediaType with " + value + " and " + this._JB.myURL);
	// 6.0.2.0 use for special swf based sounds
	//this._JB.embedded = false;

	// what sort of multimedia is this? (It is usually going to be set)
	if (value == undefined) {
		// OK, so base it on the file extension
		if (this._JB.myURL.indexOf(".mp3")>0) {
			this._JB.mediaType = "audio";
		} else if (this._JB.myURL.indexOf(".jpg")>0) {
			this._JB.mediaType = "picture";
		} else if (this._JB.myURL.indexOf(".flv")>0) {
			this._JB.mediaType = "video";
		} else if (this._JB.myURL.indexOf(".fls")>0) {
			// v6.4.2.5 Can you treat the fls just like an mp3? So do nothing special. No, you can't
			// v6.4.2.7 Are you sure?
			this._JB.mediaType = "flashAudio";
			//this._JB.mediaType = "audio";
		} else if (this._JB.myURL.indexOf(".htm")>0) {
			this._JB.mediaType = "url";
		} else if (this._JB.myURL.indexOf(".xml")>0) {
			this._JB.mediaType = "text";
		} else {
			this._JB.mediaType = "animation";
		}
		//myTrace("type undefined, so base on extension, so is " + this._JB.mediaType);
	} else {
		// 6.0.3.0 slight change to allow anchored media type
		// v6.4.2.8 And anchored ones
		//if (value.substr(0,2) == "m:" || value.substr(0,2) == "q:") {
		if (value.substr(0,2) == "m:" || value.substr(0,2) == "q:" || value.substr(0,2) == "a:") {
			// 6.0.2.0 There is a special case of audio which is embedded in a swf
			// which needs to be treated as an animation (not use the sound object)
			// v6.4.2.7 Try stopping this being picked up - duge the extensions
			if ((value.substr(2) == "audio") && ((this._JB.myURL.indexOf(".fls")>0) ||
												 (this._JB.myURL.indexOf(".swf")>0))){
				myTrace("this is special flash audio, overwrite settings");
				//this._JB.embedded = true;				
				// v6.4.2.5 Can you treat the fls just like an mp3? So do nothing special. No
				this._JB.mediaType = "flashAudio";
				this._JB.myTarget = this.interface.mediaHolder; 
				this._JB.targetType = "mc";
				//this._JB.mediaType = value.substr(2);
			// 6.3 There is a special case of url links that don't get set up with
			// their own type by the authoring at the moment (m:animation)
			} else if (this._JB.myURL.indexOf(".htm")>0){
				myTrace("this is a special url, overwrite settings");
				this._JB.mediaType = "url";
				this._JB.targetType = "external";
			} else {
				this._JB.mediaType = value.substr(2);
			}
		} else {
			this._JB.mediaType = value;
		}
	}
}
// return dimensions of the current interface
// v6.3.4 Ditch the background as jb_holder is the graphic you want.
jukeBox.prototype.getSize = function() {
//	return {width:this.interface.controls.background._width, height:this.interface.controls.background._height}
	return {width:this.interface.jb_holder._width, height:this.interface.jb_holder._height}
}
// simple little clean up that stops sounds and removes visuals
jukeBox.prototype.clearMedia = function(mediaType) {
	//myTrace("jb.clearMedia for " + this._JB.mediaType + " from "+ this._JB.associatedPlayer);
	// v6.4.2.4 Check on the new file type before stopping existing media. I guess only pictures will NOT stop other media running
	//if (mediaType == "audio" || mediaType == "flashAudio" || mediaType == "video" || mediaType == "streamingAudio") {
	if (mediaType.indexOf("picture")>=0 || mediaType.indexOf("image")>=0) {
	} else {
		// Try another way to stop the flashAudio
		//this._JB.myTarget.closePane();
		//myTrace("stop swf in " + this._JB.myTarget);
		
		// v6.4.2.5 This is the reason why I can't do a second audio autoplay. Comment and it is OK!
		//this._JB.myTarget.stop();
		
		// If you have started loading a big file and move to another exercise
		// before it has downloaded, it seems that it keeps going. Is this how
		// you delete the handler?
		delete this.fileExists;
		this.s.stop();
		delete this.s;
		// v6.4.1 And any video
		//myTrace("stop media from " + this._JB.associatedPlayer);
		//myTrace("1.stop media from " + this._JB.myID);
		//myTrace("2.stop media from " + this._JB.jbEndEventTarget);
		// v6.4.3 This is the reason why I can't do a second audio autoplay. Comment and it is OK!
		this._JB.associatedPlayer.stop();
		// v6.4.2.4 Tell any running media that you have terminated it
		// v6.4.3 This is the reason why I can't do a second audio autoplay. Comment and it is OK!
		//this._JB.jbEndEventTarget.onFinishedPlaying();
		// v6.5.6.4 Who do you want to tell that they have been stopped?
		var runningPlayer = this._JB.associatedPlayer._parent._parent;
		myTrace("stop media " + this._JB.myID + " from " + runningPlayer);
		runningPlayer.onNotFinished(this._JB.myID);
	}
}
// main function for playing the media
jukeBox.prototype.prepareJukeBox = function() {
	//trace("current mediaList[0].jbURL=" + this.mediaList[0].jbURL);
	//trace("==========");
	//myTrace("prepareJB for " + this._JB.myURL + " this=" + this.interface);
	//trace("mediaType is " + this._JB.mediaType);
	//trace("targetType is " + this._JB.targetType);
	// clean up anything that is already playing that will conflict with what you want to do now
	var myTarget = this._JB.myTarget;
	var myTargetType = this._JB.targetType;
	// Taken out as myTarget is not defined for drag
	//if (myTargetType == "drag") {
		//trace("try to close the media pane " + myTarget);
		// I worry that this is not asynchronous, so later calls to recreate it will fail
		//myTrace("close the drag pane " + myTarget);
		//myTarget.closePane();
	//} 
	// v6.4.2.4 This is all pushed into clearMedia
	/*
	if (this._JB.mediaType == "audio") {
		myTrace("stop old sounds in prepareJukeBox");
		// v6.4.1 You also need to stop any playing video/animation
		// So might as well use the main clear function
		this.clearMedia();
		//this.s.stop();
		//delete this.s;
	} else if (this._JB.mediaType == "animation" || this._JB.mediaType == "flashAudio") {
		// EGU - ANY sound should stop any other as there is no background etc
		// However, it would be nice to have more control, but since each
		// click of an embedded swf sound starts a new audioPlay instance I don't
		// see how to stop just others of these.
		//trace("stop old animations in prepareJukeBox for " + myTarget);
		stopAllSounds();
		// v6.4.1 You also need to stop any playing video/animation
		// So might as well use the main clear function
		this.clearMedia();
	// v6.4.1 for video
	} else if (this._JB.mediaType == "video" || this._JB.mediaType == "streamingAudio") {
		// v6.4.2.4 No - we are just using the controls to send events, not to actually control media
		// and with streaming you might already be playing the media from the videoPlayer
		//stopAllSounds();
		// v6.4.1 You also need to stop any playing video/animation
		// So might as well use the main clear function
		//this.clearMedia();
	}
	*/
	this._JB.at = 0;
	
	//set up functions for handling reading text
	if (this._JB.mediaType == "text") {
	//handle reading text
		var fileName = this._JB.myURL;
		var TextName = this._JB.myName;
		var ReadingText = new XML();
		ReadingText.ignoreWhite = true;
		ReadingText.onLoad = function(success) {
			processReadingTextXML = function(ReadingTextXML) {
				var CurrentText = new _global.ORCHID.root.objectHolder.ExerciseObject();
				//_global.ORCHID.LoadedExercises[1] is used for storing reading text object
				_global.ORCHID.LoadedExercises[1] = CurrentText;
				CurrentText.rawXML = ReadingTextXML;
				myCallBack = function() {
					var substList = new Array();
					var thisText = _global.ORCHID.LoadedExercises[1].body.text
					completeDisplayCallback = function() {
						_global.ORCHID.tlc.controller.removeMovieClip();
						delete _global.ORCHID.tlc;
					}
					_global.ORCHID.tlc = {proportion:50,  // what % of the progress bar should this section account for?
						maxLoop:thisText.paragraph.length,  // how many units is this section broken down into?
						callBack:completeDisplayCallback,
						timeLimit:1000}
					_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(thisText, "drag pane", "ReadingText_SP" + TextName, substList);
				}
				// passing 1 into populateFromXML means processing a reading text xml
				CurrentText.populateFromXML(myCallBack, 1);
			}
			if (success) {
				//myTrace("load reading text xml successfully");
				processReadingTextXML(this);
			} else {
				myTrace("fail to load reading text xml " + this.status);
			}
		}
	}
	// v6.3 A url is very much easier - you don't need to load it unless it is autoplay
	if (this._JB.mediaType == "url") {
		//myTrace("item url=" + this._JB.myURL);
		if (this._JB.myAutoPlay) {
			//myTrace("autoplay url " + this._JB.myURL);
			//myTrace("that is autoplay, so go get it!");
			//v6.4.2 rootless
			//_root.getURL(this._JB.myURL, "_blank");
			getURL(this._JB.myURL, "_blank");
		}
		// there is nothing else to do for urls
		return;
	}
	//6.0.4.0, use LoadVars object to see if the media file exists
	// ar This is all well and good, but aren't I actually loading the media twice?
	// Or will the cache be used the second time?
	// v6.4 And surely it will kill streaming.
	// So for animation and video, don't do this
	// v6.4.3 Default audio is streaming
	if (	this._JB.mediaType == "animation" || this._JB.mediaType == "video" || 
		this._JB.mediaType == "streamingAudio" || this._JB.mediaType == "audio") {
		//myTrace("don't file check animation/video");
	// Take audio checking out of the loadVars as I can't respond properly with endEvents if it is in there.
	} else if (this._JB.mediaType == "staticAudio") {
		//_global.myTrace("onLoad audio handling");
		this.s = new Sound();
		this.s.autoPlay = this._JB.myAutoPlay;
		this.s.master = this;
		//this.s.onFinishedPlaying = this._JB.jbEndEventTarget.onFinishedPlaying;
		//this.s.onInformation = this._JB.jbEndEventTarget.onInformation;
		this.s.onLoad = function() {
			if (this.autoPlay == true) {
				_global.myTrace("autoplay so start audio now");
				this.start(0, 1);
			}
			// v6.4.2.4 Send information about the sound (could be used by a slider)
			//_global.myTrace("onLoad, tell this=" + this.master._parent);
			//this._parent._JB.myDuration = this.duration / 1000; // to get seconds
			this.master._JB.jbEndEventTarget.onInformation({duration:this.duration/1000});							
		};
		this.s.onSoundComplete = function() {
			_global.myTrace("onSoundComplete so onFinishedPlaying");
			this.master._JB.at = 0;
			// v6.4.2.4 Forget fscommands!!
			//fscommand("Finished"); // let whatever called you know that we have got to the end
			this.master._JB.jbEndEventTarget.onFinishedPlaying();
		};
		//this.s.loadSound(this._JB.myURL, this._JB.myStreaming);
		// v6.4.2.4 Can I stream these sounds OK now?
		myTrace("loadSound " + this._JB.myURL);
		this.s.loadSound(this._JB.myURL, true);
		this.interface.controls.enabled = true;
		this.interface.controls._visible = true;
		this.interface.jb_holder._visible = true;
		// v6.4.2.4 Add the slider for regular audio - but I don't know duration yet.
		//this._parent.interface.controls.jbSlider.setSliderProperties(0,this._JB.myDuration);
		this.interface.controls.jbSlider._visible = true;
						
	} else {
		if (this._JB.myURL != undefined && this._JB.myURL != "") {
			var fileExists = new LoadVars();
			fileExists._parent = this;
			fileExists.onLoad = function(success) {
			//success is true if the file exists, false if it doesnt
				//_global.myTrace(this._parent._JB.myURL + " fileExists=" + success);
				if (success) {
				//the file exists
					//trace(this._parent._JB.myURL + " exists");
					removeProgressBar();
					// v6.4.3 Audio streams by default
					//if (this._parent._JB.mediaType == "audio") {
					if (this._parent._JB.mediaType == "staticAudio") {
						//_global.myTrace("onLoad audio handling");
						this._parent.s = new Sound();
						this._parent.s.autoPlay = this._parent._JB.myAutoPlay;
						this._parent.s.onFinishedPlaying = this._parent._JB.jbEndEventTarget.onFinishedPlaying;
						this._parent.s.onInformation = this._parent._JB.jbEndEventTarget.onInformation;
						this._parent.s.onLoad = function() {
							if (this.autoPlay == true) {
								_global.myTrace("autoplay so start audio now");
								this.start(0, 1);
							}
							// v6.4.2.4 Send information about the sound (could be used by a slider)
							_global.myTrace("onLoad, tell this=" + this._parent._JB);
							//this._parent._JB.myDuration = this.duration / 1000; // to get seconds
							this.onInformation({duration:this.duration/1000});							
						};
						this._parent.s.onSoundComplete = function() {
							_global.myTrace("onSoundComplete so onFinishedPlaying to " + this._parent._parent._JB.jbEndEventTarget);
							this._parent._parent._JB.at = 0;
							// v6.4.2.4 Forget fscommands!!
							//fscommand("Finished"); // let whatever called you know that we have got to the end
							this.onFinishedPlaying();
						};
						this._parent.s.loadSound(this._parent._JB.myURL, this._parent._JB.myStreaming);
						this._parent.interface.controls.enabled = true;
						this._parent.interface.controls._visible = true;
						this._parent.interface.jb_holder._visible = true;
						// v6.4.2..4 Add the slider for regular audio - but I don't know duration yet.
						//this._parent.interface.controls.jbSlider.setSliderProperties(0,this._JB.myDuration);
						this._parent.interface.controls.jbSlider._visible = true;
						
					} else if (this._parent._JB.mediaType == "picture") {
						//myTrace("this._parent=" + this._parent);
						//trace("onLoad picture handling");
						//myTrace("load picture to " + this._parent._JB.targetType + ", " + this._parent._JB.myTarget);
						if (this._parent._JB.targetType == "drag") {
							var initObj = {_y:this._parent.interface.controls._height+4};//, _width:this._JB.myWidth, _height:this._JB.myHeight}
							// v6.2 I think I should just use the simple Flash drag pane here
							var myPane_dp = this._parent.interface.attachMovie("FDraggablePaneSymbol", "mediaPane", this._parent.interface.jukeboxNS.mediaPaneDepth, initObj);
							this._parent._JB.myTarget = myPane_dp;
							//myTrace("created mediaPane " + myPane_dp + " depth=" + myPane_dp.getDepth());
							myPane_dp._visible = false; // hide until it is positioned and sized nicely
							//trace("start loading the picture into " + myPane_dp + " :" + this._parent._JB.myURL);
							myPane_dp.loadScrollContent(this._parent._JB.myURL, "onDragLoad", this._parent);
							myPane_dp.setContentSize(this._parent._JB.myWidth, this._parent._JB.myHeight);
							//trace("loadScrollContent=" + this._JB.myURL + " into + " + myPane_dp);
						} else if (this._parent._JB.targetType == "external") {
							// the external window will have already loaded the media file
							// so the punter can see the first frame
							// 6.0.2.0 UNLESS this is a special audio embedded in a swf
							// in which case we still need to load the file now
							//if (this.parent._JB.mediaType == "flashAudio") {
							//	trace("But I don't think I am ever here");
							//	myTarget.loadMovie(this._parent._JB.myURL);
							//	//var thisDesc = "audio";
							//} else {
							//	//var thisDesc = this._JB.mediaType;
							//}
							//trace("external so don't load anything");
							if (this._parent._JB.myAutoPlay) { 
								//myTrace("external autoplay on " + this._parent._JB.myTarget);
								this._parent._JB.myTarget.play();
							}
						} else {
							//myTrace("loading media into " + this._parent._JB.myTarget);
							this._parent._JB.myTarget.loadMovie(this._parent._JB.myURL);
						}
						// ar why do I need controls for a picture?
						//this._parent.interface.controls.enabled = true;
						//this._parent.interface.controls._visible = true;
						//this._parent.interface.jb_holder._visible = true;
					} else if(this._parent._JB.mediaType == "text") {
						//myTrace("onload reading text: " + fileName);
						ReadingText.load (fileName);
					// v6.3 experiment with including flashAudio files in the loadVars
					// event. The effect of this should be to stop the audio from
					// streaming as it will not be loaded into the mediaHolder until
					// it is all in the cache. Yes, that works. I want to stop streaming
					// as I get a stutter effect whilst the audio is playing and still
					// downloading. It is a shame as streaming is clearly a good thing.
					// If the onClipEvent was working I could try to use getBytesTotal
					// etc to hold off for a little while before starting to see if that
					// helped.
					// But I still don't understand why I don't trigger the onClipEvent in 
					// mediaHolder. The function must have been overwritten.
					} else if(this._parent._JB.mediaType == "flashAudio") {
						myTrace("loading flashAudio internally to  " + this._parent._JB.myTarget);
						this._parent._JB.myTarget.loadMovie(this._parent._JB.myURL);
						this._parent.interface.controls.enabled = true;
						this._parent.interface.controls._visible = true;
						this._parent.interface.jb_holder._visible = true;
						// v6.3.5 Add in end testing for embedded sounds
						if (this._parent._JB.endTestInterval != undefined) clearInterval(this._parent._JB.endTestInterval);
						this._parent._JB.endTest = function() {
							// should have a similiar test for audio
							//myTrace("in endTest for " + this.myTarget);
							if (this.myTarget._currentframe >= this.myTarget._totalframes) {
								this.myTarget.nowPlaying = false;
								//myTrace("interval cleared at " + this.endTestInterval);
								clearInterval(this.endTestInterval);
								this.endTestInterval = undefined;
								myTrace("endTest triggered, tell " + this.jbEndEventTarget);
								// v6.4.2.7 This doesn't seem correct - call a named event on the target
								//this.jbEndEvent(this.jbEndEventTarget);
								this.jbEndEventTarget.onFinishedPlaying();
							} else {
								//myTrace("running endTest");
							}
						}
						this._parent._JB.endTestInterval = setInterval(this._parent._JB, "endTest", 500);
						//myTrace("start endTest with interval=" + this._parent._JB.endTestInterval);
					}
					//delete this;
				} else {
					this._parent.interface.mediaPane.removeMovieClip();
					this._parent.interface.controls.enabled = false;
					this._parent.interface.controls._visible = false;
					this._parent.interface.jb_holder._visible = false;
					removeProgressBar();
					myTrace(this._parent._JB.myURL + " does not exist");
					//setProgressErrorMsg("cannot load media");
					setProgressErrorMsg();
					delete this;
				}
			}
			myTrace("check if " + this._JB.myURL + " exists");
			fileExists.load(this._JB.myURL); //initiate the test
			if (this._JB.mediaType != "animation") {
				//setProgressBar(fileExists, "loading...");
				//myTrace("call setProgressBar");
				setProgressBar(fileExists);
			}
		}
	}
	/*if (this._JB.mediaType == "audio") {
		//trace("load audio to " + myTargetType);
		this.s = new Sound();
		//trace("s is a " + typeof this.s + " and it is at " + this._JB.myURL);
		this.s.autoPlay = this._JB.myAutoPlay;
		// enable the controls if this is an autoplay
		//if (this._JB.myAutoPlay) this.interface.controls._enabled = true;
		this.s.onLoad = function() {
			//trace("sound loaded into " + this);
			if (this.autoPlay == true) { 
				//trace("autoplay the sound now");
				this.start(0,1);
				//jbPlay.enabled = true; // how to do this properly?
			} else {
				//trace("sound is loaded ready to play");
			}
		}
		
		this.s.onSoundComplete = function() {
			//trace("onSoundComplete so send fsCommand('Finished')");
			this._parent._JB.at = 0;
			fscommand("Finished"); // let whatever called you know that we have got to the end
		};
		this.s.loadSound(this._JB.myURL, this._JB.myStreaming);
		//AM: display the progress bar for loading the sound.
		//setProgressBar(fileExists, "loading audio...");
		setProgressBar(this.s, "loading audio...");
		this.interface.controls.enabled = true;
		this.interface.controls._visible = true;
		this.interface.jb_holder._visible = true;
	} else*/
	//if (this._JB.mediaType == "animation" || this._JB.mediaType == "flashAudio") {
	//v6.4.1 bundle animation and video together
	//if (this._JB.mediaType == "animation") {
	if (this._JB.mediaType == "animation" || this._JB.mediaType == "video") {
		//myTrace("load animation/video to " + myTargetType + ", " + myTarget);
		// v6.0.4.0, for animation files, I don't wait to play the file until it is completely download.
		// because it may be a streaming file.
		// So the code for play back animation is not in the onLoad function of loadVars object
		//trace("load animation/flashAudio to " + myTargetType + ", " + myTarget);
		if (myTargetType == "drag") {
			var initObj = {_y:this.interface.controls._height+4};//, _width:this._JB.myWidth, _height:this._JB.myHeight}
			// v6.2 I think I should just use the simple Flash drag pane here
			var myPane_dp = this.interface.attachMovie("FDraggablePaneSymbol", "mediaPane", this.interface.jukeboxNS.mediaPaneDepth, initObj);
			this._JB.myTarget = myPane_dp;
			//myTrace("created mediaPane " + myPane_dp + " depth=" + myPane_dp.getDepth());
			myPane_dp._visible = false; // hide until it is positioned and sized nicely
			//trace("start loading the animation into " + myPane_dp + " :" + this._JB.myURL);
			
			// AR v6.3 This causes an error. The scroll content target cannot be found.
			// Don't know why. Also, if you embed an animation in the exercise, it starts
			// playing straight away and you cannot stop it.
			myPane_dp.loadScrollContent(this._JB.myURL, "onDragLoad", this);
			//myTrace("onLoad is " + this.onDragLoad);
			myPane_dp.setContentSize(this._JB.myWidth, this._JB.myHeight);
			//setProgressBar(myPane_dp.getScrollContent(), "loading ...");
			setProgressBar(myPane_dp.getScrollContent());
			//trace("loadScrollContent=" + this._JB.myURL + " into + " + myPane_dp);
		} else if (myTargetType == "external") {
			// the external window will have already loaded the media file
			// so the punter can see the first frame
			// 6.0.2.0 UNLESS this is a special audio embedded in a swf
			// in which case we still need to load the file now
			//if (this._JB.mediaType == "flashAudio") {
			//	trace("also don't think you are ever here either");
			//	myTarget.loadMovie(this._JB.myURL);
			//	var thisDesc = "audio";
			//} else {
			//	var thisDesc = this._JB.mediaType;
			//}
			// v6.4.2.4 It is not up to the controller to tell the video to get going
			//if (this._JB.myAutoPlay) { 
			//	myTrace("external autoplay, so tell it to get going");
			//	myTarget.play();
			//}
			//AM: display the progress bar for loading the media.
			//setProgressBar(myTarget, "loading ...");
			setProgressBar(myTarget);
		} else {
			myTrace("loading animation/video internally to jb");
			myTarget.loadMovie(this._JB.myURL);
			//AM: display the progress bar for loading the media.
			//setProgressBar(myTarget, "loading ...");
			//setProgressBar(myTarget);
			// what triggers this to start playing?? It should be
			// the onClipEvent in mediaHolder (embedded at design time)
		}
		//trace("making jb interface visible");
		this.interface.controls.enabled = true;
		this.interface.controls._visible = true;
		this.interface.jb_holder._visible = true;
		// v6.4.1 For the video slider
		this.interface.controls.jbSlider.setSliderProperties(0,this._JB.myDuration);
		// v6.4.1 Currently, only animation and video use the slider
		this.interface.controls.jbSlider._visible = true;

//		myPane_dp.setCloseHandler(this.onClose);
		//var thisTarget = targetPath(this.interface.mediaHolder);
		//trace("target for drag is " + thisTarget);
		//myPane_dp.setScrollContent(thisTarget);
		// the onLoad function code for this is in the mc
	//} else if (this._JB.mediaType == "picture") {
	//	//trace("JB load the picture, width=" + this._JB.myWidth);
	//	this.interface.controls._alpha = 50;
	//	this.interface.mediaHolder.loadMovie(this._JB.myURL);
	//	// the onLoad function code for this HAS to be in the mc onClipEvent(data)
	
	// v6.4.2.4 Add streaming audio - which also has a scrub bar
	// v6.4.3 Audio streams by default
	} else if (this._JB.mediaType == "streamingAudio" || this._JB.mediaType == "audio") {
		this.interface.controls.enabled = true;
		this.interface.controls._visible = true;
		this.interface.jb_holder._visible = true;
		// v6.4.1 For the video slider
		this.interface.controls.jbSlider.setSliderProperties(0,this._JB.myDuration);
		// v6.4.1 Currently, only animation and video use the slider
		this.interface.controls.jbSlider._visible = true;
	} else {
		// v6.4.1 Currently, only animation and video use the slider
		this.interface.controls.jbSlider._visible = false;
	}
	/*else if (this._JB.mediaType == "text") {
	//handle reading text
		var fileName = this._JB.myURL;
		var TextName = this._JB.myName;
		var ReadingText = new XML();
		ReadingText.ignoreWhite = true;
		ReadingText.onLoad = function(success) {
			processReadingTextXML = function(ReadingTextXML) {
				var CurrentText = new _root.objectHolder.ExerciseObject();
				//_global.ORCHID.LoadedExercises[1] is used for storing reading text object
				_global.ORCHID.LoadedExercises[1] = CurrentText;
				CurrentText.rawXML = ReadingTextXML;
				myCallBack = function() {
					var substList = new Array();
					var thisText = _global.ORCHID.LoadedExercises[1].body.text
					completeDisplayCallback = function() {
						_global.ORCHID.tlc.controller.removeMovieClip();
						delete _global.ORCHID.tlc;
					}
					_global.ORCHID.tlc = {proportion:50,  // what % of the progress bar should this section account for?
						maxLoop:thisText.paragraph.length,  // how many units is this section broken down into?
						callBack:completeDisplayCallback,
						timeLimit:1000}
					_root.objectHolder.putParagraphsOnTheScreen(thisText, "drag pane", "ReadingText_SP" + TextName, substList);
				}
				// passing 1 into populateFromXML means processing a reading text xml
				CurrentText.populateFromXML(myCallBack, 1);
			}
			if (success) {
				myTrace("load reading text xml successfully");
				processReadingTextXML(this);
			} else {
				myTrace("fail to load reading text xml " + this.status);
			}
		}
		myTrace("load reading text: " + fileName);
		ReadingText.load (fileName);
	}*/
}

jukeBox.prototype.onDragLoad = function() {
	//myTrace("animation loaded into drag");
	var content = this.interface.mediaPane.getScrollContent();
	//myTrace("drag content=" + content);
	var jbObj = this._JB;
	//AM: display the progress bar for loading the media.
	//if(this._JB.mediaType == "animation") {
	//	setProgressBar(content, "loading ...");
	//}
	//trace("media loaded into " + content);
	if (jbObj.myWidth > 0) {
		content._width = jbObj.myWidth;
	}
	if (jbObj.myHeight > 0) {
		content._height = jbObj.myHeight;
	}
	//trace("loaded media and requested width=" + jbObj.myWidth);
	//trace("scale=" + this._xscale + " current width=" + this._width);
	this.interface.mediaPane.setContentSize(content._width, content._height);
	// use the absolute coordinates sent (optionally) to jukeBox to position the drag pane
	if (jbObj.displayX != undefined || jbObj.displayY != undefined) {
		var xOffset = yOffset = 0; // default is top left
		//trace("displayX = " + jbObj.displayX + " xOffset=" + xOffset);
		if (jbObj.displayAnchor == "tr") { // anchor at top right
			xOffset = -content._width;
			yOffset = 0;
		} else if (jbObj.displayAnchor == "br") { // anchor at bottom right
			xOffset = -content._width;
			yOffset = -content._height;
		} else if (jbObj.displayAnchor == "c") { // anchor at centre
			xOffset = -content._width/2;
			yOffset = -content._height/2;
		}
		//trace("abs coordinate request = (" + jbObj.displayX + ", " + jbObj.displayY +")");
		var myPoint = {x:jbObj.displayX, y:jbObj.displayY};
		this.interface.mediaPane.globalToLocal(myPoint);
		//myTrace("translate to local = (" + myPoint.x + ", " + myPoint.y +") from (" + jbObj.displayX + ", " + jbObj.displayY + ")");
		this.interface.mediaPane._x = myPoint.x + xOffset;
		this.interface.mediaPane._y = myPoint.y + yOffset;
	}

	//this.interface.mediaPane.setScrollPosition(0,0);
	// This is where we hide the media pane because special audio doesn't want to see it
	// You should NOT be here as flashAudio works with internal NOT the drag pane
	if (this._JB.mediaType == "flashAudio") {
		//trace("keep the drag pane invisible");
	} else {
		myTrace("display the drag pane");
		this.interface.mediaPane._visible = true;
		this.interface.mediaPane.refreshScrollContent();
	}
	if (jbObj.myAutoPlay) { 
		content.play();
	} else {
		content.stop();
		content._currentframe = 0;
	}
}
// external function to pass a media file properties and prepare it for running
jukeBox.prototype.setMedia = function(initObj, runNow) {
	//trace("in setMedia with " + initObj.jbURL);
	// v6.4.1 Send out an event if you are changing from one media object to another
	//myTrace("setMedia for id=" + initObj.jbID + " old id=" + this._JB.myID); // + " oldPlayer=" + this._JB.associatedPlayer + " newPlayer=" + initObj.associatedPlayer);
	//if (this._JB.associatedPlayer == undefined) { myTrace("oldPlayer=undefined")};
	// v6.4.2.5 If the old player is not defined, don't touch it
	if (this._JB.associatedPlayer != undefined) {
		//if (this._JB.myID != initObj.jbID &&	this._JB.associatedPlayer != undefined) {
		if (this._JB.myID != initObj.jbID) {
			//myTrace("lose focus from " + this._JB.associatedPlayer);
			this._JB.associatedPlayer.lostFocus()
		} else {
			// v6.4.2.5 If this is really the same media, then why not just stop and start again?
			//myTrace("try to start again");
			this.startAgain();
			return;
		}
		// v6.4.2.4 If I am trying to stop the existing audio when a new one starts, I can't set all the properties first
		// So change this order
		//myTrace("clear media new type=" + initObj.jbMediaType + " old id=" + this._JB.jbID);
		// v6.4.2.5 This is the reason why I can't do a second audio autoplay. Comment and it is OK!
		// No, now it is sorted out
		this.clearMedia(initObj.jbMediaType);
	}
	// if you have asked to set and start the media in one call, then use autoPlay
	// as it has the same impact. NOTE: this might overwrite the original object 
	// property, and that might not be good - I don't know.
	if (runNow) initObj.jbAutoPlay = true;
	if (this.initProperties(initObj)) {
		this.prepareJukeBox();
	};
}
jukeBox.prototype.play = function() {
	//myTrace("jukebox:class:play:629");
	this.interface.controls.jbPlay.onRelease();
}
jukeBox.prototype.stop = function() {
	//myTrace("jukebox:class:stop:782");
	this.interface.controls.jbStop.onRelease();
	// v6.4.2.4 Tell any running media that you have terminated it
	this._JB.jbEndEventTarget.onFinishedPlaying();
}
jukeBox.prototype.startAgain = function() {
	//myTrace("jukebox:class:startAgain");
	this.interface.controls.jbStartAgain.onRelease();
}
jukeBox.prototype.clear = function() {
//	trace("clear called from somewhere");
}

jukeBox.prototype.clearAll = function() {
	//myTrace("clearAll: stop and empty the jukebox sound");
	this.interface.mediaHolder.stop();
	// v6.3 If you just do this, you lose the drag pane capabilities - so try
	// closing it in a nicer way.
	//this.interface.mediaPane.removeMovieClip();
	this.interface.mediaPane.closePane();
	this.interface.loadProgress._visible = false;
	this.interface.errorMsg._visible = false;
	delete this.s.onLoad;
	this.s.stop();
	delete this.s;
	this.interface.controls._visible = false;
	this.interface.jb_holder._visible = false;
	//trace("Media list is " + this.mediaList);
	this.mediaList = new Array();
	// v6.4.1 for video
	this._JB.associatedPlayer.stop();
	// v6.4.2.4 Tell any running media that you have terminated it
	this._JB.jbEndEventTarget.onFinishedPlaying();
}
// v6.3.4 for skinning
// v6.5 Allow two different colours to be used. No forget that.
jukeBox.prototype.setColour = function(myColour) {
//jukeBox.prototype.setColour = function(myColour, mySecondColour) {
	//myTrace("jukebox.setColour=" + _global.ORCHID.root.licenceHolder.licenceNS.branding);
	if (mySecondColour==undefined) mySecondColour = myColour;
	// Maybe you should redo the text captions as we know the brand now
	this.initButtons();
	// Allow more skinning - be careful of sizes
	// v6.5.6.4 New SSS
	//if ((_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sss") >= 0) ||
	var myInt = this.interface.controls;
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("bc/ielts") >= 0) {
		// v6.4.2.8 Allow more skinning options based on brand
		///myTrace("sss so blue text");
		var textColour = 0x333399;
		var recordingTextColour = 0xFF0000;
		myInt.jbPlay.ControlText.textColor = textColour;
		myInt.jbPause.ControlText.textColor = textColour;
		myInt.jbStop.ControlText.textColor = textColour;
		myInt.jbRewind.ControlText.textColor  = textColour;
		myInt.jbStartAgain.ControlText.textColor  = textColour;
		myInt.jbRecord.ControlText.textColor = recordingTextColour;
		
		// the old way, using the same colour for background and buttons (glass tile)
		//myTrace("jukeBox: sss, setColour to " + myColour);
		this.interface.jb_holder.setColour(myColour);
		var thisButtonAlpha=90;
		var myTarget = this.interface.controls.jbPlay.controlFill;
		var myColourObject = new Color(myTarget);
		myColourObject.setRGB(mySecondColour);
		myTarget._alpha = thisButtonAlpha;
		var myTarget = this.interface.controls.jbRecord.controlFill;
		var myColourObject = new Color(myTarget);
		myColourObject.setRGB(mySecondColour);
		myTarget._alpha = thisButtonAlpha;
		var myTarget = this.interface.controls.jbPause.controlFill;
		var myColourObject = new Color(myTarget);
		myColourObject.setRGB(mySecondColour);
		myTarget._alpha = thisButtonAlpha;
		var myTarget = this.interface.controls.jbStop.controlFill;
		var myColourObject = new Color(myTarget);
		myColourObject.setRGB(mySecondColour);
		myTarget._alpha = thisButtonAlpha;
		var myTarget = this.interface.controls.jbRewind.controlFill;
		var myColourObject = new Color(myTarget);
		myColourObject.setRGB(mySecondColour);
		myTarget._alpha = thisButtonAlpha;
		var myTarget = this.interface.controls.jbStartAgain.controlFill;
		var myColourObject = new Color(myTarget);
		myColourObject.setRGB(mySecondColour);
		myTarget._alpha = thisButtonAlpha;
		return;
	// v6.4.2.4 Or skin the buttons for each interface
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
	
		myTrace("skinning sss/cp2 jukebox"); 
		// You can't do this in init as you don't know branding then
		// override the default positions
		var leftNudge=20;
		var topNudge=5;
		myInt.jbSlider._x=5 + leftNudge;
		myInt.jbSlider._y=30 - topNudge;
		myInt.jbSlider._width = 65;
		myInt.jbSlider._height = 8;
		myInt.jbPlay._x=0 + leftNudge;
		//myInt.jbPause._x=myInt.jbPlay._width;
		myInt.jbPause._x=26 + leftNudge;
		//myInt.jbStop._x=myInt.jbPause._x + myInt.jbPause._width;
		myInt.jbStop._x=52 + leftNudge;
		myInt.jbPlay._y=myInt.jbPause._y=myInt.jbStop._y=0+topNudge;

		// Replace the original background
		// v6.5.6.4 But I see that the original has the interface above things like the notepad. Oops.
		// It is because buttonsHolder is under jukeboxHolder, and notepad is floating around on buttons!
		//this.interface.jb_holder.attachMovie("sssBackground", "jbSkinnedBackground", 10); 
		// Its not a solution, but put the background onto the buttons screen and make it invisible here
		var backgroundDepth = this.interface.jb_holder.getDepth();
		this.interface.jb_holder.swapDepths(10);
		this.interface.jb_holder.removeMovieClip();
		//myTrace("add jb background at depth=" + backgroundDepth);
		this.interface.attachMovie("sssBackground", "jb_holder", backgroundDepth);
		// v6.5.6.5 I don't see why, but set this to false to keep teh background from displaying when there is no controller.
		this.interface.jb_holder._visible = false;
		
		// You can't just replace jbPlay as you have already set lots of functions on it
		var playBtnDepth = this.interface.controls.jbPlay.controlFill.getDepth();
		this.interface.controls.jbPlay.controlFill.swapDepths(11);
		this.interface.controls.jbPlay.controlFill.removeMovieClip();
		playBtnDepth = this.interface.controls.jbPlay.ControlText.getDepth();
		this.interface.controls.jbPlay.ControlText.swapDepths(11); 
		this.interface.controls.jbPlay.ControlText.removeMovieClip();
		playBtnDepth = this.interface.controls.jbPlay.outside.getDepth();
		this.interface.controls.jbPlay.outside.swapDepths(11);
		this.interface.controls.jbPlay.outside.removeMovieClip();
		this.interface.controls.jbPlay.attachMovie("sssPlay", "jbSkinnedButton1", 10);
		
		playBtnDepth = this.interface.controls.jbPause.controlFill.getDepth();
		this.interface.controls.jbPause.controlFill.swapDepths(11);
		this.interface.controls.jbPause.controlFill.removeMovieClip();
		playBtnDepth = this.interface.controls.jbPause.ControlText.getDepth();
		this.interface.controls.jbPause.ControlText.swapDepths(11);
		this.interface.controls.jbPause.ControlText.removeMovieClip();
		playBtnDepth = this.interface.controls.jbPause.outside.getDepth();
		this.interface.controls.jbPause.outside.swapDepths(11);
		this.interface.controls.jbPause.outside.removeMovieClip();
		this.interface.controls.jbPause.attachMovie("sssPause", "jbSkinnedButton3", 10);
		
		playBtnDepth = this.interface.controls.jbStop.controlFill.getDepth();
		this.interface.controls.jbStop.controlFill.swapDepths(11);
		this.interface.controls.jbStop.controlFill.removeMovieClip();
		playBtnDepth = this.interface.controls.jbStop.ControlText.getDepth();
		this.interface.controls.jbStop.ControlText.swapDepths(11);
		this.interface.controls.jbStop.ControlText.removeMovieClip();
		playBtnDepth = this.interface.controls.jbStop.outside.getDepth();
		this.interface.controls.jbStop.outside.swapDepths(11);
		this.interface.controls.jbStop.outside.removeMovieClip();
		this.interface.controls.jbStop.attachMovie("sssStop", "jbSkinnedButton4", 10);
		
		this.interface.controls.jbRecord._visible = false; 
		this.interface.controls.jbStartAgain._visible = false; 
		this.interface.controls.jbRewind._visible = false; 
		// And can I skin the slider here?
		
		return;
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/tb") >= 0) {
		this.interface.jb_holder.attachMovie("tbBackground", "jbSkinnedBackground", 10); // Has to go above the glass tile
		var thisButton = "tbButton";
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/ro") >= 0) {
		this.interface.jb_holder.attachMovie("roBackground", "jbSkinnedBackground", 10); // Has to go above the glass tile
		var thisButton = "tbButton";
	} else {
		this.interface.jb_holder.attachMovie("roBackground", "jbSkinnedBackground", 10); // Has to go above the glass tile
		var thisButton = "tbButton";
	}
	this.interface.controls.jbPlay.controlFill.attachMovie(thisButton, "jbSkinnedButton1", 10);
	this.interface.controls.jbRecord.controlFill.attachMovie(thisButton, "jbSkinnedButton2", 10);
	this.interface.controls.jbPause.controlFill.attachMovie(thisButton, "jbSkinnedButton3", 10);
	this.interface.controls.jbStop.controlFill.attachMovie(thisButton, "jbSkinnedButton4", 10);
	this.interface.controls.jbRewind.controlFill.attachMovie(thisButton, "jbSkinnedButton5", 10);
	this.interface.controls.jbStartAgain.controlFill.attachMovie(thisButton, "jbSkinnedButton6", 10);
	var myTarget = this.interface.controls.jbPlay.controlFill;
	var playColor = new Color(myTarget);
	playColor.setTransform({rb:0, gb:0, bb:0, aa:100, ab:0});
	var myTarget = this.interface.controls.jbRecord.controlFill;
	var playColor = new Color(myTarget);
	playColor.setTransform({rb:0, gb:0, bb:0, aa:100, ab:0});
	var myTarget = this.interface.controls.jbPause.controlFill;
	var playColor = new Color(myTarget);
	playColor.setTransform({rb:0, gb:0, bb:0, aa:100, ab:0});
	var myTarget = this.interface.controls.jbStop.controlFill;
	var playColor = new Color(myTarget);
	playColor.setTransform({rb:0, gb:0, bb:0, aa:100, ab:0});
	var myTarget = this.interface.controls.jbRewind.controlFill;
	var playColor = new Color(myTarget);
	playColor.setTransform({rb:0, gb:0, bb:0, aa:100, ab:0});
	var myTarget = this.interface.controls.jbStartAgain.controlFill;
	var playColor = new Color(myTarget);
	playColor.setTransform({rb:0, gb:0, bb:0, aa:100, ab:0});
}
// v6.4.2.4 For hiding the control interface, but not the whole thing
jukeBox.prototype.setEnabled = function(enabled) {
	myTrace("jukebox interface setEnabled " + enabled);
	this.interface._visible = enabled;
}
// 
// Code for button action
//
jukeBox.prototype.setButtonCode = function() {
	var jbObj = this._JB;
	var controls = this.interface.controls;
	// v6.4.1 To make video control easier
	//controls.controller = this;
	controls.jbPlay.endTest = function() {
		// should have a similiar test for audio
		//trace("in endTest");
		if (controls._parent.mediaHolder._currentframe >= controls._parent.mediaHolder._totalframes) {
			jbObj.at = 1;
			//trace("interval cleared at " + this.myInterval);
			clearInterval(this.myInterval);
			this.myInterval = undefined;
			//myTrace("endTest triggered");
		}
	}
	controls.jbPlay.onRelease = function() {
		myTrace("play:" + jbObj.myURL+" at "+jbObj.at + " as a " + jbObj.mediaType);
		// v6.4.3 Audio streams by default
		//if (jbObj.mediaType == "audio") {
		if (jbObj.mediaType == "staticAudio") {
			// setting the absolute ref works, so how to get there relatively?
			//var so = _level0.mediaHolder.myJukeBox.s;
			var s = this._parent._parent.myJukeBox.s;
			s.stop();
			s.start(Number(jbObj.at/1000));
			//so.start(0,1);
		} else if (jbObj.mediaType == "animation" || jbObj.mediaType == "flashAudio") {
			if (jbObj.at == 0) jbObj.at = 1; // a frame of 0 is ignored by gotoAndPlay
			//trace("mediaHolder=" + controls._parent.mediaHolder);
			// or this works if you load into a dragPane
			if (jbObj.targetType == "drag") {
				var content = controls._parent.mediaPane.getScrollContent();
			} else if (jbObj.targetType == "external") {
				var content = jbObj.myTarget;
			} else {
				// this works if the media is loaded into the static MC
				var content = controls._parent.mediaHolder;
			}
			//trace("try sending play to " + content);
			content.gotoAndPlay(jbObj.at);

			// set a test so that you can reset when the animation finishes
			// but make sure you don't do this too often!
			if (this.myInterval == undefined) {
				this.myInterval = setInterval(this, "endTest", 500);
			}
			//myTrace("endTest interval=" + this.myInterval);
		//} else if (_parent._JB.mediaType == "picture") {
		//	mediaHolder.loadMovie(_parent._JB.myURL);
		//v6.4.1 Add video
		// v6.4.3 Audio streams by default
		} else if (jbObj.mediaType == "video" || jbObj.mediaType == "streamingAudio" || jbObj.mediaType == "audio") {
			//var myController = this._parent._parent;
			//myTrace("click play, pass to " + jbObj.associatedPlayer);
			//var videoPlayer = myController.associatedPlayer;
			var videoPlayer = jbObj.associatedPlayer;
			videoPlayer.play();
		}
	}
	controls.jbStop.onRelease = function() {
		// stop the sound and reset the position property
		// v6.4.3 Audio streams by default
		_global.myTrace("try to stop " + jbObj.mediaType);
		//if (jbObj.mediaType == "audio") {
		if (jbObj.mediaType == "staticAudio") {
			if (jbObj.the_mic != undefined) {
				//trace("stopping recording");
				delete jbObj.the_mic;
			} else {
				jbObj.at = 0;
				var s = this._parent._parent.myJukeBox.s;
				s.stop();
			};
			// v6.4.2.4 Tell any running media that you have terminated it
			//myTrace("jbStop for " )
			this._parent._parent.myJukeBox._JB.jbEndEventTarget.onFinishedPlaying();
			
		} else if (jbObj.mediaType == "animation" || jbObj.mediaType == "flashAudio") {
			jbObj.at = 1;
			if (jbObj.targetType == "drag") {
				var content = controls._parent.mediaPane.getScrollContent();
			} else if (jbObj.targetType == "external") {
				var content = jbObj.myTarget;
			} else {
				var content = controls._parent.mediaHolder;
			}
			// v6.2 Reset the playhead as well as stopping
			//content.stop();
			//trace("reset from frame " + content._currentFrame + " content=" + content);
			content.gotoAndStop(jbObj.at);
			//content._currentFrame = jbObj.at;
			//trace("to frame " + content._currentFrame);
			//v6.3.5 And also stop any endTest
			if (jbObj.endTestInterval != undefined) {
				//myTrace("stop so clear endTestInterval");
				clearInterval(jbObj.endTestInterval);
			}
		//v6.4.1 Add video
		// v6.4.3 Audio streams by default
		} else if (jbObj.mediaType == "video" || jbObj.mediaType == "streamingAudio" || jbObj.mediaType == "audio") {
			var myController = this._parent._parent;
			myTrace("click stop, pass to " + myController.associatedPlayer);
			var videoPlayer = jbObj.associatedPlayer;
			videoPlayer.stop();
		}
	}
	controls.jbPause.onRelease = function() {
		//myTrace("pause at ...");
		// v6.4.3 Audio streams by default
		//if (jbObj.mediaType == "audio") {
		if (jbObj.mediaType == "staticAudio") {
			var s = this._parent._parent.myJukeBox.s;
			jbObj.at = s.position;
			s.stop();
		} else if (jbObj.mediaType == "animation" || jbObj.mediaType == "flashAudio") {
			if (jbObj.targetType == "drag") {
				//trace("drag");
				var content = controls._parent.mediaPane.getScrollContent();
			} else if (jbObj.targetType == "external") {
				//trace("external");
				var content = jbObj.myTarget;
			} else {
				//trace("other");
				var content = controls._parent.mediaHolder;
			}
			//jbObj.at = controls._parent.mediaHolder._currentframe;
			jbObj.at = content._currentframe;
			//trace("paused at " + jbObj.at);
			//controls._parent.mediaHolder.stop();
			content.stop();
		//v6.4.1 Add video
		// v6.4.3 Audio streams by default
		} else if (jbObj.mediaType == "video" || jbObj.mediaType == "streamingAudio" || jbObj.mediaType == "audio") {
			//var myController = this._parent._parent;
			var videoPlayer = jbObj.associatedPlayer;
			//myTrace("click pause, pass to " + videoPlayer);
			videoPlayer.pause();
		}
	}
	controls.jbStartAgain.onRelease = function() {
		// v6.4.3 Audio streams by default
		//if (jbObj.mediaType == "audio") {
		if (jbObj.mediaType == "staticAudio") {
	//	trace(this._name);
			var s = this._parent._parent.myJukeBox.s;
			s.stop();
			s.start(0,1);
			jbObj.at = 0;
		} else if (jbObj.mediaType == "animation" || jbObj.mediaType == "flashAudio") {
			jbObj.at = 1;
			//controls._parent.mediaHolder.stop();		
			//controls._parent.mediaHolder.gotoAndPlay(jbObj.at);
			if (jbObj.targetType == "drag") {
				var content = controls._parent.mediaPane.getScrollContent();
			} else if (jbObj.targetType == "external") {
				var content = jbObj.myTarget;
			} else {
				var content = controls._parent.mediaHolder;
			}
			content.gotoAndPlay(jbObj.at);
			//trace("now at " + controls._parent.mediaHolder._currentframe);
		//v6.4.1 Add video
		// v6.4.3 Audio streams by default
		} else if (jbObj.mediaType == "video" || jbObj.mediaType == "streamingAudio" || jbObj.mediaType == "audio") {
			//var myController = this._parent._parent;
			//myTrace("click start again, pass to " + jbObj.associatedPlayer);
			var videoPlayer = jbObj.associatedPlayer;
			videoPlayer.play(0);
		}
	}
	controls.jbRewind.onRelease = function() {
			//	trace(this._name+" at "+_root.s.position);
		// v6.4.3 Audio streams by default
		//if (jbObj.mediaType == "audio") {
		if (jbObj.mediaType == "staticAudio") {
			var s = this._parent._parent.myJukeBox.s;
			jbObj.at = s.position;
			jbObj.at = jbObj.at - 3000; // go back 3 seconds
			if (jbObj.at<0) {jbObj.at = 0};
			s.stop();
			s.start(Number(jbObj.at/1000),1);
		} else if (jbObj.mediaType == "animation" || jbObj.mediaType == "flashAudio") {
			if (jbObj.targetType == "drag") {
				var content = controls._parent.mediaPane.getScrollContent();
			} else if (jbObj.targetType == "external") {
				var content = jbObj.myTarget;
			} else {
				var content = controls._parent.mediaHolder;
			}
			jbObj.at = content._currentframe;
			//jbObj.at = controls._parent.mediaHolder._currentframe;
			jbObj.at = jbObj.at - 36; // go back 3 seconds
			if (jbObj.at<0) {jbObj.at = 1};
			//controls._parent.mediaHolder.gotoAndPlay(jbObj.at);
			content.gotoAndPlay(jbObj.at);
		//v6.4.1 Add video
		// v6.4.3 Audio streams by default
		} else if (jbObj.mediaType == "video" || jbObj.mediaType == "streamingAudio" || jbObj.mediaType == "audio") {
			//var myController = this._parent._parent;
			var videoPlayer = jbObj.associatedPlayer;
			//var atNow = videoPlayer.playheadTime - 3;
			//if (atNow<0) atNow = 0;
			//myTrace("rewind from " + videoPlayer.playheadTime + "to " + atNow);
			//videoPlayer.play(atNow); // rewind 3 seconds
			videoPlayer.play(-3); // rewind 3 seconds
		}
	}
	// functions for the handmade slider. Don't use the regular changeHandler
	// as we are moving the slider from the video anyway. How about onRelease?
	//jbSlider.setChangeHandler("onChange", this);
	controls.jbSlider.onStartChangeEvent = function() {
		var myController = this._parent._parent;
		var videoPlayer = jbObj.associatedPlayer;
		//myTrace("start drag"); // at " + this.getValue() + " send to " + videoPlayer);
		if (videoPlayer.isPlaying()) {
			this.wasPlaying = true;
		} else {
			this.wasPlaying = false;
		}
		videoPlayer.pause();
		// enable the regular change event
		this.setChangeHandler("onChange", this);
	}
	controls.jbSlider.onStopChangeEvent = function() {
		//myTrace("slider max=" + this.getMaxValue());
		var fromHere = this.getValue();
		var myController = this._parent._parent;
		var videoPlayer = jbObj.associatedPlayer;
		//myTrace("stop drag at " + fromHere + " send to " + videoPlayer);
		if (this.wasPlaying) {
			//myTrace("playing so restart from " + fromHere);
			videoPlayer.play(fromHere)
		} else {
			//myTrace("paused, so gotoAndStop " + fromHere);
			//jukeboxPlayer.playheadTime = fromHere;
			videoPlayer.gotoAndStop(fromHere);
		}
		// disable the regular change event
		this.setChangeHandler(undefined);
	}
	controls.jbSlider.onChange = function() {
		//myTrace("change playhead");
		var myController = this._parent._parent;
		var videoPlayer = jbObj.associatedPlayer;
		//jukeboxPlayer.playheadTime = this.getValue();
		videoPlayer.gotoAndStop(this.getValue());
	}
	// an event triggered by videoPlayer, back to it's parent and onto here
	this.onPlaying = function(at) {
		//var jukeboxPlayer = this.associatedPlayer;
		//myTrace("onPlaying at " + at);
		this.interface.controls.jbSlider.setValue(at);
	}
	//v6.4.1.4 Function to update slider limits once you know them
	// Not actually used at the moment.
	this.setSliderDuration = function(duration) {
		//myTrace("update slider from 0 to " + duration);
		this.interface.controls.jbSlider.setSliderProperties(0, duration);
	}

	// v6.4.1 Custom events from the slider
	controls.jbSlider.setStartChangeEvent(controls.jbSlider.onStartChangeEvent);
	controls.jbSlider.setStopChangeEvent(controls.jbSlider.onStopChangeEvent);	
}
//
// Note
// There is still other code in jukeBox.fla in the mediaHolder mc
/*
onClipEvent (data) {
	myTrace("in mediaHolder onClipEvent(data)");
	//trace("media loaded");
	var jbObj = this._parent.myJukeBox._JB;
	//trace("loaded media and requested width=" + jbObj.myWidth);
	//trace("scale=" + this._xscale + " current width=" + this._width);
	if (jbObj.myWidth > 0) {
		this._width = jbObj.myWidth;
	}
	if (jbObj.myHeight > 0) {
		this._height = jbObj.myHeight;
	}
	//v6.4.1 Add video
	//if (jbObj.mediaType == "animation" || jbObj.mediaType == "flashAudio") {
	if (jbObj.mediaType == "animation" || 
		jbObj.mediaType == "video" || 
		jbObj.mediaType == "flashAudio") {
		if (jbObj.myAutoPlay) { 
			this.play();
		} else {
			this.stop();
			this._currentframe = 0;
		}
	} 
}
*/
// And in the progress function
/*
var startLoadTime;
setProgressBar = function(progressTarget, statusTxt) {
	//this.loadProgress.removeMovieClip();
	//this.errorMsg.removeTextField();
	//var bar = this.attachMovie("progressBar", "loadProgress", jukeboxNS.depth++);
	//this.createTextField("errorMsg", jukeboxNS.depth++, 92, 0, 120, Number(this.loadStatus._height));
	//startLoadTime = getTimer();
	setPercentage = function(value) {
		if (value > 100) value=100;
		if (value < 0) value=0;
		//trace("setting % at " + value);
		loadProgress.pc.text = value + "%";
		loadProgress.fill._xscale = value;
	}
	incPercentage = function(value) {
		var total = loadProgress.fill._xscale + value;
		if (total > 100) total=100;
		if (total < 0) total=0;
		loadProgress.fill._xscale = total;
		loadProgress.pc.text = total + "%";
	}
	loadProgress.onEnterFrame = function(){
		if(progressTarget.getBytesLoaded() < progressTarget.getBytesTotal()) {
			setPercentage(Math.round(100 * (progressTarget.getBytesLoaded() / progressTarget.getBytesTotal())));
		} else if(progressTarget.getBytesLoaded() == progressTarget.getBytesTotal()){
			setPercentage(100);
			removeProgressBar();
			//myTrace("show=" + controls);
			controls._visible = true;
			//this.removeMovieClip();
		//} else if(progressTarget.getBytesTotal() == -1 || progressTarget.getBytesTotal() == undefined) {
		//	if(getTimer() - startLoadTime > 5000) {
		//		this._parent.createTextField("errorMsg", jukeboxNS.depth++, -15, -3, 120, Number(this.loadStatus._height));
		//		this._parent.errorMsg.multiline = true;
		//		this._parent.errorMsg.wordWrap = true;
		//		this._parent.errorMsg.border = false;
		//		this._parent.errorMsg.autoSize = true;
		//		this._parent.errorMsg.selectable = false;
		//		myformat = new TextFormat();
		//		myformat.color = 0x000066;
		//		myformat.font = "Verdana";
		//		myformat.size = 11;
		//		myformat.align = "center";
		//		var filename = _root.objectHolder.findReplace(jbURL, "\\", "/");
		//		var arr = filename.split("/");
		//		filename = arr[arr.length - 1];
		//		this._parent.errorMsg.text = "cannot load media";
		//		this._parent.errorMsg.setTextFormat(myformat);
		//		this._parent.myJukeBox.interface.controls._visible = false;
		//		this.removeMovieClip();
		//		//this.loadStatus.text = "cannot load media";
		//		//delete this.onEnterFrame;
		//	}
		}
	}
	// v6.3.4 Try putting the caption over the top of the bar?
	//loadProgress._x = 155;
	//loadProgress._y = 8;
	//myTrace("hide=" + controls);
	// do you want to see the status OR the % ?
	loadprogress.loadStatus._visible = false;
	//loadprogress.pc._visible = false;
	controls._visible = false;
	
	if(statusTxt != undefined) {
		loadProgress.loadStatus.text = statusTxt;
	}
	setPercentage(0);
	loadProgress._visible = true;
	errorMsg._visible = false;
}
removeProgressBar = function() {
	//this.loadProgress.removeMovieClip();
	loadProgress._visible = false;
	delete loadProgress.onEnterFrame;
}
setProgressErrorMsg = function(message) {
	//this.errorMsg.multiline = false;
	//this.errorMsg.wordWrap = false;
	//this.errorMsg.border = false;
	//this.errorMsg.autoSize = true;
	//this.errorMsg.selectable = false;
	myformat = new TextFormat();
	myformat.color = 0x000066;
	myformat.font = "Verdana";
	myformat.size = 10;
	myformat.align = "center";
	myTrace("setProgressErrorMsg for " + message);
	if(message != undefined) {
		this.errorMsg.text = message;
	}
	// v6.3.5 The default error text (for fail to load) is set in screen.as
	//this.errorMsg.setTextFormat(myformat);
	errorMsg._visible = true;
}
removeProgressErrorMsg = function() {
	errorMsg._visible = false;
}
//picture.loadMovie(jbURL);
//stop();
*/