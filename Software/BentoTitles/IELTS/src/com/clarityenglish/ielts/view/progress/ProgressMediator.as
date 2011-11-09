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
			// This is where we trigger the call to get the progress data
			// Progress data comes in three blocks, and to save time we can choose which block(s) we want from this call
			var progress:Progress = new Progress();
			//progress.loadMySummary = true;
			//progress.loadMyDetails = true;
			//progress.loadEveryoneSummary = true;
			progress.href = view.href;
			progress.type = Progress.PROGRESS_MY_DETAILS;
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, progress)
			progress.type = Progress.PROGRESS_MY_SUMMARY;
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, progress)
			progress.type = Progress.PROGRESS_EVERYONE_SUMMARY;
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, progress)
				
			// listen for these signals
			view.chartTemplatesLoad.add(onChartTemplatesLoad);
			
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
				case BBNotifications.PROGRESS_DATA_LOADED:
					
					// Split the data that comes back for the various charts
					var rs:Object = note.getBody() as Object;
					if (rs.type == Progress.PROGRESS_MY_SUMMARY) {
						view.setMySummaryDataProvider(rs.dataProvider);
					}
					if (rs.type == Progress.PROGRESS_MY_DETAILS) {
						//view.setMyDetailsDataProvider(rs.dataProvider);
					}
					if (rs.type == Progress.PROGRESS_EVERYONE_SUMMARY) {
						view.setEveryoneSummaryDataProvider(rs.dataProvider);
					}
					break;
				
				// Once the chart templates are loaded, inject them into the view
				case CommonNotifications.CHART_TEMPLATES_LOADED:
					
					// Inject the chart templates back into the view
					view.initCharts(note.getBody() as XML);
					break;
			}
		}
		/**
		 * Trigger the loading of the chart templates
		 *
		 */
		private function onChartTemplatesLoad():void {
			
			// directly call the ConfigProxy to get the template for us
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.getChartTemplates();
		}
		
	}
}
