package org.davekeen.utils {
	import mx.formatters.DateFormatter;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class DateUtils {
			
		public static function formatDate(date:Date, dateFormat:String):String {
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = dateFormat;
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
				return DateUtils.formatDate(date, "YYYY-MM-DD JJ:NN:SS");
			}
		}
		
		public static function ansiStringToDate(ansiString:String):Date {
			return new Date(ansiString.replace(/-/g, "/"));
		}
		
		public static function dateAndTimeToString(date:Date, hours:Number, minutes:Number, seconds:Number=0):String {
			date.hours = hours;
			date.minutes = minutes;
			date.seconds = seconds;
			return DateUtils.dateToAnsiString(date);
		}
	}
	
}