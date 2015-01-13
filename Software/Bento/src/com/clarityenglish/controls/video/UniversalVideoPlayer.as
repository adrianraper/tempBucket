package com.clarityenglish.controls.video {
	import com.clarityenglish.controls.video.events.VideoSpanButtonBarEvent;
	import com.clarityenglish.controls.video.players.FlashVideoPlayer;
	import com.clarityenglish.controls.video.players.HTMLVideoPlayer;
	import com.clarityenglish.controls.video.providers.AwsProvider;
	import com.clarityenglish.controls.video.providers.RackspaceProvider;
	import com.clarityenglish.controls.video.providers.VimeoProvider;
	import com.clarityenglish.controls.video.providers.YouKuProvider;
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
		
		private var _source:Object;
		private var _sourceChanged:Boolean;
		
		protected static var providers:Array = [
			YouTubeProvider,
			VimeoProvider,
			YouKuProvider,
			RackspaceProvider,
			//AwsProvider,
		];
		
		public static function canHandleSource(value:Object):Boolean {
			// Check that a provider exists that can handle the source
			for each (var providerClass:Class in providers)
				if (new providerClass().canHandleSource(value))
					return true;
			
			return false;
		}
		
		// gh#875 Format the exercise node src value for the provider that will handle it
		public static function formatSource(value:Object):Object {
			// Which provider can handle the source?
			for each (var providerClass:Class in providers) {
				var provider:IVideoProvider = new providerClass();
				if (provider.canHandleSource(value))
					return provider.fromSource(value);
			}
			return null;
		}
		
		// gh#875 Format the URL that the provider will actually use
		public static function formatUrl(value:String):String {
			// Which provider can handle the source?
			for each (var providerClass:Class in providers) {
				var provider:IVideoProvider = new providerClass();
				if (provider.isRightProvider(value))
					return (provider.toSource(value) as String);
			}
			return null;
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
		
		protected override function commitProperties():void {
			if (_sourceChanged && videoPlayer) {
				// Go through the registered providers, selecting the first one that can handle this source
				var provider:IVideoProvider;
				for each (var providerClass:Class in providers) {
					// gh#875
					if (new providerClass(videoPlayer).isRightProvider(_source)) {
						// TODO: THIS SHOULD ABSOLUTELY *NOT* BE HERE AS IT IS C-BUILDER SPECIFIC AND THIS IS SUPPOSED TO BE A UNIVERSAL VIDEO PLAYER!
						// for youku video, the span button bar in widget menu is hided.
						if (providerClass == YouKuProvider) {
							dispatchEvent(new VideoSpanButtonBarEvent(VideoSpanButtonBarEvent.SPANBUTTONBAR_HIDE, true, true));
						} else {
							dispatchEvent(new VideoSpanButtonBarEvent(VideoSpanButtonBarEvent.SPANBUTTONBAR_HIDE, true, false));
						}
						provider = new providerClass(videoPlayer);
						break;
					}
					
				}
				
				if (!provider) {
					log.error("Unable to find a provider supporting source '" + _source + "'");
					return;
				} else {
					(videoPlayer as IVideoProvidable).provider = provider;
					videoPlayer.source = provider.toSource(_source);
				}
				
				_sourceChanged = false;
			}
		}

		/**
		 * Expects source like vimeo:12345678, which comes from saved src value in exercise node
		 */
		public function set source(value:Object):void {
			_source = value;
			_sourceChanged = true;
			invalidateProperties();
		}
		
		public function get source():Object {
			return (videoPlayer) ? videoPlayer.source : null;
		}
		
		public function play():void {
			if (videoPlayer) {
				videoPlayer.visible = true;
				videoPlayer.play();
			}
		}

		public function stop():void {
			if (videoPlayer) videoPlayer.stop();
		}
		
		public override function set visible(value:Boolean):void {
			if (videoPlayer) videoPlayer.visible = value;
		}
	}
}
