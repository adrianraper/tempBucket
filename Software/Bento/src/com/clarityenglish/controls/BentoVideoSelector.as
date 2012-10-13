package com.clarityenglish.controls {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.setTimeout;
	
	import mx.collections.IList;
	import mx.core.mx_internal;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.Closure;
	import org.osflash.signals.Signal;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	
	import spark.components.ButtonBar;
	import spark.components.Image;
	import spark.components.List;
	import spark.components.VideoPlayer;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	/**
	 * This is generally rather messy and needs to be rewritten.
	 */
	[Event(name="videoSelected", type="com.clarityenglish.controls.BentoVideoSelectorEvent")]
	public class BentoVideoSelector extends SkinnableComponent {
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		// This is the OSMF video player TODO: These should be combined with a neat interface
		[SkinPart]
		public var videoPlayer:VideoPlayer;
		
		// This is the iOS video player TODO: These should be combined with a neat interface
		[SkinPart]
		public var webViewVideoPlayer:WebViewVideoPlayer;
		
		[SkinPart]
		public var placeholderImage:Image;
		
		[SkinPart(required="true")]
		public var channelButtonBar:ButtonBar;
		
		[SkinPart(required="true")]
		public var videoList:List;
		
		protected var _channelCollection:IList;
		protected var _channelCollectionChanged:Boolean;
		
		protected var _videoCollection:IList;
		protected var _videoCollectionChanged:Boolean;
		
		protected var _placeholderSource:Object;
		protected var _placeholderSourceChanged:Boolean;
		
		protected var _autoPlay:Boolean;
		protected var _autoPlayChanged:Boolean;
		
		private var videoHref:Href;
		private var zoneSelected:String;
		private var urlLoader:URLLoader;
		private var pluginFlag:Boolean;
		private var streamName:String;
		private var channelName:String;
		
		// TODO: This absolutely shouldn't know anything about ConfigProxy
		public var configProxy:ConfigProxy;
		
		[Bindable]
		public var viewHref:Href;
		
		[Bindable]
		public var courseSelected:String;
		
		[Bindable]
		public var zone:String;
		
		[Bindable]
		public var showSelector:Boolean = true;
		
		public static var selectedChannelIndex:int = 0;
		
		private static const PLUGIN:String = "http://players.edgesuite.net/flash/plugins/osmf/advanced-streaming-plugin/v2.8/osmf2.0/AkamaiAdvancedStreamingPlugin.swf";
		
		public var videoSelected:Signal = new Signal(Href, String);
		public var videoPlayerStateChange:Signal = new Signal(MediaPlayerStateChangeEvent);
		
		[Bindable]
		public function get channelCollection():IList {
			return _channelCollection;
		}
		
		public function set channelCollection(value:IList):void {
			if (_channelCollection !== value) {
				_channelCollection = value;
				_channelCollectionChanged = true;
				
				invalidateProperties();
			}
		}
		
		[Bindable]
		public function get videoCollection():IList {
			return _videoCollection;
		}
		
		public function set videoCollection(value:IList):void {
			if (_videoCollection !== value) {
				_videoCollection = value;
				_videoCollectionChanged = true;
				
				invalidateProperties();
			}
		}
		
		[Bindable]
		public function get placeholderSource():Object {
			return _placeholderSource;
		}
		
		public function set placeholderSource(value:Object):void {
			if (_placeholderSource !== value) {
				_placeholderSource = value;
				_placeholderSourceChanged = true;
				
				invalidateProperties();
			}
		}
		
		[Bindable]
		public function get autoPlay():Boolean {
			return _autoPlay;
		}
		
		public function set autoPlay(value:Boolean):void {
			_autoPlay = value;
			_autoPlayChanged = true;
			invalidateProperties();
		}
		
		public function BentoVideoSelector() {
			super();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_channelCollectionChanged) {
				_channelCollectionChanged = false;
				channelButtonBar.dataProvider = _channelCollection;
			}
			
			if (_videoCollectionChanged) {
				_videoCollectionChanged = false;
				videoList.dataProvider = _videoCollection;
			}
			
			if (_placeholderSourceChanged) {
				_placeholderSourceChanged = false;
			}
			
			if (_autoPlayChanged) {
				_autoPlayChanged = false;
				if (_autoPlay) {
					// Horribly hacky, but this whole component needs to be rewritten anyway
					setTimeout(function():void {
						if (videoList.dataProvider.length > 0) {
							videoList.selectedItem = videoList.dataProvider[0];
							videoList.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE, true, false, -1, 0));
							zoneVideoSelected(videoList.selectedItem.@href);
						}
					}, 2000);
				}
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case videoPlayer:
					videoPlayer.videoDisplay.mx_internal::mediaFactory = new SmoothingMediaFactory();
					videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
					videoPlayer.addEventListener(TimeEvent.COMPLETE, onVideoPlayerComplete);
					break;
				case webViewVideoPlayer:
					break;
				case channelButtonBar:
					channelButtonBar.addEventListener(IndexChangeEvent.CHANGE, onChannelClicked);
					break;
				case videoList:
					videoSelected.add(onVideoSelected);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case videoList:
					videoSelected.remove(onVideoSelected);
					break;
			}
		}
		
		public function loadPlugin():void {
			if (videoPlayer) {
				var pluginResource:MediaResourceBase = new URLResource(PLUGIN);
				videoPlayer.videoDisplay.mx_internal::mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoad);
				videoPlayer.videoDisplay.mx_internal::mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);
				videoPlayer.videoDisplay.mx_internal::mediaFactory.loadPlugin(pluginResource);
			}
		}
		
		public function rssLoad(href:Href):void {
			var videoSource:String = href.url;
			
			if (videoSource.match(/\.(rss|xml)$/)) {
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, Closure.create(this, onRssLoadComplete, configProxy));
				urlLoader.load(new URLRequest(videoSource));
			} else {
				setVideoSource(videoSource);
				// #63
				callLater(function():void {
					play()
				});
			}
		}
		
		public function zoneVideoSelected(filename:String):void {
			//trace("The advice video player's choice is " + selectedChannelIndex);
			channelButtonBar.selectedIndex = selectedChannelIndex;
			videoHref = viewHref.createRelativeHref(null, filename);
			zoneSelected = zone;
			videoSelected.dispatch(videoHref, zoneSelected);
			trace("file href=" + videoHref);
			trace("selected channel = " + channelButtonBar.selectedItem.name);
		}
		
		private function onPluginLoad(event:MediaFactoryEvent):void {
			trace("the plug-in loaded successfully.");
			pluginFlag = true;
		}
		
		private function onPluginLoadError(event:MediaFactoryEvent):void {
			trace("the plug-in failed to load.");
			pluginFlag = false;
		}
		
		private function onRssLoadComplete(e:Event, configProxy:ConfigProxy):void {
			var dynamicList:XML = new XML(e.target.data);
			
			if (dynamicList.channel.hasOwnProperty("@name")) {
				var channel:XML = dynamicList.channel.(@name == channelName)[0];
				var protocol:String = (channel) ? channel.@protocol.toString() : "";
			} else {
				channel = dynamicList.channel[0];
				protocol = (channel) ? channel.streaming.toString() : "";
			}
			var host:String = (channel) ? channel.host.toString() : "";
			
			if (host.indexOf('{streamingMedia}') >= 0) host = host.replace("{streamingMedia}", streamName);
			if (host.indexOf('{contentPath}') >= 0) host = host.replace("{contentPath}", configProxy.getContentPath());
			
			switch (protocol) {
				case "rtmp":
					var server:String = channel.server.toString();
					var dynamicSource:DynamicStreamingResource = new DynamicStreamingResource(host);
					dynamicSource.urlIncludesFMSApplicationInstance = (server == "fms");
					
					dynamicSource.streamType = channel.type.toString();
					var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
					for each (var stream:XML in channel.item) {
						var streamingItem:DynamicStreamingItem = new DynamicStreamingItem(stream.streamName, stream.bitrate);
						streamItems.push(streamingItem);
					}
					dynamicSource.streamItems = streamItems;
					
					setVideoSource(dynamicSource);
					play();
					break;
				// Rackspace's pseudo streaming over http
				case "http":
					if (pluginFlag) {
						setVideoSource(host + channel.item[0].streamName.toString() + ".flv");
					} else {
						trace("warning: Plugin fail to load!");
					}
					play()
					break;
				case "progressive-download":
				case "http-streaming":
					setVideoSource(host + channel.item[0].streamName.toString());
					play();
					break;
				default:
					//log.error(protocol + " streaming type not supported");
					stop();
					setVideoSource(null);
			}
			
			// Allow the listener to be garbage collected
			urlLoader = null;
		}
		
		protected function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
			log.debug("VIDEO PLAYER STATE CHANGE: " + event.state);
			
			// React to some states
			switch (event.state) {
				case "playbackError":
					// Load an error message onto the video player
					// That can be done with a state in the skin
					break;
				case "buffering":
				case "loading":
				case "uninitialized":
					// Run the loading animation
					break;
				case "playing":
					break;
				default:
					// Just play
			}
			
			// Trigger the signal in case the mediator wants to take action too
			videoPlayerStateChange.dispatch(event);
		}
		
		protected function onVideoPlayerComplete(event:TimeEvent):void {
			// When a video in advice zone reaches the end deselect the video in the list so we don't end up with a floating 'loading...'
			if (zone == "advice-zone")
				videoList.selectedItem = null;
		}
		
		protected function onChannelClicked(event:IndexChangeEvent):void {
			selectedChannelIndex = event.target.selectedIndex;
			videoSelected.dispatch(videoHref, zoneSelected);
		}
		
		private function onVideoSelected(href:Href, zoneName:String):void {
			channelName = channelButtonBar.selectedItem.name;
			streamName = channelButtonBar.selectedItem.streamName;
			if (videoPlayer) videoPlayer.videoDisplay.mx_internal::videoPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange, false, 0, true);
			dispatchEvent(new BentoVideoSelectorEvent(BentoVideoSelectorEvent.VIDEO_SELECTED));
			rssLoad(href);
		}
		
		protected function onBufferingChange(event:Event):void {
			event.target.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			event.target.bufferTime = 4;
		}
		
		private function setVideoSource(source:Object):void {
			if (videoPlayer) {
				// Setting source to null and forcing gc fixes a memory leak inherent in OSMF (not on iPad unfortunately)
				videoPlayer.source = null;
				System.gc();
				videoPlayer.source = source;
			}
			
			if (webViewVideoPlayer) {
				webViewVideoPlayer.source = source;
			}
		}
		
		private function play():void {
			if (videoPlayer) callLater(videoPlayer.play);
			if (webViewVideoPlayer) callLater(webViewVideoPlayer.play);
		}
		
		private function stop():void {
			if (videoPlayer) videoPlayer.stop();
			if (webViewVideoPlayer) webViewVideoPlayer.stop();
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
