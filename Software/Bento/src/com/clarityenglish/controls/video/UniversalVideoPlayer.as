package com.clarityenglish.controls.video {
	import com.clarityenglish.controls.video.players.FlashVideoPlayer;
	import com.clarityenglish.controls.video.players.HTMLVideoPlayer;
	import com.clarityenglish.controls.video.providers.VimeoProvider;
	import com.clarityenglish.controls.video.providers.YouTubeProvider;
	
	import flash.media.StageWebView;
	import flash.system.ApplicationDomain;
	
	import mx.core.IVisualElement;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Group;
	
	public class UniversalVideoPlayer extends Group implements IVideoPlayer {
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		protected var videoPlayer:IVideoPlayer;
		
		protected var providers:Array = [
			YouTubeProvider,
			VimeoProvider
		];
		
		public function UniversalVideoPlayer() {
			super();
		}
		
		protected override function createChildren():void {
			super.createChildren();
			
			if (!videoPlayer) {
				// Select a video player based on the availability of StageWebView
				var hasStageWebView:Boolean = ApplicationDomain.currentDomain.hasDefinition("flash.media.StageWebView") && StageWebView.isSupported;
				videoPlayer = new ((hasStageWebView) ? HTMLVideoPlayer : FlashVideoPlayer)();
				(videoPlayer as Group).percentWidth = (videoPlayer as Group).percentHeight = 100; 
				addElement(videoPlayer as IVisualElement);
			}
		}
		
		public function set source(value:Object):void {
			// Go through the registered providers, selecting the first one that can handle this source
			var provider:IVideoProvider;
			for each (var providerClass:Class in providers) {
				if (new providerClass().canHandleSource(value)) {
					provider = new providerClass();
					break;
				}
			}
			
			if (!provider) {
				log.error("Unable to find a provider supporting source '" + source + "'");
				return;
			} else {
				// Set the provider
				(videoPlayer as IVideoProvidable).provider = provider;
				
				// And set the source
				videoPlayer.source = value;
			}
		}
		
		public function get source():Object {
			return (videoPlayer) ? videoPlayer.source : null;
		}
		
		public function play():void {
			if (videoPlayer) videoPlayer.play();
		}

		public function stop():void {
			if (videoPlayer) videoPlayer.stop();
		}
	}
}
