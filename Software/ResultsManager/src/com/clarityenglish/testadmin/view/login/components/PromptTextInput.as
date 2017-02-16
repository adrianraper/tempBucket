/**
 * This component adds a prompt to a text input for old mx components
 */
package com.clarityenglish.testadmin.view.login.components {
	import flash.events.Event;	
	import mx.controls.Label;
	import mx.controls.TextInput;
	
	public class PromptTextInput extends TextInput {
		private var _promptText:String;
		private var promptLabel:Label;
		
		public function PromptTextInput() {
			super();
			
			promptLabel = new Label();
			promptLabel.x = promptLabel.y = 6;
			promptLabel.visible = false;
			addChild(promptLabel);
			
			addEventListener(Event.CHANGE, onChange);
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			promptLabel.width = unscaledWidth;
			promptLabel.height = unscaledHeight;			
		}
		
		public function set promptStyleName(value:String):void {
			promptLabel.styleName = value;
		}
		
		public function set promptText(value:String):void {
			_promptText = value;
			promptLabel.text = value;
			promptLabel.visible = (text == "");
		}
		
		public function get promptText():String {
			return _promptText;
		}
		
		private function onChange(event:Event):void {
			promptLabel.visible = (text == "");
		}
	}
}