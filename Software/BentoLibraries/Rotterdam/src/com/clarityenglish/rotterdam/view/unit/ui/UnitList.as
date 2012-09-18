package com.clarityenglish.rotterdam.view.unit.ui {
	import com.clarityenglish.rotterdam.view.unit.layouts.UnitLayout;
	import com.clarityenglish.rotterdam.view.unit.widgets.TextWidget;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ListCollectionView;
	import mx.core.ClassFactory;
	import mx.core.DragSource;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.SandboxMouseEvent;
	import mx.managers.DragManager;
	
	import spark.components.List;
	
	use namespace mx_internal;
	
	public class UnitList extends List {
		
		private var dragSource:DragSource;
		
		public function UnitList() {
			super();
			
			itemRendererFunction = widgetItemRendererFunction;
		}
		
		private function widgetItemRendererFunction(item:Object):ClassFactory {
			// TODO: Add in more widgets; these should probably be specified elsewhere
			var widgetClass:Class = TextWidget;
			
			var classFactory:ClassFactory = new ClassFactory(widgetClass);
			classFactory.properties = { xml: item };
			return classFactory;
		}
		
		override protected function dragStartHandler(event:DragEvent):void {
			if (event.isDefaultPrevented())
				return;
			
			dragSource = new DragSource();
			addDragData(dragSource);
			dragSource.addData(selectedIndex, "draggedIndex");
			dragSource.addData(dataProvider.getItemAt(selectedIndex), "draggedItem");
			DragManager.doDrag(this, dragSource, event, createDragIndicator(), 0, 0, 0.5, dragMoveEnabled);
			
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, onMouseUp, false, 0, true);
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		protected function onMouseUp(event:Event):void {
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false);
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, false);
			systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, onMouseUp, false);
		}
		
		protected function onMouseMove(event:MouseEvent):void {
			// Defer any updates until everything has been done
			(dataProvider as ListCollectionView).disableAutoUpdate();
			
			var pt:Point = new Point(event.localX, event.localY);
			pt = DisplayObject(event.target).localToGlobal(pt);
			
			var draggedItem:Object = dragSource.dataForFormat("draggedItem") as Object;
			var draggedIndex:int = dragSource.dataForFormat("draggedIndex") as int;
			
			// Figure out the new column and bound it within a valid range
			var newColumn:int;
			newColumn = (layout as UnitLayout).getColumnFromX(pt.x);
			newColumn = Math.max(0, newColumn);
			newColumn = Math.min(newColumn, (layout as UnitLayout).columns - draggedItem.@span);
			
			// If the column has changed then rewrite the XML accordingly
			if (newColumn != draggedItem.@column) {
				draggedItem.@column = newColumn;
				dataProvider.setItemAt(draggedItem, draggedIndex);
			}
			
			// Figure out the new index and rearrange the dataprovider if it has changed
			var dropIndex:int = (layout as UnitLayout).getDropIndex(event.stageX, event.stageY);
			if (dropIndex >= 0 && dropIndex != draggedIndex) {
				dataProvider.removeItemAt(draggedIndex);
				dataProvider.addItemAt(draggedItem, dropIndex);
				dragSource.addData(dropIndex, "draggedIndex");
			}
			
			// Execute any updates
			(dataProvider as ListCollectionView).enableAutoUpdate();
		}
		
		override protected function dragCompleteHandler(event:DragEvent):void {
			// Override with an empty method so that the superclass doesn't do anything
		}
		
		override protected function dragDropHandler(event:DragEvent):void {
			// Override with an empty method so that the superclass doesn't do anything
		}
		
	}
}
