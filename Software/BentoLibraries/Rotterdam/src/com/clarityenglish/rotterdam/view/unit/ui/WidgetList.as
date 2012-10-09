package com.clarityenglish.rotterdam.view.unit.ui {
	import com.clarityenglish.rotterdam.view.unit.layouts.UnitLayout;
	import com.clarityenglish.rotterdam.view.unit.widgets.PDFWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.TextWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.VideoWidget;
	
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
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.DragManager;
	import mx.utils.UIDUtil;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.List;
	
	use namespace mx_internal;
	
	public class WidgetList extends List {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var dragSource:DragSource;
		
		public var editable:Boolean;
		
		public function WidgetList() {
			super();
			
			itemRendererFunction = widgetItemRendererFunction;
		}
		
		private function nodeNameToWidgetClass(name:String):Class {
			// TODO: Add in more widgets; also these should probably be specified elsewhere
			switch (name) {
				case "text":
					return TextWidget;
				case "pdf":
					return PDFWidget;
				case "video":
					return VideoWidget;
				default:
					log.error("Unsupported widget node " + name);
					return null;
			}
		}
		
		private function widgetItemRendererFunction(item:Object):ClassFactory {
			var widgetClass:Class = nodeNameToWidgetClass(item.name());
			
			var classFactory:ClassFactory = new ClassFactory(widgetClass);
			classFactory.properties = { xml: item, editable: editable };
			return classFactory;
		}
		
		override protected function dragStartHandler(event:DragEvent):void {
			if (event.isDefaultPrevented())
				return;
			
			// This is a little hack, but it means that we will only allow a drag if it started in a component with id="dragArea"
			if (!mouseDownObject.hasOwnProperty("id") || mouseDownObject["id"] != "dragArea")
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
			
			var newObject:Object;
			var draggedItem:Object = dragSource.dataForFormat("draggedItem") as Object;
			var draggedIndex:int = dragSource.dataForFormat("draggedIndex") as int;
			
			// Figure out the new column and bound it within a valid range
			var newColumn:int;
			newColumn = (layout as UnitLayout).getColumnFromX(pt.x);
			newColumn = Math.max(0, newColumn);
			newColumn = Math.min(newColumn, (layout as UnitLayout).columns - draggedItem.@span);
			
			// If the column has changed then rewrite the XML accordingly
			if (newColumn != draggedItem.@column) {
				newObject = draggedItem.copy();
				
				newObject.@column = newColumn;
				dataProvider.setItemAt(newObject, draggedIndex);
			}
			
			// Figure out the new index and rearrange the dataprovider if it has changed
			var dropIndex:int = (layout as UnitLayout).getDropIndex(event.stageX, event.stageY);
			if (dropIndex >= 0 && dropIndex != draggedIndex) {
				newObject = draggedItem.copy();
				
				dataProvider.removeItemAt(draggedIndex);
				dataProvider.addItemAt(newObject, dropIndex);
				dragSource.addData(newObject, "draggedItem");
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
