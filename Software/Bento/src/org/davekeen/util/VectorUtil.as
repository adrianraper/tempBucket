package org.davekeen.util {
	import mx.formatters.DateFormatter;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class VectorUtil {
			
		public static function vectorToArray(vector:*):Array {
			var array:Array = [];
			for (var n:uint = 0; n < vector.length; n++)
				array[n] = vector[n];
			
			return array;
		}
		
	}
	
}