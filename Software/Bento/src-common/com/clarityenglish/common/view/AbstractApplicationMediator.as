/*
 Mediator - PureMVC
 */
package com.clarityenglish.common.view {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BBStates;
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.interfaces.IBentoApplication;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.utilities.statemachine.State;
	import org.puremvc.as3.utilities.statemachine.StateMachine;
	
	/**
	 * A Mediator
	 */
	public class AbstractApplicationMediator extends Mediator implements IMediator {
	
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var networkCheckAvailabilityTimer:Timer;
		
		private var checkNetworkAvailabilityInterval:Number;
		private var checkNetworkAvailabilityReconnectInterval:Number;
		
		public function AbstractApplicationMediator(NAME:String, viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
			
			if (!(viewComponent is IBentoApplication))
				throw new Error("The main application must implement com.clarityenglish.bento.view.interfaces.IBentoApplication");
			
			if (!(viewComponent is BentoApplication))
				throw new Error("The main application must extend com.clarityenglish.bento.BentoApplication");
		}
		
		private function get view():IBentoApplication {
			return (viewComponent as IBentoApplication);
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			networkCheckAvailabilityTimer.reset();
			networkCheckAvailabilityTimer = null;
		}
		
		/**
		 * List all notifications this Mediator is interested in.
		 * <P>
		 * Automatically called by the framework when the mediator
		 * is registered with the view.</P>
		 * 
		 * @return Array the list of Nofitication names
		 */
		override public function listNotificationInterests():Array {
			return [
					CommonNotifications.TRACE_NOTICE,
					CommonNotifications.TRACE_WARNING,
					CommonNotifications.TRACE_ERROR,
					StateMachine.CHANGED,
					BBNotifications.NETWORK_AVAILABLE,
					BBNotifications.NETWORK_UNAVAILABLE,
					CommonNotifications.CONFIG_LOADED,
			];
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * <P>
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * (see <code>listNotificationInterests</code>.</P>
		 * 
		 * @param INotification a notification 
		 */
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				case CommonNotifications.TRACE_NOTICE:
					log.info(note.getBody().toString());
					break;
				case CommonNotifications.TRACE_WARNING:
					log.warn(note.getBody().toString());
					break;
				case CommonNotifications.TRACE_ERROR:
					log.error(note.getBody().toString());
					break;
				case StateMachine.CHANGED:
					handleStateChange(note.getBody() as State);
					break;
				case CommonNotifications.CONFIG_LOADED:
					// #472 - once config has loaded start the network availability time if there is one
					var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
					checkNetworkAvailabilityInterval = configProxy.getConfig().checkNetworkAvailabilityInterval;
					checkNetworkAvailabilityReconnectInterval = configProxy.getConfig().checkNetworkAvailabilityReconnectInterval;
					
					if (configProxy.getConfig().checkNetworkAvailabilityUrl && checkNetworkAvailabilityInterval > 0 && checkNetworkAvailabilityReconnectInterval > 0) {
						networkCheckAvailabilityTimer = new Timer(checkNetworkAvailabilityInterval * 1000);
						networkCheckAvailabilityTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
							sendNotification(BBNotifications.NETWORK_CHECK_AVAILABILITY);
						});
						networkCheckAvailabilityTimer.start();
					}
					break;
				case BBNotifications.NETWORK_AVAILABLE:
					if (networkCheckAvailabilityTimer)
						networkCheckAvailabilityTimer.delay = checkNetworkAvailabilityInterval * 1000;
					break;
				case BBNotifications.NETWORK_UNAVAILABLE:
					if (networkCheckAvailabilityTimer)
						networkCheckAvailabilityTimer.delay = checkNetworkAvailabilityReconnectInterval * 1000;
					break;
				default:
					break;		
			}
		}
		
		private function handleStateChange(state:State):void {
			switch (state.name) {
				case BBStates.STATE_LOGIN:
					if (!handleDirectLogin()) viewComponent.currentState = "login";
					break;
			}
		}
		
		private function handleDirectLogin():Boolean {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var directLogin:LoginEvent = configProxy.getDirectLogin();
			
			if (directLogin) {
				// If direct start login is on then log straight in without changing to the login state
				sendNotification(CommonNotifications.LOGIN, directLogin);
				
				return true;
			}
			
			return false;
		}
		
	}
}