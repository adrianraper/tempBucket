package com.clarityenglish.ielts {
	import com.clarityenglish.bento.BentoFacade;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class ApplicationFacade extends BentoFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new ApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
		}
		
	}
	
}