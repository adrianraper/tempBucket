package com.clarityenglish.components {
	import flash.events.FocusEvent;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.events.FlexEvent;
	
	import spark.components.RichEditableText;
	
	public class PromptingRichEditableText extends RichEditableText {
		
		private var _placeholderColor:String = "#AAAAAA";
		private var _placeholder:String;
		private var _placeholderChanged:Boolean;
		
		private var _placeholderFlow:TextFlow;
		
		private var _originalTextFlow:TextFlow;
		
		private var hasFocus:Boolean;
		private var needToCheckPrompt:Boolean;
		
		private var isDisplayingPrompt:Boolean;
		
		public function PromptingRichEditableText() {
			super();
			
			addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
		
		public function get placeholder():String {
			return _placeholder;
		}
		
		public function set placeholder(value:String):void {
			_placeholder = value;
			_placeholderChanged = true;
			invalidateProperties();
		}
		
		public function get placeholderColor():String {
			return _placeholderColor;
		}
		
		public function set placeholderColor(value:String):void {
			_placeholderColor = value;
			_placeholderChanged = true;
			invalidateProperties();
		}
		
		protected function onFocusIn(event:FocusEvent):void {
			hasFocus = true;
			needToCheckPrompt = true;
			invalidateProperties();
		}
		
		protected function onFocusOut(event:FocusEvent):void {
			hasFocus = false;
			needToCheckPrompt = true;
			invalidateProperties();
		}
		
		public override function set textFlow(value:TextFlow):void {
			super.textFlow = value;
			_originalTextFlow = value;
			
			needToCheckPrompt = true;
			invalidateProperties();
		}
		
		public override function get text():String {
			if (isDisplayingPrompt) {
				return "";
			} else {
				return super.text;
			}
		}
		
		protected override function commitProperties():void {
			// If the placeholder or placeholder colour has changed then update the cached flow
			if (_placeholderChanged && _placeholder && _placeholderColor) {
				var html:XML = <font color={_placeholderColor}>{_placeholder}</font>;
				_placeholderFlow = TextConverter.importToFlow(html, TextConverter.TEXT_FIELD_HTML_FORMAT);
				_placeholderChanged = false;
			}
			
			if (needToCheckPrompt && editable) {
				// Show or hide the placeholder accordingly
				addEventListener(FlexEvent.VALUE_COMMIT, onValueCommitMuncher, false, int.MAX_VALUE);
				if (!hasFocus && super.text == "") {
					isDisplayingPrompt = true;
					super.textFlow = _placeholderFlow;
				} else {
					isDisplayingPrompt = false;
					super.textFlow = _originalTextFlow;
				}
				removeEventListener(FlexEvent.VALUE_COMMIT, onValueCommitMuncher);
				
				needToCheckPrompt = false;
			}
			
			super.commitProperties();
		}
		
		/**
		 * Munch up the value commit event so it doesn't get fired by the automatic placeholder text changing
		 * 
		 * @param event
		 */
		protected function onValueCommitMuncher(event:FlexEvent):void {
			event.preventDefault();
			event.stopPropagation();
			event.stopImmediatePropagation();
		}
		
	}
}