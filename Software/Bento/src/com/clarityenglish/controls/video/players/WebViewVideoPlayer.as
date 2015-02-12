package com.clarityenglish.controls.video.players {
	import com.clarityenglish.controls.video.IVideoPlayer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
import flash.system.Capabilities;

import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Application;
	import spark.components.Group;
	
	public class WebViewVideoPlayer extends Group implements IVideoPlayer {
		
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		// remove static for there maybe two videos in same page.
		private var stageWebView:StageWebView;
		
		private var _source:Object;
		private var _sourceChanged:Boolean;
		private var _placeholderSource:String;
		
		private var dpiScaleFactor:Number = 1;
		
		public function WebViewVideoPlayer() {
			if (!StageWebView)
				throw new Error("This component can only be used in an AIR application");
			
			if (!StageWebView.isSupported)
				throw new Error("StageWebView is not supported in this environment");

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}
		
		public function get source():Object {
			return _source;
		}
		
		// For ipad candidates video which require video stop when switch to another. 
		// Using set visible to stop video will call onRemovedFromStage and stageWebView will be set to null.
		// So before playing another video, stageWebView need to be recreated.
		public function createStageWebView():void {
			if (!stageWebView) {
				dpiScaleFactor = (parentApplication as Application).runtimeDPI / (parentApplication as Application).applicationDPI;
				stageWebView = new StageWebView();
				
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
				addEventListener(FlexEvent.HIDE, onRemovedFromStage, false, 0, true);
				addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			}
		}
		
		public function get placeholderSource():String {
			return _placeholderSource;
		}
		
		public function set placeholderSource(value:String):void {
			_placeholderSource = value;
		}

		private function get link():String {
			var sourceHtml:String = "";
			sourceHtml += "<!DOCTYPE html>";
			sourceHtml += "<html>";
			sourceHtml += "<head>";
			sourceHtml += "	<meta name='viewport' content='width=" + getVideoWidth() + ", height=" + getVideoHeight() + ",";
			sourceHtml += "		  initial-scale=1.0, maximum-scale=1.0, user-scalable=no, target-densitydpi=device-dpi' />"
			sourceHtml += " <style type='text/css'>";
			sourceHtml += "		video::-webkit-media-controls-fullscreen-button {display: none;}";
			sourceHtml += "	</style>";
			sourceHtml += "</head>";
			sourceHtml += "<body style='margin:0;padding:0;border:0;overflow:hidden;'>";
			sourceHtml += "	<video id='myVideo' width='" + getVideoWidth() + "'";
			sourceHtml += "			height='"+ getVideoHeight() + "'";
			sourceHtml += "			controls poster='" + placeholderSource + "'  preload='auto'>";
			sourceHtml += "			<source src='" + source + "' type='video/mp4' >";
			sourceHtml += "	</video>";
			sourceHtml += "</body>";
			sourceHtml += "</html>";

			return sourceHtml;
		}

		private function getVideoWidth():Number {
			if (Capabilities.os.indexOf("iPad") > -1) {
				return stageWebView.viewPort.width / dpiScaleFactor;
			} else {
				return stageWebView.viewPort.width;
			}
		}

		private function getVideoHeight():Number {
			if (Capabilities.os.indexOf("iPad") > -1) {
				return stageWebView.viewPort.height / dpiScaleFactor;
			} else {
				return stageWebView.viewPort.height;
			}
		}
		
		private function get isHtml():Boolean {
			return source && source.toString().match(/^https?:\/\//i) == null;
		}
		
		private function get html():String {
			if (!stageWebView.viewPort) return null;
			
			var matches:Array = (source.toString()) ? source.toString().match(/^(\w+):?(.*)$/i) : null;
			if (!matches || matches.length < 3) return source.toString();
			
			var format:String = matches[1];
			var id:String = matches[2];
			
			var html:String = "";
			
			switch (format) {
				case "youtube":
					html += "<!DOCTYPE html>";
					html += "<html>";
					html += "<head>";
					html += "	<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no' />";
					html += "</head>";
					html += "<body style='margin:0;padding:0;border:0;overflow:hidden'>";
					html += "	<iframe id='player'";
					html += "			type='text/html'";
					html += "			width='"+ stageWebView.viewPort.width + "'";
					html += "			height='"+ stageWebView.viewPort.height + "'";
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

		public function set source(value:Object):void {
			_source = value;
			log.info("Setting video source to {0}", value);
		}
		
		public override function set visible(value:Boolean):void {
			super.visible = value;
			
			invalidateProperties();
		}
		
		/*protected override function createChildren():void {
			super.createChildren();
			
			if (!stageWebView) {
				// #443 - since StageWebView is native we need to apply the Retina dpi scaling manually
				dpiScaleFactor = (parentApplication as Application).runtimeDPI / (parentApplication as Application).applicationDPI;
				stageWebView = new StageWebView();
			}
		}*/
		
		protected override function commitProperties():void {
			super.commitProperties();

			if (stageWebView)
				stageWebView.stage = (visible) ? stage : null;
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (!stageWebView.viewPort) {
				var globalPos:Point = contentToGlobal(new Point(x, y));
				stageWebView.viewPort = new Rectangle(globalPos.x, globalPos.y, Math.max(0, unscaledWidth * dpiScaleFactor), unscaledHeight * dpiScaleFactor);
			}
		}
		
		public function play():void {
			invalidateDisplayList();
			
			callLater(function():void {
				if (source) {
					if (stageWebView) {
						if (isHtml) {
							if (html) {
								log.debug("loading html {0}", html.toString());
								stageWebView.loadString(html);
							}
						} else {
							if (source.toString()) {
								log.debug("loading url {0}", source.toString());
								stageWebView.loadString(link);
							}
						}
					}
				} else {
					stop();
				}
			});
		}
		
		public function stop():void {
			if (stageWebView) {
				stageWebView.reload();
				stageWebView.viewPort = null;
			}
		}
		
		protected function onAddedToStage(event:Event):void {
			addEventListener(FlexEvent.HIDE, onHide, false, 0, true);
			addEventListener(FlexEvent.SHOW, onShow, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);

			// Create the StageWebView
			if (!stageWebView) {
				dpiScaleFactor = (parentApplication as Application).runtimeDPI / (parentApplication as Application).applicationDPI;
				stageWebView = new StageWebView();
			}

			// Make sure that commitProperties runs when the component is added to the stage so that stageWebView.stage can be set
			invalidateProperties();

			// for some video selector that only stageWebView is removed from stage, the video selector doesn't recreate again and the source is still remained.
			if (source) {
				play();
			}
			//addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(FlexEvent.HIDE, onHide);
			removeEventListener(FlexEvent.SHOW, onShow);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if (stageWebView) {
				stageWebView.stage = null;
				stageWebView.viewPort = null;
				stageWebView.dispose();
				stageWebView = null;
			}
		}

		protected function onHide(evnet:Event):void {
			if (stageWebView) {
				stageWebView.reload();
				stageWebView.viewPort = null;
			}
		}

		protected function onShow(event:Event):void {
			if (stageWebView) {
				invalidateProperties();
				invalidateDisplayList();
			}
		}
		
		protected function onEnterFrame(event:Event):void {
			if (stageWebView.viewPort) {
				var globalPos:Point = contentToGlobal(new Point(x, y));
				stageWebView.viewPort = new Rectangle(globalPos.x, globalPos.y, stageWebView.viewPort.width, stageWebView.viewPort.height);
			}
		}
		
	}
	
}
