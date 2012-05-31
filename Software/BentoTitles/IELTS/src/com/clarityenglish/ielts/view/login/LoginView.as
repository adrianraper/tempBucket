package com.clarityenglish.ielts.view.login {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import mx.controls.Alert;
	import mx.core.ITextInput;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import org.osflash.signals.Signal;
	
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

		// #341
		[SkinPart]
		public var addUserButton:Button;
		[SkinPart]
		public var newUserButton:Button;
		[SkinPart]
		public var cancelButton:Button;
		[SkinPart]
		public var newInput1:TextInput;
		[SkinPart]
		public var newInput2:TextInput;
		[SkinPart]
		public var newInput3:TextInput;
		[SkinPart]
		public var newPassword:TextInput;

		[SkinPart]
		public var quickStartButton:Button;
		
		[Bindable]
		public var loginID_lbl:String;
		[Bindable]
		public var newData1_lbl:String;
		
		private var _productVersion:String;
		private var _productCode:uint;
		
		// #341
		private var _loginOption:Number;
		private var _selfRegister:Number;

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
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		private var demoAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		private var demoGeneralTrainingLogo:Class;
		
		public function LoginView() {
			super();
		}

		// #341
		[Bindable]
		public function get selfRegister():Number {
			return _selfRegister; 
		}
		public function set selfRegister(value:Number):void {
			if (_selfRegister != value) {
				_selfRegister = value;
			}
		}
		public function get loginOption():Number {
			return _loginOption; 
		}
		public function set loginOption(value:Number):void {
			if (_loginOption != value) {
				_loginOption = value;
				// BUG. Why doesn't this work?
				dispatchEvent(new Event("loginOptionChanged"));
				changeLoginLabels();
			}
		}
		
		public function setProductVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		[Bindable(event="productVersionChanged")]
		public function getProductVersion():String {
			return _productVersion;
		}
		public function setProductCode(value:uint):void {
			if (_productCode != value) {
				_productCode = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		[Bindable(event="productVersionChanged")]
		public function get productCode():uint {
			return _productCode;
		}
		
		[Bindable(event="productVersionChanged")]
		public function get productVersionLogo():Class {
			switch (_productCode) {
				case IELTSApplication.ACADEMIC_MODULE:
					switch (_productVersion) {
						case IELTSApplication.FULL_VERSION:
							return fullVersionAcademicLogo;
						case IELTSApplication.LAST_MINUTE:
							return lastMinuteAcademicLogo;
						case IELTSApplication.TEST_DRIVE:
							return tenHourAcademicLogo;
						default:
							//return demoAcademicLogo;
							return fullVersionAcademicLogo;
					}
					break;
				case IELTSApplication.GENERAL_TRAINING_MODULE:
					switch (_productVersion) {
						case IELTSApplication.FULL_VERSION:
							return fullVersionGeneralTrainingLogo;
						case IELTSApplication.LAST_MINUTE:
							return lastMinuteAcademicLogo;
						case IELTSApplication.TEST_DRIVE:
							return tenHourGeneralTrainingLogo;
						default:
							//return demoGeneralTrainingLogo;
							return fullVersionGeneralTrainingLogo;
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
				case IELTSApplication.ACADEMIC_MODULE:
					switch (_productVersion) {
						case IELTSApplication.FULL_VERSION:
							return "Full Version - Academic module";
						case IELTSApplication.LAST_MINUTE:
							return "Last Minute - Academic module";
						case IELTSApplication.TEST_DRIVE:
							return "Test Drive - Academic module";
						case IELTSApplication.HOME_USER:
							return "Home user - Academic module";
						default:
							return "Demo - Academic module";
					}
					break;
				case IELTSApplication.GENERAL_TRAINING_MODULE:
					switch (_productVersion) {
						case IELTSApplication.FULL_VERSION:
							return "Full Version - General Training module";
						case IELTSApplication.LAST_MINUTE:
							return "Last Minute - General Training module";
						case IELTSApplication.TEST_DRIVE:
							return "Test Drive - General Training module";
						case IELTSApplication.HOME_USER:
							return "Home user - General Training module";
						default:
							return "Demo - General Training module";
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
				case addUserButton:
				case newUserButton:
				case cancelButton:
					instance.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
					break;				
			}
		}

		// #341
		protected override function getCurrentSkinState():String {
			return super.getCurrentSkinState();
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
		/**
		 * Push the login option into the view 
		 * @param uint value
		 * 
		 */
		public function setLoginOption(value:Number):void {
			loginOption = value;
		}
		public function setSelfRegister(value:Number):void {
			selfRegister = value;
		}

		/**
		 * To let you work out what data you need for logging in to this account. 
		 * @param Number loginOption
		 * 
		 */
		[Bindable(event="loginOptionChanged")]
		public function changeLoginLabels():void {
			
			// Override normal text with Last Minute
			if (_productVersion == IELTSApplication.LAST_MINUTE) { 
				loginID_lbl = "Login id:";
				
			} else {
				switch (loginOption) {
					case 1:
						loginID_lbl = "Your name:";
						newData1_lbl = "Your name:";
						break;
					case 2:
						loginID_lbl = "Your id:";
						newData1_lbl = "Your id:";
						break;
					case 128:
						loginID_lbl = "Your email:";
						newData1_lbl = "Your email:";
						break;
					default:
				}
			}
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
		 * The user has clicked one of the login buttons
		 *
		 * @param event
		 */
		protected function onLoginButtonClick(event:MouseEvent):void {
			// Trigger login, registration, add new user or cancel
			switch (event.target) {
				case quickStartButton:
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, "Adrian Raper", "passwording", true));
					break;
				case loginButton:
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, nameInput.text, passwordInput.text, true));
					break;
				case newUserButton:
					setState("register");
					break;
				case addUserButton:
					//addUser.dispatch();
					break;
				default:
					setState("login");
			}
		
		}
		
		// #341
		public function setState(state:String):void {
			currentState = state;
			invalidateSkinState();
		}
		
		public function setCopyProvider(copyProvider:CopyProvider):void {
		}
		
		public function showInvalidLogin(error:BentoError):void {
			// #280 - this is no longer used
		}
		
		public function clearData():void {
			passwordInput.text = "";
		}
	
	}
}
