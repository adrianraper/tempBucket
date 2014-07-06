package com.clarityenglish.bento.form {
	import flash.events.Event;
	
	import org.davekeen.util.ArrayUtils;
	
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	
	public class RadioButtonGroupItemHandler extends AbstractFormItemHandler {
		
		protected var _keys:Array;
		protected var _data:Array;
		
		public function RadioButtonGroupItemHandler(radioButtonGroup:RadioButtonGroup, node:XML, keys:Array, data:Array) {
			this._keys = keys;
			this._data = data;
			
			super(radioButtonGroup, node);
		}
		
		override protected function populate():void {
			var idx:int = _data.indexOf(value);
			if (idx >= 0) _keys[idx].selected = true;
		}
		
		override protected function onChange(event:Event):void {
			var idx:int = _keys.indexOf((_target as RadioButtonGroup).selection);
			if (idx >= 0) value = _data[idx];
		}
		
		override protected function onRemovedFromStage(event:Event):void {
			_keys = _data = null;
			super.onRemovedFromStage(event);
		}
		
	}
	
}