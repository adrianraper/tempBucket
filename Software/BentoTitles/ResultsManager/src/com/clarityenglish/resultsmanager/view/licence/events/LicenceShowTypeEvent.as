package com.clarityenglish.resultsmanager.view.licence.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class LicenceShowTypeEvent extends Event {
		
		public static const SHOW_ALL:String = "show_all";
		public static const SHOW_SELECTED:String = "show_selected";
		public static const SHOW_UNASSIGNED:String = "show_unassigned";
		
		public function LicenceShowTypeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new LicenceShowTypeEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("LicenceShowTypeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}