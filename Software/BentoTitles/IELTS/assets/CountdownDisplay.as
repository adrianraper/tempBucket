package {
	
	import mx.flash.UIMovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	public class CountdownDisplay extends UIMovieClip {
		
		protected var _targetDate:Date = new Date(2012, 11, 30);
		
		public function CountdownDisplay() {
			// constructor code
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
			trace("init");
			//this._targetDate(new Date(2013, 11, 30));
		}
		private function counterDisplay(e:Event):void {
			if (!this._targetDate) {
				trace("no date yet");
				daysTxt.text = "--";
				hoursTxt.text = "--";
				minsTxt.text = "--";
				secsTxt.text = "--";			
			} else {
				trace("target = " + this._targetDate.toString());
				// Difference between now and the target date
				var justNow:Date = new Date();
				var ms:Number = targetDate.getTime()- justNow.getTime();
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
		}

		// From http://stackoverflow.com/questions/666531/what-would-you-use-to-zero-pad-a-number-in-flex-as3
		private function zeroPad(number:String, width:int):String {
			if (number.length < width)
				return "0" + zeroPad(number, width-1);
			return number;
		}
		/**
		 * This function returns the difference between two dates. 
		 * The answer is rounded to the closest unit your choose. 
		 * @param startDate as a Date
		 * @param endDate as a Date
		 * @param datePart as a String - s,m,h,d,w,M,y - follow spark date formatter key
		 * @return difference as a Number
		 * 
		 */
		private function dateDiff(startDate:Date = null, endDate:Date = null, datePart:String = "s"):Number {
			if (!startDate)
				startDate = new Date();
			if (!endDate)
				endDate = new Date();
			
			var startNumber:Number = startDate.getTime();
			var endNumber:Number = endDate.getTime();
			var difference:Number = Math.abs(endNumber - startNumber);
			switch (datePart) {
				case "s":
					var divisor:Number = 1000;
					break;
				case "m":
					divisor = 60*1000;
					break;
				case "h":
					divisor = 60*60*1000;
					break;
				case "d":
					divisor = 24*60*60*1000;
					break;
				case "w":
					divisor = 7*24*60*60*1000;
					break;
				case "M":
					divisor = 2629744*1000;
					break;
				case "y":
					divisor = 31556926*1000;
					break
				default:
					divisor = 1;
			}
			return Math.round(difference/divisor);
		}

	}
	
}
