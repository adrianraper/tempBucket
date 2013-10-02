package com.clarityenglish.dms.vo.account {
	import com.clarityenglish.common.vo.Reportable;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	
	/**
	* ...
	* @author ...
	*/
	[RemoteClass(alias = "com.clarityenglish.dms.vo.account.Account")]
	[Bindable]
	public class Account extends Reportable {
		
		public var name:String;
		public var prefix:String;
		// v3.6 Drop AccountRoot F_Email
		//public var email:String;
		public var tacStatus:Number;
		public var accountStatus:Number;
		// v3.0.5 Change status handling
		//public var approvalStatus:Number;
		public var accountType:Number;
		public var customerType:Number;
		public var invoiceNumber:String;
		public var resellerCode:Number;
				
		public var reference:String;
		public var logo:String;
		// v3.0.6 Self-hosting
		public var selfHost:Boolean;
		// v3.0.6 LoginOption, used for CE.com/shared portal
		public var loginOption:Number;
		// v3.3 Security for self hosting
		public var selfHostDomain:String;
		// v3.5 Flexibility of email system
		public var optOutEmails:Boolean;
		public var optOutEmailDate:String;
		// v4.0 Integration with Bento
		public var verified:Number;
		public var selfRegister:Number;
		public var languageCode:String;
		
		public var adminUser:User;
		
		public var titles:Array;
		
		public var licenceAttributes:Array;
		
		// gh#659
		public var productCodes:Array;
		
		public function Account() {
			
		}
		
		public static function createDefault():Account {
			var account:Account = new Account();
			account.titles = new Array();
			account.adminUser = User.createDefault();
			account.adminUser.userType = User.USER_TYPE_ADMINISTRATOR;
			// v3.0.6 Is there anything else you want to default in a new account?
			account.accountType = 1; // Standard invoice
			account.accountStatus = 0; // Account created
			account.tacStatus = 0; // Display
			//account.loginOption = 1;
			account.optOutEmails = false;
			// v3.4.2 I want to include RM by default - can I do that here?
			var defaultRM:Title = Title.createDefault(2);
			account.titles.push(defaultRM);
			return account;
		}
	
		/*
		 Take this out now as we don't want facade and proxy
		*/
		/*
		public function isInEmailToList():Boolean {
			// We shouldn't really be retrieving proxies from value objects, but the alternatives are much messier and we know
			// we are doing it for a good reason :)
			var emailProxy:EmailProxy = ApplicationFacade.getInstance().retrieveProxy(EmailProxy.NAME) as EmailProxy;
			return emailProxy.isAccountInToList(this);
		}
		*/
		/**
		 * Implementing a children field allows us to use this class directly as a dataprovider to a tree
		 */
		override public function get children():Array {
			return titles;
		}
		
		override public function set children(children:Array):void {
			titles = children;
		}
		
		/**
		 * Convenience method to get a title in an account
		 * @param productCode - optional product code that finds the matching title. If not set, simply get the first (and presumably only) title
		 * @return Title 
		 * 
		 */
		public function getTitle(productCode:uint=0):Title {
			// Send back first title if no productCode set
			if (productCode==0)
				return this.titles[0];
			
			// Try to find the matching title
			for each (var title:Title in this.titles) {
				if (title.id == productCode.toString()) {
					return title;
				}
			}
			return null;
		}
		/**
		 * By linking the uid (used by Flex dataProviders) to a unique key based on the type and database id we can ensure
		 * that Flex components still know which object is which even when performing a complete refresh from the backend.
		 */
		override public function get uid():String{
			return "account" + this.id;
		}
		
		override public function set uid(value:String):void { }
		
	}
	
}