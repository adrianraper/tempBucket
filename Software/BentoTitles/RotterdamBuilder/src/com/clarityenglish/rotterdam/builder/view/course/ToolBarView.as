package com.clarityenglish.rotterdam.builder.view.course {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLinkEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	
	import org.davekeen.util.StateUtil;
	import org.davekeen.validators.URLValidator;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.ButtonBarButton;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	import spark.primitives.Rect;
	
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
		public var listAddTextButton:Button;
		
		[SkinPart]
		public var normalAddPDFButton:Button;
		
		[SkinPart]
		public var listAddPDFButton:Button;

		[SkinPart]
		public var normalAddVideoButton:Button;
		
		[SkinPart]
		public var listAddVideoButton:Button;
		
		[SkinPart]
		public var normalAddImageButton:Button;
		
		[SkinPart]
		public var listAddImageButton:Button;
		
		[SkinPart]
		public var normalAddAudioButton:Button;
		
		[SkinPart]
		public var listAddAudioButton:Button;
		
		[SkinPart]
		public var normalAddExerciseButton:Button;
		
		[SkinPart]
		public var listAddExerciseButton:Button;
		
		[SkinPart]
		public var normalPreviewButton:Button;
		
		[SkinPart]
		public var normalCancelButton:Button;
		
		[SkinPart]
		public var pdfUploadButton:Button;
		
		[SkinPart]
		public var pdfResourceCloudButton:Button;
		
		[SkinPart]
		public var pdfUrlTextInput:TextInput;
		
		[SkinPart]
		public var imageUploadButton:Button;
		
		[SkinPart]
		public var imageResourceCloudButton:Button;
		
		[SkinPart]
		public var imageUrlTextInput:TextInput;
		
		[SkinPart]
		public var audioUploadButton:Button;
		
		[SkinPart]
		public var audioResourceCloudButton:Button;
		
		[SkinPart]
		public var audioUrlTextInput:TextInput;
		
		[SkinPart]
		public var videoUrlTextInput:TextInput;
		
		//gh #221
		[SkinPart]
		public var webUrlTextInput:TextInput;
		
		[SkinPart]
		public var captionTextInput:TextInput;
				
		[SkinPart]
		public var videoSelectButton:Button;
		
		//gh #221
		[SkinPart]
		public var linkSelectButton:Button;
		
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
		
		[SkinPart]
		public var symbol:Group;
        
		[SkinPart]
		public var itemList:Group;
		
		[SkinPart]
		public var addItemButton:ToggleButton;
		
		//alice: small screen size solution
		[SkinPart]
		public var iconGroup:HGroup;
		
		public var saveCourse:Signal = new Signal();
		public var addText:Signal = new Signal(Object, XML);
		public var addPDF:Signal = new Signal(Object, XML);
		public var addImage:Signal = new Signal(Object, XML);
		public var addAudio:Signal = new Signal(Object, XML);
		public var addVideo:Signal = new Signal(Object, XML);
		public var addExercise:Signal = new Signal(Object, XML);
		public var formatText:Signal = new Signal(Object);
		public var preview:Signal = new Signal();
		public var backToEditor:Signal = new Signal();
		// gh#221
		public var addLink:Signal = new Signal(XML);
		public var cancelLink:Signal = new Signal();

		private var outsideClick:Boolean = false;
		private var itemClick:Boolean = false;
		
		// alice: small screen size solution
		private var smallScreenFlag:Boolean;
		
		private var _currentEditingWidget:XML;
		
		public function ToolBarView() {
			StateUtil.addStates(this, [ "normal", "pdf", "video", "image", "audio", "link", "preview" ], true);
		}
		
		/**
		 * gh#115 - when currentEditingWidget is set the toolbar enters an appropriate mode for editing existing content of a widget.  In most cases this means
		 * changing the state of the toolbar, but 'exercise' is a special case and immediately pops up the content editor.
		 * 
		 * @param widget
		 */
		public function set currentEditingWidget(widget:XML):void {
			_currentEditingWidget = widget;
			
			if (!widget) {
				setCurrentState("normal");
			} else if (widget.@type == "exercise") {
				addExercise.dispatch({}, _currentEditingWidget);
			} else {
				setCurrentState(widget.@type);
			}
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
		
		protected override function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			if (stage.stageWidth == 1200) {
				smallScreenFlag = false;
			} else {
				smallScreenFlag = true;
			}
			
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
			addEventListener(Event.RESIZE, onScreenResize);
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			removeEventListener(Event.RESIZE, onScreenResize);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (smallScreenFlag) {
				addItemButton.visible = true;
				iconGroup.visible = false; 
			} else {
				addItemButton.visible = false;
				iconGroup.visible = true; 
			}
		}
				
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				// Normal toolbar listeners
				case normalSaveButton:
					normalSaveButton.addEventListener(MouseEvent.CLICK, onNormalSave);
					break;
				case listAddTextButton:
					listAddTextButton.addEventListener(MouseEvent.CLICK, onNormalAddText);
					break;
				case normalAddTextButton:
					normalAddTextButton.addEventListener(MouseEvent.CLICK, onNormalAddText);
					break;
				case listAddPDFButton:
					listAddPDFButton.addEventListener(MouseEvent.CLICK, onNormalAddPDF);
					break;
				case normalAddPDFButton:
					normalAddPDFButton.addEventListener(MouseEvent.CLICK, onNormalAddPDF);
					break;
				case listAddVideoButton:
					listAddVideoButton.addEventListener(MouseEvent.CLICK, onNormalAddVideo);
					break;
				case normalAddVideoButton:
					normalAddVideoButton.addEventListener(MouseEvent.CLICK, onNormalAddVideo);
					break;
				case listAddImageButton:
					listAddImageButton.addEventListener(MouseEvent.CLICK, onNormalAddImage);
					break;
				case normalAddImageButton:
					normalAddImageButton.addEventListener(MouseEvent.CLICK, onNormalAddImage);
					break;
				case listAddAudioButton:
					listAddAudioButton.addEventListener(MouseEvent.CLICK, onNormalAddAudio);
					break;
				case normalAddAudioButton:
					normalAddAudioButton.addEventListener(MouseEvent.CLICK, onNormalAddAudio);
					break;
				case listAddExerciseButton:
					listAddExerciseButton.addEventListener(MouseEvent.CLICK, onNormalAddExercise);
					break;
				case normalAddExerciseButton:
					normalAddExerciseButton.addEventListener(MouseEvent.CLICK, onNormalAddExercise);
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
				case pdfResourceCloudButton:
					pdfResourceCloudButton.addEventListener(MouseEvent.CLICK, onPdfCloudUpload);
					break;
				case pdfUrlTextInput:
					pdfUrlTextInput.addEventListener(FlexEvent.ENTER, onPdfUrlEnter);
					break;
				case imageUploadButton:
					imageUploadButton.addEventListener(MouseEvent.CLICK, onImageUpload);
					break;
				case imageResourceCloudButton:
					imageResourceCloudButton.addEventListener(MouseEvent.CLICK, onImageCloudUpload);
					break;
				case imageUrlTextInput:
					imageUrlTextInput.addEventListener(FlexEvent.ENTER, onImageUrlEnter);
					break;
				case audioUploadButton:
					audioUploadButton.addEventListener(MouseEvent.CLICK, onAudioUpload);
					break;
				case audioResourceCloudButton:
					audioResourceCloudButton.addEventListener(MouseEvent.CLICK, onAudioCloudUpload);
					break;
				case audioUrlTextInput:
					audioUrlTextInput.addEventListener(FlexEvent.ENTER, onAudioUrlEnter);
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
				case addItemButton:
					addItemButton.addEventListener(MouseEvent.CLICK, onAddItemClick);
					break;
				case itemList:
					itemList.addEventListener(MouseEvent.CLICK, onItemListClick);
					break;
				//gh #221
				case linkSelectButton:
					linkSelectButton.addEventListener(MouseEvent.CLICK, onLinkSelect);					
					break;
			}
		}
				
		protected function onNormalAddImage(event:MouseEvent):void {
			setCurrentState("image");
			itemClick = true;
		}
		
		protected function onNormalAddAudio(event:MouseEvent):void {
			setCurrentState("audio");
			itemClick = true;
		}
		
		protected function onNormalSave(event:MouseEvent):void {
			saveCourse.dispatch();
		}
		
		protected function onNormalAddText(event:MouseEvent):void {
			addText.dispatch({}, _currentEditingWidget);
			itemClick = true;
		}
		
		protected function onNormalAddPDF(event:MouseEvent):void {
			setCurrentState("pdf");
			itemClick = true;
		}
		
		protected function onNormalAddVideo(event:MouseEvent):void {
			setCurrentState("video");
			itemClick = true;
		}
		
		protected function onNormalAddExercise(event:MouseEvent):void {
			addExercise.dispatch({}, _currentEditingWidget);
			itemClick = true;
		}
		
		//gh #221
		public function onNormalAddWebLink():void {
			setCurrentState("link");
			itemClick = true;
		}
		
		protected function onNormalCancel(event:MouseEvent):void {
			if (this.currentState == "link") {
				cancelLink.dispatch();
			}
			setCurrentState("normal");
		}
		
		protected function onPdfUpload(event:MouseEvent):void {
			addPDF.dispatch( { source: "computer" }, _currentEditingWidget); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onPdfCloudUpload(event:MouseEvent):void {
			addPDF.dispatch( { source: "cloud" }, _currentEditingWidget); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onPdfUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				addPDF.dispatch( { source: "external", url: url }, _currentEditingWidget); // TODO: use a constant from somewhere?
				event.target.text = "";
				setCurrentState("normal");
			}
		}
		
		protected function onImageUpload(event:MouseEvent):void {
			addImage.dispatch( { source: "computer" }, _currentEditingWidget); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onImageCloudUpload(event:MouseEvent):void {
			addImage.dispatch( { source: "cloud" }, _currentEditingWidget); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onImageUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				addImage.dispatch( { source: "external", url: url }, _currentEditingWidget); // TODO: use a constant from somewhere?
				event.target.text = "";
				setCurrentState("normal");
			}
		}
		
		protected function onAudioUpload(event:MouseEvent):void {
			addAudio.dispatch( { source: "computer" }, _currentEditingWidget); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onAudioCloudUpload(event:MouseEvent):void {
			addAudio.dispatch( { source: "cloud" }, _currentEditingWidget); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onAudioUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				addAudio.dispatch( { source: "external", url: url }, _currentEditingWidget); // TODO: use a constant from somewhere?
				event.target.text = "";
				setCurrentState("normal");
			}
		}
		
		protected function onVideoSelect(event:MouseEvent):void {
			var url:String = videoUrlTextInput.text;
			if (url) {
				addVideo.dispatch( { type: "youtube", url: url }, _currentEditingWidget); // TODO: use a constant from somewhere (in fact this isn't used yet)?
				setCurrentState("normal");
			}
		}
		
		//gh #221
		protected function onLinkSelect(event:MouseEvent):void {
			if (webUrlTextInput.text != null) {
				captionTextInput.text = (captionTextInput.text == "")? webUrlTextInput.text: captionTextInput.text;
				var linkXML:XML = <a href={webUrlTextInput.text} target="_blank">{captionTextInput.text}</a> ;
				addLink.dispatch(linkXML);
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
		
		//alice: small screen size solution
		protected function onScreenResize(event:Event):void {
			if (stage.stageWidth == 1200) {
				smallScreenFlag = false;
			} else {
				smallScreenFlag = true;
			}
			invalidateProperties();				
		}
		
		protected function onAddItemClick(event:MouseEvent):void {
			itemList.visible = true;
			outsideClick = false;
		}
		
		protected function onItemListClick(event:MouseEvent):void {
			if (!itemClick) {
				outsideClick = false;
			}
		}
		
		protected function onStageClick(event:MouseEvent):void {
			if (outsideClick) {
				itemList.visible = false;
				addItemButton.skin.setCurrentState("up", true);
				addItemButton.selected = false;
			} else {
				outsideClick = true;
				itemClick = false;
			}

		}
		
		/**
		 * gh#115 - make sure that as soon as we go back to normal state we stop editing any widget.  This should stop hard to track down errors where the
		 * wrong widget is getting changed.
		 * 
		 * @param stateName
		 * @param playTransition
		 */
		public override function setCurrentState(stateName:String, playTransition:Boolean = true):void {
			if (stateName == "normal") _currentEditingWidget = null;
			super.setCurrentState(stateName, playTransition);
		}
		
	}
}