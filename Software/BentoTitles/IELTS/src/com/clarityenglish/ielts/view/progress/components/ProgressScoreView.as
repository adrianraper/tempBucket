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
	
	public class ProgressScoreView extends BentoView {
		
		[SkinPart(required="true")]
		public var progressCourseBar:ProgressCourseBarComponent;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart(required="true")]
		public var scoreDetailsDataGrid:DataGrid;
		
		[Bindable]
		public var tableDataProvider:XMLListCollection;

		public var chartDataProvider:XML;
		
		public var _summaryData:XML;
		public var _detailData:XML;
		
		//private var _course:XML;
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		private var _dataChanged:Boolean;
		
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
			_courseChanged = true;
			invalidateProperties();
		}
		[Bindable]
		public function get courseClass():String {
			return _courseClass;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			if (_courseChanged || _dataChanged) {
				
				// Update the components of the view that change their data
				if (progressBar && courseClass && summaryDataProvider) {
					//progressBar.courseClass = course.@["class"];
					progressBar.courseClass = courseClass;
					// BUG. For this view I want to show coverage summary. For score view I want average score.
					progressBar.type = "score";
					progressBar.data = {dataProvider:summaryDataProvider};
				}
				if (courseClass && detailDataProvider) {
					focusCourse(courseClass);
					//selectCourseData(course.@["class"]);
				}
				
				_courseChanged = _dataChanged = false;
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

				// Use one of the 'charts' to initialise for all
				case scoreDetailsDataGrid:
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
				var buildXML:XMLList = detailDataProvider.course.(@["class"]==courseClass).unit.exercise.score;
				// Then add the caption from the exercise to the score to make it easy to display in the grid
				// If the grid can do some sort of subheading, then I could do something similar with the unit name too
				for each (var score:XML in buildXML) {
					score.@caption = score.parent().@caption;
					score.@unitCaption = detailDataProvider.course.(@["class"]==courseClass).groups.group.(@id==score.parent().@group).@caption;
				}
				tableDataProvider = new XMLListCollection(buildXML);
			}			
		}
		
		/**
		 * The user has changed the course to be displayed
		 * 
		 * @param String course class name
		 */
		public function onCourseSelect(newCourseClass:String):void {
			
			courseSelect.dispatch(newCourseClass);
			
		}
	}
	
}