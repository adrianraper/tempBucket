package com.clarityenglish.bento.view.progress.components {
import com.clarityenglish.bento.BBNotifications;
import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import org.puremvc.as3.interfaces.IMediator;
	
	/**
	 * A Mediator
	 */
	public class ProgressAnalysisMediator extends BentoMediator implements IMediator {
		
		public function ProgressAnalysisMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ProgressAnalysisView {
			return viewComponent as ProgressAnalysisView;
		}
		
		override public function onRegister():void {
			super.onRegister();

			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
            if (bentoProxy.menuXHTML == null) {
                facade.sendNotification(BBNotifications.MENU_XHTML_RELOAD);
                return;
            }

            view.href = bentoProxy.menuXHTML.href;
		}
		
	}
}
