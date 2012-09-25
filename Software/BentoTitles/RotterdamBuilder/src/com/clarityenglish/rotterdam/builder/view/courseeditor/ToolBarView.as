package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.MouseEvent;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.TextInput;
	
	[SkinState("normal")]
	[SkinState("pdf")]
	[SkinState("video")]
	public class ToolBarView extends BentoView {
		
		[SkinPart]
		public var normalSaveButton:Button;
		
		[SkinPart]
		public var normalAddTextButton:Button;
		
		[SkinPart]
		public var normalAddPDFButton:Button;
		
		[SkinPart]
		public var normalAddVideoButton:Button;
		
		[SkinPart]
		public var normalPreviewButton:Button;
		
		[SkinPart]
		public var normalCancelButton:Button;
		
		[SkinPart]
		public var pdfUploadButton:Button;
		
		[SkinPart]
		public var videoUrlTextInput:TextInput;
		
		[SkinPart]
		public var videoSelectButton:Button;
		
		public var saveCourse:Signal = new Signal();
		public var addText:Signal = new Signal(Object);
		public var addPDF:Signal = new Signal(Object);
		public var addVideo:Signal = new Signal(Object);
		
		public function ToolBarView() {
			StateUtil.addStates(this, [ "normal", "pdf", "video" ], true);
		}
		
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
				case normalAddVideoButton:
					normalAddVideoButton.addEventListener(MouseEvent.CLICK, onNormalAddVideo);
					break;
				case normalPreviewButton:
					break;
				case normalCancelButton:
					normalCancelButton.addEventListener(MouseEvent.CLICK, onNormalCancel);
					break;
				case pdfUploadButton:
					pdfUploadButton.addEventListener(MouseEvent.CLICK, onPdfUpload);
					break;
				case videoSelectButton:
					videoSelectButton.addEventListener(MouseEvent.CLICK, onVideoSelect);
					break;
			}
		}
		
		protected function onNormalSave(event:MouseEvent):void {
			saveCourse.dispatch();
		}
		
		protected function onNormalAddText(event:MouseEvent):void {
			addText.dispatch({});
		}
		
		protected function onNormalAddPDF(event:MouseEvent):void {
			setCurrentState("pdf");
		}
		
		protected function onNormalAddVideo(event:MouseEvent):void {
			setCurrentState("video");
		}
		
		protected function onNormalCancel(event:MouseEvent):void {
			setCurrentState("normal");
		}
		
		protected function onPdfUpload(event:MouseEvent):void {
			addPDF.dispatch( { source: "computer" } ); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onVideoSelect(event:MouseEvent):void {
			var url:String = videoUrlTextInput.text;
			if (url) {
				addVideo.dispatch({ type: "youtube", url: url }); // TODO: use a constant from somewhere?
				setCurrentState("normal");
			}
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}

	}
}