package com.clarityenglish.bento.view.xhtmlexercise.components.behaviours {
	import com.clarityenglish.bento.view.xhtmlexercise.events.DictionaryEvent;
	import com.clarityenglish.textLayout.components.behaviours.AbstractXHTMLBehaviour;
	import com.clarityenglish.textLayout.components.behaviours.IXHTMLBehaviour;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	import com.clarityenglish.textLayout.events.RenderFlowMouseEvent;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.utils.StringUtil;
	
	import org.davekeen.util.PointUtil;
	import org.hamcrest.number.IsCloseToMatcher;
	
	import spark.components.Group;
	
	public class DictionaryBehaviour extends AbstractXHTMLBehaviour implements IXHTMLBehaviour {
		
		public function DictionaryBehaviour(container:Group) {
			super(container);
			
			// Listen for clicks on the render flow
			container.addEventListener(Event.REMOVED_FROM_STAGE, onContainerRemovedFromStage)
			container.addEventListener(RenderFlowMouseEvent.RENDER_FLOW_CLICK, onRenderFlowClick);
		}
		
		protected function onContainerRemovedFromStage(event:Event):void {
			container.removeEventListener(Event.REMOVED_FROM_STAGE, onContainerRemovedFromStage)
			container.removeEventListener(RenderFlowMouseEvent.RENDER_FLOW_CLICK, onRenderFlowClick);
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
				
				// Convert the coordinate space for contained RenderFlows (gh#416)
				var textFlowLineBounds:Rectangle = PointUtil.convertRectangleCoordinateSpace(textFlowLine.getBounds(), textFlowLine.paragraph.getTextFlow().flowComposer.getControllerAt(0).container, container);
				
				// If the click was on this TextFlowLine then iterate deeper
				if (textFlowLineBounds.contains(clickPoint.x, clickPoint.y)) {
					if (textFlowLine.textLineExists) {
						var textLine:TextLine = textFlowLine.getTextLine();
						for (var j:int = 0; j < textLine.atomCount; j++) {
							// Get the click point relative to the TextLine
							var tlClickPoint:Point = PointUtil.convertPointCoordinateSpace(new Point(clickPoint.x, clickPoint.y), container, textLine);
							
							// If the click is within the atom bounds then we have found an atom within the word
							var atomBounds:Rectangle = textLine.getAtomBounds(j);
							if (atomBounds.contains(tlClickPoint.x, tlClickPoint.y)) {
								// Determine the relative position of this atom within the paragraph
								var relativeIdx:int = textFlowLine.absoluteStart - textFlowLine.paragraph.getAbsoluteStart() + j;
								
								try {
									// Get the word and send it to the outside world as an event on the container
									var word:String = StringUtil.trim(textFlowLine.paragraph.getText(textFlowLine.paragraph.findPreviousWordBoundary(relativeIdx), textFlowLine.paragraph.findNextWordBoundary(relativeIdx)));
									//log.debug("User clicked on the word '{0}'", word);
									
									container.dispatchEvent(new DictionaryEvent(DictionaryEvent.WORD_CLICK, word, true));
								} catch (e:Error) {
									log.error(e.getStackTrace());
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
