package com.clarityenglish.activereading.view.ending {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import org.puremvc.as3.interfaces.IMediator;
	
	public class EndingMediator extends BentoMediator implements IMediator {
		
		public function EndingMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():EndingView {
			return viewComponent as EndingView;
		}
	}
}