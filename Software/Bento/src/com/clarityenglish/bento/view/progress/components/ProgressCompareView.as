package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.charts.BarChart;
	import mx.charts.CategoryAxis;
	import mx.charts.ColumnChart;
	import mx.charts.chartClasses.CartesianCanvasValue;
	import mx.charts.chartClasses.CartesianDataCanvas;
	import mx.charts.series.ColumnSeries;
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.events.IndexChangeEvent;
	import spark.events.ListEvent;
	
	public class ProgressCompareView extends BentoView {
		
		[SkinPart(required="true")]
		public var compareChart:ColumnChart;
		
		[SkinPart(required="true")]
		public var horizontalAxis:CategoryAxis;
		
		[SkinPart]
		public var compareInstructionLabel:Label;
		
		[SkinPart]
		public var chartCaptionLabel:Label;
		
		[SkinPart]
		public var myScoreColumnSeries:ColumnSeries;
		
		[SkinPart]
		public var everyScoreColumnSeries:ColumnSeries;
		
		[SkinPart]
		public var canvas:CartesianDataCanvas;
		
		[SkinPart]
		public var myScoreLegendLabel:Label;
		
		[SkinPart]
		public var everyoneScoreLegendLabel:Label;
		
		// gh#1166
		[SkinPart]
		public var countrySelection:DropDownList;
		public var countryDataProvider:ArrayCollection;
		public var country:String;
		public var userCountry:String;
		public var countrySelect:Signal = new Signal(String);
		
		private var _everyoneCourseSummaries:Object;
		private var _everyoneCourseSummariesChanged:Boolean;
		
		public function set everyoneCourseSummaries(value:Object):void {
			_everyoneCourseSummaries = value;
			_everyoneCourseSummariesChanged = true;
			invalidateProperties();
		}
		
		// gh#1166
		[Bindable]
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (compareInstructionLabel) compareInstructionLabel.text = copyProvider.getCopyForId("compareInstructionLabel");
			if (chartCaptionLabel) chartCaptionLabel.text = copyProvider.getCopyForId("chartCaptionLabel");
			if (myScoreLegendLabel) myScoreLegendLabel.text = copyProvider.getCopyForId("myScoreLegendLabel");
			
			// gh#1166 
			country = copyProvider.getCopyForId("worldwide");
			var initialList:String = country + '|';
			if (userCountry)
				initialList += userCountry + '|';
			var countryList:String = initialList + copyProvider.getCopyForId("countryList");
			countryDataProvider = new ArrayCollection(countryList.split('|'));
			countrySelection.dataProvider = countryDataProvider;
			countrySelection.selectedIndex = 0;
			var currentDataItem:Object = countrySelection.selectedItem;
			countrySelect.dispatch(currentDataItem as String);
		}
		
		// gh#1166
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case countrySelection:
					countrySelection.addEventListener(Event.CHANGE, onCountrySelect);
					break;
				default:
			}
		}

		protected function onCountrySelect(event:IndexChangeEvent):void {
			var currentDataItem:Object = event.currentTarget.selectedItem;
			country = currentDataItem as String;
			countrySelect.dispatch(country);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_everyoneCourseSummariesChanged) {
				// Merge the my and everyone summary into some XML and return a list collection of the course nodes
				var xml:XML = <progress />;
				
				for each (var courseNode:XML in menu.course) {
					var everyoneAverageScore:Number = (_everyoneCourseSummaries[courseNode.@id]) ? _everyoneCourseSummaries[courseNode.@id].AverageScore : 0;
					var everyoneCount:Number = (_everyoneCourseSummaries[courseNode.@id]) ? _everyoneCourseSummaries[courseNode.@id].Count : 1;
					xml.appendChild(<course class={courseNode.@['class']} caption={courseNode.@caption} myAverageScore={courseNode.@averageScore} everyoneAverageScore={everyoneAverageScore} everyoneCount={everyoneCount}/>);
				}
				
				horizontalAxis.dataProvider = compareChart.dataProvider = new XMLListCollection(xml.course);
				
				_everyoneCourseSummariesChanged = false;
				// gh#1166
				if (everyoneScoreLegendLabel) everyoneScoreLegendLabel.text = copyProvider.getCopyForId("everyoneScoreLegendLabel", {country: country});
			}
		}
	}
	
}