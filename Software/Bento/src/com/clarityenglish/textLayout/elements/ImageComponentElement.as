package com.clarityenglish.textLayout.elements {
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.InlineGraphicElement;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	public class ImageComponentElement extends InlineGraphicElement {
		
		protected var component:UIComponent;
		
		public function ImageComponentElement() {
			super();
		}
		
		protected override function get abstract():Boolean {
			return true;
		}
		
		public function hasComponent():Boolean {
			return (component !== null);
		}
		
		public function removeComponent():void {
			(component.parent as Group).removeElement(component);
			component = null;
		}
		
		public function getComponent():UIComponent {
			return component;
		}
		
		public function getElementBounds():Rectangle {
			return null;
		}
		
	}
}