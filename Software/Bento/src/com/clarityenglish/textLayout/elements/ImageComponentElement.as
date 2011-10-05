package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	use namespace tlf_internal;
	
	public class ImageComponentElement extends InlineGraphicElement {
		
		protected var component:UIComponent;
		
		public function ImageComponentElement() {
			super();
		}
		
		protected override function get abstract():Boolean {
			return true;
		}
		
		protected function fireElementSizeChanged():void {
			getTextFlow().dispatchEvent(new StatusChangeEvent(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, true, false, this, InlineGraphicElementStatus.SIZE_PENDING));
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
			var bounds:Rectangle = TLFUtil.getFlowLeafElementBounds(this);
			bounds.width = (component.initialized) ? component.width : NaN;
			bounds.height = (component.initialized) ? component.height : NaN;
			
			return bounds;
		}
		
	}
}