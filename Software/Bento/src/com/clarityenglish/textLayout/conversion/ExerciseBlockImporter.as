package com.clarityenglish.textLayout.conversion {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.bento.vo.content.model.Answer;
	import com.clarityenglish.textLayout.elements.RenderableTextFlow;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.SelectElement;
	import com.clarityenglish.textLayout.elements.VideoElement;
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.CSSComputedStyle;
	
	import flashx.textLayout.conversion.TextLayoutImporter;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.GlobalSettings;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ListElement;
	import flashx.textLayout.elements.ListItemElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.ParagraphFormattedElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.elements.SubParagraphGroupElementBase;
	import flashx.textLayout.elements.TCYElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	use namespace tlf_internal;
	
	public class ExerciseBlockImporter extends TextLayoutImporter {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		static private const anyPrintChar:RegExp = /[^\u0009\u000a\u000d\u0020]/g;
		
		// TODO: This may cause memory leaks
		private var _flowElementXmlBiMap:FlowElementXmlBiMap;
		
		// TODO: This too
		private var _exercise:Exercise;
		
		// TODO: And this!
		private var _css:CSS;
		
		private var _ignoreNodes:Vector.<XML>;
		
		public function ExerciseBlockImporter() {
			super();
			
			addIEInfo("input", InputElement, parseInput, null);
			addIEInfo("select", SelectElement, parseSelect, null);
			addIEInfo("video", VideoElement, parseVideo, null);
		}
		
		public function set flowElementXmlBiMap(value:FlowElementXmlBiMap):void {
			this._flowElementXmlBiMap = value;
		}
		
		public function set exercise(value:Exercise):void {
			this._exercise = value;
		}
		
		public function set css(value:CSS):void {
			this._css = value;
		}
		
		public function set ignoreNodes(value:Array):void {
			this._ignoreNodes = Vector.<XML>(value);
		}
		
		/**
		 * Clear any extra state the converter may have before beginning a new import
		 */
		tlf_internal override function clear():void {
			super.clear();
		}
		
		/**
		 * A convenience method that only adds new IEInfo if it doesn't already exist
		 * 
		 * @param name
		 * @param flowClass
		 * @param parser
		 * @param exporter
		 */
		private function addIEInfo(name:String, flowClass:Class, parser:Function, exporter:Function):void {
			if (!_config.lookup(name))
				_config.addIEInfo(name, flowClass, parser, exporter);
		}
		
		/** create an implied span with specified text */
		override public function createImpliedSpan(text:String):SpanElement {
			// This certainly helps the import spacing issue although its still not quite perfect
			var span:SpanElement = new SpanElement();	// No PMD
			span.text = text + " ";
			return span;
		}
		
		/**
		 * Parser for the custom <input> element
		 * 
		 * @param importFilter
		 * @param xmlToParse
		 * @param parent
		 */
		public static function parseInput(importFilter:ExerciseBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
			var inputElement:InputElement = importFilter.createInputFromXml(xmlToParse);
			importFilter.addChild(parent, inputElement);
		}
		
		/**
		 * Parser for the custom <select> element
		 *  
		 * @param importFilter
		 * @param xmlToParse
		 * @param parent
		 */
		public static function parseSelect(importFilter:ExerciseBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
			var selectElement:SelectElement = importFilter.createSelectFromXml(xmlToParse);
			importFilter.addChild(parent, selectElement);
		}
		
		/**
		 * Parser for the custom <video> element
		 *  
		 * @param importFilter
		 * @param xmlToParse
		 * @param parent
		 */
		public static function parseVideo(importFilter:ExerciseBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
			var videoElement:VideoElement = importFilter.createVideoFromXml(xmlToParse);
			importFilter.addChild(parent, videoElement);
		}
		
		/** @private */
		protected override function handleUnknownElement(name:String, xmlToParse:XML, parent:FlowGroupElement):void {
			var newParent:FlowGroupElement; // scratch
			
			var befNumChildren:int = parent.numChildren;
			parseFlowGroupElementChildren(xmlToParse, parent, null, true);
			
			// nothing got added - the custom element will be normalized away so just ignore it
			if (befNumChildren == parent.numChildren)
				return;
			
			if (befNumChildren + 1 == parent.numChildren) {
				// exactly one child was added - just tag it with the typeName if possible
				var addedChild:FlowElement = parent.getChildAt(befNumChildren);
				if (addedChild.id == null && addedChild.styleName == null && addedChild.typeName == addedChild.defaultTypeName) {
					addedChild.typeName = name.toLowerCase();
					
					// This bypasses the overridden 'create' methods below, so make sure it gets added to the map
					addToFlowElementXmlMap(xmlToParse, addedChild);
					return;
				}
			}
			
			// have to make one - case 1)
			newParent = ((parent is ParagraphElement) || (parent is SubParagraphGroupElementBase)) ? new SubParagraphGroupElement() : new DivElement();
			newParent.typeName = name.toLowerCase();
			newParent.replaceChildren(0, 0, parent.mxmlChildren.slice(befNumChildren));
			addChild(parent, newParent);
		}
		
		/**
		 * I have to overwrite this so that we also strip when the parent is a ParagraphFormattedElement, otherwise we end up with spurious span elements.
		 * In fact this might actually have no impact (an empty span does nothing anyway), but for the moment leave this in.
		 */
		override public function parseFlowGroupElementChildren(xmlToParse:XML, parent:FlowGroupElement, exceptionElements:Object = null, chainedParent:Boolean = false):void {
			for each (var child:XML in xmlToParse.children()) {
				if (child.nodeKind() == "element") {
					if (!isIgnoreNode(child)) {
						parseObject(child.name().localName, child, parent, exceptionElements);
					} else {
						log.info("Ignoring " + child.name().localName);
					}
				}
				// look for mixed content here
				else if (child.nodeKind() == "text") {
					var txt:String = child.toString();
					// Strip whitespace-only text appearing as a child of a container-formatted element
					var strip:Boolean = false;
					if (parent is ParagraphFormattedElement) { // DK: Changed this from the original ContainerFormattedElement
						strip = txt.search(anyPrintChar) == -1;
					}
					
					if (!strip)
						addChild(parent, createImpliedSpan(txt));
				}
			}
			
			// no implied paragraph should extend across container elements
			if (!chainedParent && parent is ContainerFormattedElement)
				resetImpliedPara();
		}
		
		/**
		 * As we parse the XML input maintain a map of the created FlowElement to its original node in the XML document.  This is to allow CSS to affect the
		 * FlowElements whilst still selecting on the original document.
		 * 
		 * @param xml
		 * @param flowElement
		 */
		private function addToFlowElementXmlMap(xml:XML, flowElement:FlowElement):void {
			_flowElementXmlBiMap.add(flowElement, xml);
		}
		
		/**
		 * Get the map of created FlowElements to original nodes
		 * 
		 * @return 
		 */
		public function getFlowElementXmlBiMap():FlowElementXmlBiMap {
			return _flowElementXmlBiMap;
		}
		
		/**
		 * The string "TextFlow" is hardcoded into the TextLayoutImporter so we need to override this method to replace TextFlow with header and section.
		 * In fact doing this means we don't need to add section or header to _config as this gets called first anyway (which is good because TLF doesn't
		 * like more than one tag mapping to the same FlowElement).
		 * 
		 * @param rootStory
		 * @return 
		 */
		protected override function parseContent(rootStory:XML):TextFlow {
			/*var rootName:String = rootStory.name().localName;
			var textFlowElement:XML = (rootName == "header" || rootName == "section") ? rootStory : rootStory..*::TextFlow[0];
			if (!textFlowElement) {
				reportError(GlobalSettings.resourceStringFunction("missingTextFlow")); 
				return null;
			}*/
			
			var textFlowElement:XML = rootStory;
			
			if (!checkNamespace(textFlowElement))
				return null;
			
			return parseTextFlow(this, textFlowElement);
		}

		/**
		 * We want to bypass the check to ensure that we are in the TextFlow namespace.
		 * 
		 * @param xmlToParse
		 * @return 
		 */
		protected override function checkNamespace(xmlToParse:XML):Boolean {
			return true;
		}
		
		public override function createTextFlowFromXML(xmlToParse:XML, textFlow:TextFlow = null):TextFlow {
			textFlow = new RenderableTextFlow(_textFlowConfiguration);
			
			var element:FlowElement = super.createTextFlowFromXML(xmlToParse, textFlow);
			
			// Inject any CSS properties into the element
			var style:CSSComputedStyle = _css.style(xmlToParse);
			if (style.width) trace(style.width);
			if (style.float) trace(style.height);
			
			addToFlowElementXmlMap(xmlToParse, element);
			return element as TextFlow;
		}
		
		public override function createDivFromXML(xmlToParse:XML):DivElement {
			var element:FlowElement = super.createDivFromXML(xmlToParse);
			addToFlowElementXmlMap(xmlToParse, element);
			return element as DivElement;
		}
		
		public override function createParagraphFromXML(xmlToParse:XML):ParagraphElement {
			var element:FlowElement = super.createParagraphFromXML(xmlToParse);
			addToFlowElementXmlMap(xmlToParse, element);
			return element as ParagraphElement;
		}
		
		public override function createSubParagraphGroupFromXML(xmlToParse:XML):SubParagraphGroupElement {
			var element:FlowElement = super.createSubParagraphGroupFromXML(xmlToParse);
			addToFlowElementXmlMap(xmlToParse, element);
			return element as SubParagraphGroupElement;
		}
		
		public override function createListFromXML(xmlToParse:XML):ListElement {
			var element:FlowElement = super.createListFromXML(xmlToParse);
			addToFlowElementXmlMap(xmlToParse, element);
			return element as ListElement;
		}
		
		public override function createListItemFromXML(xmlToParse:XML):ListItemElement {
			var element:FlowElement = super.createListItemFromXML(xmlToParse);
			addToFlowElementXmlMap(xmlToParse, element);
			return element as ListItemElement;
		}
		
		public override function createLinkFromXML(xmlToParse:XML):LinkElement {
			var element:FlowElement = super.createLinkFromXML(xmlToParse);
			addToFlowElementXmlMap(xmlToParse, element);
			return element as LinkElement;
		}
		
		public override function createSpanFromXML(xmlToParse:XML):SpanElement {
			var element:FlowElement = super.createSpanFromXML(xmlToParse);
			addToFlowElementXmlMap(xmlToParse, element);
			return element as SpanElement;
		}
		
		public override function createTCYFromXML(xmlToParse:XML):TCYElement {
			var element:FlowElement = super.createTCYFromXML(xmlToParse);
			addToFlowElementXmlMap(xmlToParse, element);
			return element as TCYElement;
		}
		
		public override function createInlineGraphicFromXML(xmlToParse:XML):InlineGraphicElement {
			var inlineGraphicElement:InlineGraphicElement = super.createInlineGraphicFromXML(xmlToParse);
			
			// TLF uses 'source' for the attribute, but allow 'src' too to match HTML better
			if (xmlToParse.hasOwnProperty("@src")) inlineGraphicElement.source = xmlToParse.@src.toString();
			
			// Inject any CSS properties into the element
			var style:CSSComputedStyle = _css.style(xmlToParse);
			if (style.width) inlineGraphicElement.width = style.width;
			if (style.height) inlineGraphicElement.height = style.height;
			if (style.float) inlineGraphicElement.float = style.float;
			
			addToFlowElementXmlMap(xmlToParse, inlineGraphicElement);
			return inlineGraphicElement as InlineGraphicElement;
		}
		
		/**
		 * Creator for the custom <input> element
		 *  
		 * @param xmlToParse
		 * @return 
		 */
		public function createInputFromXml(xmlToParse:XML):InputElement {
			var inputElement:InputElement = new InputElement();
			
			// Inject XML properties into the element
			if (xmlToParse.hasOwnProperty("@value")) inputElement.value = xmlToParse.@value.toString();
			if (xmlToParse.hasOwnProperty("@type")) inputElement.type = xmlToParse.@type.toString();
			
			// Inject any CSS properties into the element
			var style:CSSComputedStyle = _css.style(xmlToParse);
			if (style.gapAfterPadding) inputElement.gapAfterPadding = style.gapAfterPadding;
			if (style.gapText) inputElement.gapText = style.gapText;
			
			// Get the longest possible answer and make that the underlying text of the input
			inputElement.text = getLongestAnswerValue(_exercise.model.getPossibleAnswersForNode(xmlToParse));
			
			addToFlowElementXmlMap(xmlToParse, inputElement);
			
			return inputElement;
		}
		
		/**
		 * Creator for the custom <select> element
		 * 
		 * @param xmlToParse
		 * @return 
		 */
		public function createSelectFromXml(xmlToParse:XML):SelectElement {
			var selectElement:SelectElement = new SelectElement();
			
			var answers:Vector.<Answer> = _exercise.model.getPossibleAnswersForNode(xmlToParse);
			
			selectElement.answers = answers;
			
			// Get the longest possible answer and make that the underlying text of the select.  Add some spacers to accomodate the chrome too.
			selectElement.text = getLongestAnswerValue(answers) + "____.";
			
			addToFlowElementXmlMap(xmlToParse, selectElement);
			
			return selectElement;
		}
		
		public function createVideoFromXml(xmlToParse:XML):VideoElement {
			var videoElement:VideoElement = new VideoElement();
			
			// Inject XML properties into the element
			if (xmlToParse.hasOwnProperty("@src")) videoElement.src = xmlToParse.@src.toString();
			if (xmlToParse.hasOwnProperty("@width")) videoElement.width = xmlToParse.@width.toString();
			if (xmlToParse.hasOwnProperty("@height")) videoElement.height = xmlToParse.@height.toString();
			if (xmlToParse.hasOwnProperty("@autoPlay")) videoElement.autoPlay = (xmlToParse.@autoPlay.toString().toLowerCase() == "true");
			
			// Inject any CSS properties into the element
			var style:CSSComputedStyle = _css.style(xmlToParse);
			if (style.width) videoElement.width = style.width;
			if (style.height) videoElement.height = style.height;
			if (style.float) videoElement.float = style.float;
			
			addToFlowElementXmlMap(xmlToParse, videoElement);
			
			return videoElement;
		}
		
		/**
		 * Helper method to determine the longest textual answer in a vector of Answers
		 * 
		 * @param answers
		 * @return 
		 */
		private static function getLongestAnswerValue(answers:Vector.<Answer>):String {
			var longestAnswer:String = "";
			for each (var answer:Answer in answers)
			if (answer.value.length > longestAnswer.length)
				longestAnswer = answer.value;
			
			return longestAnswer;
		}
		
		private function isIgnoreNode(node:XML):Boolean {
			for each (var ignoreNode:XML in _ignoreNodes)
				if (ignoreNode === node)
					return true;
			
			return false;
		}
		
	}
}
