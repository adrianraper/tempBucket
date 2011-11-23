package com.clarityenglish.ielts.view.home {
	import com.anychart.AnyChartFlex;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TabBar;
	
	public class HomeView extends BentoView {
		
		[SkinPart(required="true")]
		public var readingCourse:Button;
		
		[SkinPart(required="true")]
		public var writingCourse:Button;
		
		[SkinPart(required="true")]
		public var speakingCourse:Button;
		
		[SkinPart(required="true")]
		public var listeningCourse:Button;
		
		[SkinPart]
		public var examTipsCourse:Button;

		[SkinPart(required="true")]
		public var coveragePieChart:AnyChartFlex;
		
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
            <font bold="False" color="White">
              <effects>
                <drop_shadow enabled="True" opacity="0.5" distance="2" blur_x="1" blur_y="1" />
              </effects>
            </font>
            <format>{"{%YValue}{numDecimals:0}%"}</format>
		  </label_settings>
		</bar_series>
	  </data_plot_settings>
	<styles>
		<bar_style name="Writing">
			<states>
				<normal>
					<fill enabled="true" type="solid" color="#7DAB36" />
				</normal>
				<hover>
					<fill enabled="true" type="solid" color="#7DAB36" />
				</hover>
			</states>
		</bar_style>
		<bar_style name="Reading">
			<states>
				<normal>
					<fill enabled="true" type="solid" color="#00A2C8" />
				</normal>
				<hover>
					<fill enabled="true" type="solid" color="#00A2C8" />
				</hover>
			</states>
		</bar_style>
		<bar_style name="Speaking">
			<states>
				<normal>
					<fill enabled="true" type="solid" color="#A93087"  />
				</normal>
				<hover>
					<fill enabled="true" type="solid" color="#A93087" />
				</hover>
			</states>
		</bar_style>
		<bar_style name="Listening">
			<states>
				<normal>
					<fill enabled="true" type="solid" color="#FF6600" />
				</normal>
			</states>
		</bar_style>
	</styles>
	  <data >
		<series name="Skill" type="Bar" >
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
		private var _fullChartXML:XML;
		
		public var courseSelect:Signal = new Signal(XML);
		
		public function setSummaryDataProvider(mySummary:XML):void {
			
			// We have the chart template, inject the data from the data provider
			//for each (var point:Object in mySummary) {
			var points:XMLList = mySummary.course;
			for each (var point:XML in points) {
				_fullChartXML.charts.chart.data.series[0].appendChild(<point name={point.@caption} y={point.@coverage} style={point.@caption} />);
			}
			coveragePieChart.anychartXML = _fullChartXML;
			
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Populate the buttons with the course names
			//courseTabBar.dataProvider = new XMLListCollection(menu..course);
			
			// TODO: GO STRAIGHT TO THE READING COURSE SINCE I AM WORKING ON THE ZONE PAGE
			if (Config.DEVELOPER.name == "DK") {
				readingCourse.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			//trace("partAdded in HomeView for " + partName);
			switch (instance) {
				case readingCourse:
				case writingCourse:
				case speakingCourse:
				case listeningCourse:
				case examTipsCourse:
					instance.addEventListener(MouseEvent.CLICK, onCourseClick);
					break;
				case coveragePieChart:
					initCharts(chartTemplates);
					break;
			}
		}
		/**
		 * The user has clicked a course button
		 * 
		 * @param event
		 */
		protected function onCourseClick(event:MouseEvent):void {
			var matchingCourses:XMLList = menu.course.(@["class"] == event.target.getStyle("title").toLowerCase());
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a course with caption {0}", event.target.getStyle("title").toLowerCase());
			} else {
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		}
		/**
		 * Many settings for the pie chart are completely static and can be initialised/reset here 
		 */
		public function initCharts(templates:XML):void {
			
			_fullChartXML = templates;
			// Set the axis label that we couldn't do in the const XML due to data binding
			// Just add extra brackets
			//_fullChartXML.charts.chart.data_plot_settings.bar_series.label_settings.format = "{%YValue}{numDecimals:0}%";
			
		}

	}
}