package com.clarityenglish.bento.view.exercise.ui.behaviours {
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.conversion.FlowElementXmlBiMap;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.elements.TextFlow;
	
	import spark.components.Group;
	
	public class DictionaryBehaviour extends AbstractSectionBehaviour implements ISectionBehaviour {
		
		public function DictionaryBehaviour(container:Group) {
			super(container);
		}
		
		public function onCreateChildren():void { }
		
		public function onTextFlowUpdate(textFlow:TextFlow):void { }

		public function onTextFlowClear(textFlow:TextFlow):void { }

		public function onClick(event:MouseEvent, textFlow:TextFlow):void {
			// Get the click coordinates relative to this component
			var clickPoint:Object = container.globalToLocal(new Point(event.stageX, event.stageY));
			
			// Iterate through the lines in the TextFlow
			for (var i:int = 0; i < textFlow.flowComposer.numLines; i++) {
				var textFlowLine:TextFlowLine = textFlow.flowComposer.getLineAt(i);
				
				// If the click was on this TextFlowLine then iterate deeper
				if (textFlowLine.getBounds().contains(clickPoint.x, clickPoint.y)) {
					if (textFlowLine.textLineExists) {
						var textLine:TextLine = textFlowLine.getTextLine();
						for (var j:int = 0; j < textLine.atomCount; j++) {
							// Get the click point relative to the TextLine
							var tlClickPoint:Point = textLine.globalToLocal(new Point(event.stageX, event.stageY));
							
							// If the click is within the atom bounds then we have found an atom within the word
							if (textLine.getAtomBounds(j).contains(tlClickPoint.x, tlClickPoint.y)) {
								var word:String = textFlowLine.paragraph.getText(textFlowLine.paragraph.findPreviousWordBoundary(j), textFlowLine.paragraph.findNextWordBoundary(j));
								trace("You clicked on: " + word);
							}
						}
					}
				}
			}    
		}

		public function onImportComplete(html:XML, textFlow:TextFlow, exercise:Exercise, flowElementXmlBiMap:FlowElementXmlBiMap):void { }

	}
}
