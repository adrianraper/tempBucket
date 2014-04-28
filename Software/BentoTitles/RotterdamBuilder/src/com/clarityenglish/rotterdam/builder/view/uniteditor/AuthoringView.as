package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	
	public class AuthoringView extends BentoView {
		
		[SkinPart(required="true")]
		public var okButton:Button;
		
		[SkinPart(required="true")]
		public var cancelButton:Button;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case okButton:
					okButton.addEventListener(MouseEvent.CLICK, onSelectButton);
					okButton.label = copyProvider.getCopyForId("okButton");
					break;
				case cancelButton:
					cancelButton.addEventListener(MouseEvent.CLICK, onCancelButton);
					cancelButton.label = copyProvider.getCopyForId("cancelButton");
					break;
			}
		}
		
		protected function onSelectButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onCancelButton(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
	}
}