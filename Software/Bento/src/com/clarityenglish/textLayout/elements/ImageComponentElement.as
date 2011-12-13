package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.UIComponent;
	
	use namespace tlf_internal;
	
	public class ImageComponentElement extends InlineGraphicElement {
		
		protected var component:UIComponent;
		
		public function ImageComponentElement() {
			super();
		}
		
		protected override function get abstract():Boolean {
			return true;
		}
		
		/**
		 * This can be called by the concrete child of this class in order to tell the parent text flow that the size of this element may have changed
		 * and everything needs to be laid out again.  Typically called when the component has been added to the stage.
		 */
		protected function fireElementSizeChanged():void {
			getTextFlow().dispatchEvent(new StatusChangeEvent(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, true, false, this, InlineGraphicElementStatus.SIZE_PENDING));
		}
		
		public function get hideChrome():Boolean {
			return false;
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
		
		/**
		 * Get the bounds of the element, but override the width and height (which will be the width and height of the underlying image).  If the component is not
		 * yet initialized return NaN which tells overlay behaviour not to attempt to set a size on the component as it is not yet ready.
		 * 
		 * @return 
		 */
		public function getElementBounds():Rectangle {
			var bounds:Rectangle = TLFUtil.getFlowElementBounds(this);
			
			if (bounds) {
				bounds.width = (component.initialized) ? component.width : NaN;
				bounds.height = (component.initialized) ? component.height : NaN;
			}
			
			return bounds;
		}
		
	}
}