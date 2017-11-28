package org.davekeen.delegates {

import com.clarityenglish.common.vo.config.Endpoint;
import com.clarityenglish.common.CommonNotifications;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.core.FlexGlobals;
import mx.messaging.ChannelSet;
import mx.messaging.channels.AMFChannel;
import mx.messaging.channels.SecureAMFChannel;
import mx.rpc.AbstractOperation;
import mx.rpc.AsyncToken;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

public class RemoteDelegate extends EventDispatcher implements IDelegate {
		
		private static var disableAppOnCall:Boolean = false;
		
		// PHP Error codes
		public static const E_ERROR:int = 1;
		public static const E_WARNING:int = 1;
		public static const E_NOTICE:int = 8;

        private static const waitForFaultsLimit:int = 10;

		private var responder:IDelegateResponder;
		private var operationName:String;
		private var args:Array;
		//private var remoteObjects:Array;
		private var dispatchEvents:Boolean;
		
		private static var showBusyCursor:Boolean = true;

        private static var endpoints:Array;
        private static var _params:Object;
		//private static var channelSet:ChannelSet;
		//private static var service:String;

        private var acceptFirstResult:Boolean;
        //private var waitForResult:Boolean;
        private var firstFault:Fault;
        private var faultTimer:Timer;

        public function RemoteDelegate(operationName:String = "", args:Array = null, responder:IDelegateResponder = null, dispatchEvents:Boolean = false, endpointAction:Object = null) {
			super();
			//trace("new RemoteDelegate for " + operationName);
			this.responder = responder;
			this.operationName = operationName;
			this.args = args;
			this.dispatchEvents = dispatchEvents;
            // gh#1561 How to choose an endpoint for this RemoteDelegate
            if (endpointAction) {
                this.acceptFirstResult = endpointAction.acceptFirstResult;
                //this.waitForResult = endpointAction.waitForResult;
            } else {
                //this.waitForResult = this.acceptFirstResult = false;
            }
            faultTimer = null;
		}
		
		public static function setShowBusyCursor(value:Boolean):void {
			showBusyCursor = value;
		}

		// gh#1561 Hold a list of endpoints that will be touched by all remote delegates
        public static function addEndpoint(endpoint:Endpoint):void {
            //trace("add endpoint " + endpoint.name);
            if (endpoints == null)
                endpoints = new Array();
            endpoints.push(endpoint);

        }

        private function selectEndpoint(selectedEndpoint:Endpoint):void {
            // Only call this once
            if (selectedEndpoint.selected) return;

            //trace("select endpoint " + selectedEndpoint.name);
            for each (var endpoint:Endpoint in endpoints) {
                if (endpoint.name == selectedEndpoint.name) {
                    endpoint.selected = true;
                    // Add any configuration options in the endpoint into our common config

                } else {
                    endpoint.rejected = true;
                }
            }
            // gh#1561 This is an EXTRA call to onDelegateResult. It would have been cleaner
            // to have done a sendNotification, then used a command to trigger ConfigProxy to add in the
            // specific config held in this endpoint.
            if (responder) responder.onDelegateResult('selectedEndpoint', selectedEndpoint);
        }
        private function rejectEndpoint(rejectedEndpoint:Endpoint):void {
            //trace("reject endpoint " + rejectedEndpoint.name);
            for each (var endpoint:Endpoint in endpoints) {
                if (endpoint.name == rejectedEndpoint.name) {
                    endpoint.rejected = true;
                }
            }
        }
        public static function setGatewayParams(params:Object):void {
            _params = params;
        }
		/**
		 * Statically set the gateway for the delegate.  For AMFPHP this will be the absolute URL of a gateway.php file.  There is an option getParams
		 * object argument, which list permanent get parameters that will be added to the url.  Typically this would be used for a sessionid.
		 * 
		 * @param	url
		 */
        /*
		public static function setGateway(url:String, getParams:Object = null):void {
			if (getParams) {
				var getArray:Array = [];
				for (var key:String in getParams)
					getArray.push(key + "=" + getParams[key]);
				
				url += "?" + encodeURI(getArray.join("&"));
			}
			
			channelSet = new ChannelSet();
            // gh#1331 For when we are talking to https for ios clearance
            if (url.indexOf('https') == 0) {
                var secureAmfChannel:SecureAMFChannel = new SecureAMFChannel("amfphp", url);
                channelSet.addChannel(amfChannel);
            } else {
                var amfChannel:AMFChannel = new AMFChannel("amfphp", url);
                channelSet.addChannel(amfChannel);
            }
		}
		 */

		/**
		 * Staticaly set the service (remote class) that this delegate will be calling methods on.
		 * 
		 * @param	service
		 */
        /*
		public static function setService(s:String):void {
			service = s;
		}
		*/
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
         * gh#1561 This will run for each endpoint, unless any are selected or some are rejected
		 */
		public function execute():AsyncToken {
            //trace("execute RemoteDelegate");
            //remoteObjects = [];
            // If any of the endpoints are selected, just use that one
            for each (var endpoint:Endpoint in endpoints) {
                if (endpoint.selected)
                    return executeEndpoint(endpoint);
            }
            // Otherwise use any that are not rejected
            var t:AsyncToken;
            for each (endpoint in endpoints) {
                if (!endpoint.rejected)
                    t = executeEndpoint(endpoint);
            }
            return t;
        }

        public function executeEndpoint(endpoint:Endpoint):AsyncToken {
            //trace("executeEndpoint " + endpoint.name + " on " + endpoint.remoteGateway + " for " + operationName);
            endpoint.waitForResult = true;

            var remoteObject = new RemoteObject();
            var url:String = endpoint.remoteGateway + "gateway.php";
            if (_params) {
                var getArray:Array = [];
                for (var key:String in _params)
                    getArray.push(key + "=" + _params[key]);

                url += "?" + encodeURI(getArray.join("&"));
            }

            var channelSet:ChannelSet = new ChannelSet();
            // gh#1331 For when we are talking to https for ios clearance
            if (url.indexOf('https') == 0) {
                var secureAmfChannel:SecureAMFChannel = new SecureAMFChannel("amfphp", url);
                channelSet.addChannel(secureAmfChannel);
            } else {
                var amfChannel:AMFChannel = new AMFChannel("amfphp", url);
                channelSet.addChannel(amfChannel);
            }

            // Set the gateway and service of the remote object
            remoteObject.channelSet = channelSet;
            remoteObject.destination = "amfphp";
            remoteObject.source = endpoint.remoteService;
            remoteObject.showBusyCursor = showBusyCursor;

            endpoint.remoteObject = remoteObject;

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
		 * Remove event listeners and disconnect the remote object. This should make the delegate eligible for garbage collection.
		 */
        public function closeRemoteObject(remoteObject:Object):void {
            if (remoteObject) {
                remoteObject.removeEventListener(ResultEvent.RESULT, onResult);
                remoteObject.removeEventListener(FaultEvent.FAULT, onFault);

                //remoteObject.disconnect();
                //remoteObject = null;
            }
			if (disableAppOnCall) FlexGlobals.topLevelApplication.enabled = true;
		}
		
		/**
		 * A result has been received so close the remote object and call the onDelegateResult method on the listener.
		 * 
		 * @param	event
		 */
		private function onResult(event:ResultEvent):void {
            // Need to figure out which endpoint this event came from
            var thisRemoteObject:RemoteObject = event.currentTarget as RemoteObject;
            for (var i:int=0; i<endpoints.length; i++) {
                if (endpoints[i].remoteObject === thisRemoteObject)
                    var thisIdx:int = i;
                closeRemoteObject(endpoints[i].remoteObject);
                endpoints[i].waitForResult = false;
            }
            trace("onResult for endpoint " + endpoints[thisIdx].name + " in "  + operationName);

            // gh#1561 Does success indicate that we select this endpoint permanently?
            // Only ever need to do this once
            if (acceptFirstResult && endpoints[thisIdx].selected == false)
                selectEndpoint(endpoints[thisIdx]);

            // Tidy up anything waiting for other results
            if (faultTimer) {
                faultTimer.stop();
                faultTimer.removeEventListener(TimerEvent.TIMER, waitForFaults);
                faultTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, waitNoMore);
                faultTimer = null;
            }

			if (responder) responder.onDelegateResult(operationName, event.result);
			if (dispatchEvents) dispatchEvent(event);
		}
		
		/**
		 * A fault has been received so close the remote object and call the onDelegateFault method on the listener.
		 * 
		 * @param	event
		 */
		private function onFault(event:FaultEvent):void {
            var thisRemoteObject:RemoteObject = event.currentTarget as RemoteObject;
            for (var i:int=0; i<endpoints.length; i++) {
                if (endpoints[i].remoteObject === thisRemoteObject)
                    var thisIdx:int = i;
            }
            trace("onFault for endpoint " + endpoints[thisIdx].name + " in "  + operationName);
            closeRemoteObject(thisRemoteObject);
            endpoints[thisIdx].waitForResult = false;

            // gh#1561 Does failure indicate that we reject this endpoint?
            // Some faults are expected - we send an Exception to indicate a wrong password for instance
            // And you can't assume that almost success (wrong password) means you know which endpoint, as it is just about
            // possible that you got the email wrong and a different endpoint has the correct one...
            // Whilst a server error or a timeout indicates we never want this endpoint, it might be easier just to wait for a positive outcome

            // gh#1561 We want to wait for all endpoints to come back in case one of them has a result.
            // If none of them does, just use the first fault.
            firstFault = event.fault;

            // As soon as you get one fault back, start checking to see if they are all back every second
            // You could put a time limit on this (30 seconds?)
            // Set new TimerEvent on waitForResults()
            if (!faultTimer) {
                faultTimer = new Timer(1 * 1000, waitForFaultsLimit);
                faultTimer.addEventListener(TimerEvent.TIMER, waitForFaults);
                faultTimer.addEventListener(TimerEvent.TIMER_COMPLETE, waitNoMore);
                faultTimer.start();
            }

        }
        // We have waited long enough for endpoints to respond, go ahead with whatever we have
        private function waitNoMore(event:TimerEvent):void {
            trace("stop waiting for endpoints to respond");
            for each (var endpoint:Endpoint in endpoints)
                closeRemoteObject(endpoint.remoteObject);

            if (faultTimer) {
                faultTimer.stop();
                faultTimer.removeEventListener(TimerEvent.TIMER, waitForFaults);
                faultTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, waitNoMore);
                faultTimer = null;
            }
            if (responder) responder.onDelegateFault(operationName, firstFault);

        }
        // Are there any endpoints still waiting for a response?
        private function waitForFaults(event:TimerEvent):void {
            trace("check for outstanding calls for " + operationName);
            // Is there anything in the remoteObjects collection that is not nullifed?
            for each (var endpoint:Endpoint in endpoints) {
                if (endpoint.waitForResult) {
                    return;
                }
            }
            //trace("all endpoints responded, so keep going");
            if (faultTimer) {
                faultTimer.stop();
                faultTimer.removeEventListener(TimerEvent.TIMER, waitForFaults);
                faultTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, waitNoMore);
                faultTimer = null;
            }
            if (responder) responder.onDelegateFault(operationName, firstFault);
            // gh#1561 This seems to never be used, but very naughty to just comment it out here
            //if (dispatchEvents) dispatchEvent(event);

        }
		
	}
	
}