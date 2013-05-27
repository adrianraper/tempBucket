package com.clarityenglish.rotterdam.builder.view.course {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.FontStyle;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	
	import org.davekeen.util.StateUtil;
	import org.davekeen.validators.URLValidator;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	import spark.effects.Animate;
	
	public class ToolBarView extends BentoView {
		
		/**
		 * The font sizes for the three buttons
		 */
		private static var FONT_SIZES:Array = [ 13, 15, 17 ];
			
		[SkinPart]
		public var normalSaveButton:Button;
		
		[SkinPart]
		public var normalAddTextButton:Button;
		
		[SkinPart]
		public var listAddTextButton:Button;
		
		[SkinPart]
		public var addTextLabel:Label;
		
		[SkinPart]
		public var normalAddPDFButton:Button;
		
		[SkinPart]
		public var listAddPDFButton:Button;
		
		[SkinPart]
		public var addPDFLabel:Label;

		[SkinPart]
		public var normalAddVideoButton:Button;
		
		[SkinPart]
		public var listAddVideoButton:Button;
		
		[SkinPart]
		public var addVideoLabel:Label;
		
		[SkinPart]
		public var normalAddImageButton:Button;
		
		[SkinPart]
		public var listAddImageButton:Button;
		
		[SkinPart]
		public var addIamgeLabel:Label;
		
		[SkinPart]
		public var normalAddAudioButton:Button;
		
		[SkinPart]
		public var listAddAudioButton:Button;
		
		[SkinPart]
		public var addAudioLabel:Label;
		
		[SkinPart]
		public var normalAddExerciseButton:Button;
		
		[SkinPart]
		public var listAddExerciseButton:Button;
		
		[SkinPart]
		public var addExerciseLabel:Label;
		
		[SkinPart]
		public var normalPreviewButton:Button;
		
		[SkinPart]
		public var normalCancelButton:Button;
		
		[SkinPart]
		public var pdfUploadButton:Button;
		
		[SkinPart]
		public var uploadPDFLabel:Label;
		
		[SkinPart]
		public var pdfResourceCloudButton:Button;
		
		[SkinPart]
		public var pdfUrlTextInput:TextInput;
		
		[SkinPart]
		public var pdfOrLabel:Label;
		
		[SkinPart]
		public var pdfOrLabel2:Label;
		
		[SkinPart]
		public var imageUploadButton:Button;
		
		[SkinPart]
		public var uploadImageLabel:Label;
		
		[SkinPart]
		public var imageResourceCloudButton:Button;
		
		[SkinPart]
		public var imageUrlTextInput:TextInput;
		
		[SkinPart]
		public var imageOrLabel:Label;
		
		[SkinPart]
		public var imageOrLabel2:Label;
		
		[SkinPart]
		public var audioUploadButton:Button;
		
		[SkinPart]
		public var uploadAudioLabel:Label;
		
		[SkinPart]
		public var audioResourceCloudButton:Button;
		
		[SkinPart]
		public var audioUrlTextInput:TextInput;
		
		[SkinPart]
		public var audioOrLabel:Label;
		
		[SkinPart]
		public var audioOrLabel2:Label;
		
		[SkinPart]
		public var videoUrlTextInput:TextInput;
		
		[SkinPart]
		public var webLinkURLLabel:Label;
		
		[SkinPart]
		public var webLinkTextLabel:Label;
		
		// gh#221
		[SkinPart]
		public var webUrlTextInput:TextInput;
		
		[SkinPart]
		public var captionTextInput:TextInput;
				
		[SkinPart]
		public var videoSelectButton:Button;
		
		[SkinPart]
		public var uploadVideoLabel:Label;
		
		// gh#221
		[SkinPart]
		public var linkSelectButton:Button;
		
		[SkinPart]
		public var previewBackToEditorButton:Button;
		
		[SkinPart]
		public var boldButton:ToggleButton;
		
		[SkinPart]
		public var underlineButton:ToggleButton;
		
		[SkinPart]
		public var italicButton:ToggleButton;
		
		[SkinPart]
		public var fontSize1Button:ToggleButton;
		
		[SkinPart]
		public var fontSize2Button:ToggleButton;
		
		[SkinPart]
		public var fontSize3Button:ToggleButton;
		
		[SkinPart]
		public var urlButton:Button;
		
		[SkinPart]
		public var symbol:Group;
        
		[SkinPart]
		public var itemList:Group;
		
		[SkinPart]
		public var itemListLabel:Label;
		
		[SkinPart]
		public var itemListLabel2:Label;
		
		[SkinPart]
		public var addItemButton:ToggleButton;
		
		[SkinPart]
		public var upButton:Button;
		
		// alice: small screen size solution
		[SkinPart]
		public var iconGroup:HGroup;
		
		[SkinPart]
		public var addItemButtonGroup:Group;
		
		[SkinPart]
		public var downButton:Button;
		
		[SkinPart]
		public var upAnim:Animate;
		
		[SkinPart]
		public var largePopUpGroup:Group;
		
		[SkinPart]
		public var smallPopUpGroup:Group;
		
		public var saveCourse:Signal = new Signal();
		public var addText:Signal = new Signal(Object, XML);
		public var addPDF:Signal = new Signal(Object, XML, String);
		public var addImage:Signal = new Signal(Object, XML, String);
		public var addAudio:Signal = new Signal(Object, XML, String);
		public var addVideo:Signal = new Signal(Object, XML);
		public var addExercise:Signal = new Signal(Object, XML, String);
		public var formatText:Signal = new Signal(Object);
		public var preview:Signal = new Signal();
		public var backToEditor:Signal = new Signal();
		// gh#221
		public var addLink:Signal = new Signal(String, String);
		public var cancelLink:Signal = new Signal();

		private var isOutsideClick:Boolean;
		private var isItemClick:Boolean;
		private var isUpArrowClick:Boolean = false;
		public var isDownArrowClick:Boolean;
		public var captureCaption:String;
		
		// alice: small screen size solution
		private var smallScreenFlag:Boolean;
		
		private var _currentEditingWidget:XML;
		private var _urlCaption:String = "";
		
		[Bindable]
		private var contentWindowTitle:String;
		
		[Bindable]
		private var cloudWindowTitle:String;
		
		[Bindable]
		public function get urlCaption():String {
			return _urlCaption;
		}
		
		public function set urlCaption(value:String):void {
			if (value) {
				_urlCaption = value;
			}
		}
		
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
				addExercise.dispatch({}, _currentEditingWidget, contentWindowTitle);
				_currentEditingWidget = null;
			} else {
				setCurrentState(widget.@type);
			}
		}
		
		public function setCurrentTextFormat(format:TextLayoutFormat):void {
			// Set the bold button
			boldButton.selected = (format.fontWeight == FontWeight.BOLD);
			underlineButton.selected = (format.textDecoration == TextDecoration.UNDERLINE);
			italicButton.selected = (format.fontStyle == FontStyle.ITALIC);
				
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
			
			smallScreenFlag = (stage.stageWidth < 1200);
			stage.addEventListener(MouseEvent.CLICK, onStageClick);
			addEventListener(Event.RESIZE, onScreenResize);
			
			contentWindowTitle = copyProvider.getCopyForId("contentWindowTitle");
			cloudWindowTitle = copyProvider.getCopyForId("resourceCloudButton");
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			removeEventListener(Event.RESIZE, onScreenResize);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (addItemButton) {
				if (smallScreenFlag) {
					addItemButton.visible = true;
					iconGroup.visible = false; 
				} else {
					if (isUpArrowClick) {
						iconGroup.visible = false;
					} else {
						iconGroup.visible = true; 
					}
					addItemButton.visible = false;
					
				}
			}		
		}
				
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				// Normal toolbar listeners
				case normalSaveButton:
					normalSaveButton.addEventListener(MouseEvent.CLICK, onNormalSave);
					normalSaveButton.label = copyProvider.getCopyForId("normalSaveButton");
					break;
				case listAddTextButton:
					listAddTextButton.addEventListener(MouseEvent.CLICK, onNormalAddText);
					break;
				case addTextLabel:
					addTextLabel.text = copyProvider.getCopyForId("addTextLabel");
					break;
				case normalAddTextButton:
					normalAddTextButton.addEventListener(MouseEvent.CLICK, onNormalAddText);
					break;
				case listAddPDFButton:
					listAddPDFButton.addEventListener(MouseEvent.CLICK, onNormalAddPDF);
					break;
				case addPDFLabel:
					addPDFLabel.text = copyProvider.getCopyForId("addPDFLabel");
					break;
				case normalAddPDFButton:
					normalAddPDFButton.addEventListener(MouseEvent.CLICK, onNormalAddPDF);
					break;
				case listAddVideoButton:
					listAddVideoButton.addEventListener(MouseEvent.CLICK, onNormalAddVideo);
					break;
				case addVideoLabel:
					addVideoLabel.text = copyProvider.getCopyForId("addVideoLabel");
					break;
				case normalAddVideoButton:
					normalAddVideoButton.addEventListener(MouseEvent.CLICK, onNormalAddVideo);
					break;
				case listAddImageButton:
					listAddImageButton.addEventListener(MouseEvent.CLICK, onNormalAddImage);
					break;
				case addIamgeLabel:
					addIamgeLabel.text = copyProvider.getCopyForId("addIamgeLabel");
					break;
				case normalAddImageButton:
					normalAddImageButton.addEventListener(MouseEvent.CLICK, onNormalAddImage);
					break;
				case listAddAudioButton:
					listAddAudioButton.addEventListener(MouseEvent.CLICK, onNormalAddAudio);
					break;
				case addAudioLabel:
					addAudioLabel.text = copyProvider.getCopyForId("addAudioLabel");
					break;
				case normalAddAudioButton:
					normalAddAudioButton.addEventListener(MouseEvent.CLICK, onNormalAddAudio);
					break;
				case listAddExerciseButton:
					listAddExerciseButton.addEventListener(MouseEvent.CLICK, onNormalAddExercise);
					break;
				case addExerciseLabel:
					addExerciseLabel.text = copyProvider.getCopyForId("addExerciseLabel");
					break;
				case normalAddExerciseButton:
					normalAddExerciseButton.addEventListener(MouseEvent.CLICK, onNormalAddExercise);
					break;
				case normalPreviewButton:
					normalPreviewButton.addEventListener(MouseEvent.CLICK, onNormalPreview);
					normalPreviewButton.label = copyProvider.getCopyForId("normalPreviewButton");
					break;
				case normalCancelButton:
					normalCancelButton.addEventListener(MouseEvent.CLICK, onNormalCancel);
					normalCancelButton.label = copyProvider.getCopyForId("cancelButton");
					break;
				case pdfUploadButton:
					pdfUploadButton.addEventListener(MouseEvent.CLICK, onPdfUpload);
					pdfUploadButton.label = copyProvider.getCopyForId("myComputerButton");
					break;
				case uploadPDFLabel:
					uploadPDFLabel.text = copyProvider.getCopyForId("uploadPDFLabel");
					break;
				case pdfResourceCloudButton:
					pdfResourceCloudButton.addEventListener(MouseEvent.CLICK, onPdfCloudUpload);
					pdfResourceCloudButton.label = copyProvider.getCopyForId("resourceCloudButton");
					break;
				case pdfOrLabel:
				case pdfOrLabel2:
					instance.text = copyProvider.getCopyForId("orLabel");
					break;
				case pdfUrlTextInput:
					pdfUrlTextInput.addEventListener(FlexEvent.ENTER, onPdfUrlEnter);
					break;
				case imageUploadButton:
					imageUploadButton.addEventListener(MouseEvent.CLICK, onImageUpload);
					imageUploadButton.label = copyProvider.getCopyForId("myComputerButton");
					break;
				case uploadImageLabel:
					uploadImageLabel.text = copyProvider.getCopyForId("uploadImageLabel");
					break;
				case imageResourceCloudButton:
					imageResourceCloudButton.addEventListener(MouseEvent.CLICK, onImageCloudUpload);
					imageResourceCloudButton.label = copyProvider.getCopyForId("resourceCloudButton");
					break;
				case imageUrlTextInput:
					imageUrlTextInput.addEventListener(FlexEvent.ENTER, onImageUrlEnter);
					break;
				case imageOrLabel:
				case imageOrLabel2:
					instance.text = copyProvider.getCopyForId("orLabel");
					break;
				case audioUploadButton:
					audioUploadButton.addEventListener(MouseEvent.CLICK, onAudioUpload);
					audioUploadButton.label = copyProvider.getCopyForId("myComputerButton");
					break;
				case uploadAudioLabel:
					uploadAudioLabel.text = copyProvider.getCopyForId("uploadAudioLabel");
					break;
				case audioOrLabel:
				case audioOrLabel2:
					instance.text = copyProvider.getCopyForId("orLabel");
					break;
				case audioResourceCloudButton:
					audioResourceCloudButton.addEventListener(MouseEvent.CLICK, onAudioCloudUpload);
					audioResourceCloudButton.label = copyProvider.getCopyForId("resourceCloudButton");
					break;
				case audioUrlTextInput:
					audioUrlTextInput.addEventListener(FlexEvent.ENTER, onAudioUrlEnter);
					break;
				case videoSelectButton:
					videoSelectButton.addEventListener(MouseEvent.CLICK, onVideoSelect);
					videoSelectButton.label = copyProvider.getCopyForId("selectButton");
					break;
				case uploadVideoLabel:
					uploadVideoLabel.text = copyProvider.getCopyForId("uploadVideoLabel");
					break;
				case webLinkURLLabel:
					webLinkURLLabel.text = copyProvider.getCopyForId("webLinkURLLabel");
					break;
				case webLinkTextLabel:
					webLinkTextLabel.text = copyProvider.getCopyForId("webLinkTextLabel");
					break;
				case previewBackToEditorButton:
					previewBackToEditorButton.addEventListener(MouseEvent.CLICK, onPreviewBackToEditor);
					previewBackToEditorButton.label = copyProvider.getCopyForId("backButton");
					break;
				case boldButton:
					boldButton.addEventListener(MouseEvent.CLICK, onBoldChange);
					break;
				case underlineButton:
					underlineButton.addEventListener(MouseEvent.CLICK, onUnderlineChange);
					break;
				case italicButton:
					italicButton.addEventListener(MouseEvent.CLICK, onItalicChange);
					break;
				case fontSize1Button:
				case fontSize2Button:
				case fontSize3Button:
					instance.addEventListener(MouseEvent.CLICK, onFontSizeChange);
					break;
				case urlButton:
					urlButton.addEventListener(MouseEvent.CLICK, onURLClick);
					break;
				case addItemButton:
					addItemButton.addEventListener(MouseEvent.CLICK, onAddItemClick);
					addItemButton.label = copyProvider.getCopyForId("addItemButton");
					break;
				case itemList:
					itemList.addEventListener(MouseEvent.CLICK, onItemListClick);
					break;
				case itemListLabel:
				case itemListLabel2:
					instance.text = copyProvider.getCopyForId("itemListLabel");
					break;
				// gh#221
				case linkSelectButton:
					linkSelectButton.addEventListener(MouseEvent.CLICK, onLinkSelect);
					linkSelectButton.label = copyProvider.getCopyForId("selectButton");
					break;
				case upButton:
					upButton.addEventListener(MouseEvent.CLICK, onUpClick);
					upButton.label = copyProvider.getCopyForId("upButton");
					break;
				case downButton:
					downButton.addEventListener(MouseEvent.CLICK, onDownClick);
					break;
				case upAnim:
					upAnim.addEventListener(EffectEvent.EFFECT_END, onUpAimEnd);
					break;
			}
		}
				
		protected function onNormalAddImage(event:MouseEvent):void {
			setCurrentState("image");
			isItemClick = true;
		}
		
		protected function onNormalAddAudio(event:MouseEvent):void {
			setCurrentState("audio");
			isItemClick = true;
		}
		
		protected function onNormalSave(event:MouseEvent):void {
			saveCourse.dispatch();
		}
		
		protected function onNormalAddText(event:MouseEvent):void {
			addText.dispatch({}, _currentEditingWidget);
			isItemClick = true;
		}
		
		protected function onNormalAddPDF(event:MouseEvent):void {
			setCurrentState("pdf");
			isItemClick = true;
		}
		
		protected function onNormalAddVideo(event:MouseEvent):void {
			setCurrentState("video");
			isItemClick = true;
		}
		
		protected function onNormalAddExercise(event:MouseEvent):void {
			addExercise.dispatch({}, _currentEditingWidget, contentWindowTitle);
			isItemClick = true;
		}
		
		// gh#306
		public function onURLClick(event:MouseEvent):void {
			setCurrentState("link");
			callLater(function():void { 
				if (urlCaption) {
					captionTextInput.text = urlCaption;
				}
			});
			isItemClick = true;
		}
		
		protected function onNormalCancel(event:MouseEvent):void {
			if (this.currentState == "link") {
				cancelLink.dispatch();
			}
			setCurrentState("normal");
		}
		
		protected function onPdfUpload(event:MouseEvent):void {
			addPDF.dispatch( { source: "computer" }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onPdfCloudUpload(event:MouseEvent):void {
			addPDF.dispatch( { source: "cloud" }, _currentEditingWidget, cloudWindowTitle); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onPdfUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				addPDF.dispatch( { source: "external", url: url }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
				event.target.text = "";
				setCurrentState("normal");
			}
		}
		
		protected function onImageUpload(event:MouseEvent):void {
			addImage.dispatch( { source: "computer" }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onImageCloudUpload(event:MouseEvent):void {
			addImage.dispatch( { source: "cloud" }, _currentEditingWidget, cloudWindowTitle); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onImageUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				addImage.dispatch( { source: "external", url: url }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
				event.target.text = "";
				setCurrentState("normal");
			}
		}
		
		protected function onAudioUpload(event:MouseEvent):void {
			addAudio.dispatch( { source: "computer" }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onAudioCloudUpload(event:MouseEvent):void {
			addAudio.dispatch( { source: "cloud" }, _currentEditingWidget, cloudWindowTitle); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onAudioUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				addAudio.dispatch( { source: "external", url: url }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
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
		
		// gh#221
		protected function onLinkSelect(event:MouseEvent):void {
			if (webUrlTextInput.text != null) {
				captionTextInput.text = (captionTextInput.text == "")? webUrlTextInput.text: captionTextInput.text;
				addLink.dispatch(webUrlTextInput.text, captionTextInput.text);
				webUrlTextInput.text = "";
				captionTextInput.text = "";
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
			isOutsideClick = false;
		}
		
		protected function onUnderlineChange(event:MouseEvent):void {
			var format:TextLayoutFormat = new TextLayoutFormat();
			format.textDecoration = (underlineButton.selected) ? TextDecoration.UNDERLINE : TextDecoration.NONE;
			formatText.dispatch( { format: format } );
			isOutsideClick = false;
		}
		
		protected function onItalicChange(event:MouseEvent):void {
			var format2:TextLayoutFormat = new TextLayoutFormat();
			format2.fontStyle = (italicButton.selected) ? "italic" : "normal";
			formatText.dispatch( { format: format2 } );
			isOutsideClick = false;
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
			isOutsideClick = false;
		}
		
		protected function selectFontSizeButton(selectedButton:ToggleButton):void {
			// Make sure that only one button is selected at a time
			for each (var button:ToggleButton in [ fontSize1Button, fontSize2Button, fontSize3Button ])
				button.selected = false;
			
			selectedButton.selected = true;
		}
		
		protected function disSelectFontFormattingButton():void {
			for each (var button:ToggleButton in [ boldButton, underlineButton, italicButton, fontSize1Button, fontSize2Button, fontSize3Button ])
				button.selected = false;
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
		// alice: small screen size solution
		protected function onScreenResize(event:Event):void {
			if (stage.stageWidth < 1200) {
				smallScreenFlag = true;
			} else {
				smallScreenFlag = false;
			}
			invalidateProperties();				
		}
		
		protected function onUpClick(event:MouseEvent):void {
			isUpArrowClick = true;
			largePopUpGroup.visible = true;
			smallPopUpGroup.visible = false;
			itemList.alpha = 1;
			isOutsideClick = false;
			isDownArrowClick = false; 
			
			invalidateProperties();
		}
		
		protected function onDownClick(event:MouseEvent):void {
			isItemClick = true;
			isDownArrowClick = true;
		}
		
		protected function onAddItemClick(event:MouseEvent):void {
			largePopUpGroup.visible = false;
			smallPopUpGroup.visible = true;
			itemList.height = 200;
			itemList.alpha = 1;
			isOutsideClick = false;
		}
		
		// The pop up menu will not shrink if user click on menu itself
		protected function onItemListClick(event:MouseEvent):void {
			if (!isItemClick) {
				isOutsideClick = false;
			}
		}
		
		protected function onStageClick(event:MouseEvent):void {
			if (isOutsideClick) {
				disSelectFontFormattingButton();
				if (!addItemButton.selected) {
					upAnim.play(null, true);
					isDownArrowClick = true;
				} else {
					addItemButton.skin.setCurrentState("up", true);
					addItemButton.selected = false;
					itemList.alpha = 0;
					itemList.height = 0;
				}				
			} else {
				isOutsideClick = true;
				isItemClick = false;
			}

		}
		
		protected function onUpAimEnd(event:Event):void {
			if (isDownArrowClick) {
				itemList.alpha = 0;
				isUpArrowClick = false;
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