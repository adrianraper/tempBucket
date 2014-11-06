package com.clarityenglish.clearpronunciation.view.exercise {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	public class YouWillMediator extends BentoMediator {
		public function YouWillMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():YouWillView {
			return viewComponent as YouWillView;
		}
	}
}