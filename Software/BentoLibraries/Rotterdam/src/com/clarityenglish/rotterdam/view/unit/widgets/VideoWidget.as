package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.events.VideoEvent;
	import com.clarityenglish.controls.video.events.VideoSpanButtonBarEvent;
	import com.clarityenglish.controls.video.players.FlashVideoPlayer;
	import com.clarityenglish.controls.video.players.OSMFVideoPlayer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	
	import skins.rotterdam.unit.widgets.WidgetChrome;
	
	import spark.components.Group;
	
	public class VideoWidget extends AbstractWidget {
		
		[SkinPart]
		public var videoHolder:Group;
		
		[SkinPart]
		public var videoPlayer:IVideoPlayer;

		private var _hideSpanButtonBar:Boolean;
		
		public function VideoWidget() {
			super();
			
			addEventListener("srcAttrChanged", reloadVideo, false, 0, true);
			
			// gh#215
			addEventListener(FlexEvent.HIDE, stopVideo, false, 0, true);
			
			// hiding span button bar for youku video
			addEventListener(VideoSpanButtonBarEvent.SPANBUTTONBAR_HIDE, onHideSpanButtonBar);
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get src():String {
			return _xml.@src;
		}
		
		[Bindable(event="srcAttrChanged")]
		public function get hasSrc():Boolean {
			return _xml.hasOwnProperty("@src");
		}

		public function get hideSpanButtonBar():Boolean {
			return _hideSpanButtonBar;
		}
		
		public override function updateSrc(value:String):void {
			reloadVideo();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case videoPlayer:
					videoPlayer.addEventListener(VideoEvent.VIDEO_CLICK, onVideoClick);
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
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();

			// hiding span button bar for youku video
			if (widgetChrome)
				widgetChrome.hideSpanButtonBar = hideSpanButtonBar;
		}
		
		protected function reloadVideo(event:Event = null):void {
			if (hasSrc && videoPlayer) {
				videoPlayer.source = src;
			}
		}
		
		// gh#215
		protected function stopVideo(event:Event = null):void {
			if (videoPlayer) videoPlayer.stop();
			if (videoPlayer) videoPlayer.visible = false;
		}
		
		// gh#106
		protected function onVideoClick(event:VideoEvent):void {
			playVideo.dispatch(xml);
			videoPlayer.removeEventListener(VideoEvent.VIDEO_CLICK, onVideoClick); // only register one click per video
		}
		
		// hiding span button bar for youku video
		protected function onHideSpanButtonBar(event:VideoSpanButtonBarEvent):void {
			_hideSpanButtonBar = event.isHideSpanButtonBar;
			invalidateProperties();
		}
	}
}
