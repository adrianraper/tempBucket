package com.clarityenglish.controls.video {
	import com.clarityenglish.controls.video.players.FlashVideoPlayer;
	import com.clarityenglish.controls.video.players.HTMLVideoPlayer;
	import com.clarityenglish.controls.video.providers.VimeoProvider;
	import com.clarityenglish.controls.video.providers.YouTubeProvider;
	
	import flash.events.Event;
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
		
		protected static var providers:Array = [
			YouTubeProvider,
			VimeoProvider
		];
		
		public static function canHandleSource(value:Object):Boolean {
			// Check that a provider exists that can handle the source
			for each (var providerClass:Class in providers)
				if (new providerClass().canHandleSource(value))
					return true;
			
			return false;
		}
		
		public function UniversalVideoPlayer() {
			super();
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
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
				if (new providerClass(videoPlayer).canHandleSource(value)) {
					provider = new providerClass(videoPlayer);
					break;
				}
			}
			
			if (!provider) {
				log.error("Unable to find a provider supporting source '" + value + "'");
				return;
			} else {
				// Set the provider
				(videoPlayer as IVideoProvidable).provider = provider;
				
				// Set the source
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
