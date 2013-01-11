package com.clarityenglish.rotterdam.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
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
			
			view.saveWarningShow.add(onSaveWarningShow);
		}
				
		override public function onRemove():void {
			super.onRemove();
			
			view.saveWarningShow.remove(onSaveWarningShow);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.MENU_XHTML_LOADED,
				BBNotifications.PROGRESS_DATA_LOADED, // GH #95 - again, XHTMLProxy and ProgressProxy *need* to be consolidated
				RotterdamNotifications.SETTINGS_DIRTY,
				RotterdamNotifications.SETTINGS_CLEAN,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.MENU_XHTML_LOADED:
				case BBNotifications.PROGRESS_DATA_LOADED: // GH #95 - again, XHTMLProxy and ProgressProxy *need* to be consolidated
					view.showCourseView();
					break;
				case RotterdamNotifications.SETTINGS_DIRTY:
					view.enableSaveWarning = true; // GH #83
					break;
				case RotterdamNotifications.SETTINGS_CLEAN:
					view.enableSaveWarning = false; // GH #83
					break;
			}
		}
		
		protected function onSaveWarningShow(next:Function):void {
			// GH #83
			sendNotification(BBNotifications.WARN_DATA_LOSS, next, "changes_not_saved");
		}
		
	}
}
