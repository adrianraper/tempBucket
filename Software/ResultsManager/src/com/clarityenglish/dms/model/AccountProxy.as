/*
Proxy - PureMVC
*/
package com.clarityenglish.dms.model {
	import com.adobe.serialization.json.JSON;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.dms.Constants;
	import com.clarityenglish.dms.DMSNotifications;
	import com.clarityenglish.dms.vo.account.Account;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	//import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * A proxy
	 */
	public class AccountProxy extends Proxy implements IProxy, IDelegateResponder {
		
		public static const NAME:String = "AccountProxy";
		
		private var accounts:Array;
		
		private var reportTemplateDefinitions:Array;
		
		// v3.0.6 Account type has to be a class variable
		private var showIndividualAccounts:Boolean;
		// gh#911
		private var showArchivedAccounts:Boolean;
		
		public function AccountProxy(data:Object = null) {
			super(NAME, data);
			
			// v3.0.6 Since you might not be resetting, pick up any account parameters from the screen
			// Or rather, change them back to the default.
			sendNotification(DMSNotifications.ACCOUNTS_RESET);
			getAccounts();
			getReportTemplates();
		}
		
		public function getReportTemplates():void {
			new RemoteDelegate("getReportTemplates", [], this).execute();
		}
		
		// v3.0.6 Always pick up the accounts type from our own variable now
		public function getAccounts():void {
			if (Constants.filterString) {
				new RemoteDelegate("getAccounts", [ [ ], { individuals:showIndividualAccounts, archived:showArchivedAccounts, accountName:Constants.filterString } ], this).execute();
			} else {
				new RemoteDelegate("getAccounts", [ [ ], { individuals:showIndividualAccounts, archived:showArchivedAccounts } ], this).execute();
			}
		}

		// v3.0.6 Always pick up the accounts type from our own variable now
		// gh#911
		public function changeAccountType(individualAccounts:Boolean = false, archivedAccounts:Boolean = false):void {
			showIndividualAccounts = individualAccounts;
			showArchivedAccounts = archivedAccounts;
			getAccounts();
		}
		
		public function addAccount(account:Account):void {
			new RemoteDelegate("addAccount", [ account ], this).execute();
		}
		
		public function updateAccounts(accounts:Array):void {
			new RemoteDelegate("updateAccounts", [ accounts ], this).execute();
		}
		
		public function deleteAccounts(accounts:Array):void {
			new RemoteDelegate("deleteAccounts", [ accounts ], this).execute();
		}

		// gh#911
		public function archiveAccounts(accounts:Array):void {
			for each (var account:Account in accounts)
 				account.accountStatus = 11;
			new RemoteDelegate("updateAccounts", [ accounts ], this).execute();
		}
		
		public function getAccountDetails(accountID:String):void {
			//MonsterDebugger.trace(this, accountID);
			new RemoteDelegate("getAccountDetails", [ accountID ], this).execute();
		}
		
		public function generateReport(accounts:Array, reportTemplate:String):void {
			var urlRequest:URLRequest = new URLRequest(Constants.AMFPHP_BASE + "services/GenerateDMSReport.php");
			urlRequest.method = Constants.URL_REQUEST_METHOD;
			
			var postVariables:URLVariables = new URLVariables();
			postVariables.nocache = Math.floor(Math.random() * 999999);
			postVariables.template = reportTemplate;
			postVariables.accountIDArray = JSON.encode(accounts.map(
				function(account:Account, index:int, array:Array):Object { 
					return account.id; 
				} ));
					
			urlRequest.data = postVariables;
								
			navigateToURL(urlRequest, "_blank");
		}
		
		/**
		 * Open this account in Results Manager by using Constants.RESULTS_MANAGER_URL and passing the username and password of the account
		 * admin user as request parameters.
		 * 
		 * @param	account
		 */
		public function showInResultsManager(account:Account):void {
			var urlRequest:URLRequest = new URLRequest(Constants.HOST + "../../../area1/" + Constants.RESULTS_MANAGER_URL);
			urlRequest.method = URLRequestMethod.GET;
			
			var postVariables:URLVariables = new URLVariables();
			postVariables.username = account.adminUser.name;
			postVariables.password = account.adminUser.password;
			
			urlRequest.data = postVariables;
			navigateToURL(urlRequest, "_blank");			
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getAccounts":
					//MonsterDebugger.trace(this, "back from getAccounts");
					accounts = data as Array;
					sendNotification(DMSNotifications.ACCOUNTS_LOADED, accounts);
					break;
				case "getAccountDetails":
					//MonsterDebugger.trace(this, "back from getAccountDetails" );
					//MonsterDebugger.trace(this, data as Array );
					sendNotification(DMSNotifications.ACCOUNT_DETAILS_LOADED, data as Array);
					break;
				case "addAccount":
				case "updateAccounts":
				case "deleteAccounts":
					//MonsterDebugger.trace(this, operation);
					getAccounts();
					break;
				case "getReportTemplates":
					reportTemplateDefinitions = data as Array;
					sendNotification(DMSNotifications.REPORT_TEMPLATES_LOADED, reportTemplateDefinitions);
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, data);
			
			switch (operation) {
				case "addAccounts":
				case "updateAccounts":
					break;
				default:
			}
		}
		
	}
}