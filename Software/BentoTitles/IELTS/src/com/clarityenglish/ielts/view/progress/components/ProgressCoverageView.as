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
	import spark.components.Label;
	import spark.components.List;
	
	public class ProgressCoverageView extends BentoView {
		
		[SkinPart(required="true")]
		public var progressCourseBar:ProgressCourseBarComponent;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart(required="true")]
		public var practiceZoneList:List;
		
		[SkinPart(required="true")]
		public var questionZoneList:List;
		
		[SkinPart(required="true")]
		public var adviceZoneList:List;
		
		[SkinPart(required="true")]
		public var examPracticeZoneList:List;
		
		[Bindable]
		public var practiceZoneDataProvider:XMLListCollection;

		[Bindable]
		public var questionZoneDataProvider:XMLListCollection;
		
		[Bindable]
		public var adviceZoneDataProvider:XMLListCollection;
		
		[Bindable]
		public var examPracticeDataProvider:XMLListCollection;
		
		public var _summaryData:XML;
		public var _detailData:XML;
		
		// TODO. Highlight the last exercise done somehow
		public var bookmark:XML;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(String);
		
		/**
		 * This setter is given a full XML that includes scores and coverage for the student.
		 * It then breaks this down into dataProviders for the components that will display this
		 *  
		 * @param XML value
		 * 
		 */
		public function set detailDataProvider(value:XML):void {
			_detailData = value;
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
		
		private function selectCourseData(courseClass:String):void {
			// The data is for putting detailed records in a set of lists
			// You want to get 
			//	a) the node for the current course (_course.@class)
			//	b) only records for the current unit
			for each (var unitNode:XML in detailDataProvider.course.(@["class"]==courseClass).unit) {
				switch (unitNode.@["class"]) {
					case 'practice-zone':
						practiceZoneDataProvider = new XMLListCollection(unitNode.exercise);
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
		/**
		 * This can be called from outside the view to make the view display a different course
		 * 
		 * @param XML A course node from the menu
		 * 
		 */
		public function set course(value:XML):void {
			_course = value;
			_courseChanged = true;
			invalidateProperties();
		}
		public function get course():XML {
			return _course;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			if (_courseChanged) {
				
				// Update the components of the view that change their data
				if (progressBar && course && summaryDataProvider) {
					progressBar.courseClass = course.@["class"];
					// BUG. For this view I want to show coverage summary. For score view I want average score.
					progressBar.data = {dataProvider:summaryDataProvider};
				}
				_courseChanged = false;
			}
		}
		
		public function initCharts():void {
			
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				
				case progressCourseBar:
					instance.courseSelect.add(onCourseSelect);
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
		 * The user has changed the course to be displayed
		 * 
		 * @param String course class name
		 */
		public function onCourseSelect(courseClass:String):void {

			//var matchingCourses:XMLList = menu.course.(@["class"] == event.target.label.toLowerCase());
			var matchingCourses:XMLList = menu.course.(@["class"] == courseClass);
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a course with class {0}", courseClass);
			} else {
				course = matchingCourses[0] as XML;
				courseSelect.dispatch(courseClass);
			}
		}

	}
	
}