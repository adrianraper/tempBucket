package com.clarityenglish.bento.view.progress.ui {
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import mx.collections.ArrayList;
	
	import org.davekeen.util.StringUtils;
	
	import spark.components.ButtonBar;
	
	public class ProgressCourseButtonBar extends ButtonBar {
		
		private var _copyProvider:CopyProvider;
		
		private var _courses:XMLList;
		private var _coursesChanged:Boolean;
		
		private var _courseClass:String;
		private var _courseClassChanged:Boolean;
		
		public function ProgressCourseButtonBar() {
			super();
			
			focusEnabled = false;
			requireSelection = true;
		}
		
		public function set courses(value:XMLList):void {
			_courses = value;
			_coursesChanged = true;
			invalidateProperties();
		}
		
		public function set copyProvider(value:CopyProvider):void {
			_copyProvider = value;
			invalidateProperties();
		}
		
		public function set courseClass(value:String):void {
			_courseClass = value;
			_courseClassChanged = true;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_coursesChanged && _copyProvider) {
				// Dynamically build the button bar from the courses.  Two conventions are being used here:
				// - the language xml file has a capitalized courseClass for the course name (e.g. reading => "Reading")
				// - the CSS contains an embedded small icon in {courseClass}IconSmall (e.g. reading => readingIconSmall)
				var data:Array = [];
				for each (var course:XML in _courses) {
					var courseClass:String = course.@["class"].toString();
					data.push( { courseClass: courseClass, label: _copyProvider.getCopyForId(StringUtils.capitalize(courseClass)), icon: getStyle(courseClass + "IconSmall") } );
				}
				
				dataProvider = new ArrayList(data);
				
				_coursesChanged = false;
			}
			
			if (_courseClassChanged && dataProvider) {
				// If the course class has changed then go through and make sure the correct item is selected
				for (var n:uint = 0; n < dataProvider.length; n++) {
					if (dataProvider.getItemAt(n).courseClass == _courseClass) {
						callLater(function():void { // gh#180
							selectedIndex = n;
						});
						break;
					}
				}
				
				_courseClassChanged = false;
			}
		}
		
	}
}
