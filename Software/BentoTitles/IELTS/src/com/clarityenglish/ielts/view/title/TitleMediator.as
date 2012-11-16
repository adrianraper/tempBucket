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
		}
		
		/**
		 * Click to go back to menu from an exercise. 
		 * Check if the exercise is dirty or with undisplayed feedback
		 */
		private function onBackToMenu():void {
			// #210 - can you simply stop the exercise now, or do you need any warning first?
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			if (exerciseProxy.attemptToLeaveExercise(new Notification(BBNotifications.EXERCISE_SECTION_FINISHED))) {
				sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view); // #265
				sendNotification(BBNotifications.EXERCISE_SECTION_FINISHED);
			}
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.EXERCISE_SHOW,
				BBNotifications.EXERCISE_SECTION_FINISHED,
				IELTSNotifications.COURSE_SHOW,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.EXERCISE_SHOW:
					var href:Href = note.getBody() as Href;
					view.showExercise(href);
					break;
				case BBNotifications.EXERCISE_SECTION_FINISHED:
					view.showExercise(null);
					break;
				case IELTSNotifications.COURSE_SHOW:
					view.selectedCourseXML = note.getBody() as XML;
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
