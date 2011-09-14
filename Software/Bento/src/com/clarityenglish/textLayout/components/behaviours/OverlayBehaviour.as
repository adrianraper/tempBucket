package com.clarityenglish.textLayout.components.behaviours {
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.IComponentElement;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.geom.Rectangle;
	
	import flashx.textLayout.elements.TextFlow;
	
	import spark.components.Group;
	
	public class OverlayBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		private var overlayContainer:Group;
		
		public function OverlayBehaviour(container:Group):void {
			super(container);
		}
		
		private function getComponentElements(textFlow:TextFlow):Array {
			// This is just temporary; make this nicer once we have a better idea of how the Spark overlays are going to work
			if (textFlow)
				return textFlow.getElementsByTypeName("input").concat(textFlow.getElementsByTypeName("select"), textFlow.getElementsByTypeName("video"));
			
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
			trace(TLFUtil.dumpTextFlow(textFlow));
			
			for each (var componentElement:IComponentElement in getComponentElements(textFlow)) {
				// If the component hasn't yet been created then create a new one
				if (!componentElement.hasComponent()) {
					componentElement.createComponent();
					overlayContainer.addElement(componentElement.getComponent());
				}
				
				// Position and size the component
				var fontSize:int = componentElement.computedFormat.fontSize;
				componentElement.getComponent().setStyle("fontSize", fontSize); // Not sure about this - should probably be in the element itself
				
				var bounds:Rectangle = componentElement.getElementBounds();
				
				if (bounds) {
					componentElement.getComponent().width = bounds.width;
					componentElement.getComponent().height = bounds.height;
					componentElement.getComponent().x = bounds.x;
					componentElement.getComponent().y = bounds.y + 1; // not sure if we want +1 - that should probably be in getElementBounds depending on the component
					
					componentElement.getComponent().visible = true;
				} else {
					componentElement.getComponent().visible = false;
				}
			}
		}

		public function onTextFlowClear(textFlow:TextFlow):void {
			for each (var componentElement:IComponentElement in getComponentElements(textFlow))
				if (componentElement.hasComponent())
					componentElement.removeComponent();
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void { }
		
	}
}
