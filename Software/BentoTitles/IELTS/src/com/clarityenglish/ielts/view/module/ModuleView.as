package com.clarityenglish.ielts.view.module {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.module.ui.DifficultyRenderer;
	
	import spark.components.Button;
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
		
		private var _course:XML;
		
		public function set course(value:XML):void {
			_course = value;
			invalidateProperties();
		}

		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_course) {
				courseTitleLabel.text = _course.@caption;
				courseDescriptionLabel.text = _course.@description;
				
				// Class is a reserved word so have to use attribute(name)
				examPractice1Button.label = _course.unit.(attribute("class") == "exam-practice").exercise[0].@caption;
				examPractice1Difficulty.data = _course.unit.(attribute("class") == "exam-practice").exercise[0].@difficulty;
				examPractice2Button.label = _course.unit.(attribute("class") == "exam-practice").exercise[1].@caption;
				examPractice2Difficulty.data = _course.unit.(attribute("class") == "exam-practice").exercise[1].@difficulty;
			}
		}
		
	}
	
}