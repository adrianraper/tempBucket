package com.clarityenglish.bento.form {
	import flash.events.Event;
	
	import spark.components.supportClasses.SkinnableTextBase;
	
	public class TextFormItemHandler extends AbstractFormItemHandler {
		
		public function TextFormItemHandler(textComponent:SkinnableTextBase, node:XML) {
			super(textComponent, node);
		}

		override protected function populate():void {
			(target as SkinnableTextBase).text = value;
		}
		
		override protected function onChange(event:Event):void {
			value = (target as SkinnableTextBase).text;
		}
		
	}
	
}