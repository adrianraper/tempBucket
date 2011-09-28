package com.clarityenglish.bento.view {
	
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.components.XHTMLExerciseView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.core.UIComponent;
	
	import skins.bento.DynamicViewSkin;
	import skins.bento.exercise.XHTMLExerciseViewSkin;
	
	import spark.components.Group;
	import spark.components.supportClasses.Skin;
	
	public class DynamicView extends BentoView {
		
		[SkinPart(required="true")]
		public var contentGroup:Group;
		
		public function DynamicView() {
			setStyle("skinClass", DynamicViewSkin);
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Remove any existing dynamic view
			while (contentGroup.numChildren > 0)
				contentGroup.removeElementAt(0);
			
			// Create the new view and add it.  For the moment just use the default XHTMLExerciseView, but this will be definable in the XML
			var bentoView:BentoView = new XHTMLExerciseView();
			bentoView.percentWidth = bentoView.percentHeight = 100;
			bentoView.href = href;
			contentGroup.addElement(bentoView);
		}
		
	}
	
}