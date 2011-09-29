package com.clarityenglish.ielts.view.exercise {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	public class ExerciseView extends BentoView {
		
		[SkinPart(required="true")]
		public var dynamicView:DynamicView;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName,instance);
			
			switch (instance) {
				case dynamicView:
					dynamicView.href = href;
					break;
			}
		}
		
	}
	
}