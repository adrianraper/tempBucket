package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetMenuEvent;
	import com.clarityenglish.rotterdam.view.unit.widgets.AbstractWidget;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.XMLListCollection;
	
	import skins.rotterdam.unit.widgets.WidgetMenu;
	
	import spark.components.List;
	
	public class UnitEditorView extends BentoView {
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var widgetMenu:WidgetMenu;
		
		[Bindable]
		public var unitCollection:XMLListCollection;
		
		protected override function onAddedToStage(event:Event):void {
			// TODO: Hide the WidgetMenu if we click elsewhere
			/*stage.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				trace("STAGE CLICK!!!!");
			});*/
		}
		
		public override function set data(value:Object):void {
			super.data = value;
			
			if (data) {
				unitCollection = new XMLListCollection(data.*);
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.dragEnabled = unitList.dropEnabled = unitList.dragMoveEnabled = true;
					unitList.addEventListener(WidgetMenuEvent.MENU_SHOW, onShowWidgetMenu, false, 0, true);
					unitList.addEventListener(WidgetMenuEvent.MENU_HIDE, onHideWidgetMenu, false, 0, true);
					break;
				case widgetMenu:
					widgetMenu.visible = false;
					break;
			}
		}
		
		protected function onShowWidgetMenu(event:Event):void {
			var widget:AbstractWidget = event.target.parentDocument.hostComponent as AbstractWidget;
			
			var pt:Point = new Point(widget.width - widgetMenu.width, widget.y);
			pt = DisplayObject(widget).localToGlobal(pt);
			pt = this.globalToLocal(pt);
			
			// Configure, position and show the menu
			widgetMenu.xml = widget.xml;
			widgetMenu.x = pt.x;
			widgetMenu.y = pt.y;
			widgetMenu.visible = true;
		}
		
		protected function onHideWidgetMenu(event:Event):void {
			widgetMenu.visible = false;
		}
		
	}
}