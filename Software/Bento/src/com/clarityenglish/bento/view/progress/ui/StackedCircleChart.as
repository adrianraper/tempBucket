package com.clarityenglish.bento.view.progress.ui {
	import mx.core.UIComponent;
	
	public class StackedCircleChart extends UIComponent implements IStackedChart {
		
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
			
			// Implement drawing the circle graph!
			graphics.beginFill(0xFF0000, 1);
			graphics.drawCircle(0, 0, 100);
			graphics.endFill();
		}
	
	}
}
