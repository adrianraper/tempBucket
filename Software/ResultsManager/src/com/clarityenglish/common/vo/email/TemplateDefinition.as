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
		
		// gh#1487 Data to go in the template that is the same for this whole batch
		public var data:Object;
	}
	
}