package com.clarityenglish.common.view.error {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	
	public class ErrorView extends BentoView {
		[SkinPart]
		public var problemLabel:Label;
		
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
					// gh#999 This might be happening before copy loaded
					if (copyProvider.isCopyLoaded()) {
						instance.label = copyProvider.getCopyForId("closeButton");
					} else {
						instance.label = 'OK';						
					}
					break;
				case problemLabel:
					if (copyProvider.isCopyLoaded()) {
						instance.text = copyProvider.getCopyForId("stdErrorTitle");
					} else {
						instance.text = 'Sorry, there is a problem...';						
					}
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