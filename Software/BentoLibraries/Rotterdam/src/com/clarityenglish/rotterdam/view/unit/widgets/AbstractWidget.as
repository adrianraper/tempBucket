package com.clarityenglish.rotterdam.view.unit.widgets {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLayoutEvent;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetTextFormatMenuEvent;
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayoutElement;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import flashx.textLayout.formats.TextLayoutFormat;
	
	import mx.events.StateChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.XMLNotifier;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import skins.rotterdam.unit.widgets.WidgetChrome;
	import skins.rotterdam.unit.widgets.WidgetText;
	
	import spark.components.supportClasses.Range;
	
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
		
		protected var _xml:XML;
		
		protected var _editable:Boolean;
		
		protected var xmlWatcher:XMLWatcher;
		
		public var openMedia:Signal = new Signal(XML);
		public var textSelected:Signal = new Signal(TextLayoutFormat);
		
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
		
		[Bindable(event="columnAttrChanged")]
		public function get column():uint {
			return _xml.@column;
		}
		
		[Bindable(event="spanAttrChanged")]
		public function get span():uint {
			return _xml.@span;
		}
		
		[Bindable(event="titleAttrChanged")]
		public function get title():String {
			return _xml.@title;
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
					break;
			}
		}
		
		protected function onTextSelected(event:WidgetTextFormatMenuEvent):void {
			textSelected.dispatch(event.format);
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
