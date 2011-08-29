package com.clarityenglish.textLayout.conversion {
	import flash.utils.Dictionary;
	
	import flashx.textLayout.elements.FlowElement;

	/**
	 * This class is supposed to store a bi-directional map between XML nodes and their associated FlowElement.  Unfortunately due to a
	 * Flash Player bug (https://bugs.adobe.com/jira/browse/FP-2869) it is not possible to use XML nodes as keys for a Dictionary as
	 * strict equality is not maintained, hence breaking the Dictionary.
	 * 
	 * Therefore the FlowElement -> XML map uses a Dictionary, but XML -> FlowElement has to use an iterative Vector solution.
	 */
	public class FlowElementXmlBiMap {
		
		private var flowElementToXmlMap:Dictionary;
		
		private var xmlToFlowElementXmlVector:Vector.<XML>, xmlToFlowElementFlowElementVector:Vector.<FlowElement>;
		
		public function FlowElementXmlBiMap() {
			flowElementToXmlMap = new Dictionary();
			
			xmlToFlowElementXmlVector = new Vector.<XML>();
			xmlToFlowElementFlowElementVector = new Vector.<FlowElement>();
		}
		
		public function add(flowElement:FlowElement, xml:XML):void {
			if (flowElementToXmlMap[flowElement])
				throw new Error("There is already a mapping for FlowElement " + flowElement);
			
			// Removed this check for performance reasons
			/*if (xmlToFlowElementMap[xml])
				throw new Error("There is already a mapping for XML node " + xml.toXMLString());*/
			
			flowElementToXmlMap[flowElement] = xml;
			
			xmlToFlowElementXmlVector.push(xml);
			xmlToFlowElementFlowElementVector.push(flowElement);
		}
		
		public function getXML(flowElement:FlowElement):XML {
			return flowElementToXmlMap[flowElement];
		}
		
		public function getFlowElement(xml:XML):FlowElement {
			var idx:int = xmlToFlowElementXmlVector.indexOf(xml);
			return (idx < 0) ? null : xmlToFlowElementFlowElementVector[idx];
		}
		
	}
}