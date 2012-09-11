package com.clarityenglish.rotterdam.builder.view.login {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
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
		
		private var _currentState:String;
		
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
			}
		}
		
		// #341 Need to know if it is a network version.
		public function get isNetwork():Boolean {
			return (_licenceType == Title.LICENCE_TYPE_NETWORK);
		}
		
		[Bindable(event="productVersionChanged")]
		public function getProductVersion():String {
			return _productVersion;
		}
		public function setProductVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		
		public function setProductCode(value:uint):void {
			if (_productCode != value) {
				_productCode = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
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
		
		// #254
		public function onEnter(event:FlexEvent):void {
			if (StringUtil.trim(loginKeyInput.text) && StringUtil.trim(passwordInput.text)) {
				var user:User = new User({ name: loginKeyInput.text, studentID: loginKeyInput.text, email: loginKeyInput.text, password: passwordInput.text });
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
					user = new User({ name:loginKeyInput.text, studentID: loginKeyInput.text, email: loginKeyInput.text, password: null});
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
