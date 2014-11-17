package com.clarityenglish.bento.view.login {
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
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.ComponentDescriptor;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.FormHeading;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.primitives.BitmapImage;
	
	public class LoginView extends BentoView {

		[SkinPart(required="true")]
		public var loginButton:Button;
		
		[SkinPart(required="true")]
		public var passwordInput:TextInput;
		
		[SkinPart(required="true")]
		public var loginKeyInput:TextInput;
		
		[SkinPart(required="true")]
		public var forgotPasswordButton:Button;
		
		[SkinPart(required="true")]
		public var anonymousStartButton:Button;
		
		[Bindable]
		public var loginCaption:String;
		
		[Bindable]
		public var loginKeyCaption:String;
		
		[Bindable]
		public var passwordCaption:String;
		
		[Bindable]
		public var loginButtonCaption:String;
		
		[Bindable]
		public var forgotPasswordCaption:String;
		
		[Bindable]
		public var anonymousCaption:String;
		
		[Bindable]
		public var anonymousStartButtonCaption:String;
		
		[SkinPart]
		public var newUserButton:Button;
		
		[Bindable]
		public var newUserButtonCaption:String;
		
		[Bindable]
		public var demoButtonCaption:String;
		
		[SkinPart]
		public var demoButton:Button;
		
		// Registration
		// #341
		[SkinPart]
		public var addUserButton:Button;
		
		[SkinPart]
		public var cancelButton:Button;
		
		[SkinPart]
		public var selfRegisterName:TextInput;
		
		[SkinPart]
		public var selfRegisterEmail:TextInput;
		
		[SkinPart]
		public var selfRegisterId:TextInput;
		
		[SkinPart]
		public var selfRegisterPassword:TextInput;
		
		[SkinPart]
		public var confirmPassword:TextInput;
		
		[Bindable]
		public var selfRegisterCaption:String;
		
		[Bindable]
		public var selfRegisterNameCaption:String;
		
		[Bindable]
		public var selfRegisterEmailCaption:String;
		
		[Bindable]
		public var selfRegisterIdCaption:String;
		
		[Bindable]
		public var selfRegisterPasswordCaption:String;
		
		[Bindable]
		public var confirmPasswordCaption:String;
		
		[Bindable]
		public var addUserButtonCaption:String;
		
		[Bindable]
		public var cancelButtonCaption:String;
		
		// gh#224
		[SkinPart]
		public var brandingImage1:BitmapImage;
		[SkinPart]
		public var brandingImage2:BitmapImage;
		[SkinPart]
		public var brandingImage3:BitmapImage;
		[SkinPart]
		public var brandingImage4:BitmapImage;
		
		/*
		[Bindable]
		public var isPlatformTablet:Boolean;
		
		[Bindable]
		public var isPlatformiPad:Boolean;
		
		[Bindable]
		public var isPlatformAndroid:Boolean;
		*/
		
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
		private var _noLogin:Boolean;

		// gh#1090 Components of the login screen
		[Bindable]
		public var allowSelfRegister:Boolean = false;
		[Bindable]
		public var allowAnonymous:Boolean = false;
		[Bindable]
		public var allowLogin:Boolean = true;

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
		public function get noAccount():Boolean {
			return _noAccount;
		}
		public function set noAccount(value:Boolean):void {
			if (_noAccount != value) {
				_noAccount = value;
			}			
		}
		public function get noLogin():Boolean {
			return _noLogin;
		}
		public function set noLogin(value:Boolean):void {
			if (_noLogin != value) {
				_noLogin = value;
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

		/*
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
		*/
		
		public function get loginOption():Number {
			return _loginOption; 
		}
		public function set loginOption(value:Number):void {
			if (_loginOption != value) {
				_loginOption = value;
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
		/*
		public function get isNetwork():Boolean {
			return (_licenceType == Title.LICENCE_TYPE_NETWORK);
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
		*/
		
		override protected function onViewCreationComplete():void {
			super.onViewCreationComplete();

			// gh#1090 Use data to set literals and layout
			setLoginLabels();
			setLoginComponents();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
					
				case loginKeyInput:
				case passwordInput:
					instance.addEventListener(FlexEvent.ENTER, onEnter, false, 0, true);
					break;
				
				case forgotPasswordButton:
					instance.addEventListener(FlexEvent.ENTER, onForgotPassword, false, 0, true);
					break;
				
				case loginButton:
				case addUserButton:
				case newUserButton:
				case cancelButton:
				case anonymousStartButton:
				case demoButton:
					instance.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
					break;
				
				case brandingImage1:
				case brandingImage2:
				case brandingImage3:
				case brandingImage4:
					if (branding && branding.image)
						addBrandingImageToInstance(instance, branding.image);
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
		/*
		public function setBranding(branding:XML):void {
			if (branding)
				this.branding = branding;
		}
		*/
		/**
		 * Add the institution name from the licence to the screen 
		 * @param String name
		 * 
		 */
		/*
		public function setLicencee(name:String):void {
			// gh#224
			licenceeName = name;
		}
		*/
		/**
		 * Push the login option into the view 
		 * @param uint value
		 * 
		 */
		/*
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
		*/
		
		// gh#41
		public function setNoAccount(value:Boolean):void {
			noAccount = value;
		}
		
		/*
		public function setPlatformTablet(value:Boolean):void {
			isPlatformTablet = value;
		}
		
		public function setPlatformiPad(value:Boolean):void {
			isPlatformiPad = value;
		}
		
		public function setPlatformAndroid(value:Boolean):void {
			isPlatformAndroid = value;
		}
		*/
		/**
		 * To let you work out what data you need for logging in to this account. 
		 * It isn't really login option change, more that it is set in the first place.
		 * @param Number loginOption
		 * 
		 */
		public function setLoginLabels():void {
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
			loginKeyCaption = copyProvider.getCopyForId("yourLoginDetail", replaceObj);	
			
			// gh#100
			passwordCaption = copyProvider.getCopyForId("passwordLabel");
			
			// gh#487
			forgotPasswordCaption = copyProvider.getCopyForId("forgotPasswordLabel");
			
			// gh#1090
			loginCaption = copyProvider.getCopyForId("loginCaption");
			loginButtonCaption = copyProvider.getCopyForId("loginButton");
			anonymousCaption = copyProvider.getCopyForId("anonymousCaption");
			anonymousStartButtonCaption = copyProvider.getCopyForId("anonymousButtonCaption");		

			if (selfRegister & Config.SELF_REGISTER_NAME)
				selfRegisterNameCaption = copyProvider.getCopyForId("nameLoginDetail");
			if (selfRegister & Config.SELF_REGISTER_ID)
				selfRegisterIdCaption = copyProvider.getCopyForId("IDLoginDetail");
			if (selfRegister & Config.SELF_REGISTER_EMAIL)
				selfRegisterEmailCaption = copyProvider.getCopyForId("emailLoginDetail");
			if (selfRegister & Config.SELF_REGISTER_PASSWORD) {
				selfRegisterPasswordCaption = copyProvider.getCopyForId("passwordLabel");
				confirmPasswordCaption = copyProvider.getCopyForId("confirmPasswordCaption");
			}
			if (selfRegister > 0) {
				newUserButtonCaption = copyProvider.getCopyForId("newUserButtonCaption");		
				addUserButtonCaption = copyProvider.getCopyForId("addUserButtonCaption");
				cancelButtonCaption = copyProvider.getCopyForId("cancelButtonCaption");
				selfRegisterCaption = copyProvider.getCopyForId("selfRegisterCaption");
			}
			demoButtonCaption = copyProvider.getCopyForId("demoButtonCaption");

		}
		
		/**
		 * Which elements of the login will you show for this licence/configuration?
		 * 
		 */
		public function setLoginComponents():void {
			
			// Do we know the account?
			if (noAccount) {
				allowSelfRegister = false;
				allowAnonymous = false;
				allowLogin = true;
			} else {
			
				// Is self-registration allowed?
				// Note that all AA accounts should automatically have the selfRegister settings forced on them (name, email, password) + verified
				// In the meantime I can do a double check.
				// Or you could allow name/id/password to be account selectable?
				if (licenceType == Title.LICENCE_TYPE_AA || licenceType == Title.LICENCE_TYPE_CT) {
					selfRegister = Config.SELF_REGISTER_EMAIL + Config.SELF_REGISTER_NAME + Config.SELF_REGISTER_PASSWORD;
					verified = true;
				}
				allowSelfRegister = (selfRegister > 0) ? true : false;
				
				// Is login allowed
				allowLogin = (noLogin) ? false : true;
				
				// Is anonymous access allowed?
				allowAnonymous = (licenceType == Title.LICENCE_TYPE_AA || licenceType == Title.LICENCE_TYPE_CT) ? true : false;
			}
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
				case loginButton:
					config.signInAs = Title.SIGNIN_TRACKING;
					user = new User({name:loginKeyInput.text, studentID:loginKeyInput.text, email:loginKeyInput.text, password:passwordInput.text});
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
					break;
				
				case anonymousStartButton:
					event.target.enabled = false;
					user =  new User();
					// gh#1090
					config.signInAs = Title.SIGNIN_ANONYMOUS;
					dispatchEvent(new LoginEvent(LoginEvent.LOGIN, user, loginOption, verified));
					break;

				case newUserButton:
					setState("register");
					// Try to save anything they type before clicking to register
					/*
					if (loginOption & Config.LOGIN_BY_NAME || loginOption & Config.LOGIN_BY_NAME_AND_ID) {
						selfRegisterName.text = loginKeyInput.text;
					} else if (loginOption & Config.LOGIN_BY_ID) {
						selfRegisterId.text = loginKeyInput.text;
					} else if (loginOption & Config.LOGIN_BY_EMAIL) {
						selfRegisterEmail.text = loginKeyInput.text;
					}
					selfRegisterPassword.text = passwordInput.text;
					*/
					break;
				
				case addUserButton:
					config.signInAs = Title.SIGNIN_TRACKING;
					var user:User = new User({name:selfRegisterName.text, studentID:selfRegisterId.text, email:selfRegisterEmail.text, password:selfRegisterPassword.text});
					dispatchEvent(new LoginEvent(LoginEvent.ADD_USER, user, loginOption, verified));
					break;
				
				case demoButton:
					//config.signInAs = Title.SIGNIN_ANONYMOUS;
					//dispatchEvent(new LoginEvent(LoginEvent.ADD_USER, user, loginOption, verified));
					break;
				
				default:
					setState("normal");
			}
			
		}
		
		/**
		 * The user clicked the forgot password button
		 * 
		 */
		public function onForgotPassword(event:MouseEvent):void {
			var substTags:Object = { productCode: config.productCode };
			if (config.rootID)
				substTags.rootID = config.rootID; 
			substTags.loginOption = (isNaN(loginOption)) ? '' : loginOption;
			var urlReq:URLRequest = new URLRequest(getCopyProvider().getCopyForId("forgotPasswordLink", substTags ));
			navigateToURL(urlReq, "_new");
		}
		
		public function setState(state:String):void {
			// Can't use currentState as that belongs to the view and is not automatically linked to the skin
			_currentState = state;
			invalidateSkinState();
		}
		protected override function getCurrentSkinState():String {
			return _currentState;
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