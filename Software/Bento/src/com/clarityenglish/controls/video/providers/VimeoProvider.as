package com.clarityenglish.controls.video.providers {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.IVideoProvider;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.IVisualElementContainer;
	
	public class VimeoProvider implements IVideoProvider {
		
		protected var videoPlayer:IVideoPlayer;
		
		protected var vimeoPlayer:VimeoPlayer;

		protected var urlPattern:RegExp;
		protected var srcPattern:RegExp;
		protected var urlBase:String;
		protected var srcBase:String;
		protected var idPattern:RegExp;
		
		public function VimeoProvider(videoPlayer:IVideoPlayer = null) {
			this.videoPlayer = videoPlayer;
			
			// gh#875
			urlPattern = /https?:\/\/(?:www\.)?vimeo.com\/(?:channels\/|groups\/([^\/]*)\/videos\/|album\/(\d+)\/video\/|)(\d+)(?:$|\/|\?)/i;
			srcPattern = /vimeo:(\d+)/i;
			urlBase = 'https:\/\/vimeo.com\/{id}';
			srcBase = 'vimeo:{id}';
			idPattern = /{id}/i;
		}
		
		/**
		 * A helper function to get the id out of the Vimeo url
		 * 
		 * @param source
		 * @return 
		 */
		protected function getId(source:Object):String {
			//var pattern:RegExp = /https?:\/\/(?:www\.)?vimeo.com\/(?:channels\/|groups\/([^\/]*)\/videos\/|album\/(\d+)\/video\/|)(\d+)(?:$|\/|\?)/i;
			var matches:Array = source.match(urlPattern);
			return matches[3];
		}
		
		/**
		 * A helper function to get the id out of the stored src
		 * gh#875
		 * @param source
		 * @return 
		 */
		protected function getIdFromSrc(source:Object):String {
			//var pattern:RegExp = /vimeo:(\d+)/i;
			var matches:Array = source.match(srcPattern);
			return matches[1];
		}
		
		/**
		 * This provider applies if the source is in the format 'vimeo.com'
		 *  
		 * @param source
		 * @return 
		 * 
		 */
		public function canHandleSource(source:Object):Boolean {
			//var pattern:RegExp = /https?:\/\/(?:www\.)?vimeo.com\/(?:channels\/|groups\/([^\/]*)\/videos\/|album\/(\d+)\/video\/|)(\d+)(?:$|\/|\?)/i;
			var matches:Array = source.match(urlPattern);
			return (matches && matches.hasOwnProperty(3) && matches[3] != null);
		}
		
		/**
		 * This provider applies if the src is in the format 'vimeo:12345678'
		 * gh#875
		 * @param source
		 * @return 
		 * 
		 */
		public function isRightProvider(source:Object):Boolean {
			//var pattern:RegExp = /vimeo:(\d)+/i;
			var matches:Array = source.match(srcPattern);
			return (matches && matches.hasOwnProperty(1) && matches[1] != null);
		}
		
		/**
		 * gh#875 Create a URL that the video player can use from the current provider URL and the id
		 * 
		 */
		public function toSource(src:Object):Object {
			//return 'https://vimeo.com/' + this.getIdFromSrc(src); 
			return urlBase.replace(idPattern, this.getIdFromSrc(src));
		}
		
		/**
		 * gh#875 Create an exercise node format from the URL
		 * 
		 */
		public function fromSource(source:Object):Object {
			//return 'vimeo:' + this.getId(source); 
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
			html += "			src='http://player.vimeo.com/video/" + getId(source) + "'";
			html += "			frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen>";
			html += "	</iframe>";
			html += "</body>";
			html += "</html>";
			return html;
		}
		
		public function create(source:Object):void {
			vimeoPlayer = new VimeoPlayer("00684db92d5e65590b4210f1c46ad2704704e357", parseInt(getId(source)), 640, 360);
			vimeoPlayer.addEventListener(Event.COMPLETE, onVimeoPlayerComplete);
			(videoPlayer as IVisualElementContainer).addElement(vimeoPlayer);
		}
		
		protected function onVimeoPlayerComplete(event:Event):void {
			if (vimeoPlayer) {
				vimeoPlayer.removeEventListener(Event.COMPLETE, onVimeoPlayerComplete);
				vimeoPlayer.addEventListener(MouseEvent.CLICK, onClickVideo); // gh#106
			}
			resize();
		}
		
		protected function onReady(e:Event):void {
			/*resize();*/
		}
		
		public function resize():void {
			if (vimeoPlayer)
				vimeoPlayer.setSize(videoPlayer.width, videoPlayer.height);
		}
		
		public function play():void {
			if (vimeoPlayer)
				vimeoPlayer.play();
		}
		
		public function stop():void {
			if (vimeoPlayer)
				vimeoPlayer.pause();
		}
		
		protected function onClickVideo(event:MouseEvent):void {
			/*videoPlayer.dispatchEvent(new VideoEvent(VideoEvent.VIDEO_CLICK, true)); // gh#106*/
		}
		
		public function destroy():void {
			stop();
			(videoPlayer as IVisualElementContainer).removeElement(vimeoPlayer);
			vimeoPlayer.destroy();
			vimeoPlayer = null;
		}
		
	}
}

