// v6.4.3 Since any movies published for different Flash players will not share the same
//_global space, I need to pass this object through to them.
if (_global.ORCHID == undefined) {
	_global.ORCHID = this._parent.sharedGlobal;
} 
// You need this for tracing - it isn't passed from loading module
//#include "d:/workbench/myTrace.as"

// This mediaHolder is used for swf animations, code for flv is at the top level
// on a frame. They are very similar.

//v6.4.2 Move to same loading technique as other swf - like jukebox
/*
var videoNS = new Object();
videoNS.moduleName = "videoModule";
videoNS.depth = 1;
videoNS.initialise = function () {
	_root.controlNS.remoteOnData(this.moduleName, true); // this is a key module
};
videoNS.initialise();
*/
// First create the player and controller
// The main reason for dynamic creation is to get them at the right size.
// If you simply alter the size of a preset control, it does not work
// as you expect.
this.depth=0;
this.margin=0;
// multi-player version
//this.players = new Array();

// function to load up the video
this.setMedia = function(videoObj) {
	// v6.4.3 See below for why you are now creating the jukeboxListener here. Not any more.
	//this.newJukeboxListener();
	
	myTrace("videoPlayer:setMedia " + videoObj.jbURL + " type=" + videoObj.jbMediaType);
	// Create the control for the media and size it and set listener events
	createPlayer(videoObj);

	// this is what you have just created
	var jukeboxPlayer = this[videoObj.jbID].jukeboxPlayer;
	
	// save information about the media Object
	this[videoObj.jbID].id = videoObj.jbID;
	this[videoObj.jbID].autoPlay = videoObj.jbAutoPlay;
	// v6.4.2.6 AR Note that this is NOT the correct meaning of stretch. True means that you must follow the width and height
	// irrespective of aspect ratio. False means that you make the video as big as possible within the width and height whilst
	// keeping aspect ratio. If no width and height then use autosize=true.
	// I have pasted the code from resizing images at the bottom for your reference.
	// So, no width means autosize=true. For now this is enough as aspect ratio is kept automatically.
	// Stretch=true is ignored - and width is more important than height
	//this[videoObj.jbID].autoSize = !videoObj.jbStretch;
	if (videoObj.jbWidth==undefined || videoObj.jbWidth<=0) {
		myTrace("no video.width");
		this[videoObj.jbID].autoSize = true;
	} else {
		myTrace("got video.width=" + videoObj.jbWidth);
		this[videoObj.jbID].autoSize = false;
	}
	this[videoObj.jbID].anchor = videoObj.jbAnchor;
	this[videoObj.jbID].mediaType = videoObj.jbType;
	// Save the media type from the XML as well as the type based on the file extension.
	this[videoObj.jbID].requestedMediaType = videoObj.jbMediaType;
	this[videoObj.jbID].duration = videoObj.jbDuration;
	// copy functions from the parent - pretty poor way of doing things
	this[videoObj.jbID].setEnabled = this.setEnabled;
	this[videoObj.jbID].play = this.play;
	this[videoObj.jbID].pause = this.pause;
	this[videoObj.jbID].stop = this.stop;
	this[videoObj.jbID].rewind = this.rewind;
	this[videoObj.jbID].startAgain = this.startAgain;
	this[videoObj.jbID].gotoAndStop = this.gotoAndStop;
	this[videoObj.jbID].getPlayHead = this.getPlayHead;
	this[videoObj.jbID].isPlaying = this.isPlaying;
	this[videoObj.jbID].magnify = this.magnify;
	this[videoObj.jbID].setSize = this.setSize;
	
	// v6.4.2.5 Can I treat an fls just like an MP3?
	//if (videoObj.jbType.toUpperCase() == "FLV" || videoObj.jbType.toUpperCase() == "MP3") {
	if (videoObj.jbType.toUpperCase() == "FLV" || videoObj.jbType.toUpperCase() == "MP3" || videoObj.jbType.toUpperCase() == "FLS") {
		//videoObj.jbURL = "Content\\drew.flv";
		//v6.4.1.5 using URL like this does not seem to work for network version
		// So how about adding in the full path. It might be better to do it in
		// the calling program as you have access to _global.ORCHID there
		//if (_root.mdm_appdir != undefined) {
		//	videoObj.jbURL = _root.mdm_appdir + videoObj.jbURL;
		//}
		//myTrace("videoPlayer:setMedia:flv set url=" + videoObj.jbURL);
		//myTrace("vp=" + jukeboxPlayer);
		jukeboxPlayer.setMedia(videoObj.jbURL, videoObj.jbType);
		// The load method appears not to do anything.
		//jukeboxPlayer.load(videoObj.jbURL); //, videoObj.jbType);
		// v6.4.2.4 Need this to REALLY stop any audio spilling out from a non-autoplay video
		// but if you do it for audio you never start!
		// v6.4.2.4 If you are running in MDM and you have ..\ in your content folder, trying to load a .flv file will fail. It will
		// generate one progress event call (load 0 of -1) and stop. But streaming MP3 is fine. Likewise, if you are on a webserver
		// and your programs are under and different root than your content.
		// This is clearly something to do with the Flash 8 security sandbox.
		// Temporarily I will try to avoid .. in network version and hope that cross domain stuff doesn't happen on server, but it needs to be solved.
		if (videoObj.jbType == "FLV" && videoObj.requestedMediaType.indexOf("video")>=0) jukeboxPlayer.stop();
		//myTrace("jbPlayer=" + jukeboxPlayer);
		// v6.4.2.4 For autoplay audio, we need to see the streamer, so set it to be on here?
		// v6.4.2.5 Can I treat an fls just like an MP3?
		//if (videoObj.jbType == "MP3" && videoObj.jbX == undefined) {
		if ((videoObj.jbType == "MP3" || videoObj.jbType == "FLS") && videoObj.jbX == undefined) {
			this._x = 25;
			this._y = 25;
		}
		//myTrace("vP.as.this._x=" + this._x);
	} else {
		//myTrace("load video swf " + videoObj.jbURL);
		// I need to save the starting stuff (specially dims) as I can't
		// keep in jukeboxPlayer as it will get overloaded.
		// v6.4.2.4 WIth jpgs, react to the new video code
		// this.videoObj = videoObj;
		myTrace("loadNonVideo " + videoObj.jbType + " to " + jukeboxPlayer);
		// v6.4.2.4 use the same mediaHolder as buttons (but with modified onClipEvent)
		//jukeboxPlayer.loadMovie(videoObj.jbURL);
			// v6.4.2.4 Copied from buttons - since already included, need a function wrapper
			// (display.as loads this dynamically)
			jukeboxPlayer.loadNonVideo = function(me) {
				//_global.myTrace("loadNonVideo for jbULR=" + me.jbURL);
				this.fileExists = new LoadVars();
				//this.fileExists._parent = this;
				this.fileExists.master = this;
				// onLoad requires some parsing, onData doesn't, so that will help effeciency
				//fileExists.onLoad = function(success) {
				//	if (success) {
				this.fileExists.onData = function(src) {
				//success is true if the file exists, false if it doesnt
					if (src != undefined) {
						//the file exists
						// v6.4 Flash 8 beta throws up an error at this line.
						//myTrace("mediaHolder.loaded picture");
						this.master.picture.loadMovie(me.jbURL); //and load our picture into it
						
						//myTrace(jbURL + " exists so load into " + this._parent.picture);
						this.master.loadProgress.removeMovieClip();
					} else {
						//this._parent.createTextField("errorMsg", 2, Number(me.jbX), Number(me.jbY), Number(me.jbWidth), Number(me.jbHeight));
						this.master.createTextField("errorMsg", 2, 10, 10, 200, 60);
						this.master.errorMsg.multiline = true;
						this.master.errorMsg.wordWrap = true;
						this.master.errorMsg.border = false;
						//this._parent.errorMsg.autoSize = true;
						this.master.errorMsg.selectable = false;
						myformat = new TextFormat();
						myformat.color = 0x000066;
						myformat.font = "Verdana";
						myformat.size = 10;
						myformat.align = "left";
						var filename = _global.ORCHID.root.objectHolder.findReplace(me.jbURL, "\\", "/");
						var arr = filename.split("/");
						filename = arr[arr.length - 1];
						//this._parent.errorMsg.text = "cannot load " + filename;
						this.master.errorMsg.text = _global.ORCHID.root.objectHolder.findReplace(_global.ORCHID.literalModelObj.getLiteral("loadFail", "labels"), "[x]", filename);
						this.master.errorMsg.setTextFormat(myformat);
						this.master.loadProgress.removeMovieClip();
						// v6.4.2.4 But you need to send information to the parent for onResize otherwise nothing will be shown for the PUW
						//myTrace("error msg, send resize to " + this.master._parent);
						//this.master._parent.onResize({width:200, height:60}, "perfect");
						this.master._parent.onFinishedLoading();
					}
				}
				//myTrace("in mediaHolder: try to load " + me.jbURL);
				//Flash8 testing
				this.fileExists.load(me.jbURL); //initiate the test
				
				// v6.4.2.4 You can attach the progress bar, but until you send onResize, the PUW will be hidden
				// Whilst this appears to work perfectly after the error msg above, it doesn't work here at all. The target seems to be the same.
				//myTrace("progress, send resize to =" + this._parent);
				this._parent.onResize({width:200, height:100}, "original");
				
				this.attachMovie("progressBar", "loadProgress", 1);
				//myTrace("attached progressBar=" + this.loadProgress);
				this.loadProgress.setPercentage = function(value) {
					if (value > 100) value = 100;
					if (value < 0) value = 0;
					//myTrace("setting % at " + value);
					this.pc.text = value + "%";
					this.fill._xscale = value;
				}
				this.loadProgress.incPercentage = function(value) {
					var total = bar.fill._xscale + value;
					if (total > 100) total=100;
					if (total < 0) total=0;
					this.fill._xscale = total;
					this.pc.text = total + "%";
				}
				this.loadProgress.onEnterFrame = function(){
					var bytesLoaded = this._parent.fileExists.getBytesLoaded();
					var bytesTotal = this._parent.fileExists.getBytesTotal();
					//myTrace("oEF: bytesLoaded=" + bytesLoaded + " of " + bytesTotal + " width=" + this._parent.picture._width);
					if (bytesLoaded < bytesTotal) {
						this.setPercentage(Math.round(100 * bytesLoaded / bytesTotal));
					} else if(bytesLoaded >= bytesTotal && bytesTotal>32){
						this.setPercentage(100);
					}
				}
				//loadProgress.loadStatus.text = "loading picture...";
				this.loadProgress.loadStatus.text = _global.ORCHID.literalModelObj.getLiteral("loadingPicture", "labels");
				this.loadProgress._x = 10;
				this.loadProgress._y = 10;
				var startLoadTime = getTimer();
				this.loadProgress.setPercentage(0);				
			}
		jukeboxPlayer.loadNonVideo(videoObj);
		
	}
	//jukeboxPlayer.duration = videoObj.jbDuration;
	//jukeboxPlayer._parent.onOriginalSize();
	//this.jukeboxPlayer._width = videoObj.jbWidth;
	//this.jukeboxPlayer._height = videoObj.jbHeight;
	//jukeboxController.setSliderProperties(0,videoObj.jbDuration);
	//jbSlider.checkPlayheadInt = setInterval(jbSlider, "checkPlayhead", 1000);
	//myTrace("streamer width=" + videoObj.jbWidth);
	// v6.4.2.5 You might want to supress the streaming bar sometimes (most likely for question based audio)
	myTrace("xsetMedia.streamingLabel=" + videoObj.streamingLabel + " type=" + videoObj.jbType);
	// v6.4.2.5 Or if you are using fls files which don't stream
	//if (videoObj.streamingLabel == undefined) {
	if (videoObj.streamingLabel == undefined || videoObj.jbType == "FLS") {
		jbStreamer._visible = false;
	} else {
		jbStreamer._visible = true;
		jbStreamer.setLabel(videoObj.streamingLabel);
		// This width might be zero for floating	
		jbStreamer.setWidth((videoObj.jbWidth <= 0) ? 100: videoObj.jbWidth);
	}
}

