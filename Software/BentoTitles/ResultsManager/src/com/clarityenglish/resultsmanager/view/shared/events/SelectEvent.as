package com.clarityenglish.resultsmanager.view.shared.events {
	import com.clarityenglish.resultsmanager.vo.manageable.Group;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class SelectEvent extends Event {
		
		public static const EXPIRED_USERS:String = "expired_users";
		public static const ALL:String = "all";
		public static const NONE:String = "none";
		
		public var manageables:Array;
		
		public function SelectEvent(type:String, manageables:Array = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.manageables = manageables;
		} 
		
		public override function clone():Event { 
			return new SelectEvent(type, manageables, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("SelectEvent", "type", "manageables", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}