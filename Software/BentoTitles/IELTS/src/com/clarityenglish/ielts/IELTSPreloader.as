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
	import mx.core.FlexGlobals;
	
	public class IELTSPreloader extends SparkDownloadProgressBar {

		private var preloaderDisplay:IELTSPreloaderDisplay;
		private var showingDisplay:Boolean = false;
		private var swfPercent:Number = 0;
		private var rslPercent:Number = 0;
		private var rslBytesTotal:Array;
		private var rslBytesLoaded:Array;
		private var swfBytesTotal:Number = 0;
		private var swfBytesLoaded:Number = 0;
		/**
		 * Keep the rslEstimate low as it mostly completes before the main application
		 * and is highly variable based on how many rsls are in your browser already.
		 * There is a fairly persuasive argument that we only need the application actually...
		 */
		private var rslEstimate:Number = 1000000;
		private var swfEstimate:Number = 2500000; // published size
		private var passedCountryName:String;
		
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
			
			// gh#1281
			passedCountryName = (loaderInfo.parameters && loaderInfo.parameters.country) ? loaderInfo.parameters.country : '';
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
			for each (var i:Number in rslBytesTotal) {
				total += i;
			}
			// To make the bar hit 100% at the end
			rslEstimate = total;
			updateTotalProgressBar();
			
			var msg:String = "total rsl = " + total + " swf total = " + swfBytesTotal;
			trace(msg);
			logToConsole(msg);

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
			
			if (rslBytesTotal) {
				if (e.rslIndex >= 0 && e.bytesTotal >=0 ) {
					//rslBytesTotal[e.rslIndex] = e.bytesTotal;
				
					var msg:String = "complete rsl["+e.rslIndex+"] bytesTotal=" + e.bytesTotal;
					logToConsole(msg);
				}
			}
		}
		
		/**
		 * Event listener for the <code>ProgressEvent.PROGRESS event</code> event.
		 * Download of the main application swf
		 */
		override protected function progressHandler(e:ProgressEvent):void {
			if (preloaderDisplay) {
				// Strangely, e.bytesTotal get bigger as loading takes place... why
				swfBytesTotal = (e.bytesTotal > swfBytesTotal) ? e.bytesTotal : swfBytesTotal;
				
				//var msg:String = "swf bytesLoaded=" + e.bytesLoaded + " bytesTotal=" + e.bytesTotal;
				//logToConsole(msg);
				
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
					// but this is pretty meaningless because the moment an rsl is in the browser, it will
					// never trigger this handler to fill up it's space. So most spaces will be empty.
					if (rslBytesTotal==null) {
						var msg:String = "first rsl, total number is " + e.rslTotal;
						logToConsole(msg);
						rslBytesTotal = new Array(e.rslTotal);
						rslBytesLoaded = new Array(e.rslTotal);
					}

					//msg = "rsl["+e.rslIndex+"] bytesLoaded=" + e.bytesLoaded + " bytesTotal=" + e.bytesTotal;
					//logToConsole(msg);

					// Add to the total progress bar
					rslBytesLoaded[e.rslIndex] = e.bytesLoaded;				
					rslBytesTotal[e.rslIndex] = e.bytesTotal;				
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
			var bytesTotal:Number = 0;
			for each (i in rslBytesTotal) {
				bytesTotal += i;
			}
			if (bytesTotal < rslEstimate)
				bytesTotal = rslEstimate;
			
			// I would like to do the following, but swfTotalBytes never reaches full size until it is fully loaded!
			//var totalPercent:Number = Math.round(100 * (swfBytesLoaded + bytesLoaded) / (swfBytesTotal + bytesTotal)); 
			var totalPercent:Number = Math.round(100 * (swfBytesLoaded + bytesLoaded) / (swfEstimate + bytesTotal)); 
			preloaderDisplay.setMainProgress(totalPercent);
			
			// gh#1281
			preloaderDisplay.changeCountryName(passedCountryName);
		}
		
		private function logToConsole(message:String):void {
			if (ExternalInterface.available)
				ExternalInterface.call("log", message);
		}
		
	}
}
