package com.clarityenglish.rotterdam.view.login {
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
	
	import mx.core.ComponentDescriptor;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.FormHeading;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.primitives.BitmapImage;
	
	public class LoginView extends BentoView implements LoginComponent {
		
		[SkinPart(required="true")]
		public var loginButton:Button;
		
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
		
		// gh#224
		[SkinPart]
		public var brandingImage1:BitmapImage;
		[SkinPart]
		public var brandingImage2:BitmapImage;
		[SkinPart]
		public var brandingImage3:BitmapImage;
		[SkinPart]
		public var brandingImage4:BitmapImage;
		
		[SkinPart]
		public var versionLabel:Label;
		
		[SkinPart]
		public var copyrightLabel:Label;
		
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
		
		// gh#487
		[Bindable]
		public var forgotPassword_lbl:String;
		
		[Bindable]
		public var isPlatformTablet:Boolean;
		
		[Bindable]
		public var isPlatformiPad:Boolean;
		
		[Bindable]
		public var isPlatformAndroid:Boolean;
		
		[Bindable]
		public var noLogin:Boolean;
		
		// #341
		private var _loginOption:Number;
		private var _selfRegister:Number;
		private var _verified:Boolean;
		// gh#659
		private var _hasIPrange:Boolean;
		private var _IPMatchedProductCodes:Array;
		
		private var _currentState:String;
		
		// gh#224
		private var _licenceeName:String;
		private var _branding:XML;
		public static var brandingImageIndex:uint = 1;
		
		// gh#41
		private var _noAccount:Boolean;
		
		public function LoginView() {
			super();
		}
		
		// gh#487
		public function getCopyProvider():CopyProvider {
			return copyProvider;
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
		
		// gh#224
		public function set licenceeName(value:String):void {
			if (_licenceeName != value)
				_licenceeName = value;
		}
		public function get licenceeName():String {
			return _licenceeName;
		}
		// gh#224
		// <login src='AbbeyLogo.png' horizontal-align='center' vertical-align='top'>
		public function set branding(value:XML):void {
			// initialise
			brandingImageIndex = 1;
			if (_branding != value) {
				_branding = value;
			}
		}
		public function get branding():XML {
			return _branding;
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
		
		public function setNoLogin(value:Boolean):void {
			noLogin = value;
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
				
				case brandingImage1:
				case brandingImage2:
				case brandingImage3:
				case brandingImage4:
					if (branding && branding.image)
						addBrandingImageToInstance(instance, branding.image);
					break;
				case versionLabel:
					versionLabel.text = "v" + FlexGlobals.topLevelApplication.versionNumber + "   " + copyProvider.getCopyForId("versionLabel");
					break;
				case copyrightLabel:
					copyrightLabel.text = copyProvider.getCopyForId("footerLabel");
					break;
				case versionLabel:
					versionLabel.text = copyProvider.getCopyForId("versionLabel");
					break;
			}
		}
		
		/**
		 * This takes the xml describing the placement of the image and translates
		 * it into image properties.
		 * eg: <image horizontalAlign="left|center|right" verticalAlign="top|center|bottom" padding="20" />
		 */
		private function addBrandingImageToInstance(instance:Object, images:XMLList):void {
			// gh#224
			if (images) {
				var numImages:uint = images.length();
				if (numImages >= brandingImageIndex) {
					var image:XML = images[brandingImageIndex-1];
					instance.visible = instance.includeInLayout = true;
					
					instance.source = config.paths.brandingMedia + image.@src; 
					var paddingLeft:uint = 0;
					var paddingTop:uint = 0;
					var paddingRight:uint = 0;
					var paddingBottom:uint = 0;
					if (image.hasOwnProperty('@padding'))
						paddingLeft = paddingTop = paddingRight = paddingBottom = Number(image.@padding);
					if (image.hasOwnProperty('@paddingLeft'))
						paddingLeft = Number(image.@paddingLeft);
					if (image.hasOwnProperty('@paddingTop'))
						paddingTop = Number(image.@paddingTop);
					if (image.hasOwnProperty('@paddingRight'))
						paddingRight = Number(image.@paddingRight);
					if (image.hasOwnProperty('@paddingBottom'))
						paddingBottom = Number(image.@paddingBottom);
					
					if (image.hasOwnProperty('@horizontalAlign')) {
						switch (String(image.@horizontalAlign)) {
							case 'center':
							case 'centre':
								instance.horizontalCenter = 0;
								break;
							case 'left':
								instance.left = paddingLeft;
								break;
							case 'right':
								instance.right = paddingRight;
								break;
						}
					}
					if (image.hasOwnProperty('@verticalAlign')) {
						switch (String(image.@verticalAlign)) {
							case 'center':
							case 'centre':
								instance.verticalCenter = 0;
								break;
							case 'top':
								instance.top = paddingTop + 40;
								break;
							case 'bottom':
								instance.bottom = paddingBottom + 40;
								break;
						}
					}
					brandingImageIndex++;
				}
			}
		}
		/**
		 * Add branding. 
		 * gh#224
		 */
		public function setBranding(branding:XML):void {
			if (branding)
				this.branding = branding;
		}
		/**
		 * Add the institution name from the licence to the screen 
		 * @param String name
		 * 
		 */
		public function setLicencee(name:String):void {
			// gh#224
			licenceeName = name;
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

			// gh#100
			loginPassword_lbl = copyProvider.getCopyForId("passwordLabel");
			
			// gh#487
			forgotPassword_lbl = copyProvider.getCopyForId("forgotPasswordLabel");
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
					//trace("email: "+loginKeyInput.text);
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
