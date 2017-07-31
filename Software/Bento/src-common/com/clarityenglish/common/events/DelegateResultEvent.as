package com.clarityenglish.common.events {

import com.clarityenglish.common.vo.config.Endpoint;

import flash.events.Event;

import mx.rpc.events.ResultEvent;

/**
	 * ...
	 * @author Clarity
	 */
	public class DelegateResultEvent extends ResultEvent {
		
		public var endpoint:Endpoint;
		
		public function DelegateResultEvent(type:String, endpoint:Endpoint, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			
			this.endpoint = endpoint;
		} 
		
		public override function clone():Event { 
			return new MemoryEvent(type, endpoint, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("DelegateResultEvent", "type", "endpoint", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}