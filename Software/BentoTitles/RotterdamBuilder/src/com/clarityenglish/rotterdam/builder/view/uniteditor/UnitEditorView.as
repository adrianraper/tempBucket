package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetLayoutEvent;
	import com.clarityenglish.rotterdam.view.unit.events.WidgetMenuEvent;
	import com.clarityenglish.rotterdam.view.unit.ui.WidgetList;
	import com.clarityenglish.rotterdam.view.unit.widgets.AbstractWidget;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ListCollectionView;
	import mx.core.UIComponent;
	
	import org.osflash.signals.Signal;
	
	import skins.rotterdam.unit.widgets.WidgetMenu;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class UnitEditorView extends BentoView {
		
		[SkinPart(required="true")]
		public var widgetList:WidgetList;
		
		[SkinPart(required="true")]
		public var widgetMenu:WidgetMenu;
		
		[Bindable]
		public var widgetCollection:ListCollectionView;
		
		/**
		 * The widget that the WidgetMenu is currently on
		 */
		private var currentMenuWidget:AbstractWidget;
		
		public var widgetSelect:Signal = new Signal(XML);
		public var widgetDelete:Signal = new Signal(XML);
		public var widgetEdit:Signal = new Signal(XML);
		
		protected override function onAddedToStage(event:Event):void {
			super.onAddedToStage(event);
			
			stage.addEventListener(MouseEvent.CLICK, onStageClick, false, 0, true);
			addEventListener(WidgetMenuEvent.MENU_SHOW, onShowWidgetMenu, false, 0, true);
			addEventListener(WidgetMenuEvent.MENU_HIDE, onHideWidgetMenu, false, 0, true);
			addEventListener(WidgetMenuEvent.WIDGET_DELETE, onWidgetDelete, false, 0, true);
			addEventListener(WidgetMenuEvent.WIDGET_EDIT, onWidgetEdit, false, 0, true);
		}
		
		protected override function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			
			stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			removeEventListener(WidgetMenuEvent.MENU_SHOW, onShowWidgetMenu);
			removeEventListener(WidgetMenuEvent.MENU_HIDE, onHideWidgetMenu);
			removeEventListener(WidgetMenuEvent.WIDGET_DELETE, onWidgetDelete);
			removeEventListener(WidgetMenuEvent.WIDGET_EDIT, onWidgetEdit);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case widgetList:
					widgetList.editable = true;
					widgetList.dragEnabled = widgetList.dropEnabled = widgetList.dragMoveEnabled = true;
					widgetList.addEventListener(Event.CHANGE, onWidgetSelected, false, 0, true);
					widgetList.addEventListener(WidgetLayoutEvent.LAYOUT_CHANGED, onLayoutChanged, false, 0, true);
					break;
				case widgetMenu:
					widgetMenu.visible = false;
					break;
			}
		}
		
		/**
		 * The user has selected a widget
		 */
		protected function onWidgetSelected(event:IndexChangeEvent):void {
			if (event.target.selectedItem)
				widgetSelect.dispatch(event.target.selectedItem);
		}
		
		/**
		 * Delete the widget specified in event.xml
		 */
		protected function onWidgetDelete(event:WidgetMenuEvent):void {
			widgetDelete.dispatch(event.xml);
		}
		
		/**
		 * Edit the widget specified in event.xml gh#115
		 */
		protected function onWidgetEdit(event:WidgetMenuEvent):void {
			widgetEdit.dispatch(event.xml);
		}
		
		/**
		 * The user has clicked the cog button to show the menu so display and position it
		 */
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
		 */
		protected function onLayoutChanged(event:Event = null):void {
			if (currentMenuWidget) {
				callLater(function():void {
					var pt:Point = new Point(currentMenuWidget.width - widgetMenu.width, currentMenuWidget.y);
					pt = UIComponent(currentMenuWidget).localToContent(pt);
					
					widgetMenu.xml = currentMenuWidget.xml;
					widgetMenu.x = pt.x + currentMenuWidget.x;
					widgetMenu.y = pt.y; // TODO: This doesn't give the correct position when the list is scrolled vertically
				});
			}
		}
		
		protected function onHideWidgetMenu(event:Event = null):void {
			if (currentMenuWidget)
				currentMenuWidget.widgetChrome.currentState = "closed";
			
			widgetMenu.visible = false;
		}
		
		/**
		 * Any click that is not on the cog button or on the open widget menu will close the menu
		 */
		protected function onStageClick(event:MouseEvent):void {
			if (widgetMenu.visible &&
				currentMenuWidget &&
				!currentMenuWidget.widgetChrome.menuButton.hitTestPoint(event.stageX, event.stageY) &&
				!widgetMenu.hitTestPoint(event.stageX, event.stageY)) {
				onHideWidgetMenu();
			}
		}
		
	}
}