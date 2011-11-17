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
		
		public function setMySummaryDataProvider(dataProvider:XML):void {
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:XML in dataProvider.course) {
					_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={point.@averageScore}/>);
				}
				if (compareChart)
					compareChart.anychartXML = _fullChartXML;
			}
		}
		public function setEveryoneSummaryDataProvider(dataProvider:XML):void {
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:XML in dataProvider.course) {
					_fullChartXML.charts.chart.data.series[1].appendChild(<point name={point.@caption} y={point.@averageScore}/>);
				}
				if (compareChart)
					compareChart.anychartXML = _fullChartXML;
			}
		}
		
		//[Bindable]
		private var _fullChartXML:XML;

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
						<format>{"{%YValue}{numDecimals:0}%"}</format>
					  </label_settings>
					</bar_series>
				  </data_plot_settings>
				  <data>
					<series name="You" type="Bar" palette="Default" />
					<series name="Everyone" type="Bar" palette="Default" />
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
		
		protected override function commitProperties():void {
			super.commitProperties();		
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case compareChart:
					if (_fullChartXML) 
						compareChart.anychartXML = _fullChartXML;
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
		}
		
		/**
		 * Many settings for the pie chart are completely static and can be initialised here 
		 */
		public function initCharts():void {
			
			_fullChartXML = chartTemplates;
			
		}

	}
	
}