package com.clarityenglish.textLayout.elements {
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;
	
	/**
	 * This extends TextFlow to add properties allowing it to float.  This is used by Bento's custom importers.
	 * 
	 * @author Dave Keen
	 */
	public class FloatableTextFlow extends TextFlow {
		
		public static const SIZE_DYNAMIC:String = "size_dynamic";
		public static const SIZE_FIXED:String = "size_fixed";
		public static const SIZE_PERCENTAGE:String = "size_percentage";
		
		public static const FLOAT_NONE:String = "none";
		public static const FLOAT_LEFT:String = "left";
		public static const FLOAT_RIGHT:String = "right";
		
		public static const POSITION_STATIC:String = "static";
		public static const POSITION_RELATIVE:String = "relative";
		public static const POSITION_ABSOLUTE:String = "absolute";
		
		// TODO: Not yet implemented
		public var position:String = POSITION_STATIC;
		
		public var float:String = FLOAT_NONE;
		
		public var width:*;
		
		public var height:*;
		
		public var left:Number;
		
		public var right:Number;
		
		public var top:Number;
		
		public var bottom:Number;
		
		public function get widthType():String {
			if (isFixedWidth()) {
				return SIZE_FIXED;
			} else if (isPercentWidth()) {
				return SIZE_PERCENTAGE;
			} else {
				return SIZE_DYNAMIC;
			}
		}
		
		public function get heightType():String {
			if (isFixedHeight()) {
				return SIZE_FIXED;
			} else if (isPercentHeight()) {
				return SIZE_PERCENTAGE;
			} else {
				return SIZE_DYNAMIC;
			}
		}
		
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
		 * Parse the percentage height into an integer
		 * 
		 * @return 
		 */
		public function get percentHeight():int {
			return new Number(height.substr(0, height.length - 1));
		}
		
		/**
		 * Determine whether height is a pixel amount (e.g. 50) or a percentage (e.g. 50%).
		 *  
		 * @return 
		 */
		public function isPercentHeight():Boolean {
			return (height is String) && height.charAt(height.length - 1) == "%";
		}
		
		/**
		 * Determine whether the height is fixed or dynamic.
		 *  
		 * @return 
		 */
		public function isFixedHeight():Boolean {
			return height != null && !isPercentHeight();
		}
		
		/** 
		 * Returns all elements of class <code>klass</code>.
		 *
		 * @param klass The class of which to find elements.
		 *
		 * @return An array of the elements whose class is <code>klass</code>. For example,
		 * all elements that are of class InputElement.
		 */
		public function getElementsByClass(klass:Class):Array {
			var a:Array = [ ];
			applyFunctionToElements(function (elem:FlowElement):Boolean{ if (elem is klass) a.push(elem); return false; });
			return a;
		}
		
		public function FloatableTextFlow(config:IConfiguration = null) {
			super(config);
		}
		
	}
}
