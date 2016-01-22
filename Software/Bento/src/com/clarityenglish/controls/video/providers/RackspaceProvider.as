package com.clarityenglish.controls.video.providers {
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.IVideoProvider;
	import com.clarityenglish.controls.video.events.VideoEvent;
	import com.clarityenglish.controls.video.players.OSMFVideoPlayer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.controls.SWFLoader;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.patterns.facade.Facade;
	
	public class RackspaceProvider implements IVideoProvider {
		
		protected var videoPlayer:IVideoPlayer;
		
		protected var osmfPlayer:OSMFVideoPlayer;
		
		protected var urlPattern:RegExp;
		protected var srcPattern:RegExp;
		protected var urlBase:String;
		protected var srcBase:String;
		protected var idPattern:RegExp;
		
		public function RackspaceProvider(videoPlayer:IVideoPlayer = null) {
			this.videoPlayer = videoPlayer;
			
			// gh#875
			//var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			//urlPattern = copyProvider.getCopyForId('awsPattern');
			srcPattern = /osmf:([\w\/]+)/i;
			srcBase = 'osmf:{id}';
			idPattern = /{id}/i;
		}
		
		/**
		 * A helper function to get the id out of the AWS source
		 * 
		 * @param source
		 * @return 
		 */
		/*protected function getId(source:Object):String {
			var matches:Array = source.match(urlPattern);
			return matches[1];
		}*/
		
		/**
		 * A helper function to get the id out of the stored src
		 * gh#875
		 * @param source
		 * @return 
		 */
		protected function getIdFromSrc(source:Object):String {
			// first 5 string is osmf:
			var matcheString:String = (source as String).substr(5);
			return matcheString;
		}
		
		/**
		 * This provider applies if the source is in the format 'youtube.com'
		 *  
		 * @param source
		 * @return 
		 * 
		 */
		public function canHandleSource(source:Object):Boolean {
			var matches:Array = (source as String).split(".");
			return (matches[matches.length - 1] == "mp4" || matches[matches.length - 1] == "flv");
		}
		
		/**
		 * This provider applies if the src is in the format 'rackspace:12345678'
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
			//return 'http://youtu.be/' + this.getIdFromSrc(src);
			//return copyProvider.getCopyForId('youTubeBase', {id: this.getIdFromSrc(src)});
			return this.getIdFromSrc(src);
		}
		
		/**
		 * gh#875 Create an exercise node format from the URL
		 * 
		 */
		public function fromSource(source:Object):Object {
			//return 'youtube:' + this.getId(source); 
			return srcBase.replace(idPattern, source);
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
			html += "			src=" + source;
			html += "			frameborder='0'>";
			html += "	</iframe>";
			html += "</body>";
			html += "</html>";
			return html;
		}
		
		public function create(source:Object):void {
			osmfPlayer = new OSMFVideoPlayer();
			osmfPlayer.addEventListener(FlexEvent.CREATION_COMPLETE, onOSMFPlayerComplete);
			osmfPlayer.autoPlay = false;
			osmfPlayer.percentHeight = osmfPlayer.percentWidth = 100;
			osmfPlayer.source = source;
			
			(videoPlayer as IVisualElementContainer).addElement(osmfPlayer);
		}
		
		protected function onOSMFPlayerComplete(event:Event):void {
			if (osmfPlayer) {
				osmfPlayer.removeEventListener(Event.COMPLETE, onOSMFPlayerComplete);
				osmfPlayer.addEventListener(MouseEvent.CLICK, onClickVideo); // gh#106
			}
			resize();
		}
		
		protected function onReady(e:Event):void {
			resize();
		}
		
		public function resize():void {
			if (osmfPlayer) {
				osmfPlayer.setActualSize(videoPlayer.width, videoPlayer.height);
			}		
		}
		
		public function play():void {
			if (osmfPlayer)
				osmfPlayer.play();
		}
		
		public function stop():void {
			if (osmfPlayer)
				osmfPlayer.pause();
		}

		// gh#1449
		public function pause():void {
			if (osmfPlayer)
				osmfPlayer.pause();
		}
		
		protected function onClickVideo(event:MouseEvent):void {
			videoPlayer.dispatchEvent(new VideoEvent(VideoEvent.VIDEO_CLICK, true)); // gh#106
		}
		
		public function destroy():void {
			stop();
			(videoPlayer as IVisualElementContainer).removeElement(osmfPlayer);
			osmfPlayer.removeEventListener(MouseEvent.CLICK, onClickVideo);
			
			osmfPlayer = null;
		}
		
	}
}