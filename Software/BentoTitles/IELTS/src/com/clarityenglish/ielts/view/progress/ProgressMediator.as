package com.clarityenglish.ielts.view.progress {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
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
			progress.loadMySummary = true;
			progress.loadMyDetails = true;
			progress.loadEveryoneSummary = true;
			sendNotification(BBNotifications.PROGRESS_DATA_LOAD, progress)
			
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
					var progress:Progress = new Progress(note.getBody() as Array);
					view.setSummaryDataProvider(progress.mySummary, progress.everyoneSummary);
					break;
			}
		}
		
	}
}
