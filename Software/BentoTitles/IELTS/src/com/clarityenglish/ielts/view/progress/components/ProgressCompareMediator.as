package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	
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
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			// I want the first thing to be the initChart call
			//trace("progCompareMediator call initCharts");
			view.initCharts();

			// Ask for the progress data you want
			//trace("progCompareMediator, ask for my_summary and everyone_summary");
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_SUMMARY);
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_EVERYONE_SUMMARY);

			// Inject required data into the view
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.licenceType = configProxy.getLicenceType();
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			// #320
			view.clearCharts();
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
					//trace("progCompareMediator, got back " + rs.type);
					if (rs.type == Progress.PROGRESS_MY_SUMMARY) {
						// #250. Save xml rather than a string
						//view.setMySummaryDataProvider(new XML(rs.dataProvider));
						view.setMySummaryDataProvider(rs.dataProvider);
					}
					if (rs.type == Progress.PROGRESS_EVERYONE_SUMMARY) {
						//view.setEveryoneSummaryDataProvider(new XML(rs.dataProvider));
						view.setEveryoneSummaryDataProvider(rs.dataProvider);
					}
					break;
				
			}
		}	
	}
}
