package com.clarityenglish.activereading.view.home.ui
{
	import spark.components.supportClasses.ButtonBase;
	
	public class MenuButton extends ButtonBase {
		private var _courseIndex:Number;
		private var _courseClass:String;
		
		public function set courseIndex(value:Number):void {
			_courseIndex = value;
		}
		
		[Bindable]
		public function get courseIndex():Number {
			return _courseIndex;
		}
		
		public function set courseClass(value:String):void {
			_courseClass = value;
		}
		
		[Bindable]
		public function get courseClass():String {
			return _courseClass;
		}
	}
}