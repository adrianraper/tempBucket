package com.clarityenglish.clearpronunciation.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.clearpronunciation.ClearPronunciationNotifications;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */	
	public class TitleMediator extends BentoMediator {
		public function TitleMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():TitleView {
			return viewComponent as TitleView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.dirtyWarningShow.add(onDirtyWarningShow);
			view.settingsOpen.add(onSettingsOpen);
			view.logout.add(onLogout);
			view.progressTransform.add(onProgressTransform);
			
			// gh#299 - always start in course selector
			view.currentState = "home";
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.dirtyWarningShow.remove(onDirtyWarningShow);
			view.logout.remove(onLogout);
			view.settingsOpen.remove(onSettingsOpen);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.UNIT_STARTED,
				RotterdamNotifications.SETTINGS_SHOW,
				RotterdamNotifications.SCHEDULE_SHOW,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.UNIT_STARTED:
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
		
		protected function onSettingsOpen():void {
			sendNotification(ClearPronunciationNotifications.SETTINGS_SHOW);
		}
		
		// gh#217
		private function onLogout():void {
			sendNotification(CommonNotifications.LOGOUT);
		}
		
		protected function onProgressTransform():void {
			//sendNotification();
		}
	}
}