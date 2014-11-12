package com.clarityenglish.clearpronunciation {
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.preloaders.SparkDownloadProgressBar;
	
	public class ClearPronunciationPreloader extends SparkDownloadProgressBar {
		private var preloaderDisplay:PreloaderDisplay;
		private var showingDisplay:Boolean = false;
		private var swfPercent:Number = 0;
		private var rslPercent:Number = 0;
		private var rslBytesTotal:Array;
		private var rslBytesLoaded:Array;
		private var swfBytesTotal:Number = 0;
		private var swfBytesLoaded:Number = 0;
		/**
		 * Keep the rslEstimate low as it mostly completes before the main application
		 * and is highly variable  based on how many rsls are in your browser already.
		 * There is a fairly persuasive argument that we only need the application actually...
		 */
		private var rslEstimate:Number = 1000000;
		private var swfEstimate:Number = 4000000; // published size
		
		public function ClearPronunciationPreloader() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		protected function onResize(event:Event = null):void {
			if (preloaderDisplay) {
				preloaderDisplay.scaleX = 0.6;
				preloaderDisplay.scaleY = 0.6;
				preloaderDisplay.x = Math.round((stage.stageWidth - preloaderDisplay.width)/ 2 + 170);
				preloaderDisplay.y = Math.round((stage.stageHeight - preloaderDisplay.height)/ 2 + 70);
			}
		}
		
		private function show():void {
			// SWFObject reports 0 sometimes at startup - if we get zero, wait and try on next attempt
			if (stageWidth == 0 && stageHeight == 0) {
				try	{
					stageWidth = stage.stageWidth;
					stageHeight = stage.stageHeight
				} catch (e:Error) {
					stageWidth = loaderInfo.width;
					stageHeight = loaderInfo.height;
				}
				
				if (stageWidth == 0 && stageHeight == 0) 
					return;
			}
			
			showingDisplay = true;
			createChildren();
		}
		
		/**
		 *  Creates the subcomponents of the display.
		 */
		override protected function createChildren():void {
			if (!preloaderDisplay) {
				preloaderDisplay = new PreloaderDisplay();
				
				onResize();
				
				addChild(preloaderDisplay);
			}
		}
		
		/**
		 *  Event listener for the <code>FlexEvent.INIT_COMPLETE</code> event.
		 *  NOTE: This event can be commented out to stop preloader from completing during testing
		 */
		override protected function initCompleteHandler(event:Event):void {
			stage.removeEventListener(Event.RESIZE, onResize);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Event listener for the <code>ProgressEvent.PROGRESS event</code> event.
		 * Download of the main application swf
		 */
		override protected function progressHandler(e:ProgressEvent):void {
			if (!preloaderDisplay) {
				show();
			}
		}
		
		/**
		 * Event listener for the <code>RSLEvent.RSL_PROGRESS</code> event.
		 */
		override protected function rslProgressHandler(e:RSLEvent):void {
			if (!preloaderDisplay) {
				show();
			}
		}
	}
}