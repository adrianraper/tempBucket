package com.clarityenglish.ielts.view.progress.components {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.view.progress.ui.ProgressBarRenderer;
	import com.clarityenglish.ielts.view.progress.ui.ProgressCourseBarComponent;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.HierarchicalData;
	import mx.collections.XMLListCollection;
	import mx.controls.AdvancedDataGrid;
	
	import org.osflash.signals.Signal;
	
	import skins.ielts.progress.ProgressCourseBarSkin;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	
	public class ProgressCoverageView extends BentoView {
		
		[SkinPart(required="true")]
		public var progressCourseBar:ProgressCourseBarComponent;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart(required="true")]
		public var practiceZoneCoverage:Group;
		
		[SkinPart(required="true")]
		public var questionZoneCoverage:Group;
		
		[SkinPart(required="true")]
		public var adviceZoneCoverage:Group;
		
		[SkinPart(required="true")]
		public var examPracticeCoverage:Group;
		
		[Bindable]
		public var practiceZoneDataProvider:XMLList;

		[Bindable]
		public var questionZoneDataProvider:XMLListCollection;
		
		[Bindable]
		public var adviceZoneDataProvider:XMLListCollection;
		
		[Bindable]
		public var examPracticeDataProvider:XMLListCollection;
		
		// Internal store for the full dataProvider
		public var _summaryData:XML;
		public var _detailData:XML;
		
		// TODO. Highlight the last exercise done somehow
		public var bookmark:XML;
		
		//private var _course:XML;
		private var _courseClass:String;
		private var _courseClassChanged:Boolean;
		private var _dataChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(String);
		
		/**
		 * This setter is given a full XML that includes scores and coverage for the student.
		 * It then breaks this down into dataProviders for the components that will display this
		 *  
		 * @param XML value
		 * 
		 */
		[Bindable]
		public function set detailDataProvider(value:XML):void {
			_detailData = value;
			_dataChanged = true;
			invalidateProperties();
		}
		public function get detailDataProvider():XML {
			return _detailData;
		}
		public function set summaryDataProvider(value:XML):void {
			_summaryData = value;
		}
		public function get summaryDataProvider():XML {
			return _summaryData;
		}
		
		/**
		 * This can be called from outside the view to make the view display a different course
		 * 
		 * @param XML A course node from the menu
		 * 
		 */
		public function set courseClass(value:String):void {
			_courseClass = value;
			_courseClassChanged = true;
			invalidateProperties();
		}
		[Bindable]
		public function get courseClass():String {
			return _courseClass;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			if (_courseClassChanged || _dataChanged) {
				
				// Update the components of the view that change their data
				if (progressBar && courseClass && summaryDataProvider) {
					//progressBar.courseClass = course.@["class"];
					progressBar.courseClass = courseClass;
					// BUG. For this view I want to show coverage summary. For score view I want average score.
					progressBar.data = {dataProvider:summaryDataProvider};
				}
				if (courseClass && detailDataProvider) {
					focusCourse(courseClass);
					//selectCourseData(course.@["class"]);
				}
				
				_courseClassChanged = _dataChanged = false;
			}
		}
		
		/**
		 * If there are any settings that the 'charts' need
		 * 
		 */
		public function initCharts():void {
			
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				
				case progressCourseBar:
					instance.courseSelect.add(onCourseSelect);
					break;

				// Use one of the 'charts' to initialise for all
				case practiceZoneCoverage:
					initCharts();
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case progressCourseBar:
					instance.courseSelect.remove(onCourseSelect);
					break;
			}
			
		}
		/**
		 * This method uses the current course class to take the full dataProvider and 
		 * split it for each component in the view 
		 * @param String courseClass
		 * 
		 */
		private function focusCourse(courseClass:String = null):void {
			if (!courseClass)
				courseClass = _courseClass;

			if (detailDataProvider) {
				for each (var unitNode:XML in detailDataProvider.course.(@["class"]==courseClass).unit) {
					switch (unitNode.@["class"].toString()) {
						case 'practice-zone':
							// Because we need to get captions from the group node, send the whole
							// course node as the practice zone data provider
							//practiceZoneDataProvider = new XMLList(unitNode.parent());
							practiceZoneDataProvider = new XMLList(unitNode.exercise);
							break;
						case 'question-zone':
							questionZoneDataProvider = new XMLListCollection(unitNode.exercise);
							break;
						case 'advice-zone':
							adviceZoneDataProvider = new XMLListCollection(unitNode.exercise);
							break;
						case 'exam-practice':
							examPracticeDataProvider = new XMLListCollection(unitNode.exercise);
							break;
					}
				}
			}			
		}
		
		/**
		 * The user has changed the course to be displayed
		 * 
		 * @param String course class name
		 */
		public function onCourseSelect(newCourseClass:String):void {

			courseClass = newCourseClass;
			
		}

	}
	
}