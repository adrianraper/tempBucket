package com.clarityenglish.rotterdam.view.unit.ui {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.rotterdam.view.unit.layouts.IUnitLayout;
	import com.clarityenglish.rotterdam.view.unit.widgets.AbstractWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.AnimationWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.AudioWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.AuthoringWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ExerciseWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.ImageWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.OrchidWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.PDFWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.SelectorWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.TextWidget;
	import com.clarityenglish.rotterdam.view.unit.widgets.VideoWidget;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.core.ClassFactory;
	import mx.core.DragSource;
	import mx.core.IFlexDisplayObject;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
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
		// For video selector widget: the video selector is the one with channel list
		private var _href:Href;
		private var _channelCollection:ArrayCollection;
		
		public var editable:Boolean;
		
		protected var mouseDownTarget:Object;
		
		public function WidgetList() {
			super();
			
			itemRendererFunction = widgetItemRendererFunction;
		}

		// for video selector widget
		[Bindable]
		public function get channelCollection():ArrayCollection {
            return _channelCollection;
        }
		public function set channelCollection(value:ArrayCollection):void {
			_channelCollection = value;
		}
		
		// for video selector widget
		[Bindable]
		public function get href():Href {
			return _href;
		}
		
		public function set href(value:Href):void {
			_href = value;
		}
		
		private function widgetItemRendererFunction(item:Object):ClassFactory {
			var widgetClass:Class = AbstractWidget.typeToWidgetClass(item.@type);
			if (!widgetClass)
				log.error("Unsupported widget type " + item.@type);
			
			var classFactory:ClassFactory = new ClassFactory(widgetClass);
			if (item.@type == "group") {
				classFactory.properties = { xml: item, editable: editable, widgetCaptionChanged: true, width: width - 30};
			} else if (item.@type == "videoSelector") {
				classFactory.properties = { xml: item, editable: editable, widgetCaptionChanged: true, width: width - 30, href: href, channelCollection: channelCollection};
			} else {
				classFactory.properties = { xml: item, editable: editable, widgetCaptionChanged: true};
			}
			
			//gh#260
			/*if (scroller.verticalScrollBar) {
				scroller.verticalScrollBar.value = scroller.verticalScrollBar.maximum + 280;
			}*/
			
			return classFactory;
		}
		
		// gh#851 - in Flex 4.12 mouseDownObject gives the widget itself instead of the individual thing that was clicked on (which we need to detect dragArea)
		override protected function item_mouseDownHandler(event:MouseEvent):void {
			mouseDownTarget = event.target;
			super.item_mouseDownHandler(event);
		}
		
		// gh#851 - in Flex 4.12 mouseDownObject gives the widget itself instead of the individual thing that was clicked on (which we need to detect dragArea)
		override protected function mouseUpHandler(event:Event):void {
			mouseDownTarget = null;
			super.mouseUpHandler(event);
		}
		
		override protected function dragStartHandler(event:DragEvent):void {
			if (event.isDefaultPrevented())
				return;
			
			// This is a little hack, but it means that we will only allow a drag if it started in a component with id="dragArea"
			if (!mouseDownTarget.hasOwnProperty("id") || mouseDownTarget["id"] != "dragArea")
				return;
			
			dragSource = new DragSource();
			addDragData(dragSource);
			dragSource.addData(selectedIndex, "draggedIndex");
			dragSource.addData(dataProvider.getItemAt(selectedIndex), "draggedItem");
			
			// Recursively figure out what widget is actually being dragged, as this is the dragInitiator
			var widget:AbstractWidget = function(target:UIComponent):AbstractWidget {
				if (!target) return null;
				else if (target is AbstractWidget) return (target as AbstractWidget);
				return arguments.callee(target.parent); // this is how you do recursion in an anonoymous function
			}(mouseDownTarget);
			
			DragManager.doDrag(widget, dragSource, event, null, 0, 0, 0.5, dragMoveEnabled);
			
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
			
		}
		
		override protected function dragCompleteHandler(event:DragEvent):void {
			// Override with an empty method so that the superclass doesn't do anything
		}
		
		override protected function dragDropHandler(event:DragEvent):void {
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
	}
}
