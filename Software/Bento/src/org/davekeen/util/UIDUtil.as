package org.davekeen.util {

	public class UIDUtil {
		
		/**
		 * A helper method to break a UID string into component parts
		 * 
		 * UID:String = productCode.courseID.unitID.exerciseID;
		 * 
		 * @param UID
		 * 
		 */
		public static function UID(value:String):Object {
			
			var UIDArray:Array = value.split('.');
			if (UIDArray.length>0) {
				var productCode:String = UIDArray[0];
			} else {
				return null;
			}
			if (UIDArray.length>1) 
				var courseID:String = UIDArray[1];
			if (UIDArray.length>2) 
				var unitID:String = UIDArray[2];
			if (UIDArray.length>3) 
				var exerciseID:String = UIDArray[3];
		
			return {productCode:productCode,
					courseID:courseID,
					unitID:unitID,
					exerciseID:exerciseID};
		}
		
	}
	
}