package com.clarityenglish.ielts.view.progress.components {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ProgressScoreMediator extends BentoMediator implements IMediator {
		
		public function ProgressScoreMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressScoreView {
			return viewComponent as ProgressScoreView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, view.href, Progress.PROGRESS_MY_DETAILS);
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
					if (rs.type == Progress.PROGRESS_MY_DETAILS) {
						view.setMyDetailsDataProvider = rs.dataProvider;
					}
					break;
				
			}
		}
		
		
		/*
		// Whenever you pick up the mySummary data, add it to the chart
		private function onMyDetailsDataLoad(dataProvider:ArrayCollection):void {
			view.scoreDetails.dataProvider = dataProvider;
		}
		*/
		
	}
}
