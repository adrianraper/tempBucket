package com.clarityenglish.textLayout.elements {
	import com.clarityenglish.bento.view.xhtmlexercise.events.MarkingOverlayEvent;
	import com.clarityenglish.textLayout.util.TLFUtil;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.utils.StringUtil;
	
	import spark.components.Button;
	import spark.components.Scroller;
	import spark.components.TextInput;
	
	use namespace tlf_internal;
	
	public class InputElement extends TextComponentElement implements IComponentElement {
		
		/**
		 * An input of type 'text' maps to a Spark TextInput component.
		 */
		public static const TYPE_TEXT:String = "text";
		
		/**
		 * An input of type 'button' maps to a Spark Button component
		 */
		public static const TYPE_BUTTON:String = "button";
		
		/**
		 * An input of type 'droptarget' maps to a Spark Label that accepts drops
		 * TODO: This is currently a TextInput
		 */
		public static const TYPE_DROPTARGET:String = "droptarget";
		
		private var _type:String;
		
		private var _value:String;
		
		private var _gapAfterPadding:Number;
		
		private var _gapText:String;
		
		// gh#338
		private var _showHint:Boolean;
		
		/**
		 * If the input was populated by drag and drop, this is the node and flow element that was dropped
		 */
		private var _droppedNode:XML;
		private var _droppedFlowElement:FlowElement;
		
		private var disableValueCommitEvent:Boolean;
		
		// gh#407 hold the longest answer, only useful for errorCorrection
		private var _longestAnswer:String;
		
		public function InputElement() {
			super();
		}
		
		protected override function get abstract():Boolean {
			return false;
		}
		
		/** @private */
		tlf_internal override function get defaultTypeName():String {
			return "input";
		}
		
		public function get value():String {
			return _value;
		}
		
		public function get enteredValue():String {
			switch (_type) {
				case TYPE_TEXT:
				case TYPE_DROPTARGET:
					return (component) ? (component as TextInput).text : null;
			}
			
			return null;
		}
		
		public function get droppedNode():XML {
			return _droppedNode;
		}
		
		public function get droppedFlowElement():FlowElement {
			return _droppedFlowElement;
		}
		
		/**
		 * If value is set the input is prefilled with the given value
		 *
		 * @param value
		 */
		public function set value(value:String):void {
			_value = value;
			
			// #98 - don't dispatch any events when the value is being set programatically so that feedback can't be fired on show answers
			disableValueCommitEvent = true;
			updateComponentFromValue();
			disableValueCommitEvent = false;
		}
		
		/**
		 * Inputs are rendered above a TLF span element so that the width is correct.  If afterPad is set (through the CSS after-pad property) then after-pad "_" characters
		 * are appended to the underlying text.
		 *
		 * @param value
		 */
		public function set gapAfterPadding(value:Number):void {
			_gapAfterPadding = value;
		}

		// gh#407 hold the longest answer, only useful for errorCorrection
		public function set longestAnswer(value:String):void {
			_longestAnswer = value;
		}
		public function get longestAnswer():String {
			return _longestAnswer;
		}

		public function set gapText(value:String):void {
			_gapText = value;
			
			// TODO: I don't think this does anything... remove at some point in the future
			modelChanged(ModelChange.ELEMENT_MODIFIED, this, 0, textLength);
		}
		
		public function get type():String {
			return _type;
		}
		
		public override function set text(textValue:String):void {
			if (_hideChrome && value) {
				// If a value has been provided and hideChrome is true, this means that we want the user to see the text underneath the input so
				// disable gapText and gapAfterPadding and just set the underlying text to the value.
				super.text = value;
			} else {
				// Pad the hidden text with _ characters (this is set using the after-pad CSS property).  If widthText is set, then we just use that.
				super.text = (_gapText) ? _gapText : textValue + StringUtil.repeat("_", _gapAfterPadding);
			}
		}
		
		/**
		 * This is a little hacky, but if hideChrome is changed (e.g. when a hidden error correction input is clicked on) then set text again
		 * from the value since the text may need to be updated depending on the value of hideChrome.
		 *
		 * @param value
		 */
		public override function set hideChrome(value:Boolean):void {
			super.hideChrome = value;
			text = this.value;
			
			// If the chrome is hidden then show what's underneath, otherwise hide it
			textAlpha = (value) ? 1 : 0;
		}
		
		[Inspectable(category = "Common", enumeration = "text,button,droptarget", defaultValue = "text")]
		public function set type(value:String):void {
			// Check this is an allowed type
			if ([TYPE_TEXT, TYPE_BUTTON, TYPE_DROPTARGET].indexOf(value) < 0)
				throw new Error("Illegal type '" + value + "' for InputElement");
			
			// Check that we are not trying to change from an existing type (not currently allowed)
			if (_type)
				throw new Error("It is not allowed to change the type on an existing input element");
			
			_type = value;
		}
		
		// gh#338
		[Bindable]
		public function get showHint():Boolean {
			return _showHint;
		}
		
		public function set showHint(value:Boolean):void {
				_showHint = value;
		}
		
		public function createComponent():void {
			// The default type is text
			if (!_type)
				_type = TYPE_TEXT;
			
			switch (type) {
				case TYPE_TEXT:
					component = new TextInput();
					
					// If the user presses <enter> whilst in the textinput go to the next element in the focus cycle group
					component.addEventListener(FlexEvent.ENTER, onEnter);
					
					// Duplicate some events on the event mirror so other things can listen to the FlowElement
					component.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void {
						if (!disableValueCommitEvent)
							getEventMirror().dispatchEvent(e.clone());
					});
					
					// Duplicate some events on the event mirror so other things can listen to the FlowElement
					component.addEventListener(FocusEvent.FOCUS_OUT, function(e:Event):void {
						if (!disableValueCommitEvent){
							getEventMirror().dispatchEvent(e.clone());
						}
							
					});
					break;
				case TYPE_DROPTARGET:
					component = new TextInput();
					
					// It is not possible to type into a drop target or select any text within it
					(component as TextInput).editable = (component as TextInput).selectable = false;
					
					// If the user presses <enter> whilst in the textinput go to the next element in the focus cycle group
					component.addEventListener(FlexEvent.ENTER, onEnter);
					
					component.addEventListener(DragEvent.DRAG_ENTER, onDragEnter);
					component.addEventListener(DragEvent.DRAG_DROP, onDragDrop);
					component.addEventListener(DragEvent.DRAG_COMPLETE, onDragComplete);
					break;
				case TYPE_BUTTON:
					throw new Error("Button type not yet implemented");
					break;
			}
			
			updateComponentFromValue();
		}
		
		private function onEnter(event:FlexEvent):void {
			var nextComponent:DisplayObject = event.target.focusManager.getNextFocusManagerComponent();
			event.target.focusManager.setFocus(nextComponent);
			
			// #187 - if the focused element is offscreen then scroll it into view
			
			// First find the parent scroller
			var displayObject:DisplayObject = nextComponent;
			while (!(displayObject is Scroller) && displayObject.parent)
				displayObject = displayObject.parent;
			
			if (!displayObject || displayObject is Stage)
				return;
			
			var scroller:Scroller = displayObject as Scroller;
			
			// If the scroller has no scrollbar then there is nothing to do
			if (!scroller.verticalScrollBar)
				return;
			
			// Get the component's y position by summing y positions up the hierarchy
			var focusTopEdge:int = nextComponent.y;
			var thisItem:DisplayObjectContainer = nextComponent.parent;
			while (thisItem !== scroller) {
				focusTopEdge += thisItem.y;
				thisItem = thisItem.parent;
			}
			
			var focusBottomEdge:int = focusTopEdge + nextComponent.height;
			var scrollbarRange:int = scroller.verticalScrollBar.maxHeight;
			var visibleWindowHeight:int = scroller.height;
			var lastVisibleY:int = visibleWindowHeight + scroller.viewport.verticalScrollPosition;
			
			if (focusTopEdge == scroller.viewport.verticalScrollPosition) {
				// Do nothing
			} else if (focusTopEdge != 0) {
				// If the component is out of view then scroll it into view
				var newPos:int = Math.min(scrollbarRange, scroller.viewport.verticalScrollPosition + (focusBottomEdge - lastVisibleY));
				scroller.viewport.verticalScrollPosition = newPos;
			}
		}
		
		private function onDragEnter(event:DragEvent):void {
			var dropTarget:IUIComponent = IUIComponent(event.currentTarget);
			DragManager.acceptDragDrop(dropTarget);
			
			// If we are dragging to ourselves don't show the green icon, but still allow it (so we can catch it in onDragComplete)
			DragManager.showFeedback((dropTarget !== event.dragInitiator) ? DragManager.COPY : DragManager.NONE);
		}
		
		protected function onDragDrop(event:DragEvent):void {
			dragDrop(event.dragSource.dataForFormat("node") as XML, event.dragSource.dataForFormat("flowElement") as FlowElement, event.dragSource.dataForFormat("text").toString());
			
			if (event.dragSource.hasFormat("text")) {
				// TODO: This works, but basically we are forcing a complete update which isn't really necessary...
				getTextFlow().flowComposer.damage(0, getTextFlow().textLength, FlowDamageType.GEOMETRY);
				getTextFlow().flowComposer.updateAllControllers();
				
				// Dispatch a value commit, so if we are using instant marking the question will get marked at this point
				//getEventMirror().dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				
				// #400 Dispatch a focus out event, so if we are using instant marking the question will get marked at this point
				getEventMirror().dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
			}
		}
		
		public function dragDrop(node:XML, flowElement:FlowElement, text:String):void {
			if (node) {
				// #11 - when dragging over an input which already has some content we want to renabled the drag source we just replaced
				if (_droppedNode && _droppedFlowElement && node !== _droppedNode) {
					XHTML.removeClasses(_droppedNode, ["disabled", "used"]);
					TLFUtil.markFlowElementFormatChanged(_droppedFlowElement);
					_droppedFlowElement.getTextFlow().flowComposer.updateAllControllers();
				}
				
				_droppedNode = node;
				_droppedFlowElement = flowElement;
			}
			
			if (text) {
				value = text;
				updateComponentFromValue();
				
				// Bypass the gapText and gapAfterPadding properties by setting text on the superclass 
				super.text = value;
				
				// #170 - put in an extra space at the end of the previous element in order to force word-wrap.  Very hacky!
				// gh#472 and causes all drops to shift a bit right so alignment looks bad. Remove and live with the original bug. 
				/*
				var previousSibling:FlowElement = getPreviousSibling();
				if (previousSibling is SpanElement) {
					var spanElement:SpanElement = previousSibling as SpanElement;
					if (spanElement.text.substr(spanElement.text.length - 1, 1) != " ") spanElement.text += " ";
				}
				*/
			}
		}
		
		/**
		 * If DRAG_COMPLETE is invoked with feedback of NONE it means that the content has been dropped outside of a valid target.  This may mean
		 * we want to clear the gapfill.  Note that this is called on the drag initiator (i.e. the gapfill the user dragged from) unlike the other
		 * onDrag methods in InputElement which are called on the drag target.
		 *
		 * @param event
		 */
		protected function onDragComplete(event:DragEvent):void {
			// If the item is dragged from itself to itself then do nothing
			if (event.relatedObject === getComponent())
				return;
			
			// #11
			if (_droppedNode && _droppedFlowElement) {
				XHTML.removeClasses(_droppedNode, ["disabled", "used"]);
				TLFUtil.markFlowElementFormatChanged(_droppedFlowElement);
				droppedFlowElement.getTextFlow().flowComposer.updateAllControllers();
			}
			
			// #101 states than no matter what the source will be cleared so no need to check for DragManager.NONE - if (DragManager.getFeedback() == DragManager.NONE) {
			_droppedFlowElement = null;
			_droppedNode = null;
			text = "";
			value = "";
			(component as TextInput).text = "";
			getTextFlow().dispatchEvent(new MarkingOverlayEvent(MarkingOverlayEvent.FLOW_ELEMENT_UNMARKED, this));
			// gh#474: when the answer is cleared, we need to reassign the value to answer
			getEventMirror().dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
		}
		
		private function updateComponentFromValue():void {
			if (value && component) {
				switch (type) {
					case TYPE_TEXT:
						(component as TextInput).text = text = value;
						break;
					case TYPE_DROPTARGET:
						(component as TextInput).text = text = value;
						break;
					case TYPE_BUTTON:
						(component as Button).label = text = value;
						break;
				}
			}
		}
	
	}

}
