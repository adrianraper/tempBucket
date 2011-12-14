package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	
	import mx.collections.ArrayCollection;
	
	import org.osflash.signals.Signal;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ProgressCoverageMediator extends BentoMediator implements IMediator {
		
		public function ProgressCoverageMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressCoverageView {
			return viewComponent as ProgressCoverageView;
		}
		
		override public function onRegister():void {
			super.onRegister();

			// Ask for the progress data you want		
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_DETAILS);
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_SUMMARY);
			//sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_BOOKMARK);

			// Listen for course changing signal
			view.courseSelect.add(onCourseSelect);

		}

		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelect.remove(onCourseSelect);
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
				
					// Split the data that comes back for the various charts
					var rs:Object = note.getBody() as Object;
					switch (rs.type) {
						case Progress.PROGRESS_MY_DETAILS:
							view.detailDataProvider = new XML(rs.dataProvider);
							break;
						case Progress.PROGRESS_MY_SUMMARY:
							view.summaryDataProvider = new XML(rs.dataProvider);
							break;
						case Progress.PROGRESS_MY_BOOKMARK:
							view.bookmark = new XML(rs.dataProvider);
							break;
						default:
					}
					break;
				
			}
		}
		
		private function onCourseSelect(courseClass:String):void {
			view.courseClass = courseClass;
			
			// Update the value in the main model. But it is ProgressView I really need to update it in
			// so that it can get injected into any other subview.
			// Can I do it with a signal from here to ProgressView? No.
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			bentoProxy.currentCourseClass = courseClass;
		}
	}
}
