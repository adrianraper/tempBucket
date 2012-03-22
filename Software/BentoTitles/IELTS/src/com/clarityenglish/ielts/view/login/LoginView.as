package com.clarityenglish.ielts.view.login {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.vo.config.BentoError;
	
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
	import spark.components.Label;
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
		
		private var _productVersion:String;
		private var _productCode:uint;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersionAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersion")]
		private var fullVersionAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersionGeneralTraining")]
		private var fullVersionGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHourAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHour")]
		private var tenHourAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHourGeneralTraining")]
		private var tenHourGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinuteAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinute")]
		private var lastMinuteAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinuteGeneralTraining")]
		private var lastMinuteGeneralTrainingLogo:Class;

		
		public function LoginView() {
			super();
		}
		
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		public function set productCode(value:uint):void {
			if (_productCode != value) {
				_productCode = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		
		[Bindable(event="productVersionChanged")]
		public function get productVersionLogo():Class {
			switch (_productCode) {
				case 52:
					switch (_productVersion) {
						case "fullVersion":
							return fullVersionAcademicLogo;
						case "lastMinute":
							return lastMinuteAcademicLogo;
						case "tenHour":
							return tenHourAcademicLogo;
					}
					break;
				case 53:
					switch (_productVersion) {
						case "fullVersion":
							return fullVersionGeneralTrainingLogo;
						case "lastMinute":
							return lastMinuteAcademicLogo;
						case "tenHour":
							return tenHourGeneralTrainingLogo;
					}
					break;
				default:
					// No product code set yet so don't set the logo
					return null;
			}
			return null;
		}
		
		[Bindable(event="productVersionChanged")]
		public function get productVersionText():String {
			switch (_productCode) {
				case 52:
					switch (_productVersion) {
						case "fullVersion":
							return "Full version - Academic module";
						case "lastMinute":
							return "Last minute - Academic module";
						case "tenHour":
							return "Test drive - Academic module";
					}
					break;
				case 53:
					switch (_productVersion) {
						case "fullVersion":
							return "Full version - General Training module";
						case "lastMinute":
							return "Last minute - General Training module";
						case "tenHour":
							return "Test drive - General Training module";
					}
					break;
				default:
					// No product code set yet so don't set the text
					return null;
			}
			return null;
		}

		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case nameInput:
				case passwordInput:
					instance.addEventListener(FlexEvent.ENTER, onEnter, false, 0, true);
					break;
				case loginButton:
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
			
			// Go to the password field if press Enter but it is empty
			// TODO. Ideally we would check loginOptions to see if password required
			if (StringUtil.trim(nameInput.text) && StringUtil.trim(passwordInput.text)=='')
				passwordInput.setFocus();
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
		
		public function showInvalidLogin(error:BentoError):void {
			var msgTitle:String = "Login problem";
			switch (error.errorNumber) {
				case BentoError.ERROR_DATABASE_READING:
				case BentoError.ERROR_DATABASE_WRITING:
					var msg:String = "Sorry, there is a problem reading the database.";
					break;
				
				case BentoError.ERROR_LOGIN_WRONG_DETAILS:
					msg = "Sorry, that login or password are wrong. Please try again.";
					break;
				
				case BentoError.ERROR_CONTENT_MENU:
					msg = "Sorry, there is a problem reading the content index.";
					break;
				
				default:
					msg = "Sorry, something unexpected has happened.";
			}
			Alert.show(msg + ' ' + error.errorNumber + ': ' + error.errorContext, msgTitle);
		}
		
		public function clearData():void {
			passwordInput.text = "";
		}
	
	}
}
