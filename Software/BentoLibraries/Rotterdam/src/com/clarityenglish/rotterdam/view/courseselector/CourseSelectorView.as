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
		public var selectCourseButton:Button;
		
		[SkinPart]
		public var deleteCourseButton:Button;
		
		public var createCourse:Signal = new Signal(Course);
		public var selectCourse:Signal = new Signal(XML);
		public var deleteCourse:Signal = new Signal(XML);
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			courseList.dataProvider = new XMLListCollection(xhtml.courses.course);
			
			// Auto-select a course for testing
			//selectCourse.dispatch(courseList.dataProvider.getItemAt(0));
		}

		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case createCourseButton:
					createCourseButton.addEventListener(MouseEvent.CLICK, onCreateCourse);
					break;
				case selectCourseButton:
					selectCourseButton.addEventListener(MouseEvent.CLICK, onSelectCourse);
					break;
				case deleteCourseButton:
					deleteCourseButton.addEventListener(MouseEvent.CLICK, onDeleteCourse);
					break;
			}
		}
		
		protected function onCreateCourse(event:MouseEvent):void {
			// TODO: need to have the designs to know exactly how this will work but for now just use a random name
			var course:Course = new Course();
			course.caption = "Course " + new Date().time;
			
			createCourse.dispatch(course);
		}
		
		protected function onSelectCourse(event:MouseEvent):void {
			if (courseList.selectedItem)
				selectCourse.dispatch(courseList.selectedItem);
		}
		
		protected function onDeleteCourse(event:MouseEvent):void {
			if (courseList.selectedItem)
				deleteCourse.dispatch(courseList.selectedItem);
		}
		
	}
}