package com.clarityenglish.clearpronunciationair {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.clearpronunciation.ClearPronunciationApplicationFacade;
	
	public class ClearPronunciationAirApplicationFacade extends ClearPronunciationApplicationFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new ClearPronunciationAirApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
		}
	}
}