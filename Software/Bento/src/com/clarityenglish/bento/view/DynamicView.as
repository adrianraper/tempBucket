package com.clarityenglish.bento.view {
	
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.events.XHTMLEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.utils.getDefinitionByName;
	
	import mx.core.UIComponent;
	
	import skins.bento.DynamicViewSkin;
	import skins.bento.exercise.XHTMLExerciseSkin;
	
	import spark.components.Group;
	import spark.components.supportClasses.Skin;
	import mx.events.FlexEvent;
	
	public class DynamicView extends BentoView {
		
		public static const DEFAULT_VIEW:String = "com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView";
		
		[SkinPart(required="true")]
		public var contentGroup:Group;
		
		protected override function onPreinitialize(event:FlexEvent):void {
			super.onPreinitialize(event);
			
			// It doesn't matter what media type we are using; dynamic skins *always* use DynamicViewSkin so override anything already set
			// in onPreinitialize in BentoView here.
			setStyle("skinClass", DynamicViewSkin);
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Remove any existing dynamic view
			while (contentGroup.numChildren > 0)
				contentGroup.removeElementAt(0);
			
			if (viewName) {
				try {
					var classReference:Class = getDefinitionByName(viewName) as Class;
				} catch (e:ReferenceError) {
					log.error("Unable to get a reference to the dynamic view; perhaps the name is wrong? {0}", viewName);
					return;
				}
				
				var view:Object = new classReference();
				
				if (view is BentoView) {
					// Create the new view and add it.  For the moment just use the default XHTMLExerciseView, but this will be definable in the XML
					var bentoView:BentoView = view as BentoView;
					bentoView.percentWidth = bentoView.percentHeight = 100;
					bentoView.media = media;
					bentoView.href = href;
					contentGroup.addElement(bentoView);
				} else if (!view) {
					log.error("Instantiating the dynamic view produced null. Perhaps the dynamic view wasn't embedded in the swf? {0}", viewName);
				} else {
					log.error("The passed in view was not a BentoView - {0}", viewName);
				}
			}
		}
		
		public function get viewName():String {
			var exercise:Exercise = _xhtml as Exercise;
			
			if (!exercise)
				return null;
			
			return (exercise.model && exercise.model.view) || DEFAULT_VIEW;
		}
		
	}
	
}