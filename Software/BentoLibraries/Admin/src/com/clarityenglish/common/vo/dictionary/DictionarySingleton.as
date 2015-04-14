package com.clarityenglish.common.vo.dictionary {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import mx.events.PropertyChangeEvent;
	import mx.utils.ObjectUtil;
	
	/**
	 * This singleton class is used for access to dictionaries retrieved by DictionaryProxy.  Would be nicer if it was called Dictionary really,
	 * but this conflicts with flash.utils.Dictionary
	 * 
	 * @author ...
	 */
	[Bindable("propertyChange")]
	dynamic public class DictionarySingleton extends Proxy implements IEventDispatcher {
		
		private static var _instance:DictionarySingleton;
		
		private var dictionaries:Array;
		
		private var eventDispatcher:EventDispatcher;
		
		public function DictionarySingleton(caller:Function = null) {
			if(caller != DictionarySingleton.getInstance)
				throw new Error("DictionarySingleton is a singleton class, use getInstance() instead");
			if (DictionarySingleton._instance != null)
				throw new Error("Only one DictionarySingleton instance should be instantiated");
			
			dictionaries = new Array();
			
			eventDispatcher = new EventDispatcher(this);
		}
		
		/**
		 * Singleton
		 * 
		 * @return
		 */
		public static function getInstance():DictionarySingleton {
			if (!_instance) _instance = new DictionarySingleton(arguments.callee);
			return _instance;
		}
		
		override flash_proxy function getProperty(name:*):* {			
			if (!dictionaries[name])
				dictionaries[name] = new Array();
				
			return dictionaries[name];
		}
		
		override flash_proxy function setProperty(name:*, value:*):void {
			var oldValue:* = dictionaries[name];
			
			dictionaries[name] = value;
			
			var propertyChangeEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(this, name, oldValue, value);
			dispatchEvent(propertyChangeEvent);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return eventDispatcher.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}
		
	}
	
}