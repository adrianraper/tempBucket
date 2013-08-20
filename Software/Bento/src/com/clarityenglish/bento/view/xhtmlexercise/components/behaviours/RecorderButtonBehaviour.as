package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.tlf_internal;
	
	import org.davekeen.util.Closure;
	
	import spark.components.Group;
	
	public class RecorderButtonBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		public function RecorderButtonBehaviour(container:Group) {
			super(container);
		}
		
		public function onCreateChildren():void {
			
		}
		
		public function onTextFlowUpdate(textFlow:TextFlow):void {
			
		}
		
		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void {
			for each (var recordButtonNode:XML in xhtml.select(".recorder-button")) {
				var recordButtonFlowElement:FlowElement = flowElementXmlBiMap.getFlowElement(recordButtonNode);
				
				if (recordButtonFlowElement is FlowLeafElement) {
					recordButtonFlowElement.tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.CLICK, Closure.create(this, onFlowElementClick, recordButtonNode, recordButtonFlowElement));
				} else if (recordButtonFlowElement is FloatableTextFlow) {
					(recordButtonFlowElement as FloatableTextFlow).getFirstLeaf().tlf_internal::getEventMirror().addEventListener(FlowElementMouseEvent.CLICK, Closure.create(this, onFlowElementClick, recordButtonNode, recordButtonFlowElement));
				} else {
					log.error("class='record-button' is only valid on leaf elements - " + recordButtonFlowElement);
				}
			}
		}
		
		private function onFlowElementClick(e:FlowElementMouseEvent, draggableNode:XML, draggableFlowElement:FlowElement):void {
			container.dispatchEvent(new RecorderEvent(RecorderEvent.SHOW, null, true));
		}
		
		public function onTextFlowClear(textFlow:TextFlow):void {
			
		}
		
	}
}
