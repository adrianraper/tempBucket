package com.clarityenglish.textLayout.components.behaviours {
	import com.clarityenglish.bento.view.marking.events.MarkingEvent;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.AudioElement;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.elements.IComponentElement;
	import com.clarityenglish.textLayout.elements.InputElement;
	import com.clarityenglish.textLayout.elements.SelectElement;
	import com.clarityenglish.textLayout.elements.VideoElement;
	import com.clarityenglish.textLayout.rendering.RenderFlow;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import spark.components.Group;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.TextFlow;
	
	public class OverlayBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		// gh#1051 Obsolete?
		//private var afterMarkingAudioNodes:Array = [];
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
				}
				
				// gh#1501 If the node has either 'display-after-marking'/'audio-feedback' (legacy) then hide it
				var node:XML = xmlBiMap.getXML(componentElement as FlowElement);
				var displayAfterMarking:Boolean = XHTML.hasClass(node, "audio-feedback") || XHTML.hasClass(node, "display-after-marking");
				
				// Make the component visible, unless hideChrome is set in which case hide the component leaving the underlying area visible
				componentElement.getComponent().visible = bounds && !componentElement.hideChrome && !displayAfterMarking;
			}
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void { 
			var exercise:Exercise = xhtml as Exercise;
			xmlBiMap = flowElementXmlBiMap;
			
			if (!xhtml.hasEventListener(MarkingEvent.SEE_ANSWERS))
				xhtml.addEventListener(MarkingEvent.SEE_ANSWERS, onSeeAnswers, false, 0, true);
			
			// gh#1051 Obsolete?
			//afterMarkingAudioNodes = exercise.select("audio.audio-feedback");
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void {
			for each (var componentElement:IComponentElement in getComponentElements(textFlow))
				if (componentElement.hasComponent())
					componentElement.removeComponent();
		}
		
		/**
		 * gh#1501 
		 */
		protected function onSeeAnswers(event:MarkingEvent):void {
			var node:XML, componentElement:IComponentElement, xhtml:XHTML = event.currentTarget as XHTML;
			
			// Show any components with 'display-after-marking' or 'audio-feedback' (legacy)
			for each (node in xhtml.select("audio.audio-feedback, .display-after-marking")) {
				componentElement = xmlBiMap.getFlowElement(node) as IComponentElement;
				if (componentElement) componentElement.getComponent().visible = true;
			}
			
			// Hide any components with 'hide-after-marking'
			for each (node in xhtml.select(".hide-after-marking")) {
				componentElement = xmlBiMap.getFlowElement(node) as IComponentElement;
				if (componentElement) componentElement.getComponent().visible = false;
			}
		}
		
	}
}
