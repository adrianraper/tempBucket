package com.clarityenglish.rotterdam.player.view.progress.ui {
	import mx.core.UIComponent;
	
	public class StackedBarChart extends UIComponent {
		
		private var _series:Array;
		private var _field:String;
		private var _dataProvider:Object;
		
		public function set series(value:Array):void {
			_series = value;
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
			
			if (!_series || !_field || !_dataProvider) return;
			
			// Determine the total of all the values and store it
			var seriesItem:Object;
			var totalValues:Number = 0;
			for each (seriesItem in _series)
				totalValues += new Number(_dataProvider.course.(@["class"] == seriesItem.name).attribute(_field));
			
			// Draw the bar chart with the colours specified in series
			var currentX:Number = 0;
			for each (seriesItem in _series) {
				// Determine colour and width
				var barColour:Number = seriesItem.colour;
				var barValue:Number = new Number(_dataProvider.course.(@["class"] == seriesItem.name).attribute(_field));
				var barWidth:Number = unscaledWidth * barValue / totalValues;
				
				if (isNaN(barWidth)) barWidth = 0;
				
				graphics.beginFill(barColour, 1);
				graphics.drawRect(currentX, 0, barWidth, unscaledHeight);
				graphics.endFill();
				
				currentX += barWidth;
			}
		}
	
	}
}
