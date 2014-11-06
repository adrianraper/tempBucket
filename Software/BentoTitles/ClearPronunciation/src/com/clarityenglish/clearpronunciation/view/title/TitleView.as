package com.clarityenglish.clearpronunciation.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.clearpronunciation.view.exercise.ExerciseView;
	import com.clarityenglish.clearpronunciation.view.home.HomeView;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressView;
	import com.clarityenglish.rotterdam.view.title.ui.CancelableTabbedViewNavigator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.ViewNavigator;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	// This tells us that the skin has these states, but the view needs to know about them too
	[SkinState("home")]
	[SkinState("course")]
	[SkinState("progress")]
	public class TitleView extends BentoView {
		
		[SkinPart(required="true")]
		public var sectionNavigator:CancelableTabbedViewNavigator;
		
		[SkinPart]
		public var myCoursesViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var progressViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var cloudViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var helpViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var progressButton:Button;
		
		[SkinPart]
		public var settingsButton:Button;
		
		[SkinPart]
		public var phonemicChartButton:Button;
		
		[SkinPart]
		public var helpButton:Button;
		
		[SkinPart]
		public var logoutButton:Button;
		
		[SkinPart]
		public var backButton:Button;
		
		[SkinPart]
		public var productTitle:Label;
		
		private var _selectedNode:XML;
		
		public var settingsOpen:Signal = new Signal();
		public var logout:Signal = new Signal();
		
		public function set selectedNode(value:XML):void {
			_selectedNode = value;
			
			switch (_selectedNode.localName()) {
				case "menu":
				case "course":
				case "unit":
					currentState = "home";
					break;
				case "exercise":
					currentState = "exercise";
					break;
			}
		}
		
		public function TitleView() {
			super();
			
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "exercise", "progress", "settings" ], true);
			actionBarVisible = false;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case sectionNavigator:
					setNavStateMap(sectionNavigator, {
						home: { viewClass: HomeView },
						exercise: { viewClass: ExerciseView, stack: true }, // note that this is a CP ExerciseView which extends the default Bento one
						progress: { viewClass: ProgressView }
					});
					break;
				case progressButton:
					progressButton.addEventListener(MouseEvent.CLICK, onProgressClick);
					break;
				case settingsButton:
					settingsButton.addEventListener(MouseEvent.CLICK, onSettingsClick);
					break;
				case phonemicChartButton:
					phonemicChartButton.addEventListener(MouseEvent.CLICK, onPhonemicChartClick);
					break;
				case helpButton:
					helpButton.addEventListener(MouseEvent.CLICK, onHelpButtonClick);
					break;
				case backButton:
					backButton.label = copyProvider.getCopyForId("Back");
					backButton.addEventListener(MouseEvent.CLICK, onBackClick);
					break;
				case logoutButton:
					logoutButton.addEventListener(MouseEvent.CLICK, onLogoutClick);
					break;
			}
		}
		
		protected function onProgressClick(e:Event):void {
			sectionNavigator.selectedIndex = 1;
		}
		
		protected function onSettingsClick(event:MouseEvent):void {
			settingsOpen.dispatch();
		}
		
		protected function onPhonemicChartClick(event:Event):void {
			navigateToURL(new URLRequest(copyProvider.getCopyForId("phonemicChartURL")), "_blank");
		}
		
		protected function onHelpButtonClick(event:Event):void {
			navigateToURL(new URLRequest(copyProvider.getCopyForId("helpURL")), "_blank");
		}
		
		protected function onBackClick(event:Event):void {
			if (currentState == "progress")
				sectionNavigator.selectedIndex = 0;
		}
		
		protected function onLogoutClick(event:Event):void {
			logout.dispatch();
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}