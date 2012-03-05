package com.clarityenglish.ielts.view.login {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import mx.controls.Alert;
	import mx.core.ITextInput;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import spark.components.Button;
	import spark.components.FormHeading;
	import spark.components.TextInput;
	
	
	public class LoginView extends BentoView implements LoginComponent {
		
		[SkinPart(required="true")]
		public var loginButton:Button;
		
		[SkinPart]
		public var loginHeading:FormHeading;
		
		[SkinPart(required="true")]
		public var passwordInput:TextInput;
		
		[SkinPart(required="true")]
		public var nameInput:TextInput;
		
		[SkinPart]
		public var quickStartButton:Button;
		
		public function LoginView() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case nameInput:
				case passwordInput:
					instance.addEventListener(FlexEvent.ENTER, onEnter, false, 0, true);
					break;
				case quickStartButton:
					instance.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
					break;				
			}
		}
		
		/**
		 * Add the institution name from the licence to the screen 
		 * @param String name
		 * 
		 */
		public function setLicencee(name:String):void {
			//loginHeading.label = "licenced to: " + name;
			if (loginHeading)
				loginHeading.label = name;
		}
		
		// #254
		public function onEnter(event:FlexEvent):void {
			if (StringUtil.trim(nameInput.text) && StringUtil.trim(passwordInput.text))
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN, nameInput.text, passwordInput.text, true));
		}
		
		/**
		 * The user has clicked the login button
		 *
		 * @param event
		 */
		protected function onLoginButtonClick(event:MouseEvent):void {
			// Trigger the login command
			if ((event.target)==quickStartButton) {
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN, "Adrian Raper", "passwording", true));				
			} else {
				// RM process does it like this - and all the code is copied from RM to Bento.com.clarityenglish.common
				// Dispatch a LoginEvent here
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN, nameInput.text, passwordInput.text, true));
			}
			// The loginMediator has told the loginView to listen for this event - (loginView.addEventListener(LoginEvent.LOGIN, onLogin);
			// which the mediator handles by sending a Notification.LOGIN
		
			// The applicationFacade has registered Notification.LOGIN to the LoginCommand
			// This is picked up by LoginCommand, which tells LoginProxy to call the backside through RemoteDelegate
		
			// LoginProxy picks up the result with onDelegateResult
			// This sends a notification for success or failure
		
			// The loginMediator is registered to get failure and passes the error to the loginView for display
		
			// The applicationMediator is registered to get success notification and changes the application state
			// The applicationFacade also links LoggedInCommand to the success notification
			// Should the LoggedInCommand be in common? I would think so.
		
			// The loggedInCommand gets all the data from the notification (it can trigger other notifications if necessary)
			// It also loads registers all the proxies with the facade. This triggers all sorts of action...
		
		}
		
		public function setCopyProvider(copyProvider:CopyProvider):void {
		
		}
		
		public function showInvalidLogin():void {
			Alert.show("Sorry, the login ID or password is wrong. Please try again.", "Login problem");
		}
		
		public function clearData():void {
			passwordInput.text = "";
		}
	
	}
}
