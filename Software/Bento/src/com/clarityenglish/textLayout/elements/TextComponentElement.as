package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.geom.Rectangle;
	import flash.text.engine.BreakOpportunity;
	
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	use namespace tlf_internal;
	
	public class TextComponentElement extends SpanElement {
		
		protected var component:UIComponent;
		
		protected var _hideChrome:Boolean;
		
		public function TextComponentElement() {
			super();
			
			// Hide the text underneath the input
			textAlpha = 0;
			
			// #15
			breakOpportunity = BreakOpportunity.NONE;
		}
		
		protected override function get abstract():Boolean {
			return true;
		}
		
		public function set hideChrome(value:Boolean):void {
			_hideChrome = value;
		}
		
		public function get hideChrome():Boolean {
			return _hideChrome;
		}
		
		public function set enabled(value:Boolean):void {
			component.enabled = value;
		}
		
		public function hasComponent():Boolean {
			return (component !== null);
		}
		
		public function removeComponent():void {
			component.parent.removeChild(component);
			component = null;
		}
		
		public function getComponent():UIComponent {
			return component;
		}
		
		public function getElementBounds():Rectangle {
			return TLFUtil.getFlowElementBounds(this);
		}
		
		/**
		 * Override this method with a blank implementation so that TLF normalize() doesn't fiddle with our custom components.  Specifically this
		 * stops custom text components getting merged together if they have the same styles.
		 * 
		 * @param normalizeStart
		 * @param normalizeEnd
		 */
		tlf_internal override function normalizeRange(normalizeStart:uint, normalizeEnd:uint):void {
			
		}
		
		/**
		 * Override this method with a blank implementation so that TLF normalize() doesn't fiddle with our custom components.  Specifically this
		 * stops custom text components getting merged together if they have the same styles.
		 * 
		 * @return 
		 */
		tlf_internal override function mergeToPreviousIfPossible():Boolean {
			return false;
		}
		
		/**
		 * Override this method with a blank implementation so that TLF normalize() doesn't fiddle with our custom components.  Specifically this
		 * stops tags with no text content from being removed.
		 * 
		 * @return 
		 */
		tlf_internal override function get bindableElement():Boolean {
			return true;
		}
		
	}
}