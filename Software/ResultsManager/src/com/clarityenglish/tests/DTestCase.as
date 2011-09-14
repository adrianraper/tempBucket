package com.clarityenglish.tests {
	import net.digitalprimates.fluint.tests.TestCase;
	
	/**
	 * Extend FlexUnit's TestCase with extra asserts that I might find useful.
	 * 
	 * @author Dave Keen
	 */
	public class DTestCase extends TestCase {
		
		/**
		 * Assert that two arrays are equal.  Optionally define an attribute to compare, otherwise comparisons are done using the
		 * standard == operator.
		 * 
		 * @param	array1
		 * @param	array2
		 * @param	field An optional attribute to compare.  If this does not exist or is not a public attribute this will throw an exception.
		 */
		public function assertArrayEquals(array1:Array, array2:Array, field:String = null):void {
			var result:Boolean = true;
			
			if (array1.length != array2.length) {
				result = false;
			} else {
				for (var n:uint = 0; n < array1.length; n++) {
					if (field) {
						if (array1[n][field] != array2[n][field]) {
							result = false;
							break;
						}
					} else {
						if (array1[n] != array2[n]) {
							result = false;
							break;
						}
					}
				}
			}
			
			if (!result) failWithUserMessage("", "Expected <" + array1 + "> got <" + array2 + ">");
		}
		
		/**
		 * Cause test to fail, format message
		 * 
		 * @param userMessage A string supplied by the caller of the assertion 
		 * @param failMessage A string supplied by assertion test function
		 */
		private function failWithUserMessage(userMessage:String, failMessage:String):void {
			if (userMessage.length > 0)
				failMessage = userMessage + " - " + failMessage;
			
			fail(failMessage);
		}
		
	}
	
}