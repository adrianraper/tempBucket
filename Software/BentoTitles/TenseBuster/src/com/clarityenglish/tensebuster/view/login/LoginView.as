package com.clarityenglish.tensebuster.view.login
{
	import com.adobe.utils.StringUtil;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.view.login.interfaces.LoginComponent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.system.Capabilities;
	import flash.utils.*;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.states.OverrideBase;
	
	import org.osflash.signals.Signal;
	
	import spark.components.BusyIndicator;
	import spark.components.Button;
	import spark.components.FormHeading;
	import spark.components.Group;
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
		
		[SkinPart]
		public var loginInputTitle:Label;
		
		[SkinPart]
		public var loginInstruction:Label;
		
		[SkinPart]
		public var option1Label:Label;
		
		[SkinPart]
		public var option1InstructionLabel:Label;
		
		[SkinPart]
		public var option1Labe2:Label;
		
		[SkinPart]
		public var option2InstructionLabel:Label;
		
		[SkinPart]
		public var CTStartButton:Button;
		
		[SkinPart]
		public var busyIndicator:BusyIndicator;
		
		[SkinPart]
		public var disableGroup:Group;
		
		[Bindable]
		public var loginKey_lbl:String;
		
		[Bindable]
		public var loginName_lbl:String;
		
		[Bindable]
		public var loginID_lbl:String;
		
		[Bindable]
		public var loginEmail_lbl:String;
		
		[Bindable]
		public var loginPassword_lbl:String;
		
		[Bindable]
		public var isPlatformTablet:Boolean;
		
		[Bindable]
		public var isPlatformiPad:Boolean;
		
		[Bindable]
		public var isPlatformAndroid:Boolean;
		
		// #341
		[Bindable]
		public var savedName:String;
		
		// gh#100
		[Bindable]
		public var savedPassword:String;
		
		private var _loginOption:Number;
		private var _selfRegister:Number;
		private var _verified:Boolean;
		// gh#659
		private var _hasIPrange:Boolean;
		private var _IPMatchedProductCodes:Array;
		
		private var _currentState:String;
		
		// gh#41
		private var _noAccount:Boolean;
		
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
		
		// #41
		[Bindable]
		public function get noAccount():Boolean {
			return _noAccount;
		}
		public function set noAccount(value:Boolean):void {
			if (_noAccount != value) {
				_noAccount = value;
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
		
		// gh#39
		public function setProductCode(value:String):void {
			if (_productCode != value) {
				_productCode = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		
		// gh#659
		public function setHasMatchedIPrange(value:Boolean):void {
			_hasIPrange = value;
		}
		
		// gh#659
		public function setIPMatchedProductCodes(value:Array):void {
			_IPMatchedProductCodes = value;
			dispatchEvent(new Event("productCodesChanged"));
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();

			stage.addEventListener(CloseEvent.CLOSE, onClosePopUp);
			
			enableComponent();
			
			if (disableGroup) {
				disableGroup.visible = false;
			}
			
			if (busyIndicator) {
				busyIndicator.visible = false;
			}
		}
		
		protected function enableComponent():void {
			// gh#827
			if (loginButton) {
				loginButton.enabled = true;
			}
			
			if (addUserButton) {
				addUserButton.enabled = true;
				loginNameInput.editable = true;
				loginIDInput.editable = true;
				loginEmailInput.editable = true;
				newPasswordInput.editable = true;		
				addUserButton.enabled = true;
			}
			
			if (cancelButton) {
				cancelButton.enabled = true;
			}
			
			if (CTStartButton) {
				CTStartButton.enabled = true;
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
					if (selfRegister) {
						loginButton.label = copyProvider.getCopyForId("CTLoginButton");
					} else {
						loginButton.label = copyProvider.getCopyForId("loginButton");
					};
					instance.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
					break;
				case addUserButton:
					addUserButton.label = copyProvider.getCopyForId("addUserButton");
					instance.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
					break;
				case cancelButton:
					cancelButton.label = copyProvider.getCopyForId("cancelButton");
					instance.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
					break;
				case loginInputTitle:
					loginInputTitle.text = copyProvider.getCopyForId("loginInputTitle");
					break;
				case loginInstruction:
					loginInstruction.text = copyProvider.getCopyForId("loginDetailLabel");
					break;
				case option1Label:
					option1Label.text = copyProvider.getCopyForId("option1Label");
					break;
				case option1InstructionLabel:
					option1InstructionLabel.text = copyProvider.getCopyForId("option1InstructionLabel");
					break;
				case option1Labe2:
					option1Labe2.text = copyProvider.getCopyForId("option1Labe2");
					break;
				case option2InstructionLabel:
					option2InstructionLabel.text = copyProvider.getCopyForId("option2InstructionLabel");
					break;
				case CTStartButton:
					CTStartButton.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
					CTStartButton.label = copyProvider.getCopyForId("CTStartButton");
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			var platformSize:String;
			if (isPlatformAndroid) {
				if (FlexGlobals.topLevelApplication.stage.stageWidth >= 1280) {
					platformSize = "10Inches";
				} else {
					platformSize = "7Inches";
				}
			} else {
				
				platformSize = "";
			}
			
			if (licenceType == Title.LICENCE_TYPE_NETWORK ||
				licenceType == Title.LICENCE_TYPE_CT) {
				var networkState:String = "ConcurrentTracking";
			} else {
				networkState = "";
			}
			
			if (_hasIPrange && licenceType == Title.LICENCE_TYPE_CT) {
				networkState = "IPConcurrentTracking";
			}
			
			return _currentState + networkState + platformSize;
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
		
		// gh#41
		public function setNoAccount(value:Boolean):void {
			noAccount = value;
		}
		
		public function setPlatformTablet(value:Boolean):void {
			isPlatformTablet = value;
		}
		
		public function setPlatformiPad(value:Boolean):void {
			isPlatformiPad = value;
		}
		
		public function setPlatformAndroid(value:Boolean):void {
			isPlatformAndroid = value;
		}
		
		/**
		 * To let you work out what data you need for logging in to this account. 
		 * @param Number loginOption
		 * 
		 */
		[Bindable(event="loginOptionChanged")]
		public function changeLoginLabels():void {
			// #341 This has to be bitwise comparison, not equality
			if (loginOption & Config.LOGIN_BY_NAME || loginOption & Config.LOGIN_BY_NAME_AND_ID) {
				var replaceObj:Object = {loginDetail:copyProvider.getCopyForId("nameLoginDetail")};
			} else if (loginOption & Config.LOGIN_BY_ID) {
				replaceObj = {loginDetail:copyProvider.getCopyForId("IDLoginDetail")};
			} else if (loginOption & Config.LOGIN_BY_EMAIL) {
				replaceObj = {loginDetail:copyProvider.getCopyForId("emailLoginDetail")};
			} else {
				replaceObj = {loginDetail:copyProvider.getCopyForId("nameLoginDetail")};
			}
			loginKey_lbl = copyProvider.getCopyForId("yourLoginDetail", replaceObj);	
			
			// for self-registration
			loginName_lbl = copyProvider.getCopyForId("yourName");
			loginID_lbl = copyProvider.getCopyForId("yourID");
			loginEmail_lbl = copyProvider.getCopyForId("yourEmail");
			
			// gh#100
			loginPassword_lbl = copyProvider.getCopyForId("passwordLabel");
		}
		
		// #254
		public function onEnter(event:FlexEvent):void {
			if (_currentState == "login") {
				if (StringUtil.trim(loginKeyInput.text) && StringUtil.trim(passwordInput.text)) {
					loginButton.enabled = false;
					if (disableGroup)
						disableGroup.visible = true;
					if (busyIndicator)
						busyIndicator.visible = true;
					var user:User = new User({ name: loginKeyInput.text, studentID: loginKeyInput.text, email: loginKeyInput.text, password: passwordInput.text });
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
				}	
			}
			
			if (_currentState == "register") {
				if (StringUtil.trim((loginNameInput.text) || StringUtil.trim(loginIDInput.text) || StringUtil.trim(loginEmailInput.text)) && StringUtil.trim(newPasswordInput.text)) {
					addUserButton.enabled = false;
					cancelButton.enabled = false;
					loginNameInput.editable = false;
					loginIDInput.editable = false;
					loginEmailInput.editable = false;
					newPasswordInput.editable = false;
					if (disableGroup)
						disableGroup.visible = true;
					if (busyIndicator)
						busyIndicator.visible = true;
					user = new User({name:loginNameInput.text, studentID:loginIDInput.text, email:loginEmailInput.text, password:newPasswordInput.text});
					dispatchEvent(new LoginEvent(LoginEvent.ADD_USER, user, loginOption, verified));
				}	
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
		
		protected function onClosePopUp(event:Event):void {
			enableComponent();
			
			if (busyIndicator) {
				busyIndicator.visible = false;
			}
			
			if (disableGroup) {
				disableGroup.visible = false;
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
					loginButton.enabled = false;
					if (disableGroup)
						disableGroup.visible = true;
					if (busyIndicator)
						busyIndicator.visible = true;
					user = new User({name:loginKeyInput.text, studentID:loginKeyInput.text, email:loginKeyInput.text, password:passwordInput.text});
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
					break;
				case CTStartButton:
					CTStartButton.enabled = false;
					if (disableGroup)
						disableGroup.visible = true;
					if (busyIndicator)
						busyIndicator.visible = true;
					user =  new User();
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
					break;
				case addUserButton:
					addUserButton.enabled = false;
					cancelButton.enabled = false;
					loginNameInput.editable = false;
					loginIDInput.editable = false;
					loginEmailInput.editable = false;
					newPasswordInput.editable = false;
					if (disableGroup)
						disableGroup.visible = true;
					if (busyIndicator)
						busyIndicator.visible = true;
					user = new User({name:loginNameInput.text, studentID:loginIDInput.text, email:loginEmailInput.text, password:newPasswordInput.text});
					dispatchEvent(new LoginEvent(LoginEvent.ADD_USER, user, loginOption, verified));
					break;
				default:
					if (busyIndicator && disableGroup) {
						disableGroup.visible = false;
						busyIndicator.visible = false;
						loginButton.enabled = true;
					}
					setState("login");
			}
			
		}
		
		public function setState(state:String):void {
			switch (state) { 
				case 'register':
					if (busyIndicator) {
						disableGroup.visible = false;
						busyIndicator.visible = false;
					}
					savedName = loginKeyInput.text;
					savedPassword = passwordInput.text;
					break;
			}
			// Can't use currentState as that belongs to the view and is not automatically linked to the skin
			_currentState = state;
			invalidateSkinState();
		}
		
		public function showInvalidLogin(error:BentoError):void {
			// #280 - this is no longer used
		}

		public function clearData():void {
			passwordInput.text = "";
		}
		
		// Temporary - until Alice removes getTestDrive from the LoginMediator and interface
		public function getTestDrive():Signal {
			return new Signal();
		}
	}
}