package com.clarityenglish.ielts.view.exercise {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import spark.components.Button;
	
	public class ExerciseView extends BentoView {
		
		[SkinPart]
		public var forwardButton:Button;
		
		[SkinPart]
		public var backButton:Button;
		
		[SkinPart]
		public var markingButton:Button;
		
		[SkinPart]
		public var feedbackButton:Button;
		
		[SkinPart(required="true")]
		public var dynamicView:DynamicView;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			dynamicView.href = href;
		}
		
	}
	
}