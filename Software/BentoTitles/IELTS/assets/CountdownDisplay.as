package {
	
	import mx.flash.UIMovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class CountdownDisplay extends UIMovieClip {
		
		protected var _targetDate:Date;
		
		public function CountdownDisplay() {
			super();
			this.addEventListener(Event.ENTER_FRAME, counterDisplay);
			this.init();
		}
		public function get targetDate():Date {
			return this._targetDate;
		}
		public function set targetDate(value:Date):void {
			this._targetDate = value;
		}
		protected function init():void {
			//trace("init");
			//this.targetDate(new Date(2013, 11, 30));
		}
		private function counterDisplay(e:Event):void {
			if (!this.targetDate) {
				trace("no date yet");
				daysTxt.text = "--";
				hoursTxt.text = "--";
				minsTxt.text = "--";
				secsTxt.text = "--";			
			} else {
				// Difference between now and the target date
				trace("target date=" + this.targetDate.toString());
				var justNow:Date = new Date();
				var ms:Number = targetDate.getTime()- justNow.getTime();
				
				// Don't try to display -ve numbers
				if (ms < 0) {
					daysTxt.text = "--";
					hoursTxt.text = "--";
					minsTxt.text = "--";
					secsTxt.text = "--";			
				} else {
					var sec:Number = Math.floor(ms/1000);
					var min:Number = Math.floor(sec/60);
					var hr:Number = Math.floor(min/60);
					var day:Number = Math.floor(hr/24);
		
					sec = sec % 60;
					min = min % 60;
					hr = hr % 24;
	
					daysTxt.text = zeroPad(day.toString(),2);
					hoursTxt.text = zeroPad(hr.toString(),2);
					minsTxt.text = zeroPad(min.toString(),2);
					secsTxt.text = zeroPad(sec.toString(),2);
				}
				//trace("target = " + targetDate.toString() + " min=" + min + " minsTxt=" + minsTxt.text);
			}
		}

		// From http://stackoverflow.com/questions/666531/what-would-you-use-to-zero-pad-a-number-in-flex-as3
		private function zeroPad(number:String, width:int):String {
			if (number.length < width)
				return "0" + zeroPad(number, width-1);
			return number;
		}

	}
	
}
