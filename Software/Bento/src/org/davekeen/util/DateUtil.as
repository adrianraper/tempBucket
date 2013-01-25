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
				return DateUtil.formatDate(date, "yyyy-MM-dd HH:mm:ss");
			}
		}
		
		public static function ansiStringToDate(ansiString:String):Date {
			return new Date(ansiString.replace(/-/g, "/"));
		}
		
		/**
		 * This function adds x units to the date. This is NOT accurate, but is fine for rough purposes.
		 * Leap years etc will go wrong and months are just average numbers.
		 * @param startDate as a Date
		 * @param datePart as a String - s,m,h,d,w,M,y - follow spark date formatter key
		 * @param quantity as a number
		 * @return new Date
		 * 
		 */
		public static function dateAdd(startDate:Date, datePart:String = "s", quantity:int = 1):Date {
			if (!startDate)
				startDate = new Date();
			
			var startNumber:Number = startDate.getTime();
			switch (datePart) {
				case "s":
					var multiplier:Number = 1000;
					break;
				case "m":
					multiplier = 60*1000;
					break;
				case "h":
					multiplier = 60*60*1000;
					break;
				case "d":
					multiplier = 24*60*60*1000;
					break;
				case "w":
					multiplier = 7*24*60*60*1000;
					break;
				case "M":
					multiplier = 2629744*1000;
					break;
				case "y":
					multiplier = 31556926*1000;
					break
				default:
					multiplier = 1;
			}
			var endNumber:Number = startNumber + (quantity*multiplier);
			return new Date(endNumber);
			
		}
		
		/**
		 * This function returns the difference between two dates. 
		 * The answer is rounded to the closest unit you choose. 
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
			// Don't do abs as we might want to know -ve difference
			//var difference:Number = Math.abs(endNumber - startNumber);
			var difference:Number = endNumber - startNumber;
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