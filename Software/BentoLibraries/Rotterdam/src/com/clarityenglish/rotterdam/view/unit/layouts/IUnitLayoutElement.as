package com.clarityenglish.rotterdam.view.unit.layouts {
	import mx.core.ILayoutElement;

	public interface IUnitLayoutElement extends ILayoutElement {
		
		function set column(value:uint):void;
		function get column():uint;
		
		function set span(value:uint):void;
		function get span():uint;
		
	}
}