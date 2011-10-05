package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.textLayout.components.AudioPlayer;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.geom.Rectangle;
	import flash.utils.setInterval;
	
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.tlf_internal;
	
	import mx.events.FlexEvent;
	
	import spark.components.supportClasses.SkinnableComponent;

	use namespace tlf_internal;
	
	public class AudioElement extends ImageComponentElement implements IComponentElement {
		
		private var _src:String;
		
		private var _controls:String;
		
		public function AudioElement() {
			super();
		}
		
		public function set src(value:String):void {
			_src = value;
		}
		
		public function set controls(value:String):void {
			_controls = value;
		}
		
		protected override function get abstract():Boolean {
			return false;
		}
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "audio"; }
		
		public function createComponent():void {
			component = new AudioPlayer();
			
			component.addEventListener(FlexEvent.CREATION_COMPLETE, onComponentCreationComplete);
		}
		
		protected function onComponentCreationComplete(event:FlexEvent):void {
			component.removeEventListener(FlexEvent.CREATION_COMPLETE, onComponentCreationComplete);
			
			elementWidth = component.width;
			elementHeight = component.height;
			
			fireElementSizeChanged();
		}
		
	}
	
}