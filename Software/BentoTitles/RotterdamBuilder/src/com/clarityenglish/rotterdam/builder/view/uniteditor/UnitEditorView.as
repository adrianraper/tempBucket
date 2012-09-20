package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetMenuEvent;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLayoutEvent;
	import com.clarityenglish.rotterdam.view.unit.widgets.AbstractWidget;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.collections.XMLListCollection;
	import mx.core.UIComponent;
	
	import skins.rotterdam.unit.widgets.WidgetMenu;
	
	import spark.components.List;
	
	public class UnitEditorView extends BentoView {
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var widgetMenu:WidgetMenu;
		
		[Bindable]
		public var unitCollection:XMLListCollection;
		
		/**
		 * The widget that the WidgetMenu is currently on
		 */
		private var currentMenuWidget:AbstractWidget;
		
		protected override function onAddedToStage(event:Event):void {
			// TODO: Hide the WidgetMenu if we click elsewhere
			/*stage.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				trace("STAGE CLICK!!!!");
			});*/
			
			addEventListener(WidgetMenuEvent.MENU_SHOW, onShowWidgetMenu, false, 0, true);
			addEventListener(WidgetMenuEvent.MENU_HIDE, onHideWidgetMenu, false, 0, true);
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
					unitList.addEventListener(WidgetLayoutEvent.LAYOUT_CHANGED, onLayoutChanged, false, 0, true);
					break;
				case widgetMenu:
					widgetMenu.visible = false;
					break;
			}
		}
		
		protected function onShowWidgetMenu(event:Event):void {
			var newMenuWidget:AbstractWidget = event.target.parentDocument.hostComponent as AbstractWidget;
			
			// If a different menu is already selected then deselect it
			if (currentMenuWidget && currentMenuWidget !== newMenuWidget)
				currentMenuWidget.widgetChrome.currentState = "closed";
			
			// Set the current menu widget, position it and make it visible
			currentMenuWidget = newMenuWidget;
			onLayoutChanged();
			widgetMenu.visible = true;
		}
		
		/**
		 * This positions the floating WidgetMenu to be aligned with whichever Widget currently has the menu.  In the event of
		 * the layout changing (e.g. if span or column changes) this is retriggered so the menu is always over the correct
		 * widget.
		 * 
		 * @param event
		 */
		protected function onLayoutChanged(event:Event = null):void {
			callLater(function():void {
				var pt:Point = new Point(currentMenuWidget.width - widgetMenu.width, currentMenuWidget.y);
				pt = UIComponent(currentMenuWidget).localToContent(pt);
				
				widgetMenu.xml = currentMenuWidget.xml;
				widgetMenu.x = pt.x;
				widgetMenu.y = pt.y; // TODO: This doesn't give the correct position when the list is scrolled vertically
			});
		}
		
		protected function onHideWidgetMenu(event:Event):void {
			widgetMenu.visible = false;
		}
		
	}
}