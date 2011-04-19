// v6.4.3 Since any movies published for different Flash players will not share the same
//_global space, I need to pass this object through to them.
if (_global.ORCHID == undefined) {
	_global.ORCHID = this._parent.sharedGlobal;
} 

this.depth=0;
this.margin=0;

// function to load up the video
this.setMedia = function(videoObj) {
	
	myTrace("newVideoPlayer:setMedia " + videoObj.jbURL);
	
	// Create the control for the media and size it and set listener events
	if (this[videoObj.jbID] != undefined) {
		//myTrace("a player for this mediaID already exists")
	} else {

		if (Number(videoObj.jbWidth) <= 0 || Number(videoObj.jbHeight) <= 0) {
			var thisWidth = 100;
			var thisHeight =100;
			var thisAutosize = true;
			//myTrace("based on no size given, autoSize=" + thisAutosize);
		} else {
			var thisWidth = Number(videoObj.jbWidth);
			var thisHeight = Number(videoObj.jbHeight);
			//myTrace("based on size width="+ thisWidth+ " height=" + thisHeight);
		}
		// these should be on the parent, not directly on component
		//thisVideo.anchor = videoObj.jbAnchor;
		if (thisAutosize) {
			this[videoObj.jbID].autoSize = true
		}
		var thisVideo = this.createEmptyMovieClip(videoObj.jbID, this.depth++);
		// v6.5.5.3 For FLVPlayback component
		import mx.video.*;
		//var flvPlayer:FLVPlayback = new FLVPlayback();
		//thisVideo.jukeboxPlayer = thisVideo.addChildAt(flvPlayer, this.depth++);
		//The next line assumes you have copied the skin file to the local directory
		//flvPlayer.skin = "./ClearOverPlaySeekMute.swf"
		//flvPlayer.source = videoObj.jbURL;
		var myPlayer:FLVPlayback = thisVideo.attachMovie("FLVPlayback","jukeboxPlayer", this.depth++);
		// Can you base the skin on the width? So a narrow video gets this
		// v6.5.5.8 For new CP we would like to pick up the video controls from literals
		var videoController = _global.ORCHID.literalModelObj.getLiteral("videoController", "messages");
		if (videoController.indexOf(".swf")<=0) {
			if (thisWidth<200) {
				videoController = "MojaveOverPlaySeekMute.swf";
			} else {
				// and a wider one gets it all?
				videoController = "MojaveOverAll.swf";
			}
		}
		//myTrace("use videoController=" + videoController);
		myPlayer.skin = _global.ORCHID.paths.movie + videoController;
		
		// v6.5.5.8 A clumsy way to set parameters, but it fits with choosing the controller by product.
		//myPlayer.skinAutoHide = true;
		if (_global.ORCHID.literalModelObj.getLiteral("videoControllerAutoHide", "messages")=="true") {
			myPlayer.skinAutoHide = true;
		} else {
			myPlayer.skinAutoHide = false;
		}
		myPlayer.autoPlay = videoObj.jbAutoPlay;
		myPlayer.bufferTime = 2;
		
		var listenerObject:Object = new Object();
		// listen for playing event on RTMP connection; display result of isRTMP
		listenerObject.ready = function(eventObject:Object) {
			//myTrace("newVideo: value of isRTMP property is: " + eventObject.target.isRTMP);
		};
		listenerObject.playing = function(eventObject:Object) {
			//myTrace("newVideo: playing video: " + eventObject.target.totalTime + ", " + eventObject.target.contentPath);
			// If you start playing, how about pausing all other videos on teh screen?
			for (var i in _global.ORCHID.root.jukeboxHolder.videoList) {
				if (_global.ORCHID.root.jukeboxHolder.videoList[i].player !=eventObject.target) {
					//myTrace("try to pause " + _global.ORCHID.root.jukeboxHolder.videoList[i].player);
					_global.ORCHID.root.jukeboxHolder.videoList[i].player.pause();
				} else {
					//myTrace("don't pause yourself! = " + _global.ORCHID.root.jukeboxHolder.videoList[i].player);
				}
			}
		};
		listenerObject.stateChange = function(eventObject:Object):Void {
			if (eventObject.target.buffering){
				//myTrace("newVideo: buffering");
			} else {
				//myTrace("state is:" + eventObject.target.state);
			}
		};
		listenerObject.complete = function(eventObject:Object):Void {
			//myTrace("video playback is complete");
		}
		// The following is NOT triggered if you use stopallsounds elsewhere, though the video does stop playing
		listenerObject.stopped = function(eventObject:Object):Void {
			//myTrace("video stopped at " + eventObject.target.playheadTime);
		}
		myPlayer.addEventListener("ready", listenerObject);
		myPlayer.addEventListener("playing", listenerObject);
		myPlayer.addEventListener("stateChange", listenerObject);
		myPlayer.addEventListener("complete", listenerObject);
		myPlayer.addEventListener("stopped", listenerObject);
	
		//myTrace("created video player=" + thisVideo.jukeboxPlayer);
						  
		//v6.4.1.4 These are the size that the xml would like to show the video
		// at. But if the actual video is different, we will modify these later
		// so that the component matches the actual size, whilst not getting
		// outside the desired outline.
		thisVideo.originalWidth = Number(thisWidth);
		thisVideo.originalHeight = Number(thisHeight);
		if (videoObj.jbHeight > 0) {
			thisVideo.originalRatio = thisWidth / thisHeight;
		} else {
			thisVideo.originalRatio = 1;
		}
		this[videoObj.jbID].loaded = true;
		
		// v6.5.5.6 Add it to the list of videos in this exercise
		if (_global.ORCHID.root.jukeboxHolder.videoList == undefined) {
			_global.ORCHID.root.jukeboxHolder.videoList = new Array({id:videoObj.jbID, player:myPlayer});
		} else {
			_global.ORCHID.root.jukeboxHolder.videoList.push({id:videoObj.jbID, player:myPlayer});
		}
		
		// v6.5.5.8 Can I catch a click on the main video (but not one that disrupts the controller?)
		// Not like this
		//listenerObject.click = function(eventObject:Object):Void {
		//	myTrace("click on the video");
		//}
		//myPlayer.addEventListener("click", listenerObject);
		// This works, but still smothers the controller.
		//thisVideo.onRelease = function() {
		//	myTrace("click on the video");
		//}
		// Try to make a small button in the middle. It is 100 pixels square.
		var myMiddleX = (thisWidth - 100) / 2;
		var myMiddleY = (thisHeight - 100) / 2;
		myTrace("put the video play at x=" + myMiddleX + " y=" + myMiddleY);
		var initObj = {_x:myMiddleX, _y:myMiddleY, _alpha:100};
		var toggleButton = thisVideo.attachMovie("playPauseButton","playPauseButton", this.depth++, initObj);
		toggleButton.onRelease = function() {
			var myVideo = this._parent.jukeboxPlayer;
			//_global.myTrace("2.in video player " + myVideo + "=" + myVideo.state);
			if (myVideo.state=="playing") {
				myVideo.pause();
			} else {
				myVideo.play();
			}
		}
		/* Don't use this yet - but it will be very nice.
		toggleButton.onRollOver = function() {
			var myVideo = this._parent.jukeboxPlayer;
			if (myVideo.state=="playing") {
				this.gotoAndPlay(20);
			} else {
				//this.gotoAndPlay("fadeInPlay");
				this.gotoAndPlay(10);
			}
		}
		toggleButton.onRollOut = function() {
			var myVideo = this._parent.jukeboxPlayer;
			this.gotoAndPlay(1)
		}
		*/

	}

	// this is what you have just created
	//var jukeboxPlayer = this[videoObj.jbID].jukeboxPlayer;
	
	// save information about the media Object
	this[videoObj.jbID].id = videoObj.jbID;
	this[videoObj.jbID].autoPlay = videoObj.jbAutoPlay;
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
	//this[videoObj.jbID].setEnabled = this.setEnabled;
	//this[videoObj.jbID].setSize = this.setSize;
	
	// v6.5.5.5 For FLVPlayback component
	//jukeboxPlayer.autoSize = true;
	myPlayer.autoSize = true;
	myPlayer.isLive = false;
	try {
		myPlayer.contentPath = videoObj.jbURL;
		//myPlayer.contentPath = "rtmp://www.ieltspractice.com/oflaDemo/videoclip1_q1.flv";
	} catch (err:VideoError) {
		myTrace ("Error code is: " + err.code) 
	}

	//myPlayer.contentPath = "http://www.ClarityEnglish.com/Content/ActiveReading-International/Courses/1213672591135/Media/S01M.flv";
	//jukeboxPlayer.load("rtmp://www.ieltspractice.com/oflaDemo/videoclip1_q1.flv",60,false);
	//myTrace("newVideo:11");
	//myPlayer.load("rtmp://www.ieltspractice.com/oflaDemo/videoclip1_q1.flv",60,false);
	//myPlayer.load(videoObj.jbURL,60,false);

	/*
	// You don't need to do NetConnection if you use FLVPlayback as it wraps it all up
	jukeboxPlayer.setMedia(videoObj.jbURL, videoObj.jbType);
	var connection_nc:NetConnection = new NetConnection();
	connection_nc.connect(null);
	var stream_ns:NetStream = new NetStream(connection_nc);
	my_video.attachVideo(stream_ns);
	stream_ns.play("video2.flv");

	jukeboxPlayer.attachVideo(videoObj.jbURL);
	*/
}

// v6.5.5.8 Functions to control the playback from outside
this.togglePlayPause = function(mediaID) {
	var myVideo = this[mediaID].jukeboxPlayer;
	_global.myTrace("2.in video player " + myVideo + "=" + myVideo.state);
	if (myVideo.state=="playing") {
		myVideo.pause();
	} else {
		myVideo.play();
	}
	
}
