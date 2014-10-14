package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flash.geom.Rectangle;
	
	import mx.events.FlexEvent;
	
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;
	
	public class AudioElement extends ImageComponentElement implements IComponentElement {
		
		private var _src:String;
		
		private var _controls:String;
		
		private var _autoplay:Boolean;
		
		private var _playComponentEnable:Boolean;
		
		public function AudioElement() {
			super();
		}
		
		public function set src(value:String):void {
			_src = value;
		}
		
		public function set controls(value:String):void {
			_controls = value;
		}
		
		// disable playComponent for feedback audio before click "see answer"
		public function set playComponentEnable(value:Boolean):void {
			_playComponentEnable = value;
			(component as AudioPlayer).playComponentEnable = value;
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
		
		// gh#348
		public function clearComponent():void {
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