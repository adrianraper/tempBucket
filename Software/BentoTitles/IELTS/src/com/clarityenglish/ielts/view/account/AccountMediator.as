package com.clarityenglish.ielts.view.account {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.LoginProxy;
	
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
			
			// Inject some data to the screen.
			// But this is too early, the fields don't exist, so just save the data
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			//view.showUserDetails(loginProxy.user);
			view.userDetails = loginProxy.user;
			
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				CommonNotifications.UPDATE_FAILED,
				BBNotifications.USER_UPDATED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case CommonNotifications.UPDATE_FAILED:
					view.showUpdateError();
					break;	
				
				case BBNotifications.USER_UPDATED:
					view.showUpdateSuccess();
					break;
			}
		}
		
		/**
		 * Trigger the update of the user
		 *
		 */
		private function onUpdateUser(userDetails:Object):void {
			
			// Validate the data that you can first
			//if (userDetails.currentPassword) {
				var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
				if (userDetails.currentPassword != loginProxy.user.password) {
					view.showUpdateError("Your current password doesn't match, please try again.");
					return;
				}
			//}
			if (userDetails.examJustDate) {
				// It must be a valid date in the future
			}
			if (userDetails.examJustTime) {
				// It must be a valid time
			}

			var passedDetails:Object = new Object();
			passedDetails.password = userDetails.password;
			passedDetails.examDate = userDetails.examJustDate + ' ' + userDetails.examJustTime;
			
			// dispatch a notification, which will trigger the command
			sendNotification(BBNotifications.USER_UPDATE, passedDetails);
			
		}
		
		
	}
}
