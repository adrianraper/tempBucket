﻿package com.clarityenglish.ielts.view.account {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.dms.vo.account.Account;
	import com.clarityenglish.dms.vo.account.Licence;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class AccountMediator extends BentoMediator implements IMediator {
		
		public function AccountMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():AccountView {
			return viewComponent as AccountView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// listen for this signal
			view.updateUser.add(onUpdateUser);
			view.register.add(onInfoRequested);
			//view.languageChange.add(onLanguageChange);
			
			// Inject some data to the screen.
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;

			// Inject required data into the view
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.productVersion = configProxy.getProductVersion();
			view.productCode = configProxy.getProductCode();
			view.licenceType = configProxy.getLicenceType();

			view.isPlatformiPad = configProxy.isPlatformiPad();

			// The start and end date depend on the type of account, and whether you expire or not
			// Start date is either account start date, or user registration date whichever is later
			// Expiry date is either account end date, or user expiry date whichever is earlier
			var licence:Licence = configProxy.getLicence();
			// gh#38
			//if (loginProxy.user.registrationDate && loginProxy.user.registrationDate > licence.licenceStartDate) {
			if (loginProxy.user.registrationDate) {
				view.startDate = loginProxy.user.registrationDate;
			} else {
				// gh#38
				//view.startDate = licence.licenceStartDate;
				view.startDate = null;
			}
			// gh#38 Show the user's expiry date if they have one, even if past the licence expiry date
			//if (loginProxy.user.expiryDate && loginProxy.user.expiryDate < licence.expiryDate) {
			if (loginProxy.user.expiryDate) {
				view.expiryDate = loginProxy.user.expiryDate;
			} else {
				view.expiryDate = licence.expiryDate;
			}
			
			view.isDirty = false;
		}
		
		
		public override function onRemove():void {
			super.onRemove();
			
			//view.updateUser.remove(onUpdateUser);
			view.register.remove(onInfoRequested);
			//view.languageChange.remove(onLanguageChange);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				CommonNotifications.UPDATE_FAILED,
				BBNotifications.USER_UPDATED,
				//BBNotifications.LANGUAGE_CHANGED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
//				case CommonNotifications.UPDATE_FAILED:
//					view.showUpdateError();
//					break;
				case BBNotifications.USER_UPDATED:
					//view.showUpdateSuccess();
					//view.isDirty = false;
					view.updateCountDownLabel();
					break;
//				case BBNotifications.LANGUAGE_CHANGED:
//					view.reloadCopy(); // gh#72
//					break;
			}
		}
		
		/**
		 * Trigger the update of the user
		 *
		 */
		private function onUpdateUser(userDetails:Object):void {
			// Validate the data that you can first
			/*if (userDetails.currentPassword) {
				var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
				if (userDetails.currentPassword != loginProxy.user.password) {
					view.showUpdateError("Your current password doesn't match, please try again.");
					return;
				}
			}*/
			if (userDetails.examDate) {
				// It must be a valid date in the future
			}

			var passedDetails:Object = new Object();
			//passedDetails.password = userDetails.password;
			passedDetails.examDate = userDetails.examDate;
			
			// dispatch a notification, which will trigger the command
			sendNotification(BBNotifications.USER_UPDATE, passedDetails);
			
		}
		
		private function onInfoRequested():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var registerPage:String = (configProxy.getConfig().registerURL) ? configProxy.getConfig().registerURL : "www.takeielts.org";
			sendNotification(IELTSNotifications.IELTS_REGISTER, registerPage);
		}
		
		/*private function onLanguageChange(languageCode:String):void {
			sendNotification(BBNotifications.LANGUAGE_CHANGE, languageCode);
		}*/
		
	}
}
