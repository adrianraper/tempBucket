package com.clarityenglish.rotterdam.clearpronunciation.view.course.layouts {
	import flash.geom.Rectangle;
	
	import mx.core.ILayoutElement;
	import mx.core.mx_internal;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.layouts.supportClasses.LayoutBase;
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayout;
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayoutElement;
	
	use namespace mx_internal;
	
	public class FreeUnitLayout extends LayoutBase implements IUnitLayout {
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var _columns:int = 2;
		
		public var horizontalGap:uint = 2;
		
		public function FreeUnitLayout() {
			super();
		}
		
		mx_internal override function get virtualLayoutSupported():Boolean {
			return false;
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
			
			// For cp, widget column width is fixed. Instead of width, we use 950
			var columnWidth:Number = (950 - horizontalGap * (columns - 1)) / columns;
			
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
					var elementY:uint = currentElement.ypos;
					
					//gh: #185 measureHeight + 120
					// gh#865
					measuredHeight = Math.max(measuredHeight, elementY + currentElement.getLayoutBoundsHeight());
					
					// Set the position
					currentElement.setLayoutBoundsPosition(elementX, elementY);
					
					// #17 - this is somewhat hacky, but set the current height of the element in the XML so that WidgetAddCommand can figure out
					// where to put new widgets.  When widget layout is figured out properly this will definitely go.
					currentElement.layoutheight = currentElement.getLayoutBoundsHeight();
				} else {
					log.error("Only IUnitLayoutElements can be in a UnitLayout (" + target.getElementAt(i) + ")");
				}
			}
			
			target.setContentSize(width, measuredHeight);
		}
		
		override protected function scrollPositionChanged():void {
			// this is all fine
			var hsp:Number = horizontalScrollPosition;
			var vsp:Number = verticalScrollPosition;
			target.scrollRect = new Rectangle(hsp, vsp, target.width, target.height);
		}
		
		/**
		 * Determine the column that the given x value falls into based on the width of the container and the number of columns
		 * 
		 * @param x
		 * @return 
		 */
		public function getColumnFromX(x:Number):int {
			return Math.floor(x / target.width * columns);
		}
		
		/**
		 * A public method allowing us to call the protected framework method calculateDropIndex method from outside the class
		 */
		public function getDropIndex(x:Number, y:Number):int {
			return calculateDropIndex(x, y);
		}
		
		/**
		 * Any action in the FreeUnitLayout brings a widget to the front, so the drop index is always at the end.
		 */
		override protected function calculateDropIndex(x:Number, y:Number):int {
			return Math.max(0, target.numElements - 1);
		}
		
		/**
		 * Update the element during a drag.  In this layout this means setting the column and the ypos based on the mouse position.  This method
		 * invalidates the target's display list when necessary.
		 * 
		 * @param item
		 * @param x
		 * @param y
		 */
		public function updateElementFromDrag(item:Object, x:Number, y:Number):void {
			// Figure out the new column and bound it within a valid range
			var newColumn:int;
			newColumn = getColumnFromX(x);
			newColumn = Math.max(0, newColumn);
			newColumn = Math.min(newColumn, columns - item.@span);
			
			// If the column has changed then rewrite the XML accordingly
			if (newColumn != item.@column) {
				item.@column = newColumn;
				target.invalidateDisplayList();
			}
			
			// Set the y position
			if (y != item.@ypos && y >= 0) {
				item.@ypos = y;
				target.invalidateDisplayList();
			}
			
		}
	}
}