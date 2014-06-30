package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.rotterdam.view.unit.ui.UniversalWidget;
	import com.clarityenglish.rotterdam.view.unit.ui.WidgetList;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.events.StateChangeEvent;
	
	import spark.components.List;
	
	public class SelectorWidget extends AbstractWidget {
		
		[SkinPart]
		public var universalWidget:UniversalWidget;
		
		[SkinPart]
		public var selectorList:spark.components.List;
		
		private var _widgetSelectorCollection:XMLListCollection;
		private var _index:Number;
		private var indexChanged:Boolean;
		
		[Bindable(event="srcAttrChanged")]
		public function get src():String {
			return _xml.@src;
		}
		
		[Bindable(event="widgetSelectorCollectionChanged")]
		public function get widgetSelectorCollection():XMLListCollection {
			return _widgetSelectorCollection;
		}
	
		public function set widgetSelectorCollection(value:XMLListCollection):void {
			if (value != _widgetSelectorCollection) {
				_widgetSelectorCollection = null;
				dispatchEvent(new Event("widgetSelectorCollectionChanged"));
				
				callLater(function():void {
					_widgetSelectorCollection = value;
					dispatchEvent(new Event("widgetSelectorCollectionChanged"));
				});
			}
		}
		
		public function set index(value:Number):void {
			_index = value;
			indexChanged = true;
			invalidateProperties();
		}
		
		protected function setUniversalWidget(event:Event = null):void {
			if (_xml) {
				if (universalWidget) {
					universalWidget.xml = _xml;
				}
					
				widgetSelectorCollection = new XMLListCollection(_xml.exercise);
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (indexChanged) {
				universalWidget.index = _index;
				indexChanged = false;
			}
				
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case universalWidget:
					setUniversalWidget();
					break;
				case selectorList:
					selectorList.addEventListener(MouseEvent.CLICK, onSelectorListClick);
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			if (src == "video") {
				return "videoSelector";
			} else {
				return "normalSelector";
			}
		}
		
		protected function onSelectorListClick(event:Event):void {
			index = selectorList.selectedIndex;
		}
	}
}