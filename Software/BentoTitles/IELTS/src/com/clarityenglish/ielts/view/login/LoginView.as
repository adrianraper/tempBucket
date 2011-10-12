package com.clarityenglish.ielts.view.login {
	import com.clarityenglish.bento.view.base.BentoView;
	// AR No longer sharing code with RM - copy it to this project
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.events.LoginEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.controls.Alert;
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TextInput;

	
	public class LoginView extends BentoView implements LoginComponent {
		
		[SkinPart(required="true")]
		public var loginButton:Button;
		
		[SkinPart]
		public var passwordLabel:Label;
		[SkinPart]
		public var nameLabel:Label;
		[SkinPart]
		public var passwordInput:TextInput;
		[SkinPart]
		public var nameInput:TextInput;
		
		public function LoginView() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName,instance);
			
			switch (instance) {
				case loginButton:
					loginButton.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
					break;

			}
		}

		/**
		 * The user has clicked the login button
		 * 
		 * @param event
		 */
		protected function onLoginButtonClick(event:MouseEvent):void {
			// Trigger the login command
			// RM process does it like this - and all the code is copied from RM to Bento.com.clarityenglish.common
			// Dispatch a LoginEvent here
			dispatchEvent(new LoginEvent(LoginEvent.LOGIN, nameInput.text, passwordInput.text, true));
			
			// The loginMediator has told the loginView to listen for this event - (loginView.addEventListener(LoginEvent.LOGIN, onLogin);
			// which the mediator handles by sending a Notification.LOGIN
			
			// The applicationFacade has registered Notification.LOGIN to the LoginCommand
			// This is picked up by LoginCommand, which tells LoginProxy to call the backside through RemoteDelegate
			
			// LoginProxy picks up the result with onDelegateResult
			// This sends a notification for success or failure
			
			// The loginMediator is registered to get failure and passes the error to the loginView for display
			
			// The applicationMediator is registered to get success notification and changes the application state
			// The applicationFacade also links LoggedInCommand to the success notification
			
			// The loggedInCommand gets all the data from the notification (it can trigger other notifications if necessary)
			// It also loads registers all the proxies with the facade. This triggers all sorts of action...
			
		}
		
		public function setCopyProvider(copyProvider:CopyProvider):void {
			
		}

		public function showInvalidLogin():void {
			Alert("Sorry, that name or password are wrong.");
		}

		public function clearData():void {
			passwordInput.text = "";
		}

	}
}