/**
 * VimeoPlayer - http://developer.vimeo.com/player/as-api https://github.com/vimeo/player-api/blob/master/actionscript/src/com/vimeo/api/VimeoPlayer.as
 *
 * A wrapper class for Vimeo's video player (codenamed Moogaloop)
 * that allows you to embed easily into any AS3 application.
 *
 * Example on how to use:
 *  var vimeo_player = new VimeoPlayer([YOUR_APPLICATIONS_CONSUMER_KEY], 2, 400, 300);
 *  vimeo_player.addEventListener(Event.COMPLETE, vimeoPlayerLoaded);
 *  addChild(vimeo_player);
 *
 * http://vimeo.com/api/docs/moogaloop
 *
 * Register your application for access to the Moogaloop API at:
 *
 * http://vimeo.com/api/applications
 */
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.utils.Timer;

import spark.core.SpriteVisualElement;

class VimeoPlayer extends SpriteVisualElement {
	
	// Assets
	private var container:Sprite = new Sprite(); // sprite that holds the player
	private var moogaloop:Object = false;        // the player
	private var player_mask:Sprite = new Sprite(); // some sprites inside moogaloop go outside the bounds of the player. we use a mask to hide it
	
	// Default variables
	private var player_width:int = 400;
	private var player_height:int = 300;
	private var api_version:int = 2;
	private var load_timer:Timer = new Timer(200);
	
	// Events
	// API v2
	public static const FINISH:String = 'finish';
	public static const LOAD_PROGRESS:String = 'loadProgress';
	public static const PAUSE:String = 'pause';
	public static const PLAY:String = 'play';
	public static const PLAY_PROGRESS:String = 'playProgress';
	public static const READY:String = 'ready';
	public static const SEEK:String = 'seek';
	
	// API v1
	public static const ON_FINISH:String = 'onFinish';
	public static const ON_LOADING:String = 'onLoading';
	public static const ON_PAUSE:String = 'onPause';
	public static const ON_PLAY:String = 'onPlay';
	public static const ON_PROGRESS:String = 'onProgress';
	public static const ON_SEEK:String = 'onSeek';
	
	public function VimeoPlayer(oauth_key:String, clip_id:int, w:int, h:int, fp_version:String = '10', api_version:int = 2) {
		this.setDimensions(w, h);
		
		Security.allowDomain('*');
		Security.allowInsecureDomain('*');
		
		var api_param:String = '&js_api=1';
		this.api_version = api_version;
		
		//
		if (fp_version != '9') {
			switch(api_version) {
				case 2:
					api_param = '&api=1';
					break;
			}
		} else {
			this.api_version = 1;
		}
		
		var request:URLRequest = new URLRequest("http://api.vimeo.com/moogaloop_api.swf?oauth_key=" + oauth_key + "&clip_id=" + clip_id + "&width=" + w + "&height=" + h + "&fullscreen=0&fp_version=" + fp_version + api_param + "&cache_buster=" + (Math.random() * 1000));
		
		var loaderContext:LoaderContext = new LoaderContext(true);
		
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
		loader.load(request, loaderContext);
		
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
	}
	
	public function destroy():void {
		if (moogaloop) {
			if (api_version == 2) {
				// API v2 Event Handlers
				moogaloop.removeEventListener(READY, readyHandler);
				moogaloop.removeEventListener(PLAY, playHandler);
				moogaloop.removeEventListener(PAUSE, pauseHandler);
				moogaloop.removeEventListener(SEEK, seekHandler);
				moogaloop.removeEventListener(LOAD_PROGRESS, loadProgressHandler);
				moogaloop.removeEventListener(PLAY_PROGRESS, playProgressHandler);
				moogaloop.removeEventListener(FINISH, finishHandler);
			} else {
				// API v1 Event Handlers
				moogaloop.removeEventListener(ON_PLAY, onPlayHandler);
				moogaloop.removeEventListener(ON_PAUSE, onPauseHandler);
				moogaloop.removeEventListener(ON_SEEK, onSeekHandler);
				moogaloop.removeEventListener(ON_LOADING, onLoadingHandler);
				moogaloop.removeEventListener(ON_PROGRESS, onProgressHandler);
				moogaloop.removeEventListener(ON_FINISH, onFinishHandler);
			}
			
			moogaloop.destroy();
		
			if (container.contains(DisplayObject(moogaloop))) container.removeChild(DisplayObject(moogaloop));
		}
		
		if (this.contains(player_mask)) this.removeChild(player_mask);
		if (this.contains(container)) this.removeChild(container);
		
		if (stage) stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
	}
	
	private function setDimensions(w:int, h:int):void {
		player_width  = w;
		player_height = h;
	}
	
