﻿package org.davekeen.utils {
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
		
		public static function dateAndTimeToString(date:Date, hours:Number=0, minutes:Number=0, seconds:Number=0):String {
			if (hours>0)
				date.hours = hours;
			if (minutes>0)
				date.minutes = minutes;
			if (seconds>0) 
				date.seconds = seconds;
			return DateUtils.dateToAnsiString(date);
		}
		
		public static function formatTimeZone():String {
			var offset:Number = new Date().timezoneOffset;
			var offsetSign:String = (offset == 0) ? "" : (offset < 0) ? "+" : "-"; 
			var offsetHours:Number = Math.abs(offset) / 60;
			var offsetWholeHours:Boolean = (offsetHours == int(offsetHours));
			var offsetMinutes:int = Math.abs(offset) - (int(offsetHours) * 60);
			// Remove trailing zeros
			//var offsetFormatted:String = (offsetWholeHours) ? offsetHours.toString() : offsetHours.toString().replace(/(\d+\.*[1-9]*)[0]*/g, "$1");
			var offsetFormatted:String = (offsetSign == "") ? "" : (offsetWholeHours) ? offsetHours.toString() : int(offsetHours).toString() + ":" + offsetMinutes.toString();
			return "GMT " + offsetSign + offsetFormatted;
		}

	}
	
}