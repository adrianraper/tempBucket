package com.clarityenglish.ielts.view.account {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.DateField;
	import mx.controls.SWFLoader;
	import mx.core.FlexGlobals;
	import mx.events.CalendarLayoutChangeEvent;
	
	import org.davekeen.util.ArrayUtils;
	import org.davekeen.util.DateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.NumericStepper;
	import spark.components.RichText;
	import spark.components.TextInput;
	import spark.events.DropDownEvent;
	import spark.utils.TextFlowUtil;
	
	public class AccountView extends BentoView {
			
		/*[SkinPart]
		public var currentPassword:TextInput;
		
		[SkinPart]
		public var newPassword:TextInput;
		
		[SkinPart]
		public var confirmPassword:TextInput;*/
		
		[SkinPart]
		public var countdownLabel:Label;
		
		[SkinPart]
		public var examDateField:DateField;
		
		[SkinPart(required="true")]
		public var examHours:NumericStepper;
		
		[SkinPart(required="true")]
		public var examMinutes:NumericStepper;
		
//		[SkinPart(required="true")]
//		public var saveChangesButton:Button;

		[SkinPart]
		public var registerInfoButton:Button;
		
		/*[SkinPart]
		public var IELTSApp1:SWFLoader;*/
		
		[SkinPart]
		public var countdownDisplay:CountdownDisplay;
		
		//[SkinPart]
		//public var setTestDateLabel:Label;
		
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
		
		[SkinPart]
		public var languageLabel:Label;
		
		/*[SkinPart]
		public var languageDropDownList:DropDownList;*/
		
		[SkinPart]
		public var countdownHeadingLabel:Label;
		
		[SkinPart]
		public var dateLabel:Label;
		
		[SkinPart]
		public var hourLabel:Label;
		
		[SkinPart]
		public var minuteLabel:Label;
		
		[SkinPart]
		public var myProfileLabel:Label;

		[SkinPart]
		public var myToolsLabel:Label;

		[SkinPart]
		public var calculatorLabel:Label;
		
		[SkinPart]
		public var registerInfoRichText:Label;
		
		[SkinPart]
		public var videoRichText:Label;
		
		[SkinPart]
		public var mockTestRichText:Label;
		
		[SkinPart]
		public var hourRichText:Label;

		[SkinPart]
		public var studyGuideList:List;

		[SkinPart]
		public var studyGuideLabel:Label;

		[SkinPart]
		public var studyPlannerCaptionLabel:Label;

		[SkinPart]
		public var studyPalnnerDescriptionLabel:Label;

		[SkinPart]
		public var studyPlannerDownloadButton:Button;

		[SkinPart]
		public var studyPlannerLabel:Label;

		public var updateUser:Signal = new Signal(Object);
		public var register:Signal = new Signal();
		public var languageChange:Signal = new Signal(String);
		
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
		
		[Bindable]
		public var hostCopyProvider:CopyProvider;

		[Bindable]
		public var isPlatformiPad:Boolean;
		
		override public function setCopyProvider(copyProvider:CopyProvider):void {
			super.setCopyProvider(copyProvider);
			hostCopyProvider = copyProvider;
		}
		
		public function AccountView() {
			super();
		}

		// gh#11
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		
		public function reloadCopy():void {
			styleManager.getStyleDeclaration("global").setStyle("fontFamily", "Helvetica");

			onViewCreationComplete();
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();

//			if (saveChangesButton) saveChangesButton.label = copyProvider.getCopyForId("saveChangesButton");
			
			if (countdownLabel) {
				// We will only tell the user about the countdown if they have confirmed their exam date
				if (user.examDate) {
					var daysLeft:Number = DateUtil.dateDiff(new Date(), user.examDate, "d");
					if (daysLeft > 0) {
						countdownLabel.text = copyProvider.getCopyForId("countDownLabel1");
					} else if (daysLeft == 0) {
						countdownLabel.text = copyProvider.getCopyForId("countDownLabel2");
					} else {
						countdownLabel.text = copyProvider.getCopyForId("countDownLabel3");
					}
				} else {
					countdownLabel.text = copyProvider.getCopyForId("alertEmptyDateLabel");
				}
			}
			
			//if (setTestDateLabel) setTestDateLabel.text = copyProvider.getCopyForId("setTestDateLabel");
			if (registeredNameLabel) registeredNameLabel.text = copyProvider.getCopyForId("registeredNameLabel");
			if (emailLabel) emailLabel.text = copyProvider.getCopyForId("emailLabel");
			if (accountStartDateLabel) accountStartDateLabel.text = copyProvider.getCopyForId("accountStartDateLabel");
			
			if (startDateLabel) {
				// gh#38
				if (startDate) {
					// TODO. I'm guessing that the date formatter can do the full Chinese date as well?
					var repObject:Object = new Object();
					var thisDate:Date = DateUtil.ansiStringToDate(startDate);
					repObject.day = thisDate.date;
					repObject.year = thisDate.fullYear;
					/*if (CopyProxy.languageCode == "ZH") {
						repObject.month = thisDate.month + 1;
					} else {*/
						repObject.month = DateUtil.formatDate(thisDate, 'MMMM');
					//}
					startDateLabel.text = copyProvider.getCopyForId("dateFormatLabel", repObject);
				}
			}
			
			if (endDateLabel) {
				// gh#38
				if (expiryDate) {
					repObject = new Object();
					thisDate = DateUtil.ansiStringToDate(expiryDate);
					repObject.day = thisDate.date;
					repObject.year = thisDate.fullYear;
					/*if (CopyProxy.languageCode == "ZH") {
						repObject.month = thisDate.month + 1;
					} else {*/
						repObject.month = DateUtil.formatDate(thisDate, 'MMMM');
					//}
					endDateLabel.text = copyProvider.getCopyForId("dateFormatLabel", repObject);
				}
			}
			
			if (accountExpiryDateLabel) accountExpiryDateLabel.text = copyProvider.getCopyForId("accountExpiryDateLabel");
			if (languageLabel) languageLabel.text = copyProvider.getCopyForId("accountLanguageLabel");
			
			if (testDateLabel) testDateLabel.text = copyProvider.getCopyForId("testDateLabel");
			if (countdownHeadingLabel) countdownHeadingLabel.text = copyProvider.getCopyForId("countdownHeadingLabel");
			if (dateLabel) dateLabel.text = copyProvider.getCopyForId("testDateLabel");
			if (hourLabel) hourLabel.text = copyProvider.getCopyForId("hourLabel");
			if (minuteLabel) minuteLabel.text = copyProvider.getCopyForId("minuteLabel");
			if (myProfileLabel) myProfileLabel.text = copyProvider.getCopyForId("myProfile");
			if (myToolsLabel) myToolsLabel.text = copyProvider.getCopyForId("myToolsLabel");
			if (calculatorLabel) calculatorLabel.text = copyProvider.getCopyForId("calculatorLabel");
			if (studyGuideLabel) studyGuideLabel.text = copyProvider.getCopyForId("studyGuideLabel");
			
			if (registerInfoRichText) {
				var registerInfoString:String = this.copyProvider.getCopyForId("registerInfoButton");
				//var registerInfoFlow:TextFlow = TextFlowUtil.importFromString(registerInfoString);
				//registerInfoRichText.textFlow = registerInfoFlow;
				registerInfoRichText.text = registerInfoString;
			}
			
			if (hourRichText) {
				var hourString:String = this.copyProvider.getCopyForId("hourRichText");
				//var hourFlow:TextFlow = TextFlowUtil.importFromString(hourString);
				//hourRichText.textFlow = hourFlow;
				hourRichText.text = hourString;
			}
			
			if (videoRichText) {
				var videoString:String = this.copyProvider.getCopyForId("videoRichText");
				//var videoFlow:TextFlow = TextFlowUtil.importFromString(videoString);
				//videoRichText.textFlow = videoFlow;
				videoRichText.text = videoString;
			}
			
			if (mockTestRichText) {
				var mockTestString:String = this.copyProvider.getCopyForId("mockTestRichText");
				//var mockTestFlow:TextFlow = TextFlowUtil.importFromString(mockTestString);
				//mockTestRichText.textFlow = mockTestFlow;
				mockTestRichText.text = mockTestString;
			}

			studyGuideList.dataProvider = new ArrayList(new Array(6));
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
//				case saveChangesButton:
//					instance.addEventListener(MouseEvent.CLICK, onUpdateButtonClick);
//					break;
				case examDateField:
					instance.addEventListener(CalendarLayoutChangeEvent.CHANGE, onExamDateChange);
					break;
				case examHours:
				case examMinutes:
					instance.addEventListener(Event.CHANGE, onExamTimeChange);
					break; 
				case registerInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onRequestInfoClick);
					break;
				case studyPlannerLabel:
				case studyPlannerCaptionLabel:
					instance.text = copyProvider.getCopyForId("studyPlannerCaptionLabel");
					break;
				case studyPalnnerDescriptionLabel:
					instance.text = copyProvider.getCopyForId("studyPalnnerDescriptionLabel");
					break;
				case studyPlannerDownloadButton:
					instance.label = copyProvider.getCopyForId("studyPlannerDownloadButton");
					instance.addEventListener(MouseEvent.CLICK, onStudyPlannerClicked);
					break;
				/*case languageDropDownList:
					instance.dataProvider = new ArrayCollection([
						{ label: "English", data: "EN" },
						{ label: "Chinese", data: "ZH" },
						{ label: "Japanese", data: "JP" }
					]);
					
					var currentLanguage:Object = ArrayUtils.searchArrayForObject(instance.dataProvider.source, CopyProxy.languageCode, "data");
					instance.selectedItem = currentLanguage;
					
					instance.addEventListener(Event.CHANGE, onLanguageChange);
					instance.addEventListener(MouseEvent.CLICK, onLanguageChange);
					break;*/
			}
		}
		
		protected override function getCurrentSkinState():String {
			switch (productVersion) {
				case BentoApplication.DEMO:
					return "demo";
					break;
				case IELTSApplication.TEST_DRIVE:
					return "testDrive";
					break;
				case IELTSApplication.FULL_VERSION:
					var currentState:String = "fullVersion";
					// gh#38 userID is from user not config
					if (licenceType == Title.LICENCE_TYPE_AA ||
						Number(user.userID) < 1)
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
				//trace("exam date changed to " + DateUtil.formatDate(user.examDate, "yyyy-MM-dd hh:mm"));
				
			}
			//isDirty = true;
			var updatedUserDetails:Object = new Object();
			if (user.examDate) {
				updatedUserDetails.examDate = DateUtil.formatDate(user.examDate, "yyyy-MM-dd") + " " + examHours.value.toString() + ":" + examMinutes.value.toString();
			}
			updateUser.dispatch(updatedUserDetails);
		}
		
		/*protected function onLanguageChange(e:Event):void {
			if (languageDropDownList.selectedItem) {
				var languageCode:String = languageDropDownList.selectedItem.data;
				languageChange.dispatch(languageCode);
				
				if (languageCode == "EN") {
					FlexGlobals.topLevelApplication.setStyle("fontFamily", "Helvetica");
				} else {
					FlexGlobals.topLevelApplication.setStyle("fontFamily", "ChineseFont"); 
				}
				
				// gh#163
				//isDirty = true;
			}
			
		}*/
		
		/**
		 * The user has clicked the update button
		 *
		 * @param event
		 */
		protected function onUpdateButtonClick(event:MouseEvent):void {
				var updatedUserDetails:Object = new Object();

				if (user.examDate) {
					updatedUserDetails.examDate = DateUtil.formatDate(user.examDate, "yyyy-MM-dd") + " " + examHours.value.toString() + ":" + examMinutes.value.toString();
				}
				
				updateUser.dispatch(updatedUserDetails);
		}

		protected function onStudyPlannerClicked(event:Event):void {
			var url:String;
			if (productVersion == IELTSApplication.FULL_VERSION) {
				url = copyProvider.getCopyForId("studyPlannerFVDownloadLink");
			} else if (productVersion == IELTSApplication.LAST_MINUTE){
				url = copyProvider.getCopyForId("studyPlannerLMDownloadLink");
			}
			navigateToURL(new URLRequest(url), "_blank");
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