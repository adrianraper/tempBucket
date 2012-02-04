package com.clarityenglish.textLayout.conversion {
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	
	import flash.utils.Dictionary;
	
	import flashx.textLayout.elements.FlowElement;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;

	/**
	 * This class is supposed to store a bi-directional map between XML nodes and their associated FlowElement.  Unfortunately due to a
	 * Flash Player bug (https://bugs.adobe.com/jira/browse/FP-2869) it is not possible to use XML nodes as keys for a Dictionary as
	 * strict equality is not maintained, hence breaking the Dictionary.
	 * 
	 * Therefore the FlowElement -> XML map uses a Dictionary, but XML -> FlowElement has to use an iterative Vector solution.
	 */
	public class FlowElementXmlBiMap {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var flowElementToXmlMap:Dictionary;
		
		private var xmlToFlowElementXmlVector:Vector.<XML>;
		private var xmlToFlowElementFlowElementVector:Vector.<FlowElement>;
		
		public function FlowElementXmlBiMap() {
			clear();
		}
		
		public function add(flowElement:FlowElement, xml:XML):void {
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
		
		public function clear():void {
			flowElementToXmlMap = new Dictionary(true);
			xmlToFlowElementXmlVector = new Vector.<XML>();
			xmlToFlowElementFlowElementVector = new Vector.<FlowElement>();
		}
		
	}
}