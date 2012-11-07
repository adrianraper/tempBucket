package com.clarityenglish.rotterdam.view.unit.layouts {
	import mx.core.ILayoutElement;

	public interface IUnitLayoutElement extends ILayoutElement {
		
		function get column():uint;
		function get ypos():uint; // TODO: this is just to implement #17 and will not last
		function set layoutheight(value:uint):void; // TODO: this is just to implement #17 and will not last
		function get span():uint;
		
	}
}