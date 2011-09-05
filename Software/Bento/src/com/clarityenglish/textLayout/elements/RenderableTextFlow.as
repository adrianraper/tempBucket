package com.clarityenglish.textLayout.elements {
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;
	
	import spark.core.SpriteVisualElement;
	
	public class RenderableTextFlow extends TextFlow {
		
		public static const FLOAT_NONE:String = "float_none";
		public static const FLOAT_LEFT:String = "float_left";
		public static const FLOAT_RIGHT:String = "float_right";
		
		public var width:*;
		
		public var float:String;
		
		/**
		 * The HTML node before parsing 
		 */
		public var html:XML;
		
		/**
		 * The visual component once rendered
		 * 
		 * TODO: This definitely shouldn't be here; one this actually works move this into a TextFlow<->SpriteVisualElement Dictionary in the rendering component
		 */
		public var textFlowContainer:SpriteVisualElement;
		
		public function RenderableTextFlow(config:IConfiguration = null) {
			super(config);
		}
		
	}
}