// This function makes an empty movieClip for the media and loads a component into it
this.createPlayer = function(videoObj) {
	//myTrace("createPlayer for " + videoObj.jbID);
	// multi check to see if this player already exists
	if (this[videoObj.jbID] != undefined) {
		myTrace("a player for this mediaID already exists")
		return;
	} else {
		//myTrace("first time, create a new player");
	}

	//thisPlayer.videoType = videoObj.jbType;
	//thisPlayer.autoPlay = videoObj.jbAutoPlay;
	
	if (Number(videoObj.jbWidth) <= 0 || Number(videoObj.jbHeight) <= 0) {
		var thisWidth = 100;
		var thisHeight =100;
		var thisAutosize = true;
		//myTrace("based on no size given, autoSize=" + thisAutosize);
	} else {
		var thisWidth = Number(videoObj.jbWidth);
		var thisHeight = Number(videoObj.jbHeight);
	}
	// these should be on the parent, not directly on component
	//thisVideo.anchor = videoObj.jbAnchor;
	if (thisAutosize) {
		this[videoObj.jbID].autoSize = true
	}
	//myTrace("videoPlayer:jbWidth=" + Number(videoObj.jbWidth)+this.margin);
	// v6.4.1.4 Play animations as well. 
	// Based on type or ext, have condition to make jukeboxPlayer a simple mc
	// instead of the mediaDisplay component.
	// To try and cope with multiplayers, I added an extra layer. But this screws up rest of _parent stuff (shows you shouldn't do it!)
	// and since I am not doing multiplayers anymore, no point. But coded, so have to leave
	var thisVideo = this.createEmptyMovieClip(videoObj.jbID, this.depth++);
	// v6.4.3 I am not able to autoplay a second audio, try splitting this code. No, has no impact
	// Due to clearMedia in jukebox. Not sure why.
	// v6.4.2.5 Can I treat an fls just like an MP3?
	//if (videoObj.jbType== "FLV" || videoObj.jbType == "MP3") {
	if (videoObj.jbType== "FLV" || videoObj.jbType == "MP3" || videoObj.jbType == "FLS" ) {
		//myTrace("streaming, width=" + thisWidth + ", x=" + videoObj.jbX);
		// v6.4.2.4 Why not set autoPlay to the desired value?
		// v6.4.2.4 For video, I do not get preferredWidth as soon as I would like, and the audio starts before I see the screen.
		// So it might be smoother to not autoplay, but to start after 0.5 seconds. But with autoPlay=false, I also get 0.8 seconds of audio
		// before it stops itself!
		//var thisVideo = this;
		thisVideo.createClassObject(mx.controls.MediaDisplay, "jukeboxPlayer", 1, 
							//{_x:videoObj.jbX, _y:videoObj.jbY, width:thisWidth+this.margin, height:thisHeight+this.margin, 
							{_x:0, _y:0, width:thisWidth, height:thisHeight, 
							autoPlay:false, autoSize:false, aspectRatio:true,
							//autoPlay:videoObj.jbAutoPlay, autoSize:false, aspectRatio:true,
							// not sure if you can set this here or not. LiveDocs say read-only at run time but use during configuration
							mediaType:videoObj.jbType,
							//id:videoObj.jbID, // to make it easy to reference - put on parent
							duration:5, // some kind of default, waiting to be overwritten
							visible:false
							});
		//myTrace("created vp=" + jukeboxPlayer);
	} else {
		//myTrace("create mc for a swf, width=" + thisWidth);
		//var jukeboxPlayer = this.mediaHolder; 
		thisVideo.jukeboxPlayer = this.mediaHolder; 
		myTrace("jpg holder=" + thisVideo.jukeboxPlayer); // + " from mediaHolder=" + this.mediaHolder);
		//thisVideo.attachMovie("mediaHolder", "jukeboxPlayer", 1);
		//jukeboxPlayer._width = thisWidth;
		//jukeboxPlayer._height = thisHeight;
	}
	var jukeboxPlayer = thisVideo.jukeboxPlayer;
	// v6.5.5.3 see if you can use your own controller for video - but NOT for streaming audio
	if (videoObj.jbType== "FLVx") {
		myTrace("6.5.5.3 adding controller");
		createClassObject(mx.controls.MediaController, "jukeboxController", this.depth++, 
						  {_x:0, _y:videoObj.jbHeight, _width:videoObj.jbWidth, _height:10,
						  backgroundStyle:"none", activePlayControl:"play"}); 
		jukeboxPlayer.associateController(jukeboxController);
	}
	// Now see if the controller can be in the harness
	//this.jukeboxController = this.jbSlider;
	//jukeboxPlayer.visible = false;
	//jukeboxController.visible = false;
	// v6.4.2.5 Can I treat an fls just like an MP3?
	//if (videoObj.jbType== "FLV" || videoObj.jbType == "MP3") {
	// v6.5.5.3 If you have your own controller, no need for the events to tell anything to the common one
	if (videoObj.jbType == "MP3" || videoObj.jbType == "FLS" ) {
		jukeboxPlayer.addEventListener("progress", myJukeboxListener);
		jukeboxPlayer.addEventListener("complete", myJukeboxListener);
		jukeboxPlayer.addEventListener("change", myJukeboxListener);
		// v6.4.2.4 New events
		jukeboxPlayer.addEventListener("start", myJukeboxListener);
		jukeboxPlayer.addEventListener("resizeVideo", myJukeboxListener);
		// This one doesn't seem to be triggered, and it works very well inside progress anyway
		//jukeboxPlayer.addEventListener("totalTimeUpdated", myJukeboxListener);
	} else if (videoObj.jbType== "FLV") {
		// use these during debugging
		jukeboxPlayer.addEventListener("progress", myJukeboxListener);
		jukeboxPlayer.addEventListener("complete", myJukeboxListener);
		jukeboxPlayer.addEventListener("change", myJukeboxListener);
		// v6.4.2.4 New events
		jukeboxPlayer.addEventListener("start", myJukeboxListener);
		// v6.5.5.3 Except perhaps the resize one?
		jukeboxPlayer.addEventListener("resizeVideo", myJukeboxListener);
	} else {
		//jukeboxPlayer.onData = myJukeboxListener.onData;
	}
	//v6.4.1.4 These are the size that the xml would like to show the video
	// at. But if the actual video is different, we will modify these later
	// so that the component matches the actual size, whilst not getting
	// outside the desired outline.
	// For swf, you will lose this info when you load the mc, unless
	// you put the movie in a lower layer to protect this lot?
	// Actually, could probably just put all this on this and this shove
	// it to jukeboxPlayer once it is safe
	if (videoObj.jbType == "FLV") {
		thisVideo.originalWidth = Number(thisWidth);
		thisVideo.originalHeight = Number(thisHeight);
		if (videoObj.jbHeight > 0) {
			thisVideo.originalRatio = thisWidth / thisHeight;
		} else {
			thisVideo.originalRatio = 1;
		}
		//jukeboxPlayer.autoPlay = videoObj.jbAutoPlay;
	// v6.4.2.5 Can I treat an fls just like an MP3?
	//} else if (videoObj.jbType == "MP3") {
	} else if (videoObj.jbType == "MP3" || videoObj.jbType == "FLS") {
		thisVideo.originalWidth = 0;
		thisVideo.originalHeight = 0;
		thisVideo.originalRatio = 1;
		//jukeboxPlayer.autoPlay = videoObj.jbAutoPlay;
	} else {
		// temporarily store in this rather than jukeboxPlayer
		this.originalWidth = Number(thisWidth);
		this.originalHeight = Number(thisHeight);
		this.anchor = videoObj.jbAnchor;
		if (thisAutosize) {
			myTrace("set " + this + ".autoSize=" + this.autoSize);
			this.autoSize = true
		}
		this.autoPlay = videoObj.jbAutoPlay;
		//myTrace("temp: anchor=" + this.anchor);
	}
	// set the built in type?
	//if (this.videoType == "FLV" || this.videoType == "MP3") {
	//	jukeboxPlayer.mediaType = this.videoType;
	//}
	//myTrace("video.autoPlay=" + jukeboxPlayer.autoPlay);
	// multi - acknowledge that a player has been created for this media
	this[videoObj.jbID].loaded = true;
	
}

