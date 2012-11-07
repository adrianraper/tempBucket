package com.clarityenglish.rotterdam.view.unit.layouts {
	
	public interface IUnitLayout {
		
		function getColumnFromX(x:Number):int;
		function getDropIndex(x:Number, y:Number):int;
		function updateElementFromDrag(item:Object, x:Number, y:Number):void;
		function set columns(value:int):void;
		function get columns():int;
		
	}
	
}