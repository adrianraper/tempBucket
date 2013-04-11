package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.ExerciseView;
	import com.clarityenglish.bento.view.progress.ProgressView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.account.AccountView;
	import com.clarityenglish.ielts.view.credits.CreditsView;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.support.SupportView;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.SWFLoader;
	import mx.formatters.DateFormatter;
	
	import org.davekeen.util.ArrayUtils;
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.Label;
	import spark.components.TabbedViewNavigator;
	import spark.components.ViewNavigator;
	import spark.events.IndexChangeEvent;
	
	// This tells us that the skin has these states, but the view needs to know about them too
	[SkinState("home")]
	[SkinState("zone")]
	[SkinState("progress")]
	[SkinState("account")]
	[SkinState("support")]
	[SkinState("exercise")]
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var homeViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var homeNavBarItem:Object;
		
		[SkinPart]
		public var homeViewNavigatorButton1:Button;
		
		[SkinPart]
		public var homeViewNavigatorButton2:Button;
		
		[SkinPart]
		public var myProgressViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var myProgressNavBarItem:Object;
		
		[SkinPart]
		public var myProgressViewNavigatorButton1:Button;
		
		[SkinPart]
		public var myProgressViewNavigatorButton2:Button;
		
		[SkinPart]
		public var myProfileViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var myProfileNavBarItem:Object;
		
		[SkinPart]
		public var myProfileViewNavigatorButton1:Button;
		
		[SkinPart]
		public var myProfileViewNavigatorButton2:Button;
		
		[SkinPart]
		public var helpViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var helpNavBarItem:Object;
		
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
		public var navBar:ButtonBar;
		
		[SkinPart]
		public var logoutButton:Button;
		
		[SkinPart]
		public var backToMenuButton:Button;
		
		[SkinPart]
		public var homeView:HomeView;
		
		[SkinPart]
		public var zoneView:ZoneView;
		
		[SkinPart]
		public var progressView:ProgressView;
		
		[SkinPart]
		public var accountView:AccountView;
		
		[SkinPart]
		public var supportView:SupportView;
		
		[SkinPart]
		public var exerciseView:ExerciseView;
		
		[SkinPart]
		public var noticeLabel:Label;
		
		[SkinPart]
		public var infoButton:SWFLoader;
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var configID:String;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		// These SkinParts are only in the ipad app
		[SkinPart]
		public var sectionNavigator:TabbedViewNavigator;
		
		// #337
		public var candidateOnlyInfo:Boolean = false;
		
		// #260 
		private var shortDelayTimer:Timer;
		
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
		
		/*private var _selectedCourseXML:XML;
		
		public function set selectedCourseXML(value:XML):void {
			_selectedCourseXML = value;
			
			if (_selectedCourseXML) {
				currentState = "zone";
				if (navBar) navBar.selectedIndex = -1;
				
				// This is for mobile skins; if the ZoneView is top of the stack then push the data, otherwise push ZoneView and data
				if (homeViewNavigator) {
					if (ClassUtil.getClass(homeViewNavigator.activeView) == ZoneView) {
						homeViewNavigator.activeView.data = _selectedCourseXML;
					} else {
						homeViewNavigator.pushView(ZoneView, _selectedCourseXML);
					}
				}
			}
		}
		
		public function showExercise(exerciseHref:Href):void {
			currentExerciseHref = exerciseHref;
			if (exerciseView) exerciseView.href = currentExerciseHref;
			callLater(invalidateSkinState); // callLater is part of #192
		
			// This is for mobile skins; if the ExerciseView is already top of the stack then set the href, otherwise push a new ExerciseView
			if (homeViewNavigator) {
				if (ClassUtil.getClass(homeViewNavigator.activeView) == ExerciseView) {
					if (currentExerciseHref) {
						(homeViewNavigator.activeView as ExerciseView).href = currentExerciseHref;
					} else {
						homeViewNavigator.popView();
					}
				} else {
					homeViewNavigator.pushView(ExerciseView, currentExerciseHref);
				}
			}
		}*/
		
		private var _selectedNode:XML;
		
		public function set selectedNode(value:XML):void {
			_selectedNode = value;
			
			switch (_selectedNode.localName()) {
				case "course":
				case "unit":
					currentState = "zone";
					if (navBar) navBar.selectedIndex = -1; // this is ugly; should I put it in a listener in the skin instead?  I reckon yes.
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
					return this.languageAssetFolder + (config.pricesURL) ? "price.jpg" : "buy.jpg";
				case IELTSApplication.FULL_VERSION:
				default:
					return null;
			}
			return null;
		}

		[Bindable(event="licenceTypeChanged")]
		public function get licenceTypeText():String {
			return Title.getLicenceTypeText(_licenceType);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case navBar:
					// Network licence doesn't want a My Profile tab
					if (licenceType == Title.LICENCE_TYPE_NETWORK) {
						var myProfileItem:Object = ArrayUtils.searchArrayForObject(navBar.dataProvider.toArray(), "account", "state");
						if (myProfileItem) navBar.dataProvider.removeItemAt(navBar.dataProvider.getItemIndex(myProfileItem));
					}
					
					navBar.selectedIndex = 0;
					navBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					
					// This is some slightly hacky code to ensure that the user cannot deselect a navbar button whilst still allowing us to set selectedIndex=-1 programatically (#140)
					navBar.addEventListener(IndexChangeEvent.CHANGE, function(e:IndexChangeEvent):void {
						if (e.newIndex == -1) {
							e.preventDefault();
							navBar.callLater(function():void { navBar.selectedIndex = e.oldIndex; });
						}
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
					var daysUnit:String = (daysLeft==1) ? copyProvider.getCopyForId("day") : copyProvider.getCopyForId("days");
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
				case homeViewNavigator:
				case homeNavBarItem:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case homeViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Back");
					break;
				case homeViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
			    case myProgressViewNavigator:
				case myProgressNavBarItem:
					instance.label = copyProvider.getCopyForId("myProgress");
					break;
				case myProgressViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case myProgressViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
				case myProfileViewNavigator:
				case myProfileNavBarItem:
					instance.label = copyProvider.getCopyForId("myProfile");
					break;
				case myProfileViewNavigatorButton1:
					instance.label = copyProvider.getCopyForId("Home");
					break;
				case myProfileViewNavigatorButton2:
					instance.label = copyProvider.getCopyForId("LogOut");
					break;
				case helpViewNavigator:
				case helpNavBarItem:
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
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onNavBarIndexChange(event:Event):void {
			// We can set the skin state from the tab bar click
			if (event.target.selectedItem) currentState = event.target.selectedItem.state;
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
			if (zoneView && zoneView.isMediated) {
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
		
	}
	
}