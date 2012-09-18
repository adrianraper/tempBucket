package com.clarityenglish.rotterdam.view.unit.widgets {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayoutElement;
	
	public class AbstractWidget extends SkinnableItemRenderer implements IUnitLayoutElement {
		
		protected var _xml:XML;
		
		private var _column:uint;
		private var _span:uint = 1;
		private var _data:Object;
		
		public function set column(value:uint):void {
			_column = value;
		}
		
		public function get column():uint {
			return _column;
		}
		
		public function set span(value:uint):void {
			_span = value;
		}
		
		public function get span():uint {
			return _span;
		}
		
		public function AbstractWidget() {
			super();
		}
		
	}
}
