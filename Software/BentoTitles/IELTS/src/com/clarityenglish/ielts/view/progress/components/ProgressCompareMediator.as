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
	public class ProgressCompareMediator extends BentoMediator implements IMediator {
		
		public function ProgressCompareMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressCompareView {
			return viewComponent as ProgressCompareView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// Ask for the progress data you want
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_SUMMARY);
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_EVERYONE_SUMMARY);

			// Directly call the ConfigProxy to get the chart template for us
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.getChartTemplates();
			
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.PROGRESS_DATA_LOADED,
				CommonNotifications.CHART_TEMPLATES_LOADED,
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
					if (rs.type == Progress.PROGRESS_MY_SUMMARY) {
						view.mySummaryDataProvider = rs.dataProvider;
					}
					if (rs.type == Progress.PROGRESS_EVERYONE_SUMMARY) {
						view.everyoneSummaryDataProvider = rs.dataProvider;
					}
					break;
			}
		}
		
		/*
		// Whenever you pick up a data, add it to the appropriate chart
		private function onMySummaryDataLoaded(dataProvider:Array):void {
			view.setMySummaryDataProvider(dataProvider);
		}
		private function onEveryoneSummaryDataLoaded(dataProvider:Array):void {
			view.setEveryoneSummaryDataProvider(dataProvider);
		}
		*/
	}
}
