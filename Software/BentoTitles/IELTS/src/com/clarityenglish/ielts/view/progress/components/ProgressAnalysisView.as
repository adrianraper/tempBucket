package com.clarityenglish.ielts.view.progress.components {
	import com.anychart.AnyChartFlex;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.progress.ui.StackedBarChart;
	
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
	
	public class ProgressAnalysisView extends BentoView {
		
		[SkinPart(required="true")]
		public var stackedBarChart:StackedBarChart;
		
		[Bindable]
		public var progressXml:XML;
		
		public function get assetFolder():String {
			return config.remoteDomain + '/Software/ResultsManager/web/resources/assets/';
		}
		
		/*public function setDataProvider(dataProvider:XML):void {
			if (_scoreChartXML) {
				// WARNING. It is possible for the mediator of a different view (coverage say) to still be loading
				// and firing notifications to get data. The notifications will be picked up by us too and end up here.
				// So you need to remove data points before you add them again.
				// The following works if <point> is the only node in series.
				_scoreChartXML.charts.chart.data.series[0].setChildren(new XMLList());
				
				// #320. If no points you get vast amounts of debug information on screen
				numberScoreSectionsDone = 0;
				for each (var point:XML in dataProvider.course) {
					if (Number(point.@averageScore)>0) {
						numberScoreSectionsDone++;
						_scoreChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={point.@averageScore} style={point.@caption} />);
					}
				}
				if (analysisScoreChart) {
					analysisScoreChart.anychartXML = _scoreChartXML;
				}
			}
			
			var myDuration:int = 0;
			if (_durationChartXML) {
				// Or this works to just delete the first node x times.
				var numberOfPoints:int = _durationChartXML.charts.chart.data.series[0].point.length();
				for (var i:int=0; i < numberOfPoints; i++) {
					delete _durationChartXML.charts.chart.data.series[0].point[0]; 
				}
				
				// AR Pie charts don't work well if only one non-zero chunk.
				numberDurationSectionsDone = 0;
				//logToConsole("building duration data");
				for each (point in dataProvider.course) {
					//logToConsole("this point.count=" + Number(point.@count) as String);
					if (Number(point.@count)>0) {
						numberDurationSectionsDone++;
						// Duration data is in seconds, but we want to display in minutes (rounded)
						// Massage 0 values, they don't work well in a pie-chart
						if (Number(point.@duration)<30) {
							myDuration = 1;
						} else {
							myDuration = Math.round(Number(point.@duration)/60);
						}
						_durationChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={myDuration} style={point.@caption} />);
					}
				}
				if (analysisTimeChart) {
					analysisTimeChart.anychartXML = _durationChartXML;
				}
			}
			
			// #320 Update skin state
			invalidateSkinState();
		}
		
		private function logToConsole(message:String):void {
			if (ExternalInterface.available)
				ExternalInterface.call("log", message);
		}*/
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case stackedBarChart:
					// Set the series and colours for the stacked bar chart based on CSS styles
					stackedBarChart.series = [
						{ name: "reading", colour: getStyle("readingColor") },
						{ name: "listening", colour: getStyle("listeningColor") },
						{ name: "speaking", colour: getStyle("speakingColor") },
						{ name: "writing", colour: getStyle("writingColor") }
					]
					
					// set the field we will be drawing
					stackedBarChart.field = "duration";
					break;
			}
		}
		
		/**
		 * Many settings for the pie chart are completely static and can be initialised here 
		 */
		/*public function initCharts():void {
			trace("ProgressAnalysisView.initCharts");
			_scoreChartXML = new XML(barchartTemplates.toString());
			_durationChartXML = new XML(piechartTemplates.toString());
			
			// customise the label settings
			//_scoreChartXML.charts.chart.data_plot_settings.bar_series.label_settings[0].appendChild = new XML(<format>{"{%YValue}{numDecimals:0}%"}</format>);
			_durationChartXML.charts.chart.data_plot_settings.pie_series.label_settings[0].appendChild = new XML(<format>{"{%YValue}{numDecimals:0} minute(s)"}</format>);
			
		}
		// #320
		public function clearCharts():void {
			trace("ProgressAnalysisView.clearCharts");
			_scoreChartXML = null;
			_durationChartXML = null;
		}*/

		/*protected override function getCurrentSkinState():String {
			// Skin is dependent on data
			if (productVersion == IELTSApplication.DEMO) {
				return "demo";
			// #320
			} else if (numberScoreSectionsDone < 1 && numberDurationSectionsDone < 2) {
				return "blocked";
			} else if (numberScoreSectionsDone < 1) {
				return "blockedScore";
			} else if (numberDurationSectionsDone < 2) {
				return "blockedDuration";
			} else {
				return "normal";
			}
		}*/
		
	}
}