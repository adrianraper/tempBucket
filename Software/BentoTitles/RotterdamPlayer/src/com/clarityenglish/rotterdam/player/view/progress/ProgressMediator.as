package com.clarityenglish.rotterdam.player.view.progress {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import org.puremvc.as3.interfaces.IMediator;
	
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
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
		}
		
	}
	
}
