package com.clarityenglish.common.view.error {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Label;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	
	public class ErrorView extends BentoView {
		
		[SkinPart]
		public var closeButton:Button;
		
		[SkinPart]
		public var message:Label;
		
		[Bindable]
		public var error:BentoError;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			// Add an OK button that triggers the close event
			switch (instance) {
				case closeButton:
					instance.addEventListener(MouseEvent.CLICK, onCloseButtonClick);
					break;				
			}
			
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
		}
		
		protected function onCloseButtonClick(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
	
}