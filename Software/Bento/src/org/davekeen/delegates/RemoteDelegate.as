package org.davekeen.delegates {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class RemoteDelegate extends EventDispatcher implements IDelegate {
		
		private static var disableAppOnCall:Boolean = false;
		
		// PHP Error codes
		public static const E_ERROR:int = 1;
		public static const E_WARNING:int = 1;
		public static const E_NOTICE:int = 8;
		
		private var responder:IDelegateResponder;
		private var operationName:String;
		private var args:Array;
		private var remoteObject:RemoteObject;
		private var dispatchEvents:Boolean;
		
		private static var showBusyCursor:Boolean = true;
		
		private static var channelSet:ChannelSet;
		private static var service:String;
		
		public function RemoteDelegate(operationName:String = "", args:Array = null, responder:IDelegateResponder = null, dispatchEvents:Boolean = false) {
			super();
			
			this.responder = responder;
			this.operationName = operationName;
			this.args = args;
			this.dispatchEvents = dispatchEvents;
		}
		
		public static function setShowBusyCursor(value:Boolean):void {
			showBusyCursor = value;
		}
		
		/**
		 * Statically set the gateway for the delegate.  For AMFPHP this will be the absolute URL of a gateway.php file.
		 * 
		 * @param	url
		 */
		public static function setGateway(url:String):void {
			channelSet = new ChannelSet();
			var amfChannel:AMFChannel = new AMFChannel("amfphp", url);
			channelSet.addChannel(amfChannel);
		}
		
		/**
		 * Staticaly set the service (remote class) that this delegate will be calling methods on.
		 * 
		 * @param	service
		 */
		public static function setService(s:String):void {
			service = s;
		}
		
		public function setOperationName(operationName:String):void {
			this.operationName = operationName;
		}
		
		public function getOperationName():String {
			return operationName;
		}
		
		public function setArgs(args:Array = null):void {
			this.args = args;
		}
		
		public function setDispatchEvents(dispatchEvents:Boolean):void {
			this.dispatchEvents = dispatchEvents;
		}
		
		/**
		 * Make the remote function call.
		 */
		public function execute():void {
			remoteObject = new RemoteObject();
			
			// Set the gateway and service of the remote object
			remoteObject.channelSet = channelSet;
			remoteObject.destination = "amfphp";
			remoteObject.source = service;
			remoteObject.showBusyCursor = showBusyCursor;
			
			// Add listeners for results and faults
			remoteObject.addEventListener(ResultEvent.RESULT, onResult);
			remoteObject.addEventListener(FaultEvent.FAULT, onFault);
			
			// Make the remote function call
			var operation:AbstractOperation = remoteObject.getOperation(operationName);
			
			if (args) operation.arguments = args;
			
			if (disableAppOnCall) FlexGlobals.topLevelApplication.enabled = false;
			
			operation.send();
		}
		
		/**
		 * Remove event listeners and disconnect the remote object.  This should make the delegate eligable for garbage collection.
		 */
		private function closeRemoteObject():void {
			remoteObject.removeEventListener(ResultEvent.RESULT, onResult);
			remoteObject.removeEventListener(FaultEvent.FAULT, onFault);
			
			//remoteObject.disconnect();
			remoteObject = null;
			
			if (disableAppOnCall) FlexGlobals.topLevelApplication.enabled = true;
		}
		
		/**
		 * A result has been received so close the remote object and call the onDelegateResult method on the listener.
		 * 
		 * @param	event
		 */
		private function onResult(event:ResultEvent):void {
			closeRemoteObject();
			if (responder) responder.onDelegateResult(operationName, event.result);
			if (dispatchEvents) dispatchEvent(event);
		}
		
		/**
		 * A fault has been received so close the remote object and call the onDelegateFault method on the listener.
		 * 
		 * @param	event
		 */
		private function onFault(event:FaultEvent):void {
			closeRemoteObject();
			trace("RemoteDelegate:" + event.fault);
			if (responder) responder.onDelegateFault(operationName, event.fault);
			if (dispatchEvents) dispatchEvent(event);
		}
		
	}
	
}