package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	
	public class UnitEditorView extends BentoView {
		
		/*public var _selectedCourseXML:XML;
		
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
			
			dispatchEvent(new Event("courseSelected"));
		}*/
		
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