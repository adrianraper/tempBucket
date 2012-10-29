package com.clarityenglish.controls.video.players {
	import com.clarityenglish.controls.video.IVideoPlayer;
	
	import flash.events.Event;
	import flash.system.System;
	
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import org.osmf.events.BufferEvent;
	import org.osmf.utils.OSMFSettings;
	
	import spark.components.VideoPlayer;
	
	public class OSMFVideoPlayer extends VideoPlayer implements IVideoPlayer {
		
		private static const BUFFER_TIME:int = 4;
		
		public function OSMFVideoPlayer() {
			super();
			
			OSMFSettings.enableStageVideo = false;
			
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		private function onCreationComplete(event:FlexEvent):void {
			// Try and turn on smoothing automatically
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			videoDisplay.mx_internal::mediaFactory = new SmoothingMediaFactory();
			
			// Set the buffer time
			videoDisplay.mx_internal::videoPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange, false, 0, true);
		}
		
		protected function onBufferingChange(event:BufferEvent):void {
			event.target.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			event.target.bufferTime = BUFFER_TIME;
		}
		
		public override function set source(value:Object):void {
			// Setting source to null and forcing gc fixes a memory leak inherent in OSMF (not on iPad unfortunately)
			super.source = null;
			System.gc();
			super.source = value;
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			stop();
			super.source = null;
			System.gc();
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
		if (mfi && mfi.id.indexOf('org.osmf') < 0) {
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