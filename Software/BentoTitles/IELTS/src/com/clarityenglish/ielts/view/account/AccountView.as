package com.clarityenglish.ielts.view.account {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.manageable.User;
	
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
		public var examDate:DateField;
		
		[SkinPart(required="true")]
		public var examHours:NumericStepper;
		[SkinPart(required="true")]
		public var examMinutes:NumericStepper;
		
		[SkinPart(required="true")]
		public var saveChangesButton:Button;

		[SkinPart]
		public var IELTSApp1:SWFLoader;

		public var updateUser:Signal = new Signal(Object);
		
		[Bindable]
		public var userDetails:User;

		private var _productVersion:String;
		private var _productCode:uint;
		
		public function AccountView() {
			super();
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
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case saveChangesButton:
					instance.addEventListener(MouseEvent.CLICK, onUpdateButtonClick);
					break;
				
				case countdownLabel:
					// We will only tell the user about the countdown if they have confirmed their exam date
					if (userDetails.examDate) {
						instance.text = "This is the remaining time until your test."
					} else {
						instance.text = "Please confirm your test date below."
					}
					break;
				
				case examDate:
					instance.addEventListener(CalendarLayoutChangeEvent.CHANGE, onExamDateChange);
					break;
				
				case IELTSApp1:
					var context:LoaderContext = new LoaderContext();
					
					/* Specify the current application's security domain. */
					//context.securityDomain = SecurityDomain.currentDomain;
					
					/* Specify a new ApplicationDomain, which loads the sub-app into a peer ApplicationDomain. */
					context.applicationDomain = new ApplicationDomain();
					
					instance.loaderContext = context;                 
					instance.source = "/Software/Widget/IELTS/bin/BandScoreCalculator-200.swf?widgetdatawidth=200&widgetdataheight=300&widgetdatalanguage=EN&widgetdatacountry=none&widgetdatabclogo=true&cache=" + new Date().getTime();
					break
			}
		}
		
		/**
		 * The user changed the exam date 
		 * @param event
		 * 
		 */
		protected function onExamDateChange(eventObj:CalendarLayoutChangeEvent):void {
			// Make sure selectedDate is not null.
			if (eventObj.currentTarget.selectedDate) {
				// Just update the counter for now
				//userDetails.birthday = dbDateFormatter.format(eventObj.currentTarget.selectedDate);
				userDetails.examDate = eventObj.currentTarget.selectedDate;
				trace("exam date changed to " + userDetails.examDate.toDateString()); 
			}
		}
		
		/**
		 * The user has clicked the update button
		 *
		 * @param event
		 */
		protected function onUpdateButtonClick(event:MouseEvent):void {
			// Any validation to do here?
			if (newPassword.text != confirmPassword.text) {
				showUpdateError("The two new passwords you typed must be the same.");
			} else {
				// Trigger the update command. Use an Event or a Signal?
				// Do I really need to pass anything at all since the mediator can get it all anyway?
				// Or I could use a form and pass that?
				var newUserDetails:Object = new Object();
				newUserDetails.currentPassword = currentPassword.text;
				newUserDetails.password = newPassword.text;
				//newUserDetails.examJustDate = DateUtil.dateToAnsiString(examDate.selectedDate);
				newUserDetails.examJustTime = examHours.value.toString() + ":" + examMinutes.value.toString();
				updateUser.dispatch(newUserDetails);
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
				Alert.show("Your details have been changed.", "Update");				
			}
		}
		
	}
	
}