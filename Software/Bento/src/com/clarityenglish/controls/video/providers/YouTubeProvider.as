package com.clarityenglish.controls.video.providers {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.IVideoProvider;
	import com.clarityenglish.controls.video.events.VideoEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.controls.SWFLoader;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class YouTubeProvider implements IVideoProvider {
		
		protected var videoPlayer:IVideoPlayer;
		
		protected var swfLoader:SWFLoader;
		
		public function YouTubeProvider(videoPlayer:IVideoPlayer) {
			this.videoPlayer = videoPlayer;
		}
		
		/**
		 * A helper function to get the id out of the YouTube source
		 * 
		 * @param source
		 * @return 
		 */
		protected function getId(source:Object):String {
			var matches:Array = (source.toString()) ? source.toString().match(/^(\w+):?(.*)$/i) : null;
			return matches[2];
		}
		
		/**
		 * This provider applies if the source is in the format 'youtube:<id>'
		 *  
		 * @param source
		 * @return 
		 * 
		 */
		public function canHandleSource(source:Object):Boolean {
			var matches:Array = (source.toString()) ? source.toString().match(/^(\w+):?(.*)$/i) : null;
			if (!matches || matches.length < 3) return false;
			return matches[1] == "youtube";
		}
		
		/**
		 * This returns the HTML version of the provider (used for AIR)
		 * 
		 * @param source
		 * @return 
		 */
		public function getHtml(source:Object):String {
			var html:String = "";
			html += "<!DOCTYPE html>";
			html += "<html>";
			html += "<body style='margin:0;padding:0;border:0;overflow:hidden;'>";
			html += "	<iframe id='ytplayer' style='position:absolute;top:0px;width:100%;height:100%'";
			html += "			type='text/html'";
			html += "			src='http://www.youtube.com/embed/" + getId(source) + "?rel=0&fs=1'";
			html += "			frameborder='0'>";
			html += "	</iframe>";
			html += "</body>";
			html += "</html>";
			return html;
		}
		
		public function create(source:Object):void {
			swfLoader = new SWFLoader();
			swfLoader.percentWidth = swfLoader.percentHeight = 100;
			swfLoader.scaleContent = true;
			swfLoader.maintainAspectRatio = true;
			swfLoader.addEventListener(Event.COMPLETE, onSwfLoaderComplete, false, 0, true);
			
			swfLoader.load("http://www.youtube.com/v/" + getId(source) + "?version=3");
			
			(videoPlayer as IVisualElementContainer).addElement(swfLoader);
		}
		
		protected function onSwfLoaderComplete(event:Event):void {
			swfLoader.removeEventListener(Event.COMPLETE, onSwfLoaderComplete);
			swfLoader.content.addEventListener("onReady", onReady); // gh#328
			swfLoader.content.addEventListener(MouseEvent.CLICK, onClickVideo); // gh#106
		}
		
		protected function onReady(e:Event):void {
			resize();
		}
		
		public function resize():void {
			if (swfLoader && swfLoader.content && swfLoader.content["setSize"]) {
				swfLoader.content["setSize"](videoPlayer.width, videoPlayer.height);
				swfLoader.x = 8; // A bit hacky, but otherwise it doesn't centre properly
			}
		}
		
		public function play():void {
			if (swfLoader && swfLoader.content && swfLoader.content["playVideo"])
				swfLoader.content["playVideo"]();
		}
		
		public function stop():void {
			if (swfLoader && swfLoader.content && swfLoader.content["stopVideo"])
				swfLoader.content["stopVideo"]();
		}
		
		protected function onClickVideo(event:MouseEvent):void {
			videoPlayer.dispatchEvent(new VideoEvent(VideoEvent.VIDEO_CLICK, true)); // gh#106
		}
		
		public function destroy():void {
			stop();
			(videoPlayer as IVisualElementContainer).removeElement(swfLoader);
			swfLoader.content.removeEventListener("onReady", onReady);
			swfLoader.content.removeEventListener(MouseEvent.CLICK, onClickVideo);
			swfLoader.source = null;
			swfLoader = null;
		}
		
	}
}