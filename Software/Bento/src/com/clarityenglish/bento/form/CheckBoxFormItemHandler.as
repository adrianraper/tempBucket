package com.clarityenglish.bento.form {
	import flash.events.Event;
	
	import spark.components.CheckBox;
	
	public class CheckBoxFormItemHandler extends AbstractFormItemHandler {
		
		public function CheckBoxFormItemHandler(checkBox:CheckBox, node:XML) {
			super(checkBox, node);
		}
		
		override protected function populate():void {
			(target as CheckBox).selected = (value == "true");
		}
		
		override protected function onChange(event:Event):void {
			value = (target as CheckBox).selected ? "true" : "false";
		}
		
	}
	
}