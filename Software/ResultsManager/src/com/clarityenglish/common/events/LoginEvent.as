package com.clarityenglish.common.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class LoginEvent extends Event {
		
		public static const LOGIN:String = "login";
		
		public var username:String;
		public var password:String;
		
		public function LoginEvent(type:String, username:String, password:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.username = username;
			this.password = password;
		} 
		
		public override function clone():Event { 
			return new LoginEvent(type, username, password, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("LoginEvent", "type", "username", "password", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}