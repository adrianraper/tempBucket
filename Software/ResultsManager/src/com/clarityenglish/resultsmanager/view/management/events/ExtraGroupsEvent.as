package com.clarityenglish.resultsmanager.view.management.events {
	import com.clarityenglish.common.vo.manageable.User;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ExtraGroupsEvent extends Event {
		
		public static const SET_EXTRA_GROUPS:String = "set_extra_groups";
		
		public var user:User;
		public var groups:Array;
		
		public function ExtraGroupsEvent(type:String, user:User, groups:Array, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.user = user;
			this.groups = groups;
		} 
		
		public override function clone():Event { 
			return new ExtraGroupsEvent(type, user, groups, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ExtraGroupsEvent", "type", "user", "groups", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}