package com.clarityenglish.bento.view.progress.ui {
	import mx.core.UIComponent;
	
	public class StackedBarChart extends UIComponent implements IStackedChart {
		
		private var _colours:Array = [];
		private var _field:String;
		private var _dataProvider:Object;
		
		public function set colours(value:Array):void {
			_colours = value;
			invalidateDisplayList();
		}
		
		public function set field(value:String):void {
			_field = value;
			invalidateDisplayList();
		}
		
		public function set dataProvider(value:Object):void {
			_dataProvider = value;
			invalidateDisplayList();
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			graphics.clear();
			
			if (!_field || !_dataProvider) return;
			
			// Determine the total of all the values and store it
			var item:Object;
			var totalValues:Number = 0;
			for each (item in _dataProvider)
				totalValues += new Number(item.attribute(_field));
			
			// Draw the bar chart with the colours specified in series
			var currentX:Number = 0, idx:int = 0;
			for each (item in _dataProvider) {
				// Determine colour and width
				var barColour:Number = _colours[idx];
				var barValue:Number = new Number(item.attribute(_field));
				var barWidth:Number = unscaledWidth * barValue / totalValues;
				
				if (isNaN(barWidth)) barWidth = 0;
				
				graphics.beginFill(barColour, 1);
				graphics.drawRect(currentX, 0, barWidth, unscaledHeight);
				graphics.endFill();
				
				currentX += barWidth;
				idx++;
			}
		}
		
	}
}