	private function onComplete(e:Event):void {
		// Finished loading moogaloop
		container.addChild(e.currentTarget.loader.content);
		moogaloop = e.currentTarget.loader.content;
		
		if (api_version == 2) {
			// API v2 Event Handlers
			moogaloop.addEventListener(READY, readyHandler, false, 0, true);
			moogaloop.addEventListener(PLAY, playHandler, false, 0, true);
			moogaloop.addEventListener(PAUSE, pauseHandler, false, 0, true);
			moogaloop.addEventListener(SEEK, seekHandler, false, 0, true);
			moogaloop.addEventListener(LOAD_PROGRESS, loadProgressHandler, false, 0, true);
			moogaloop.addEventListener(PLAY_PROGRESS, playProgressHandler, false, 0, true);
			moogaloop.addEventListener(FINISH, finishHandler, false, 0, true);
			
			moogaloop.disableKeyboardEvents(); // gh#898
		} else {
			// API v1 Event Handlers
			moogaloop.addEventListener(ON_PLAY, onPlayHandler, false, 0, true);
			moogaloop.addEventListener(ON_PAUSE, onPauseHandler, false, 0, true);
			moogaloop.addEventListener(ON_SEEK, onSeekHandler, false, 0, true);
			moogaloop.addEventListener(ON_LOADING, onLoadingHandler, false, 0, true);
			moogaloop.addEventListener(ON_PROGRESS, onProgressHandler, false, 0, true);
			moogaloop.addEventListener(ON_FINISH, onFinishHandler, false, 0, true);
		}
		
		// Create the mask for moogaloop
		this.addChild(player_mask);
		container.mask = player_mask;
		this.addChild(container);
		
		redrawMask();
		
		load_timer.addEventListener(TimerEvent.TIMER, playerLoadedCheck);
		load_timer.start();
	}
	
	/**
	 * Wait for Moogaloop to finish setting up
	 */
	private function playerLoadedCheck(e:TimerEvent):void {
		if (moogaloop.player_loaded) {
			// Moogaloop is finished configuring
			load_timer.stop();
			load_timer.removeEventListener(TimerEvent.TIMER, playerLoadedCheck);
			
			// remove moogaloop's mouse listeners listener
			moogaloop.disableMouseMove();
			if (stage) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
	/**
	 * Fake the mouse move/out events for Moogaloop
	 */
	private function mouseMove(e:MouseEvent):void {
		if (moogaloop && moogaloop.player_loaded) {
			var pos : Point = this.parent.localToGlobal(new Point(this.x, this.y));
			if (e.stageX >= pos.x && e.stageX <= pos.x + this.player_width &&
				e.stageY >= pos.y && e.stageY <= pos.y + this.player_height) {
				moogaloop.mouseMove(e);
			} else {
				moogaloop.mouseOut();
			}
		}
	}
	
	private function redrawMask():void {
		with (player_mask.graphics) {
			beginFill(0x000000, 1);
			drawRect(container.x, container.y, player_width, player_height);
			endFill();
		}
	}
	
	public function play():void {
		if (moogaloop) moogaloop.play();
	}
	
	public function pause():void {
		if (moogaloop) moogaloop.pause();
	}
	
	/**
	 * returns duration of video in seconds
	 */
	public function getDuration():int {
		return moogaloop.duration;
	}
	
	/**
	 * Seek to specific loaded time in video (in seconds)
	 */
	public function seekTo(time:int):void {
		moogaloop.seek(time);
	}
	
	/**
	 * Change the primary color (i.e. 00ADEF)
	 */
	public function changeColor(hex:String):void {
		moogaloop.color = uint('0x' + hex);
	}
	
	/**
	 * Load in a different video
	 */
	public function loadVideo(id:int):void {
		moogaloop.loadVideo(id);
	}
	
	public function setSize(w:int, h:int):void {
		if (moogaloop) {
		this.setDimensions(w, h);
		moogaloop.setSize(w, h);
		this.redrawMask();
		}
	}
	
	// Event Handlers ____________________________________________________
	
	private function addedToStageHandler(event:Event):void {
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true);
	}
	
	private function removedFromStageHandler(event:Event):void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
	}
	
	/**
	 * API v2 Event Handlers
	 */
	private function readyHandler(event:Event):void { }
	private function playHandler(event:Event):void { }
	private function pauseHandler(event:Event):void { }
	private function seekHandler(event:Event):void { }
	private function loadProgressHandler(event:Event):void { }
	private function playProgressHandler(event:Event):void { }
	private function finishHandler(event:Event):void { }
	
	/**
	 * API v1 Event Handlers
	 */
	private function onPlayHandler(event:Event):void { }
	private function onPauseHandler(event:Event):void { }
	private function onSeekHandler(event:Event):void { }
	private function onLoadingHandler(event:Event):void { }
	private function onProgressHandler(event:Event):void { }
	private function onFinishHandler(event:Event):void { }
	
}