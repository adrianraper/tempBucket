package com.clarityenglish.controls.video.players {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.events.VideoEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import org.osmf.events.BufferEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.utils.OSMFSettings;
	
	import spark.components.VideoPlayer;
	
	[Event(name="videoPlayed", type="com.clarityenglish.controls.video.events.VideoEvent")]
	[Event(name="videoPaused", type="com.clarityenglish.controls.video.events.VideoEvent")]
	[Event(name="videoStopped", type="com.clarityenglish.controls.video.events.VideoEvent")]
	[Event(name="videoComplete", type="com.clarityenglish.controls.video.events.VideoEvent")]
	public class OSMFVideoPlayer extends VideoPlayer implements IVideoPlayer {
		
		private static const BUFFER_TIME:int = 4;
		
		private var fullScreenTime:Number = NaN;
		
		public function OSMFVideoPlayer() {
			super();
			
			OSMFSettings.enableStageVideo = false;
			
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);
			addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		private function onCreationComplete(event:FlexEvent):void {
			// Try and turn on smoothing automatically
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			videoDisplay.mx_internal::mediaFactory = new SmoothingMediaFactory();
			
			// Set the buffer time
			videoDisplay.mx_internal::videoPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange, false, 0, true);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			if (instance == fullScreenButton) {
				fullScreenButton.addEventListener(MouseEvent.CLICK, onFullScreen);
			}
			
			super.partAdded(partName, instance);
		}
		
		protected function onBufferingChange(event:BufferEvent):void {
			event.target.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			event.target.bufferTime = BUFFER_TIME;
		}
		
		protected function onStateChange(event:MediaPlayerStateChangeEvent):void {
			switch (event.state) {
				case MediaPlayerState.READY:
					dispatchEvent(new VideoEvent(VideoEvent.VIDEO_READY));
					break;
				case MediaPlayerState.PLAYING:
					dispatchEvent(new VideoEvent(VideoEvent.VIDEO_PLAYED));
					break;
				case MediaPlayerState.PAUSED:
					dispatchEvent(new VideoEvent(VideoEvent.VIDEO_PAUSED));
					break;
			}
		}
		
		public override function set source(value:Object):void {
			// Setting source to null and forcing gc fixes a memory leak inherent in OSMF (not on iPad unfortunately)
			super.source = null;
			System.gc();
			super.source = value;
		}
		
		/**
		 * Record the timestamp when the full screen button was last pressed (GH #47)
		 * 
		 * @param event
		 */
		protected function onFullScreen(event:MouseEvent):void {
			fullScreenTime = (new Date()).time;
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange);
			
			// This is rather hacky, but it seems that the first time that the full screen button is pressed for an OSMF video the REMOVED_FROM_STAGE event is fired.
			// After full screen has been pressed (for any instance) it then works normally for all future instances.  Therefore I'm using a simple timer so that I
			// don't clear the source unless the full screen button *wasn't* pressed in the last half second, hence protecting against this issue.  These hoops are
			// necessary because everything that would actually be useful in VideoPlayer for dealing with this neatly is private... grr :(  GH #47.
			if (isNaN(fullScreenTime) || ((new Date()).time - fullScreenTime) > 500) {
				stop();
				super.source = null;
				System.gc();
			}
		}
		
	}
}
import org.osmf.elements.VideoElement;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaResourceBase;

/**
 * An attempt to enable smoothing with OSMF2 - not convinced it is working though
 */
class SmoothingMediaFactory extends DefaultMediaFactory {
	
	private var _highjackedMediaCreationFunction:Function;
	
	protected override function resolveItems(resource:MediaResourceBase, items:Vector.<MediaFactoryItem>):MediaFactoryItem {
		var mfi:MediaFactoryItem = super.resolveItems(resource, items);
		/* If a custom MFI is being used, hijack it and intercept the media element it returns to set smoothing on it */
		if (mfi) {
			_highjackedMediaCreationFunction = mfi.mediaElementCreationFunction;
			var hijacker:MediaFactoryItem = new MediaFactoryItem(mfi.id, mfi.canHandleResourceFunction, interceptMediaElement);
			return hijacker;
		}
		return mfi;
	}
	
	protected function interceptMediaElement():MediaElement {
		var element:MediaElement = _highjackedMediaCreationFunction();
		if (element is VideoElement) {
			VideoElement(element).smoothing = true;
		}
		return element;
	}
	
}