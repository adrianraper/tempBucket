package com.clarityenglish.rotterdam.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ProgressView;
	import com.clarityenglish.rotterdam.view.course.CourseView;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	import com.clarityenglish.rotterdam.view.schedule.ScheduleView;
	import com.clarityenglish.rotterdam.view.settings.SettingsView;
	import com.clarityenglish.components.CancelableTabbedViewNavigator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.StateChangeEvent;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
    import spark.components.Group;
    import spark.components.Label;
	import spark.components.ViewNavigator;
	
	// This tells us that the skin has these states, but the view needs to know about them too
	[SkinState("course_selector")]
	[SkinState("course")]
	[SkinState("progress")] // optional
	[SkinState("filemanager")] // optional
	[SkinState("settings")] // optional
	[SkinState("schedule")] // optional

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
		public var logoutButton:Button;
		
		[SkinPart]
		public var backButton:Button;
		
		[SkinPart]
		public var productTitle:Label;

        [SkinPart]
        public var coverTabBarDisabler:Group;

        public var dirtyWarningShow:Signal = new Signal(Function);
		
		public var logout:Signal = new Signal();
		
		public function TitleView() {
			super();
			
			// The first one listed will be the default
			StateUtil.addStates(this, [ "course_selector", "course", "progress", "settings", "schedule" ], true);
			// gh#745
			this.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onStateChange);
		}
		
		public function showCourseView(event:Event=null):void {
			currentState = "course";
		}
		
		public function showSettingsView():void {
			currentState = "settings";
		}
		
		public function showScheduleView():void {
			currentState = "schedule";
		}
		
		public function showProgressView():void {
			currentState = "progress";
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case sectionNavigator:
					setNavStateMap(sectionNavigator, {
						course_selector: { viewClass: CourseSelectorView },
						course: { viewClass: CourseView, stack: true },
						settings: { viewClass: SettingsView, stack: true },
						schedule: { viewClass: ScheduleView, stack:true }
						// TODO: this really should be here, but there is some bug whereby the framework is straight away changing back from progress to course, so leave for now
						//progress: { viewClass: ProgressView }
					});
					// gh#83
					sectionNavigator.changeConfirmFunction = function(next:Function):void {
						dirtyWarningShow.dispatch(next); // If there is no dirty warning this will cause next() to be executed immediately
					};
					break;
				case myCoursesViewNavigator:
					myCoursesViewNavigator.label = copyProvider.getCopyForId("myCoursesViewNavigator");
					break;
				case progressViewNavigator:
					progressViewNavigator.label = copyProvider.getCopyForId("progressViewNavigator");
					break;
				case cloudViewNavigator:
					cloudViewNavigator.label = copyProvider.getCopyForId("cloudViewNavigator");
					break;
				case helpViewNavigator:
					helpViewNavigator.label = copyProvider.getCopyForId("helpViewNavigator");
					break;
				case logoutButton:
					// gh#217
					instance.label = copyProvider.getCopyForId("LogOut");
					instance.addEventListener(MouseEvent.CLICK, onLogoutClick);
					break;
                case backButton:
                    // gh#217
                    instance.label = copyProvider.getCopyForId("doneButton");
                    instance.addEventListener(MouseEvent.CLICK, onBackToCourseSelector);
                    break;
				case productTitle:
					instance.text = copyProvider.getCopyForId("applicationTitle");
					break;
                case coverTabBarDisabler:
                    instance.addEventListener(MouseEvent.CLICK, doNothing);
                    break;
            }
		}
		
		// gh#745
		protected function onStateChange(event:StateChangeEvent):void {
		}

        protected function onBackToCourseSelector(event:Event=null):void {
            dirtyWarningShow.dispatch(function():void {myCoursesViewNavigator.popView()});
        }
		
		// gh#217
		protected function onLogoutClick(event:Event):void {
			logout.dispatch();
		}

        // Stops components that have been hidden from picking up mouse events
        protected function doNothing(event:MouseEvent):void {}

        protected override function getCurrentSkinState():String {
			return currentState;
		}		
	}
}