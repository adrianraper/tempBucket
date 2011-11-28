package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	import com.clarityenglish.ielts.view.progress.ProgressView;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ProgressAnalysisMediator extends BentoMediator implements IMediator {
		
		public function ProgressAnalysisMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressAnalysisView {
			return viewComponent as ProgressAnalysisView;
		}
		
		override public function onRegister():void {
			super.onRegister();

			// I want the first thing to be the initChart call
			trace("progCompareMediator call initCharts");
			view.initCharts();

			// Ask for the progress data you want
			trace("progAnalysisMediator, ask for my_summary and everyone_summary");
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_SUMMARY);
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_EVERYONE_SUMMARY);

		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.PROGRESS_DATA_LOADED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				// Here we should listen for notification of data_loaded
				// then it does view.setMySummary
				case BBNotifications.PROGRESS_DATA_LOADED:
				
					// Split the data that comes back for the various charts
					var rs:Object = note.getBody() as Object;
					trace("progAnalysisMediator, got back " + rs.type);
					if (rs.type == Progress.PROGRESS_MY_SUMMARY) {
						view.setMySummaryDataProvider(new XML(rs.dataProvider));
					}
					if (rs.type == Progress.PROGRESS_EVERYONE_SUMMARY) {
						view.setEveryoneSummaryDataProvider(new XML(rs.dataProvider));
					}
					break;
				
			}
		}	
	}
}
