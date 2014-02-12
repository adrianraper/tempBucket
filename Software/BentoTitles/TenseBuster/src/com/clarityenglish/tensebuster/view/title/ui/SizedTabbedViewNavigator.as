package com.clarityenglish.tensebuster.view.title.ui
{
	import spark.components.TabbedViewNavigator;
	
	public class SizedTabbedViewNavigator extends TabbedViewNavigator
	{
		private var _size:String;
		
		public function SizedTabbedViewNavigator()
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