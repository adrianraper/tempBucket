package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.graphics.BitmapFillMode;
	import mx.managers.DragManager;
	
	import org.davekeen.util.Closure;
	import org.davekeen.util.PointUtil;
	
	import spark.components.Group;
	import spark.components.Image;
	
	public class DraggableBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		[Embed(source="/skins/assets/draggable_pointer.png")]
		private static var draggableIcon:Class;
		private static var draggableIconOffsetX:Number = -8;
		private static var draggableIconOffsetY:Number = -3;
		private static var cursorData:MouseCursorData;
		
		private var dragImage:Image;

		public function DraggableBehaviour(container:Group) {
			super(container);
		}
		
		public function onCreateChildren():void {
			if (!dragImage) {
				dragImage = new Image();
				dragImage.fillMode = BitmapFillMode.CLIP; // This ensures that the Image component doesn't try to scale
				dragImage.visible = false;
				
				// We need to wrap it in an MX component otherwise the DragManager complains
				var wrapper:UIComponent = new UIComponent();
				wrapper.addChild(dragImage);
				
				container.addElement(wrapper);
			}
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void {
		}
		
		/**
		 * Draggable nodes are nodes that explicitly have the draggable attribute set on them, or (potentially) inputs that are droptargets - this is to allow
		 * drags from one input to another.
		 * 
		 * @param xhtml
		 * @return 
		 */
		private function getDraggableNodes(xhtml:XHTML):XMLList {
			return xhtml.xml..*.((hasOwnProperty("@draggable") && @draggable == "true") || (name() == "input" && hasOwnProperty("@type") && @type == "droptarget"));
		}
		
		private function canDrag(draggableNode:XML, draggableFlowElement:FlowElement):Boolean {
			if (!draggableNode || !draggableFlowElement) return false;
			
			// If the node is an input element with nothing dragged into it then nothing can be dragged out of it
			if (draggableFlowElement is InputElement)
				if (!(draggableFlowElement as InputElement).droppedNode)
					return false;
			
			// If the node has the 'disabled' class then it is not draggable
			if (XHTML.hasClass(draggableNode, "disabled"))
				return false;
			
			return true;
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			for each (var draggableNode:XML in getDraggableNodes(xhtml)) {
				var draggableFlowElement:FlowElement = flowElementXmlBiMap.getFlowElement(draggableNode);
				
				if (draggableFlowElement is FlowLeafElement) {
					draggableFlowElement.tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_MOVE, Closure.create(this, onFlowElementMouseMove, draggableNode, draggableFlowElement));
					draggableFlowElement.tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OVER, Closure.create(this, onRollOver, draggableNode));
					draggableFlowElement.tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OUT, Closure.create(this, onRollOut, draggableNode));
				} else if (draggableFlowElement is FloatableTextFlow) {
					(draggableFlowElement as FloatableTextFlow).getFirstLeaf().tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_MOVE, Closure.create(this, onFlowElementMouseMove, draggableNode, draggableFlowElement));
					(draggableFlowElement as FloatableTextFlow).getFirstLeaf().tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OVER, Closure.create(this, onRollOver, draggableNode));
					(draggableFlowElement as FloatableTextFlow).getFirstLeaf().tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.ROLL_OUT, Closure.create(this, onRollOut, draggableNode));					
				} else {
					log.error("draggable='true' is only valid on leaf elements - " + draggableFlowElement);
				}
			}
		}
		
		private function onFlowElementMouseMove(e:FlowElementMouseEvent, draggableNode:XML, draggableFlowElement:FlowElement):void {
			if (!DragManager.isDragging) {
				// The drag initiator is either a TextInput if we are dragging from one to another, or the container otherwise
				var dragInitiator:IUIComponent = (e.flowElement is InputElement) ? (e.flowElement as InputElement).getComponent() : container;
				var ds:DragSource = new DragSource();
				
				if (!canDrag(draggableNode, draggableFlowElement)) return;
				
				if (draggableFlowElement is InputElement) {
					var inputElement:InputElement = draggableFlowElement as InputElement;
					draggableFlowElement = inputElement.droppedFlowElement;
					draggableNode = inputElement.droppedNode;
				}
				
				ds.addData((e.flowElement as FlowLeafElement).text, "text");
				ds.addData(draggableNode, "node");
				ds.addData(draggableFlowElement, "flowElement");
				
				DragManager.doDrag(dragInitiator, ds, e.originalEvent, dragImage, 0, 0, 0.8);
				
				// If doDrag decided that we have started a drag, we want to draw the drag area into the dragImage and make it visible
				if (DragManager.isDragging) {
					// First get the bounds of the draggable flow leaf element
					var elementBounds:Rectangle = TLFUtil.getFlowElementBounds(e.flowElement as FlowLeafElement);
					
					// Convert the element bounds from their original coordinate space to the container coordinate space
					var containingBlock:RenderFlow = e.flowElement.getTextFlow().flowComposer.getControllerAt(0).container as RenderFlow;
					elementBounds = PointUtil.convertRectangleCoordinateSpace(elementBounds, containingBlock, container);
					
					// Position the dragImage so that it is centered horizontally, and vertically is above the mouse
					var containerPoint:Point = (dragInitiator as UIComponent).globalToContent(new Point(e.originalEvent.stageX, e.originalEvent.stageY));
					dragImage.x = containerPoint.x - elementBounds.width / 2;
					dragImage.y = containerPoint.y - elementBounds.height / 2;
					
					// Determine translation matrix and clip rectangle to capture the draggable element as bitmap data
					var translationMatrix:Matrix = new Matrix();
					translationMatrix.translate(-elementBounds.x, -elementBounds.y);
					var clipRect:Rectangle = new Rectangle(0, 0, elementBounds.width, elementBounds.height);
					
					// Capture the draggable element into a BitmapData, draw it into the dragImage and make the dragImage visible
					var bitmapData:BitmapData = new BitmapData(elementBounds.width, elementBounds.height);
					bitmapData.draw(container, translationMatrix, null, null, clipRect, true);
					dragImage.source = bitmapData;
					dragImage.width = elementBounds.width;
					dragImage.height = elementBounds.height;
					dragImage.visible = true;
				}
			}
		}
		
		protected function onRollOver(e:FlowElementMouseEvent, draggableNode:XML):void {
			if (!canDrag(draggableNode, e.flowElement)) return;
			
			if (!cursorData) {
				cursorData = new MouseCursorData();
				cursorData.hotSpot = new Point(-draggableIconOffsetX, -draggableIconOffsetY);
				var bitmapDatas:Vector.<BitmapData> = new Vector.<BitmapData>(1, true);
				var frame1Bitmap:Bitmap = new draggableIcon();
				bitmapDatas[0] = frame1Bitmap.bitmapData;
				cursorData.data = bitmapDatas;
				cursorData.frameRate = 1;
				Mouse.registerCursor("handCursor", cursorData);
			}
			
			Mouse.cursor = "handCursor";
		}
		
		protected function onRollOut(e:FlowElementMouseEvent, draggableNode:XML):void {
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void { }
		
	}
}
