package com.clarityenglish.ielts.view.module {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.module.ui.ButtonItemRenderer;
	import com.clarityenglish.ielts.view.module.ui.DifficultyRenderer;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.DataRenderer;
	import spark.components.Label;
	
	public class ModuleView extends BentoView {
		
		[SkinPart]
		public var courseTitleLabel:Label;
		
		[SkinPart]
		public var courseDescriptionLabel:Label;
		
		[SkinPart]
		public var examPractice1Button:Button;
		
		[SkinPart]
		public var examPractice1Difficulty:DataRenderer;
		
		[SkinPart]
		public var examPractice2Button:Button;
		
		[SkinPart]
		public var examPractice2Difficulty:DataRenderer;
		
		[SkinPart]
		public var practiceZoneDataGroup:DataGroup;
		
		private var _courseName:String;
		
		public function set courseName(value:String):void {
			_courseName = value;
			invalidateProperties();
		}

		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseName) {
				var course:XML = menu..course.(@caption == _courseName)[0];
				
				courseTitleLabel.text = course.@caption;
				courseDescriptionLabel.text = course.@description;
				
				// Class is a reserved word so have to use attribute(name)
				examPractice1Button.label = course.unit.(attribute("class") == "exam-practice").exercise[0].@caption;
				examPractice1Difficulty.data = course.unit.(attribute("class") == "exam-practice").exercise[0].@difficulty;
				examPractice2Button.label = course.unit.(attribute("class") == "exam-practice").exercise[1].@caption;
				examPractice2Difficulty.data = course.unit.(attribute("class") == "exam-practice").exercise[1].@difficulty;
				
				practiceZoneDataGroup.dataProvider = new XMLListCollection(course.unit.(attribute("class") == "practice-zone").exercise);
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName,instance);
			
			switch (instance) {
				case practiceZoneDataGroup:
					practiceZoneDataGroup.itemRenderer = new ClassFactory(ButtonItemRenderer);
					break;
			}
		}
		
	}
	
}