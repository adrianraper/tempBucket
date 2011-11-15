package com.clarityenglish.ielts.view.progress.components {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	
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
		public var setMyDetailsDataProvider:XML;

		private var _course:XML;
		private var _courseChanged:Boolean;
		
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
				
				_courseChanged = false;
			}
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