package com.clarityenglish.rotterdam.view.unit.widgets {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	
	import mx.controls.SWFLoader;
	
	import spark.components.Group;
	
	public class VideoWidget extends AbstractWidget {
		
		[SkinPart]
		public var videoHolder:Group;
		
		[SkinPart]
		public var swfLoader:SWFLoader;
		
		public function VideoWidget() {
			super();
			
			addEventListener("srcAttrChanged", reloadVideo, false, 0, true);
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
			}
		}
		
		protected function onSwfLoaderComplete(event:Event):void {
			event.target.content.addEventListener("onReady", resizeVideo, false, 0, true);
			//alice: Detect video play
			event.target.content.addEventListener(MouseEvent.CLICK, onClickVideo);
		}
		
		protected function reloadVideo(event:Event = null):void {
			if (hasSrc)
				swfLoader.load(src)
		}
		
		protected function resizeVideo(event:Event = null):void {
			if (swfLoader && swfLoader.content && swfLoader.content["setSize"] && videoHolder) {
				swfLoader.content["setSize"](width - 16, videoHolder.height);
				
				// These three lines are a bit hacky, but otherwise the YouTube video doesn't want to centre itself properly
				swfLoader.x = 8;
				swfLoader.height = videoHolder.height + 12;
				invalidateSize();
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
		
		//alice: Detect video play
		protected function onClickVideo(event:MouseEvent):void {
				trace("click video widget");
			
		}
		
	}
}
