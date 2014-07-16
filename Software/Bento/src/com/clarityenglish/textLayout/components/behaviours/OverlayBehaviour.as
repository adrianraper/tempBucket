package com.clarityenglish.textLayout.components.behaviours {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.components.AudioPlayer;
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
		private var audioNodes:Array = [];
		private var xmlBiMap:FlowElementXmlBiMap;
		
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
					// gh#348 the feedback audio will be add to stage in AudioFeedbackBehaviour
					if (componentElement.getComponent() is AudioPlayer) {
						var audioElement:AudioElement = componentElement as AudioElement;
						if (getAudioElementIndex(audioElement) >= 0) {
							// disable playComponent for feedback audio before click "see answer"
							//audioElement.playComponentEnable = false;
							continue;
						} /*else {
							//audioElement.playComponentEnable = true;
						}*/
							
					}
					containingBlock.addChild(componentElement.getComponent());
				}
				
				// Style the component in line with its underlying text
				componentElement.getComponent().setStyle("fontFamily", componentElement.computedFormat.fontFamily);
				componentElement.getComponent().setStyle("fontSize", componentElement.computedFormat.fontSize);
				componentElement.getComponent().setStyle("color", componentElement.computedFormat.color);
				
				// Position and size the component in line with its underlying text
				var bounds:Rectangle = componentElement.getElementBounds();
				if (bounds) {
					// gh#472 To make the overlay deep enough, tweak the bounds that come back
					if (!isNaN(bounds.width)) componentElement.getComponent().width = bounds.width;
					if (!isNaN(bounds.height)) componentElement.getComponent().height = bounds.height + 1;
					componentElement.getComponent().x = bounds.x; 
					// gh#536 DK originally had this comment: // for some reason -1 is necessary to get everything to line up
					// AR BUT 0 for gapfill in a split screen. Does that indicate that this is a css conflict issue?
					// Yes. If I drop most css, I now get the gap too low! So set here as perfect for no css.
					componentElement.getComponent().y = bounds.y - 1; 
					
					// Make the component visible, unless hideChrome is set in which case hide the component leaving the underlying area visible
					componentElement.getComponent().visible = !componentElement.hideChrome;
				} else {
					componentElement.getComponent().visible = false;
				}
			}
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			xmlBiMap = flowElementXmlBiMap;
			
			if (xhtml is Exercise)
				audioNodes = (xhtml as Exercise).select("audio.audio-feedback");
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void {
			for each (var componentElement:IComponentElement in getComponentElements(textFlow))
				if (componentElement.hasComponent())
					componentElement.removeComponent();
		}
		
		private function getAudioElementIndex(element:AudioElement):Number {
			for each (var node:XML in audioNodes) {
				var audioElement:AudioElement = xmlBiMap.getFlowElement(node) as AudioElement;
				if(element == audioElement) {
					return audioNodes.indexOf(node);
				}
			}
			return -1;
		}
		
	}
}
