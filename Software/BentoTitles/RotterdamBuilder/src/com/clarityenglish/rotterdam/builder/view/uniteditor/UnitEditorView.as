package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import mx.collections.XMLListCollection;
	
	import spark.components.List;
	
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
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					// Some test unit
					var xml:XML =
						<units>
							<text height="100" column="0" span="1" label="Widget 1"/>
							<text height="130" column="1" span="2" label="Widget 2"/>
							<text height="110" column="0" span="2" label="Widget 3"/>
							<text height="100" column="0" span="1" label="Widget 4"/>
							<text height="100" column="2" span="1" label="Widget 5"/>
							<text height="80" column="2" span="1" label="Widget 6"/>
							<text height="115" column="0" span="3" label="Widget 7"/>
							<text height="130" column="0" span="1" label="Widget 8"/>
							<text height="90" column="0" span="1" label="Widget 9"/>
							<text height="300" column="0" span="3" label="Widget 10"/>
						</units>;
					unitList.dataProvider = new XMLListCollection(xml..text);
					break;
			}
		}
		
	}
}