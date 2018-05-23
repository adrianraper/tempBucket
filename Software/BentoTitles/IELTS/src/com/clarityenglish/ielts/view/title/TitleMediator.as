package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.observer.Notification;
	import com.clarityenglish.bento.model.SCORMProxy;
	
	/**
	 * A Mediator
	 */
	public class TitleMediator extends BentoMediator implements IMediator {
		
		public function TitleMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():TitleView {
			return viewComponent as TitleView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// Inject required data into the view
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.dateFormatter = configProxy.getDateFormatter();
			view.configID = configProxy.getConfig().configID;
			view.productVersion = configProxy.getProductVersion() || 'R2IFV';
			view.productCode = configProxy.getProductCode() || '52';
			view.licenceType = configProxy.getLicenceType(); 
			
			// listen for these signals
			view.logout.add(onLogout);
			view.backToMenu.add(onBackToMenu);
			view.upgrade.add(onUpgradeIELTS); 
			view.register.add(onRegisterIELTS);
			view.buy.add(onBuyIELTS);
			
			// gh#761
			if (configProxy.getDirectStart()) {
				var directStart:Object = configProxy.getDirectStart();
				
				if (directStart.exerciseID || directStart.groupID) {
					view.isDirectStartEx = true;
				}
			}
			
			if (configProxy.isAccountJustAnonymous() && configProxy.isPlatformTablet()) {
				view.isLogoutButtonHide = true;
			}
		}
		
		override public function onRemove():void {
			super.onRegister();
			
			view.logout.remove(onLogout);
			view.backToMenu.remove(onBackToMenu);
			view.upgrade.remove(onUpgradeIELTS); 
			view.register.remove(onRegisterIELTS);
			view.buy.remove(onBuyIELTS);
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
		}
		
		/**
		 * Logout
		 * 
		 */
		private function onLogout():void {
			sendNotification(CommonNotifications.LOGOUT);
			// gh#1517
			view.homeViewNavigator.popToFirstView();
		}
		
		/**
		 * Click to go back to menu from an exercise. 
		 * Check if the exercise is dirty or with undisplayed feedback
		 */
		private function onBackToMenu():void {
			// #210 - can you simply stop the exercise now, or do you need any warning first?
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            
            // m#9 If the exercise failed to load, this will be null which is fine
			if (bentoProxy.currentExercise)
			    var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			if (bentoProxy.currentExercise == null || exerciseProxy.attemptToLeaveExercise(new Notification(BBNotifications.SELECTED_NODE_UP))) {
				sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view); // #265
				sendNotification(BBNotifications.SELECTED_NODE_UP);
			}
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.SELECTED_NODE_CHANGED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.SELECTED_NODE_CHANGED:
					view.selectedNode = note.getBody() as XML;
					// gh#383
					view.getCourseClass(note.getBody() as XML);
					break;
			}
		}
		
		private function onUpgradeIELTS():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var buyPage:String = (configProxy.getConfig().upgradeURL) ? configProxy.getConfig().upgradeURL : "www.ieltspractice.com";
			sendNotification(IELTSNotifications.IELTS_REGISTER, buyPage);
		}
		
		private function onRegisterIELTS():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var registerPage:String = (configProxy.getConfig().registerURL) ? configProxy.getConfig().registerURL : "www.takeielts.org";
			sendNotification(IELTSNotifications.IELTS_REGISTER, registerPage);
		}
		
		private function onBuyIELTS():void {
			// #337 Did you come from a candidate specific site?
			// Remove the pop-up window, always go to one page as indicated by config
			//if (view.candidateOnlyInfo) {
			//}
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var buyPage:String = (configProxy.getConfig().pricesURL) ? configProxy.getConfig().pricesURL : "www.clarityenglish.com";
			sendNotification(IELTSNotifications.IELTS_REGISTER, buyPage);
		}
		
	}
}
