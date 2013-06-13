package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.tlf_internal;
	
	import mx.events.FlexEvent;

	use namespace tlf_internal;
	
	public class AudioElement extends ImageComponentElement implements IComponentElement {
		
		private var _src:String;
		
		private var _controls:String;
		
		private var _autoplay:Boolean;
		
		// gh#348
		private var _type:String;
		
		public function AudioElement() {
			super();
		}
		
		public function set src(value:String):void {
			_src = value;
		}
		
		public function set controls(value:String):void {
			_controls = value;
		}
		
		// gh#348
		public function set type(value:String):void {
			_type = value;
		}
		
		[Bindable]
		public function get type():String {
			return _type
		}
		
		public function set autoplay(value:String):void {
			// autoplay="autoplay" and autoplay="" are both 'on' values in HTML5 syntax so set autoplay if its anything but null
			_autoplay = (value != null);
		}
		
		protected override function get abstract():Boolean {
			return false;
		}
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "audio"; }
		
		public function createComponent():void {
			component = new AudioPlayer();
			(component as AudioPlayer).src = _src;
			(component as AudioPlayer).controls = _controls;
			(component as AudioPlayer).autoplay = _autoplay;
			
			component.addEventListener(FlexEvent.CREATION_COMPLETE, onComponentCreationComplete);
		}
		
		// gh348
		public function removeCompoment():void {
			component = new AudioPlayer();
			(component as AudioPlayer).src = null;
			(component as AudioPlayer).controls = null;
			(component as AudioPlayer).autoplay = false;
		}
		
		protected function onComponentCreationComplete(event:FlexEvent):void {
			if (component) {
				component.removeEventListener(FlexEvent.CREATION_COMPLETE, onComponentCreationComplete);
				
				// This needs to use the measured size
				elementWidth = component.measuredWidth;
				elementHeight = component.measuredHeight;
				
				fireElementSizeChanged();
			}
		}
		
		public override function getElementBounds():Rectangle {
			var bounds:Rectangle = super.getElementBounds();
			if (bounds) {
				bounds.width = (component.initialized) ? component.measuredWidth : NaN;
				bounds.height = (component.initialized) ? component.measuredHeight : NaN;
			}
			
			return bounds;
		}
		
	}
	
}