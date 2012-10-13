package com.clarityenglish.controls {
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Application;
	import spark.components.Group;
	
	public class WebViewVideoPlayer extends Group {
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var stageWebView:StageWebView;
		
		private var _source:Object;
		private var _sourceChanged:Boolean;
		
		private var dpiScaleFactor:Number = 1;
		
		public function WebViewVideoPlayer() {
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			if (!StageWebView)
				throw new Error("This component can only be used in an AIR application");
		}
		
		public function get source():Object {
			return _source;
		}

		public function set source(value:Object):void {
			_source = value;
			log.info("Setting video source to {0}", value);
		}
		
		public override function set visible(value:Boolean):void {
			super.visible = value;
			
			invalidateProperties();
		}

		protected override function createChildren():void {
			super.createChildren();
			
			if (!stageWebView) {
				// #443 - since StageWebView is native we need to apply the Retina dpi scaling manually
				dpiScaleFactor = (parentApplication as Application).runtimeDPI / (parentApplication as Application).applicationDPI;
				
				stageWebView = new StageWebView();
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (stageWebView)
				stageWebView.stage = (visible) ? stage : null;
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var globalPos:Point = contentToGlobal(new Point(x, y));
			stageWebView.viewPort = new Rectangle(globalPos.x, globalPos.y, unscaledWidth * dpiScaleFactor, unscaledHeight * dpiScaleFactor);
		}
		
		public function play():void {
			if (source) {
				if (stageWebView)
					stageWebView.loadURL(source.toString());
			} else {
				stop();
			}
		}
		
		public function stop():void {
			if (stageWebView) {
				stageWebView.reload();
				stageWebView.viewPort = null;
			}
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			stop();
			
			if (stageWebView) {
				stageWebView.dispose();
				stageWebView = null;
			}
		}
		
	}
	
}
