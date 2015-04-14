/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import com.clarityenglish.utils.TraceUtils;

	/**
	 * A proxy
	 */
	public class EmailOptsProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "EmailOptsProxy";
		
		private var emailOptionArray:Array;
		
		public static const SUBSCRIPTION_REMINDERS:int = 1;
		public static const USAGE_STATISTICS:int = 2;
		public static const SERVICE_NOTICES:int = 4;
		public static const SUPPORT_NOTICES:int = 8;
		public static const UPGRADE_INFORMATION:int = 16;
		public static const PRODUCT_INFORMATION:int = 32;

		public function EmailOptsProxy(data:Object = null) {
			super(NAME, data);
			
			getEmailOpts();
		}
		
		public function getEmailOpts():void {
			//// TraceUtils.myTrace("proxy.getEmailOpts");
			new RemoteDelegate("getEmailOpts", [], this).execute();
		}
		public function saveEmailOpts():void {
			//// TraceUtils.myTrace("proxy.saveEmailOpts " + emailOptionArray.toString());
			new RemoteDelegate("setEmailOpts", [ emailOptionArray ], this).execute();
		}
		
		// Public functions to get and set the data
		public function getEmailCount():uint {
			//// TraceUtils.myTrace("getEmailCount=" + emailOptionArray.length);
			return emailOptionArray.length;
		}
		public function getEmail(index:uint):String {
			//// TraceUtils.myTrace("proxy.getEmail for email(" +index+ ")=" + emailOptionArray[index].email);
			return emailOptionArray[index].email;
		}
		public function setEmailItem(index:uint, email:String, messageType:uint):void {
			//// TraceUtils.myTrace("proxy.setEmailItem for email(" +index + ")=" + email);
			if (index >= emailOptionArray.length) {
				emailOptionArray.push({ email:email, messageType:messageType });
			} else {
				emailOptionArray[index].email = email;
				emailOptionArray[index].messageType = messageType;
			}
		}
		public function clearEmailItems():void {
			emailOptionArray = new Array();
		}

		public function getSubscriptionReminders(index:uint):Boolean {
			var flagOn:Boolean = (emailOptionArray[index].messageType & SUBSCRIPTION_REMINDERS) == SUBSCRIPTION_REMINDERS;
			//// TraceUtils.myTrace("proxy.getSubscriptionReminders for email("+index+")=" + flagOn);
			return flagOn;
		}
		public function getUsageStatistics(index:uint):Boolean {
			var flagOn:Boolean = (emailOptionArray[index].messageType & USAGE_STATISTICS) ==USAGE_STATISTICS;
			//// TraceUtils.myTrace("proxy.getUsageStatistics for email("+index+")=" + flagOn);
			return flagOn;
		}
		public function getServiceNotices(index:uint):Boolean {
			var flagOn:Boolean = (emailOptionArray[index].messageType & SERVICE_NOTICES) == SERVICE_NOTICES;
			//// TraceUtils.myTrace("proxy.getServiceNoties for email("+index+")=" + flagOn);
			return flagOn;
		}
		public function getSupportNotices(index:uint):Boolean {
			var flagOn:Boolean = (emailOptionArray[index].messageType & SUPPORT_NOTICES) == SUPPORT_NOTICES;
			//// TraceUtils.myTrace("proxy.getSupportNotices for email("+index+")=" + flagOn);
			return flagOn;
		}
		public function getUpgradeInformation(index:uint):Boolean {
			var flagOn:Boolean = (emailOptionArray[index].messageType & UPGRADE_INFORMATION) == UPGRADE_INFORMATION;
			//// TraceUtils.myTrace("proxy.getUpgradeInformation for email("+index+")=" + flagOn);
			return flagOn;
		}
		public function getProductInformation(index:uint):Boolean {
			var flagOn:Boolean = (emailOptionArray[index].messageType & PRODUCT_INFORMATION) == PRODUCT_INFORMATION;
			//// TraceUtils.myTrace("proxy.getProductInformation for email("+index+")=" + flagOn);
			return flagOn;
		}

		/*
		public function setSubscriptionReminders(index:uint, value:Boolean):void {
			// TraceUtils.myTrace("proxy.setSubscriptionReminders for email(" + index + ")=" + value);
			if (value) {
				emailOptionArray[index].messageType |= SUBSCRIPTION_REMINDERS;
			} else {
				emailOptionArray[index].messageType &= ~SUBSCRIPTION_REMINDERS;
			}
		}
		*/
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getEmailOpts":
					emailOptionArray = data as Array;
					//// TraceUtils.myTrace("got email[0] as " + emailOptionArray[0].messageType);
					sendNotification(RMNotifications.EMAILOPTS_LOADED, emailOptionArray);
					break;
				case "setEmailOpts":
					getEmailOpts();
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);

			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void {
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
			
			switch (operation) {
				case "setEmailOpts":
					break;
				case "getEmailOpts":
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Fault from unknown operation: " + operation);
			}
		}
		
	}
}