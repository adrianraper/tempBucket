package com.clarityenglish.bento.view.progress.components {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.vo.content.Title;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.rpc.ResultResponder;
	import org.puremvc.as3.interfaces.IMediator;
	
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
			
			// gh#1166
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			view.userCountry = loginProxy.user.country;
			
			// gh#1166
			view.countrySelect.add(onCountrySelected);
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (configProxy.isPlatformTablet()) {
				view.isPlatformTablet = true;
			} else {
				view.isPlatformTablet = false;
			}
		}

		// getEveryoneSummary is only used by the compare mediator, so use a direct call with a responder instead of mucking about with notifications
		private function getRemoteData(country:String = null):void {
			new RemoteDelegate("getEveryoneSummary", [ view.productCode, country ]).execute().addResponder(new ResultResponder(
				function(e:ResultEvent, data:AsyncToken):void {
					view.everyoneCourseSummaries = e.result;
				},
				function(e:FaultEvent, data:AsyncToken):void {
					var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
					sendNotification(CommonNotifications.BENTO_ERROR, copyProxy.getBentoErrorForId("errorCantLoadEveryoneSummary"));
				}
			));
		}
		
		private function onCountrySelected(country:String = null):void {
			getRemoteData(country);
		}
	}
}
