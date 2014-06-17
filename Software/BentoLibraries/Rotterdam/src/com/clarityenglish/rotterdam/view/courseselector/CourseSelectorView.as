package com.clarityenglish.rotterdam.view.courseselector {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseDeleteEvent;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseExportEvent;
	import com.clarityenglish.rotterdam.view.courseselector.events.CourseSelectEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import org.osflash.signals.Signal;
	
	import spark.components.BusyIndicator;
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.List;
	
	import ws.tink.spark.controls.Alert;
	
	public class CourseSelectorView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseList:List;
		
		[SkinPart]
		public var createCourseButton:Button;
		
		// gh#233
		//[SkinPart]
		//public var deleteCourseButton:Button;
		
		[SkinPart]
		public var courseListTitleLabel:Label;
		
		[SkinPart]
		public var busyIndicator:BusyIndicator;
		
		public var createCourse:Signal = new Signal();
		public var selectCourse:Signal = new Signal(XML);
		public var deleteCourse:Signal = new Signal(XML);
		public var exportCourse:Signal = new Signal(XML);
		
		private var isCourseListCreated:Boolean;
		
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
					createCourseButton.label = copyProvider.getCopyForId("createCourseButton");
					break;
				case courseList:
					courseList.dataGroup.doubleClickEnabled = true;
					courseList.addEventListener(CourseSelectEvent.COURSE_SELECT, onSelectCourse);
					courseList.addEventListener(CourseDeleteEvent.COURSE_DELETE, onDeleteCourse);
					courseList.addEventListener(CourseExportEvent.COURSE_EXPORT, onExportCourse);
					courseList.addEventListener(FlexEvent.UPDATE_COMPLETE, onCourseListUpdateComplete);
					break;
				case courseListTitleLabel:
					courseListTitleLabel.text = copyProvider.getCopyForId("courseListTitleLabel");
					break;
			}
		}
		
		protected function onCreateCourse(event:MouseEvent):void {
			createCourse.dispatch();
		}
		
		protected function onExportCourse(event:CourseExportEvent):void {
			exportCourse.dispatch(event.course);
		}
		
		public function onSelectCourse(event:CourseSelectEvent):void {
			if (courseList.selectedItem)
				selectCourse.dispatch(courseList.selectedItem);
		}
		
		protected function onDeleteCourse(event:CourseDeleteEvent):void {
			var alertMessage:String = copyProvider.getCopyForId("deleteCourseWarning");
			var alertTitle:String = copyProvider.getCopyForId("noUndoWarning");
			var alertYes:String = copyProvider.getCopyForId("yesButton");
			var alertNo:String = copyProvider.getCopyForId("noButton");
			Alert.show(alertMessage, alertTitle, Vector.<String>([ alertYes, alertNo ]), this, function(closeEvent:CloseEvent):void {
				if (closeEvent.detail == 0)
					deleteCourse.dispatch(event.course);
			});
		}
		
		// Add busy indicator before course list display in screen
		protected function onCourseListUpdateComplete(event:FlexEvent):void {
			if (isCourseListCreated && busyIndicator) {
				busyIndicator.visible = false;
				isCourseListCreated = false;
			} else {
				isCourseListCreated = true;
			}
		}
	}
}