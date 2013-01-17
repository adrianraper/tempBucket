package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.ielts.view.progress.ui.CourseDurationRenderer;
	import com.clarityenglish.ielts.view.progress.ui.StackedBarChart;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	
	public class ProgressAnalysisView extends BentoView {
		
		[SkinPart(required="true")]
		public var stackedBarChart:StackedBarChart;
		
		[SkinPart(required="true")]
		public var analysisInstructionLabel1:Label;
		
		[SkinPart(required="true")]
		public var analysisInstructionLabel2:Label;
		
		[SkinPart(required="true")]
		public var analysisTimeLabel:Label;
		
		[SkinPart(required="true")]
		public var durationDataGroup:DataGroup;
		
		private var _viewCopyProvider:CopyProvider;
		
		public function set viewCopyProvider(viewCopyProvider:CopyProvider):void {
			_viewCopyProvider = viewCopyProvider;
		}
		
		public function get viewCopyProvider():CopyProvider {
			return _viewCopyProvider;
		}
		
		public override function setCopyProvider(copyProvider:CopyProvider):void {
			this.copyProvider = copyProvider;	
		}
		
		// gh#11
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			stackedBarChart.dataProvider = menu;
			
			durationDataGroup.dataProvider = new XMLListCollection(menu.course);
			
			var duration:Number = 0;
			for each (var course:XML in menu.course)
				duration += new Number(course.@duration);
				
			analysisTimeLabel.text = _viewCopyProvider.getCopyForId("analysisTime", { x: Math.floor(duration / 60) } );
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
				case analysisInstructionLabel1:
					instance.text = _viewCopyProvider.getCopyForId("analysisInstructionLabel1");
					break;
				case analysisInstructionLabel2:
					instance.text = _viewCopyProvider.getCopyForId("analysisInstructionLabel2");
					break;
				case durationDataGroup:
					var classFactory:ClassFactory = new ClassFactory(CourseDurationRenderer);
					classFactory.properties = { copyProvider: _viewCopyProvider };
					instance.itemRenderer = classFactory;
					break;
			}
		}
		
		[Bindable(event="progressChanged")]
		public function get totalDuration():Number {
			var duration:Number = 0;
			
			for each (var course:XML in menu.course)
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