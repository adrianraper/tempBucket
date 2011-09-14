package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.SpanElement;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	public class TextComponentElement extends SpanElement {
		
		protected var component:UIComponent;
		
		public function TextComponentElement() {
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
			return TLFUtil.getFlowLeafElementBounds(this);
		}
		
	}
}