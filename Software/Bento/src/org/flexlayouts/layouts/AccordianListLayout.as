package org.flexlayouts.layouts {
	import mx.core.ILayoutElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class AccordianListLayout extends LayoutBase {
		private var _horizontalGap:Number = 6;
		private var _verticalGap:Number = 6;
		
		private var _columnCount:uint = 2;
		private var _columnWidth:uint = 0;
		private var _collapsedElementHeight:Number = 65;
		private var _expandedElementHeight:Number = 200;
		
		public function set horizontalGap(val:Number):void {
			_horizontalGap = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) layoutTarget.invalidateDisplayList();
		}

		public function set verticalGap(val:Number):void {
			_verticalGap = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) layoutTarget.invalidateDisplayList();
		}
		
		public function set columnWidth(val:Number):void {
			_columnWidth = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) layoutTarget.invalidateDisplayList();
		}
		
		public function set collapsedElementHeight(val:Number):void {
			_collapsedElementHeight = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) layoutTarget.invalidateDisplayList();
		}
		
		public function set expandedElementHeight(val:Number):void {
			_expandedElementHeight = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget) layoutTarget.invalidateDisplayList();
		}
		
		override public function updateDisplayList(containerWidth:Number, containerHeight:Number):void {
			super.updateDisplayList(containerWidth, containerHeight);
			
			var x:Number = 0, y:Number = 0, currentColumn:uint = 0, maxWidth:Number = 0, maxHeight:Number = 0;

			// Loop through all the elements
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;
			
			// Figure out how many elements there are in each row
			var maxElementsPerRow:uint = Math.floor((containerHeight - _expandedElementHeight) / _collapsedElementHeight) + 1;
			var elementsPerRow:uint = Math.min(Math.ceil(count / _columnCount), maxElementsPerRow);
			
			for (var i:int = 0; i < count; i++) {
				var element:ILayoutElement = (useVirtualLayout ? layoutTarget.getVirtualElementAt(i) : layoutTarget.getElementAt(i));
				
				// Let the element size itself
				element.setLayoutBoundsSize(NaN, NaN);
				var elementWidth:Number = element.getLayoutBoundsWidth();
				var elementHeight:Number = element.getLayoutBoundsHeight();
				
				// Move along a column if necessary
				if (i > 0 && i % elementsPerRow == 0) {
					y = 0;
					x += ((_columnWidth > 0) ? _columnWidth : elementWidth) + _horizontalGap;
				}
				
				// Position the element
				element.setLayoutBoundsPosition(x, y);
				
				// Update max dimensions (needed for scrolling)
				maxWidth = Math.max(maxWidth, x + elementWidth);
				maxHeight = Math.max(maxHeight, y + elementHeight);
				
				// Move y for the next element
				y += elementHeight + _verticalGap;
			}
			
			// Set final content size (needed for scrolling)
			layoutTarget.setContentSize(maxWidth, maxHeight);
		}
	}
}