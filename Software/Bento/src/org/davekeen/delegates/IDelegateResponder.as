package org.davekeen.delegates {
	import mx.rpc.Fault;
	
	public interface IDelegateResponder {
		
		function onDelegateResult(operation:String, data:Object):void;
		function onDelegateFault(operation:String, fault:Fault):void;
		
	}
	
}