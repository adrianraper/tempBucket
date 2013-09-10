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
		public static const POSITION_ABSOLUTE:String = "absolute"; // TODO: not yet implemented
		
		public static const DISPLAY_INLINE:String = "inline";
		public static const DISPLAY_INLINE_BLOCK:String = "inline-block";
		public static const DISPLAY_BLOCK:String = "block"; // TODO: not yet implemented
		
		public static const DISPLAY_TABLE_ROW:String = "table-row";
		public static const DISPLAY_TABLE_CELL:String = "table-cell";
		
		public static const OVERFLOW_VISIBLE:String = "visible"; // TODO: not yet implemented
		public static const OVERFLOW_HIDDEN:String = "hidden"; // TODO: not yet implemented
		
		public static const BORDER_STYLE_NONE:String = "none";
		public static const BORDER_STYLE_SOLID:String = "solid";
		
		public var position:String = POSITION_STATIC;
		
		public var display:String = DISPLAY_INLINE;
		
		public var overflow:String = OVERFLOW_VISIBLE;
		
		public var float:String = FLOAT_NONE;
		
		public var width:*;
		public var height:*;
		
		public var left:Number;
		public var right:Number;
		public var top:Number;
		public var bottom:Number;
		
		private var _marginLeft:Number = 0;
		private var _marginRight:Number = 0;
		private var _marginTop:Number = 0;
		private var _marginBottom:Number = 0;
		
		// gh#364
		public var borderTopStyle:String = BORDER_STYLE_NONE;
		public var borderTopColor:Number = 0;
		private var _borderTopWidth:Number = 0;
		
		public var borderRightStyle:String = BORDER_STYLE_NONE;
		public var borderRightColor:Number = 0;
		private var _borderRightWidth:Number = 0;
		
		public var borderBottomStyle:String = BORDER_STYLE_NONE;
		public var borderBottomColor:Number = 0;
		private var _borderBottomWidth:Number = 0;
		
		public var borderLeftStyle:String = BORDER_STYLE_NONE;
		public var borderLeftColor:Number = 0;
		private var _borderLeftWidth:Number = 0;
		
		public var borderRadius:Number = 0;
		
		private var originalPaddingLeft:Number = 0;
		private var originalPaddingRight:Number = 0;
		private var originalPaddingTop:Number = 0;
		private var originalPaddingBottom:Number = 0;
		
		public override function set paddingLeft(value:*):void {
			originalPaddingLeft = value;
			updateRealPadding();
		}
		
		public override function set paddingRight(value:*):void {
			originalPaddingRight = value;
			updateRealPadding();
		}
		
		public override function set paddingTop(value:*):void {
			originalPaddingTop = value;
			updateRealPadding();
		}
		
		public override function set paddingBottom(value:*):void {
			originalPaddingBottom = value;
			updateRealPadding();
		}
		
		public function set marginLeft(value:Number):void {
			_marginLeft = value;
			updateRealPadding();
		}
		
		public function get marginLeft():Number {
			return _marginLeft;
		}
		
		public function set marginRight(value:Number):void {
			_marginRight = value;
			updateRealPadding();
		}
		
		public function get marginRight():Number {
			return _marginRight;
		}

		public function set marginTop(value:Number):void {
			_marginTop = value;
			updateRealPadding();
		}
		
		public function get marginTop():Number {
			return _marginTop;
		}

		public function set marginBottom(value:Number):void {
			_marginBottom = value;
			updateRealPadding();
		}
		
		public function get marginBottom():Number {
			return _marginBottom;
		}

		public function set borderTopWidth(value:Number):void {
			_borderTopWidth = value;
			updateRealPadding();
		}
		
		public function get borderTopWidth():Number {
			return _borderTopWidth;
		}
		
		public function set borderRightWidth(value:Number):void {
			_borderRightWidth = value;
			updateRealPadding();
		}
		
		public function get borderRightWidth():Number {
			return _borderRightWidth;
		}
		
		public function set borderBottomWidth(value:Number):void {
			_borderBottomWidth = value;
			updateRealPadding();
		}
		
		public function get borderBottomWidth():Number {
			return _borderBottomWidth;
		}
		
		public function set borderLeftWidth(value:Number):void {
			_borderLeftWidth = value;
			updateRealPadding();
		}
		
		public function get borderLeftWidth():Number {
			return _borderLeftWidth;
		}
		
		/**
		 * We make up the actual TLF padding out of the padding, margin and border (as defined in the CSS box model)
		 */
		private function updateRealPadding():void {
			writableTextLayoutFormat().setStyle("paddingLeft", originalPaddingLeft + _marginLeft + (_borderLeftWidth * 2));
			writableTextLayoutFormat().setStyle("paddingRight", originalPaddingRight + _marginRight + (_borderRightWidth * 2));
			writableTextLayoutFormat().setStyle("paddingTop", originalPaddingTop + _marginTop + (_borderTopWidth * 2));
			writableTextLayoutFormat().setStyle("paddingBottom", originalPaddingBottom + _marginBottom + (_borderBottomWidth * 2));
			
			formatChanged();
		}
		
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
		 * Returns true if this box has at least one border
		 * 
		 * @return 
		 */
		public function hasBorder():Boolean {
			return (
				borderTopStyle != FloatableTextFlow.BORDER_STYLE_NONE && borderTopWidth > 0 ||
				borderRightStyle != FloatableTextFlow.BORDER_STYLE_NONE && borderRightWidth > 0 ||
				borderBottomStyle != FloatableTextFlow.BORDER_STYLE_NONE && borderBottomWidth > 0 ||
				borderLeftStyle != FloatableTextFlow.BORDER_STYLE_NONE && borderLeftWidth > 0);
		}
		
		/**
		 * Returns true if this box has every border
		 *
		 * @return
		 */ 
		public function hasAllBorders():Boolean {
			return (
				borderTopStyle != FloatableTextFlow.BORDER_STYLE_NONE && borderTopWidth > 0 &&
				borderRightStyle != FloatableTextFlow.BORDER_STYLE_NONE && borderRightWidth > 0 &&
				borderBottomStyle != FloatableTextFlow.BORDER_STYLE_NONE && borderBottomWidth > 0 &&
				borderLeftStyle != FloatableTextFlow.BORDER_STYLE_NONE && borderLeftWidth > 0);
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
