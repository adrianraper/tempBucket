package com.clarityenglish.rotterdam.builder.view.title {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.builder.view.courseeditor.CourseEditorView;
	
	import flash.events.Event;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.ViewNavigator;
	
	public class TitleView extends BentoView {
		
		[SkinPart(required="true")]
		public var myCoursesViewNavigator:ViewNavigator;
		
		public var _selectedCourseXML:XML;
		
		[Bindable(event="courseSelected")]
		public function get selectedCourseXML():XML { return _selectedCourseXML; }
		public function set selectedCourseXML(value:XML):void {
			_selectedCourseXML = value;
			
			if (_selectedCourseXML) {
				if (ClassUtil.getClass(myCoursesViewNavigator.activeView) == CourseEditorView) {
					myCoursesViewNavigator.activeView.data = _selectedCourseXML;
				} else {
					myCoursesViewNavigator.pushView(CourseEditorView, _selectedCourseXML);
				}
			}
			
			/*if (_selectedCourseXML) {
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
			}*/
			
			dispatchEvent(new Event("courseSelected"));
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}
		
	}
}