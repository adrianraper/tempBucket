package com.clarityenglish.ielts.view.progress.components {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	
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
		
		[SkinPart(required="true")]
		public var writingCourse:Button;
		
		[SkinPart(required="true")]
		public var readingCourse:Button;
		
		[SkinPart(required="true")]
		public var speakingCourse:Button;
		
		[SkinPart(required="true")]
		public var listeningCourse:Button;
		
		[SkinPart(required="true")]
		public var examTipsCourse:Button;
		
		[SkinPart(required="true")]
		public var scoreDetails:DataGrid;
		
		[Bindable]
		public var tableDataProvider:XMLListCollection;

		private var _course:XML;
		private var _courseChanged:Boolean;
		
		/**
		 * This setter is given a full XML that includes scores and coverage for the student.
		 * It then breaks this down into dataProviders for the components that will display this
		 *  
		 * @param XML value
		 * 
		 */
		public function set dataProvider(value:XML):void {
			// One set of data is for putting detailed records in a table
			// You want to get 
			//	a) the node for the current course (_course.@caption)
			//	b) only records that have a score
			var buildXML:XMLList = value.course.(@["class"]=='writing').unit.exercise.score;
			// Then add the caption from the exercise to the score to make it easy to display in the grid
			// If the grid can do sort of subheading, then I could do something similar with the unit name too
			for each (var score:XML in buildXML) {
				score.@caption = score.parent().@caption;
				score.@unitCaption = value.course.(@["class"]=='writing').groups.group.(@id==score.parent().@group).@caption;
			}
			tableDataProvider = new XMLListCollection(buildXML);
			
			// Another set of data is for showing coverage
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
		
		protected override function commitProperties():void {
			super.commitProperties();
			if (_courseChanged) {
				
				// Display the data for this course
				// ????
				_courseChanged = false;
			}
		}
		
		public function initCharts():void {
			
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case writingCourse:
				case readingCourse:
				case speakingCourse:
				case listeningCourse:
				case examTipsCourse:
					break;
				case scoreDetails:
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
			// Whilst we are using fake buttons
			var matchingCourses:XMLList = menu.course.(@caption == event.target.label);
			//var matchingCourses:XMLList = menu.course.(@caption == event.target.getStyle("title"));
			//var matchingCourses:XMLList = menu.course.(@caption == 'Reading');
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a course with caption {0}", event.target.label);
				//log.error("Unable to find a course with caption {0}", event.target.getStyle("title"));
			} else {
				course = matchingCourses[0] as XML;
			}
		}

	}
	
}