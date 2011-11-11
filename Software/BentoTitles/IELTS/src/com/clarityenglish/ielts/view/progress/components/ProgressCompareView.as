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
		[Bindable]
		public function set mySummaryDataProvider(dataProvider:ArrayCollection):void {
			this._mySummaryDataProvider = dataProvider;
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:Object in dataProvider) {
					_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.caption} y={point.averageScore}/>);
				}
				compareChart.anychartXML = _fullChartXML;
			}
		}
		public function get mySummaryDataProvider():ArrayCollection {
			return this._mySummaryDataProvider;
		}
		[Bindable]
		public function set everyoneSummaryDataProvider(dataProvider:ArrayCollection):void {
			this._everyoneSummaryDataProvider = dataProvider;
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:Object in dataProvider) {
					_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.caption} y={point.averageScore}/>);
				}
				compareChart.anychartXML = _fullChartXML;
			}
		}
		public function get everyoneSummaryDataProvider():ArrayCollection {
			return this._everyoneSummaryDataProvider;
		}
		
		private var _mySummaryDataProvider:ArrayCollection;
		private var _everyoneSummaryDataProvider:ArrayCollection;
		[Bindable]
		public var _fullChartXML:XML;
		
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
		*/
		public function setEveryoneSummaryDataProvider(dataProvider:Array):void {
			// Check that we DO have the template alredy loaded
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:Object in dataProvider) {
					_fullChartXML.charts.chart.data.series[1].appendChild(<point name={point.caption} y={point.averageScore}/>);
				}
				// Then send a signal telling the chart to draw, if it is listening
				drawChart.dispatch();
			}
		}

		protected override function commitProperties():void {
			super.commitProperties();		
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case compareChart:
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
		}
		
		/**
		 * Many settings for the pie chart are completely static and can be initialised here 
		 * The data comes from XML template files loaded by ConfigProxy
		 */
		public function initCharts(templates:XML):void {
			
			// TODO. You can use the same XML to hold multiple chart templates, pull out just the one you want here
			_fullChartXML = templates;
			
			// I would like to draw the base chart now with 0 data points
			// But you can't, as this might be called before the chart is added
			compareChart.anychartXML = templates;
			
		}
		/*
		 * Comment for now, just sample data
		var _mainSettings:XML = <settings>
							<animation enabled="True"/>
						</settings>;

		var _dataPlotSettings:XML = <data_plot_settings default_series_type = "Bar" enable_3d_mode = "true"
								z_padding = "0.5" z_aspect = "1"
								z_elevation="45" >
								<bar_series point_padding="0" group_padding="1" style="filledGradient">
									<tooltip_settings enabled="true">
										<format>{"{%YValue}{numDecimals:0}"}</format>
									</tooltip_settings>
								</bar_series>
							</data_plot_settings>;
		
		var _chartStyles:XML = <styles>
					<bar_style name="filledGradient">
						<fill type="Gradient" opacity="1">
							<gradient>
								<key position="0" color="Red"/>
								<key position="1" color="Purple"/>
							</gradient>
						</fill>
						<states>
							<hover>
								<fill type="Gradient" opacity="1">
									<gradient>
										<key position="0" color="LightColor(%Color)"/>
										<key position="1" color="DarkColor(%Color)"/>
									</gradient>
								</fill>
							</hover>
						</states>
					</bar_style>
				</styles>;
		
		var _axes:XML = <axes>
					<y_axis>
						<title rotation="0">
							<font family="Verdana" size="10" />
							<text>Number</text>
						</title>
						<labels allow_overlap="True" show_first_label="True" show_last_label="True">
							<font family="Verdana" size="10" />
							<format>{ "{%Value}{numDecimals:0}" }</format>
						</labels>
						<major_tickmark enabled="true" />
						<scale minimum="0" mode="Overlay"/>
						<axis_markers>
							<lines>
								<line opacity="0">
									<label enabled="True" position="Axis" rotation="0">
										<font family="Verdana" size="10" color="Black" bold="False" />
										<format>{ "{%Value}{numDecimals:0}" }</format>
									</label>
								</line>
							</lines>
						</axis_markers>
					</y_axis>
					<x_axis>
						<title enabled="false">
						</title>
						<labels enabled="true" >
							<font family="Verdana" size="10" />
						</labels>
					</x_axis>
				</axes>;
		
		var _title:XML = <title enabled="true">
					<text>Showing the number of times the program has been used each month</text>
				</title>;
		
		var _chartSettings:XML = <chart_settings>
					<chart_background>
						<border enabled="false"/>
					</chart_background>
					{_title}
					<legend enabled="true" position="Bottom" ignore_auto_item="true">
						<title enabled="false">
						</title>
						<columns_separator enabled="true"/>
						<background>
							<inside_margin left="10" right="10"/>
						</background>
						<items></items>
					</legend>
					{_axes}
				</chart_settings>;
		
		// Full thing before any dynamic data
		_fullChartXML = <anychart>
				{_mainSettings}
				<charts>
					<chart plot_type="CategorizedVertical">
						{_dataPlotSettings }
						{_chartStyles}
						{_chartSettings}
						<data><note>nothing here</note></data>
					</chart>
				</charts>
			</anychart>;
		*/

	}
	
}