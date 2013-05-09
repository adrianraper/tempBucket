package com.clarityenglish.rotterdam.view.unit.widgets {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLayoutEvent;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLinkCaptureEvent;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLinkEvent;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetTextFormatMenuEvent;
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayoutElement;
	import com.newgonzo.web.css.selectors.ClassCondition;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.XMLNotifier;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.StateUtil;
	import org.davekeen.util.StringUtils;
	import org.osflash.signals.Signal;
	
	import skins.rotterdam.unit.widgets.WidgetChrome;
	import skins.rotterdam.unit.widgets.WidgetText;
	
	import spark.components.supportClasses.Range;
	import spark.utils.TextFlowUtil;
	
	/**
	 * TODO: Implement an xml notification watcher (setNotifications) to watch for changes and fire events that will trigger bindings on the getters.
	 * For example, [Bindable("titleAttrChanged")].
	 */
	[SkinState("normal")]
	[SkinState("editing_normal")]
	[SkinState("editing_selected")]
	public class AbstractWidget extends SkinnableItemRenderer implements IUnitLayoutElement {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[SkinPart(required="true")]
		public var widgetChrome:WidgetChrome;
		
		[SkinPart(required="true")]
		public var widgetText:WidgetText;
		
		[SkinPart]
		public var progressRange:Range;
		
		[Bindable]
		public var mediaFolder:String;
		
		[Bindable]
		public var thumbnailScript:String;
		
		[Bindable]
		public var placeholder:String;
		
		protected var _xml:XML;
		
		protected var _editable:Boolean;
		
		protected var xmlWatcher:XMLWatcher;
		
		//gh#187
		protected var _widgetCaptionChanged:Boolean;
		
		public var openMedia:Signal = new Signal(XML);
		public var openContent:Signal = new Signal(XML, String);
		public var textSelected:Signal = new Signal(TextLayoutFormat);
		//gh #106
		public var playVideo:Signal = new Signal(XML);
		public var playAudio:Signal = new Signal(XML);
		
		private var anchorPosition:Number = 0;
		private var activePosition:Number = 0;
		private var captureCaption:String = "";
		
		public function AbstractWidget() {
			super();
			
			StateUtil.addStates(this, [ "normal", "selected", "dragging" ], true);
			
			xmlWatcher = new XMLWatcher(this);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			// Changes in span and column force the layout to redraw
			addEventListener("spanAttrChanged", validateUnitListLayout, false, 0, true);
			addEventListener("columnAttrChanged", validateUnitListLayout, false, 0, true);
			addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onStateChange, false, 0, true);
			
			addEventListener(WidgetLinkEvent.ADD_LINK, onAddSelectedText, false, 0, true);
		}
		
		public function set editable(value:Boolean):void {
			if (_editable !== value) {
				_editable = value;
				invalidateSkinState();
			}
		}
		
		public function get editable():Boolean {
			return _editable;
		}
		
		[Bindable]
		public function get xml():XML {
			return _xml;
		}
		
		public function set xml(value:XML):void {
			if (_xml !== value) {
				if (_xml)
					XMLNotifier.getInstance().unwatchXML(_xml, xmlWatcher);
				
				_xml = value;
				XMLNotifier.getInstance().watchXML(_xml, xmlWatcher);
			}
		}
		
		//gh#187
		public function get widgetCaptionChanged():Boolean {
			return _widgetCaptionChanged;
		}
		
		public function set widgetCaptionChanged(value:Boolean):void {
			if (_widgetCaptionChanged != value) {
				_widgetCaptionChanged = value;
			}	
		}
		
		[Bindable(event="columnAttrChanged")]
		public function get column():uint {
			return _xml.@column;
		}
		
		[Bindable(event="spanAttrChanged")]
		public function get span():uint {
			return _xml.@span;
		}
		
		[Bindable(event="captionAttrChanged")]
		public function get caption():String {
			return _xml.@caption;
		}
		
		[Bindable(event="textChanged")]
		public function get text():String {
			return _xml.text[0].toString();
		}
		
		// #17 - will not stay!
		[Bindable(event="columnAttrChanged")]
		public function get ypos():uint {
			return _xml.@ypos;
		}
		
		// #17 - will not stay!
		public function set layoutheight(value:uint):void {
			_xml.@layoutheight = value;
		}
		
		//gh#106
		public function get clarityUID():String {
			if (_xml && _xml.(hasOwnProperty("@id"))) {
				var eid:String = _xml.@id;
				var unitid:String = _xml.parent().@id;			
				var cid:String = _xml.parent().parent().@id;			
				//var pid:String = _xml.parent().parent().parent().@id;
			} else {
				cid = unitid = eid = '0';
			}
			
			var UID:String = "54" + "." + cid + "." + unitid + "." + eid;
			return UID;
		}
		
		public function set text(value:String):void {
			if (_xml) {
				if (_xml.text.length() == 0) _xml.text = <text />;
				_xml.text.setChildren(new XML("<![CDATA[" + value + "]]>"));
				dispatchEvent(new Event("textChanged"));
			}
		}
		
		public function setUploading(uploading:Boolean):void {
			if (progressRange)
				progressRange.visible = uploading;
		}
		
		public function setProgress(event:ProgressEvent):void {
			if (progressRange)
				progressRange.value = event.bytesLoaded / event.bytesTotal * 100;
		}
		
		//gh#187
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_widgetCaptionChanged) {
				if (widgetChrome.widgetCaptionLabel) widgetChrome.widgetCaptionLabel.text = _xml.@caption;
				if (widgetChrome.widgetCaptionTextInput) widgetChrome.widgetCaptionTextInput.text = _xml.@caption;
				_widgetCaptionChanged = false;
			}
		}
		
		protected function validateUnitListLayout(e:Event = null):void {
			invalidateParentSizeAndDisplayList();
			validateNow();
			
			dispatchEvent(new WidgetLayoutEvent(WidgetLayoutEvent.LAYOUT_CHANGED, true));
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressRange:
					progressRange.visible = false;
					break;
				case widgetText:
					widgetText.addEventListener(WidgetTextFormatMenuEvent.TEXT_SELECTED, onTextSelected);
					widgetText.addEventListener(WidgetLinkCaptureEvent.LINK_CAPTURE, onLinkCapture);
					break;
				//gh#187
				case widgetChrome:
					widgetChrome.widgetCaptionTextInput.addEventListener(FocusEvent.FOCUS_OUT, onDone);
					widgetChrome.widgetCaptionTextInput.addEventListener(FlexEvent.ENTER, onDone);
					break;
			}
		}
		
		protected function onTextSelected(event:WidgetTextFormatMenuEvent):void {
			textSelected.dispatch(event.format);
		}
		
		//gh#221
		public function onAddLink(webUrlString:String, captionString:String):void {
			trace("webUrlString: "+ webUrlString);
			trace("captionString: "+captionString);
			if (anchorPosition == 0 && activePosition == 0) {
				var anchorTag:XML = <a href={webUrlString} target="_blank">{captionString}</a>;
				var textFlow:TextFlow = TextConverter.importToFlow(text, TextConverter.TEXT_LAYOUT_FORMAT) || new TextFlow();
				
				var textXML:XML = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
				
				//gh#221: enalbe web link insert next to text
				if (textXML == "") {
					textXML.appendChild(anchorTag);
				}
				else if (textXML.children().children() == "") {
					textXML.children().appendChild(anchorTag);
				} else {
					textXML.children()[textXML.children().length()-1].appendChild(anchorTag);
				}
				
				text = textXML.toXMLString();
			} else {
				//gh287 XML settings Pretty usefull!! Not sure whether I should put it here
				XML.ignoreWhitespace = false;
				XML.prettyPrinting = false;
				trace("text: "+text);
				var richTextFlow:TextFlow =  widgetText.richEditableText.textFlow;
				var lastFlowElment:TextFlow = richTextFlow.splitAtPosition(activePosition) as TextFlow;
				var chopFlowElment:FlowElement = richTextFlow.splitAtPosition(anchorPosition)
				trace("first flow: "+richTextFlow.getText());
				trace("last flow: "+lastFlowElment.getText());
				var firstParagraph:ParagraphElement= richTextFlow.getChildAt(richTextFlow.numChildren -1) as ParagraphElement;
				trace("total children: "+richTextFlow.numChildren);
				//insert link element
				var linkElement:LinkElement = new LinkElement();
				linkElement.href = webUrlString;
				linkElement.target = "_blank";
				var linkSpan:SpanElement = new SpanElement();
				linkSpan.text = captionString;
				linkElement.addChild(linkSpan);
				if (firstParagraph) {
					firstParagraph.addChild(linkElement);
					var lastP:ParagraphElement = lastFlowElment.getChildAt(0) as ParagraphElement;					
					if (lastP) {
						firstParagraph.replaceChildren(firstParagraph.numChildren, firstParagraph.numChildren, getParagraphChildren(lastP));
					}
				}
				trace("richTextFlow: "+richTextFlow.getText());
				richTextFlow.removeChildAt(richTextFlow.numChildren - 1);
				richTextFlow.addChild(firstParagraph);
				var totalNumber:Number = lastFlowElment.numChildren;
				for (var i:int = 1; i < totalNumber; i++ ) {
					var paragraphElement:ParagraphElement = lastFlowElment.getChildAt(1) as ParagraphElement;
					richTextFlow.addChild(paragraphElement);
				}
				var firstXML:XML = firstXML = TextConverter.export(richTextFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;			
				text = firstXML.toXMLString();
			}
			
			anchorPosition = 0;
			activePosition = 0;
			captureCaption = "";
		}
		
		private function getParagraphChildren(p:ParagraphElement):Array
		{
			var kids:Array =[];
			var numKids:int = p.numChildren;
			for (var i:int = 0; i<numKids; i++)
			{
				kids.push( p.getChildAt(i) );
			}
			return kids;
		}
		
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			removeEventListener("spanAttrChanged", validateUnitListLayout);
			removeEventListener("columnAttrChanged", validateUnitListLayout);
			removeEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onStateChange);
			
			if (_xml) {
				XMLNotifier.getInstance().unwatchXML(_xml, xmlWatcher);
				_xml = null;
			}
			
			xmlWatcher.destroy();
			xmlWatcher = null;
		}
		
		protected function onStateChange(event:StateChangeEvent):void {
			invalidateSkinState();
		}
		
		protected override function getCurrentSkinState():String {
			if (currentState == "dragging")
				return "dragging";
			
			// TODO: Needs to support normal and editing
			if (_editable) {
				return "editing_" + currentState;
			} else {
				return "normal";
			}
			
			return null;
		}
		
		//gh#187
		protected function onDone(event:Event):void {
			_xml.@caption = StringUtils.trim(widgetChrome.widgetCaptionTextInput.text);
			
			widgetChrome.widgetCaptionTextInput.visible = false;
			widgetChrome.widgetCaptionLabel.visible = true;
			
			callLater(function():void {
				_widgetCaptionChanged = true;
				invalidateProperties();
			});
		}
		
		protected function onLinkCapture(event:WidgetLinkCaptureEvent):void {
			anchorPosition = Math.min(event.anchorPosition, event.activePosition);
			activePosition = Math.max(event.anchorPosition, event.activePosition);
			captureCaption = widgetText.richEditableText.text.substring(anchorPosition, activePosition);
		}
		
		// Intercept the WidgetLinkEvent here to assign text parameter 
		protected function onAddSelectedText(event:WidgetLinkEvent):void {
			event.text = captureCaption;
		}
		
	}
}
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.utils.IXMLNotifiable;

class XMLWatcher implements IXMLNotifiable {
	
	private var eventDispatcher:EventDispatcher;
	
	public function XMLWatcher(eventDispatcher:EventDispatcher) {
		this.eventDispatcher = eventDispatcher;
	}
	
	public function xmlNotification(currentTarget:Object, type:String, target:Object, value:Object, detail:Object):void {
		switch (type) {
			case "attributeAdded":
			case "attributeChanged":
			case "attributeRemoved":
				eventDispatcher.dispatchEvent(new Event(value + "AttrChanged", true));
				break;
		}
	}
	
	public function destroy():void {
		eventDispatcher = null;
	}
	
}
