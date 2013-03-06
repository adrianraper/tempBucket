package com.clarityenglish.rotterdam.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
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
		}
				
		override public function onRemove():void {
			super.onRemove();
			
			view.dirtyWarningShow.remove(onDirtyWarningShow);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.COURSE_STARTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.COURSE_STARTED:
					view.showCourseView();
					break;
			}
		}
		
		protected function onDirtyWarningShow(next:Function):void {
			// gh#83 and gh#90
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			if (courseProxy.isDirty) {
				sendNotification(BBNotifications.WARN_DATA_LOSS, { message: courseProxy.getDirtyMessage(), func: next }, "changes_not_saved");
			} else {
				next();
			}
		}
		
	}
}
