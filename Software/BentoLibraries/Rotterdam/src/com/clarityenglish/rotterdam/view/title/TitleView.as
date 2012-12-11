package com.clarityenglish.rotterdam.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.course.CourseView;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	import com.clarityenglish.rotterdam.view.title.ui.CancelableTabbedViewNavigator;
	
	import org.davekeen.util.ClassUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.ViewNavigator;
	
	public class TitleView extends BentoView {
		
		[SkinPart(required="true")]
		public var tabbedViewNavigator:CancelableTabbedViewNavigator;
		
		[SkinPart(required="true")]
		public var myCoursesViewNavigator:ViewNavigator;
		
		public var enableSaveWarning:Boolean;
		
		public var saveWarningShow:Signal = new Signal(Function); 
		
		public function showCourseView():void {
			if (ClassUtil.getClass(myCoursesViewNavigator.activeView) == CourseSelectorView) {
				myCoursesViewNavigator.pushView(CourseView);
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case tabbedViewNavigator:
					// GH #83
					tabbedViewNavigator.changeConfirmFunction = function(next:Function):void {
						if (enableSaveWarning) {
							saveWarningShow.dispatch(next);
						} else {
							next();
						}
					};
					break;
			}
		}
		
	}
}