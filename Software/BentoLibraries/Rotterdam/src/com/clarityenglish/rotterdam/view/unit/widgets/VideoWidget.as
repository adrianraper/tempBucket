package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.events.VideoEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class VideoWidget extends AbstractWidget {
		
		[SkinPart]
		public var videoHolder:Group;
		
		[SkinPart]
		public var videoPlayer:IVideoPlayer;
		
		public function VideoWidget() {
			super();
			
			addEventListener("srcAttrChanged", reloadVideo, false, 0, true);
			
			// gh#215
			addEventListener(FlexEvent.HIDE, stopVideo, false, 0, true);
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get src():String {
			return _xml.@src;
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get hasSrc():Boolean {
			return _xml.hasOwnProperty("@src");
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case videoPlayer:
					videoPlayer.addEventListener(VideoEvent.VIDEO_CLICK, onVideoClick);
					reloadVideo();
					break;
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			widgetText.width = width;
			
			if (videoPlayer) {
				videoPlayer.width = width - 16;
				videoPlayer.height = videoHolder.height - 8;
				videoPlayer.x = 8;
				videoPlayer.play();
			}
		}
		
		protected function reloadVideo(event:Event = null):void {
			if (hasSrc && videoPlayer) videoPlayer.source = src;
		}
		
		// gh#215
		protected function stopVideo(event:Event = null):void {
			if (videoPlayer) videoPlayer.stop();
		}
		
		// gh#106
		protected function onVideoClick(event:VideoEvent):void {
			playVideo.dispatch(xml);
			videoPlayer.removeEventListener(VideoEvent.VIDEO_CLICK, onVideoClick); // only register one click per video
		}
		
	}
}
