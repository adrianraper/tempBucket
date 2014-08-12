package com.clarityenglish.ieltsair.view.candidates {
	import spark.components.ButtonBarButton;
	
	public class IndexButtonBarButton extends ButtonBarButton {
		
		private var _index:Number;
		private var _imageSource:String;
		
		public function IndexButtonBarButton():void {
			super();
			allowDeselection = false;
		}
		
		[Bindable]
		public function get index():Number {
			return _index;
		}
		
		public function set index(value:Number):void {
			_index = value;
		}
		
		[Bindable]
		public function get imageSource():String {
			return _imageSource;
		}
		
		public function set imageSource(value:String):void {
			_imageSource = value;
		}
	}
}