// v6.4.3 All this code used to be on the root for this code, so only loaded once per videoPlayer.swf. Could this be why autoPlay
// only works once? Try putting it into a function you can call from setMedia. It is not the reason, but seems better to do this here anyway.
// Except what will happen then to multiplayers on a screen? Go back to the original since that worked.
//this.newJukeboxListener = function() {
	//myTrace("new jukeboxListener");
	///this.myJukeboxListener = new Object();
	var myJukeboxListener = new Object();
	myJukeboxListener.firstTime = true;
	// v6.4.1.4 What are the equivalent events for a Flash animation?
	// progress would be onData - but needs to be a clipEvent, so see mediaHolder mc
	// change would be onEnterFrame - but this would have to killed if not playing
	// complete would be part of onEnterFrame
	// Note: I guess that the MovieClipLoader component might be better for this
	// purpose than a simple mc with onClipEvent embedded in it.
	myJukeboxListener.progress = function(eventObject){ 
		//myTrace("**autoplay=" + eventObject.target.autoPlay);
		myTrace(eventObject.target._parent.id + ":" + eventObject.target.bytesLoaded + " of " + eventObject.target.bytesTotal); // + ", streamer=" + eventObject.target._parent.jbStreamer);
	
		// You will not know an accurate total time immediately, but it will be close. In fact, it will continually fluctuate fractionally.
		// So read it and continually update the slider until it settles. Then wait until fully loaded for final result.
		// And video converted with earlier Flash doesn't have this a readable, it has to set by author
		if (eventObject.target.totalTime > 0) {
			//myTrace("currentTotal=" + eventObject.target.totalTime + " existingTotal=" + eventObject.target.duration);
			var estimatedDuration = Math.floor(eventObject.target.totalTime);
			// Are you 5% bigger than last time? If not, not worth updating.
			if (estimatedDuration > (eventObject.target.duration*1.05)) {
				eventObject.target.duration = estimatedDuration;
				// v6.4.2.4 With multiplayers, _parent goes up one!
				eventObject.target._parent._parent.onInformation({id:eventObject.target._parent.id, duration:eventObject.target.duration});
					// is it worth sending back any width/height info here? Probably not.
														//width:eventObject.target.actualWidth,
														//height:eventObject.target.actualHeight});
			}
		}
		
		// tell the handmade streamer how far you have got
		eventObject.target._parent._parent.jbStreamer.setProgress(100*eventObject.target.bytesLoaded/eventObject.target.bytesTotal);
	
		// v6.4.2.4 I think the other checking should go first in case you are loading very quickly! So new order will be to see
		// if preferred width is set - then do the if complete and NO preferred width stuff.
		
		// send an event, just once, as soon as you know sizes
		//if (eventObject.target.bytesLoaded > 4 && this.firstTime) {
		// the problem is that this still can have preferredWidth set to zero
		// even after a huge chunk of download. So how about waiting for this to
		// be something interesting? Then if it never gets set you will have
		// to default to something moderate.
		//if (eventObject.target.bytesLoaded > 1024 && this.firstTime) {
		// v6.4.2.4 Try doing all preferred width stuff once you have got enough buffered to start
		//if (eventObject.target.preferredWidth > 0 && this.firstTime) {
		//	myTrace("got preferred width=" + eventObject.target.preferredWidth);
		//	this.firstTime = false;
		//	this.doPreferredWidthResizing(eventObject);
		//}
		// send an event up to the parent once fully loaded
		// v6.4.1.5 You sometimes get the resize sent up with a 0 width
		// Is it because you need more than 4 bytes to detect the width?
		// And is this caused in any way by Speedera caching?
		// Perhaps not as it seems to be happening with network version too.
		if (eventObject.target.bytesLoaded >= eventObject.target.bytesTotal &&
			//eventObject.target.bytesLoaded > 4) {
			eventObject.target.bytesLoaded > 1024) {
			// Update the final duration
			if (eventObject.target.totalTime > 0) {
				eventObject.target.duration = Math.floor(eventObject.target.totalTime);
			} else if (eventObject.target._parent.duration > 0) {
				// Can't get duration from the video/mp3 itself, so use the authored timing
				eventObject.target.duration = eventObject.target._parent.duration;
			} else {
				// Even that wasn't set. So assume it lasts 1 minute!
				eventObject.target.duration = 60;
			}			
			eventObject.target._parent._parent.onInformation({id:eventObject.target._parent.id, duration:eventObject.target.duration});
			// There is a chance that you will finish loading without having
			// triggered sizing events. So do it now unless preferred width is OK
			// in which case let the code run through to do first time next (the order
			// don't matter)
			/*
			if (eventObject.target.mediaType == "MP3") {
				var vidWidth = 0;
				var vidHeight = 0;
			} else if (this.firstTime && eventObject.target.preferredWidth <= 0) {
				myTrace("didn't get preferred width whilst loading");
				// Can I trigger this in a little while then? Will it help?
				var setTimeOutID = _global['setTimeout'](this, 'doPreferredWidthResizing', 500, eventObject);
				//myTrace("made timeout " + setTimeOutID);
				//var vidWidth = eventObject.target.originalWidth;
				//var vidHeight = eventObject.target.originalHeight;
				//eventObject.target._parent.onResize({width:vidWidth, height:vidHeight}, "perfect");
				//eventObject.target._parent.onInformation({width:vidWidth,
				//										height:vidHeight});
			} else if (this.firstTime && eventObject.target.preferredWidth > 0) {
				// so I now have preferredWidth, but have not done any resizing.
				this.doPreferredWidthResizing(eventObject);
			} else {
				var vidWidth = eventObject.target.actualWidth
				var vidHeight = eventObject.target.actualHeight;
			}
			// don't do any more since we don't know the size for some reason - or don't care
			//this.sizeAlreadySet = true;
			//eventObject.target._parent.onInformation({width:vidWidth,
			//										height:vidHeight,
			//										duration:eventObject.target.duration,
			//										autosize:eventObject.target.jbAutosize});
			*/
			eventObject.target._parent._parent.onFinishedLoading();
			//this.jukebox.removeEventListener("progress", myJukeboxListener);
			//trace("remove progEventListener from " + eventObject.target);
			eventObject.target.removeEventListener("progress", this);
			// update the streamer (in case you are very quick!)
			//eventObject.target._parent.jbStreamer.setProgress(100);	
			//eventObject.target._parent.jbStreamer.setLabel();
			// or rather remove it once the streaming is finished
			// v6.4.2.4 comment out so you can see where it is even for very quick streaming
			// Or perhaps fade out after a second so that you can apprecite the speed!!
			//eventObject.target._parent._parent.jbStreamer._visible = false;
			eventObject.target._parent._parent.jbStreamer.disappearEffect();
			// v6.4.3 I also seem to get problems with Start being triggered for MP3 - although the first run one always works
			// so it must be something I am not initialising properly. jukebox.clearMedia
			// v6.4.2.4 For video with only an audio track, the Start event is not triggered reliably.
			// So if you get to here, at least make sure that something is playing. But this is crap, defeats purpose of streaming!
			// OK. If you make the flv in Squeeze with a .mov of the right length, and then attach the audio .wav to it, it works fine.
			//this.start(eventObject);
		}
	}
	myJukeboxListener.complete = function(eventObject){ 
		// send an event up to the parent once the playhead finishes
		// NOTE this is not being called for the second video embedded on a screen.
		myTrace(eventObject.target._parent.id + ":complete");
		eventObject.target._parent._parent.onFinishedPlaying();
	}
	myJukeboxListener.change = function(eventObject){ 
		// send an event up to the parent if the video is playing
		//myTrace("video.change." + eventObject.target.playheadTime);
		eventObject.target._parent._parent.onPlaying(eventObject.target.playheadTime);
	}
	// v6.4.2.4 The video is buffered enough to start
	// v6.4.3 But with audio, this is only triggered for the first autoPlay exercise. After that it never triggers.
	// due to jukebox.clearMedia
	myJukeboxListener.start = function(eventObject){ 
		//myTrace("target.parent=" + eventObject.target._parent);
		// v6.4.3 If i build some extra ways to start this, make sure you are not already playing
		//if (eventObject.target.playing) return;
		myTrace("ready to start " + eventObject.target._parent.id + ", if autoPlay=" + eventObject.target._parent._parent.autoPlay); // + ", _p.x=" + eventObject.target._parent._x + ", .x=" + eventObject.target._x);
		// v6.4.2.4 Try doing all preferred width stuff once you have got enough buffered to start
		if (eventObject.target._parent._parent.autoPlay) {
			//eventObject.target._parent.stopOtherVideos();
			eventObject.target.play();
		}
		// adding this here just to test if it will now appear for audio
		//eventObject.target._parent.setEnabled(true);
	}
	// v6.4.2.4 The video is resized. But I need it to trigger before 'start', does it?
	myJukeboxListener.resizeVideo = function(eventObject){ 
		// mediaDisplay.videoWidth is NOT reliable
		//myTrace("resize, preferred=" + eventObject.target.preferredWidth + " from xml=" + eventObject.target._parent.originalWidth);
		// v6.4.2.4 How about if you are playing an flv, but only want the audio track?
		//myTrace("type="+eventObject.target._parent.requestedMediaType);
		// v6.4.3 By default all audio now streams
		//if (eventObject.target._parent.requestedMediaType.indexOf("streamingAudio")>=0) {
		if (eventObject.target._parent.requestedMediaType.toLowerCase().indexOf("audio")>=0) {
			//myTrace("audio track from video " + eventObject.target);
			eventObject.target._parent._visible = false;
		} else if (eventObject.target.preferredWidth > 0) {
			//myTrace("got preferred width=" + eventObject.target.preferredWidth + " or " + eventObject.target.videoWidth);
			this.doPreferredWidthResizing(eventObject);
		}
		//myTrace("call to setEnable vP " + eventObject.target._parent);
		eventObject.target._parent.setEnabled(true);
	}
	// v6.4.2.4 The total time of the video has changed. But doesn't seem to trigger at all.
	myJukeboxListener.totalTimeUpdated = function(eventObject){ 
		//myTrace("totalTimeUpdated:" + eventObject.target.totalTime);
	}
	// v6.4.2.4 A tidier function to do resizing once you know the preferred width/height
	myJukeboxListener.doPreferredWidthResizing = function(eventObject) {
		//myTrace("dPWR:with "+ eventObject.target.preferredWidth + " or " + eventObject.target.videoWidth);
		//myTrace("dPWR:with autosize="+ eventObject.target._parent.autoSize);
		var vidWidth = eventObject.target.preferredWidth;
		var vidHeight = eventObject.target.preferredHeight;
		var compWidth = eventObject.target._parent.originalWidth;
		var compHeight = eventObject.target._parent.originalHeight;
		//myTrace("call to onResize of " + eventObject.target._parent._parent);
		if (eventObject.target._parent.autoSize) {
			// tell the event target that you must start at the preferred size
			// and make it go there.
			myTrace("use autosize");
			// v6.4.1.4 But the puw is going to tell the video to setSize
			// and I think it has to for puw resizing, so let it
			// No, it seems I don't. Maybe another onResize!
			eventObject.target.setSize(vidWidth, vidHeight);	
			eventObject.target._parent._parent.onResize({id:eventObject.target._parent.id, width:vidWidth, height:vidHeight}, "perfect");
			
		} else if (vidWidth > compWidth || vidHeight > compHeight) {
			//trace("can enlarge to width " + eventObject.target.preferredWidth);
			// tell the event target that you will start at an original size
			// v6.4.1.4 So, I am initially going to see the video shrunk to fit
			// into the size sent by XML. The mediaComponent will ensure that my
			// aspect ratio is not lost, but it will change the vertical placement.
			// So it would be bettter for me to resize the component so that it reflects
			// the video size exactly.
			// But first, I have to figure out the shrunk size.
			var myAspectRatio = vidWidth / vidHeight;
			var shrinkW = false;
			//v6.4.2.4 If either of the width or height is set to 1, then this means I want to ignore this dimension and
			// resize based on the other one.
			if (compHeight==1) {
				shrinkW = true
			} else if ((compWidth / vidWidth) < (compHeight / vidHeight)) {
				shrinkW = true
			}
			if (shrinkW) {
				var myW = compWidth;
				var myH = compWidth / myAspectRatio;
				//myTrace("shrink width to w=" + myW + ", h=" + myH, 1);
			} else {
				var myH = compHeight;
				var myW = compHeight * myAspectRatio;
				//myTrace("shrink height to w=" + myW + ", h=" + myH, 1);
			}
			// I think I should also change the 'original' dims to reflect
			// this reality, otherwise magnify will undo this work
			eventObject.target._parent.originalWidth = myW;
			eventObject.target._parent.originalHeight = myH;
			eventObject.target._parent.originalRatio = myAspectRatio;
			myTrace("shrink component to match shrunk video, w=" + myW + ", h=" + myH);
			eventObject.target.setSize(myW, myH);			
			eventObject.target._parent._parent.onResize({id:eventObject.target._parent.id, width:myW, height:myH}, "original");
			
		// v6.4.1.4 And what about a video that is smaller?
		// Don't increase it's size
		} else if (vidWidth < compWidth && vidHeight < compHeight) {
			var myW = vidWidth;
			var myH = vidHeight;
			myTrace("shrink component to match small video, w=" + myW + ", h=" + myH);
			eventObject.target.setSize(myW, myH);			
			eventObject.target._parent._parent.onResize({id:eventObject.target._parent.id, width:myW, height:myH}, "original");
		// and for perfect match
		} else if (vidWidth == compWidth &&
			vidHeight == compHeight) {
			// tell the event target that you will start at the perfect size
			//myTrace("perfect, so tell your parent this " + eventObject.target._parent);
			// v6.5.5.3 Can I do this to make it go nice? Yes, you have to.
			eventObject.target.autoSize = true;
			eventObject.target.setSize(vidWidth, vidHeight);			
			eventObject.target.move(0,0);
				
			eventObject.target._parent._parent.onResize({id:eventObject.target._parent.id, width:vidWidth, height:vidHeight}, "perfect");
		}
		// also tell the event target about the preferred width and height, and duration
		// if it has been automatically set by the FLV creator. No - this is done in the calling function(s)
		eventObject.target._parent._parent.onInformation({id:eventObject.target._parent.id, 
												width:vidWidth,
												height:vidHeight,
		//// and don't send duration info here
		////										duration:eventObject.target.duration,
												autosize:eventObject.target._parent.autoSize});
		// save what you have sent so it never gets overwritten
		eventObject.target._parent.actualWidth = vidWidth;
		eventObject.target._parent.actualHeight = vidHeight;	
		//myTrace("end of resize, x=" + eventObject.target._x + " _p.x=" + eventObject.target._parent._x + " _p._p.x=" + eventObject.target._parent._parent._x + " _p._p._p.x=" + eventObject.target._parent._parent._parent._x);
	}
	
	// Move controller functions out of the player
	this.pause = function() {
		var jukeboxPlayer = this.jukeboxPlayer;
		myTrace("pause player=" + jukeboxPlayer);
		// v6.4.2.5 Can I treat an fls just like an MP3?
		//if (this.mediaType == "FLV" || this.mediaType == "MP3") {
		if (this.mediaType == "FLV" || this.mediaType == "MP3" || this.mediaType == "FLS") {
			jukeboxPlayer.pause();
		} else {
			//myTrace("videoPlayer:pause");
			jukeboxPlayer.onEnterFrame = undefined;
			jukeboxPlayer.stop();
			jukeboxPlayer.playing = false;
		}
	}
