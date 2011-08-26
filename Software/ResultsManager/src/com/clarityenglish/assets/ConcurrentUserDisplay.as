package com.clarityenglish.assets 
{
	/**
	 * ...
	 * @author Adrian Raper
	 */
	//import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mx.controls.Label;
	import mx.core.Container;
	import flash.text.TextField;
	import org.davekeen.controls.SmoothImage;
	import com.clarityenglish.utils.TraceUtils;
	
	public class ConcurrentUserDisplay extends Container
	{
		private var _concurrentUsers:uint;
		//private var _caption:Label;
		//private var container:Sprite;
		
		[Embed(source="/../assets/cudOff.swf")]
		private var offUser:Class;
		[Embed(source="/../assets/cudOn.swf")]
		private var onUser:Class;
		
		private var _image:Array;
		
		// Constructor
		public function ConcurrentUserDisplay() {
			super();			
		}
		// Getter and setter
		public function set value(value:uint):void {
			//TraceUtils.myTrace("setting value of cud to " + value);
			_concurrentUsers = Math.floor(value);
			redraw();
		}
		public function get value():uint {
			return _concurrentUsers;
		}
		
		// Display functions
		private function addImage(e:TimerEvent):void {
			//TraceUtils.myTrace("add image " + (e.currentTarget as Timer).currentCount + " x=" + _image[(e.currentTarget as Timer).currentCount].x);
			addChild(_image[(e.currentTarget as Timer).currentCount]);
		}
		private function redraw():void {
			_image = new Array();
			removeAllChildren();
			// It would be nice to fill the space with the number of users
			// We have a width of about 230 to look good in, height is about 150, maybe a little more
			// We want a square up until 5x5, then 5 rows up until 75
			var value:uint = _concurrentUsers;
			var theSquare:uint = Math.ceil(Math.sqrt(value));
			if (theSquare <= 5) {
				var colLimit:uint = theSquare;
				var imageSize:uint = Math.floor(25 * (5 / theSquare));
				var timerSpeed:uint = 50;
			} else if (value<=75) {
				colLimit = 15;
				imageSize = 25;
				timerSpeed = 40;
			} else if (value<=120) {
				colLimit = Math.ceil(value/6);
				imageSize = 20;
				timerSpeed = 35;
			} else if (value<=176) {
				colLimit = Math.ceil(value/8);
				imageSize = 16;
				timerSpeed = 25;
			} else {
				value = 176;
				colLimit = 22;
				imageSize = 16;
				timerSpeed = 25;
			}
			//TraceUtils.myTrace("value=" + value + " sqrt=" + theSquare + " imagesize=" + imageSize);
			var row:uint = 1;
			var col:uint = 1;
			// Array goes from 1 to make the currentCount of the Timer event match
			for (var i:uint = 1; i <= value; i++) {
				// Make an array of images
				_image[i] = new SmoothImage();
				_image[i].width = _image[i].height = imageSize;
				if (col > colLimit) {
					col = 1;
					row++;
				}
				_image[i].x = (col-1) * (_image[i].width/1.8);
				_image[i].y = (row-1) * (imageSize+5);
				_image[i].source = onUser;
				col++;
			}
			// Then add them to the stage one by one
			var animatedAdder:Timer = new Timer(timerSpeed, value);
			animatedAdder.addEventListener(TimerEvent.TIMER, addImage);
			animatedAdder.start();
		}

	}

}