package com.clarityenglish.rotterdam.view.unit.layouts {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	/**
	 * This layout implements the unit editor and viewer layout.  Since this is really the core of the application usability it is implemented to be as fast
	 * as it possibly can be, and uses a BitmapData canvas to draw where things are going and to figure out where the next available slots are that elements
	 * can be positioned into. 
	 */
	public class UnitLayout extends LayoutBase {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public var columns:int = 3;
		
		public var horizontalGap:uint = 2;
		
		public var verticalGap:uint = 2;
		
		private var elementMap:BitmapData;
		
		private var measuredWidth:uint = 0;
		private var measuredHeight:uint = 0;
		
		public function UnitLayout() {
			elementMap = new BitmapData(columns, 8191, true);
		}
		
		override public function measure():void {
			super.measure();
			
			target.measuredWidth = measuredWidth;
			target.measuredHeight = measuredHeight;
			target.measuredMinWidth = measuredWidth;
			target.measuredMinHeight = measuredHeight;
			target.setContentSize(measuredWidth, measuredHeight);
		}
		
		public override function updateDisplayList(width:Number, height:Number):void {
			super.updateDisplayList(width, height);
			
			if (!target)
				return;
			
			measuredWidth = width;
			
			// Create a new delimiters array (this is what we will check for gaps) and clear the elementMap
			var yDelimiters:Array = [ 0 ];
			elementMap.fillRect(new Rectangle(0, 0, elementMap.width, elementMap.height), 0x00000000);
			
			// Get the width of a column
			var columnWidth:Number = (width - horizontalGap * (columns - 1)) / columns;
			
			for (var i:int = 0; i < target.numElements; i++) {
				// Get as an IUnitLayoutElement (this gives us column and span attributes)
				var currentElement:IUnitLayoutElement = target.getElementAt(i) as IUnitLayoutElement;
				
				if (currentElement) {
					// Set the width based on the span and column width, and allow the widget to set its own height
					var widthGapOffset:uint = horizontalGap * (currentElement.span - 1);
					currentElement.setLayoutBoundsSize(currentElement.span * columnWidth + widthGapOffset, NaN);
					
					// Calculate the x position based on the requested column
					var xGapOffset:uint = horizontalGap * currentElement.column;
					var elementX:uint = currentElement.column * columnWidth + xGapOffset;
					
					// Calculate the y position based on what is already there
					var elementY:uint = getFirstAvailableY(currentElement, yDelimiters, elementMap);
					if (elementY > 0) elementY += verticalGap; // TODO: not 100% convinced that this works properly yet...
					
					measuredHeight = Math.max(measuredWidth, elementY + currentElement.getLayoutBoundsHeight());
					
					// Set the position
					currentElement.setLayoutBoundsPosition(elementX, elementY);
					
					// Update the column heights
					updateColumnMap(currentElement, yDelimiters, elementMap);
				} else {
					log.error("Only IUnitLayoutElements can be in a UnitLayout (" + target.getElementAt(i) + ")");
				}
			}
			
			target.invalidateSize(); // TODO: needed to make the scroller work, but performance issues?
		}
		
		private function getFirstAvailableY(element:IUnitLayoutElement, yDelimiters:Array, elementMap:BitmapData):Number {
			// Here we go through the gaps seeing if element will fit; if not it goes at the end
			for each (var y:uint in yDelimiters) {
				var available:Boolean = !elementMap.hitTest(new Point(0, 0), 1, new Rectangle(element.column, y, element.span, element.getPreferredBoundsHeight()));
				if (available)
					return y;
			}
			
			// Not as performant as it might be since we already have delimiters?
			return Math.max.apply(null, yDelimiters);
		}
		
		private function updateColumnMap(element:IUnitLayoutElement, yDelimiters:Array, elementMap:BitmapData):void {
			var yDelimiter:uint = element.getLayoutBoundsY() + element.getPreferredBoundsHeight();
			if (yDelimiters.indexOf(yDelimiter) < 0) yDelimiters.push(element.getLayoutBoundsY() + element.getPreferredBoundsHeight());
			
			elementMap.fillRect(new Rectangle(element.column, element.getLayoutBoundsY(), element.span, element.getLayoutBoundsHeight()), 0xFF000000);
		}
	
	}
}