//}
// v6.4.2.4 You don't usually send place to play()
this.play = function(place) {
	// v6.4.2.4 Only play one video at once.
	this.stopOtherVideos();
	var jukeboxPlayer = this.jukeboxPlayer;
	//myTrace("play " + jukeboxPlayer);
	//myTrace("videoPlayer:play("+place+")");
	// a -ve place means rewind by this many seconds, please
	// v6.4.2.5 Can I treat an fls just like an MP3?
	//if (this.mediaType == "FLV" || this.mediaType == "MP3") {
	if (this.mediaType == "FLV" || this.mediaType == "MP3" || this.mediaType == "FLS") {
		if (place < 0 && place != undefined) {
			var newPlace = Number(jukeboxPlayer.playheadTime)+Number(place);
			//myTrace("rewind from " + jukeboxPlayer.playheadTime + " to " + newPlace);
			jukeboxPlayer.playheadTime = newPlace;
		} else if (place >= 0 && place != undefined) {
			jukeboxPlayer.playheadTime = place;
		} else {
			// v6.4.2.4 If the playhead is already at the end, go back to the beginning
			//myTrace("play: playhead=" + jukeboxPlayer.playheadTime + " duration=" + jukeboxPlayer.duration);
			if (jukeboxPlayer.playheadTime >= jukeboxPlayer.duration) {
				jukeboxPlayer.playheadTime = 0;
			}
		}
		jukeboxPlayer.play();
	} else {
		// for an animation, place is a frame number, not time
		// also, the controller will send play() if it wants you to play from
		// where you are.
		if (place == undefined) {
			var newPlace = this.getPlayHead();
		} else {
			var newPlace = Math.floor(place);
		}
		if (isNaN(newPlace)){
			newPlace = 1
		} else if (newPlace < 0) { 
			// this means rewind place seconds, so convert to (guessed) framerate
			newPlace = this.getPlayHead() + (place * 12);
		}
		if (newPlace<1) newPlace=1;
		jukeboxPlayer.gotoAndPlay(newPlace);
		jukeboxPlayer.playing = true;
		jukeboxPlayer.onEnterFrame = function() {
			this._parent.onPlaying(this._currentFrame);
			//myTrace("onEnterFrame");
			if (this._currentFrame >= this._totalFrames) {
				this._parent.onFinishedPlaying();
				this.stop();
				this.onEnterFrame = undefined;
			}
		}
	}
}
this.stop = function() {
	//var thisVideo = this[id];
	var jukeboxPlayer = this.jukeboxPlayer;
	//myTrace("stop player[" + id + "]=" + jukeboxPlayer);
	// v6.4.2.5 Can I treat an fls just like an MP3?
	//if (this.mediaType == "FLV" || this.mediaType == "MP3") {
	if (this.mediaType == "FLV" || this.mediaType == "MP3" || this.mediaType == "FLS") {
		//myTrace("simply stop;")
		//jukeboxPlayer.stop();
		//myTrace("force stop;")
		this.gotoAndStop(0);
	} else {
		//myTrace("videoPlayer:stop");
		jukeboxPlayer.onEnterFrame = undefined;
		jukeboxPlayer.gotoAndStop(1);
		jukeboxPlayer._parent.onPlaying(1);
		jukeboxPlayer.playing = false;
	}
}
this.gotoAndStop = function(place) {
	//var thisVideo = this[id];
	var jukeboxPlayer = this.jukeboxPlayer;
	//myTrace("gotoStop player=" + jukeboxPlayer);
	// v6.4.2.5 Can I treat an fls just like an MP3?
	//if (this.mediaType == "FLV" || this.mediaType == "MP3") {
	if (this.mediaType == "FLV" || this.mediaType == "MP3" || this.mediaType == "FLS") {
		jukeboxPlayer.pause();
		jukeboxPlayer.playheadTime = place;
	} else {
		var newPlace = Math.floor(place);
		jukeboxPlayer.gotoAndStop(newPlace);
		jukeboxPlayer.playing = false;
	}
}
this.getPlayHead = function() {
	var jukeboxPlayer = this.jukeboxPlayer;
	//myTrace("getPlayhead player=" + jukeboxPlayer + ", this=" + this);
	// v6.4.2.5 Can I treat an fls just like an MP3?
	//if (this.mediaType == "FLV" || this.mediaType == "MP3") {
	if (this.mediaType == "FLV" || this.mediaType == "MP3" || this.mediaType == "FLS") {
		return jukeboxPlayer.playheadTime;
	} else {
		return jukeboxPlayer._currentframe;
	}
}
this.isPlaying = function() {
	var jukeboxPlayer = this.jukeboxPlayer;
	return jukeboxPlayer.playing;
}
	
