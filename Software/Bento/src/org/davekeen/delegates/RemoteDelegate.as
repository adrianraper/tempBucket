package org.davekeen.delegates {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.utils.Timer;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
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
		
		// gh#793
		private static const RETRY_LIMIT:int = 4;
		private var retryCounter:int = 0;
		private var retryInitialTime:int = 2;
		public static const CHANNEL_CALL_FAILED:String = "Channel.Call.Failed";
		public static const CLIENT_ERROR_SEND:String = "Client.Error.MessageSend";
		public static const HTTP_Status_500:String = "HTTP: Status 500";
		public static const HTTP_Status_501:String = "HTTP: Status 501";
		public static const HTTP_Status_5xx:String = "HTTP: Status 5";
		public static const SERVER_CONNECTION_ERROR:int = 504;
		public static const SERVER_ERROR:int = 505;
		
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
		 * Statically set the gateway for the delegate.  For AMFPHP this will be the absolute URL of a gateway.php file.  There is an option getParams
		 * object argument, which list permanent get parameters that will be added to the url.  Typically this would be used for a sessionid.
		 * 
		 * @param	url
		 */
		public static function setGateway(url:String, getParams:Object = null):void {
			if (getParams) {
				var getArray:Array = [];
				for (var key:String in getParams)
					getArray.push(key + "=" + getParams[key]);
				
				url += "?" + encodeURI(getArray.join("&"));
			}
			
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
		public function execute():AsyncToken {
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
			
			return operation.send();
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
			//trace("RemoteDelegate:" + event.fault);
			
			// gh#793
			// Not sure why the retry has a different faultCode...
			var proxyFault:Fault = event.fault;
			// I don't think there is any value in filtering the faultCode
			//if (event.fault.faultCode == CHANNEL_CALL_FAILED || event.fault.faultCode == CLIENT_ERROR_SEND ) {
				if ((event.fault.faultDetail.indexOf(HTTP_Status_500) > 0) ||
					(event.fault.faultDetail.indexOf(HTTP_Status_501) > 0)) {
					proxyFault = new Fault(String(SERVER_ERROR), event.fault.faultString, event.fault.faultDetail); ;
					
				} else if (event.fault.faultDetail.indexOf(HTTP_Status_5xx) > 0) {
					if (this.retryCounter++ < RETRY_LIMIT) {
						var retryTimer:Timer = new Timer(Math.round(Math.random() * 50) + (1000 * Math.pow(this.retryInitialTime, retryCounter)), 1);
						retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, execute);
						retryTimer.start();
						return;
					} else {
						// override the faultCode so you can easily catch all kinds of errors in the remote delegate fault handler
						proxyFault = new Fault(String(SERVER_CONNECTION_ERROR), event.fault.faultString, event.fault.faultDetail); ;
					}
				}
				
			//}
			if (responder) responder.onDelegateFault(operationName, proxyFault);
			if (dispatchEvents) dispatchEvent(event);
		}
		
	}
	
}