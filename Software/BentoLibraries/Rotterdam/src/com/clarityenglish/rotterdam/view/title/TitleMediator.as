package com.clarityenglish.rotterdam.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
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
			
			view.dirtyWarningShow.add(onDirtyWarningShow);
			view.logout.add(onLogout);
			
			// gh#299 - always start in course selector
			view.currentState = "course_selector";
		}
				
		override public function onRemove():void {
			super.onRemove();
			
			view.dirtyWarningShow.remove(onDirtyWarningShow);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.COURSE_STARTED,
				RotterdamNotifications.SETTINGS_SHOW,
				RotterdamNotifications.SCHEDULE_SHOW,
				//RotterdamNotifications.BACK_TO_COURSE
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.COURSE_STARTED:
				//case RotterdamNotifications.BACK_TO_COURSE:
					view.showCourseView();
					break;
				case RotterdamNotifications.SETTINGS_SHOW:
					view.showSettingsView();
					break;
				case RotterdamNotifications.SCHEDULE_SHOW:
					view.showScheduleView();
					break;
            }
		}
		
		protected function onDirtyWarningShow(next:Function):void {
			// gh#83 and gh#90
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.isDirty) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, { message: bentoProxy.getDirtyMessage(), func: next }, "changes_not_saved");
			} else {
				next();
			}
		}
		
		// gh#217
		private function onLogout():void {
			/*var logOutFun:Function = function():void {
				sendNotification(CommonNotifications.LOGOUT);
				view.myCoursesViewNavigator.popToFirstView();
			}
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.isDirty) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, { message: bentoProxy.getDirtyMessage(), func: logOutFun }, "changes_not_saved");
			} else {
				logOutFun();
			}*/
			
			sendNotification(CommonNotifications.LOGOUT);
		}
		
	}
}
