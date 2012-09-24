package com.clarityenglish.rotterdam.view.unit.widgets {
	import almerblank.flex.spark.components.SkinnableItemRenderer;
	
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLayoutEvent;
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayoutElement;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.StateChangeEvent;
	import mx.utils.XMLNotifier;
	
	import org.davekeen.util.StateUtil;
	
	import skins.rotterdam.unit.widgets.WidgetChrome;
	
	/**
	 * TODO: Implement an xml notification watcher (setNotifications) to watch for changes and fire events that will trigger bindings on the getters.
	 * For example, [Bindable("titleAttrChanged")].
	 */
	[SkinState("normal")]
	[SkinState("editing_normal")]
	[SkinState("editing_selected")]
	public class AbstractWidget extends SkinnableItemRenderer implements IUnitLayoutElement {
		
		[SkinPart]
		public var widgetChrome:WidgetChrome;
		
		protected var _xml:XML;
		
		private var xmlWatcher:XMLWatcher;
		
		public function AbstractWidget() {
			super();
			
			StateUtil.addStates(this, [ "normal", "selected" ], true);
			
			xmlWatcher = new XMLWatcher(this);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			// Changes in span and column force the layout to redraw
			addEventListener("spanAttrChanged", validateUnitListLayout, false, 0, true);
			addEventListener("columnAttrChanged", validateUnitListLayout, false, 0, true);
			addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onStateChange, false, 0, true);
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
		
		public function set text(value:String):void {
			if (_xml.text.length() == 0) _xml.text = <text />;
			_xml.text.setChildren(new XML("<![CDATA[" + value + "]]>"));
		}
		
		public function get text():String {
			return _xml.text[0].toString();
		}
		
		protected function validateUnitListLayout(e:Event = null):void {
			invalidateParentSizeAndDisplayList();
			validateNow();
			
			dispatchEvent(new WidgetLayoutEvent(WidgetLayoutEvent.LAYOUT_CHANGED, true));
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
			// TODO: Needs to support normal and editing
			return "editing_" + currentState;
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
			case "attributeChanged":
				eventDispatcher.dispatchEvent(new Event(value + "AttrChanged", true));
				break;
		}
	}
	
	public function destroy():void {
		eventDispatcher = null;
	}
	
}
