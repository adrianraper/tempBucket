package com.clarityenglish.controls {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
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
	
	[Event(name = "videoSelected", type = "com.clarityenglish.controls.BentoVideoSelectorEvent")]
	public class BentoVideoSelector extends SkinnableComponent {
		
		[SkinPart(required = "true")]
		public var videoPlayer:VideoPlayer;
		
		[SkinPart(required = "true")]
		public var channelButtonBar:ButtonBar;
		
		//[SkinPart(required="true")]
		//public var qualityButtonBar:ButtonBar;
		
		[SkinPart(required = "true")]
		public var videoImage1:Image;
		
		[SkinPart(required = "true")]
		public var videoImage2:Image;
		
		[SkinPart(required = "true")]
		public var videoImage3:Image;
		
		[SkinPart(required = "true")]
		public var videoImage4:Image;
		
		[SkinPart(required = "true")]
		public var videoList:List;
		
		protected var _courseSelected:String;
		
		protected var _viewHref:Href;
		
		protected var _channelCollection:ArrayCollection;
		protected var _channelCollectionChanged:Boolean;
		
		protected var _zone:String;
		
		private var videoHref:Href;
		private var zoneSelected:String;
		private var urlLoader:URLLoader;
		public var pluginFlag:Boolean;
		public var streamName:String;
		public var channelName:String;
		public var configProxy:ConfigProxy;
		public static var selectedChannelIndex:int = 0;
		
		private static const PLUGIN:String = "http://players.edgesuite.net/flash/plugins/osmf/advanced-streaming-plugin/v2.8/osmf2.0/AkamaiAdvancedStreamingPlugin.swf";
		
		public var videoSelected:Signal = new Signal(Href, String);
		public var videoPlayerStateChange:Signal = new Signal(MediaPlayerStateChangeEvent);
		//public var exerciseSelect:Signal = new Signal(Href);
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		
		[Bindable]
		public function get courseSelected():String {
			return _courseSelected;
		}
		
		public function set courseSelected(value:String):void {
			if (_courseSelected != value) {
				_courseSelected = value;
				trace("courseSelected = " + _courseSelected);
			}
		}
		
		[Bindable]
		public function get viewHref():Href {
			return _viewHref;
		}
		
		public function set viewHref(value:Href):void {
			if (_viewHref !== value) {
				_viewHref = value;
			}
		}
		
		[Bindable]
		public function get channelCollection():ArrayCollection {
			return _channelCollection;
		}
		
		public function set channelCollection(value:ArrayCollection):void {
			if (_channelCollection !== value) {
				_channelCollection = value;
				_channelCollectionChanged = true;
				
				invalidateProperties();
			}
		}
		
		[Bindable]
		public function get zone():String {
			return _zone;
		}
		
		public function set zone(value:String):void {
			if (_zone !== value) {
				_zone = value;
			}
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
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case videoPlayer:
					videoPlayer.videoDisplay.mx_internal::mediaFactory = new SmoothingMediaFactory();
					
					videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
					videoPlayer.addEventListener(TimeEvent.COMPLETE, onVideoPlayerComplete);
					break;
				case channelButtonBar:
					channelButtonBar.addEventListener(IndexChangeEvent.CHANGE, onChannelClicked);
					break;
				//case qualityButtonBar:
				//qualityButtonBar.addEventListener(IndexChangeEvent.CHANGE, onQualityClicked);
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
			//var resource:URLResource=new URLResource(PLUGIN);
			var pluginResource:MediaResourceBase = new URLResource(PLUGIN);
			videoPlayer.videoDisplay.mx_internal::mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoad);
			videoPlayer.videoDisplay.mx_internal::mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);
			videoPlayer.videoDisplay.mx_internal::mediaFactory.loadPlugin(pluginResource);
		}
		
		public function rssLoad(href:Href):void {
			var videoSource:String = href.url;
			
			if (videoSource.match(/\.(rss|xml)$/)) {
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, Closure.create(this, onRssLoadComplete, configProxy));
				urlLoader.load(new URLRequest(videoSource));
			} else {
				videoPlayer.source = videoSource;
				// #63
				callLater(function():void {
					videoPlayer.play();
				});
			}
		}
		
		public function zoneVideoSelected(filename:String):void {
			//trace("The advice video player's choice is " + selectedChannelIndex);
			channelButtonBar.selectedIndex = selectedChannelIndex;
			videoHref = _viewHref.createRelativeHref(null, filename);
			zoneSelected = _zone;
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
				//var item:XMLList = dynamicList.channel.(@name==channelName).item;				
				var protocol:String = channel.@protocol.toString();
			} else {
				channel = dynamicList.channel[0];
				protocol = channel.streaming.toString();
			}
			var host:String = channel.host.toString();
			
			if (host.indexOf('{streamingMedia}') >= 0)
				host = host.replace("{streamingMedia}", streamName);
			if (host.indexOf('{contentPath}') >= 0)
				host = host.replace("{contentPath}", configProxy.getContentPath());
			
			switch (protocol) {
				case "rtmp":
					var server:String = channel.server.toString();
					var dynamicSource:DynamicStreamingResource = new DynamicStreamingResource(host);
					
					if (server == "fms")
						dynamicSource.urlIncludesFMSApplicationInstance = true;
					
					dynamicSource.streamType = channel.type.toString();
					var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
					for each (var stream:XML in channel.item) {
						var streamingItem:DynamicStreamingItem = new DynamicStreamingItem(stream.streamName, stream.bitrate);
						streamItems.push(streamingItem);
					}
					dynamicSource.streamItems = streamItems;
					
					videoPlayer.source = dynamicSource;
					callLater(videoPlayer.play);
					break;
				// Rackspace's pseudo streaming over http
				case "http":
					//videoPlayer.source = host + channel.item[0].streamName.toString() + ".f4m";
					if (pluginFlag) {
						videoPlayer.source = host + channel.item[0].streamName.toString() + ".flv";
					} else {
						trace("warning: Plugin fail to load!");
					}
					callLater(videoPlayer.play);
					break;
				case "progressive-download":
					videoPlayer.source = host + channel.item[0].streamName.toString();
					callLater(videoPlayer.play);
					break;
				default:
					//log.error(protocol + " streaming type not supported");
					videoPlayer.stop();
					videoPlayer.source = null;
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
			if (_zone == "advice-zone")
				videoList.selectedItem = null;
		}
		
		protected function onChannelClicked(event:IndexChangeEvent):void {
			// the quality stuff is used to retrieve quality information of each channe which need to clear before new data transfered
			//qualityArray = [];
			//qualityCollection.removeAll();
			//qualityButtonBar.dataProvider = null;
			selectedChannelIndex = event.target.selectedIndex;
			videoSelected.dispatch(videoHref, zoneSelected);
		}
		
		private function onVideoSelected(href:Href, zoneName:String):void {
			channelName = channelButtonBar.selectedItem.name;
			streamName = channelButtonBar.selectedItem.streamName;
			videoPlayer.videoDisplay.mx_internal::videoPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			dispatchEvent(new BentoVideoSelectorEvent(BentoVideoSelectorEvent.VIDEO_SELECTED));
			rssLoad(href);
		}
		
		protected function onBufferingChange(event:Event):void {
			//trace("buffering change, bufferTime is " + event.target.bufferTime);
			event.target.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
			event.target.bufferTime = 4;
		}
	
	}
}
import org.osmf.elements.VideoElement;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaResourceBase;

class SmoothingMediaFactory extends DefaultMediaFactory {
	
	private var _highjackedMediaCreationFunction:Function;
	
	protected override function resolveItems(resource:MediaResourceBase, items:Vector.<MediaFactoryItem>):MediaFactoryItem {
		var mfi:MediaFactoryItem = super.resolveItems(resource, items);
		/*If a custom MFI is being used, hijack it and intercept the media element it returns to set smoothing on it*/
		if (mfi.id.indexOf('org.osmf') < 0) {
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
