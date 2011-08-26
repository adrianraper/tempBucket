package com.clarityenglish.resultsmanager.model.utils {
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ExcelImportError extends Error {
		
		public static const NO_USERNAME_HEADER:String = "no_username_header";
		
		public function ExcelImportError(message:String, id:int = 0) {
			super(message, id);
		}
		
	}
	
}