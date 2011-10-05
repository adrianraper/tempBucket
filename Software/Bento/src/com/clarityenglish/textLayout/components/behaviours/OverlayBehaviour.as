package com.clarityenglish.textLayout.components.behaviours {
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.AudioElement;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.elements.IComponentElement;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.SelectElement;
	import com.clarityenglish.textLayout.elements.VideoElement;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.TextFlow;
	
	import org.davekeen.util.PointUtil;
	
	import spark.components.Group;
	
	public class OverlayBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		private var overlayContainer:Group;
		
		public function OverlayBehaviour(container:Group):void {
			super(container);
		}
		
		private function getComponentElements(textFlow:TextFlow):Array {
			var floatableTextFlow:FloatableTextFlow = textFlow as FloatableTextFlow;
		
			// This is just temporary; make this nicer once we have a better idea of how the Spark overlays are going to work
			if (floatableTextFlow) {
				return [ ].concat(
					   floatableTextFlow.getElementsByClass(InputElement),
					   floatableTextFlow.getElementsByClass(SelectElement),
					   floatableTextFlow.getElementsByClass(VideoElement),
					   floatableTextFlow.getElementsByClass(AudioElement));
			}
			
			return null;
		}
		
		public function onCreateChildren():void {
			if (!overlayContainer) {
				overlayContainer = new Group();
				overlayContainer.percentWidth = 100;
				container.addElement(overlayContainer);
			}
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void {
			for each (var componentElement:IComponentElement in getComponentElements(textFlow)) {
				// If the component hasn't yet been created then create a new one
				if (!componentElement.hasComponent()) {
					componentElement.createComponent();
					overlayContainer.addElement(componentElement.getComponent());
				}
				
				// Position and size the component
				componentElement.getComponent().setStyle("fontFamily", componentElement.computedFormat.fontFamily);
				componentElement.getComponent().setStyle("fontSize", componentElement.computedFormat.fontSize);
				
				var bounds:Rectangle = componentElement.getElementBounds();
				
				if (bounds) {
					// Convert the bounds from their original coordinate space to the coordinate space of the container
					// TODO: This doesn't quite work properly in Grid1.xml, although it is very close
					var containingBlock:RenderFlow = textFlow.flowComposer.getControllerAt(0).container as RenderFlow;
					bounds = PointUtil.convertRectangleCoordinateSpace(bounds, containingBlock, container);
					
					if (!isNaN(bounds.width)) componentElement.getComponent().width = bounds.width;
					if (!isNaN(bounds.height)) componentElement.getComponent().height = bounds.height; // TODO: This doesn't set the height correctly on the dropdownlist
					componentElement.getComponent().x = bounds.x;
					componentElement.getComponent().y = bounds.y + 1; // not sure if we want +1 - that should probably be in getElementBounds depending on the component
					
					componentElement.getComponent().visible = !componentElement.hideChrome;
				} else {
					componentElement.getComponent().visible = false;
				}
			}
			
			// Make sure the overlay container is at the front
			container.setElementIndex(overlayContainer, container.numChildren - 1); 
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void { }
		
		public function onTextFlowClear(textFlow:TextFlow):void {
			for each (var componentElement:IComponentElement in getComponentElements(textFlow))
				if (componentElement.hasComponent())
					componentElement.removeComponent();
		}
		
	}
}
