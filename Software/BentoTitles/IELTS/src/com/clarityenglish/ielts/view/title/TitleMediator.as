package com.clarityenglish.ielts.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
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
			view.productVersion = configProxy.getProductVersion() || "fullVersion";
			view.productCode = configProxy.getProductCode() || 52;
			
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
			// #210. Can you simply stop the exercise now, or do you need any warning first?
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exercise:Exercise = bentoProxy.currentExercise;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(exercise)) as ExerciseProxy;
			
			if (!exerciseProxy.exerciseMarked && exerciseProxy.exerciseDirty) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, { type: "lose_answers", action: BBNotifications.EXERCISE_SECTION_FINISHED });
			} else {
				view.showExercise(null);
			}
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.EXERCISE_SHOW,
				BBNotifications.EXERCISE_RESTART,
				BBNotifications.EXERCISE_SECTION_FINISHED,
				IELTSNotifications.COURSE_SHOW,
				CommonNotifications.LOGGED_OUT,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.EXERCISE_SHOW:
					var href:Href = note.getBody() as Href;
					view.showExercise(href);
					break;
				case BBNotifications.EXERCISE_RESTART:
					// Restart an exercise by showing a clone of the current Href.  This will have the same effect as starting a new exercise
					// as the view will see that the Href is a new instance, hence resetting everything (but ultimately loading the same xml).
					var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
					view.showExercise(bentoProxy.currentExercise.href.clone());
					break;
				case BBNotifications.EXERCISE_SECTION_FINISHED:
					view.showExercise(null);
					break;
				case IELTSNotifications.COURSE_SHOW:
					var course:XML = note.getBody() as XML;
					view.currentState = "zone";
					if (view.navBar) view.navBar.selectedIndex = -1;
					view.callLater(function():void {
						view.zoneView.course = course;
					});
					break;
				case CommonNotifications.LOGGED_OUT:
					break;
			}
		}
		
		private function onUpgradeIELTS():void {
			sendNotification(IELTSNotifications.IELTS_UPGRADE_WINDOW_SHOW);
		}
		
		private function onRegisterIELTS():void {
			sendNotification(IELTSNotifications.IELTS_REGISTER);
		}
		
		private function onBuyIELTS():void {
			sendNotification(IELTSNotifications.IELTS_UPGRADE_WINDOW_SHOW);
		}
		
	}
}
