package com.clarityenglish.rotterdam.view.courseselector {
	import com.clarityenglish.bento.view.base.BentoView;
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
		public var deleteCourseButton:Button;
		
		public var createCourse:Signal = new Signal();
		public var selectCourse:Signal = new Signal(XML);
		public var deleteCourse:Signal = new Signal(XML);
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			courseList.dataProvider = new XMLListCollection(xhtml.courses.course);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case createCourseButton:
					createCourseButton.addEventListener(MouseEvent.CLICK, onCreateCourse);
					break;
				case courseList:
					courseList.dataGroup.doubleClickEnabled = true;
					courseList.dataGroup.addEventListener(MouseEvent.CLICK, onSelectCourse);
					break;
			}
		}
		
		protected function onCreateCourse(event:MouseEvent):void {
			createCourse.dispatch();
		}
		
		protected function onSelectCourse(event:MouseEvent):void {
			trace("courseList selectedItem: "+ courseList.selectedItem);
			if (courseList.selectedItem)
				selectCourse.dispatch(courseList.selectedItem);
		}
		
		public function deleteCourseClick():void {
			if (courseList.selectedItem)
				deleteCourse.dispatch(courseList.selectedItem);
		}
		
	}
}