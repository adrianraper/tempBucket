package org.davekeen.delegates {
	import mx.rpc.AsyncToken;
	
	public interface IDelegate {
		
		function execute():AsyncToken;
		
	}
	
}