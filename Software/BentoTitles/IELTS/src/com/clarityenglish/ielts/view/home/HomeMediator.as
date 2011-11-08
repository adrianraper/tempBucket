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
			
			// listen for these signals
			view.courseSelect.add(onCourseSelected);
			view.chartTemplatesLoad.add(onChartTemplatesLoad);
			
			// Progress data comes in three blocks, and to save time we can choose which block(s) we want from this call
			var progress:Progress = new Progress();
			//progress.loadMySummary = true;
			//progress.loadMyDetails = true;
			///progress.loadEveryoneSummary = true;
			progress.type = Progress.PROGRESS_MY_SUMMARY;
			progress.href = view.href;
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, progress);
		}
		
		override public function onRemove():void {
			super.onRemove();
			view.courseSelect.remove(onCourseSelected);
			view.chartTemplatesLoad.remove(onChartTemplatesLoad);
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
					//var progress:Progress = new Progress(note.getBody() as Object);
					
					//view.setSummaryDataProvider(progress.mySummary, progress.everyoneSummary);
					var rs:Object = note.getBody() as Object;
					// For this mediator, currently only expecting one progress type to come back
					if (rs.type == Progress.PROGRESS_MY_SUMMARY) {
						view.setSummaryDataProvider(rs.dataProvider);
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
		 * Trigger the display of a course in the zone view
		 *
		 */
		private function onCourseSelected(course:XML):void {
			// dispatch a notification, which titleMediator is listening for
			sendNotification(IELTSNotifications.COURSE_SHOW, course);
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
