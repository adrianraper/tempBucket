package com.clarityenglish.ielts.view.progress.components {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	
	import mx.collections.ArrayCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
	
	public class ProgressCompareView extends BentoView {

		[SkinPart(required="true")]
		public var compareChart:AnyChartFlex;
		
		// Use a setter here to do the injection of the dataProvider into the chart XML
		//[Bindable]
		public function set mySummaryDataProvider(dataProvider:Array):void {
			this._mySummaryDataProvider = dataProvider;
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:Object in dataProvider) {
					_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.caption} y={point.averageScore}/>);
				}
				//compareChart.anychartXML = _fullChartXML;
			}
		}
		public function get mySummaryDataProvider():Array {
			return this._mySummaryDataProvider;
		}
		//[Bindable]
		public function set everyoneSummaryDataProvider(dataProvider:Array):void {
			this._everyoneSummaryDataProvider = dataProvider;
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:Object in dataProvider) {
					_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.caption} y={point.averageScore}/>);
				}
				//compareChart.anychartXML = _fullChartXML;
			}
		}
		public function get everyoneSummaryDataProvider():Array {
			return this._everyoneSummaryDataProvider;
		}
		
		private var _mySummaryDataProvider:Array;
		private var _everyoneSummaryDataProvider:Array;
		
		[Bindable]
		public var _fullChartXML:XML;

		private static const chartTemplates:XML = 
			<anychart>
			  <settings>
				<animation enabled="True" />
			  </settings>
			  <charts>
				<chart plot_type="CategorizedHorizontal">
				  <data_plot_settings default_series_type="Bar">
					<bar_series group_padding="0.5">
					  <tooltip_settings enabled="false" />
					  <label_settings enabled="true">
						<background enabled="false" />
						<position anchor="Center" valign="Center" halign="Center" />
						<font color="White" />
						<format />
					  </label_settings>
					</bar_series>
				  </data_plot_settings>
				  <data>
					<series name="Skill" type="Bar" palette="Default">
					</series>
				  </data>
				  <chart_settings>
					<chart_background enabled="false" />
					<title enabled="false" />
					<legend enabled="false" />
					<axes>
					  <y_axis enabled="false" position="Opposite">
						<scale minimum="0" maximum="100" major_interval="50" />
						<title enabled="false" />
						<labels enabled="false" />
					  </y_axis>
					  <x_axis>
						<labels>
							<font size="16" family="Helvetica,Arial" />
						</labels>
						<title enabled="false" />
					  </x_axis>
					</axes>
				  </chart_settings>
				</chart>
			  </charts>
			</anychart>;
		
		/*
		public function setMySummaryDataProvider(dataProvider:Array):void {
			// Check that we DO have the template alredy loaded
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:Object in dataProvider) {
					_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.caption} y={point.averageScore}/>);
				}
				// Then send a signal telling the chart to draw, if it is listening
				//if (compareChart)
				//	compareChart.anychartXML = _fullChartXML;
				drawChart.dispatch();
			}
		}
		public function setEveryoneSummaryDataProvider(dataProvider:Array):void {
			// Check that we DO have the template alredy loaded
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:Object in dataProvider) {
					_fullChartXML.charts.chart.data.series[1].appendChild(<point name={point.caption} y={point.averageScore}/>);
				}
				// Then send a signal telling the chart to draw, if it is listening
				//drawChart.dispatch();
			}
		}
		*/

		protected override function commitProperties():void {
			super.commitProperties();		
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case compareChart:
					initCharts(chartTemplates);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
		}
		
		/**
		 * Many settings for the pie chart are completely static and can be initialised here 
		 */
		public function initCharts(templates:XML):void {
			
			_fullChartXML = templates;
			// Set the axis label that we couldn't do in the const XML due to data binding
			_fullChartXML.charts.chart.data_plot_settings.bar_series.label_settings.format = "{%YValue}{numDecimals:0}%";
			
		}

	}
	
}