package com.clarityenglish.ielts {
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.preloaders.SparkDownloadProgressBar;
	
	import org.davekeen.util.ClassUtil;
	import org.flexunit.internals.dependency.ExternalDependencyResolver;
	
	public class IELTSPreloader extends SparkDownloadProgressBar {

		/**
		 * Standard flex logger
		 */
		//private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));

		private var preloaderDisplay:IELTSPreloaderDisplay;
		private var showingDisplay:Boolean = false;
		private var swfPercent:Number = 0;
		private var rslPercent:Number = 0;
		private var rslTotalBytes:Array;
		private var rslBytesLoaded:Array;
		private var swfTotalBytes:Number = 0;
		private var swfBytesLoaded:Number = 0;
		private var rslEstimate:Number = 2409361;
		private var swfEstimate:Number = 7180653;
		
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
		 *  Event listener for the <code>FlexEvent.INIT_COMPLETE</code> event.
		 *  NOTE: This event can be commented out to stop preloader from completing during testing
		 */
		override protected function initCompleteHandler(event:Event):void {
			stage.removeEventListener(Event.RESIZE, onResize);
			//trace("INIT complete");
			var total:Number = 0;
			for each (var i:Number in rslTotalBytes) {
				total += i;
			}
			trace("total rsl = " + total + " swf total = " + swfTotalBytes);
			//log.info("total rsl = {0}, swf total = {1}", total, swfTotalBytes);

			dispatchEvent(new Event(Event.COMPLETE));
		}
		// AR
		/*
		override protected function initProgressHandler(event:Event):void {
			if (preloaderDisplay) {
				trace("initProgress");
				preloaderDisplay.initLabel.text = 'init progress event';
			} else {
				show();
			}
		}
		*/
		// Called when each rsl has been loaded
		// This throws an error on CE.com - and I'm not really using it so comment out.
		override protected function rslCompleteHandler(e:RSLEvent):void {
			//var rsl:RSLEvent = e;
			
			if (rslTotalBytes) {
				if (e.rslIndex >= 0 && e.bytesTotal >=0 )
					rslTotalBytes[e.rslIndex] = e.bytesTotal;
			}
		}
		
		/**
		 * Event listener for the <code>ProgressEvent.PROGRESS event</code> event.
		 * Download of the main application swf
		 */
		override protected function progressHandler(e:ProgressEvent):void {
			if (preloaderDisplay) {
				// Strangely, you can't rely on e.bytesTotal not going up as loading takes place... why
				swfTotalBytes = (e.bytesTotal > swfTotalBytes) ? e.bytesTotal : swfTotalBytes;
				
				// Add to the total progress bar. 
				swfBytesLoaded = e.bytesLoaded;
				updateTotalProgressBar();
				
			} else {
				show();
			}
		}
		
		/**
		 * Event listener for the <code>RSLEvent.RSL_PROGRESS</code> event.
		 */
		override protected function rslProgressHandler(e:RSLEvent):void {
			if (preloaderDisplay) {
				if (e.rslTotal) {
					
					// First time, set up the rsl arrays as you now know how many spaces you need
					if (!rslTotalBytes) {
						rslTotalBytes = new Array(e.rslTotal);
						rslBytesLoaded = new Array(e.rslTotal);
					}
					
					// Add to the total progress bar
					rslBytesLoaded[e.rslIndex] = e.bytesLoaded;				
					updateTotalProgressBar();
					
				}				
			} else {
				show();
			}
		}
		
		private function updateTotalProgressBar():void {
			
			var bytesLoaded:Number = 0;
			for each (var i:Number in rslBytesLoaded) {
				bytesLoaded += i;
			}
			// I would like to do the following, but it seems swfTotalBytes is dynamic!
			//var totalPercent:Number = Math.round(100 * (swfBytesLoaded + bytesLoaded) / (swfTotalBytes + rslEstimate)); 
			var totalPercent:Number = Math.round(100 * (swfBytesLoaded + bytesLoaded) / (swfEstimate + rslEstimate)); 
			preloaderDisplay.setMainProgress(totalPercent);
		}
		
		private function logToConsole(message:String):void {
			if (ExternalInterface.available)
				ExternalInterface.call("log", message);
		}
		
	}
}
