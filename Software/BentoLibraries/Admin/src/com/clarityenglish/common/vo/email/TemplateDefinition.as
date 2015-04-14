package com.clarityenglish.common.vo.email {
	
	/**
	 * ...
	 * @author ...
	 */
	[RemoteClass(alias = "com.clarityenglish.common.vo.email.TemplateDefinition")]
	[Bindable]
	public class TemplateDefinition {
		
		public var title:String;
		
		public var filename:String;
		
		public var description:String;
		
		// Added to PHP by Adrian
		public var templateID:String;
		public var name:String;
	}
	
}