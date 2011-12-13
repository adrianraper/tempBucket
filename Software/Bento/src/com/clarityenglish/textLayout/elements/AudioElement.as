package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.textLayout.components.AudioPlayer;
	
	import flashx.textLayout.tlf_internal;
	
	import mx.events.FlexEvent;

	use namespace tlf_internal;
	
	public class AudioElement extends ImageComponentElement implements IComponentElement {
		
		private var _src:String;
		
		private var _controls:String;
		
		private var _autoplay:Boolean;
		
		public function AudioElement() {
			super();
		}
		
		public function set src(value:String):void {
			_src = value;
		}
		
		public function set controls(value:String):void {
			_controls = value;
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
		
		protected function onComponentCreationComplete(event:FlexEvent):void {
			if (component) {
				component.removeEventListener(FlexEvent.CREATION_COMPLETE, onComponentCreationComplete);
				
				// TODO: I have no idea why, but suddenly these are all returning 0 (except when debugging they show the correct values...).  This is causing text to flow over the
				// audio player component.
				elementWidth = component.width;
				elementHeight = component.height;
				
				fireElementSizeChanged();
			}
		}
		
	}
	
}