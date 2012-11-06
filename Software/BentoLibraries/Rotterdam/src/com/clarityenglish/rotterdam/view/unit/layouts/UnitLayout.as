package com.clarityenglish.rotterdam.view.unit.layouts {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.ILayoutElement;
	import mx.core.mx_internal;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	use namespace mx_internal;
	
	/**
	 * This layout implements the unit editor and viewer layout.  Since this is really the core of the application usability it is implemented to be as fast
	 * as it possibly can be, and uses a BitmapData canvas to draw where things are going and to figure out where the next available slots are that elements
	 * can be positioned into.
	 */
	public class UnitLayout extends LayoutBase implements IUnitLayout {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var _columns:int = 3;
		
		public var horizontalGap:uint = 2;
		
		public var verticalGap:uint = 2;
		
		private var elementMap:BitmapData;
		
		public function UnitLayout() {
			elementMap = new BitmapData(columns, 8191, true);
		}
		
		public function get columns():int {
			return _columns;
		}

		public function set columns(value:int):void {
			_columns = value;
		}

		public override function updateDisplayList(width:Number, height:Number):void {
			super.updateDisplayList(width, height);
			
			if (!target)
				return;
			
			var measuredHeight:Number = 0;
			
			// Create a new delimiters array (this is what we will check for gaps) and clear the elementMap
			var yDelimiters:Array = [ 0 ];
			elementMap.fillRect(new Rectangle(0, 0, elementMap.width, elementMap.height), 0x00000000);
			
			// Get the width of a column
			var columnWidth:Number = (width - horizontalGap * (columns - 1)) / columns;
			
			for (var i:int = 0; i < target.numElements; i++) {
				var element:ILayoutElement = (useVirtualLayout ? target.getVirtualElementAt(i) : target.getElementAt(i));
				
				if (element is IUnitLayoutElement) {
					// Get as an IUnitLayoutElement (this gives us column and span attributes)
					var currentElement:IUnitLayoutElement = target.getElementAt(i) as IUnitLayoutElement;
					
					// Set the width based on the span and column width, and allow the widget to set its own height
					var widthGapOffset:uint = horizontalGap * (currentElement.span - 1);
					currentElement.setLayoutBoundsSize(currentElement.span * columnWidth + widthGapOffset, NaN);
					
					// Calculate the x position based on the requested column
					var xGapOffset:uint = horizontalGap * currentElement.column;
					var elementX:uint = currentElement.column * columnWidth + xGapOffset;
					
					// Calculate the y position based on what is already there
					var elementY:uint = getFirstAvailableY(currentElement, yDelimiters, elementMap);
					if (elementY > 0)
						elementY += verticalGap; // TODO: not 100% convinced that this works properly yet...
					
					measuredHeight = Math.max(measuredHeight, elementY + currentElement.getLayoutBoundsHeight());
					
					// Set the position
					currentElement.setLayoutBoundsPosition(elementX, elementY);
					
					// Update the column heights
					updateColumnMap(currentElement, yDelimiters, elementMap);
				} else {
					log.error("Only IUnitLayoutElements can be in a UnitLayout (" + target.getElementAt(i) + ")");
				}
			}
			
			target.setContentSize(width, measuredHeight);
		}
		
		private function getFirstAvailableY(element:IUnitLayoutElement, yDelimiters:Array, elementMap:BitmapData):Number {
			// Here we go through the gaps seeing if element will fit; if not it goes at the end
			for each (var y:uint in yDelimiters) {
				var available:Boolean = !elementMap.hitTest(new Point(0, 0), 1, new Rectangle(element.column, y, element.span, element.getPreferredBoundsHeight()));
				if (available) {
					return y;
				}
			}
			
			// We should never get here
			throw new Error("Didn't find an available y for the dropped element (this shouldn't be possible!");
			return null;
		}
		
		private function updateColumnMap(element:IUnitLayoutElement, yDelimiters:Array, elementMap:BitmapData):void {
			var yDelimiter:uint = element.getLayoutBoundsY() + element.getPreferredBoundsHeight();
			if (yDelimiters.indexOf(yDelimiter) < 0)
				yDelimiters.push(element.getLayoutBoundsY() + element.getPreferredBoundsHeight());
			
			elementMap.fillRect(new Rectangle(element.column, element.getLayoutBoundsY(), element.span, element.getLayoutBoundsHeight()), 0xFF000000);
		}
		
		/**
		 * Determine the column that the given x value falls into based on the width of the container and the number of columns
		 * 
		 * @param x
		 * @return 
		 */
		public function getColumnFromX(x:Number):int {
			return Math.floor(x / target.width * columns) - 1;
		}
		
		/**
		 * A public method allowing us to call the protected framework method calculateDropIndex method from outside the class
		 */
		public function getDropIndex(x:Number, y:Number):int {
			return calculateDropIndex(x, y);
		}
		
		/**
		 * This needs to figure out the drop index for a certain point.  This seems to mostly work, although its not perfect.
		 */
		override protected function calculateDropIndex(x:Number, y:Number):int {
			// First determine the column
			var column:int = getColumnFromX(x);
			
			// If we are hovering over an existing element then move to that position
			for (var i:int = 0; i < target.numElements; i++) {
				var bounds:Rectangle = getElementBounds(i);
				if (bounds && bounds.contains(x, y))
					return i;
			}
			
			// Otherwise don't move
			return -1;
		}
		
		public function updateElementFromDrag(item:Object, x:Number, y:Number):void {
			
		}
		
	}
}