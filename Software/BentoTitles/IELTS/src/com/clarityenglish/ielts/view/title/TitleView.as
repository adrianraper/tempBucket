package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.bento.view.progress.ProgressView;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.account.AccountView;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.support.SupportView;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.SWFLoader;
	import mx.controls.Text;
	import mx.formatters.DateFormatter;
	
	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.RichEditableText;
	import spark.components.TabbedViewNavigator;
	import spark.components.ViewNavigator;
	import spark.utils.TextFlowUtil;
	
	// This tells us that the skin has these states, but the view needs to know about them too
	[SkinState("home")]
	[SkinState("zone")]
	[SkinState("progress")]
	[SkinState("account")]
	[SkinState("support")]
	[SkinState("exercise")]
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var sectionNavigator:TabbedViewNavigator;
		
		[SkinPart]
		public var homeViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var homeViewNavigatorButton1:Button;
		
		[SkinPart]
		public var homeViewNavigatorButton2:Button;
		
		[SkinPart]
		public var myProgressViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var myProgressViewNavigatorButton1:Button;
		
		[SkinPart]
		public var myProgressViewNavigatorButton2:Button;
		
		[SkinPart]
		public var myProfileViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var myProfileViewNavigatorButton1:Button;
		
		[SkinPart]
		public var myProfileViewNavigatorButton2:Button;
		
		[SkinPart]
		public var helpViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var helpViewNavigatorButton1:Button;
		
		[SkinPart]
		public var helpViewNavigatorButton2:Button;
		
		[SkinPart]
		public var creditsViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var creditsViewNavigatorButton1:Button;
		
		[SkinPart]
		public var creditsViewNavigatorButton2:Button;
		
		[SkinPart]
		public var moreViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var moreViewNavigatorButton1:Button;
		
		[SkinPart]
		public var moreViewNavigatorButton2:Button;
		
		[SkinPart]
		public var logoutButton:Button;
		
		[SkinPart]
		public var backToMenuButton:Button;
		
		[SkinPart]
		public var noticeLabel:Label;
		
		[SkinPart]
		public var topInforButton:InforButton;
		
		// gh#383
		[SkinPart]
		public var infoButton:SWFLoader;
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var configID:String;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		// #337
		public var candidateOnlyInfo:Boolean = false;
		
		// #260 
		private var shortDelayTimer:Timer;
		
		// gh#383
		private var _infoButtonText:String;
		private var _inforButtonTextFlow:TextFlow;
		
		public var logout:Signal = new Signal();
		public var backToMenu:Signal = new Signal();
		public var register:Signal = new Signal();
		public var upgrade:Signal = new Signal();
		public var buy:Signal = new Signal();
		
		[Embed(source="/skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersion")]
		private var fullVersionAcademicLogo:Class;
		
		[Embed(source="/skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersion")]
		private var fullVersionGeneralTrainingLogo:Class;
		
		[Embed(source="/skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHour")]
		private var tenHourAcademicLogo:Class;
		
		[Embed(source="/skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHour")]
		private var tenHourGeneralTrainingLogo:Class;
		
		[Embed(source="/skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinute")]
		private var lastMinuteAcademicLogo:Class;
		
		[Embed(source="/skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinute")]
		private var lastMinuteGeneralTrainingLogo:Class;
		
		[Embed(source="/skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		private var demoAcademicLogo:Class;

		[Embed(source="/skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		private var demoGeneralTrainingLogo:Class;
		
		public function set selectedNode(value:XML):void {
			switch (value.localName()) {
				case "course":
				case "unit":
					currentState = "zone";
					break;
				case "exercise":
					currentState = "exercise";
					break;
			}
		}
		
		public function TitleView() {
			super();
			
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "zone", "exercise", "account", "progress", "support" ], true);
		}
		
		// gh#11 Language Code, read pictures from the folder base on the LanguageCode you set
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		
		// gh#383
		[Bindable]
		public function get infoButtonText():String {
			return _infoButtonText;
		}
		
		public function set infoButtonText(value:String):void {
			_infoButtonText = value;
		}
		
		// gh#383
		[Bindable]
		public function get inforButtonTextFlow():TextFlow {
			return _inforButtonTextFlow;
		}
		
		public function set inforButtonTextFlow(value:TextFlow):void {
			_inforButtonTextFlow = value;
		}
		
		[Bindable(event="productCodeChanged")]
		[Bindable(event="productVersionChanged")]
		public function get productVersionLogo():Class {
			switch (_productCode) {
				case IELTSApplication.ACADEMIC_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return lastMinuteAcademicLogo;
						case IELTSApplication.TEST_DRIVE:
							return tenHourAcademicLogo;
						case BentoApplication.DEMO:
							return demoAcademicLogo;
						case IELTSApplication.FULL_VERSION:
							
						default:
							return fullVersionAcademicLogo;
					}
					break;
				case IELTSApplication.GENERAL_TRAINING_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return lastMinuteAcademicLogo;
						case IELTSApplication.TEST_DRIVE:
							return tenHourGeneralTrainingLogo;
						case BentoApplication.DEMO:
							return demoGeneralTrainingLogo;
						case IELTSApplication.FULL_VERSION:
						default:
							return fullVersionGeneralTrainingLogo;
					}
					break;
				default:
					// No product code set yet so don't set the logo
					return null;
			}
			return null;
		}

		[Bindable(event="productCodeChanged")]
		[Bindable(event="productVersionChanged")]
		public function get productVersionText():String {
			switch (_productCode) {
				case IELTSApplication.ACADEMIC_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return "       " + copyProvider.getCopyForId("lastTimeAC");
						case IELTSApplication.TEST_DRIVE:
							return "       " + copyProvider.getCopyForId("testDriveAC");
						case BentoApplication.DEMO:
							return "                 " + copyProvider.getCopyForId("AC");
						case IELTSApplication.FULL_VERSION:
						default:
							return copyProvider.getCopyForId("AC");
					}
					break;
				case IELTSApplication.GENERAL_TRAINING_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return "       " + copyProvider.getCopyForId("lastTimeGT");
						case IELTSApplication.TEST_DRIVE:
							return "       " + copyProvider.getCopyForId("testDriveGT");
						case BentoApplication.DEMO:
							return "                 " + copyProvider.getCopyForId("GT");
						case IELTSApplication.FULL_VERSION:
						default:
							return copyProvider.getCopyForId("GT");
					}
					break;
				default:
					// No product code set yet so don't set the text
					return null;
			}
			return null;
		}

		// #337
		[Bindable(event="productVersionChanged")]
		public function get productVersionInfo():String {
			switch (_productVersion) {
				case IELTSApplication.LAST_MINUTE:
					return this.languageAssetFolder + "upgrade.jpg";
				case IELTSApplication.TEST_DRIVE:
					return this.languageAssetFolder + "register.jpg";
				case BentoApplication.DEMO:
					// #337
					return this.languageAssetFolder + ((config.pricesURL) ? "price.jpg" : "buy.jpg");
				case IELTSApplication.FULL_VERSION:
				default:
					return null;
			}
			return null;
		}
		
		// gh#383
		[Bindable(event="productVersionChanged")]
		public function get productVersionInforButton():Boolean {
			if (_productVersion == IELTSApplication.LAST_MINUTE) {
				// assign default value to information button in home menu page
				infoButtonText = copyProvider.getCopyForId("infoReadingText");
				inforButtonTextFlow = TextFlowUtil.importFromString(infoButtonText);
				return true;
			} else {
				return false;
			}
		}

		[Bindable(event="licenceTypeChanged")]
		public function get licenceTypeText():String {
			return Title.getLicenceTypeText(_licenceType);
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			// Don't show profile tab for network users
			// gh#603 removing profile tab blocks the logout button
			/*
			if (licenceType == Title.LICENCE_TYPE_NETWORK) {
				var profileIdx:int = sectionNavigator.tabBar.dataProvider.getItemIndex(myProfileViewNavigator);
				if (profileIdx >= 0) sectionNavigator.tabBar.dataProvider.removeItemAt(profileIdx);
			}
			*/
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case sectionNavigator:
					setNavStateMap(sectionNavigator, {
						home: { viewClass: HomeView },
						zone: { viewClass: ZoneView, stack: true },
						exercise: { viewClass: ExerciseView, stack: true },
						progress: { viewClass: ProgressView },
						account: { viewClass: AccountView },
						support: { viewClass: SupportView }
					});
					break;
				case logoutButton:
					instance.addEventListener(MouseEvent.CLICK, onLogoutButtonClick);
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
				case noticeLabel:
					// TODO: Check whether we know the exam date, if not say go to my account page to set it
					var daysLeft:Number = DateUtil.dateDiff(new Date(), user.examDate, "d");
					var daysUnit:String = (daysLeft == 1) ? copyProvider.getCopyForId("day") : copyProvider.getCopyForId("days");
					if (daysLeft > 0) {
						instance.text = copyProvider.getCopyForId("lessThan") + " " + daysLeft.toString() + " " + daysUnit + " " + copyProvider.getCopyForId("leftUntil");
					} else if (daysLeft == 0) {
						instance.text = copyProvider.getCopyForId("countDownLabel2");
					} else {
						instance.text = copyProvider.getCopyForId("countDownLabel3");
					}
					break;
				// #299, #337
				case infoButton:
					instance.addEventListener(MouseEvent.CLICK, onRequestInfoClick);
					break;
				// gh#383
				case topInforButton:
					instance.addEventListener(MouseEvent.CLICK, onRequestInfoClick);
					break;
				case homeViewNavigator:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case homeViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Back");
					break;
				case homeViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
			    case myProgressViewNavigator:
					instance.label = copyProvider.getCopyForId("myProgress");
					break;
				case myProgressViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case myProgressViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
				case myProfileViewNavigator:
					instance.label = copyProvider.getCopyForId("myProfile");
					break;
				case myProfileViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case myProfileViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
				case helpViewNavigator:
					instance.label = copyProvider.getCopyForId("help");
					break;
				case helpViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case helpViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
				case creditsViewNavigator:
					instance.label = copyProvider.getCopyForId("credits");
					break;
				case creditsViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case creditsViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
				case moreViewNavigator:
					instance.label = copyProvider.getCopyForId("more");
					break;
				case moreViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case moreViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
			}
		}
		
		protected function onLogoutButtonClick(event:MouseEvent):void {
			logout.dispatch();
		}
		
		/**
		 * The user has clicked the back button to get out of an exercise, so clear the current exercise
		 * 
		 * @param event
		 */
		protected function onBackToMenuButtonClick(event:MouseEvent):void {
			backToMenu.dispatch();
			
			// #260 
			if (logoutButton) logoutButton.enabled = false;
			shortDelayTimer = new Timer(1000, 60);
			shortDelayTimer.start();
			shortDelayTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			shortDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetLogoutButton);
		}
		
		// #260 
		// This function enables logoutButton no matter what
		private function resetLogoutButton(event:TimerEvent):void {
			if (logoutButton) logoutButton.enabled = true;
		}
		
		// #260 
		// If the ZoneView is mediated, then enable the logoutButton and stop the Timer
		private function timerHandler(event:TimerEvent):void {
			// gh#278 This was removed because zoneView no longer exists, but the functionality is still required!
			/*if (zoneView && zoneView.isMediated) {
				callLater(resetLogoutButton, new Array(event));
				shortDelayTimer.stop();
			}*/
			if (currentState != 'exercise') {
				callLater(resetLogoutButton, new Array(event));
				shortDelayTimer.stop();
			}
		}
		
		// #337
		private function onRequestInfoClick(event:MouseEvent):void {
			switch (_productVersion) {
				case IELTSApplication.LAST_MINUTE:
					upgrade.dispatch();
					break;
				case IELTSApplication.TEST_DRIVE:
					register.dispatch();
					break;
				case BentoApplication.DEMO:
					buy.dispatch();
					break;
				case IELTSApplication.FULL_VERSION:
				default:
			}
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
		// gh#383
		public function getCourseClass(value:XML):void {
				if (value.localName() == "course") {
					switch (value.@["class"].toString()) {
						case "reading":
							infoButtonText = copyProvider.getCopyForId("infoReadingText");
							inforButtonTextFlow = TextFlowUtil.importFromString(infoButtonText);						
							break;
						case "listening":
							infoButtonText = copyProvider.getCopyForId("infoListeningText");
							inforButtonTextFlow = TextFlowUtil.importFromString(infoButtonText);	
							break;
						case "speaking":
							infoButtonText = copyProvider.getCopyForId("infoSpeakingText");
							inforButtonTextFlow = TextFlowUtil.importFromString(infoButtonText);	
							break;
						case "writing":
							infoButtonText = copyProvider.getCopyForId("infoWritingText");
							inforButtonTextFlow = TextFlowUtil.importFromString(infoButtonText);	
							break;
						default:
							
							break;
					}
				}			
		}
	}
	
}