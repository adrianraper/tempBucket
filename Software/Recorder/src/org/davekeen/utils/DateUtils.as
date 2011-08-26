package org.davekeen.utils {
	
	public class DateUtils {
		
		/**
		 * This function converts a time in seconds (e.g. 90) to a string in the form h:mm:ss.  Hours can be optionally
		 * turned on and off using the second parameter.
		 * 
		 * @param   seconds   Number The number of seconds - this is what is formatted
		 * @param   showHours Boolean Whether or not to show the hours field
		 * @param   seperator String The seperator to use between the hours, minutes and seconds
		 * @return  String The formatted time.
		 */
		public static function secondsToHMS(seconds:Number, showHours:Boolean, padMinutes:Boolean = true, seperator:String = null):String {
			seperator = (!seperator) ? ":" : seperator;
			
			var s:Number = Math.floor(seconds % 60);
			var m:Number = Math.floor(seconds / 60) % 60;
			var h:Number = Math.floor(seconds / 3600)
			
			return ((showHours) ? StringUtils.padString(h.toString(), "0",  2) + seperator : "") + ((padMinutes) ? StringUtils.padString(m.toString(), "0", 2) : m.toString()) + seperator + StringUtils.padString(s.toString(), "0", 2);
		}
		
	}
	
}