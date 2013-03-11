package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.StackedBarChart;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	
	/**
	 * TODO: This class is way too specific; we don't want to be specifying course classes in here since we want it to be shared between all titles.
	 */
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
		
		// gh#11
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (analysisInstructionLabel1) analysisInstructionLabel1.text = copyProvider.getCopyForId("analysisInstructionLabel1");
			if (analysisInstructionLabel2) analysisInstructionLabel2.text = copyProvider.getCopyForId("analysisInstructionLabel2");
			
			if (durationDataGroup) {
				// Inject the copy provider into the data provider
				var classFactory:ClassFactory = durationDataGroup.itemRenderer as ClassFactory;
				classFactory.properties = { copyProvider: copyProvider };
				durationDataGroup.itemRenderer = classFactory;
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			stackedBarChart.dataProvider = menu;
			
			durationDataGroup.dataProvider = new XMLListCollection(menu.course);
			
			var duration:Number = 0;
			for each (var course:XML in menu.course)
				duration += new Number(course.@duration);
				
			analysisTimeLabel.text = copyProvider.getCopyForId("analysisTime", { x: Math.floor(duration / 60) } );
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
			
			for each (var course:XML in menu.course)
				duration += new Number(course.@duration);
				
			return duration;
		}
		
	}
}