package com.clarityenglish.controls.video.players {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import com.clarityenglish.controls.video.IVideoProvidable;
	import com.clarityenglish.controls.video.IVideoProvider;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.utils.Dictionary;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.StringUtils;
	
	import spark.components.Application;
	import spark.components.Group;
	import spark.components.List;
	
	public class HTMLVideoPlayer extends Group implements IVideoPlayer, IVideoProvidable {
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		protected var stageWebView:StageWebView;
		
		protected var _provider:IVideoProvider;
		protected var _providerChanged:Boolean;
		
		protected var _source:Object;
		protected var _sourceChanged:Boolean;
		
		protected var _visibleChanged:Boolean;
		
		protected var dpiScaleFactor:Number = 1;
		
		protected static var videoPlayers:Dictionary = new Dictionary(true); // gh#749
		
		public static function hideAllVideo():void {
			for (var videoPlayer:* in videoPlayers)
				(videoPlayer as HTMLVideoPlayer).visible = false;
		}
		
		public static function showAllVideo():void {
			for (var videoPlayer:* in videoPlayers)
				(videoPlayer as HTMLVideoPlayer).visible = true;
		}
		
		public function HTMLVideoPlayer() {
			if (!StageWebView)
				throw new Error("This component can only be used in an AIR application");
			
			if (!StageWebView.isSupported)
				throw new Error("StageWebView is not supported in this environment")
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		
		public function set provider(value:IVideoProvider):void {
			_provider = value;
			_providerChanged = true;
			invalidateProperties();
		}
		
		public function set source(value:Object):void {
			log.info("Source set to " + value);
			_source = value;
			_sourceChanged = true;
			invalidateProperties();
		}
		
		public function get source():Object {
			return _source;
		}
		
		public override function set visible(value:Boolean):void {
			super.visible = value;
			invalidateProperties();
		}
		
		protected function onAddedToStage(event:Event):void {
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			videoPlayers[this] = true; // gh#749
			
			// #443 - since StageWebView is native we need to apply the Retina dpi scaling manually (changed for #732 to hardcoded 160 which is apparently a constant)
			dpiScaleFactor = (parentApplication as Application).runtimeDPI / 160;
			
			// Create the StageWebView
			if (!stageWebView) stageWebView = new StageWebView();
			
			invalidateProperties();
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			delete videoPlayers[this]; // gh#749
			
			// Destroy the StageWebView
			destroy();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (!stageWebView) return;
			
			// This is how we hide/show the stage web view whilst still keeping it on the stage
			stageWebView.stage = (visible) ? stage : null;
			
			if (_sourceChanged || _providerChanged) {
				if (_source && _provider) {
					_sourceChanged = false;
					_providerChanged = false;
					
					load();
				}
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Set the viewport
			if (stageWebView) {
				var globalPos:Point = contentToGlobal(new Point(x, y));
				
				var viewportWidth:Number = Math.max(0, unscaledWidth * dpiScaleFactor);
				var viewportHeight:Number = Math.max(0, unscaledHeight * dpiScaleFactor);
				var viewportX:Number = Math.max(globalPos.x, -viewportWidth);
				var viewportY:Number = Math.max(globalPos.y, -viewportHeight);
				
				var rectangle:Rectangle = new Rectangle(viewportX, viewportY, viewportWidth, viewportHeight);
				
				// Need to get the viewport of the List - some kind of parent will give us the VideoWidget which is an ItemRenderer and from there we can get the list as owner.
				// TODO: Need to check that this still works if we are planning to use this in non-List settings (e.g. exercises).  In which case maybe we can figure out something
				// better than parentDocument.owner.owner and find a more generic class than List in which case it will work for all viewports.
				// gh#732
				if (parentDocument.owner && parentDocument.owner.owner) {
					var parentDocumentOwner:Object = parentDocument.owner.owner;
					while(!(parentDocumentOwner is List) && parentDocumentOwner.hasOwnProperty("owner")) {
						parentDocumentOwner = parentDocumentOwner.owner;
					}
					var list:List = parentDocumentOwner as List;
					if (list) {
						var listRect:Rectangle = list.getVisibleRect(stage);
						
						// #732 - this is necessary to get this to work properly on a Retina iPad
						listRect.width *= dpiScaleFactor;
						listRect.height *= dpiScaleFactor;
						
						rectangle = rectangle.intersection(listRect);
					}
				}
				
				if (!stageWebView.viewPort || !rectangle.equals(stageWebView.viewPort)) {
					if (rectangle.size.length == 0) rectangle = new Rectangle(0, 0, 1, 1); // Never let the viewport have 0 size or terrible things happen
					stageWebView.viewPort = rectangle;
				}
			}
		}
		
		protected function onEnterFrame(event:Event):void {
			if (stageWebView && stageWebView.stage && stageWebView.viewPort)
				invalidateDisplayList();
		}
		
		public function play():void { }
		
		public function stop():void {
			callLater(destroy);
		}
		
		private function load():void {
			if (_source && _provider) {
				var html:String = _provider.getHtml(_source);
				if (StringUtils.beginsWith(html, "<!DOCTYPE html>")) {
					stageWebView.loadString(html);
				} else {
					stageWebView.loadURL(html);
				}
			}
		}
		
		private function destroy():void {
			if (stageWebView) {
				_source = null;
				stageWebView.stage = null;
				stageWebView.viewPort = null;
				stageWebView.dispose();
				stageWebView = null;
			}
		}
	}
	
}
/*import flash.media.StageWebView;

interface IStageWebViewLoader {
	
	function load(stageWebView:StageWebView, source:Object):void;
	
}

class URLStageWebVideoLoader implements IStageWebViewLoader {
	
	public function load(stageWebView:StageWebView, source:Object):void {
		stageWebView.loadURL(source.toString());
	}
	
}

class HTMLStageWebVideoLoader implements IStageWebViewLoader {
	
	public function load(stageWebView:StageWebView, source:Object):void {
		var html:String = sourceToHtml(source);
		stageWebView.loadString(html);
	}
	
	private function sourceToHtml(source:Object):String {
		var matches:Array = (source.toString()) ? source.toString().match(/^(\w+):?(.*)$/i) : null;
		if (!matches || matches.length < 3) return source.toString();
		
		var format:String = matches[1];
		var id:String = matches[2];
		
		var html:String = "";
		html += "<!DOCTYPE html>";
		html += "<html>";
		
		switch (format) {
			case "youtube":
				html += "<body style='margin:0;padding:0;border:0;overflow:hidden;'>";
				html += "	<iframe id='ytplayer' style='position:absolute;top:0px;width:100%;height:100%'";
				html += "			type='text/html'";
				html += "			src='http://www.youtube.com/embed/" + id + "?rel=0&fs=1'";
				html += "			frameborder='0'>";
				html += "	</iframe>";
				html += "</body>";
				break;
			case "vimeo":
				html += "<body style='margin:0;padding:0;border:0;overflow:hidden;'>";
				html += "	<iframe style='position:absolute;top:0px;width:100%;height:100%'";
				html += "			src='http://player.vimeo.com/video/" + id + "'";
				html += "			frameborder='0'";
				html += "			webkitallowfullscreen mozallowfullscreen allowfullscreen";
				html += "	</iframe>";
				html += "</body>";
				break;
			default:
				return "Unsupported source: " + source.toString();
		}
		
		html += "</html>";
		
		return html;
	}
	
}*/