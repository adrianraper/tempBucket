package com.clarityenglish.components {
	import spark.components.IconItemRenderer;
	
	public class DisablableIconItemRenderer extends IconItemRenderer {
		
		protected var _enabledChanged:Boolean;
		
		public function DisablableIconItemRenderer() {
			super();
		}
		
		public override function set enabled(value:Boolean):void {
			super.enabled = value;
			
			_enabledChanged = true;
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (_enabledChanged) {
				_enabledChanged = false;
				
				mouseEnabled = mouseChildren = enabled;
				alpha = (enabled) ? 1 : 0.6;
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			
		}
		
	}
}
