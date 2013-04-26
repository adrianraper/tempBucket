package com.clarityenglish.rotterdam.view.unit.ui {
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayout;
	import com.clarityenglish.rotterdam.view.unit.widgets.AudioWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ExerciseWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ImageWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.PDFWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.TextWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.VideoWidget;
	
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
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.PointUtil;
	
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
		
		private function typeToWidgetClass(type:String):Class {
			// TODO: These should probably be specified elsewhere
			switch (type) {
				case "text":
					return TextWidget;
				case "pdf":
					return PDFWidget;
				case "video":
					return VideoWidget;
				case "image":
					return ImageWidget;
				case "audio":
					return AudioWidget;
				case "exercise":
					return ExerciseWidget;
				default:
					log.error("Unsupported widget type " + type);
					return null;
			}
		}
		
		private function widgetItemRendererFunction(item:Object):ClassFactory {
			var widgetClass:Class = typeToWidgetClass(item.@type);
			
			var classFactory:ClassFactory = new ClassFactory(widgetClass);
			classFactory.properties = { xml: item, editable: editable, widgetCaptionChanged: true };
			
			//gh#260
			/*if (scroller.verticalScrollBar) {
				scroller.verticalScrollBar.value = scroller.verticalScrollBar.maximum + 280;
			}*/
			
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
			
			var pt:Point = PointUtil.convertPointCoordinateSpace(new Point(event.stageX, event.stageY), stage, this);
			
			var newObject:Object;
			var draggedItem:Object = dragSource.dataForFormat("draggedItem") as Object;
			var draggedIndex:int = dragSource.dataForFormat("draggedIndex") as int;
			
			// Update the object using the layout's updateElementFromDrag method (this does all the positioning and invalidation of the display list)
			//gh: #186 the virtual widget postition display odd
			(layout as IUnitLayout).updateElementFromDrag(draggedItem, pt.x, pt.y + this.scroller.verticalScrollBar.value);
			
			// Figure out the new index and rearrange the dataprovider if it has changed.
			var dropIndex:int = (layout as IUnitLayout).getDropIndex(pt.x, pt.y);
			if (dropIndex >= 0 && dropIndex != draggedIndex) {
				var rearrangedObject:Object = draggedItem.copy();
				
				dataProvider.removeItemAt(draggedIndex);
				dataProvider.addItemAt(rearrangedObject, dropIndex);
				dragSource.addData(rearrangedObject, "draggedItem");
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
