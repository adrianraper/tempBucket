package com.clarityenglish.ielts.view.account {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	import mx.controls.Alert;
	import mx.controls.DateField;
	import mx.controls.SWFLoader;
	import mx.events.CalendarLayoutChangeEvent;
	
	import org.davekeen.util.DateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.NumericStepper;
	import spark.components.TextInput;
	import spark.formatters.DateTimeFormatter;
	
	public class AccountView extends BentoView {
				
		[SkinPart(required="true")]
		public var currentPassword:TextInput;
		
		[SkinPart(required="true")]
		public var newPassword:TextInput;
		
		[SkinPart(required="true")]
		public var confirmPassword:TextInput;
		
		[SkinPart]
		public var countdownLabel:Label;
		
		[SkinPart]
		public var examDateField:DateField;
		
		[SkinPart(required="true")]
		public var examHours:NumericStepper;
		[SkinPart(required="true")]
		public var examMinutes:NumericStepper;
		
		[SkinPart(required="true")]
		public var saveChangesButton:Button;

		[SkinPart]
		public var IELTSApp1:SWFLoader;
		
		[SkinPart]
		public var countdownDisplay:CountdownDisplay;

		public var updateUser:Signal = new Signal(Object);
		
		[Bindable]
		public var userDetails:User;
		
		[Bindable]
		public var startDate:String;
		[Bindable]
		public var expiryDate:String;
		
		[Bindable]
		public var isDirty:Boolean;

		// #333
		private var _remoteDomain:String;
		private var _productVersion:String;
		private var _productCode:uint;
		private var _licenceType:uint;
		
		public function AccountView() {
			super();
		}

		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder;
		}
		[Bindable]
		public function get productVersion():String {
			return _productVersion;
		}
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
			}
		}
		[Bindable]
		public function get productCode():uint {
			return _productCode;
		}
		public function set productCode(value:uint):void {
			if (_productCode != value) {
				_productCode = value;
			}
		}
		[Bindable]
		public function get licenceType():uint {
			return _licenceType;
		}
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case saveChangesButton:
					instance.addEventListener(MouseEvent.CLICK, onUpdateButtonClick);
					break;
				
				case countdownLabel:
					// We will only tell the user about the countdown if they have confirmed their exam date
					if (userDetails.examDate) {
						var daysLeft:Number = DateUtil.dateDiff(new Date(), userDetails.examDate, "d");
						if (daysLeft > 0) {
							instance.text = "This is the remaining time until your test."
						} else if (daysLeft == 0) {
							instance.text = "Your test is today, good luck!";
						} else {
							//countdownDisplay.enabled = false;
							instance.text = "Hope your test went well...";
						}
						
					} else {
						instance.text = "Please set your test date below:"
					}
					break;
				
				case examDateField:
					instance.addEventListener(CalendarLayoutChangeEvent.CHANGE, onExamDateChange);
					break;
				
				case newPassword:
					instance.addEventListener(Event.CHANGE, onPasswordChange);
					break;
				
				case examHours:
				case examMinutes:
					instance.addEventListener(Event.CHANGE, onExamTimeChange);
					break;
				
				case IELTSApp1:
					var context:LoaderContext = new LoaderContext();
					
					/* Specify the current application's security domain. */
					//context.securityDomain = SecurityDomain.currentDomain;
					
					/* Specify a new ApplicationDomain, which loads the sub-app into a peer ApplicationDomain. */
					context.applicationDomain = new ApplicationDomain();
					
					// #333 At present the widget doesn't allow communication with the stage. Not sure why
					// but I had got round it by copying /Widget to each domain. But now that I am 
					// preferring to use config.xml to have only CE.com/Software I need to force the domain here.
					// Which is in config.remoteDomain, and now injected into the interface
					instance.loaderContext = context;
					instance.source = config.remoteDomain + "Software/Widget/IELTS/bin/BandScoreCalculator-200.swf?literals=/Software/Widget/IELTS/bin&widgetdatawidth=200&widgetdataheight=300&widgetdatalanguage=EN&widgetdatabclogo=true&cache=" + new Date().getTime();
					if (userDetails.country) {
						// The final names of countries MUST match the literals.xml list.
						switch (userDetails.country) {
							case "Hong Kong":
							case "Hong-Kong":
							case "HK":
								var myCountry:String = "Hong-Kong";
								break;
							default:
								myCountry = userDetails.country;
						}
					} else {
						myCountry = "global";
					}
					instance.source += "&widgetdatacountry=" + myCountry;
					break
			}
		}
		
		protected override function getCurrentSkinState():String {
			switch (productVersion) {
				case IELTSApplication.DEMO:
					return "demo";
					break;
				case IELTSApplication.TEST_DRIVE:
					return "testDrive";
					break;
				case IELTSApplication.FULL_VERSION:
					var currentState:String = "fullVersion";
					if (licenceType == Title.LICENCE_TYPE_AA)
						currentState += "_anonymous";
					return currentState;
					break;
				case IELTSApplication.LAST_MINUTE:
					return "lastMinute";
					break;
				case IELTSApplication.HOME_USER:
					return "homeUser";
					break;
				default:
					return super.getCurrentSkinState();
			}
		}
		
		// TODO. Unload the countdownDisplay.swc when you don't need it anymore.
		
		/** 
		 * The user simply changed the password field.
		 * TODO. Check whether it is empty, in which case no longer isDirty 
		 */
		protected function onPasswordChange(eventObj:Event):void {
			isDirty = true;
		}
		/**
		 * The user changed the exam date.  
		 * @param event
		 * 
		 */
		protected function onExamDateChange(eventObj:CalendarLayoutChangeEvent):void {
			updateExamDate();
		}
		/**
		 * The user changed the exam hours or minutes.  
		 * @param event
		 * 
		 */
		protected function onExamTimeChange(eventObj:Event):void {
			updateExamDate();
		}
		protected function updateExamDate():void {
			// Make sure selectedDate is not null.
			// Quite often it is, though you can clearly see a date on the screen...
			// So instead build the date from userDetails...
			if (examDateField.selectedDate) {
				var baseDateTime:Number = examDateField.selectedDate.getTime();
				//trace("selectedDate =" + DateUtil.formatDate(examDateField.selectedDate, "yyyy-MM-dd hh:mm:ss"));
			} else if (userDetails.examDate) {
				var baseDate:Date = new Date(userDetails.examDate.getTime());
				baseDate.hours = 0;
				baseDate.minutes = 0;
				baseDate.seconds = 0;
				baseDateTime = baseDate.getTime(); 
				//trace("selectedDate null, but baseDate=" + DateUtil.formatDate(baseDate, "yyyy-MM-dd hh:mm:ss"));
			}
			if (baseDateTime) {
				// TODO. You should be able to just do setHours on the date. But it isn't working.
				// So convert to milliseconds, adding some hours/minutes then converting back.
				//userDetails.examDate.setHours(examHours.value as Number, examMinutes.value as Number);
				var examDateTime:Number = baseDateTime + (examHours.value as Number)*60*60*1000 + (examMinutes.value as Number)*60*1000;
				userDetails.examDate = new Date(examDateTime);
				trace("exam date changed to " + DateUtil.formatDate(userDetails.examDate, "yyyy-MM-dd hh:mm"));
				
				isDirty = true;
			}
			
		}
		
		/**
		 * The user has clicked the update button
		 *
		 * @param event
		 */
		protected function onUpdateButtonClick(event:MouseEvent):void {
			// Any validation to do here?
			if (newPassword && confirmPassword && (newPassword.text != confirmPassword.text)) {
				showUpdateError("The two new passwords you typed must be the same.");
			} else {
				// Trigger the update command. Use an Event or a Signal?
				// Do I really need to pass anything at all since the mediator can get it all anyway?
				// Or I could use a form and pass that?
				var updatedUserDetails:Object = new Object();
				if (currentPassword && currentPassword.text)
					updatedUserDetails.currentPassword = currentPassword.text;
				if (newPassword && newPassword.text)
					updatedUserDetails.password = newPassword.text;
				if (userDetails.examDate) {
					// setHours is just not working
					//userDetails.examDate.setHours(examHours.value);
					//userDetails.examDate.setMinutes(examMinutes.value);
					//updatedUserDetails.examDate = DateUtil.dateToAnsiString(userDetails.examDate);
					updatedUserDetails.examDate = DateUtil.formatDate(userDetails.examDate, "yyyy-MM-dd") + " " + examHours.value.toString() + ":" + examMinutes.value.toString();
				}
				updateUser.dispatch(updatedUserDetails);
			}
		}
		
		public function showUpdateError(msg:String = ""):void {
			if (msg) {
				Alert.show(msg, "Update problem");
			} else {
				Alert.show("Sorry, these details can't be updated.", "Update problem");				
			}
		}
		
		public function showUpdateSuccess(msg:String = ""):void {
			if (msg) {
				Alert.show(msg, "Update success");
			} else {
				Alert.show("Your details have been saved.", "Your profile");				
			}
		}
		
	}
	
}