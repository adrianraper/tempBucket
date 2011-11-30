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
			// The data is for putting detailed records in a table
			// You want to get 
			//	a) the node for the current course (_course.@class)
			//	b) only records that have a score
			var buildXML:XMLList = detailDataProvider.course.(@["class"]==courseClass).unit.exercise.score;
			// Then add the caption from the exercise to the score to make it easy to display in the grid
			// If the grid can do some sort of subheading, then I could do something similar with the unit name too
			for each (var score:XML in buildXML) {
				score.@caption = score.parent().@caption;
				score.@unitCaption = detailDataProvider.course.(@["class"]==courseClass).groups.group.(@id==score.parent().@group).@caption;
			}
			tableDataProvider = new XMLListCollection(buildXML);
			
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
					progressBar.data = {dataProvider:summaryDataProvider};
				}
				// BUG. First time in, detailDataProvider is likely to not be set
				// This is where having bindable variables would help.
				if (scoreDetailsDataGrid && course && detailDataProvider) {
					selectCourseData(course.@["class"]);
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