package com.clarityenglish.rotterdam.view.unit.widgets {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLayoutEvent;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLinkCaptureEvent;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetTextFormatMenuEvent;
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayoutElement;
	import com.newgonzo.web.css.selectors.ClassCondition;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
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
	import org.davekeen.util.XmlUtils;
	import org.osflash.signals.Signal;
	
	import skins.rotterdam.unit.widgets.WidgetChrome;
	import skins.rotterdam.unit.widgets.WidgetMenu;
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
		
		// gh#187
		protected var _widgetCaptionChanged:Boolean;
		
		public var openMedia:Signal = new Signal(XML);
		public var openContent:Signal = new Signal(XML, String);
		public var textSelected:Signal = new Signal(TextLayoutFormat);
		// gh#306
		public var captionSelected:Signal = new Signal(String, String);
		// gh#106
		public var playVideo:Signal = new Signal(XML);
		public var playAudio:Signal = new Signal(XML);

		private var captureCaption:String = "";
		
		// gh#899
		protected var copyProvider:CopyProvider;
		
		public function AbstractWidget() {
			super();
			
			StateUtil.addStates(this, [ "normal", "selected", "dragging" ], true);
			
			xmlWatcher = new XMLWatcher(this);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			// Changes in span and column force the layout to redraw
			addEventListener("spanAttrChanged", validateUnitListLayout, false, 0, true);
			addEventListener("columnAttrChanged", validateUnitListLayout, false, 0, true);
			addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onStateChange, false, 0, true);
		}
		
		// gh#899
		public function setCopyProvider(copyProvider:CopyProvider):void {
			this.copyProvider = copyProvider;
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
			
			invalidateProperties();
		}
		
		// gh#187
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
		
		// gh#106
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
			
		// gh#187
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_widgetCaptionChanged) {
				if (widgetChrome && widgetChrome.widgetCaptionLabel) widgetChrome.widgetCaptionLabel.text = _xml.@caption;
				if (widgetChrome && widgetChrome.widgetCaptionTextInput) widgetChrome.widgetCaptionTextInput.text = _xml.@caption;
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
					widgetText.addEventListener(WidgetLinkCaptureEvent.CAPTION_SELECTED, onCaptionSlected);
					break;
				// gh#187
				case widgetChrome:
					widgetChrome.widgetCaptionTextInput.addEventListener(FocusEvent.FOCUS_OUT, onDone);
					widgetChrome.widgetCaptionTextInput.addEventListener(FlexEvent.ENTER, onDone);
					break;
			}
		}
		
		protected function onTextSelected(event:WidgetTextFormatMenuEvent):void {
			textSelected.dispatch(event.format);
		}
		
		protected function onCaptionSlected(event:WidgetLinkCaptureEvent):void {
			captionSelected.dispatch(event.caption, event.urlString);
		}
		
		private function getParagraphChildren(p:ParagraphElement):Array {
			var kids:Array = [];
			var numKids:int = p.numChildren;
			for (var i:int = 0; i < numKids; i++) {
				kids.push(p.getChildAt(i));
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
		
		// gh#187
		protected function onDone(event:Event):void {
			_xml.@caption = StringUtils.trim(widgetChrome.widgetCaptionTextInput.text);
			
			widgetChrome.widgetCaptionTextInput.visible = false;
			widgetChrome.widgetCaptionLabel.visible = true;
			
			callLater(function():void {
				_widgetCaptionChanged = true;
				invalidateProperties();
			});
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
