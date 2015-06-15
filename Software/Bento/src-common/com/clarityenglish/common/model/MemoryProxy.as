/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.CommonNotifications;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.rpc.ResultResponder;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class MemoryProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "MemoryProxy";

		private var _memories:Object;

		public function get memories():Object {
			return _memories;
		}
		
		public function MemoryProxy(data:Object = null) {
			super(NAME, data);
		}
		
		/**
		 * Write a user's memory.
		 * 
		 */
		public function writeMemory(memories:Object):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			
			var params:Array = [ memories ];
			new RemoteDelegate("writeMemory", params, this).execute();
		}
		
		/** 
		 * Get a key from the user's memory. 
		 * This is not needed yet, but Dave suggests doing something like the following to get a memory at any point.
		 * 
		 */
		public function getMemory(key:String):Object {
			trace("key: "+key);
			return new RemoteDelegate("getMemory", [ key ], this).execute();
		}
		
		// Another proxy or a mediator calling this would have
		/*
		memoryProxy.getMemory('videoChannel').addResponder(new ResultResponder(
			function(e:ResultEvent, data:AsyncToken):void {
				view.selectedChannel = e.result;
			},
			function(e:FaultEvent, data:AsyncToken):void {
				var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
				sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorCantGetMemory"));
			}
		));
		*/
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void {
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			// TODO: Most of these generate errors on the client side; I need to implement this
			switch (operation) {
				case "writeMemory":
					var temp:Object = data;
					break;
				case "getMemory":
					_memories = data;
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, fault:Fault):void {
			sendNotification(CommonNotifications.TRACE_ERROR, fault.faultString);
		}
	}
}
