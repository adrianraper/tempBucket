package com.clarityenglish.controls.video.players {
	import com.clarityenglish.controls.video.IVideoPlayer;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Application;
	import spark.components.Group;
	import spark.components.SkinnableDataContainer;
	
	public class NewWebViewVideoPlayer extends Group implements IVideoPlayer {
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var stageWebView:StageWebView;
		
		private var _source:Object;
		private var _sourceChanged:Boolean;
		
		private var _visibleChanged:Boolean;
		
		private var dpiScaleFactor:Number = 1;
		
		public function NewWebViewVideoPlayer() {
			if (!StageWebView)
				throw new Error("This component can only be used in an AIR application");
			
			if (!StageWebView.isSupported)
				throw new Error("StageWebView is not supported in this environment")
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
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
			
			// #443 - since StageWebView is native we need to apply the Retina dpi scaling manually
			dpiScaleFactor = (parentApplication as Application).runtimeDPI / (parentApplication as Application).applicationDPI;
			
			// Create the StageWebView
			if (!stageWebView) stageWebView = new StageWebView();
			
			invalidateProperties();
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			// Destroy the StageWebView
			destroy();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (!stageWebView) return;
			
			// This is how we hide/show the stage web view whilst still keeping it on the stage
			stageWebView.stage = (visible) ? stage : null;
			
			if (_sourceChanged) {
				_sourceChanged = false;
				
				load();
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
				if (!stageWebView.viewPort || !rectangle.equals(stageWebView.viewPort)) stageWebView.viewPort = rectangle;
			}
		}
		
		protected function onEnterFrame(event:Event):void {
			if (stageWebView && stageWebView.stage && stageWebView.viewPort)
				invalidateDisplayList();
		}
		
		public function play():void {
			// This does nothing...
		}
		
		public function stop():void {
			callLater(destroy);
		}
		
		private function load():void {
			if (source) {
				var loader:IStageWebViewLoader = (source.toString().match(/^https?:\/\//i) == null) ? new HTMLStageWebVideoLoader() : new URLStageWebVideoLoader();
				loader.load(stageWebView, source);
			} else {
				trace("SOURCE SET TO NULL???");
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
import flash.media.StageWebView;

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
		
		switch (format) {
			case "youtube":
				html += "<!DOCTYPE html>";
				html += "<html>";
				html += "<body style='margin:0;padding:0;border:0;overflow:hidden;'>";
				html += "	<iframe id='player' style='position:absolute;width:100%;height:100%'";
				html += "			type='text/html'";
				html += "			src='http://www.youtube.com/embed/" + id + "?rel=0&hd=1&fs=1'";
				html += "			frameborder='0'>";
				html += "	</iframe>";
				html += "</body>";
				html += "</html>";
				break;
			default:
				return "Unsupported source: " + source.toString();
		}
		
		return html;
	}
	
}