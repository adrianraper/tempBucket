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
			//view.mySummaryDataLoaded.add(onMySummaryDataLoad);
			//view.everyoneSummaryDataLoaded.add(onEveryoneSummaryDataLoad);
			//view.myDetailsDataLoaded.add(onMyDetailsDataLoad);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);	
		}
		
		// Whenever you pick up the mySummary data, add it to the chart
		private function onMyDetailsDataLoad(dataProvider:ArrayCollection):void {
			view.scoreDetails.dataProvider = dataProvider;
		}
		
	}
}
