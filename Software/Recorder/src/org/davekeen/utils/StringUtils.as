package org.davekeen.utils {
	/**
	 * Function library containing static utilities to do with strings
	 * 
	 * @author  Dave Keen
	 * @version 1.0
	 */	
	public class StringUtils {
	
		/**
		 * Pad a string up to the given length with the specified padder string.  For example, with a length of 4 and a padder of
		 * "a" the string "z" would become "aaaz".  Padding is always applied on the left.  If the string is already of or more
		 * than the given length this function has no effect.
		 * 
		 * @param   string String The string to be padded.
		 * @param   padder String The character to use as padding.
		 * @param   length Number The length to pad the string to.
		 * @return  String The padded string.
		 */
		public static function padString(string:String, padder:String, length:Number):String {
			if (padder.length != 1)
				throw new Error("The padder must be exactly one character long (padder='" + padder + "')");
			
			while (string.length < length)
				string = padder + string;
				
			return string;
		}
	
	}
	
}