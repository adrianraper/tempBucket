package com.clarityenglish.activereading.view.progress {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.rpc.ResultResponder;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
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
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			view.href = bentoProxy.menuXHTML.href;			
			view.courseClass = dataProxy.getString("currentCourseClass") || "";
			
			// Listen for course changing signal
			view.courseSelect.add(onCourseSelect);
			
			// getEveryoneSummary is only used by the compare mediator, so use a direct call with a responder instead of mucking about with notifications
			new RemoteDelegate("getEveryoneUnitSummary", [ view.productCode, view.config.rootID ]).execute().addResponder(new ResultResponder(
				function(e:ResultEvent, data:AsyncToken):void {
					view.everyoneCourseSummaries = e.result;
				},
				function(e:FaultEvent, data:AsyncToken):void {
					var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
					sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorCantLoadEveryoneSummary"));
				}
			));
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (!configProxy.isPlatformTablet()) {
				view.isPlatformOnline = true;
			}
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.courseSelect.remove(onCourseSelect);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.DATA_CHANGED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);	
			
			switch (note.getName()) {
				case BBNotifications.DATA_CHANGED:
					if (note.getType() == "currentCourseClass") view.courseClass = note.getBody() as String;
					break;
			}
		}
		
		private function onCourseSelect(courseClass:String):void {
			// Set the selected course class
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			dataProxy.set("currentCourseClass", courseClass);
		}
	}
}