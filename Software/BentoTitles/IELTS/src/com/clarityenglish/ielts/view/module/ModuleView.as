package com.clarityenglish.ielts.view.module {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import spark.components.Button;
	import spark.components.Label;
	
	public class ModuleView extends BentoView {
		
		[SkinPart]
		public var courseTitleLabel:Label;
		
		[SkinPart]
		public var courseDescriptionLabel:Label;
		
		[SkinPart]
		public var examPracticeButton1:Button;
		
		[SkinPart]
		public var examPracticeButton2:Button;
		
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
			}
		}
		
	}
	
}