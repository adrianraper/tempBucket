package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.rotterdam.view.unit.ui.UniversalWidgetHolder;
	import com.clarityenglish.rotterdam.view.unit.ui.WidgetList;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.events.StateChangeEvent;
	
	import org.davekeen.util.StateUtil;
	
	import spark.components.List;
	
	public class SelectorWidget extends AbstractWidget {
		
		[SkinPart]
		public var universalWidget:UniversalWidgetHolder;
		
		[SkinPart]
		public var selectorList:spark.components.List;
		
		private var _widgetSelectorCollection:XMLListCollection;
		private var _exercise:XML;
		private var _exerciseChanged:Boolean;
		
		public function SelectorWidget():void {
			super();
			
			StateUtil.addStates(this, [ "normalSelector", "videoSelector"], true);
		}
		
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
		
		public function set exercise(value:XML):void {
			_exercise = value;
			_exerciseChanged = true;
			invalidateProperties();
		}
		
		protected function setUniversalWidget(event:Event = null):void {
			if (_xml) {
				if (universalWidget) {
					// set the first exercise to universlWidget
					universalWidget.exercise = _xml.exercise[0];
				}
					
				widgetSelectorCollection = new XMLListCollection(_xml.exercise);
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_exerciseChanged) {
				universalWidget.exercise = _exercise;
				_exerciseChanged = false;
			}		
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (getCurrentSkinState() == "videoSelector") {
				selectorList.right = -58;
				universalWidget.left = 0;
			} else if (getCurrentSkinState() == "normalSelector") {
				selectorList.left = 0;
				universalWidget.right = 0;
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
		
		protected function onSrcAttrChanged(event:Event = null):void {
			invalidateSkinState();
		}
		
		protected function onSelectorListClick(event:Event):void {
			exercise = selectorList.selectedItem;
		}
	}
}