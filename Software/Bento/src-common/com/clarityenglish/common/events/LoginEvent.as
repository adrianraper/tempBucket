package com.clarityenglish.common.events {
	import com.clarityenglish.common.vo.manageable.User;
	
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class LoginEvent extends Event {
		
		public static const LOGIN:String = "login";
		public static const ADD_USER:String = "add_user";

		// Note that username is really just the key that is being used to identify the user, it might be name or id or email
		//public var username:String;
		//public var studentID:String;
		//public var email:String;
		//public var password:String;
		public var user:User;
		public var loginOption:Number;
		public var verified:Boolean;
		
		public function LoginEvent(type:String, userObject:Object, loginOption:uint, verified:Boolean = true, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			
			//this.name = username;
			//this.password = password;
			// gh#41
			if (userObject)
				this.user = new User(userObject);
			this.loginOption = loginOption;
			this.verified = verified;
		} 
		
		public override function clone():Event { 
			//return new LoginEvent(type, username, password, bubbles, cancelable);
			return new LoginEvent(type, user, loginOption, verified, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("LoginEvent", "type", "user", "loginOption", "verified", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}