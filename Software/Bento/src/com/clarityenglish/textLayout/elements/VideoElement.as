package com.clarityenglish.textLayout.elements {
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.system.Security;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.tlf_internal;
	
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	
	import spark.components.VideoPlayer;

	use namespace tlf_internal;
	
	public class VideoElement extends ImageComponentElement implements IComponentElement {
		
		private static const NORMAL:String = "normal";
		private static const YOU_TUBE:String = "you_tube";
		private static const VIMEO:String = "vimeo";
		
		private static var inititalized:Boolean = false;
		
		private var _src:String;
		
		private var _autoPlay:Boolean = true;
		
		private var _fullScreenDisabled:Boolean = false;
		
		private var _videoDimensionsCalculated:Boolean;
		
		// #306
		private var currentlyPlayerVideoHasFinished:Boolean;
		
		// This is a weak dictionary with a single key that statically tracks the currently playing video without making a GC root
		private static var _currentlyPlayingVideoPlayerDictionary:Dictionary;
		
		public function VideoElement() {
			super();
			
			// Allow www.youtube.com (only do this once)
			if (!inititalized) {
				Security.allowDomain("www.youtube.com");
				Security.allowDomain("www.vimeo.com");
				inititalized = true;
			}
		}
		
		protected override function get abstract():Boolean {
			return false;
		}
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "video"; }
		
		public function set src(value:String):void {
			_src = value;
		}
		
		public function get src():String {
			return _src;
		}
		
		public function set autoPlay(value:Boolean):void {
			_autoPlay = value;
		}
		
		public function set fullScreenDisabled(value:Boolean):void {
			_fullScreenDisabled = value;
		}
		
		public function createComponent():void {
			switch(getVideoType()) {
				case NORMAL:
					var videoPlayer:VideoPlayer = new VideoPlayer();
					videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange, false, 0, true);
					videoPlayer.addEventListener(TimeEvent.COMPLETE, onTimeComplete, false, 0, true);
					
					// To let practice zone video come from rtmp too, we need some handling here
					// But this does NOT work, we see nothing in the exercise.
					if (_src.indexOf("rtmp") >= 0) {
						// Parse the filename
						var host:String = "rtmp://streaming.clarityenglish.com:1935/cfx/st";
						var streamName:String = "RoadToIELTS2/speaking/media/speaking_key_facts_700";
						var bitrate:Number = 700; 
						var dynamicSource:DynamicStreamingResource = new DynamicStreamingResource(host);
						dynamicSource.urlIncludesFMSApplicationInstance = true;
						
						dynamicSource.streamType = 'recorded';
						var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
						var streamingItem:DynamicStreamingItem = new DynamicStreamingItem(streamName, bitrate);
						streamItems.push(streamingItem);
						dynamicSource.streamItems = streamItems; 
						
						videoPlayer.source = dynamicSource;
						videoPlayer.callLater(videoPlayer.play);
					} else {
						videoPlayer.source = _src;
					}
					
					videoPlayer.width = width;
					videoPlayer.height = height;
					videoPlayer.autoPlay = _autoPlay;
					
					videoPlayer.autoDisplayFirstFrame = true;
					
					component = videoPlayer;
					
					// #113
					videoPlayer.addEventListener(FlexEvent.CREATION_COMPLETE, function(creationCompleteEvent:Event):void {
						videoPlayer.fullScreenButton.enabled = !_fullScreenDisabled;
					}, false, 0, true);
					
					// Working around #22 (which seems to be http://bugs.adobe.com/jira/browse/SDK-26331, even though that is supposed to be fixed)
					videoPlayer.addEventListener(Event.ADDED_TO_STAGE, function(addedToStageEvent:Event):void {
						addedToStageEvent.currentTarget.removeEventListener(addedToStageEvent.type, arguments.callee);
						videoPlayer.systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, function(event:FullScreenEvent):void {
							if (!event.fullScreen) {
								videoPlayer.width = (isAutoWidth()) ? videoPlayer.videoObject.videoWidth : width;
								videoPlayer.height = (isAutoHeight()) ? videoPlayer.videoObject.videoHeight : height;
								videoPlayer.invalidateDisplayList();
							}
						}, false, 0, true);
					} );
					break;
				case YOU_TUBE:
				case VIMEO:
					var swfLoader:SWFLoader = new SWFLoader();
					swfLoader.addEventListener(Event.COMPLETE, onYouTubeComplete, false, 0, true);
					
					swfLoader.scaleContent = false;
					swfLoader.maintainAspectRatio = true;
					swfLoader.load(_src);
					trace("try to load " + _src);
					
					component = swfLoader;
					break;
			}
		}
		
		/**
		 * When the video dimensions are ready we may need to resize and redraw the video component if width or height are "auto".
		 * 
		 * This listener is only applicable for NORMAL type
		 * 
		 * @param event
		 */
		private function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
			var videoPlayer:VideoPlayer = event.target as VideoPlayer;
			
			switch (event.state) {
				case MediaPlayerState.PLAYING:
				case MediaPlayerState.PAUSED:
					if (component && !_videoDimensionsCalculated) {
						if (isAutoWidth())
							elementWidth = component.width = (component as VideoPlayer).videoObject.videoWidth;
						
						if (isAutoHeight())
							elementHeight = component.height = (component as VideoPlayer).videoObject.videoHeight;
						
						_videoDimensionsCalculated = true;
						
						fireElementSizeChanged();
					}
					break;
			}
			
			// #76 - only one video should play at once
			if (event.state == MediaPlayerState.PLAYING) {
				if (currentlyPlayingVideoPlayer && currentlyPlayingVideoPlayer !== getComponent()) {
					currentlyPlayingVideoPlayer.pause(); // #306 - pause instead of stop
				}
				
				currentlyPlayingVideoPlayer = getComponent() as VideoPlayer;
			} else if (event.state == MediaPlayerState.PAUSED) {
				// #109
				currentlyPlayingVideoPlayer = null;
			} else if (event.state == MediaPlayerState.READY) {
				// #206
				if (currentlyPlayerVideoHasFinished) {
					currentlyPlayerVideoHasFinished = false;
					currentlyPlayingVideoPlayer.pause();
					currentlyPlayingVideoPlayer = null;
				}
			}
		}
		
		private function onTimeComplete(event:TimeEvent):void {
			// #206
			currentlyPlayerVideoHasFinished = true;
		}
		
		/**
		 * A funky way to statically store a VideoPlayer without making a reference and breaking GC
		 * 
		 * @param value
		 */
		private static function set currentlyPlayingVideoPlayer(value:VideoPlayer):void {
			_currentlyPlayingVideoPlayerDictionary = new Dictionary(true);
			_currentlyPlayingVideoPlayerDictionary[value] = true;
		}
		
		private static function get currentlyPlayingVideoPlayer():VideoPlayer {
			for (var videoPlayer:* in _currentlyPlayingVideoPlayerDictionary)
				return videoPlayer as VideoPlayer;
			
			return null;
		}
		
		private function onYouTubeComplete(event:Event):void {
			// Default dimensions are 400x300
			// TODO: Perhaps this should detect widescreen and change the default aspect accordingly
			var youTubeWidth:int = (isAutoWidth()) ? 400 : width;
			var youTubeHeight:int = (isAutoHeight()) ? 300 : height;
			
			event.target.content.addEventListener("onReady", function(e:Event):void {
				e.target.setSize(youTubeWidth, youTubeHeight);
				if (_autoPlay)
					e.target.playVideo();
			} );
			
			elementWidth = component.width = youTubeWidth;
			elementHeight = component.height = youTubeHeight;
		}
		
		/**
		 * TLF makes the existing method of working out whether width is auto private, so we need to duplicate it here
		 * 
		 * @return 
		 */
		private function isAutoWidth():Boolean {
			return (width === undefined && widthPropertyDefinition.defaultValue == FormatValue.AUTO);
		}
		
		/**
		 * TLF makes the existing method of working out whether height is auto private, so we need to duplicate it here
		 * 
		 * @return 
		 */
		private function isAutoHeight():Boolean {
			return (height === undefined && heightPropertyDefinition.defaultValue == FormatValue.AUTO);
		}
		
		/**
		 * If the src contains "www.youtube.com" this must be a YouTube embed, otherwise we use the Spark VideoPlayer
		 * Add in vimeo.com
		 * @return 
		 */
		private function getVideoType():String {
			if (_src.search(/www\.youtube\.com/) >= 0) { 
				trace("found a YouTube video");
				return YOU_TUBE;
			}
			if (_src.search(/\.vimeo\.com/) >= 0) {
				trace("found a vimeo video");
				return VIMEO;
			}
			return NORMAL;
		}
		
	}
	
}
