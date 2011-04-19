package com.clarityenglish.resultsmanager.view.licence.events {
	import com.clarityenglish.common.vo.content.Title;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class LicenceEvent extends Event {
		
		public static const ALLOCATE:String = "allocate";
		public static const UNALLOCATE:String = "unallocate";
		
		public var users:Array;
		public var title:Title;
		
		public function LicenceEvent(type:String, users:Array, title:Title = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.users = users;
			this.title = title;
		}
		
		public override function clone():Event { 
			return new LicenceEvent(type, users, title, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("LicenceEvent", "type", "users", "title", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}