package com.clarityenglish.controls.video.loaders {
	import com.clarityenglish.common.vo.config.ChannelObject;
	import com.clarityenglish.controls.video.IVideoLoader;
	import com.clarityenglish.controls.video.IVideoPlayer;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.Closure;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	
	public class RssVideoLoader implements IVideoLoader {
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var videoPlayer:IVideoPlayer;
		
		private var urlLoader:URLLoader;
		
		public function RssVideoLoader(videoPlayer:IVideoPlayer) {
			this.videoPlayer = videoPlayer;
		}
		
		public function load(source:Object, channelObject:ChannelObject = null):void {
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, Closure.create(this, onUrlLoaderComplete, channelObject), false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError, false, 0, true);
			urlLoader.load(new URLRequest(source.toString()));
		}
		
		protected function onUrlLoaderComplete(event:Event, channelObject:ChannelObject):void {	
			var dynamicList:XML = new XML(event.target.data);
			
			// If any channel has a @name attribute, then search for the channel name; otherwise just select the first entry
			// TODO: This was originally in Alice's code, but I'm not sure if it is necessary?
			var channel:XML = dynamicList.channel.hasOwnProperty("@name") ? dynamicList.channel.(@name == channelObject.name)[0] : dynamicList.channel[0];
			var protocol:String = (channel) ? channel.@protocol.toString() : "";
			
			var host:String = (channel) ? channel.host.toString() : "";
			
			// Replace any {streamingMedia} substrings with the streamingMedia url defined in the channel object
			if (host.indexOf('{streamingMedia}') >= 0) host = host.replace("{streamingMedia}", channelObject.streamingMedia);
			
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
					
					videoPlayer.source = dynamicSource;
					videoPlayer.play();
					break;
				case "progressive-download":
				case "http-streaming":
				case "http":
					videoPlayer.source = host + channel.item[0].streamName.toString();
					videoPlayer.play();
					break;
				default:
					videoPlayer.stop();
					videoPlayer.source = null;
			}
			
			// Allow the listener to be garbage collected
			urlLoader = null;
		}
		
		private function onIoError(event:IOErrorEvent):void {
			log.error("IO error - {0}", event.text);
		}
	
	}
}
