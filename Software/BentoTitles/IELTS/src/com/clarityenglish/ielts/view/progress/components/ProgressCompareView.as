package com.clarityenglish.ielts.view.progress.components {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	
	import mx.collections.ArrayCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class ProgressCompareView extends BentoView {

		[SkinPart(required="true")]
		public var compareChart:AnyChartFlex;

		private var _licenceType:uint;
		
		// #234
		private var _productVersion:String;
		
		public function get productVersion():String {
			return _productVersion;
		}
		
		public function set productVersion(value:String):void {
			if (_productVersion != value) {
				_productVersion = value;
			}
		}

		//[Bindable]
		private var _fullChartXML:XML;

		// see ielts.css. But I can't call getStyle in this .as file.
		private static const _writingBright:String = '#7DAB36';
		private static const _writingDull:String = '#364A17';
		private static const _writingLight:String = '#95CC40';
		private static const _readingBright:String = '#00A2C8';
		private static const _readingDull:String = '#005063';
		private static const _readingLight:String = '#00BCE8';
		private static const _listeningBright:String = '#FF6600';
		private static const _listeningDull:String = '#7A3100';
		private static const _listeningLight:String = '#FF8736';
		private static const _speakingBright:String = '#A93087';
		private static const _speakingDull:String = '#4F173F';
		private static const _speakingLight:String = '#D43CA9';
		private static const _opacityDull:String = '0.9';
		
		private static const chartTemplates:XML = 
			<anychart>
			  <settings>
				<animation enabled="True" />
			  </settings>
			  <charts>
				<chart plot_type="CategorizedVertical">
				  <data_plot_settings default_series_type="Bar" enable_3d_mode="true" z_padding="0.5" z_aspect="1" z_elevation="45" >
					<bar_series group_padding="0.9" >
						<tooltip_settings enabled="true">
							<font family="Arial" size="12" />
							<format>{"{%SeriesName} {%YValue}{numDecimals:0}%"}</format>
						</tooltip_settings>
					  <label_settings enabled="false">
						<background enabled="false" />
						<position anchor="Center" valign="Center" halign="Center" />
						<format>{"{%YValue}{numDecimals:0}%"}</format>
					  </label_settings>
					</bar_series>
				  </data_plot_settings>
				<styles>
					<bar_style name="Writing0">
						<states>
							<normal>
								<fill enabled="true" type="solid" color={_writingBright} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" color={_writingLight} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" color={_writingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" color={_writingLight} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" color={_writingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" color="#00FFFF" />
							</missing>
						</states>
					</bar_style>
					<bar_style name="Writing1">
						<states>
							<normal>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_writingDull} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_writingLight} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_writingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_writingLight} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_writingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" opacity={_opacityDull} color="#00FFFF" />
							</missing>

						</states>
					</bar_style>
					<bar_style name="Reading0">
						<states>
							<normal>
								<fill enabled="true" type="solid" color={_readingBright} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" color={_readingLight} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" color={_readingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" color={_readingLight} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" color={_readingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" color="#00FFFF" />
							</missing>
						</states>
					</bar_style>
					<bar_style name="Reading1">
						<states>
							<normal>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_readingDull} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_readingLight} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_readingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_readingLight} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_readingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" opacity={_opacityDull} color="#00FFFF" />
							</missing>

						</states>
					</bar_style>
					<bar_style name="Speaking0">
						<states>
							<normal>
								<fill enabled="true" type="solid" color={_speakingBright} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" color={_speakingLight} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" color={_speakingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" color={_speakingLight} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" color={_speakingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" color="#00FFFF" />
							</missing>
						</states>
					</bar_style>
					<bar_style name="Speaking1">
						<states>
							<normal>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_speakingDull} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_speakingLight} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_speakingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_speakingLight} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_speakingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" opacity={_opacityDull} color="#00FFFF" />
							</missing>
						</states>
					</bar_style>
					<bar_style name="Listening0">
						<states>
							<normal>
								<fill enabled="true" type="solid" color={_listeningBright} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" color={_listeningLight} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" color={_listeningDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" color={_listeningLight} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" color={_listeningBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" color="#00FFFF" />
							</missing>
						</states>
					</bar_style>
					<bar_style name="Listening1">
						<states>
							<normal>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_listeningDull} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_listeningLight} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_listeningDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_listeningLight} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" opacity={_opacityDull} color={_listeningBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" opacity={_opacityDull} color="#00FFFF" />
							</missing>
						</states>
					</bar_style>
				</styles>
				  <data>
					<series name="You" type="Bar" palette="Default">
						<animation type="ScaleXYCenter" duration="1" />
					</series>
					<series name="Everyone" type="Bar" palette="Default">
						<animation duration="1" interpolation_type="Elastic" />
					</series>
				  </data>
				  <chart_settings>
					<chart_background enabled="false" />
					<title enabled="false" />
					<legend enabled="false" />
					<axes>
							<y_axis>
								<title rotation="0">
									<font family="Arial" bold="true" size="12" />
									<text>Average score %</text>
								</title>
								<labels allow_overlap="true" show_first_label="true" show_last_label="true">
									<font family="Arial" size="12" />
									<format>{"{%Value}{numDecimals:0}"}</format>
								</labels>
								<major_tickmark enabled="true" />
								<scale minimum="0" maximum="100" major_interval="20" mode="Overlay"/>
							</y_axis>
						<x_axis>

						<labels>
							<font size="12" family="Helvetica,Arial" bold="true" />

						</labels>
						<title enabled="false" />
					  </x_axis>
					</axes>
				  </chart_settings>
				</chart>
			  </charts>
			</anychart>;
		
		public function setMySummaryDataProvider(dataProvider:XML):void {
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:XML in dataProvider.course) {
					_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={point.@averageScore} style={point.@caption+'0'} />);
				}
				if (compareChart) {
					compareChart.anychartXML = _fullChartXML;
				}
			}
		}
		public function setEveryoneSummaryDataProvider(dataProvider:XML):void {
			if (_fullChartXML) {
				// TODO. Make this smoother by adding in the data series and redrawing
				// We have the chart template, inject the data from the data provider
				for each (var point:XML in dataProvider.course) {
					_fullChartXML.charts.chart.data.series[1].appendChild(<point name={point.@caption} y={point.@averageScore} style={point.@caption+'1'} />);
				}
				if (compareChart) {
					compareChart.anychartXML = _fullChartXML;
				}
			}
		}

		protected override function commitProperties():void {
			super.commitProperties();		
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				/*
				case compareChart:
					trace("progressCompareView partAdded compareChart");
					if (_fullChartXML) { 
						trace("drawChart 1");	
						compareChart.anychartXML = _fullChartXML;
					}
					break;
				*/
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
		}
		
		/**
		 * Many settings for the pie chart are completely static and can be initialised here 
		 */
		public function initCharts():void {
			trace("ProgressCompareView.initCharts");
			_fullChartXML = chartTemplates;
			
		}
		// #320
		public function clearCharts():void {
			trace("ProgressCompareView.clearCharts");
			_fullChartXML = null;
		}

		
		[Bindable]
		public function get licenceType():uint {
			return _licenceType;
		}
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
			}
		}

	}
	
}