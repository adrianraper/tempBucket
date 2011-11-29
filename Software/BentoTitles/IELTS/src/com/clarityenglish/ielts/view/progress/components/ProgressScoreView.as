package com.clarityenglish.ielts.view.progress.components {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.view.progress.ui.ProgressBarRenderer;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.HierarchicalData;
	import mx.collections.XMLListCollection;
	import mx.controls.AdvancedDataGrid;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.Label;
	
	public class ProgressScoreView extends BentoView {
		
		[SkinPart]
		public var writingCourseButton:Button;
		[SkinPart]
		public var speakingCourseButton:Button;
		[SkinPart]
		public var readingCourseButton:Button;
		[SkinPart]
		public var listeningCourseButton:Button;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBarRenderer;
		
		[SkinPart(required="true")]
		public var scoreDetailsDataGrid:DataGrid;
		
		[Bindable]
		public var tableDataProvider:XMLListCollection;

		[Bindable]
		public var summaryData:XML;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(XML);
		
		/**
		 * This setter is given a full XML that includes scores and coverage for the student.
		 * It then breaks this down into dataProviders for the components that will display this
		 *  
		 * @param XML value
		 * 
		 */
		public function set dataProvider(value:XML):void {
			// The data is for putting detailed records in a table
			// You want to get 
			//	a) the node for the current course (_course.@class)
			//	b) only records that have a score
			var buildXML:XMLList = value.course.(@["class"]=='writing').unit.exercise.score;
			// Then add the caption from the exercise to the score to make it easy to display in the grid
			// If the grid can do some sort of subheading, then I could do something similar with the unit name too
			for each (var score:XML in buildXML) {
				score.@caption = score.parent().@caption;
				score.@unitCaption = value.course.(@["class"]=='writing').groups.group.(@id==score.parent().@group).@caption;
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
				if (progressBar && course && summaryData) {
					progressBar.courseClass = course.@["class"];
					progressBar.data = {averageScore:summaryData.@averageScore};
				}
				
				_courseChanged = false;
			}
		}
		
		public function initCharts():void {
			
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case writingCourseButton:
				case readingCourseButton:
				case speakingCourseButton:
				case listeningCourseButton:
				//case examTipsCourseButton:
					instance.addEventListener(MouseEvent.CLICK, onCourseClick);
					// listen to a signal from button component here
					break;
				case scoreDetailsDataGrid:
					break;
				
				case progressBar:
					//progressBar.data = {averageScore:49};
					//progressBar.courseClass = 'reading';
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
		}
		
		/**
		 * The user has clicked a course button 
		 * 
		 * @param event
		 */
		protected function onCourseClick(event:MouseEvent):void {

			var matchingCourses:XMLList = menu.course.(@["class"] == event.target.label.toLowerCase());
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a course with class {0}", event.target.label.toLowerCase());
			} else {
				course = matchingCourses[0] as XML;
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		}

	}
	
}