package com.clarityenglish.ielts.view.home {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.common.vo.progress.Progress;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class HomeMediator extends BentoMediator implements IMediator {
		
		public function HomeMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():HomeView {
			return viewComponent as HomeView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// listen for this signal
			view.courseSelect.add(onCourseSelected);

			// Trigger loading of progress data for my summary chart
			//sendNotification(BBNotifications.PROGRESS_DATA_LOAD, {href:view.href}, Progress.PROGRESS_MY_SUMMARY);
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_SUMMARY);
		}
		
		override public function onRemove():void {
			super.onRemove();
			view.courseSelect.remove(onCourseSelected);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
					BBNotifications.PROGRESS_DATA_LOADED,
				]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.PROGRESS_DATA_LOADED:
					
					var rs:Object = note.getBody() as Object;
					// For this mediator, currently only expecting one progress type to come back
					if (rs.type == Progress.PROGRESS_MY_SUMMARY) {
						view.setSummaryDataProvider(rs.dataProvider);
					}
					break;
				
			}
		}
		
		/**
		 * Trigger the display of a course in the zone view
		 *
		 */
		private function onCourseSelected(course:XML):void {
			// dispatch a notification, which titleMediator is listening for
			sendNotification(IELTSNotifications.COURSE_SHOW, course);
		}
		
	}
}
