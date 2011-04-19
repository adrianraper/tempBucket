package org.davekeen.utils {
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ClassUtils {
		
		/**
		 * Return the class of an object as a Class (useful for 'is' comparisons)
		 * 
		 * @param	obj
		 * @return
		 */
		public static function getClass(obj:Object):Class {
			return Class(getDefinitionByName(getQualifiedClassName(obj)));
		}
		
		public static function getClassAsString(obj:Object):String {
			return getClass(obj).toString().replace(/\[class /, "").replace(/\]/, "");
		}
		
		/**
		 * Check if all the objects in the array are of the same class.
		 * 
		 * @param	objects An array of objects
		 * @return	This return the class of the objects or null if the array contains a mix (or is empty)
		 */
		public static function checkObjectClasses(objects:Array):Class {
			if (objects.length == 0) return null;
			
			var objectClass:Class = ClassUtils.getClass(objects[0]);
			
			for each (var o:Object in objects) {
				if (!(o is objectClass)) {
					objectClass = null;
					break;
				}
			}
				
			return objectClass;
		}
		
	}
	
}