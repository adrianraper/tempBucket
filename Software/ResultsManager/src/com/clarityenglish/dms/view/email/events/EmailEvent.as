package com.clarityenglish.dms.view.email.events {
	import com.clarityenglish.common.vo.email.TemplateDefinition;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EmailEvent extends Event {
		
		public static const RELOAD_EMAIL_TEMPLATES:String = "reload_email_templates";
		public static const CLEAR_TO_LIST:String = "clear_to_list";
		public static const PREVIEW_EMAIL:String = "preview_email";
		
		public var templateDefinition:TemplateDefinition;
		
		public function EmailEvent(type:String, templateDefinition:TemplateDefinition = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.templateDefinition = templateDefinition;
		} 
		
		public override function clone():Event { 
			return new EmailEvent(type, templateDefinition, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("EmailEvent", "type", "templateDefinition", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}