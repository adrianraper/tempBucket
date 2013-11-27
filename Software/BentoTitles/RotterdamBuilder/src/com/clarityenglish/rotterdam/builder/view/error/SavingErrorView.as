package com.clarityenglish.rotterdam.builder.view.error {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.builder.view.error.events.SaveEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	
	public class SavingErrorView extends BentoView {
		[SkinPart]
		public var problemLabel:Label;
		
		[SkinPart]
		public var closeButton:Button;
		
		[SkinPart]
		public var saveButton:Button;
		
		[SkinPart]
		public var message:Label;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case closeButton:
					instance.addEventListener(MouseEvent.CLICK, onCloseButtonClick);
					instance.label = copyProvider.getCopyForId("closeButton");
					break;
				case saveButton:
					instance.addEventListener(MouseEvent.CLICK, onSaveButtonClick);
					instance.label = copyProvider.getCopyForId("saveButton");
					break;
				case problemLabel:
					instance.text = copyProvider.getCopyForId("problemLabel");
					break;
				case message:
					instance.text = copyProvider.getCopyForId("courseSavingError", {saveButtonLabel: copyProvider.getCopyForId("saveButton"), supportEmail:"support@clarityenglish.com"});
					break;
			}
			
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
		}
		
		protected function onCloseButtonClick(event:MouseEvent):void {
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onSaveButtonClick(event:MouseEvent):void {
			dispatchEvent(new SaveEvent(SaveEvent.COURSE_SAVE_ERROR, true));
		}
		
	}
	
}