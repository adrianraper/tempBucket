package com.clarityenglish.bento.view.exercise.components.behaviours {
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.graphics.BitmapFillMode;
	import mx.managers.DragManager;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.PointUtil;
	
	import spark.components.Group;
	import spark.components.Image;
	
	public class DraggableBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
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
		
		public function onTextFlowUpdate(textFlow:TextFlow):void { }
		
		/*public function onClick(event:MouseEvent, textFlow:TextFlow):void { }*/
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			for each (var draggableNode:XML in xhtml.xml..*.(hasOwnProperty("@draggable") && @draggable == "true")) {
				var draggableFlowElement:FlowElement = flowElementXmlBiMap.getFlowElement(draggableNode);
				
				// This is kind of a hack, but it might be alright just for the moment; if the node is mapped to a FloatableTextFlow
				// then just find the first leaf and use that
				if (draggableFlowElement is FloatableTextFlow)
					draggableFlowElement = (draggableFlowElement as FloatableTextFlow).getFirstLeaf();
				
				if (!draggableFlowElement)
					continue;
				
				// draggable="true" is only allowed on FlowLeafElements
				if (draggableFlowElement is FlowLeafElement) {
					draggableFlowElement.tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.MOUSE_MOVE, function(e:FlowElementMouseEvent):void {
						if (!DragManager.isDragging) {

							var dragInitiator:* = container; // This isn't really correct
							var ds:DragSource = new DragSource();
							ds.addData((e.flowElement as FlowLeafElement).text, "text");
							
							// TODO: We might want to use the bidirectional map to put the original XML node in the data as well               
							
							DragManager.doDrag(dragInitiator, ds, e.originalEvent, dragImage, 0, 0, 0.8);
							
							// If doDrag decided that we have started a drag, we want to draw the drag area into the dragImage and make it visible
							if (DragManager.isDragging) {
								// First get the bounds of the draggable flow leaf element
								var elementBounds:Rectangle = TLFUtil.getFlowLeafElementBounds(e.flowElement as FlowLeafElement);
								
								// Convert the element bounds from their original coordinate space to the container coordinate space
								var containingBlock:RenderFlow = e.flowElement.getTextFlow().flowComposer.getControllerAt(0).container as RenderFlow;
								elementBounds = PointUtil.convertRectangleCoordinateSpace(elementBounds, containingBlock, container);
								
								// Position the dragImage so that it is centered horizontally, and vertically is above the mouse
								var containerPoint:Point = container.globalToContent(new Point(e.originalEvent.stageX, e.originalEvent.stageY));
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
					});
				} else {
					log.error("draggable='true' is only valid on leaf elements - " + draggableFlowElement);
				}
			}
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void { }
		
	}
}
