package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.view.account.AccountView;
	import com.clarityenglish.ielts.view.exercise.ExerciseView;
	import com.clarityenglish.ielts.view.home.HomeView;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	import com.clarityenglish.ielts.view.zone.ZoneView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.ItemClickEvent;
	import mx.formatters.DateFormatter;
	
	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StateUtil;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	import spark.events.ListEvent;
	
	// This tells us that the skin has these states, but the view needs to know about them too
	[SkinState("home")]
	[SkinState("zone")]
	[SkinState("progress")]
	[SkinState("account")]
	[SkinState("exercise")]
	public class TitleView extends BentoView {
		
		[SkinPart]
		public var navBar:ButtonBar;
		
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
		public var exerciseView:ExerciseView;
		
		[SkinPart]
		public var noticeLabel:Label;
				
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var configID:String;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		private var currentExerciseHref:Href;
		
		private var _productVersion:String;
		private var _productCode:uint;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="HomeIcon")]
		private var homeIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="ProgressIcon")]
		private var progressIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="AccountIcon")]
		private var accountIcon:Class;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="NotepadIcon")]
		private var notepadIcon:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersionAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersion")]
		private var fullVersionAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoFullVersionGeneralTraining")]
		private var fullVersionGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHourAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHour")]
		private var tenHourAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoTenHourGeneralTraining")]
		private var tenHourGeneralTrainingLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinuteAcademic")]
		[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinute")]
		private var lastMinuteAcademicLogo:Class;
		
		//[Embed(source="skins/ielts/assets/assets.swf", symbol="IELTSLogoLastMinuteGeneralTraining")]
		private var lastMinuteGeneralTrainingLogo:Class;
		
		// Constructor to let us initialise our states
		public function TitleView() {
			super();
			
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "zone", "account", "progress", "account" ], true);
		}
		
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		public function set productCode(value:uint):void {
			if (_productCode != value) {
				_productCode = value;
				dispatchEvent(new Event("productVersionChanged"));
			}
		}
		
		[Bindable(event="productVersionChanged")]
		public function get productVersionLogo():Class {
			switch (_productCode) {
				case 52:
					switch (_productVersion) {
						case "fullVersion":
							return fullVersionAcademicLogo;
						case "lastMinute":
							return lastMinuteAcademicLogo;
						case "tenHour":
							return tenHourAcademicLogo;
					}
					break;
				case 53:
					switch (_productVersion) {
						case "fullVersion":
							return fullVersionGeneralTrainingLogo;
						case "lastMinute":
							return lastMinuteGeneralTrainingLogo;
						case "tenHour":
							return tenHourGeneralTrainingLogo;
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
				case 52:
					switch (_productVersion) {
						case "fullVersion":
							return "Full version - Academic module";
						case "lastMinute":
							return "Last minute - Academic module";
						case "tenHour":
							return "Test drive - Academic module";
					}
					break;
				case 53:
					switch (_productVersion) {
						case "fullVersion":
							return "Full version - General Training module";
						case "lastMinute":
							return "Last minute - General Training module";
						case "tenHour":
							return "Test drive - General Training module";
					}
					break;
				default:
					// No product code set yet so don't set the text
					return null;
			}
			return null;
		}

		//public function set productVersion:String;
		
		public function showExercise(exerciseHref:Href):void {
			currentExerciseHref = exerciseHref;
			if (exerciseView) exerciseView.href = currentExerciseHref;
			invalidateSkinState();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case navBar:
					navBar.dataProvider = new ArrayCollection( [
						{ icon: homeIcon, label: "Home", data: "home" },
						{ icon: progressIcon, label: "My Progress", data: "progress" },
						{ icon: accountIcon, label: "My Account", data: "account" },
						{ icon: notepadIcon, label: "Notepad", data: "account" },
					] );
					
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
				case backToMenuButton:
					backToMenuButton.addEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
					break;
				case exerciseView:
					exerciseView.href = currentExerciseHref;
					break;
				case noticeLabel:
					var daysLeft:Number = DateUtil.dateDiff(new Date(), user.examDate, "d");
					var daysUnit:String = (daysLeft==1) ? "day" : "days";
					instance.text = daysLeft.toString() + " " + daysUnit + " left until your test.";
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
					backToMenuButton.removeEventListener(MouseEvent.CLICK, onBackToMenuButtonClick);
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
		
		/**
		 * The user has clicked the back button to get out of an exercise, so clear the current exercise
		 * 
		 * @param event
		 */
		protected function onBackToMenuButtonClick(event:MouseEvent):void {
			showExercise(null);
		}
		
	}
	
}