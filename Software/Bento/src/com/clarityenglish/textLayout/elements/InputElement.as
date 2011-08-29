package com.clarityenglish.textLayout.elements {
	import flash.utils.setTimeout;
	
	import flashx.textLayout.compose.FlowDamageType;
	import flashx.textLayout.events.ModelChange;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	import mx.utils.StringUtil;
	
	import spark.components.Button;
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
		
		public function InputElement() {
			super();
		}
		
		protected override function get abstract():Boolean {
			return false;
		}
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "input"; }
		
		public function get value():String {
			return _value;
		}
		
		/**
		 * If value is set the input is prefilled with the given value
		 * 
		 * @param value
		 */
		public function set value(value:String):void {
			_value = value;
			
			updateComponentFromValue();
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
		
		public function set gapText(value:String):void {
			_gapText = value;
			
			// TODO: I don't think this does anything... remove at some point in the future
			modelChanged(ModelChange.ELEMENT_MODIFIED, this, 0, textLength);
		}
		
		public function get type():String {
			return _type;
		}
		
		public override function set text(textValue:String):void {
			// Pad the hidden text with _ characters (this is set using the after-pad CSS property).  If widthText is set, then we just use that.
			super.text = (_gapText) ? _gapText : textValue + StringUtil.repeat("_", _gapAfterPadding);
		}
		
		[Inspectable(category="Common", enumeration="text,button,droptarget", defaultValue="text")]
		public function set type(value:String):void {
			// Check this is an allowed type
			if ( [ TYPE_TEXT, TYPE_BUTTON, TYPE_DROPTARGET ].indexOf(value) < 0)
				throw new Error("Illegal type '" + value + "' for InputElement");
			
			// Check that we are not trying to change from an existing type (not currently allowed)
			if (_type)
				throw new Error("It is not allowed to change the type on an existing input element");
			
			_type = value;
		}
		
		public function createComponent():void {
			// The default type is text
			if (!_type)
				_type = TYPE_TEXT;
			
			switch (type) {
				case TYPE_TEXT:
					component = new TextInput();
					break;
				case TYPE_BUTTON:
					throw new Error("Button type not yet implemented");
					break;
				case TYPE_DROPTARGET:
					//throw new Error("Droptarget type not yet implemented");
					
					// TODO: This is a bit hacky, but good for proof of concept
					
					// This could also be a Label
					component = new TextInput();
					component.addEventListener(DragEvent.DRAG_ENTER, onDragEnter);
					component.addEventListener(DragEvent.DRAG_DROP, onDropDrop);
					break;
			}
			
			updateComponentFromValue();
		}
			
		private function onDragEnter(event:DragEvent):void {
			var dropTarget:IUIComponent = IUIComponent(event.currentTarget);
			DragManager.acceptDragDrop(dropTarget);
			DragManager.showFeedback(DragManager.COPY);
		}
		
		protected function onDropDrop(event:DragEvent):void {
			if (event.dragSource.hasFormat("text")) {
				value = event.dragSource.dataForFormat("text").toString();
				updateComponentFromValue();
				
				// Bypass the gapText and gapAfterPadding properties by setting text on the superclass 
				super.text = value;
				
				// TODO: This works, but basically we are forcing a complete update which isn't really necessary...
				getTextFlow().flowComposer.damage(0, getTextFlow().textLength, FlowDamageType.GEOMETRY);
				getTextFlow().flowComposer.updateAllControllers();
			}
		}
		
		private function updateComponentFromValue():void {
			if (value && component) {
				switch (type) {
					case TYPE_TEXT:
						(component as TextInput).text = value;
						break;
					case TYPE_BUTTON:
						(component as Button).label = value;
						break;
					case TYPE_DROPTARGET:
						(component as TextInput).text = value;
						break;
				}
			}
		}
		
	}
	
}
