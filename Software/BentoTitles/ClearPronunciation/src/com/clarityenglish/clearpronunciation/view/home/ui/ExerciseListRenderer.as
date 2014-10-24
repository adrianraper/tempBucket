package com.clarityenglish.clearpronunciation.view.home.ui {
	import spark.components.ButtonBarButton;
	
	public class ExerciseListRenderer extends ButtonBarButton {
		
		private var _showPieChart:Boolean;
		
		public function ExerciseListRenderer()
		{
			super();
			allowDeselection = false;
		}
		
		[Bindable]
		public function get showPieChart():Boolean {
			return _showPieChart;
		}
		
		public function set showPieChart(value:Boolean):void {
			_showPieChart = value;
		}
	}
}