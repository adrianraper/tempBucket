package com.clarityenglish.rotterdam.builder.view.course {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.controls.video.UniversalVideoPlayer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.FontStyle;
	import flash.text.engine.FontWeight;
	import flash.utils.*;
	
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.StateUtil;
	import org.davekeen.util.StringUtils;
	import org.davekeen.validators.URLValidator;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGroup;
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
		public var addImageLabel:Label;
		
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
		public var normalAddAuthoringButton:Button;
		
		[SkinPart]
		public var listAddAuthoringButton:Button;
		
		[SkinPart]
		public var addAuthoringLabel:Label;
		
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
		public var authoringGapFillButton:Button;
		
		[SkinPart]
		public var authoringMultipleChoiceButton:Button;
		
		[SkinPart]
		public var authoringDrapAndDropButton:Button;
		
		[SkinPart]
		public var authoringTargetSpottingButton:Button;
		
		[SkinPart]
		public var authoringErrorCorrectionButton:Button;
		
		[SkinPart]
		public var authoringDropdownButton:Button;
		
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
		public var addAuthoring:Signal = new Signal(Object, XML);
		public var formatText:Signal = new Signal(Object);
		public var preview:Signal = new Signal();
		public var backToEditor:Signal = new Signal();
		// gh#221
		public var addLink:Signal = new Signal(String, String);
		public var cancelLink:Signal = new Signal();
		// gh#91
		public var onGetPermission:Signal = new Signal();

		private var isOutsideClick:Boolean;
		private var isItemClick:Boolean;
		private var isUpArrowClick:Boolean = false;
		public var isDownArrowClick:Boolean;
		public var captureCaption:String;
		
		// alice: small screen size solution
		private var smallScreenFlag:Boolean;
		
		private var _currentEditingWidget:XML;
		private var _urlCaption:String = "";
		private var _urlString:String = "";
		
		// gh#91
		public var isEditable:Boolean = false;
		public var isOwner:Boolean = false;
		public var isPublisher:Boolean = false;
		public var isCollaborator:Boolean = false;
		private var _isPreviewMode:Boolean = false;
		
		[Bindable]
		private var contentWindowTitle:String;
		
		[Bindable]
		private var cloudWindowTitle:String;
		
		[Bindable]
		public function get urlCaption():String {
			return _urlCaption;
		}
		
		public function set urlCaption(value:String):void {
				_urlCaption = value;
		}
		
		[Bindable]
		public function get urlString():String {
			return _urlString;
		}
		
		public function set urlString(value:String):void {
			_urlString = value;
		}
		
		public function ToolBarView() {
			StateUtil.addStates(this, [ "normal", "pdf", "video", "image", "audio", "link", "authoring", "preview" ], true);
		}

		// gh#91
		public function get course():XML {	
			return _xhtml.selectOne("script#model[type='application/xml'] course");
		}
		
		/**
		 * gh#115 - when currentEditingWidget is set the toolbar enters an appropriate mode for editing existing content of a widget.  In most cases this means
		 * changing the state of the toolbar, but 'exercise' and 'authoring' are special cases and immediately pops up an editor.
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
			} else if (widget.@type == "authoring") {
				addAuthoring.dispatch({}, _currentEditingWidget);
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
		
		public function set previewMode(value:Boolean):void {
			_isPreviewMode = value;
			setCurrentState(value ? "preview" : "normal");
			invalidateSkinState();
		}
		public function get previewMode():Boolean {
			return _isPreviewMode;
		}

		protected override function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			smallScreenFlag = (stage.stageWidth < 1200);
			// gh#873
			if (!previewMode)
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
			
			if (previewBackToEditorButton)
				previewBackToEditorButton.visible = !(previewMode && (isPublisher || !isEditable));

			if (addItemButton) {
				addItemButton.visible = smallScreenFlag;
				iconGroup.visible = !smallScreenFlag && !isUpArrowClick;
			}
			// gh#899
			if (_currentEditingWidget) {
				var thisSrc:String = _currentEditingWidget.@src;
				var widgetType:String = _currentEditingWidget.@type;
				switch (widgetType) {
					case "video":
						videoUrlTextInput.text = (thisSrc) ? UniversalVideoPlayer.formatUrl(thisSrc) : '';
						break;
					case "audio":
						audioUrlTextInput.text = (thisSrc && (StringUtils.beginsWith(thisSrc.toLowerCase(), "http"))) ? thisSrc : '';
						break;
					case "pdf":
						pdfUrlTextInput.text = (thisSrc && (StringUtils.beginsWith(thisSrc.toLowerCase(), "http"))) ? thisSrc : '';
						break;
					case "image":
						imageUrlTextInput.text = (thisSrc && (StringUtils.beginsWith(thisSrc.toLowerCase(), "http"))) ? thisSrc : '';
						break;
				}
			}
		}
				
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				// Normal toolbar listeners
				case normalSaveButton:
					normalSaveButton.label = copyProvider.getCopyForId("normalSaveButton");
					// gh#91 You can only save if allowed
					if (isEditable && (isOwner || isCollaborator)) { 
						normalSaveButton.addEventListener(MouseEvent.CLICK, onNormalSave);
						normalSaveButton.visible = true;
					} else {
						normalSaveButton.visible = false;
					}
					break;
				case listAddTextButton:
					listAddTextButton.addEventListener(MouseEvent.CLICK, onNormalAddText);
					break;
				case addTextLabel:
					addTextLabel.text = copyProvider.getCopyForId("addTextLabel");
					addTextLabel.addEventListener(MouseEvent.CLICK, onNormalAddText);
					break;
				case normalAddTextButton:
					normalAddTextButton.addEventListener(MouseEvent.CLICK, onNormalAddText);
					break;
				case listAddPDFButton:
					listAddPDFButton.addEventListener(MouseEvent.CLICK, onNormalAddPDF);
					break;
				case addPDFLabel:
					addPDFLabel.text = copyProvider.getCopyForId("addPDFLabel");
					addPDFLabel.addEventListener(MouseEvent.CLICK, onNormalAddPDF);
					break;
				case normalAddPDFButton:
					normalAddPDFButton.addEventListener(MouseEvent.CLICK, onNormalAddPDF);
					break;
				case listAddVideoButton:
					listAddVideoButton.addEventListener(MouseEvent.CLICK, onNormalAddVideo);
					break;
				case addVideoLabel:
					addVideoLabel.text = copyProvider.getCopyForId("addVideoLabel");
					addVideoLabel.addEventListener(MouseEvent.CLICK, onNormalAddVideo);
					break;
				case normalAddVideoButton:
					normalAddVideoButton.addEventListener(MouseEvent.CLICK, onNormalAddVideo);
					break;
				case listAddImageButton:
					listAddImageButton.addEventListener(MouseEvent.CLICK, onNormalAddImage);
					break;
				case addImageLabel:
					addImageLabel.text = copyProvider.getCopyForId("addIamgeLabel"); // ALICETODO: Typo - the literal need to be changed to match
					addImageLabel.addEventListener(MouseEvent.CLICK, onNormalAddImage);
					break;
				case normalAddImageButton:
					normalAddImageButton.addEventListener(MouseEvent.CLICK, onNormalAddImage);
					break;
				case listAddAudioButton:
					listAddAudioButton.addEventListener(MouseEvent.CLICK, onNormalAddAudio);
					break;
				case addAudioLabel:
					addAudioLabel.text = copyProvider.getCopyForId("addAudioLabel");
					addAudioLabel.addEventListener(MouseEvent.CLICK, onNormalAddAudio);
					break;
				case normalAddAudioButton:
					normalAddAudioButton.addEventListener(MouseEvent.CLICK, onNormalAddAudio);
					break;
				case normalAddExerciseButton:
					normalAddExerciseButton.addEventListener(MouseEvent.CLICK, onNormalAddExercise);
					break;
				case listAddExerciseButton:
					listAddExerciseButton.addEventListener(MouseEvent.CLICK, onNormalAddExercise);
					break;
				case addExerciseLabel:
					addExerciseLabel.text = copyProvider.getCopyForId("addExerciseLabel");
					addExerciseLabel.addEventListener(MouseEvent.CLICK, onNormalAddExercise);
					break;
				case normalAddAuthoringButton:
					normalAddAuthoringButton.addEventListener(MouseEvent.CLICK, onNormalAddAuthoring);
					break;
				case listAddAuthoringButton:
					listAddAuthoringButton.addEventListener(MouseEvent.CLICK, onNormalAddAuthoring);
					break;
				case addAuthoringLabel:
					addAuthoringLabel.text = copyProvider.getCopyForId("addAuthoringLabel");
					addAuthoringLabel.addEventListener(MouseEvent.CLICK, onNormalAddAuthoring);
					break;
				case authoringMultipleChoiceButton:
					authoringMultipleChoiceButton.addEventListener(MouseEvent.CLICK, onAuthoringMultipleChoice);
					break;
				case authoringGapFillButton:
					authoringGapFillButton.addEventListener(MouseEvent.CLICK, onAuthoringGapFill);
					break;
				case authoringDrapAndDropButton:
					authoringDrapAndDropButton.addEventListener(MouseEvent.CLICK, onAuthoringDragAndDrop);
					break;
				case authoringTargetSpottingButton:
					authoringTargetSpottingButton.addEventListener(MouseEvent.CLICK, onAuthoringTargetSpotting);
					break;
				case authoringErrorCorrectionButton:
					authoringErrorCorrectionButton.addEventListener(MouseEvent.CLICK, onAuthoringErrorCorrection);
					break;
				case authoringDropdownButton:
					authoringDropdownButton.addEventListener(MouseEvent.CLICK, onAuthoringDropdown);
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
					instance.prompt = copyProvider.getCopyForId("urlPrompt");
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
					instance.prompt = copyProvider.getCopyForId("urlPrompt");
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
					instance.prompt = copyProvider.getCopyForId("urlPrompt");
					break;
				case videoSelectButton:
					videoSelectButton.addEventListener(MouseEvent.CLICK, onVideoSelect);
					videoSelectButton.label = copyProvider.getCopyForId("selectButton");
					break;
				case videoUrlTextInput:
					videoUrlTextInput.addEventListener(FlexEvent.ENTER, onVideoSelect);
					instance.prompt = copyProvider.getCopyForId("videoUrlPrompt");
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
					upAnim.addEventListener(EffectEvent.EFFECT_END, onUpAnimEnd);
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
		
		protected function onNormalAddAuthoring(event:MouseEvent):void {
			setCurrentState("authoring");
			isItemClick = true;
		}
		
		protected function onAuthoringMultipleChoice(event:MouseEvent):void {
			addAuthoring.dispatch({ type: Question.MULTIPLE_CHOICE_QUESTION }, _currentEditingWidget);
			setCurrentState("normal");
		}
		
		protected function onAuthoringGapFill(event:MouseEvent):void {
			addAuthoring.dispatch({ type: Question.GAP_FILL_QUESTION }, _currentEditingWidget);
			setCurrentState("normal");
		}
		
		protected function onAuthoringDragAndDrop(event:MouseEvent):void {
			addAuthoring.dispatch({ type: Question.DRAG_QUESTION }, _currentEditingWidget);
			setCurrentState("normal");
		}
		
		protected function onAuthoringTargetSpotting(event:MouseEvent):void {
			addAuthoring.dispatch({ type: Question.TARGET_SPOTTING_QUESTION }, _currentEditingWidget);
			setCurrentState("normal");
		}
		
		protected function onAuthoringErrorCorrection(event:MouseEvent):void {
			addAuthoring.dispatch({ type: Question.ERROR_CORRECTION_QUESTION }, _currentEditingWidget);
			setCurrentState("normal");
		}
		
		protected function onAuthoringDropdown(event:MouseEvent):void {
			addAuthoring.dispatch({ type: Question.DROP_DOWN_QUESTION }, _currentEditingWidget);
			setCurrentState("normal");
		}
		
		// gh#306
		public function onURLClick(event:MouseEvent):void {
			setCurrentState("link");
			callLater(function():void { 
				captionTextInput.text = urlCaption ? urlCaption : "";
				webUrlTextInput.text = urlString ? urlString : "";
			});
			isItemClick = true;
		}
		
		protected function onNormalCancel(event:MouseEvent):void {
			if (this.currentState == "link") {
				urlCaption = "";
				urlString = "";
				cancelLink.dispatch();
			}
			setCurrentState("normal");
		}
		
		protected function onPdfUpload(event:MouseEvent):void {
			addPDF.dispatch({ source: "computer" }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onPdfCloudUpload(event:MouseEvent):void {
			addPDF.dispatch({ source: "cloud" }, _currentEditingWidget, cloudWindowTitle); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onPdfUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				// gh#259 remove any thumbnail
				if (_currentEditingWidget.hasOwnProperty("@thumbnail"))
					delete _currentEditingWidget.@thumbnail;
				addPDF.dispatch({ source: "external", url: url }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
				event.target.text = "";
				setCurrentState("normal");
			}
		}
		
		protected function onImageUpload(event:MouseEvent):void {
			addImage.dispatch({ source: "computer" }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onImageCloudUpload(event:MouseEvent):void {
			addImage.dispatch({ source: "cloud" }, _currentEditingWidget, cloudWindowTitle); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onImageUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				addImage.dispatch({ source: "external", url: url }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
				event.target.text = "";
				setCurrentState("normal");
			}
		}
		
		protected function onAudioUpload(event:MouseEvent):void {
			addAudio.dispatch({ source: "computer" }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onAudioCloudUpload(event:MouseEvent):void {
			addAudio.dispatch({ source: "cloud" }, _currentEditingWidget, cloudWindowTitle); // TODO: use a constant from somewhere?
			setCurrentState("normal");
		}
		
		protected function onAudioUrlEnter(event:FlexEvent):void {
			var url:String = event.target.text;
			if (url && !(new URLValidator().validate(url).results)) {
				addAudio.dispatch({ source: "external", url: url }, _currentEditingWidget, null); // TODO: use a constant from somewhere?
				event.target.text = "";
				setCurrentState("normal");
			}
		}
		
		protected function onVideoSelect(event:Event):void {
			var url:String = videoUrlTextInput.text;
			if (url) {
				addVideo.dispatch({ url: url }, _currentEditingWidget); // TODO: use a constant from somewhere (in fact this isn't used yet)?
				setCurrentState("normal");
			}
		}
		
		// gh#221
		protected function onLinkSelect(event:MouseEvent):void {
			if (webUrlTextInput.text != null) {
				captionTextInput.text = (captionTextInput.text == "")? webUrlTextInput.text: captionTextInput.text;
				addLink.dispatch(webUrlTextInput.text, captionTextInput.text);
				setCurrentState("normal");
			}
			urlCaption = "";
			urlString = "";
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
			smallScreenFlag = (stage.stageWidth < 1200);
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
			if (!isItemClick) isOutsideClick = false;
		}
		
		protected function onStageClick(event:MouseEvent):void {
			// gh#876 temporary hack
			try {
				// gh#306
				if (ClassUtil.getClass(event.target) == DataGroup) {
					disSelectFontFormattingButton();
				}
			} catch (err:Error) {
				// Nothing to do as the event came from an object outside bento
			}
			if (isOutsideClick) {
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
		
		protected function onUpAnimEnd(event:Event):void {
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