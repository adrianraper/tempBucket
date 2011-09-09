package com.clarityenglish.textLayout.util {
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.utils.ObjectUtil;
	
	public class TLFUtil {
		
		public static function getFlowLeafElementBounds(flowLeafElement:FlowLeafElement):Rectangle {
			// First determine the absolute start and end locations within the TextFlow of this FlowLeafElement
			var startPosition:int = flowLeafElement.getAbsoluteStart();
			var endPosition:int = (flowLeafElement.getNextLeaf()) ? flowLeafElement.getNextLeaf().getAbsoluteStart() : flowLeafElement.getTextFlow().textLength;
			endPosition--;
			
			// Now get the bounds of the first and last atom (i.e. the first and last characters)
			var startRectangle:Rectangle = getAtomBounds(flowLeafElement.getTextFlow(), flowLeafElement, startPosition);
			var endRectangle:Rectangle = getAtomBounds(flowLeafElement.getTextFlow(), flowLeafElement, endPosition);
			if (!startRectangle || !endRectangle) return null;
			
			// The bounds of the entire FlowLeafElement should be the union of these two rectangles
			// TODO: We should check if this goes over multiple lines, and if so return null (or take some other action)
			return startRectangle.union(endRectangle)
		}
		
		public static function getAtomBounds(textFlow:TextFlow, flowLeafElement:FlowLeafElement, absolutePosition:int):Rectangle {
			var textFlowLine:TextFlowLine = textFlow.flowComposer.findLineAtPosition(absolutePosition);
			if (!textFlowLine) return null;
			
			var textLine:TextLine = textFlowLine.getTextLine(true);
			if (!textLine) return null;
			
			var position:int = absolutePosition - flowLeafElement.getParagraph().getAbsoluteStart();
			position = textLine.getAtomIndexAtCharIndex(position);
			
			if (position >= 0) {
				var atomBounds:Rectangle = textLine.getAtomBounds(position);
				atomBounds.offset(textLine.x, textLine.y);
				
				atomBounds.x = Math.floor(atomBounds.x);
				atomBounds.y = Math.floor(atomBounds.y);
				atomBounds.width = Math.ceil(atomBounds.width);
				atomBounds.height = Math.ceil(atomBounds.height);
				
				return atomBounds;
			}
			
			return null;
		}
		
		public static function dumpTextFlow(textFlow:TextFlow):String {
			return flowElementToXML(textFlow).toXMLString();
		}
		
		private static function flowElementToXML(flowElement:FlowElement):XML {
			var node:XML = new XML("<" + flowElement.typeName + " />");
			
			if (flowElement is SpanElement) {
				node.appendChild((flowElement as SpanElement).text);
			}
			
			if (flowElement is FlowGroupElement) {
				for each (var childFlowElement:FlowElement in (flowElement as FlowGroupElement).mxmlChildren) {
					node.appendChild(flowElementToXML(childFlowElement));
				}
			}
			
			return node;
		}
		
	}
	
}