package com.clarityenglish.rotterdam.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.course.CourseView;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	import com.clarityenglish.rotterdam.view.title.ui.CancelableTabbedViewNavigator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	
	import org.davekeen.util.ClassUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.ViewNavigator;
	import spark.events.IndexChangeEvent;
	
	public class TitleView extends BentoView {
		
		[SkinPart(required="true")]
		public var tabbedViewNavigator:CancelableTabbedViewNavigator;
		
		[SkinPart(required="true")]
		public var myCoursesViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var cloudViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var helpViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var logoutButton:spark.components.Button;
		
		public var dirtyWarningShow:Signal = new Signal(Function);
		
		public var logOut:Signal = new Signal();
		
		public function showCourseView():void {
			if (ClassUtil.getClass(myCoursesViewNavigator.activeView) == CourseSelectorView) {
				myCoursesViewNavigator.pushView(CourseView);
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case tabbedViewNavigator:
					// gh#83
					tabbedViewNavigator.changeConfirmFunction = function(next:Function):void {
						dirtyWarningShow.dispatch(next); // If there is no dirty warning this will cause next() to be executed immediately
					};
					break;
				case myCoursesViewNavigator:
					// gh#197
					myCoursesViewNavigator.addEventListener("viewChangeComplete", function(e:Event):void { invalidateSkinState(); });
					myCoursesViewNavigator.label = copyProvider.getCopyForId("myCoursesViewNavigator");
					break;
				case cloudViewNavigator:
					cloudViewNavigator.label = copyProvider.getCopyForId("cloudViewNavigator");
					break;
				case helpViewNavigator:
					helpViewNavigator.label = copyProvider.getCopyForId("helpViewNavigator");
					break;
				case logoutButton:
					//gh#217
					logoutButton.addEventListener(MouseEvent.CLICK, onLogOutClick);
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			// gh#197
			return (myCoursesViewNavigator && ClassUtil.getClass(myCoursesViewNavigator.activeView) == CourseSelectorView && skin.hasState("course_selector"))
				? "course_selector"
				: super.getCurrentSkinState();
		}
		
		//gh#217
		protected function onLogOutClick(event:Event):void {
			logOut.dispatch();
		}
		
	}
}