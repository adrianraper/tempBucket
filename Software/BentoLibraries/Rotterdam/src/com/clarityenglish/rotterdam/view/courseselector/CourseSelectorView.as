package com.clarityenglish.rotterdam.view.courseselector {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.vo.Course;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.List;
	
	public class CourseSelectorView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseList:List;
		
		[SkinPart]
		public var createCourseButton:Button;
		
		[SkinPart]
		public var editCourseButton:Button;
		
		public var createCourse:Signal = new Signal(Course);
		public var editCourse:Signal = new Signal(XML);
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			courseList.dataProvider = new XMLListCollection(xhtml.courses.course);
			
			// Go straight into the editor for testing
			editCourse.dispatch(courseList.dataProvider.getItemAt(0));
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case createCourseButton:
					createCourseButton.addEventListener(MouseEvent.CLICK, onCreateCourse);
					break;
				case editCourseButton:
					editCourseButton.addEventListener(MouseEvent.CLICK, onEditCourse);
					break;
			}
		}
		
		protected function onCreateCourse(event:MouseEvent):void {
			// TODO: need to have the designs to know exactly how this will work but for now just use a random name
			var course:Course = new Course();
			course.caption = "Course " + new Date().time;
			
			createCourse.dispatch(course);
		}
		
		protected function onEditCourse(event:MouseEvent):void {
			if (courseList.selectedItem)
				editCourse.dispatch(courseList.selectedItem);
		}
		
	}
}