package com.clarityenglish.rotterdam.builder.view.uniteditor.tlf {
	import com.clarityenglish.rotterdam.builder.view.uniteditor.events.GapEvent;
	
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SubParagraphGroupElement;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	import flashx.undo.IUndoManager;
	
	import org.davekeen.util.StringUtils;
	
	use namespace tlf_internal;
	
	public class GapEditManager extends EditManager {
		
		protected static var gapCounter:uint = 1;
		
		protected var _selectedGapId:String;
		
		public function GapEditManager(undoManager:IUndoManager = null) {
			super(undoManager);
		}
		
		protected function set selectedGapId(value:String):void {
			if (value != _selectedGapId) {
				if (_selectedGapId)
					textFlow.dispatchEvent(new GapEvent(GapEvent.GAP_DESELECTED, _selectedGapId));
				_selectedGapId = value;
				if (_selectedGapId)
					textFlow.dispatchEvent(new GapEvent(GapEvent.GAP_SELECTED, _selectedGapId));
			}
		}
		
		public function getSelectedGapId():String {
			return _selectedGapId;
		}

        /**
         * gh@#1248 Set the gapCounter used for creating new gaps to account for all initial ones
         */
        public function initialiseGapIds(value:uint):void {
            gapCounter = value;
        }

		/**
		 * Select the full gapfill if there is a mouse selection
		 */
		public override function selectRange(anchorPosition:int, activePosition:int):void {
			// Find the clicked element - if it is a paragraph then its the main text body, if its a group then its a gap
			var element:FlowElement = textFlow.findLeaf(activePosition);
			
			if (!element || !element.parent || element.parent is ParagraphElement) {
				super.selectRange(anchorPosition, activePosition);
				selectedGapId = null;
			} else if (element.parent is SubParagraphGroupElement) {
				super.selectRange(element.parent.getAbsoluteStart(), element.parent.getAbsoluteStart() + element.textLength);
				selectedGapId = element.parent.id;
			}
		}
		
		protected override function handleLeftArrow(event:KeyboardEvent):SelectionState {
			return checkForGapfillOnSelection(super.handleLeftArrow(event));
		}
		
		protected override function handleRightArrow(event:KeyboardEvent):SelectionState {
			return checkForGapfillOnSelection(super.handleRightArrow(event));
		}
		
		protected override function handleUpArrow(event:KeyboardEvent):SelectionState {
			return checkForGapfillOnSelection(super.handleUpArrow(event));
		}
		
		protected override function handleDownArrow(event:KeyboardEvent):SelectionState {
			return checkForGapfillOnSelection(super.handleDownArrow(event));
		}
		
		// #1022
		public override function deletePreviousCharacter(operationState:SelectionState = null):void {
			var element:FlowElement = textFlow.findLeaf(activePosition - 1);
			if (!element || !element.parent || element.parent is ParagraphElement) {
				super.deletePreviousCharacter(operationState);
			}
		}
		
		// #1022
		public override function deleteNextCharacter(operationState:SelectionState = null):void {
			var element:FlowElement = textFlow.findLeaf(activePosition + 1);
			if (!element || !element.parent || element.parent is ParagraphElement) {
				super.deleteNextCharacter(operationState);
			}
		}
		
		/**
		 * Select the full gapfill if these is a keyboard selection
		 */
		private function checkForGapfillOnSelection(selectionState:SelectionState):SelectionState {
			var activePosition:int = selectionState.activePosition;
			
			var element:FlowElement = textFlow.findLeaf(activePosition);
			
			if (element && element.parent && element.parent is SubParagraphGroupElement && getSelectionState().absoluteStart != element.parent.getAbsoluteStart()) {
				selectionState.activePosition = element.parent.getAbsoluteStart();
				selectionState.anchorPosition = element.parent.getAbsoluteStart() + element.textLength;
				selectedGapId = element.parent.id;
			} else {
				selectedGapId = null;
			}
			
			return selectionState;
		}
		
		public function createGap():void {
			var selectionState:SelectionState = getSelectionState();
			
			if (selectionState.absoluteStart > -1 && selectionState.absoluteEnd > -1 && selectionState.absoluteStart != selectionState.absoluteEnd && textFlow.findLeaf(activePosition).parent && !(textFlow.findLeaf(activePosition).parent is SubParagraphGroupElement)) {
				var tlf:TextLayoutFormat = new TextLayoutFormat();
				tlf.textDecoration = TextDecoration.UNDERLINE;
				
				var element:SubParagraphGroupElement = createSubParagraphGroup(null, tlf);
				element.id = "gap" + (gapCounter++);
				textFlow.dispatchEvent(new GapEvent(GapEvent.GAP_CREATED, element.id, element.getText()));
			}
		}
		
		public function removeGap(id:String):void {
			var gapElement:SubParagraphGroupElement = textFlow.getElementByID(id) as SubParagraphGroupElement;
			
			if (gapElement) {
				var placeholder:String = StringUtils.trim(gapElement.getText());
				
				var tlf:TextLayoutFormat = new TextLayoutFormat();
				tlf.textDecoration = TextDecoration.NONE;
				clearFormat(tlf, tlf, tlf);
				
				overwriteText(placeholder + " ");
				
				textFlow.dispatchEvent(new GapEvent(GapEvent.GAP_REMOVED, id));
			}
		}
	
	}
}
