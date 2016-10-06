package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.googlecode.bindagetools.Bind;
	
	import mx.utils.ObjectUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ZoneMediator extends BentoMediator implements IMediator {
		
		public function ZoneMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ZoneView {
			return viewComponent as ZoneView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// Inject required data into the view
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.user = loginProxy.user;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.dateFormatter = configProxy.getDateFormatter();
			
			// get the login platform
			if (configProxy.isPlatformTablet()) {
				view.isPlatformTablet = true;
				if (configProxy.isPlatformiPad()) {
					view.isPlatformipad = true;
				} else if (configProxy.isPlatformAndroid()) {
					view.isPlatformAndroid = true;
				}
			} else {
				view.isPlatformTablet = false;
			}
			
			// #234
			view.productVersion = configProxy.getProductVersion();
			view.licenceType = configProxy.getLicenceType();
			// gh#761
			var directStart:Object = configProxy.getDirectStart();
			if (ObjectUtil.getClassInfo(directStart).properties.length > 0) {
				view.isDirectLinkStart = true;
				
				if (directStart.unitID || directStart.exerciseID) {
					view.isCourseDirectLink= false;
				} else {
					view.isCourseDirectLink = true;
				}
			} else {
				view.isDirectLinkStart = false;
			}
			
			// listen for these signals
			view.courseSelect.add(onCourseSelected);
			view.upgrade.add(onUpgradeIELTS); 
			view.register.add(onRegisterIELTS);
			view.buy.add(onBuyIELTS);

			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			// gh#278 TitleView can no longer get at ZoneView (is this true?) so can't use this flag.
			view.isMediated = true; // #222
			
			Bind.fromProperty(bentoProxy, "selectedCourseNode").toProperty(view, "course");			
			
			// #514 If you are SCORM you don't want the course selector
			// #378 Actually, you will still use it, just disable the courses that are hidden.
			//view.useCourseSelector = !configProxy.getConfig().scorm;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelect.remove(onCourseSelected);
			
			// gh#278 TitleView can no longer get at ZoneView (is this true?) so can't use this flag.
			view.isMediated = false; // #222
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.SCORE_WRITTEN,
				IELTSNotifications.PRACTICE_ZONE_POPUP_SHOW,
				IELTSNotifications.PRACTICE_ZONE_POPUP_HIDE,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				// #164 For updating of coverage blobs when you do another exercise
				case BBNotifications.SCORE_WRITTEN:
					//view.popoutExerciseSelector.exercises = view.refreshedExercises();
					break;
				case IELTSNotifications.PRACTICE_ZONE_POPUP_SHOW:
					view.setSelectorInforButtonVisible(false);
					break;
				case IELTSNotifications.PRACTICE_ZONE_POPUP_HIDE:
					view.setSelectorInforButtonVisible(true);
					break;
			}
		}
		
		/**
		 * Trigger the display of a course in the zone view
		 *
		 */
		private function onCourseSelected(course:XML):void {
			// Open the selected course
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, course);
			
			// Set the selected course class
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			dataProxy.set("currentCourseClass", course.@["class"].toString());
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
