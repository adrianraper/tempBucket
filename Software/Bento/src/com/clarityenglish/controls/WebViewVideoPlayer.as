package com.clarityenglish.controls {
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	
	import mx.events.EffectEvent;
	import mx.events.MoveEvent;
	
	import spark.components.Group;
	import spark.components.View;
	
	public class WebViewVideoPlayer extends Group {
		
		private var stageWebView:StageWebView;
		
		private var _source:Object;
		private var _sourceChanged:Boolean;
		
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
		}

		protected override function createChildren():void {
			super.createChildren();
			
			if (!stageWebView) {
				stageWebView = new StageWebView();
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			stageWebView.stage = (visible) ? stage : null;
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			var globalPos:Point = contentToGlobal(new Point(x, y));
			stageWebView.viewPort = new Rectangle(globalPos.x, globalPos.y, unscaledWidth, unscaledHeight);
		}
		
		public function play():void {
			if (source) {
				stageWebView.loadURL(source.toString());
			} else {
				stop();
			}
		}
		
		public function stop():void {
			stageWebView.reload();
			stageWebView.viewPort = null;
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			stop();
			stageWebView.dispose();
			stageWebView = null;
		}
		
	}
	
}
