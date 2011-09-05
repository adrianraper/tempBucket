package com.clarityenglish.textLayout.conversion.rendering {
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.core.SpriteVisualElement;
	
	public class RenderBlock {
		
		/**
		 * The HTML node before parsing 
		 */
		public var html:XML;
		
		/**
		 * The imported text flow (once parsed)
		 */
		public var textFlow:FloatableTextFlow;
		
		/**
		 * The visual component (once rendered)
		 */
		public var textFlowContainer:SpriteVisualElement;
		
	}
	
}