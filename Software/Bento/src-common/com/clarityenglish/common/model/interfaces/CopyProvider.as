package com.clarityenglish.common.model.interfaces {
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public interface CopyProvider {
		
		function getCopyForId(id:String, replaceObj:Object = null):String;
		function getLanguageCode():String;
		function getDefaultLanguageCode():String;		
	}
	
}