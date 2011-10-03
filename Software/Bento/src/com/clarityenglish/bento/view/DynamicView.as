package com.clarityenglish.bento.view {
	
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.utils.getDefinitionByName;
	
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
			
			// We know that xhtml is going to be an Exercise so cast it here so we can access extra properties and methods
			var exercise:Exercise = xhtml as Exercise;
			
			// Remove any existing dynamic view
			while (contentGroup.numChildren > 0)
				contentGroup.removeElementAt(0);
			
			// Determine the dynamic view .  If no view is defined then use the default XHTMLExerciseView.
			var viewName:String = exercise.model.view || "com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView";
			var classReference:Class = getDefinitionByName(viewName) as Class;
			var view:Object = new classReference();
			
			if (view is BentoView) {
				// Create the new view and add it.  For the moment just use the default XHTMLExerciseView, but this will be definable in the XML
				var bentoView:BentoView = view as BentoView;
				bentoView.percentWidth = bentoView.percentHeight = 100;
				bentoView.href = href;
				contentGroup.addElement(bentoView);
			} if (!view) {
				log.error("Instantiating the dynamic view produced null. Either the dynamic view wasn't embedded in the swf or the name was wrong? {0}", viewName);
			} else {
				log.error("The passed in view was not a BentoView - {0}", viewName);
			}
		}
		
	}
	
}