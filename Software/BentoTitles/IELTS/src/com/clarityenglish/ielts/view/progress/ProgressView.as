package com.clarityenglish.ielts.view.progress {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import spark.components.Label;
	
	public class ProgressView extends BentoView {

		[SkinPart(required="true")]
		public var coveragePieChart:AnyChartFlex;

		public var _fullChartXML:XML;
		
		public function setAverageScoreDataProvider(dataProvider:Array):void {
			//coveragePieChart.dataProvider = _dataProvider;
			coveragePieChart.anychartXML = _fullChartXML;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();		
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case coveragePieChart:
					// Initial settings for the chart
					initPieChart();
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
		}
		
		/**
		 * Many settings for the pie chart are completely static and can be initialised here 
		 * 
		 */
		private function initPieChart():void {
			/*
			 * Comment for now, just use sample data
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
			// Purely a charting test
			_fullChartXML=<anychart>
							  <charts>
								<chart plot_type="CategorizedVertical">
								  <data>
									<series name="Product Sales" type="Bar">
									  <point name="2004" y="63716" />
									  <point name="2005" y="72163" />
									  <point name="2006" y="94866" />
									  <point name="2007" y="56866" />
									  <point name="2008" y="19000" />
									</series>
								  </data>
								  <chart_settings>
									  <title>
										  <text>ACME Corp. Sales</text>
									  </title>
									  <axes>
										  <x_axis>
											  <title>
												  <text>Year</text>
											  </title>
										  </x_axis>
										  <y_axis>
											  <title>
												  <text>Sales (USD)</text>
											  </title>
										  </y_axis>
									  </axes>
								  </chart_settings>
								</chart>
							  </charts>
							</anychart>;			
		}

	}
	
}