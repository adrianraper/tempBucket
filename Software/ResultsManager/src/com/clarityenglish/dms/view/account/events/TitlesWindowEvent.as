package com.clarityenglish.dms.view.account.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class TitlesWindowEvent extends Event {
		
		public static const SUBMIT:String = "submit";
		
		public var productCodes:Array;
		
		public function TitlesWindowEvent(type:String, productCodes:Array, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.productCodes = productCodes;
		} 
		
		public override function clone():Event { 
			return new TitlesWindowEvent(type, productCodes, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("TitlesWindowEvent", "type", "productCodes", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}