package org.davekeen.utils {
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ArrayUtils {
		
		/**
		 * Search a given array (which must contain dynamic Objects) for the object with field equal to search.  If the item is not found
		 * this will return null.
		 * 
		 * @param	array The array to search
		 * @param	search The term to search for (any type)
		 * @param	field The field to search on
		 * @return
		 */
		public static function searchArrayForObject(array:Array, search:*, field:String):Object {
			for each (var item:Object in array)
				if (item[field] == search) return item;
			
			return null;
		}
		/*
		 * Get rid of duplicates in an array
		 * http://jared.simplistika.com
		 * and quince @ peakstudios.com
		 * 
		 * @param	array The array to remove duplicates from
		 * @return	array
		 */
		public static function removeDuplicates(ac:Array):Array {
			for (var i:Number = 0; i < ac.length - 1; i++) {
				for (var j:Number = i + 1; j < ac.length; j++) {
					if (ac[i] === ac[j]) {
						ac.splice(j, 1);
						j--;
					}
				}
			}
			return ac;
		}
		
		// From O'Reilly ActionScript 3 cookbook
	    public static function duplicate(oArray:Object, bRecursive:Boolean = false):Object {
			var oDuplicate:Object;
			if (bRecursive) {
				if (oArray is Array) {
					oDuplicate = new Array();
					for (var i:Number = 0; i < oArray.length; i++) {
						if (oArray[i] is Object) {
							oDuplicate[i] = duplicate(oArray[i]);
						} else {
							oDuplicate[i] = oArray[i];
						}
					}
					return oDuplicate;
				} else {
					oDuplicate = new Object();
					for(var sItem:String in oArray) {
						if(oArray[sItem] is Object && !(oArray[sItem] is String) && !(oArray[sItem] is Boolean) && !(oArray[sItem] is Number)) {
							oDuplicate[sItem] = duplicate(oArray[sItem], bRecursive);
							} else {
								oDuplicate[sItem] = oArray[sItem];
							}
						}
						return oDuplicate;
				}
			} else {
				if(oArray is Array) {
					return oArray.concat();
				} else {
					oDuplicate = new Object();
					for (sItem in oArray) {
						oDuplicate[sItem] = oArray[sItem];
					}
					return oDuplicate;
				}
			}
		}
	}
}