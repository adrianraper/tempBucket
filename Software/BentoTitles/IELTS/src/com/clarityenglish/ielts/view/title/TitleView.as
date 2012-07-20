package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.account.AccountView;
	import com.clarityenglish.ielts.view.exercise.ExerciseView;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	import com.clarityenglish.ielts.view.support.SupportView;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.SWFLoader;
	import mx.formatters.DateFormatter;
	
	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.Label;
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
		
		private var currentExerciseHref:Href;
		
		private var _productVersion:String;
		private var _productCode:uint;
		private var _licenceType:uint;

		// #337
		public var candidateOnlyInfo:Boolean = false;
		
		// #260 
		private var shortDelayTimer:Timer;
		
		public var logout:Signal = new Signal();
		public var backToMenu:Signal = new Signal();
		public var register:Signal = new Signal();
		public var upgrade:Signal = new Signal();
		public var buy:Signal = new Signal();
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="HomeIcon")]
		private var homeIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="ProgressIcon")]
		private var progressIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="AccountIcon")]
		private var accountIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="HelpIcon")]
		private var helpIcon:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersionAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersion")]
		
		private var fullVersionAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersionGeneralTraining")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersion")]
		private var fullVersionGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHourAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHour")]
		private var tenHourAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHourGeneralTraining")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHour")]
		private var tenHourGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinuteAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinute")]
		private var lastMinuteAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinuteGeneralTraining")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinute")]
		private var lastMinuteGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemoAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		private var demoAcademicLogo:Class;

		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemoGeneralTraing")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoDemo")]
		private var demoGeneralTrainingLogo:Class;

		[Embed(source="skins/ielts/assets/upgrade.jpg")]
		private var upgradeInfo:Class;
		
		[Embed(source="skins/ielts/assets/register.jpg")]
		private var registerInfo:Class;
		
		[Embed(source="skins/ielts/assets/price.jpg")]
		private var priceInfo:Class;
		
		[Embed(source="skins/ielts/assets/buy.jpg")]
		private var buyInfo:Class;
		
		public var _selectedCourseXML:XML;
		[Bindable(event="courseSelected")]
		public function get selectedCourseXML():XML { return _selectedCourseXML; }
		public function set selectedCourseXML(value:XML):void {
			_selectedCourseXML = value;
			
			if (_selectedCourseXML) {
				currentState = "zone";
				if (navBar) navBar.selectedIndex = -1;
				if (homeViewNavigator) {
					homeViewNavigator.pushView(ZoneView, _selectedCourseXML);
				}
			}
			
			dispatchEvent(new Event("courseSelected"));
		}
		
		// Constructor to let us initialise our states
		public function TitleView() {
			super();
			
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "zone", "account", "progress", "support" ], true);
		}
		
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		
		[Bindable(event="productVersionChanged")]
		public function get productVersion():String {
			return _productVersion;
		}
		
		public function set productCode(value:uint):void {
			if (_productCode != value) {
				_productCode = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
				dispatchEvent(new Event("licenceTypeChanged"));
			}
		}
		[Bindable]
		public function get licenceType():uint {
			return _licenceType;
		}
		
		[Bindable(event="productVersionChanged")]
		public function get productVersionLogo():Class {
			switch (_productCode) {
				case IELTSApplication.ACADEMIC_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return lastMinuteAcademicLogo;
						case IELTSApplication.TEST_DRIVE:
							return tenHourAcademicLogo;
						case IELTSApplication.DEMO:
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
						case IELTSApplication.DEMO:
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

		[Bindable(event="productVersionChanged")]
		public function get productVersionText():String {
			switch (_productCode) {
				case IELTSApplication.ACADEMIC_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return "       Last Minute - Academic module";
						case IELTSApplication.TEST_DRIVE:
							return "       Test Drive - Academic module";
						case IELTSApplication.DEMO:
							return "                 Academic module";
						case IELTSApplication.FULL_VERSION:
						default:
							return "Academic module";
					}
					break;
				case IELTSApplication.GENERAL_TRAINING_MODULE:
					switch (_productVersion) {
						case IELTSApplication.LAST_MINUTE:
							return "       Last Minute - General Training module";
						case IELTSApplication.TEST_DRIVE:
							return "       Test Drive - General Training module";
						case IELTSApplication.DEMO:
							return "                 General Training module";
						case IELTSApplication.FULL_VERSION:
						default:
							return "General Training module";
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
		public function get productVersionInfo():Class {
			switch (_productVersion) {
				case IELTSApplication.LAST_MINUTE:
					return upgradeInfo;
					break;
				
				case IELTSApplication.TEST_DRIVE:
					return registerInfo;
					break;
				
				case IELTSApplication.DEMO:
					// #337 
					if (config.pricesURL)
						return priceInfo;
					
					return buyInfo;
					break;
							
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
		
		public function showExercise(exerciseHref:Href):void {
			currentExerciseHref = exerciseHref;
			if (exerciseView) exerciseView.href = currentExerciseHref;
			callLater(invalidateSkinState); // callLater is part of #192
			
			if (homeViewNavigator) {
				homeViewNavigator.pushView(ExerciseView, currentExerciseHref);
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case navBar:
					// Network licence doesn't want a My Profile tab
					// TODO. But CT licence will still want it - and they are a shared value!
					if (licenceType == Title.LICENCE_TYPE_NETWORK) {
						navBar.dataProvider = new ArrayCollection( [
							{ icon: homeIcon, label: "Home", data: "home" },
							{ icon: progressIcon, label: "My Progress", data: "progress" },
							{ icon: helpIcon, label: "Help", data: "support" },
						] );
					} else {
						navBar.dataProvider = new ArrayCollection( [
							{ icon: homeIcon, label: "Home", data: "home" },
							{ icon: progressIcon, label: "My Progress", data: "progress" },
							{ icon: accountIcon, label: "My Profile", data: "account" },
							{ icon: helpIcon, label: "Help", data: "support" },
						] );
					}
					
					navBar.selectedIndex = 0;
					navBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					
					// This is some slightly hacky code to ensure that the user cannot deselect a navbar button whilst still allowing us to set selectedIndex=-1 programatically (#140)
					navBar.addEventListener(IndexChangeEvent.CHANGE, function(e:IndexChangeEvent):void {
						if (e.newIndex == -1) {
							e.preventDefault();
							navBar.callLater(function():void { navBar.selectedIndex = e.oldIndex; });
						}
					} );
					break;
				
				case logoutButton:
					instance.addEventListener(MouseEvent.CLICK, onLogoutButtonClick);
					break;
				
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
				
				case exerciseView:
					exerciseView.href = currentExerciseHref;
					break;
				
				case noticeLabel:
					// TODO: Check whether we know the exam date, if not say go to my account page to set it
					var daysLeft:Number = DateUtil.dateDiff(new Date(), user.examDate, "d");
					var daysUnit:String = (daysLeft==1) ? "day" : "days";
					if (daysLeft > 0) {
						instance.text = "Less than " + daysLeft.toString() + " " + daysUnit + " left until your test.";
					} else if (daysLeft == 0) {
						instance.text = "Your test is today, good luck!";
					} else {
						instance.text = "Hope your test went well...";
					}
					break;
				
				// #299
				// #337
				case infoButton:
					instance.addEventListener(MouseEvent.CLICK, onRequestInfoClick);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case navBar:
					navBar.removeEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
				case backToMenuButton:
					instance.removeEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
				case logoutButton:
					instance.removeEventListener(MouseEvent.CLICK, onLogoutButtonClick);
					break;
			}
		}
		
		/**
		 * 
		 * This shows what state the skin is currently in
		 * 
		 * @return string State name 
		 */
		protected override function getCurrentSkinState():String {
			if (currentExerciseHref)
				return "exercise";
			
			return currentState;
		}
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onNavBarIndexChange(event:Event):void {
			// We can set the skin state from the tab bar click
			if (event.target.selectedItem) currentState = event.target.selectedItem.data;
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
			trace("enable logout button");
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
				case IELTSApplication.DEMO:
					buy.dispatch();
					break;
				case IELTSApplication.FULL_VERSION:
				default:
			}
		}
	}
	
}