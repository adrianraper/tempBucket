package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import mx.charts.BarChart;
	import mx.charts.CategoryAxis;
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
		
		private var _everyoneCourseSummaries:Object;
		private var _everyoneCourseSummariesChanged:Boolean;
		
		private var _viewCopyProvider:CopyProvider;
		
		public function set viewCopyProvider(viewCopyProvider:CopyProvider):void {
			_viewCopyProvider = viewCopyProvider;
		}
		
		public function set everyoneCourseSummaries(value:Object):void {
			_everyoneCourseSummaries = value;
			_everyoneCourseSummariesChanged = true;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_everyoneCourseSummariesChanged) {
				// Merge the my and everyone summary into some XML and return a list collection of the course nodes
				var xml:XML = <progress />;
				
				for each (var courseNode:XML in menu.course) {
					var everyoneAverageScore:Number = (_everyoneCourseSummaries[courseNode.@id]) ? _everyoneCourseSummaries[courseNode.@id].AverageScore : 0;
					xml.appendChild(<course class={courseNode.@['class']} caption={courseNode.@caption} myAverageScore={courseNode.@averageScore} everyoneAverageScore={everyoneAverageScore} />);
				}
				
				verticalAxis.dataProvider = compareChart.dataProvider = new XMLListCollection(xml.course);
				
				_everyoneCourseSummariesChanged = false;
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