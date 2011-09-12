package com.clarityenglish.textLayout.elements {
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;
	
	import spark.core.SpriteVisualElement;
	
	/**
	 * This extends TextFlow to add properties allowing it to float.  This is used by Bento's custom importers.
	 * 
	 * @author Dave Keen
	 */
	public class FloatableTextFlow extends TextFlow {
		
		public static const FLOAT_NONE:String = "float_none";
		public static const FLOAT_LEFT:String = "float_left";
		public static const FLOAT_RIGHT:String = "float_right";
		
		public var float:String = FLOAT_NONE;
		
		public var width:*;
		
		// TODO: Not yet implemented
		public var height:*;
		
		/**
		 * Parse the percentage width into an integer
		 * 
		 * @return 
		 */
		public function get percentWidth():int {
			return new Number(width.substr(0, width.length - 1));
		}
		
		/**
		 * Determine whether width is a pixel amount (e.g. 50) or a percentage (e.g. 50%)
		 * 
		 * @return 
		 */
		public function isPercentWidth():Boolean {
			return (width is String) && width.charAt(width.length - 1) == "%";
		}
		
		/**
		 * Determine whether the width is fixed or dynamic
		 * 
		 * @return 
		 */
		public function isFixedWidth():Boolean {
			return width != null && !isPercentWidth();
		}
		
		/**
		 * Determine whether height is a pixel amount (e.g. 50) or a percentage (e.g. 50%).  At present fixed heights are not implemented and this will
		 * always return false.
		 *  
		 * @return 
		 */
		public function isPercentHeight():Boolean {
			return false;
		}
		
		/**
		 * Determine whether the height is fixed or dynamic.  At present fixed heights are not implemented and this will
		 * always return false.
		 *  
		 * @return 
		 */
		public function isFixedHeight():Boolean {
			return false;
		}
		
		public function FloatableTextFlow(config:IConfiguration = null) {
			super(config);
		}
		
	}
}
