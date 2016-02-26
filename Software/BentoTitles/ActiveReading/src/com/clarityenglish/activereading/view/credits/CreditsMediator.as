package com.clarityenglish.activereading.view.credits {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import org.puremvc.as3.interfaces.IMediator;
	
	public class CreditsMediator extends BentoMediator implements IMediator {
		
		public function CreditsMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():CreditsView {
			return viewComponent as CreditsView;
		}
	}
}