package com.clarityenglish.textLayout.util {
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.tlf_internal;
	
	import org.davekeen.util.ClassUtil;
	
	public class TLFUtil {
		
		/**
		 * Call this when the format of a flow element has changed to update it on the screen
		 * 
		 * @param flowElement
		 * @param updateAllControllers
		 */
		public static function markFlowElementFormatChanged(flowElement:FlowElement, updateAllControllers:Boolean = false):void {
			flowElement.getTextFlow().formatResolver.invalidate(flowElement);
			flowElement.tlf_internal::formatChanged();
			flowElement.computedFormat; // Force the format to be recomputed (without this TLF can throw exceptions in certain situations)
			
			flowElement.getTextFlow().flowComposer.damage(0, flowElement.getTextFlow().textLength, FlowDamageType.GEOMETRY); // #38
			
			if (updateAllControllers) flowElement.getTextFlow().flowComposer.updateAllControllers();
		}
		
		public static function getFlowElementBounds(flowElement:FlowElement):Rectangle {
			// First determine the absolute start and end locations within the TextFlow of this FlowLeafElement
			var startPosition:int = flowElement.getAbsoluteStart();
			
			// Get the flow leaf element (this is either already the flowElement or we use findElement to find it)
			var flowLeafElement:FlowLeafElement = (flowElement is FlowLeafElement) ? flowElement as FlowLeafElement : flowElement.getTextFlow().findLeaf(startPosition);
			
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
			
			var textLine:TextLine = textFlowLine.getTextLine(false);
			if (!textLine) return null;
			
			var position:int = absolutePosition - flowLeafElement.getParagraph().getAbsoluteStart();
			position = textLine.getAtomIndexAtCharIndex(position);
			
			if (position >= 0) {
				var atomBounds:Rectangle = textLine.getAtomBounds(position);
				atomBounds.offset(textLine.x, textLine.y);
				
				atomBounds.x = Math.round(atomBounds.x);
				atomBounds.y = Math.round(atomBounds.y);
				atomBounds.width = Math.round(atomBounds.width);
				atomBounds.height = Math.round(atomBounds.height);
				
				return atomBounds;
			}
			
			return null;
		}
		
		public static function dumpTextFlow(textFlow:TextFlow):String {
			return (textFlow) ? flowElementToXML(textFlow).toXMLString() : "";
		}
		
		private static function flowElementToXML(flowElement:FlowElement):XML {
			var node:XML = new XML("<" + flowElement.typeName + " />");
			
			node.@tlfClass = ClassUtil.getClassAsString(flowElement);
			
			if (flowElement is SpanElement) {
				node.appendChild((flowElement as SpanElement).text);
			}
			
			if (flowElement is InlineGraphicElement) {
				if ((flowElement as InlineGraphicElement).width) node.@width = (flowElement as InlineGraphicElement).width;
				if ((flowElement as InlineGraphicElement).height) node.@height = (flowElement as InlineGraphicElement).height;
				if ((flowElement as InlineGraphicElement).float) node.@float = (flowElement as InlineGraphicElement).float;
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