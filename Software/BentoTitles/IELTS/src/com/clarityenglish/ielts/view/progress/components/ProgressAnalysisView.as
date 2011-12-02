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

		// TODO. These are all set in ielts.css if you can get at that from this view?
		private const _writingBright:String = '#7DAB36';
		private const _writingDull:String = '#364A17';
		private const _readingBright:String = '#00A2C8';
		private const _readingDull:String = '#005063';
		private const _listeningBright:String = '#FF6600';
		private const _listeningDull:String = '#7A3100';
		private const _speakingBright:String = '#A93087';
		private const _speakingDull:String = '#4F173F';
		private const _opacityDull:String = '0.9';
		
		private const chartTemplates:XML = 
			<anychart>
			  <settings>
				<animation enabled="False" duration="1" interpolation_type="Quadratic" show_mode="Together" />
			  </settings>
			  <charts>
				<chart plot_type="Pie">
				  <data_plot_settings enable_3d_mode="true" >
					<pie_series>
						<label_settings enabled="true">
							<background enabled="false" />
							<position anchor="Center" valign="Center" halign="Center" padding="20" />
							<font color="White">
							  <effects>
								<drop_shadow enabled="true" distance="2" opacity="0.5" blur_x="2" blur_y="2" />
							  </effects>
							</font>
						</label_settings>
						 <marker_settings enabled="true">
							<marker type="None" />
							<states>
							  <hover>
								<marker type="Circle" anchor="CenterTop" />
							  </hover>
							</states>
						  </marker_settings>
					</pie_series>
				  </data_plot_settings>
				  <data>
					<series name="You" type="Pie" palette="R2IV2" />
				  </data>
				  <chart_settings>
					<chart_background enabled="false" />
					<title enabled="false" />
					<legend enabled="false" />
				  </chart_settings>
				  <palettes>
					<palette name="R2IV2" type="DistinctColors" color_count="Auto">
						<item color={_writingBright}/>
						<item color={_speakingBright}/>
						<item color={_readingBright}/>
						<item color={_listeningBright}/>
					</palette>
				  </palettes>
				</chart>
			  </charts>
			</anychart>;
		
		public function setDataProvider(dataProvider:XML):void {
			if (_scoreChartXML) {
				// WARNING. It is possible for the mediator of a different view (coverage say) to still be loading
				// and firing notifications to get data. The notifications will be picked up by us too and end up here.
				// So you need to remove data points before you add them again.
				// The following works in <point> is the only node in series.
				_scoreChartXML.charts.chart.data.series[0].setChildren(new XMLList());
				/*
				var numberOfPoints:int = _scoreChartXML.charts.chart.data.series[0].point.length();
				for (var i:int=0; i < numberOfPoints; i++) {
					delete _scoreChartXML.charts.chart.data.series[0].point[i]; 
				}
				*/
				var numberOfPoints:int = _durationChartXML.charts.chart.data.series[0].point.length();
				for (var i:int=0; i < numberOfPoints; i++) {
					delete _durationChartXML.charts.chart.data.series[0].point[0]; 
				}
				
				for each (var point:XML in dataProvider.course) {
					_scoreChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={point.@averageScore} style={point.@caption} />);
				}
				if (analysisScoreChart) {
					analysisScoreChart.anychartXML = _scoreChartXML;
				}
			}
			if (_durationChartXML) {
				for each (point in dataProvider.course) {
					_durationChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={point.@duration} style={point.@caption} />);
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
			_durationChartXML.charts.chart.data_plot_settings.pie_series.label_settings[0].appendChild = new XML(<format>{"{%YValue}{numDecimals:0}sec"}</format>);
			
		}

	}
	
}