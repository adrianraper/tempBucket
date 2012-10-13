package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.progress.ui.StackedBarChart;
	
	import flash.events.Event;
	
	public class ProgressAnalysisView extends BentoView {
		
		[SkinPart(required="true")]
		public var stackedBarChart:StackedBarChart;
		
		private var _progressXml:XML;

		[Bindable(event="progressChanged")]
		public function get progressXml():XML {
			return _progressXml;
		}

		public function set progressXml(value:XML):void {
			_progressXml = value;
			dispatchEvent(new Event("progressChanged"));
		}

		public function get assetFolder():String {
			return config.remoteDomain + '/Software/ResultsManager/web/resources/assets/';
		}
		
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
		
		[Bindable(event="progressChanged")]
		public function get totalDuration():Number {
			var duration:Number = 0;
			for each (var course:XML in progressXml.course)
				duration += new Number(course.@duration);
			
			return duration;
		}

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