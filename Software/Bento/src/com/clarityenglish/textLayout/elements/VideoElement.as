package com.clarityenglish.textLayout.elements {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.formats.FormatValue;
	import flashx.textLayout.tlf_internal;
	
	import mx.controls.SWFLoader;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaPlayerState;
	
	import spark.components.VideoPlayer;

	use namespace tlf_internal;
	
	public class VideoElement extends ImageComponentElement implements IComponentElement {
		
		private static const NORMAL:String = "normal";
		private static const YOU_TUBE:String = "you_tube";
		
		private static var inititalized:Boolean = false;
		
		private var _src:String;
		
		private var _autoPlay:Boolean = true;
		
		private var _videoDimensionsCalculated:Boolean;
		
		public function VideoElement() {
			super();
			
			// Allow www.youtube.com (only do this once)
			if (!inititalized) {
				Security.allowDomain("www.youtube.com");
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
		
		public function set autoPlay(value:Boolean):void {
			_autoPlay = value;
		}
		
		public function createComponent():void {
			switch(getVideoType()) {
				case NORMAL:
					var videoPlayer:VideoPlayer = new VideoPlayer();
					videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange, false, 0, true);
					
					videoPlayer.source = _src;
					videoPlayer.width = width;
					videoPlayer.height = height;
					videoPlayer.autoPlay = _autoPlay;
					
					component = videoPlayer;
					break;
				case YOU_TUBE:
					var swfLoader:SWFLoader = new SWFLoader();
					swfLoader.addEventListener(Event.COMPLETE, onYouTubeComplete, false, 0, true);
					
					swfLoader.scaleContent = false;
					swfLoader.maintainAspectRatio = true;
					swfLoader.load(_src);
					
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
			switch (event.state) {
				case MediaPlayerState.PLAYING:
				case MediaPlayerState.PAUSED:
					if (!_videoDimensionsCalculated) {
						if (isAutoWidth())
							elementWidth = component.width = (component as VideoPlayer).videoObject.videoWidth;
						
						if (isAutoHeight())
							elementHeight = component.height = (component as VideoPlayer).videoObject.videoHeight;
						
						_videoDimensionsCalculated = true;
						
						getTextFlow().dispatchEvent(new StatusChangeEvent(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, true, false, this, InlineGraphicElementStatus.SIZE_PENDING));
					}
					break;
			}
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
		
		public override function getElementBounds():Rectangle {
			if (component && graphic && graphic.parent)
				return new Rectangle(graphic.parent.x, graphic.parent.y, component.width, component.height);
			
			return null;
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
		 * 
		 * @return 
		 */
		private function getVideoType():String {
			return (_src.search(/www\.youtube\.com/) >= 0) ? YOU_TUBE : NORMAL;
		}
		
	}
	
}
