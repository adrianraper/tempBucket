package com.clarityenglish.common.events {
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
		public static const SEND_EMAIL:String = "send_email";
		
		public var templateDefinition:TemplateDefinition;
		public var manageables:Array;
		
		public function EmailEvent(type:String, templateDefinition:TemplateDefinition = null, manageables:Array = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.templateDefinition = templateDefinition;
			this.manageables = manageables;
		} 
		
		public override function clone():Event { 
			return new EmailEvent(type, templateDefinition, manageables, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("EmailEvent", "type", "templateDefinition", "manageables", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}