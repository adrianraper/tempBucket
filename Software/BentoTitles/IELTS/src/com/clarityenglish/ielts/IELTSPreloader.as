package com.clarityenglish.ielts {
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.events.RSLEvent;
	import mx.preloaders.SparkDownloadProgressBar;
	
	public class IELTSPreloader extends SparkDownloadProgressBar {
		
		private var preloaderDisplay:IELTSPreloaderDisplay;
		private var showingDisplay:Boolean = false;
		
		public function IELTSPreloader() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		protected function onResize(event:Event = null):void {
			if (preloaderDisplay) {
				preloaderDisplay.x = Math.round((stage.stageWidth - preloaderDisplay.width) / 2);
				preloaderDisplay.y = Math.round((stage.stageHeight - preloaderDisplay.height) / 2);
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
				
				if (stageWidth == 0 && stageHeight == 0) return;
			}
			
			showingDisplay = true;
			createChildren();
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
		 *  Creates the subcomponents of the display.
		 */
		override protected function createChildren():void {
			if (!preloaderDisplay) {
				preloaderDisplay = new IELTSPreloaderDisplay();
				
				onResize();
				
				addChild(preloaderDisplay);
			}
		}
		
		/**
		 * Event listener for the <code>ProgressEvent.PROGRESS event</code> event.
		 * Download of the first SWF app
		 */
		override protected function progressHandler(e:ProgressEvent):void {
			if (preloaderDisplay) {
				var percent:Number = Math.round((e.bytesLoaded / e.bytesLoaded) * 100);
				preloaderDisplay.setMainProgress(percent);
			} else {
				show();
			}
		}
		
		/**
		 * Event listener for the <code>RSLEvent.RSL_PROGRESS</code> event.
		 */
		override protected function rslProgressHandler(e:RSLEvent):void {
			if (e.rslIndex && e.rslTotal) {
				var percent:Number = Math.round((e.bytesLoaded / e.bytesTotal) * 100);
				preloaderDisplay.setDownloadRSLProgress(percent);
			}
		}
		
	}
}
