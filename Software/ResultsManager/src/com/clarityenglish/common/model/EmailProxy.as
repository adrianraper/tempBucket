/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	//import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSON;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.email.TemplateDefinition;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import com.clarityenglish.common.vo.tests.TestDetail;
	import com.clarityenglish.dms.Constants;
	import com.clarityenglish.dms.DMSNotifications;
	import com.clarityenglish.dms.vo.account.Account;
	
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 * gh#1492 This was originally just for DMS, so it focusses on accounts as the 'receivers' of email
	 * But now use it in RM too, so manageables can also get email.
	 */
	public class EmailProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "EmailProxy";
		
		private var toAccounts:Array;
		
		private var templateDefinitions:Array;
		
		public function EmailProxy(data:Object = null) {
			super(NAME, data);
			
			clearToList();
		}
		
		public function getEmailTemplates():void {
			new RemoteDelegate("getEmailTemplates", null, this).execute();
		}
		
		/**
		 * Replace the 'to' list with the accounts in the array
		 * 
		 * @param	accounts
		 */
		public function setAccountsAsToList(accounts:Array):void {
			toAccounts = accounts;
			
			sendNotification(DMSNotifications.EMAIL_TO_LIST_CHANGED, toAccounts)
		}
		
		/**
		 * Add the accounts in the array to the 'to' list
		 * 
		 * @param	accounts
		 */
		public function addAccountsToToList(accounts:Array):void {
			for each (var account:Account in accounts)
				toAccounts.push(account);
			
			sendNotification(DMSNotifications.EMAIL_TO_LIST_CHANGED, toAccounts)
		}
		
		public function isAccountInToList(account:Account):Boolean {
			return toAccounts.indexOf(account) > -1;
		}
		
		/**
		 * Clear the 'to' list
		 */
		public function clearToList():void {
			toAccounts = null;
			toAccounts = new Array();
			
			sendNotification(DMSNotifications.EMAIL_TO_LIST_CHANGED, toAccounts)
		}
		
		// gh#1487
		public function previewGroupEmail(templateDefinition:TemplateDefinition, manageables:Array):void {
			var urlRequest:URLRequest = new URLRequest(Constants.AMFPHP_BASE + "services/GenerateGroupEmail.php");
			urlRequest.method = Constants.URL_REQUEST_METHOD;
			
			var postVariables:URLVariables = new URLVariables();
			postVariables.nocache = Math.floor(Math.random() * 999999);
			// Pass the whole template definition, which includes data as well as the filename
			postVariables.template = JSON.encode(templateDefinition);
			// TODO This makes assumptions that we are only passed an array of group ids.
			postVariables.groupIdArray = JSON.encode(manageables.map(
				function(manageable:Manageable, index:int, array:Array):Object { 
					return manageable.id; 
				} ));
			
			urlRequest.data = postVariables;
			navigateToURL(urlRequest, "_blank");
		}
		
		// TODO merge this into the above
		public function previewEmail(templateDefinition:TemplateDefinition):void {
			var urlRequest:URLRequest = new URLRequest(Constants.AMFPHP_BASE + "services/GenerateEmail.php");
			urlRequest.method = Constants.URL_REQUEST_METHOD;
			
			var postVariables:URLVariables = new URLVariables();
			postVariables.nocache = Math.floor(Math.random() * 999999);
			//postVariables.template = templateDefinition.title;
			postVariables.template = templateDefinition.filename;
			postVariables.emailArray = JSON.encode(toAccounts.map(
				function(account:Account, index:int, array:Array):Object { 
					// v3.6 You do NOT need to send 'to' as it should all be picked up from the account itself
					//return { to: account.email, data: { account_id: account.id } }; 
					return { data: { account_id: account.id } }; 
				} ));
					
			urlRequest.data = postVariables;
								
			navigateToURL(urlRequest, "_blank");
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getEmailTemplates":
					templateDefinitions = data as Array;
					sendNotification(DMSNotifications.EMAIL_TEMPLATES_LOADED, data);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, data);
		}
	}
}