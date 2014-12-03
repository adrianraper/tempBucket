package com.clarityenglish.activereading.view.home.ui {
	import spark.components.supportClasses.ButtonBase;
	
	public class LevelButton extends ButtonBase {
		
		private var _isLabelVisible:Boolean;
		
		public function set isLabelVisible(value:Boolean):void {
			_isLabelVisible = value;
		}
		
		[Bindable]
		public function get isLabelVisible():Boolean {
			return _isLabelVisible;
		}
	}
}