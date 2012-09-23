package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	
	public class ToolBarView extends BentoView {
		
		[SkinPart]
		public var normalSaveButton:Button;
		
		[SkinPart]
		public var normalAddTextButton:Button;
		
		[SkinPart]
		public var normalAddPDFButton:Button;
		
		[SkinPart]
		public var normalPreviewButton:Button;
		
		public var saveCourse:Signal = new Signal();
		public var addText:Signal = new Signal();
		public var addPDF:Signal = new Signal();
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				// Normal toolbar listeners
				case normalSaveButton:
					normalSaveButton.addEventListener(MouseEvent.CLICK, onNormalSave);
					break;
				case normalAddTextButton:
					normalAddTextButton.addEventListener(MouseEvent.CLICK, onNormalAddText);
					break;
				case normalAddPDFButton:
					normalAddPDFButton.addEventListener(MouseEvent.CLICK, onNormalAddPDF);
					break;
				case normalPreviewButton:
					break;
			}
		}
		
		protected function onNormalSave(event:MouseEvent):void {
			saveCourse.dispatch();
		}
		
		protected function onNormalAddText(event:MouseEvent):void {
			addText.dispatch();
		}
		
		protected function onNormalAddPDF(event:MouseEvent):void {
			addPDF.dispatch();
		}
		
		protected override function getCurrentSkinState():String {
			return super.getCurrentSkinState();
		}

	}
}