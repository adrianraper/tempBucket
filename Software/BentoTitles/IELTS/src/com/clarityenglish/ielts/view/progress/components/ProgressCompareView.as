package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
	
	import mx.charts.BarChart;
	import mx.charts.CategoryAxis;
	import mx.charts.chartClasses.IAxis;
	import mx.collections.XMLListCollection;
	
	import spark.components.Label;
	
	public class ProgressCompareView extends BentoView {
		
		[SkinPart(required="true")]
		public var compareChart:BarChart;
		
		[SkinPart(required="true")]
		public var verticalAxis:CategoryAxis;

		[SkinPart]
		public var compareInstructionLabel:Label;
		
		[SkinPart]
		public var chartCaptionLabel:Label;
		
		private var _mySummaryXml:XML;
		
		private var _everyoneSummaryXml:XML;
		
		private var _xmlChanged:Boolean;
		
		private var _viewCopyProvider:CopyProvider;
		
		public function set viewCopyProvider(viewCopyProvider:CopyProvider):void {
			_viewCopyProvider = viewCopyProvider;
		}
		
		/*//issue:#11 language Code
		public override function setCopyProvider(copyProvider:CopyProvider):void {
			this.copyProvider = copyProvider;	
		}*/
		
		public function set mySummaryXml(value:XML):void {
			_mySummaryXml = value;
			_xmlChanged = true;
			invalidateProperties();
		}

		public function set everyoneSummaryXml(value:XML):void {
			_everyoneSummaryXml = value;
			_xmlChanged = true;
			invalidateProperties();
		}
		
		private function get mergedSummaryXml():XMLListCollection {
			if (_mySummaryXml && _everyoneSummaryXml) {
				// Merge the my and everyone summary into some XML and return a list collection of the course nodes
				var xml:XML = <progress />;
				
				for each (var courseNode:XML in _mySummaryXml.course) {
					var everyoneCourseNode:XML = _everyoneSummaryXml.course.(@["class"] == courseNode.@["class"])[0];
					xml.appendChild(<course class={courseNode.@['class']} caption={courseNode.@caption} myAverageScore={courseNode.@averageScore} everyoneAverageScore={everyoneCourseNode ? everyoneCourseNode.@averageScore : 0} />);
				}
				
				return new XMLListCollection(xml.course);
			}
			
			return null;
		}

		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_xmlChanged) {
				verticalAxis.dataProvider = compareChart.dataProvider = mergedSummaryXml;
				
				_xmlChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case compareInstructionLabel:
					instance.text = _viewCopyProvider.getCopyForId("compareInstructionLabel");
					break;
				case chartCaptionLabel:
					instance.text = _viewCopyProvider.getCopyForId("chartCaptionLabel");
					break;				
			}
		}
		
	}
	
}