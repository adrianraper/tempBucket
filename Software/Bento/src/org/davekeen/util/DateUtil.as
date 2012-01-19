package org.davekeen.util {
	import spark.formatters.DateTimeFormatter;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class DateUtil {
			
		public static function formatDate(date:Date, dateFormat:String):String {
			var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
			dateFormatter.dateTimePattern = dateFormat;
			return dateFormatter.format(date);
		}
		
		public static function formatAnsiString(ansiString:String, dateFormat:String):String {
			return formatDate(ansiStringToDate(ansiString), dateFormat);
		}
		
		public static function dateToAnsiString(date:Date):String {
			// For some reason a date with a timestamp of 0 return NaN so put a special case in
			if (date.getTime() == 0) {
				return "1970-01-01 00:00:00";
			} else {
				return DateUtil.formatDate(date, "YYYY-MM-DD JJ:NN:SS");
			}
		}
		
		public static function ansiStringToDate(ansiString:String):Date {
			return new Date(ansiString.replace(/-/g, "/"));
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
		public static function dateDiff(startDate:Date = null, endDate:Date = null, datePart:String = "s"):Number {
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