package com.clarityenglish.ielts.view.account {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
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
	
	public class AccountView extends BentoView {
			
		[SkinPart]
		public var currentPassword:TextInput;
		
		[SkinPart]
		public var newPassword:TextInput;
		
		[SkinPart]
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
		public var registerInfoButton:Button;
		
		[SkinPart]
		public var IELTSApp1:SWFLoader;
		
		[SkinPart]
		public var countdownDisplay:CountdownDisplay;
		
		[SkinPart]
		public var setTestDateLabel:Label;
		
		[SkinPart]
		public var testDateLabel:Label;
		
		[SkinPart]
		public var registeredNameLabel:Label;
		
		[SkinPart]
		public var emailLabel:Label;
		
		[SkinPart]
		public var accountStartDateLabel:Label;
		
		[SkinPart]
		public var startDateLabel:Label;
		
		[SkinPart]
		public var accountExpiryDateLabel:Label;
		
		[SkinPart]
		public var endDateLabel:Label;

		public var updateUser:Signal = new Signal(Object);
		public var register:Signal = new Signal();
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var startDate:String;
		
		[Bindable]
		public var expiryDate:String;
		
		[Bindable]
		public var isDirty:Boolean;

		// #333
		private var _remoteDomain:String;
		
		public function AccountView() {
			super();
		}

		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case saveChangesButton:
					instance.addEventListener(MouseEvent.CLICK, onUpdateButtonClick);
					instance.label = copyProvider.getCopyForId("saveChangesButton");
					break;
				
				case countdownLabel:
					// We will only tell the user about the countdown if they have confirmed their exam date
					if (user.examDate) {
						var daysLeft:Number = DateUtil.dateDiff(new Date(), user.examDate, "d");
						if (daysLeft > 0) {
							instance.text = copyProvider.getCopyForId("countDownLabel1");
						} else if (daysLeft == 0) {
							instance.text = copyProvider.getCopyForId("countDownLabel2");
						} else {
							//countdownDisplay.enabled = false;
							instance.text = copyProvider.getCopyForId("countDownLabel3");
						}
						
					} else {
						instance.text = copyProvider.getCopyForId("alertEmtyDateLabel");
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
				
				case registerInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onRequestInfoClick);
					break;
				//issue:#11 Language Code
				case setTestDateLabel:
					instance.text = copyProvider.getCopyForId("setTestDateLabel");
					break;
				case registeredNameLabel:
					instance.text = copyProvider.getCopyForId("registeredNameLabel");
					break;
				case emailLabel:
					instance.text = copyProvider.getCopyForId("emailLabel");
					break;
				case accountStartDateLabel:
					instance.text = copyProvider.getCopyForId("accountStartDateLabel");
					break;
				case startDateLabel:
					if (config.languageCode == "ZH") {
						var repObejct:Object = new Object();
						repObejct.day = (DateUtil.ansiStringToDate(startDate)).day;
						repObejct.month = (DateUtil.ansiStringToDate(startDate)).month;
						repObejct.year = (DateUtil.ansiStringToDate(startDate)).fullYear;
						instance.text = copyProvider.getCopyForId("dateFormatLabel", repObejct);
					} else {
					    instance.text =DateUtil.formatDate(DateUtil.ansiStringToDate(startDate), 'd MMMM yyyy')
					}
					break;
				case accountExpiryDateLabel:
					instance.text = copyProvider.getCopyForId("accountExpiryDateLabel");
					break;
				case endDateLabel:
					if (config.languageCode == "ZH") {
						var objReplace:Object = new Object();
						objReplace.day = (DateUtil.ansiStringToDate(expiryDate)).day;
						objReplace.month = (DateUtil.ansiStringToDate(expiryDate)).month;
						objReplace.year = (DateUtil.ansiStringToDate(expiryDate)).fullYear;
						instance.text = copyProvider.getCopyForId("dateFormatLabel", objReplace);
					} else {
						instance.text =DateUtil.formatDate(DateUtil.ansiStringToDate(expiryDate), 'd MMMM yyyy')
					}
					break;
				case testDateLabel:
					instance.text = copyProvider.getCopyForId("testDateLabel");
					break;
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
					if (licenceType == Title.LICENCE_TYPE_AA ||
						Number(config.userID) < 1)
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
			} else if (user.examDate) {
				var baseDate:Date = new Date(user.examDate.getTime());
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
				user.examDate = new Date(examDateTime);
				trace("exam date changed to " + DateUtil.formatDate(user.examDate, "yyyy-MM-dd hh:mm"));
				
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
				//issue:#11
				showUpdateError(copyProvider.getCopyForId("updateError"));
			} else {
				// Trigger the update command. Use an Event or a Signal?
				// Do I really need to pass anything at all since the mediator can get it all anyway?
				// Or I could use a form and pass that?
				var updatedUserDetails:Object = new Object();
				
				if (currentPassword && currentPassword.text)
					updatedUserDetails.currentPassword = currentPassword.text;
				if (newPassword && newPassword.text)
					updatedUserDetails.password = newPassword.text;
				if (user.examDate) {
					updatedUserDetails.examDate = DateUtil.formatDate(user.examDate, "yyyy-MM-dd") + " " + examHours.value.toString() + ":" + examMinutes.value.toString();
				}
				
				updateUser.dispatch(updatedUserDetails);
			}
		}
		
		public function showUpdateError(msg:String = ""):void {
			if (msg) {
				Alert.show(msg, "Update problem");
			} else {
				//issue:#11
				Alert.show(copyProvider.getCopyForId("updateFail"), "Update problem");				
			}
		}
		
		public function showUpdateSuccess(msg:String = ""):void {
			if (msg) {
				Alert.show(msg, "Update success");
			} else {
				//isssue:#11
				Alert.show(copyProvider.getCopyForId("updateSuccess"), "Your profile");				
			}
		}
		
		private function onRequestInfoClick(event:MouseEvent):void {
			register.dispatch();
		}
		
	}
	
}