//jukeboxPlayer.autoPlay = false;
//jukeboxPlayer.autoSize = false;
//jukeboxPlayer.aspectRatio = true;
//jukeboxController.backgroundStyle = "none";
//jukeboxController.activePlayControl = "pause";

// keep the player invisible on loading, let the harness make it visible

this.setEnabled = function(enabled) {
	//var thisVideo = this[id];
	//var jukeboxPlayer = this[id].jukeboxPlayer;
	var jukeboxPlayer = this.jukeboxPlayer;
	//myTrace("enable player=" + jukeboxPlayer);
	jukeboxPlayer.visible = enabled;
	//myTrace(jukeboxPlayer + ".visible=" + jukeboxPlayer.visible);
	//myTrace(jukeboxPlayer._parent + "._visible=" + jukeboxPlayer._parent._visible);
	//myTrace(jukeboxPlayer._parent._parent + "._visible=" + jukeboxPlayer._parent._parent._visible);
	//myTrace(jukeboxPlayer._parent._parent._parent + "._visible=" + jukeboxPlayer._parent._parent._parent._visible);
	//jukeboxController._visible = enabled;
}
// a very raw function for resizing - aspect ratio is NOT broken, so actual size
// could be different.
this.setSize = function(w, h) {
	//myTrace("vp.setSize to " + w);
	//v6.4.2.4 I have no idea why I can't see to pick up the actual player here, wheras for the other functions
	// copied like this I can
	//var jukeboxPlayer = this.jukeboxPlayer;
	var jukeboxPlayer = this[this.id].jukeboxPlayer;
	//myTrace("vp.jukeboxPlayer=" + jukeboxPlayer);
	jukeboxPlayer.setSize(w, h);
}
// Let the video be enlarged or shrunk by a certain amount
this.magnify = function(delta) {
	//v6.4.2.4 I have no idea why I can't see to pick up the actual player here, wheras for the other functions
	// copied like this I can
	var jukeboxPlayer = this[this.id].jukeboxPlayer;
	var myAnchor = this[this.id].anchor;
	//myTrace("magnify, id=" + this.id + " anchor=" + myAnchor + " type=" + this[this.id].mediaType);
	if (this[this.id].mediaType == "FLV") {
		var currentWidth = jukeboxPlayer.width;
		var currentHeight = jukeboxPlayer.height;
		var currentY = jukeboxPlayer.y;
		var currentX = jukeboxPlayer.x;
	} else {
		// not differences due to new MX 2004 UIComponent
		var currentWidth = jukeboxPlayer._width;
		var currentHeight = jukeboxPlayer._height;
		var currentY = jukeboxPlayer._y;
		var currentX = jukeboxPlayer._x;
	}
	//myTrace("magnify:current w=" + currentWidth + ", h=" + currentHeight + ", delta=" + delta + ", preferred=" + jukeboxPlayer.preferredWidth);
	//myTrace("orig w=" + jukeboxPlayer._parent.originalWidth + ", h=" + jukeboxPlayer._parent.originalHeight);
	// Don't go bigger than the natural size
	if (currentWidth+delta >= jukeboxPlayer.preferredWidth) {
		myTrace("would take you bigger, so be natural");
		//jukeboxPlayer.visible = false; // this doesn't help with the flash
		if (myAnchor == "tr") {
			jukeboxPlayer.move(jukeboxPlayer._parent.originalWidth - jukeboxPlayer.preferredWidth, currentY);
		}
		jukeboxPlayer.setSize(jukeboxPlayer.preferredWidth, jukeboxPlayer.preferredHeight);
		// tell the parent that you have resized and are at the preferred size
		jukeboxPlayer._parent._parent.onResize({width:jukeboxPlayer.preferredWidth, height:jukeboxPlayer.preferredHeight}, "preferred");
		//jukeboxPlayer.visible = true;
		
	// Don't go smaller than the starting size
	} else if (currentWidth+delta <= jukeboxPlayer._parent.originalWidth) {
		myTrace("would take you smaller, so be original");
		jukeboxPlayer.setSize(Number(jukeboxPlayer._parent.originalWidth)+this.margin, Number(jukeboxPlayer._parent.originalHeight)+this.margin);
		if (myAnchor == "tr") {
			jukeboxPlayer.move(0, currentY);
		}
		// tell the parent that you have resized and are at the original size
		jukeboxPlayer._parent._parent.onResize({width:jukeboxPlayer._parent.originalWidth, height:jukeboxPlayer._parent.originalHeight}, "original");
		
	} else {
		// this probably won't be exactly delta due to aspect ratio stuff
		var myW = currentWidth + delta;
		var myH = currentHeight + (delta / jukeboxPlayer._parent.originalRatio);
		myTrace("so delta it to w=" + myW + ", h=" + myH);
		jukeboxPlayer.setSize(myW, myH);
		if (myAnchor == "tr") {
			//trace("move by " + delta + " from x=" + jukeboxPlayer.x);
			jukeboxPlayer.move(currentX - delta, currentY);
		}
		// tell the parent that you have resized 
		jukeboxPlayer._parent._parent.onResize({width:myW, height:myH}, "other");
	}
	//jukeboxController.move(jukeboxPlayer.x, jukeboxPlayer.height);
}
// v6.4.2.4 Stop other videos if you start one.
this.stopOtherVideos = function(){
	/*
	for (var i in this){
		//myTrace(this[i].jukeboxPlayer + ".isPlaying()=" + this[i].jukeboxPlayer.isPlaying())
		if (this[i].jukeboxPlayer.isPlaying()) {
			this[i].jukeboxPlayer.pause();
		}
	}
	*/
}
// make our own streaming progress bar
jbStreamer.setProgress = function(value) {
	if (value > 100) value=100;
	if (value < 0) value=0;
	//trace("setting % at " + value);
	//this.pc.text = value + "%";
	this.fill._xscale = value; // * this._width/100;
}
jbStreamer.setProgress(0);
jbStreamer.setLabel = function(value, format) {
	this.loadStatus._xscale = this.loadStatus._yscale = 100;
	//myTrace("streamer.setLabel=" + value);
	if (value == undefined) {
		this.loadStatus.text = ""
	} else {
		this.loadStatus.text = value;
	}
	if (format != undefined) {
		this.loadStatus.setTextFormat(format);
	}
}
jbStreamer.setWidth = function(value) {
	//_global.myTrace("streamer width = " + value + " x=" + this._x);
	this._width = value;
}
jbStreamer.onDisappear = function() {
	this._visible = false;
}
jbStreamer.disappearEffect = function() {
	var intID:Number = _global['setTimeout'](this, "onDisappear", 1000);
}
/*
// functions for the handmade slider. Don't use the regular changeHandler
// as we are moving the slider from the video anyway. How about onRelease?
//jbSlider.setChangeHandler("onChange", this);
jbSlider.onStartChangeEvent = function() {
	//trace("start drag at " + this.getValue());
	if (this._parent.jukeboxPlayer.playing) {
		this.wasPlaying = true;
	} else {
		this.wasPlaying = false;
	}
	this._parent.jukeboxPlayer.pause();
	// enable the regular change event
	this.setChangeHandler("onChange", this);
	// and stop checking to see if the playhead has updated
	clearInterval(this.checkPlayheadInt);
}
jbSlider.onStopChangeEvent = function() {
	var fromHere = this.getValue();
	var jukeboxPlayer = this._parent.jukeboxPlayer;
	if (this.wasPlaying) {
		trace("playing so restart from " + fromHere);
		jukeboxPlayer.play(fromHere)
	} else {
		trace("paused, so gotoAndStop " + fromHere);
		jukeboxPlayer.playheadTime = fromHere;
	}
	// disable the regular change event
	this.setChangeHandler(undefined);
	// and restart the updating of slider position
	this.checkPlayheadInt = setInterval(this, "checkPlayhead", 1000);
}
jbSlider.onChange = function() {
	//trace("change playhead");
	this._parent.jukeboxPlayer.playheadTime = this.getValue();
}
//	jukeboxController.checkPlayhead = function() {
//		//trace("playhead at " + jukeboxPlayer.playheadTime);
//		this.setValue(jukeboxPlayer.playheadTime);
//	}
jbSlider.checkPlayhead = function() {
	this.setValue(this._parent.jukeboxPlayer.playheadTime);
}

jbSlider.setStartChangeEvent(jbSlider.onStartChangeEvent);
jbSlider.setStopChangeEvent(jbSlider.onStopChangeEvent);
*/
// for self-test
/*
var thisObj = {jbURL:"http://download.macromedia.com/pub/developer/darwin.flv"};

//var thisObj = {jbURL:"http://dock/video/paraglider.flv"};
thisObj.jbDuration = 60;
thisObj.jbWidth = 160; 
thisObj.jbHeight = 106;
thisObj.jbType = "FLV";
thisObj.jbAnchor = "tr";
this.setMedia(thisObj);
this.setEnabled(true);
this.growUpWoof = function() {
	trace("growUpWoof");
	magnify(100);
	clearInterval(this.growUpInt);
	this.jukeboxPlayer.play(0);
}
this.growDownWoof = function() {
	trace("growDownWoof");
	magnify(-50);
	clearInterval(this.growDownInt);
}
this.growUpInt = setInterval(this, "growUpWoof",2000);
this.growDownInt = setInterval(this, "growDownWoof",4000);
*/
//myTrace("videoPlayer frame 1",1);
/*
	// This is the code from the image resizing (buried in buttons.fla)
	//v6.4.1 Resizing rules.
	// 1) if width or height = 0, then use the original for that dim
	// 2) if jbStretch = true (default), then simply use the width and height you are given.
	// 3) with the jbStretch=false, we need to respect the aspect-ratio
	//	  whilst making it as big as possible.
	if (_parent.jbWidth <= 0) {
		_parent.jbWidth = _width;
	}
	if (_parent.jbHeight <= 0) {
		_parent.jbHeight = _height;
	}
	if (_parent.jbStretch) {
		var myW = _parent.jbWidth;
		var myH = _parent.jbHeight;
		//myTrace("stretch to w=" + myW + ", h=" + myH, 1);
	// Next check to see if size is perfect and no need to do anything
	} else {
		// Don't let a small picture get upsized
		if (_parent.jbWidth > _width) {
			_parent.jbWidth = _width;
		}
		if (_parent.jbHeight > _height) {
			_parent.jbHeight = _height;
		}
		if (_parent.jbWidth == _width &&
			_parent.jbHeight == _height){
			var myW = _parent.jbWidth;
			var myH = _parent.jbHeight;
			//myTrace("perfect at w=" + myW + ", h=" + myH, 1);
		// Finally work out how to shrink it correctly so it doesn't exceed
		// the jbDims in any direction
		} else {
			var aspectRatio = _width / _height;
			var shrinkW = false;
			if ((_parent.jbWidth / _width) < (_parent.jbHeight / _height)) {
				shrinkW = true
			}
			if (shrinkW) {
				var myW = _parent.jbWidth;
				var myH = _parent.jbWidth / aspectRatio;
				//myTrace("shrink width to w=" + myW + ", h=" + myH, 1);
			} else {
				var myH = _parent.jbHeight;
				var myW = _parent.jbHeight * aspectRatio;
				//myTrace("shrink height to w=" + myW + ", h=" + myH, 1);
			}
		}		
	}
	_width = myW;
	_height = myH;
	_x = _parent.jbX;
	_y = _parent.jbY;
*/
