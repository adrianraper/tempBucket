package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.events.RenderFlowMouseEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.elements.TextFlow;
	
	import org.davekeen.util.PointUtil;
	
	import spark.components.Group;
	
	public class DictionaryBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		public function DictionaryBehaviour(container:Group) {
			super(container);
			
			container.addEventListener(RenderFlowMouseEvent.RENDER_FLOW_CLICK, onRenderFlowClick, false, 0, true);
		}
		
		public function onCreateChildren():void { }
		
		public function onTextFlowUpdate(textFlow:TextFlow):void { }
		
		public function onTextFlowClear(textFlow:TextFlow):void { }
		
		/**
		 * This seems to work everywhere except in a list :(
		 * 
		 * @param event
		 */
		public function onRenderFlowClick(event:RenderFlowMouseEvent):void {
			var mouseEvent:MouseEvent = event.mouseEvent;
			var textFlow:TextFlow = event.textFlow;
			
			// Get the click coordinates relative to this component
			var clickPoint:Object = container.globalToLocal(new Point(mouseEvent.stageX, mouseEvent.stageY));
			
			// Iterate through the lines in the TextFlow
			for (var i:int = 0; i < textFlow.flowComposer.numLines; i++) {
				var textFlowLine:TextFlowLine = textFlow.flowComposer.getLineAt(i);
				
				// If the click was on this TextFlowLine then iterate deeper
				if (textFlowLine.getBounds().contains(clickPoint.x, clickPoint.y)) {
					if (textFlowLine.textLineExists) {
						var textLine:TextLine = textFlowLine.getTextLine();
						for (var j:int = 0; j < textLine.atomCount; j++) {
							// Get the click point relative to the TextLine
							var tlClickPoint:Point = PointUtil.convertPointCoordinateSpace(new Point(clickPoint.x, clickPoint.y), container, textLine);
							
							// If the click is within the atom bounds then we have found an atom within the word
							var atomBounds:Rectangle = textLine.getAtomBounds(j);
							if (atomBounds.contains(tlClickPoint.x, tlClickPoint.y)) {

								var absoluteIdx:int = textFlowLine.absoluteStart - textFlowLine.paragraph.parentRelativeStart + j;
								
								try {
									var word:String = textFlowLine.paragraph.getText(textFlowLine.paragraph.findPreviousWordBoundary(absoluteIdx), textFlowLine.paragraph.findNextWordBoundary(absoluteIdx));
									trace("You clicked on: " + word);
								} catch (e:Error) {
									log.error(e.message);
								}
							}
						}
					}
				}
			}
		}

		public function onImportComplete(xhtml:XHTML, flowElementXmlBiMap:FlowElementXmlBiMap):void { }

	}
}
