/*
 Mediator - PureMVC
 */
package com.clarityenglish.resultsmanager.view.loginopts {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.resultsmanager.model.LoginOptsProxy;
	import com.clarityenglish.resultsmanager.view.loginopts.events.LoginOptEvent;
	import com.clarityenglish.resultsmanager.model.EmailOptsProxy;
	import com.clarityenglish.resultsmanager.view.loginopts.events.EmailOptEvent;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.clarityenglish.resultsmanager.view.loginopts.components.*;
	import com.clarityenglish.resultsmanager.view.loginopts.*;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.utils.TraceUtils;
	
	/**
	 * A Mediator
	 */
	public class LoginOptsMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "LoginOptsMediator";
		
		public function LoginOptsMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			loginOptsView.addEventListener(LoginOptEvent.UPDATE, onUpdate);
			loginOptsView.addEventListener(LoginOptEvent.REVERT, onRevert);
			loginOptsView.addEventListener(EmailOptEvent.UPDATE, onEmailUpdate);
			loginOptsView.addEventListener(EmailOptEvent.REVERT, onEmailRevert);
		}
		
		private function get loginOptsView():LoginOptsView {
			return viewComponent as LoginOptsView;
		}

		/**
		 * Get the Mediator name.
		 * <P>
		 * Called by the framework to get the name of this
		 * mediator. If there is only one instance, we may
		 * define it in a constant and return it here. If
		 * there are multiple instances, this method must
		 * return the unique name of this instance.</P>
		 * 
		 * @return String the Mediator name
		 */
		override public function getMediatorName():String {
			return LoginOptsMediator.NAME;
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
					RMNotifications.LOGINOPTS_LOADED,
					RMNotifications.EMAILOPTS_LOADED,
					CommonNotifications.COPY_LOADED,
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
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					loginOptsView.setCopyProvider(copyProvider);
					break;
				case RMNotifications.LOGINOPTS_LOADED:
					var loginOptsProxy:LoginOptsProxy = facade.retrieveProxy(LoginOptsProxy.NAME) as LoginOptsProxy;
					
					// Set the options from the proxy
					loginOptsView.loginTypeOption.selectedValue = loginOptsProxy.getLoginTypeLoginOpt();
					// v3.1 See loginOptsView.mxml for why this is commented
					//loginOptsView.anonLoginOption.selectedValue = loginOptsProxy.isAnonLoginAllowed();
					loginOptsView.passwordRequiredOption.selectedValue = loginOptsProxy.isPasswordRequired();
					loginOptsView.unregisteredLearnersOption.selectedValue = loginOptsProxy.canUnregisteredUsersLogin();
					
					loginOptsView.srName.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_NAME);
					loginOptsView.srStudentID.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_STUDENTID);
					loginOptsView.srEmail.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_EMAIL);
					loginOptsView.srPassword.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_PASSWORD);
					/*
					loginOptsView.srBirthday.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_BIRTHDAY);
					loginOptsView.srCountry.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_COUNTRY);
					loginOptsView.srCompany.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_COMPANY);
					loginOptsView.srCustom1.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_CUSTOM1);
					loginOptsView.srCustom2.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_CUSTOM2);
					loginOptsView.srCustom3.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_CUSTOM3);
					loginOptsView.srCustom4.selected = loginOptsProxy.isSelfRegisterOptionSet(LoginOptsProxy.SR_CUSTOM4);
					*/
					// v3.6 Here we can hide the access control completely if we need to
					if (Constants.licenceType == Title.LICENCE_TYPE_LT ||
						Constants.licenceType == Title.LICENCE_TYPE_CT ||
						Constants.licenceType == Title.LICENCE_TYPE_NETWORK ||
						Constants.licenceType == Title.LICENCE_TYPE_TT) {
						loginOptsView.accessControlPanel.visible = true;
						loginOptsView.accessControlPanel.includeInLayout = true;
					}
					
					break;
				case RMNotifications.EMAILOPTS_LOADED:
					var emailOptsProxy:EmailOptsProxy = facade.retrieveProxy(EmailOptsProxy.NAME) as EmailOptsProxy;
					
					// Set the options from the proxy
					// Loop through all emails received
					//// TraceUtils.myTrace("loginOptsMediator.EMAILOPTS_LOADED");
					var emailCount:uint = emailOptsProxy.getEmailCount();
					for (var i:uint = 0; i < emailCount; i++) {
						loginOptsView['email' + Number(i+1) + 'Address'].text = emailOptsProxy.getEmail(i);
						loginOptsView['email' + Number(i+1) + 'Type1'].selected = emailOptsProxy.getSubscriptionReminders(i);
						loginOptsView['email' + Number(i+1) + 'Type2'].selected = emailOptsProxy.getUsageStatistics(i);
						loginOptsView['email' + Number(i+1) + 'Type3'].selected = emailOptsProxy.getServiceNotices(i);
						loginOptsView['email' + Number(i+1) + 'Type4'].selected = emailOptsProxy.getSupportNotices(i);
						loginOptsView['email' + Number(i+1) + 'Type5'].selected = emailOptsProxy.getUpgradeInformation(i);
						loginOptsView['email' + Number(i+1) + 'Type6'].selected = emailOptsProxy.getProductInformation(i);
					}
					// Clear out the rest
					for (i=emailCount; i < 5; i++) {
						loginOptsView['email' + Number(i + 1) + 'Address'].text = '';
						loginOptsView['email' + Number(i + 1) + 'Type1'].selected = false;
						loginOptsView['email' + Number(i+1) + 'Type2'].selected = false;
						loginOptsView['email' + Number(i+1) + 'Type3'].selected = false;
						loginOptsView['email' + Number(i+1) + 'Type4'].selected = false;
						loginOptsView['email' + Number(i+1) + 'Type5'].selected = false;
						loginOptsView['email' + Number(i+1) + 'Type6'].selected = false;
					}
				default:
					break;
			}
		}
		
		private function onUpdate(e:LoginOptEvent):void {
			var loginOpts:Object = new Object();
			loginOpts.loginTypeOption = loginOptsView.loginTypeOption.selectedValue;
			// v3.1 See loginOptsView.mxml for why this is commented
			//loginOpts.anonLoginOption = loginOptsView.anonLoginOption.selectedValue;
			loginOpts.passwordRequiredOption = loginOptsView.passwordRequiredOption.selectedValue;
			loginOpts.unregisteredLearnersOption = loginOptsView.unregisteredLearnersOption.selectedValue;
			loginOpts.selfRegisterArray = loginOptsView.selfRegisterSelectedItems;
			
			sendNotification(RMNotifications.UPDATE_LOGIN_OPTS, loginOpts);
		}
		
		private function onRevert(e:LoginOptEvent):void {
			var loginOptsProxy:LoginOptsProxy = facade.retrieveProxy(LoginOptsProxy.NAME) as LoginOptsProxy;
			loginOptsProxy.getLoginOpts();
		}

		private function onEmailUpdate(e:EmailOptEvent):void {
			// Get the data from the view, format it in the proxy and save
			var emailOptionsArray:Array = new Array();
			// TODO: We shouldn't just fix this at 5 items, can we count rows in the grid?
			for (var i:uint = 1; i <= 5; i++) {
				var thisEmailItem:Object = new Object();
				thisEmailItem.email = loginOptsView['email' + i + 'Address'].text;
				thisEmailItem.messageType = ((loginOptsView['email' + i + 'Type1'].selected) ? EmailOptsProxy.SUBSCRIPTION_REMINDERS : 0)
									+ ((loginOptsView['email' + i + 'Type2'].selected) ? EmailOptsProxy.USAGE_STATISTICS : 0)
									+ ((loginOptsView['email' + i + 'Type3'].selected) ? EmailOptsProxy.SERVICE_NOTICES : 0)
									+ ((loginOptsView['email' + i + 'Type4'].selected) ? EmailOptsProxy.SUPPORT_NOTICES : 0)
									+ ((loginOptsView['email' + i + 'Type5'].selected) ? EmailOptsProxy.UPGRADE_INFORMATION : 0)
									+ ((loginOptsView['email' + i + 'Type6'].selected) ? EmailOptsProxy.PRODUCT_INFORMATION : 0);
				//// TraceUtils.myTrace('mediator.onEmailUpdate index=' + i + ' email=' + thisEmailItem.email + ' messageType=' + thisEmailItem.messageType);
				//if (thisEmailItem.email!='')
				if (thisEmailItem.email) {
					emailOptionsArray.push(thisEmailItem);
					//// TraceUtils.myTrace("keep this item then");
				} else {
					//// TraceUtils.myTrace("ignore this empty item");
				}
			}			
			sendNotification(RMNotifications.UPDATE_EMAIL_OPTS, emailOptionsArray);
		}
		
		private function onEmailRevert(e:EmailOptEvent):void {
			var emailOptsProxy:EmailOptsProxy = facade.retrieveProxy(EmailOptsProxy.NAME) as EmailOptsProxy;
			emailOptsProxy.getEmailOpts();
		}

	}
}
