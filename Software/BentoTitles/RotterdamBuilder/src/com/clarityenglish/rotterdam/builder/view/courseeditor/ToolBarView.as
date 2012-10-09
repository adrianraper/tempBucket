package com.clarityenglish.rotterdam.builder.view.courseeditor {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.MouseEvent;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	
	[SkinState("normal")]
	[SkinState("pdf")]
	[SkinState("video")]
	public class ToolBarView extends BentoView {
		
		/**
		 * The font sizes for the three buttons
		 */
		private static var FONT_SIZES:Array = [ 14, 16, 18 ];
		
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
		
		[SkinPart]
		public var previewBackToEditorButton:Button;
		
		[SkinPart]
		public var boldButton:ToggleButton;
		
		[SkinPart]
		public var fontSize1Button:ToggleButton;
		
		[SkinPart]
		public var fontSize2Button:ToggleButton;
		
		[SkinPart]
		public var fontSize3Button:ToggleButton;
		
		public var saveCourse:Signal = new Signal();
		public var addText:Signal = new Signal(Object);
		public var addPDF:Signal = new Signal(Object);
		public var addVideo:Signal = new Signal(Object);
		public var formatText:Signal = new Signal(Object);
		public var preview:Signal = new Signal();
		public var backToEditor:Signal = new Signal();
		
		public function ToolBarView() {
			StateUtil.addStates(this, [ "normal", "pdf", "video", "preview" ], true);
		}
		
		public function setCurrentTextFormat(format:TextLayoutFormat):void {
			// Set the bold button
			boldButton.selected = (format.fontWeight == FontWeight.BOLD);
			
			// Set the font size
			switch (format.fontSize) {
				case FONT_SIZES[0]:
					selectFontSizeButton(fontSize1Button);
					break;
				case FONT_SIZES[1]:
					selectFontSizeButton(fontSize2Button);
					break;
				case FONT_SIZES[2]:
					selectFontSizeButton(fontSize3Button);
					break;
			}
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
					normalPreviewButton.addEventListener(MouseEvent.CLICK, onNormalPreview);
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
				case previewBackToEditorButton:
					previewBackToEditorButton.addEventListener(MouseEvent.CLICK, onPreviewBackToEditor);
					break;
				case boldButton:
					boldButton.addEventListener(MouseEvent.CLICK, onBoldChange);
					break;
				case fontSize1Button:
				case fontSize2Button:
				case fontSize3Button:
					instance.addEventListener(MouseEvent.CLICK, onFontSizeChange);
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
				addVideo.dispatch({ type: "youtube", url: url }); // TODO: use a constant from somewhere (in fact this isn't used yet)?
				setCurrentState("normal");
			}
		}
		
		protected function onNormalPreview(event:MouseEvent):void {
			preview.dispatch();
			setCurrentState("preview");
		}
		
		protected function onPreviewBackToEditor(event:MouseEvent):void {
			backToEditor.dispatch();
			setCurrentState("normal");
		}
		
		protected function onBoldChange(event:MouseEvent):void {
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.fontWeight = (boldButton.selected) ? FontWeight.BOLD : FontWeight.NORMAL;
			formatText.dispatch( { format: format } );
		}
		
		protected function onFontSizeChange(event:MouseEvent):void {
			// It isn't really 'correct' to have 3 toggle buttons, but ButtonBars are such a hassle to skin that this is way quicker
			var selectedButton:ToggleButton = event.target as ToggleButton;
			selectFontSizeButton(selectedButton);
			
			var format:TextLayoutFormat = new TextLayoutFormat();
			
			switch (selectedButton) {
				case fontSize1Button:
					format.fontSize = FONT_SIZES[0];
					break;
				case fontSize2Button:
					format.fontSize = FONT_SIZES[1];
					break;
				case fontSize3Button:
					format.fontSize = FONT_SIZES[2];
					break;
			}
			
			formatText.dispatch( { format: format } );
		}
		
		protected function selectFontSizeButton(selectedButton:ToggleButton):void {
			// Make sure that only one button is selected at a time
			for each (var button:ToggleButton in [ fontSize1Button, fontSize2Button, fontSize3Button ])
				button.selected = false;
			
			selectedButton.selected = true;
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}

	}
}