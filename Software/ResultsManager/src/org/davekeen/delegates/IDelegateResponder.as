package org.davekeen.delegates {
	
	public interface IDelegateResponder {
		
		function onDelegateResult(operation:String, data:Object):void;
		function onDelegateFault(operation:String, data:Object):void;
		
	}
	
}