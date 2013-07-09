package com.clarityenglish.bento.view.recorder.ui {
	import com.clarityenglish.bento.view.recorder.events.WaveformRangeEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	
	import org.davekeen.util.DateUtil;
	
	[Event(name="select", type="com.clarityenglish.bento.view.recorder.events.WaveformRangeEvent")]
	public class WaveformRenderer extends UIComponent implements IDataRenderer {
		
		private static const RECORD_UPDATE_INTERVAL:Number = 250;
		
		public static const SELECT:String = "select";
		public static const DRAG:String = "drag";
		
		[Bindable]
		public var showTime:Boolean = true;
		
		// Follow mode will make sure that the playhead (or end of file if recording) is always visible by scrolling the viewport.
		[Bindable]
		public var followMode:Boolean = true;
		
		// The sample rate (used when converting between samples and seconds for displaying the time axis)
		public var sampleRate:Number;
		
		// The sample data
		private var samples:ByteArray;
		
		// The bitmap and bitmapdata we use to draw the waveform, and the sprite containing them (so we get InteractiveObject functionality)
		private var bitmapData:BitmapData;
		private var bitmap:Bitmap;
		private var sprite:Sprite;
		
		// The content - this is actually everything that gets masked (i.e. everything except for the time axis)
		private var contentSprite:Sprite;
		
		// The static grid background
		private var gridSprite:Sprite;
		
		// The playhead
		private var playheadSprite:Sprite;
		
		// The selection
		private var selectionSprite:Sprite;
		
		// The time axis sprite
		private var timeAxisSprite:Sprite;
		
		// The mask sprite
		private var maskSprite:Sprite;
		
		private static const RECORDING_COLOUR:Number = 0xFFE51E39;
		private static const RECORDED_COLOUR:Number = 0xFFA32A2F;
		private static const MODEL_COLOUR:Number = 0xFF333333;
		private var waveColour:Number = MODEL_COLOUR;
		
		// The left and right boundaries the renderer is showing
		private var _leftSample:Number = 0;
		private var _rightSample:Number = -1;
		
		// The left and right selection boundaries
		private var _leftSelection:Number = -1;
		private var _rightSelection:Number = -1;
		
		// These variables are using for calculations when dragging
		private var dragStartSample:Number;
		private var dragStartLeftSample:Number;
		private var dragStartRightSample:Number;
		
		private var isDragging:Boolean;
		
		// This is injected from the proxy and is used to add gain in realtime (for the renderer this means adding to the amplitude)
		private var _playbackGain:Number = 0;
		// This is injected from the proxy and is used to scroll horizontally to the place you want to play back from
		private var _scrubValue:Number = 0;
		
		// The timer used to automatically redraw the waveform (whist recording)
		private var autoRefreshTimer:Timer;
		
		private var dragTimer:Timer;
		
		public var dragMode:String = DRAG;
		
		private static const RMS_AVERAGING_DISTANCE:Number = 150;
		
		public function WaveformRenderer() {
			super();
			
			autoRefreshTimer = new Timer(RECORD_UPDATE_INTERVAL, 0);
			autoRefreshTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				if (followMode) follow(samples.length / 4);
				invalidateDisplayList();
				validateNow();
			} );
			
			dragTimer = new Timer(150, 0);
			dragTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				doDrag(sprite.mouseX);
			} );
		}
		
		[Bindable]
		public function set leftSample(value:Number):void {
			// Sanitize the sample position to ensure it is an integer and divisible by 4
			value = Math.round(value) + (Math.round(value) % 4);
			_leftSample = value;
		}
		
		public function get leftSample():Number {
			return _leftSample;
		}
		
		/**
		 * This sets the number of samples to show onscreen - for example, to make the renderer always show 5 seconds of the wave this would be 5 * sampleRate.
		 * Since follow mode is on by default this will scroll the waveform as it plays/records to always keep the value set here visible.
		 */
		public function set showSamples(value:Number):void {
			_rightSample = value * 2;
		}
		
		[Bindable]
		public function set rightSample(value:Number):void {
			// Sanitize the sample position to ensure it is an integer and divisible by 4
			value = (value >= 0) ? Math.round(value) + (Math.round(value) % 4) : value;
			_rightSample = value;
		}
		
		public function get rightSample():Number {
			return (_rightSample == -1) ? samples.length / 4 : _rightSample;
		}
		
		private function get leftSeconds():Number {
			return sampleToSeconds(leftSample);
		}
		
		private function get rightSeconds():Number {
			return sampleToSeconds(rightSample);
		}
		
		public function set leftSelection(leftSelection:Number):void {
			_leftSelection = leftSelection;
			
			invalidateProperties();
		}
		
		public function get leftSelection():Number {
			return _leftSelection;
		}
		
		public function set rightSelection(rightSelection:Number):void {
			_rightSelection = rightSelection;
			
			invalidateProperties();
		}
		
		public function get rightSelection():Number {
			return _rightSelection;
		}
		
		public function set playbackGain(playbackGain:Number):void {
			_playbackGain = playbackGain;
			
			invalidateDisplayList();
		}
		public function set scrubValue(scrubPercentage:Number):void {
			//trace("scrub to " + (scrubPercentage * 100).toString());
			// What is the left sample number to relate to this percentage?
			var value:Number = samples.length * scrubPercentage;
			// Sanitize the sample position to ensure it is an integer and divisible by 4
			value = Math.round(value) + (Math.round(value) % 4);
			playheadPosition = value;
			invalidateDisplayList();
		}
		
		/**
		 * Set leftSample and rightSample to show the entire waveform and redraw it
		 */
		public function showAll():void {
			leftSample = 0;
			rightSample = -1;
			
			invalidateDisplayList();
			invalidateProperties();
		}
		
		/**
		 * Clear any selection
		 */
		public function clearSelection():void {
			leftSelection = rightSelection = 1;
		}
		
		/**
		 * Set the position and visibility of the playhead
		 */
		public function set playheadPosition(playheadPosition:Number):void {
			if (playheadSprite) {
				playheadSprite.visible = (playheadPosition > -1);
				playheadSprite.x = sampleToX(playheadPosition);
			}
			
			if (followMode && playheadPosition > -1) follow(playheadPosition);
		}
		
		/**
		 * Tells the renderer whether we are recording or not. Whilst recording the view is updated every RECORD_UPDATE_INTERVAL milliseconds, plus the
		 * waveform goes red.
		 * 
		 */
		public function set recording(recording:Boolean):void {
			if (recording) {
				waveColour = RECORDING_COLOUR;
				autoRefreshTimer.start();
			} else {
				waveColour = RECORDED_COLOUR;
				autoRefreshTimer.stop();
			}
			
			invalidateDisplayList();
		}
		
		public function set data(value:Object):void {
			samples = value as ByteArray;
			
			invalidateDisplayList();
		}
		
		public function get data():Object {
			return samples;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			if (!contentSprite) {
				contentSprite = new Sprite();
				addChild(contentSprite);
			}
			
			if (!sprite) {
				// The bitmap needs a fake BitmapData to start with otherwise it doesn't render
				bitmapData = new BitmapData(1, 1, true);
				bitmap = new Bitmap(bitmapData, "auto", true);
				
				selectionSprite = new Sprite();
				selectionSprite.blendMode = BlendMode.MULTIPLY;
				
				sprite = new Sprite();
				
				sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				sprite.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
				
				// v4.0.1.3 Pick up selecting outside the waveform
				// Trouble is that the grid is on top of the waveform sprite, so each line you cross triggers an onMouseOut
				stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				
				sprite.addChild(bitmap);
				sprite.addChild(selectionSprite);
				
				contentSprite.addChild(sprite);
			}
			
			if (!gridSprite) {
				gridSprite = new Sprite();
				contentSprite.addChild(gridSprite);
			}
			
			if (!playheadSprite) {
				playheadSprite = new Sprite();
				playheadSprite.blendMode = BlendMode.DIFFERENCE;
				playheadSprite.x = -1;
				playheadSprite.visible = false;
				contentSprite.addChild(playheadSprite);
			}
			
			if (!timeAxisSprite) {
				timeAxisSprite = new Sprite();
				addChild(timeAxisSprite);
			}
			
			if (!maskSprite) {
				maskSprite = new Sprite();
				addChild(maskSprite);
				contentSprite.mask = maskSprite;
			}
			
		}
		
		private function onMouseDown(e:MouseEvent):void {
			var localX:Number = e.localX;
			
			isDragging = true;
			
			switch (dragMode) {
				case SELECT:
					leftSelection = rightSelection = xToSample(localX);
					break;
				case DRAG:
					dragStartSample = xToSample(localX);
					dragStartLeftSample = leftSample;
					dragStartRightSample = rightSample;
					break;
			}
			
			dragTimer.start();
		}
		
		private function onMouseMove(e:MouseEvent):void {
			var localX:Number = sprite.globalToLocal(new Point(e.stageX, e.stageY)).x;
			doDrag(localX);
		}
		
		private function doDrag(localX:Number):void {			
			if (isDragging) {
				switch (dragMode) {
					case SELECT:
						rightSelection = xToSample(localX);
						
						var sampleDifference:Number;
						if (rightSelection > rightSample) sampleDifference = rightSample - rightSelection;
						if (rightSelection < leftSample && leftSample >= 0) sampleDifference = leftSample - rightSelection;
						
						if (!isNaN(sampleDifference)) {
							//sampleDifference = rightSample - rightSelection;
							leftSample = leftSample - sampleDifference;
							rightSample = rightSample - sampleDifference;
						
							// As soon as any dragging happens, we disable follow [ticket #30]
							followMode = false;
							
							invalidateProperties();
							invalidateDisplayList();
						}
						
						break;
					case DRAG:
						sampleDifference = dragStartSample - xToSample(localX, dragStartLeftSample);
						
						leftSample = dragStartLeftSample + sampleDifference;
						rightSample = dragStartRightSample + sampleDifference;
						
						// As soon as any dragging happens, we disable follow [ticket #30]
						followMode = false;
						
						invalidateProperties();
						invalidateDisplayList();
						break;
				}
			}
		}
		private function onMouseOut(e:MouseEvent):void {
			// Need to see if you have really left the waveform
			// and if you have, which direction are you going in so that we can start a scroll and keep extending the selection
		}
		
		/**
		 * This method zooms the waveform in or out (depending on mousewheel direction) around the center point
		 * 
		 * @param	e
		 */
		private function onMouseWheel(e:MouseEvent):void {
			var direction:int = e.delta / Math.abs(e.delta);
			var amount:Number = Math.round((rightSample - leftSample) * 0.15);
			
			// We can't zoom in past a certain level
			if (direction > 0 && amount < 900) return;
			
			leftSample += (direction * amount);
			rightSample -= (direction * amount);
			
			// If we have zoomed out past the wave limits then reset them
			if (leftSample < 0) leftSample = 0;
			if (rightSample > samples.length / 4) rightSample = -1;
			
			invalidateDisplayList();
			invalidateProperties();
		}
		
		private function onMouseUp(e:MouseEvent):void {
			var localX:Number = sprite.globalToLocal(new Point(e.stageX, e.stageY)).x;
			
			if (isDragging) {
				switch (dragMode) {
					case SELECT:
						rightSelection = xToSample(localX);
						
						if (leftSelection > rightSelection) {
							// If the drag was from right to left we need to swap these two around
							var tempRightSelection:Number = rightSelection;
							
							rightSelection = leftSelection;
							leftSelection = tempRightSelection;
						}
						
						// Dispatch an event in case a listener wants to react to this selection
						dispatchEvent(new WaveformRangeEvent(WaveformRangeEvent.SELECT, leftSelection, rightSelection));
						break;
					case DRAG:
						break;
				}
			}
			
			isDragging = false;
			dragTimer.reset();
		}
		
		/**
		 * Follow keeps the amount of waveform showing constant, but scrolls it such that position is at the far right
		 * 
		 * @param	position
		 */
		private function follow(position:Number):void {
			if (position > rightSample || position < leftSample) {
				var difference:Number = (position > rightSample) ? position - rightSample : position - leftSample;
				
				leftSample += difference;
				rightSample += difference;
				
				invalidateDisplayList();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			// Draw the selection box
			if (leftSelection > 0 && rightSelection > 0) { // TODO: Only if the selection is onscreen
				selectionSprite.graphics.clear();
				selectionSprite.graphics.beginFill(0xFFCCCCCC, 1);
				selectionSprite.graphics.drawRect(sampleToX(leftSelection), 0, sampleToX(rightSelection) - sampleToX(leftSelection), height);
				selectionSprite.graphics.endFill();
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Draw the mask
			drawMask(unscaledWidth, unscaledHeight);
			
			// Draw the background grid
			drawGrid(unscaledWidth, unscaledHeight);
			
			if (samples && unscaledWidth > 0 && unscaledHeight > 0) {
				// Draw the waveform
				bitmapData = new BitmapData(unscaledWidth, unscaledHeight, true);
				renderWaveform(unscaledWidth, unscaledHeight);
				bitmap.bitmapData = bitmapData;
				
				// Draw the time axis
				if (showTime) {
					renderTimeAxis(unscaledWidth);
					timeAxisSprite.y = unscaledHeight;
				}
				
			}
			
			// Draw the playhead
			playheadSprite.graphics.clear();
			playheadSprite.graphics.lineStyle(1, 0xFFAAAAAA);
			playheadSprite.graphics.moveTo(0, 0);
			playheadSprite.graphics.lineTo(0, unscaledHeight);
		}
		
		private function drawMask(width:Number, height:Number):void{
			maskSprite.graphics.clear();
			maskSprite.graphics.beginFill(0xFF000000, 1);
			maskSprite.graphics.drawRect(0, 0, width, height);
			maskSprite.graphics.endFill();
		}
		
		private function drawGrid(width:Number, height:Number):void {
			gridSprite.graphics.clear();
			gridSprite.graphics.lineStyle(1, 0, 0.1);
			
			for (var x:int = -20; x < width; x += 40) {
				gridSprite.graphics.moveTo(x, -20);
				gridSprite.graphics.lineTo(x, height);
			}
			
			for (var y:int = -20; y < height; y += 40) {
				gridSprite.graphics.moveTo(-20, y);
				gridSprite.graphics.lineTo(width, y);
			}
					
		}
		
		/**
		 * Render the waveform between leftSample and rightSample such that it fits nicely in the component.
		 * 
		 * @param	width
		 * @param	height
		 */
		private function renderWaveform(width:Number, height:Number):void {
			// Determine the interval in samples that we are going to show
			var samplesToShow:Number = rightSample - leftSample;
			
			// Now determine the sample interval we are going to display based on the width and samplesToShow.  Ensure that width is a multiple of 4 otherwise
			// our calculations will go awry.
			width = width + (width % 4);
			var sampleInterval:int = Math.floor(samplesToShow / width);
			
			// Draw the waveform (left channel only since we only care about mono)
			var rect:Rectangle = new Rectangle(0, 0, 1, 1);
			
			// Draw the waveform (don't draw anything if attemptedSamplesPosition < 0)
			var attemptedSamplesPosition:Number = (leftSample + leftSample % 4) * 4;
			samples.position = Math.max(0, attemptedSamplesPosition);
			while (attemptedSamplesPosition <= rightSample * 4 && samples.bytesAvailable > 0) {
				if (attemptedSamplesPosition >= 0) {
					var amplitude:Number = (getRMSAmplitude(sampleInterval) * (isNaN(_playbackGain) ? 1 : _playbackGain)) * height;
					
					rect.x = sampleToX(samples.position / 4);
					rect.y = Math.floor(height / 2) - amplitude;
					rect.height = amplitude * 2;
					
					bitmapData.fillRect(rect, waveColour);
				}
				
				attemptedSamplesPosition += sampleInterval * 4;
				samples.position = Math.max(0, attemptedSamplesPosition);
			}
			
			// Finally drag a line across the entire width of the waveform so there are never empty areas within the waveform itself (outside the waveform is ok)
			var lineX:Number = Math.max(0, sampleToX(0), sampleToX(leftSample));
			var lineWidth:Number = Math.min(width, sampleToX(samples.length / 4), sampleToX(rightSample)) - lineX;
			bitmapData.fillRect(new Rectangle(lineX, Math.floor(height / 2), lineWidth, 1), waveColour);			
		}
		
		private function renderTimeAxis(width:Number):void {
			timeAxisSprite.graphics.clear();
			
			// Draw the track
			timeAxisSprite.graphics.lineStyle(1, 0xFF000000);
			timeAxisSprite.graphics.moveTo(0, 0);
			timeAxisSprite.graphics.lineTo(width, 0);
			
			// Delete any existing children (these will be textfields)
			while (timeAxisSprite.numChildren)
				timeAxisSprite.removeChildAt(0);
			
			// Work out the seconds interval so we only ever have 5 time labels onscreen at once
			var secondInterval:uint = Math.max(Math.round((Math.ceil(rightSeconds) - Math.ceil(leftSeconds)) / 5), 1);
			
			for (var seconds:int = Math.ceil(leftSeconds); seconds < Math.ceil(rightSeconds); seconds += secondInterval) {
				var x:Number = secondsToX(seconds);
				
				timeAxisSprite.graphics.moveTo(x, 0);
				timeAxisSprite.graphics.lineTo(x, -3);
				
				var textField:TextField = new TextField();
				textField.autoSize = TextFieldAutoSize.CENTER;
				textField.selectable = false;
				textField.text = DateUtil.secondsToHMS(Math.abs(seconds), false, false);
				
				var textFormat:TextFormat = new TextFormat();
				textFormat.align = TextFormatAlign.CENTER;
				// How is this textFormat picking up style? From a css or just not getting one?
				textFormat.font = "Verdana,Helvetica";
				textFormat.size = 9;
				
				textField.defaultTextFormat = textFormat;
				textField.setTextFormat(textFormat);
				
				textField.x = x - (textField.textWidth / 2) - 1.5;
				//textField.y = -20;
				textField.y = -16;
				
				timeAxisSprite.addChild(textField);
			}
		}
		
		/**
		 * Get the value at the current samples position by taking an RMS between position and (position + RMS_AVERAGING_DISTANCE)
		 * 
		 * @return
		 */
		private function getRMSAmplitude(sampleInterval:Number):Number {
			var originalPosition:uint = samples.position;
			
			var average:Number = 0;
			
			for (var n:int = 0; n < Math.min(sampleInterval, RMS_AVERAGING_DISTANCE); n++) {
				average += Math.pow(samples.readFloat(), 2);
				
				if (samples.bytesAvailable <= 4) break;
				
				samples.position += 4;
			}
			
			samples.position = originalPosition;
			
			return Math.sqrt(average / n);
		}
		
		/**
		 * Convert a sample position to an X position on the screen (based on the component width and left/right sample)
		 * 
		 * @param	sample
		 * @return
		 */
		private function sampleToX(sample:Number):Number {
			return (sample - leftSample) / (rightSample - leftSample) * width;
		}
		
		/**
		 * Convert an X position on the screen to a sample position
		 * 
		 * @param	x
		 * @param	offset
		 * @return
		 */
		private function xToSample(x:Number, offset:Number = NaN):Number {
			return (x / width) * (rightSample - leftSample) + ((isNaN(offset) ? leftSample : offset));
		}
		
		/**
		 * Convert a sample position to a position in seconds
		 * 
		 * @param	sample
		 * @return
		 */
		private function sampleToSeconds(sample:Number):Number {
			return sample / 2 / sampleRate;
		}
		
		/**
		 * Convert a position in seconds to an X position on the screen
		 * @param	seconds
		 * @return
		 */
		private function secondsToX(seconds:Number):Number {
			return (seconds - leftSeconds) / (rightSeconds - leftSeconds) * width;
		}
		
	}

}