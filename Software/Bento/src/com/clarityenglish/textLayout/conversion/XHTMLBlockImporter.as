package com.clarityenglish.textLayout.conversion {
	import com.clarityenglish.textLayout.elements.AudioElement;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.OrderedListElement;
	import com.clarityenglish.textLayout.elements.SelectElement;
	import com.clarityenglish.textLayout.elements.UnorderedListElement;
	import com.clarityenglish.textLayout.elements.VideoElement;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.newgonzo.commons.utils.StringUtil;
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.CSSComputedStyle;
	
	import flashx.textLayout.conversion.BaseTextLayoutImporter;
	import flashx.textLayout.conversion.TextLayoutImporter;
	import flashx.textLayout.elements.ContainerFormattedElement;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.IFormatResolver;
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
	import flashx.textLayout.formats.ListStyleType;
	import flashx.textLayout.tlf_internal;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;
	
	import org.davekeen.util.ClassUtil;
	
	use namespace tlf_internal;
	
	public class XHTMLBlockImporter extends TextLayoutImporter {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		static private const anyPrintChar:RegExp = /[^\u0009\u000a\u000d\u0020]/g;
		
		// TODO: This may cause memory leaks
		private var _flowElementXmlBiMap:FlowElementXmlBiMap;
		
		// TODO: And this!
		private var _css:CSS;
		
		private var _importQueueJobs:Vector.<ImportQueueJob>;
		
		private var _currentContainingBlock:RenderFlow;
		
		private var _formatResolver:IFormatResolver;
		
		private var _rootPath:String;
		
		public function XHTMLBlockImporter() {
			super();
			
			_importQueueJobs = new Vector.<ImportQueueJob>();
			
			addIEInfo("input", InputElement, parseInput, null);
			addIEInfo("select", SelectElement, parseSelect, null);
			addIEInfo("video", VideoElement, parseVideo, null);
			addIEInfo("audio", AudioElement, parseAudio, null);
			
			addIEInfo("ul", UnorderedListElement, parseUnorderedList, null);
			addIEInfo("ol", OrderedListElement, parseOrderedList, null);
		}
		
		public function set flowElementXmlBiMap(value:FlowElementXmlBiMap):void {
			this._flowElementXmlBiMap = value;
		}
		
		public function set formatResolver(value:IFormatResolver):void {
			this._formatResolver = value;
		}
		
		public function set rootPath(value:String):void {
			this._rootPath = value;
		}
		
		public function set css(value:CSS):void {
			this._css = value;
		}
		
		/**
		 * This is used to add a relative path to media referenced in the XHTML input
		 * 
		 * @param url
		 * @return 
		 */
		private function updateWithRootPath(url:String):String {
			// If rootPath is defined and the url isn't a web address then prepend the url with the root path
			if (_rootPath && url.search(/^https?:\/\/.*/i) < 0)
				url = ((_rootPath) ? _rootPath + "/" : "") + url;
			
			return url;
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
		
		public function importToRenderFlow(xmlToParse:XML):RenderFlow {
			// Create the main RenderFlow, and create the main import job and add it to the queue
			var initialRenderFlow:RenderFlow = new RenderFlow();
			var initialImportQueueJob:ImportQueueJob = new ImportQueueJob();
			initialImportQueueJob.xmlToParse = xmlToParse;
			_importQueueJobs.push(initialImportQueueJob);
			
			// Use a flag so we can actually return the first RenderView (i.e. the main one)
			var firstPass:Boolean = true;
			
			// Execute the import queue until there is nothing left
			while (_importQueueJobs.length > 0) {
				var importQueueJob:ImportQueueJob = _importQueueJobs.shift();
				executeImportQueueJob(importQueueJob, (firstPass) ? initialRenderFlow : null);
				firstPass = false;
			}
			
			// Nullify to allow garbage collection
			_formatResolver = null;
			_importQueueJobs = null;
			_currentContainingBlock = null;
			
			return initialRenderFlow;
		}
		
		private function executeImportQueueJob(importQueueJob:ImportQueueJob, renderFlow:RenderFlow = null):void {
			if (!renderFlow)
				renderFlow = new RenderFlow();
			
			// In order to fake recursion (which the design of the importer doesn't support) maintain the current render flow during import
			_currentContainingBlock = renderFlow;
			
			// Parse the xml and put it into the RenderFlow
			renderFlow.textFlow = importToFlow(importQueueJob.xmlToParse) as FloatableTextFlow;
			
			if (!renderFlow.hasTextFlow()) {
				log.error("Failed to parse some XHTML into a TextFlow: {0}", importQueueJob.xmlToParse.toXMLString());
			}
			
			// Send any import errors to the log
			if (errors && errors.length > 0)
				for each (var error:String in errors)
					log.error(error);
			
			// If there is an IGE placeholder set it on the render flow
			if (importQueueJob.inlineGraphicElementPlaceholder) {
				renderFlow.inlineGraphicElementPlaceholder = importQueueJob.inlineGraphicElementPlaceholder;
			}
			
			// If there is a containing block set it on the render flow and add this to the containing block's display list
			if (importQueueJob.containingBlock) {
				importQueueJob.containingBlock.addChildRenderFlow(renderFlow);
			}
		}
		
		/**
		 * Based on the tag name and its CSS style information this method determines whether or not this should be a seperate flow
		 * 
		 * @param name
		 * @param style
		 * @return 
		 */
		private static function isSeperateFlow(name:String, style:CSSComputedStyle):Boolean {
			// Images are never seperate flows as TLF deals with them already
			if (name == "img")
				return false;
				
			// Floats are always seperate flows
			if (style.float == FloatableTextFlow.FLOAT_LEFT || style.float == FloatableTextFlow.FLOAT_RIGHT)
				return true;
			
			if (style.position == FloatableTextFlow.POSITION_RELATIVE)
				return true;
			
			if (style.overflow == FloatableTextFlow.OVERFLOW_HIDDEN)
				return true;
			
			// Not sure about this yet...
			if (style.height)
				return true;
			
			return false;
		}
		
		tlf_internal override function parseObject(name:String, xmlToParse:XML, parent:FlowGroupElement, exceptionElements:Object = null):void {
			// Get the CSS style of the node
			var style:CSSComputedStyle = _css.style(xmlToParse);
			
			// Create a seperate flow if necessary, otherwise continue parsing within this flow
			if (isSeperateFlow(name, style)) {
				if (!style.width && !style.height)
					log.error("Non image floats should have a fixed width or height otherwise unpredicable behaviour can occur.");
				
				// Create an inline graphic element to act as a placeholder for the render flow
				var inlineGraphicElement:InlineGraphicElement = new InlineGraphicElement();
				if (style.float) inlineGraphicElement.float = style.float;
				if (style.width) inlineGraphicElement.width = style.width;
				if (style.height) inlineGraphicElement.height = style.height;
				inlineGraphicElement.source = null;
				addChild(parent, inlineGraphicElement);
				
				var importQueueJob:ImportQueueJob = new ImportQueueJob();
				importQueueJob.xmlToParse = xmlToParse;
				importQueueJob.containingBlock = _currentContainingBlock;
				importQueueJob.inlineGraphicElementPlaceholder = inlineGraphicElement;
				
				_importQueueJobs.push(importQueueJob);
			} else {
				super.parseObject(name, xmlToParse, parent, exceptionElements);
			}
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
		public static function parseInput(importFilter:XHTMLBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
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
		public static function parseSelect(importFilter:XHTMLBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
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
		public static function parseVideo(importFilter:XHTMLBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
			var videoElement:VideoElement = importFilter.createVideoFromXml(xmlToParse);
			importFilter.addChild(parent, videoElement);
		}
		
		/**
		 * Parser for the custom <audio> element
		 * 
		 * @param importFilter
		 * @param xmlToParse
		 * @param parent
		 */
		public static function parseAudio(importFilter:XHTMLBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
			var audioElement:AudioElement = importFilter.createAudioFromXml(xmlToParse);
			importFilter.addChild(parent, audioElement);
		}
		
		/**
		 * This is equivalent to <list> with listStyleType == ListStyleType.DISC
		 * 
		 * @param importFilter
		 * @param xmlToParse
		 * @param parent
		 */
		private static function parseUnorderedList(importFilter:XHTMLBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
			var listElem:ListElement = importFilter.createListFromXML(xmlToParse);
			
			// By default an unordered list is of disc type
			listElem.listStyleType = ListStyleType.DISC;
			
			if (importFilter.addChild(parent, listElem))
				importFilter.parseFlowGroupElementChildren(xmlToParse, listElem);
		}
		
		/**
		 * This is equivalent to <list> with listStyleType == ListStyleType.DECIMAL
		 * 
		 * @param importFilter
		 * @param xmlToParse
		 * @param parent
		 */
		private static function parseOrderedList(importFilter:XHTMLBlockImporter, xmlToParse:XML, parent:FlowGroupElement):void {
			var listElem:ListElement = importFilter.createListFromXML(xmlToParse);
			
			// By default an ordered list of of decimal type
			listElem.listStyleType = ListStyleType.DECIMAL;
			
			if (importFilter.addChild(parent, listElem))
				importFilter.parseFlowGroupElementChildren(xmlToParse, listElem);
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
					parseObject(child.name().localName, child, parent, exceptionElements);
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
			// Create a text flow using our subclass as a template in order to get some extra attributes in there
			var element:FloatableTextFlow = super.createTextFlowFromXML(xmlToParse, new FloatableTextFlow(_textFlowConfiguration)) as FloatableTextFlow;
			
			// Set the format resolver
			element.formatResolver = _formatResolver;
			
			// Inject any CSS properties into the element
			var style:CSSComputedStyle = _css.style(xmlToParse);
			if (style.position) element.position = style.position;
			if (style.display) element.display = style.display;
			if (style.overflow) element.overflow = style.overflow;
			if (style.width) element.width = style.width;
			if (style.height) element.height = style.height;
			if (style.float) element.float = style.float;
			
			// I'm not sure why, but the TextFlow doesn't render some styles in the CssFormatResolver, so add them manually here
			if (style.left) element.left = style.left;
			if (style.right) element.right = style.right;
			if (style.top) element.top = style.top;
			if (style.bottom) element.bottom = style.bottom;
			
			if (style.paddingLeft) element.paddingLeft = style.paddingLeft;
			if (style.paddingRight) element.paddingRight = style.paddingRight;
			if (style.paddingTop) element.paddingTop = style.paddingTop;
			if (style.paddingBottom) element.paddingBottom = style.paddingBottom;
			
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
			if (xmlToParse.hasOwnProperty("@src")) inlineGraphicElement.source = updateWithRootPath(xmlToParse.@src.toString());
			
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
			
			// Add the answers by any child option tags
			selectElement.options = xmlToParse.option;
			
			addToFlowElementXmlMap(xmlToParse, selectElement);
			
			return selectElement;
		}
		
		public function createVideoFromXml(xmlToParse:XML):VideoElement {
			var videoElement:VideoElement = new VideoElement();
			
			// Inject XML properties into the element
			if (xmlToParse.hasOwnProperty("@src")) videoElement.src = updateWithRootPath(xmlToParse.@src.toString());
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
		
		public function createAudioFromXml(xmlToParse:XML):AudioElement {
			var audioElement:AudioElement = new AudioElement();
			
			// Inject XML properties into the element
			if (xmlToParse.hasOwnProperty("@src")) audioElement.src = updateWithRootPath(xmlToParse.@src.toString());
			if (xmlToParse.hasOwnProperty("@controls")) audioElement.controls = xmlToParse.@controls.toString();
			
			addToFlowElementXmlMap(xmlToParse, audioElement);
			
			return audioElement;
		}
		
	}
}
import com.clarityenglish.textLayout.rendering.RenderFlow;

import flashx.textLayout.elements.InlineGraphicElement;

class ImportQueueJob {
	
	public var xmlToParse:XML;
	
	public var containingBlock:RenderFlow;
	
	public var inlineGraphicElementPlaceholder:InlineGraphicElement;
	
}
