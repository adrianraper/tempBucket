package com.clarityenglish.bento.view.progress.ui {
	import mx.charts.PieChart;
	import mx.charts.series.PieSeries;
	import mx.charts.series.items.PieSeriesItem;
	import mx.core.UIComponent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class StackedCircleChart extends SkinnableComponent implements IStackedChart {
		
		[SkinPart]
		public var doughnutPieChart:PieChart;
		
		private var _field:String;
		private var _dataProvider:Object;
		private var _dataTip:String;
		private var _pieDuration:Number = 0;
		private var _pieUnitIndex:Number = 0;
		
		[Bindable]
		public var dataTipLabel:String;
		
		[Bindable]
		public var dataTipCpation:String;
		
		[Bindable]
		public function set field(value:String):void {
			_field = "@" + value;
			invalidateDisplayList();
		}
		
		public function get field():String {
			return _field;
		}
		
		[Bindable]
		public function set dataProvider(value:Object):void {
			_dataProvider = value;
			invalidateDisplayList();
		}
		
		public function get dataProvider():Object {
			return _dataProvider;
		}
		
		[Bindable]
		public function set pieDuration(value:Number):void {
			_pieDuration = Math.floor(value / 60);
		}
		
		public function get pieDuration():Number {
			return _pieDuration;
		}
		
		[Bindable]
		public function set pieUnitIndex(value:Number):void {
			_pieUnitIndex = value + 1;
		}
		
		public function get pieUnitIndex():Number {
			return _pieUnitIndex;
		}


		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			graphics.clear();
			
			if (!_field || !_dataProvider) return;

			// Implement drawing the circle graph!
			/*graphics.beginFill(0xFF0000, 1);
			graphics.drawCircle(0, 0, 100);
			graphics.endFill();*/
		}
	
	}
}
