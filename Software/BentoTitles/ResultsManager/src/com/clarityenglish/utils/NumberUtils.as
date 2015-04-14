package com.clarityenglish.utils {
	
	/**
	 * ...
	 * @author Clarity
	 * With functions from
	 * http://chrispaddison.com/flex/rounding-numbers-to-decimal-places-in-actionscript-3/
	 */
	public class NumberUtils {
			
		// Rounds a target number "up to" the nearest multiple of another number.
		public static function roundUpToMultiple(numberVal:Number, roundTo:Number):Number {
			return Math.ceil(numberVal / roundTo) * roundTo;
		}
		// Rounds a target number "up to" the number in an array.
		public static function roundUpToList(numberVal:Number, roundTo:Array):Number {
			for each (var i:uint in roundTo) {
				if (numberVal < i) {
					return i;
				}
			}
			return roundTo[roundTo.length - 1];
		}
		
	}
	
}