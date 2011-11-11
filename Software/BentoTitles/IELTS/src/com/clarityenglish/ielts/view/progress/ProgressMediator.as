package com.clarityenglish.ielts.view.progress {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ProgressMediator extends BentoMediator implements IMediator {
		
		public function ProgressMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressView {
			return viewComponent as ProgressView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			// This is where we trigger the calls to get the progress data
			// Do I get problems if triggering three calls at once?
			// Or is it just that the everyone call takes a very long time?
			/*
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_SUMMARY);
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_EVERYONE_SUMMARY);
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_DETAILS);
			*/
			
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				//BBNotifications.PROGRESS_DATA_LOADED,
				//CommonNotifications.CHART_TEMPLATES_LOADED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			//switch (note.getName()) {
				//case BBNotifications.PROGRESS_DATA_LOADED:
					
					// Split the data that comes back for the various charts
					/*
					var rs:Object = note.getBody() as Object;
					if (rs.type == Progress.PROGRESS_MY_SUMMARY) {
						view.setMySummaryDataProvider(rs.dataProvider);
					}
					if (rs.type == Progress.PROGRESS_MY_DETAILS) {
						view.setMyDetailsDataProvider(rs.dataProvider);
					}
					if (rs.type == Progress.PROGRESS_EVERYONE_SUMMARY) {
						view.setEveryoneSummaryDataProvider(rs.dataProvider);
					}
					*/
					//break;
				
				// Once the chart templates are loaded, inject them into the view
				//case CommonNotifications.CHART_TEMPLATES_LOADED:
					
					// Inject the chart templates back into the view
					//view.initCharts(note.getBody() as XML);
					//break;
			//}
		}
		
	}
}
