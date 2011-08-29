package com.clarityenglish.textLayout.conversion.rendering {
	import flashx.textLayout.elements.TextFlow;
	
	import spark.core.SpriteVisualElement;
	
	public class RenderBlock {
		
		public static const FLOAT_NONE:String = "float_none";
		public static const FLOAT_LEFT:String = "float_left";
		public static const FLOAT_RIGHT:String = "float_right";
		
		/**
		 * 
		 */
		public var float:String;
		
		/**
		 * 
		 */
		public var width:*;
		
		/**
		 * The HTML node before parsing 
		 */
		public var html:XML;
		
		/**
		 * The imported text flow (once parsed)
		 */
		public var textFlow:TextFlow;
		
		/**
		 * The visual component once rendered
		 */
		public var textFlowContainer:SpriteVisualElement;
		
	}
	
}