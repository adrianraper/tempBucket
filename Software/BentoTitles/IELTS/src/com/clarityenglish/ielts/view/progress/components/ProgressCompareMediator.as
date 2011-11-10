package com.clarityenglish.ielts.view.progress.components {
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
	public class ProgressCompareMediator extends BentoMediator implements IMediator {
		
		public function ProgressCompareMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressCompareView {
			return viewComponent as ProgressCompareView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			// Listen for the signals coming from the parent view
			// TODO. How?
			view.parent.mySummaryDataLoaded.add(onMySummaryDataLoaded);
			view.parent.everyoneSummaryDataLoaded.add(onEveryoneSummaryDataLoaded);
			//view.myDetailsDataLoaded.add(onMyDetailsDataLoaded);

		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);	
		}
		
		// Whenever you pick up a data, add it to the appropriate chart
		private function onMySummaryDataLoaded(dataProvider:Array):void {
			view.setMySummaryDataProvider(dataProvider);
		}
		private function onEveryoneSummaryDataLoaded(dataProvider:Array):void {
			view.setEveryoneSummaryDataProvider(dataProvider);
		}
		
	}
}
