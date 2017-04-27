package com.clarityenglish.controls.video.providers {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.IVideoProvider;
	import com.clarityenglish.controls.video.events.VideoEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.SWFLoader;
	import mx.core.IVisualElementContainer;
	
	public class YouTubeProvider implements IVideoProvider {
		
		protected var videoPlayer:IVideoPlayer;
		
		protected var swfLoader:SWFLoader;
		
		protected var urlPattern:RegExp;
		protected var srcPattern:RegExp;
		protected var urlBase:String;
		protected var srcBase:String;
		protected var idPattern:RegExp;
		
		public function YouTubeProvider(videoPlayer:IVideoPlayer = null) {
			this.videoPlayer = videoPlayer;
			
			// gh#875
			//var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			//urlPattern = copyProvider.getCopyForId('youTubePattern');
			urlPattern = /(?:youtube(?:-nocookie)?\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|(?:youtu\.be\/))([^"&?\/ ]{11})/i;
			srcPattern = /youtube:([\w-]+)/i;
			urlBase = 'https:\/\/youtu.be\/{id}';
			srcBase = 'youtube:{id}';
			idPattern = /{id}/i;
		}
		
		/**
		 * A helper function to get the id out of the YouTube source
		 * 
		 * @param source
		 * @return 
		 */
		protected function getId(source:Object):String {
			var matches:Array = source.match(urlPattern);
			return matches[1];
		}
		
		/**
		 * A helper function to get the id out of the stored src
		 * gh#875
		 * @param source
		 * @return 
		 */
		protected function getIdFromSrc(source:Object):String {
			var matches:Array = source.match(srcPattern);
			return matches[1];
		}
		
		/**
		 * This provider applies if the source is in the format 'youtube.com'
		 *  
		 * @param source
		 * @return 
		 * 
		 */
		public function canHandleSource(source:Object):Boolean {
			// The current YouTube video link looks like
			//   https://youtu.be/oSn3i4vsGeY
			// others look like
			//   http://www.youtube.com/embed/xxx?rel=0
			// or 
			//   http://www.youtube.com/v/xxx?version=3
			//   http://www.youtube.com/watch?v=2ZVNGpU0wAg&list=UUJlUJ35AxJkS7nw90AWUZtw&feature=share&index=3
			
			// Just for reference, you can get a still shot of the video from http://img.youtube.com/vi/xxx/0.jpg
			// pattern from http://stackoverflow.com/questions/2936467/parse-youtube-video-id-using-preg-match
			var matches:Array = source.match(urlPattern);
			return (matches && matches.length == 2);
		}
		
		/**
		 * This provider applies if the src is in the format 'youtube:12345678'
		 * gh#875
		 * @param source
		 * @return 
		 * 
		 */
		public function isRightProvider(source:Object):Boolean {
			var matches:Array = source.match(srcPattern);
			return (matches && matches.hasOwnProperty(1) && matches[1] != null);
		}
		
		/**
		 * gh#875 Create a URL that the video player can use from the current provider URL and the id
		 * 
		 */
		public function toSource(src:Object):Object {
			//return 'https://youtu.be/' + this.getIdFromSrc(src);
			//return copyProvider.getCopyForId('youTubeBase', {id: this.getIdFromSrc(src)});
			return urlBase.replace(idPattern, this.getIdFromSrc(src));
		}
		
		/**
		 * gh#875 Create an exercise node format from the URL
		 * 
		 */
		public function fromSource(source:Object):Object {
			//return 'youtube:' + this.getId(source); 
			return srcBase.replace(idPattern, this.getId(source));
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
			swfLoader.scaleContent = false;
			swfLoader.maintainAspectRatio = true;
			swfLoader.addEventListener(Event.COMPLETE, onSwfLoaderComplete, false, 0, true);
			
			swfLoader.load("http://www.youtube.com/v/" + getId(source) + "?version=3");
			
			(videoPlayer as IVisualElementContainer).addElement(swfLoader);
		}
		
		protected function onSwfLoaderComplete(event:Event):void {
			if (swfLoader) {
				swfLoader.removeEventListener(Event.COMPLETE, onSwfLoaderComplete);
				swfLoader.content.addEventListener("onReady", onReady); // gh#328
				swfLoader.content.addEventListener(MouseEvent.CLICK, onClickVideo); // gh#106
			}
		}
		
		protected function onReady(e:Event):void {
			resize();
		}

        // gh#1456
		public function resize():void {
			if (swfLoader && swfLoader.content && swfLoader.content.hasOwnProperty('setSize') && swfLoader.content["setSize"])
				swfLoader.content["setSize"](videoPlayer.width, videoPlayer.height);
		}
		
		public function play():void {
			if (swfLoader && swfLoader.content && swfLoader.content["playVideo"])
				swfLoader.content["playVideo"]();
		}
		
		public function stop():void {
			if (swfLoader && swfLoader.content && swfLoader.content["stopVideo"])
				swfLoader.content["stopVideo"]();
		}

		// gh#1449
		public function pause():void {
			if (swfLoader && swfLoader.content && swfLoader.content["pauseVideo"])
				swfLoader.content["pauseVideo"]();
		}
		
		protected function onClickVideo(event:MouseEvent):void {
			videoPlayer.dispatchEvent(new VideoEvent(VideoEvent.VIDEO_CLICK, true)); // gh#106
		}
		
		public function destroy():void {
			stop();
			(videoPlayer as IVisualElementContainer).removeElement(swfLoader);
			
			// gh#852
			if (swfLoader.content) {
				swfLoader.content.removeEventListener("onReady", onReady);
				swfLoader.content.removeEventListener(MouseEvent.CLICK, onClickVideo);
			}
			
			swfLoader.source = null;
			swfLoader = null;
		}
		
	}
}