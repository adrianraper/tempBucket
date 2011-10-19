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
	
	import mx.core.IUIComponent;
	
	import org.davekeen.util.PointUtil;
	
	import spark.components.Group;
	
	public class OverlayBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		public function OverlayBehaviour(container:Group):void {
			super(container);
		}
		
		private function getComponentElements(textFlow:TextFlow):Array {
			var floatableTextFlow:FloatableTextFlow = textFlow as FloatableTextFlow;
			
			// Get all the elements that we will overlay
			if (floatableTextFlow) {
				return [ ].concat(
					   floatableTextFlow.getElementsByClass(InputElement),
					   floatableTextFlow.getElementsByClass(SelectElement),
					   floatableTextFlow.getElementsByClass(VideoElement),
					   floatableTextFlow.getElementsByClass(AudioElement));
			}
			
			return null;
		}
		
		public function onCreateChildren():void { }
		
		public function onTextFlowUpdate(textFlow:TextFlow):void {
			for each (var componentElement:IComponentElement in getComponentElements(textFlow)) {
				var containingBlock:RenderFlow = componentElement.getTextFlow().flowComposer.getControllerAt(0).container as RenderFlow;
				
				// If the component hasn't yet been created then create a new one and add it to the containing block
				if (!componentElement.hasComponent()) {
					componentElement.createComponent();
					containingBlock.addChild(componentElement.getComponent());
				}
				
				// Style the component in line with its underlying text
				componentElement.getComponent().setStyle("fontFamily", componentElement.computedFormat.fontFamily);
				componentElement.getComponent().setStyle("fontSize", componentElement.computedFormat.fontSize);
				componentElement.getComponent().setStyle("color", componentElement.computedFormat.color);
				
				var bounds:Rectangle = componentElement.getElementBounds();
				if (bounds) {
					// Convert the bounds from their original coordinate space to the coordinate space of the container
					bounds = PointUtil.convertRectangleCoordinateSpace(bounds, containingBlock, container);
					
					if (!isNaN(bounds.width)) componentElement.getComponent().width = bounds.width;
					if (!isNaN(bounds.height)) componentElement.getComponent().height = bounds.height;
					componentElement.getComponent().x = bounds.x;
					componentElement.getComponent().y = bounds.y;
					
					// Make the component visible, unless hideChrome is set in which case hide the component leaving the underlying area visible
					componentElement.getComponent().visible = !componentElement.hideChrome;
				} else {
					componentElement.getComponent().visible = false;
				}
			}
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void { }
		
		public function onTextFlowClear(textFlow:TextFlow):void {
			for each (var componentElement:IComponentElement in getComponentElements(textFlow))
				if (componentElement.hasComponent())
					componentElement.removeComponent();
		}
		
	}
}
