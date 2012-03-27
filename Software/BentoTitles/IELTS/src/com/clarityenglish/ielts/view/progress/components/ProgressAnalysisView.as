package com.clarityenglish.ielts.view.progress.components {
	import com.anychart.AnyChartFlex;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	
	import mx.collections.ArrayCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
	
	public class ProgressAnalysisView extends BentoView {

		[SkinPart(required="true")]
		public var analysisScoreChart:AnyChartFlex;
		
		[SkinPart(required="true")]
		public var analysisTimeChart:AnyChartFlex;
		
		private var _scoreChartXML:XML;
		private var _durationChartXML:XML;

		[Bindable]
		public var numberSectionsDone:uint;
		
		// TODO. These are all set in ielts.css if you can get at that from this view?
		private const _writingBright:String = '#7DAB36';
		private const _writingDull:String = '#95CC40';
		private const _readingBright:String = '#00A2C8';
		private const _readingDull:String = '#00BCE8';
		private const _listeningBright:String = '#FF6600';
		private const _listeningDull:String = '#FF8736';
		private const _speakingBright:String = '#A93087';
		private const _speakingDull:String = '#D43CA9';
		private const _opacityDull:String = '0.9';
		
		private const chartTemplates:XML = 
			<anychart>
			  <settings>
				<animation enabled="False" />
			  </settings>
			  <charts>
			<chart_settings>
				<animation enabled="False" />
			</chart_settings>
				<chart plot_type="Pie">
				  <data_plot_settings enable_3d_mode="true" >
					<pie_series style="Aqua">
<animation enabled="False" />
<tooltip_settings enabled="true" >
<format><![CDATA[{%Name}]]>
</format>
					<font family="Arial" size="12" />
				</tooltip_settings>
						<label_settings enabled="true" mode="outside">
							<background enabled="false" />
							<position anchor="Center" valign="Center" halign="Center" padding="15%" />
							<font color="#303030" family="Arial" size="12" bold="True"  />
							<drop_shadow enabled="true" distance="2" opacity="0.5" blur_x="2" blur_y="2" />
							</label_settings>
							<connector enabled="True" color="#303030" opacity="1" thickness="1.4" />

						</pie_series>

				  </data_plot_settings>
				<styles>
					<pie_style name="Writing">
						<states>
							<normal>
								<fill enabled="true" type="solid" color={_writingBright} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" color={_writingDull} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" color={_writingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" color={_writingBright} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" color={_writingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" color="#00FFFF" />
							</missing>
						</states>
					</pie_style>
					<pie_style name="Reading">
						<states>
							<normal>
								<fill enabled="true" type="solid" color={_readingBright} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" color={_readingDull} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" color={_readingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" color={_readingBright} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" color={_readingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" color="#00FFFF" />
							</missing>
						</states>
					</pie_style>
					<pie_style name="Speaking">
						<states>
							<normal>
								<fill enabled="true" type="solid" color={_speakingBright} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" color={_speakingDull} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" color={_speakingDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" color={_speakingBright} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" color={_speakingBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" color="#00FFFF" />
							</missing>
						</states>
					</pie_style>
					<pie_style name="Listening">
						<states>
							<normal>
								<fill enabled="true" type="solid" color={_listeningBright} />
							</normal>
							<hover>
								<fill enabled="true" type="solid" color={_listeningDull} />
							</hover>
							<selected_normal>
								<fill enabled="true" type="solid" color={_listeningDull} />
							</selected_normal>
							<selected_hover>
								<fill enabled="true" type="solid" color={_listeningBright} />
							</selected_hover>
							<pushed>
								<fill enabled="true" type="solid" color={_listeningBright} />
							</pushed>
							<missing>
								<fill enabled="true" type="solid" color="#00FFFF" />
							</missing>
						</states>
					</pie_style>
				</styles>			
				  <data>
					<series name="You" type="Pie" >
					<point name="Reading" />
					<point name="Listening" />
					<point name="Speaking" />
					<point name="Writing" />
					</series>
				  </data>
				  <chart_settings>
					<chart_background enabled="false" />
					<title enabled="false" />
					<legend enabled="false" />
				  </chart_settings>
				</chart>
			  </charts>
			</anychart>;
		
		public function setDataProvider(dataProvider:XML):void {
			if (_scoreChartXML) {
				// WARNING. It is possible for the mediator of a different view (coverage say) to still be loading
				// and firing notifications to get data. The notifications will be picked up by us too and end up here.
				// So you need to remove data points before you add them again.
				// The following works if <point> is the only node in series.
				_scoreChartXML.charts.chart.data.series[0].setChildren(new XMLList());
				// Or this works to just delete the first node x times.
				var numberOfPoints:int = _durationChartXML.charts.chart.data.series[0].point.length();
				for (var i:int=0; i < numberOfPoints; i++) {
					delete _durationChartXML.charts.chart.data.series[0].point[0]; 
				}
				
				// AR Pie charts also don't work well if only one non-zero chunk.
				numberSectionsDone = 0;
				for each (var point:XML in dataProvider.course) {
					// Skip 0 values, they don't work well in a pie-chart
					if (Number(point.@averageScore)>0) {
						_scoreChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={point.@averageScore} style={point.@caption} />);
						numberSectionsDone++;
					}
				}
				if (analysisScoreChart) {
					analysisScoreChart.anychartXML = _scoreChartXML;
				}
			}
			var myDuration:int = 0;
			if (_durationChartXML) {
				for each (point in dataProvider.course) {
					// Skip 0 values, they don't work well in a pie-chart
					if (Number(point.@duration)>30) {
						// Duration data is in seconds, but we want to display in minutes (rounded)
						myDuration = Math.round(Number(point.@duration)/60);
						_durationChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={myDuration} style={point.@caption} />);
					}
				}
				if (analysisTimeChart) {
					analysisTimeChart.anychartXML = _durationChartXML;
				}
			}
		}

		protected override function commitProperties():void {
			super.commitProperties();		
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case analysisScoreChart:
					if (_scoreChartXML) { 
						analysisScoreChart.anychartXML = _scoreChartXML;
					}
					break;
				case analysisTimeChart:
					if (_durationChartXML) { 
						analysisTimeChart.anychartXML = _durationChartXML;
					}
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
			trace("ProgressAnalysisView.initCharts");
			_scoreChartXML = new XML(chartTemplates.toString());
			_durationChartXML = new XML(chartTemplates.toString());
			
			// customise the label settings
			_scoreChartXML.charts.chart.data_plot_settings.pie_series.label_settings[0].appendChild = new XML(<format>{"{%YValue}{numDecimals:0}%"}</format>);
			_durationChartXML.charts.chart.data_plot_settings.pie_series.label_settings[0].appendChild = new XML(<format>{"{%YValue}{numDecimals:0} minute(s)"}</format>);
			
		}

	}
	
}