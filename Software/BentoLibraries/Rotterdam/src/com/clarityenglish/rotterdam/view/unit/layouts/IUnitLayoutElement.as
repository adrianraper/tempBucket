package com.clarityenglish.rotterdam.view.unit.layouts {
	import mx.core.ILayoutElement;

	public interface IUnitLayoutElement extends ILayoutElement {
		
		function get column():uint;
		function get ypos():uint;
		function get span():uint;
		
	}
}