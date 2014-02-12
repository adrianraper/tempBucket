package com.clarityenglish.tensebuster.view.title.ui
{
	import spark.components.Button;
	
	public class SizedButton extends Button
	{
		private var _size:String;
		
		public function SizedButton()
		{
			super();
		}
		
		public function set size(value:String):void {
			_size = value;
		}
		
		[Bindable]
		public function get size():String {
			return _size;
		}
	}
}