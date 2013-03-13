package com.clarityenglish.rotterdam.view.courseselector {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseDeleteEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
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
					courseList.dataGroup.addEventListener(MouseEvent.DOUBLE_CLICK, onSelectCourse);
					courseList.addEventListener(CourseDeleteEvent.COURSE_DELETE, onDeleteCourse);
					break;
			}
		}
		
		protected function onCreateCourse(event:MouseEvent):void {
			createCourse.dispatch();
		}
		
		protected function onSelectCourse(event:MouseEvent):void {
			if (courseList.selectedItem)
				selectCourse.dispatch(courseList.selectedItem);
		}
		
		protected function onDeleteCourse(event:CourseDeleteEvent):void {
			var alert:Alert = Alert.show("Are you sure", "Delete", Alert.YES | Alert.NO, this, alterListener);
			alert.styleName = "markingTitleWindow";
			PopUpManager.centerPopUp (alert);
		}
		
		private function alterListener(event:CloseEvent):void {
			if (event.detail == Alert.YES) {
				if (courseList.selectedItem)
					deleteCourse.dispatch(courseList.selectedItem);
			}
		}
		
	}
}