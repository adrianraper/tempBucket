package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.controls.video.IVideoPlayer;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	public class VideoWidget extends AbstractWidget {
		
		[SkinPart]
		public var videoHolder:Group;
		
		[SkinPart]
		public var swfLoader:SWFLoader;
		
		[SkinPart]
		public var videoPlayer:IVideoPlayer;

		// gh#106
		private var recordFlag:Boolean;
		
		private var player:Object;
		
		public function VideoWidget() {
			super();
			
			recordFlag = true;
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
				case swfLoader:
					swfLoader.addEventListener(Event.COMPLETE, onSwfLoaderComplete);
					swfLoader.scaleContent = true;
					swfLoader.maintainAspectRatio = true;
					reloadVideo();
					break;
				case videoPlayer:
					reloadVideo();
					break;
			}
		}
		
		protected function onSwfLoaderComplete(event:Event):void {
			event.target.content.addEventListener("onReady", resizeVideo, false, 0, true);
			// gh#106
			event.target.content.addEventListener(MouseEvent.CLICK, onClickVideo);
		}
		
		protected function reloadVideo(event:Event = null):void {
			if (hasSrc) {
				if (swfLoader) swfLoader.load(src);
				
				if (videoPlayer) {
					videoPlayer.source = src;
				}
			}
		}
		
		protected function resizeVideo(event:Event = null):void {
			if (swfLoader && swfLoader.content && swfLoader.content["setSize"] && videoHolder) {
				swfLoader.content["setSize"](width - 16, videoHolder.height - 12);
				widgetText.width = width;
				
				// These three lines are a bit hacky, but otherwise the YouTube video doesn't want to centre itself properly
				swfLoader.x = 8;
				//swfLoader.height = videoHolder.height + 12;
				invalidateSize();
			}
			
			if (videoPlayer) {
				videoPlayer.width = width - 16;
				videoPlayer.height = videoHolder.height - 8;
				videoPlayer.x = 4;
				videoPlayer.play();
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			resizeVideo();
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			removeEventListener("srcAttrChanged", reloadVideo);
		}
		
		// gh#106
		protected function onClickVideo(event:MouseEvent):void {
			if (recordFlag)
				playVideo.dispatch(xml);
			
			recordFlag = false;
		}
		
		// gh#215
		private function stopVideo(event:Event = null):void {
			if (swfLoader && swfLoader.content) {
				player = swfLoader.content;
				player.stopVideo();
				// This was merged from Alice - not too sure what its about... check when we get the new video ANE component
			}

			if (videoPlayer) videoPlayer.stop();
		}
		
	}
}
