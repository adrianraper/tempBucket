package com.clarityenglish.textLayout.elements {
	import flash.geom.Rectangle;
	
	import flashx.textLayout.formats.ITextLayoutFormat;
	
	import mx.core.UIComponent;
	
	public interface IComponentElement {
		
		function hasComponent():Boolean;
		
		function createComponent():void;
		
		function removeComponent():void;
		
		function getComponent():UIComponent;
		
		function getElementBounds():Rectangle;
		
		function get computedFormat():ITextLayoutFormat;
		
	}
	
}