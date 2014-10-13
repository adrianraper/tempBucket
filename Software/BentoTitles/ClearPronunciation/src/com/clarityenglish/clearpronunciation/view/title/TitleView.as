package com.clarityenglish.clearpronunciation.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.clearpronunciation.view.course.CourseView;
	import com.clarityenglish.clearpronunciation.view.home.HomeView;
	import com.clarityenglish.clearpronunciation.view.progress.ProgressView;
	import com.clarityenglish.rotterdam.view.schedule.ScheduleView;
	import com.clarityenglish.rotterdam.view.settings.SettingsView;
	import com.clarityenglish.rotterdam.view.title.ui.CancelableTabbedViewNavigator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.ViewNavigator;
	import spark.events.IndexChangeEvent;
	
	// This tells us that the skin has these states, but the view needs to know about them too
	[SkinState("home")]
	[SkinState("course")]
	[SkinState("progress")] // optional
	//[SkinState("filemanager")] // optional
	
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
		public var settingsButton:Button;
		
		[SkinPart]
		public var logoutButton:Button;
		
		[SkinPart]
		public var backButton:Button;
		
		[SkinPart]
		public var productTitle:Label;
		
		public var dirtyWarningShow:Signal = new Signal(Function);
		public var settingsOpen:Signal = new Signal();
		public var logout:Signal = new Signal();
		public var progressTransform:Signal = new Signal();
		
		public function TitleView() {
			super();
			
			// The first one listed will be the default
			StateUtil.addStates(this, [ "home", "course", "progress", "settings", "schedule", "progress" ], true);
			this.actionBarVisible = false;
		}
		
		public function showCourseView():void {
			currentState = "course";
		}
		
		public function showSettingsView():void {
			currentState = "settings";
		}
		
		public function showScheduleView():void {
			currentState = "schedule";
		}
		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case sectionNavigator:
					setNavStateMap(sectionNavigator, {
						home: { viewClass: HomeView },
						course: { viewClass: CourseView, stack: true },
						settings: {viewClass: SettingsView, stack: true},
						schedule: {viewClass: ScheduleView, stack:true},
						// TODO: this really should be here, but there is some bug whereby the framework is straight away changing back from progress to course, so leave for now
						progress: { viewClass: ProgressView, stack:true }
					});
					// gh#83
					sectionNavigator.changeConfirmFunction = function(next:Function):void {
						dirtyWarningShow.dispatch(next); // If there is no dirty warning this will cause next() to be executed immediately
					};
					sectionNavigator.addEventListener(IndexChangeEvent.CHANGE, onNavigatorIndexChange);
					break;
				case progressViewNavigator:
					//progressViewNavigator.label = copyProvider.getCopyForId("progressViewNavigator");
					break;
				case cloudViewNavigator:
					cloudViewNavigator.label = copyProvider.getCopyForId("cloudViewNavigator");
					break;
				case helpViewNavigator:
					helpViewNavigator.label = copyProvider.getCopyForId("helpViewNavigator");
					break;
				case settingsButton:
					//settingsButton.label = copyProvider.getCopyForId("settingsButton");
					settingsButton.addEventListener(MouseEvent.CLICK, onSettingsClick);
					break;
				case logoutButton:
					// gh#217
					//instance.label = copyProvider.getCopyForId("LogOut");
					instance.addEventListener(MouseEvent.CLICK, onLogoutClick);
					break;
				case backButton:
					backButton.label = copyProvider.getCopyForId("Back");
					backButton.addEventListener(MouseEvent.CLICK, onBackClick);
					break;
				case productTitle:
					instance.text = copyProvider.getCopyForId("applicationTitle");
					break;
			}
		}
		
		protected function onSettingsClick(event:MouseEvent):void {
			settingsOpen.dispatch();
		}
		
		// gh#217
		protected function onLogoutClick(event:Event):void {
			logout.dispatch();
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
		protected function onBackClick(evnet:Event):void {
			if (currentState == "progress")
				sectionNavigator.selectedIndex = 0;
		}
		
		protected function onNavigatorIndexChange(event:Event):void {
			if (sectionNavigator.selectedIndex == 1) {
				sectionNavigator.tabBar.visible = false;
				progressTransform.dispatch();
			}
				
		}
	}
}