package com.clarityenglish.bento.form {
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class AbstractFormItemHandler {
		
		protected var _target:IEventDispatcher;
		
		protected var _node:XML;
		
		public function AbstractFormItemHandler(target:IEventDispatcher, node:XML) {
			this._target = target;
			this._node = node;
			
			if (node) {
				populate();
				addListener();
				
				target.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			}
		}
		
		protected function onRemovedFromStage(event:Event):void {
			target.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			_target = null;
			_node = null;
		}
		
		protected function populate():void {
			
		}
		
		/**
		 * The default listener is VALUE_COMMIT - a handler can override this and removeListener if necessary
		 */
		protected function addListener():void {
			target.addEventListener(FlexEvent.VALUE_COMMIT, onChange);
		}
		
		protected function removeListener():void {
			target.removeEventListener(FlexEvent.VALUE_COMMIT, onChange);
		}
		
		protected function onChange(event:Event):void {
			
		}
		
		public function get target():IEventDispatcher {
			return _target;
		}
		
		protected function get value():String {
			return _node.toString(); // TODO: check/implement for attributes
		}
		
		protected function set value(value:String):void {
			_node.setChildren(value); // TODO: check/implement for attributes
		}

	}
	
}