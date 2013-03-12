package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.ui.IStackedChart;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import spark.components.DataGroup;
	import spark.components.Label;
	
	/**
	 * TODO: This class is way too specific; we don't want to be specifying course classes in here since we want it to be shared between all titles.
	 */
	public class ProgressAnalysisView extends BentoView {
		
		[SkinPart(required="true")]
		public var stackedChart:IStackedChart;
		
		[SkinPart(required="true")]
		public var analysisInstructionLabel1:Label;
		
		[SkinPart(required="true")]
		public var analysisInstructionLabel2:Label;
		
		[SkinPart(required="true")]
		public var analysisTimeLabel:Label;
		
		[SkinPart(required="true")]
		public var durationDataGroup:DataGroup;
		
		// #18 - analysis can be course based (e.g. IELTS) or unit based (e.g. CCB)
		public var _type:String;
		public static const UNIT_BASED:String = "progressanalysisview/unit_based";
		public static const COURSE_BASED:String = "progressanalysisview/course_based";
		
		public function set type(value:String):void {
			_type = value;
			invalidateProperties();
		}
		
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
			
			if (!_type) return;
			
			var targetNodes:XMLList;
			if (_type == COURSE_BASED) {
				targetNodes = menu.course;
			} else if (_type == UNIT_BASED) {
				targetNodes = menu.course.unit;
			}
			
			stackedChart.dataProvider = targetNodes;
			
			durationDataGroup.dataProvider = new XMLListCollection(targetNodes);
			var duration:Number = 0;
			for each (var item:XML in targetNodes)
				duration += new Number(item.@duration);
			
			analysisTimeLabel.text = copyProvider.getCopyForId("analysisTime", { x: Math.floor(duration / 60) } );
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case stackedChart:
					// set the field we will be drawing
					stackedChart.field = "duration";
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