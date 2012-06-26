package com.clarityenglish.ielts.view.login {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	
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
		public var loginKeyInput:TextInput;

		// #341
		[SkinPart]
		public var addUserButton:Button;
		[SkinPart]
		public var newUserButton:Button;
		[SkinPart]
		public var cancelButton:Button;
		[SkinPart]
		public var loginNameInput:TextInput;
		[SkinPart]
		public var loginEmailInput:TextInput;
		[SkinPart]
		public var loginIDInput:TextInput;
		[SkinPart]
		public var newPasswordInput:TextInput;

		[SkinPart]
		public var quickStartButton:Button;
		
		[Bindable]
		public var loginKey_lbl:String;
		[Bindable]
		public var loginName_lbl:String;
		[Bindable]
		public var loginID_lbl:String;
		[Bindable]
		public var loginEmail_lbl:String;
		
		// #341
		private var _loginOption:Number;
		private var _selfRegister:Number;
		private var _verified:Boolean;
		private var _licenceType:uint;
		
		private var _currentState:String;

		private var _productVersion:String;
		private var _productCode:uint;
		
		// #341
		[Bindable]
		public var savedName:String;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersionAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersion")]
		
		private var fullVersionAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersionGeneralTraining")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersion")]
		private var fullVersionGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHourAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHour")]
		private var tenHourAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHourGeneralTraining")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHour")]
		private var tenHourGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinuteAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinute")]
		private var lastMinuteAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinuteGeneralTraining")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinute")]
		private var lastMinuteGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemoAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		private var demoAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemoGeneralTraing")]
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
		[Bindable]
		public function get verified():Boolean {
			return _verified; 
		}
		public function set verified(value:Boolean):void {
			if (_verified != value) {
				_verified = value;
			}
		}

		[Bindable]
		public function get selfRegisterName():Boolean {
			return ((selfRegister & Config.SELF_REGISTER_NAME) == Config.SELF_REGISTER_NAME); 
		}
		public function set selfRegisterName(value:Boolean):void {
			selfRegister = selfRegister | Config.SELF_REGISTER_NAME;
		}
		[Bindable]
		public function get selfRegisterID():Boolean {
			return ((selfRegister & Config.SELF_REGISTER_ID) == Config.SELF_REGISTER_ID); 
		}
		public function set selfRegisterID(value:Boolean):void {
			selfRegister = selfRegister | Config.SELF_REGISTER_ID;
		}
		[Bindable]
		public function get selfRegisterEmail():Boolean {
			return ((selfRegister & Config.SELF_REGISTER_EMAIL) == Config.SELF_REGISTER_EMAIL); 
		}
		public function set selfRegisterEmail(value:Boolean):void {
			selfRegister = selfRegister | Config.SELF_REGISTER_EMAIL;
		}
		[Bindable]
		public function get selfRegisterPassword():Boolean {
			return ((selfRegister & Config.SELF_REGISTER_PASSWORD) == Config.SELF_REGISTER_PASSWORD); 
		}
		public function set selfRegisterPassword(value:Boolean):void {
			selfRegister = selfRegister | Config.SELF_REGISTER_PASSWORD;
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

		// #341 Need to know if it is a network version.
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
			}
		}
		[Bindable]
		public function get licenceType():uint {
			return _licenceType;
		}
		public function get isNetwork():Boolean {
			return (_licenceType == Title.LICENCE_TYPE_NETWORK);
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
						case IELTSApplication.LAST_MINUTE:
							return "       Last Minute - Academic module";
						case IELTSApplication.TEST_DRIVE:
							return "       Test Drive - Academic module";
						case IELTSApplication.DEMO:
							return "                 Academic module";
						case IELTSApplication.FULL_VERSION:
						default:
							return "Academic module";
					}
					break;
				case IELTSApplication.GENERAL_TRAINING_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return "       Last Minute - General Training module";
						case IELTSApplication.TEST_DRIVE:
							return "       Test Drive - General Training module";
						case IELTSApplication.DEMO:
							return "                 General Training module";
						case IELTSApplication.FULL_VERSION:
						default:
							return "General Training module";
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
				case loginKeyInput:
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
			if (licenceType == Title.LICENCE_TYPE_NETWORK) {
				var networkState:String = "Network";
			} else {
				networkState = "";
			}
				
			return _currentState + networkState;
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
		public function setVerified(value:Number):void {
			verified = (value == 1) ? true : false;
		}
		public function setLicenceType(value:uint):void {
			licenceType = value;
			
			// #341 for network version
			setState("login");
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
				loginKey_lbl = "Login id:";
				
			} else {
				// #341 This has to be bitwise comparison, not equality
				if (loginOption & Config.LOGIN_BY_NAME || loginOption & Config.LOGIN_BY_NAME_AND_ID) {
					loginKey_lbl = "Your name:";
				} else if (loginOption & Config.LOGIN_BY_ID) {
					loginKey_lbl = "Your id:";
				} else if (loginOption & Config.LOGIN_BY_EMAIL) {
					loginKey_lbl = "Your email:";
				}
			}
			
			// #341 for self-registration
			loginName_lbl = "Your name:";
			loginID_lbl = "Your id:";
			loginEmail_lbl = "Your email:";
			
		}
		
		// #254
		public function onEnter(event:FlexEvent):void {
			if (StringUtil.trim(loginKeyInput.text) && StringUtil.trim(passwordInput.text)) {
				var user:User = new User({name:loginKeyInput.text, studentID:loginKeyInput.text, email:loginKeyInput.text, password:passwordInput.text});
				dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
			}
			
			// Go to the password field if press Enter but it is empty
			// TODO. Ideally we would check loginOptions to see if password required
			// #341 Password is hidden if verified = false
			if (verified) {
				if (StringUtil.trim(loginKeyInput.text) && StringUtil.trim(passwordInput.text)=='')
					passwordInput.setFocus();
			} else {
				if (StringUtil.trim(loginKeyInput.text)) {
					user = new User({name:loginKeyInput.text, studentID:loginKeyInput.text, email:loginKeyInput.text, password:null});
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
				}				
			}
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
					var user:User = new User({name:"Adrian Raper", password:"password"});
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
					break;
				case loginButton:
					user = new User({name:loginKeyInput.text, studentID:loginKeyInput.text, email:loginKeyInput.text, password:passwordInput.text});
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
					break;
				case newUserButton:
					setState("register");
					//loginNameInput.text = loginKeyInput.text;
					//newPasswordInput.text = passwordInput.text;
					break;
				case addUserButton:
					//user = new User({name:newNameInput.text, password:newPasswordInput.text});
					user = new User({name:loginNameInput.text, studentID:loginIDInput.text, email:loginEmailInput.text, password:newPasswordInput.text});
					dispatchEvent(new LoginEvent(LoginEvent.ADD_USER, user, loginOption, verified));
					break;
				default:
					setState("login");
			}
		
		}
		
		public function setState(state:String):void {
		
			// Copy fields if appropriate
			switch (state) {
				case 'register':
					savedName = loginKeyInput.text
					break;
			}
			// Can't use currentState as that belongs to the view and is not automatically linked to the skin
			_currentState = state;
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
