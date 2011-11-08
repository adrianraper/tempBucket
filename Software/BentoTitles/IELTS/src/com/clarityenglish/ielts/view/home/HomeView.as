package com.clarityenglish.ielts.view.home {
	import com.anychart.AnyChartFlex;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TabBar;
	
	public class HomeView extends BentoView {
		
		[SkinPart(required="true")]
		public var readingCourse:Button;
		
		[SkinPart(required="true")]
		public var writingCourse:Button;
		
		[SkinPart(required="true")]
		public var speakingCourse:Button;
		
		[SkinPart(required="true")]
		public var listeningCourse:Button;
		
		[SkinPart(required="true")]
		public var examTipsCourse:Button;

		[SkinPart(required="true")]
		public var coveragePieChart:AnyChartFlex;
		
		private var _fullChartXML:XML;
		
		public var courseSelect:Signal = new Signal(XML);
		public var chartTemplatesLoad:Signal = new Signal();
		
		public function setSummaryDataProvider(mySummary:Array):void {
			// Check that we DO have the template loaded
			if (_fullChartXML) {
				// We have the chart template, inject the data from the data provider
				for each (var point:Object in mySummary) {
					_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.name} y={point.value}/>);
				}
				coveragePieChart.anychartXML = _fullChartXML;
			}
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Populate the buttons with the course names
			//courseTabBar.dataProvider = new XMLListCollection(menu..course);
			
			// Get the coverage overview from the backside
			// This is probably a 'quick' call in usage stats mode rather than full progress
			
			// TODO: GO STRAIGHT TO THE READING COURSE SINCE I AM WORKING ON THE ZONE PAGE
			//readingCourse.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			//trace("partAdded in HomeView for " + partName);
			switch (instance) {
				case readingCourse:
				case writingCourse:
				case speakingCourse:
				case listeningCourse:
				case examTipsCourse:
					instance.addEventListener(MouseEvent.CLICK, onCourseClick);
					break;
				case coveragePieChart:
					// Load the chart templates
					chartTemplatesLoad.dispatch();
					break;
			}
		}
		/**
		 * The user has clicked a course button
		 * 
		 * @param event
		 */
		protected function onCourseClick(event:MouseEvent):void {
			var matchingCourses:XMLList = menu.course.(@caption == event.target.getStyle("title"));
			//var matchingCourses:XMLList = menu.course.(@caption == 'Reading');
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a course with caption {0}", event.target.getStyle("title"));
			} else {
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		}
		/**
		 * Many settings for the pie chart are completely static and can be initialised here 
		 * The data comes from XML template files loaded by ConfigProxy
		 */
		public function initCharts(templates:XML):void {
			// Purely a charting test
			_fullChartXML = templates;
		}

	}
}