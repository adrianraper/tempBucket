package com.clarityenglish.tensebuster.view.progress
{
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.ProgressCourseButtonBar;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.charts.BarChart;
	import mx.charts.CategoryAxis;
	import mx.charts.Legend;
	import mx.charts.LegendItem;
	import mx.charts.LinearAxis;
	import mx.charts.series.BarSeries;
	import mx.collections.XMLListCollection;
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.containers.TileDirection;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import mx.graphics.SolidColor;
	
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	
	public class ProgressCompareView extends BentoView {
		
		[SkinPart]
		public var progressCourseButtonBar:ProgressCourseButtonBar;		
		
		[SkinPart(required="true")]
		public var compareChart:BarChart;
		
		[SkinPart(required="true")]
		public var verticalAxis:CategoryAxis;
				
		[SkinPart]
		public var horizontalAxis:LinearAxis;
		
		[SkinPart]
		public var myBarSeries:BarSeries;
		
		[SkinPart]
		public var myAveScoreColor1:GradientEntry;
		
		[SkinPart]
		public var myAveScoreColor2:GradientEntry;
		
		[SkinPart]
		public var everyOneBarSeries:BarSeries;
		
		[SkinPart]
		public var everyOneAveScoreColor1:GradientEntry;
		
		[SkinPart]
		public var everyOneAveScoreColor2:GradientEntry;
		
		[SkinPart]
		public var myGrid:Grid;
		
		[SkinPart]
		public var compareInstructionLabel:Label;
		
		private var _everyoneCourseSummaries:Object;
		private var _everyoneCourseSummariesChanged:Boolean;
		private var _courseClass:String;
		private var _courseChanged:Boolean;
		
		public var courseSelect:Signal = new Signal(String);
		
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
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			if (progressCourseButtonBar) progressCourseButtonBar.courses = menu.course;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (progressCourseButtonBar) progressCourseButtonBar.copyProvider = copyProvider;
			horizontalAxis.title = copyProvider.getCopyForId("verticalAxisTitle");
			compareInstructionLabel.text = copyProvider.getCopyForId("compareInstructionLabel");
		}
		
		public function set everyoneCourseSummaries(value:Object):void {
			_everyoneCourseSummaries = value;
			_everyoneCourseSummariesChanged = true;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();

			if (_courseChanged && menu && _everyoneCourseSummariesChanged) {
				
				// #176. Make sure the buttons in the progressCourseBar component reflect current state
				if (progressCourseButtonBar) progressCourseButtonBar.courseClass = courseClass;

					// Merge the my and everyone summary into some XML and return a list collection of the course nodes
					var xml:XML = <progress />;
					for each (var untiNode:XML in menu.course.(@["class"] == courseClass).unit) {
						var everyoneAverageScore:Number = (_everyoneCourseSummaries[untiNode.@id]) ? _everyoneCourseSummaries[untiNode.@id].AverageScore : 0;
						xml.appendChild(<unit caption={untiNode.@caption} myAverageScore={untiNode.@averageScore} everyoneAverageScore={everyoneAverageScore} />);
					}
					trace("progress: "+xml);
					verticalAxis.dataProvider = compareChart.dataProvider = new XMLListCollection(xml.unit);
					
					myAveScoreColor1.color = getStyle(courseClass.charAt(0) + "BarColor1");
					myAveScoreColor2.color = getStyle(courseClass.charAt(0) + "BarColor2");
					everyOneAveScoreColor1.color = getStyle(courseClass.charAt(0) + "BarColor1");
					everyOneAveScoreColor2.color = getStyle(courseClass.charAt(0) + "BarColor2");
					//myLegend.visible = true;
					drawLegend();

				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressCourseButtonBar:
					progressCourseButtonBar.addEventListener(IndexChangeEvent.CHANGE, onCourseSelect);
					break;
			}
		}
		
		/**
		 * The user has changed the course to be displayed
		 *
		 * @param String course class name
		 */
		public function onCourseSelect(event:IndexChangeEvent):void {
			courseSelect.dispatch(event.target.selectedItem.courseClass.toLowerCase());
		}
		
		public function drawLegend():void {
			// Use a counter for the series. 
			clearLegend();
			for (var j:int = 0; j < 1; j++) { 
				var gr:GridRow = new GridRow(); 
				myGrid.addChild(gr); 
				for (var k:int = 0; k < 2; k++) {
					var gi:GridItem = new GridItem(); 
					gr.addChild(gi); 
					var li:LegendItem = new LegendItem();
					// Apply the current series' displayName to the LegendItem's label. 
					if (k == 0) {
						li.label = myBarSeries.displayName 
					} else {
						li.label = everyOneBarSeries.displayName; 
					}
					
					// Get the current series' fill. 
					var sc:LinearGradient = new LinearGradient();
					var gradientEntry1:GradientEntry = new GradientEntry();
					var gradientEntry2:GradientEntry = new GradientEntry();
					if (k == 0) {
						var color1:Number = getStyle(courseClass.charAt(0) + "BarColor1");
						var color2:Number = getStyle(courseClass.charAt(0) + "BarColor2");
					} else {
						color1 = getStyle(courseClass.charAt(0) + "OtherBarColor1");
						color2 = getStyle(courseClass.charAt(0) + "OtherBarColor2");
					}					
					gradientEntry1.color = color1;					
					gradientEntry2.color = color2;
					sc.entries = [gradientEntry1, gradientEntry2];
					// Apply the current series' fill to the corresponding LegendItem. 
					li.setStyle("fill", sc); 
					li.setStyle("fontSize", 12);
					gi.addChild(li);
				}
			} 
		}
		
		private function clearLegend():void { 
			myGrid.removeAllChildren();
		} 
	}
}