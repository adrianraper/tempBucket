package com.clarityenglish.rotterdam {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorMediator;
	import com.clarityenglish.rotterdam.view.courseselector.CourseSelectorView;
	
	public class CommonAbstractApplicationFacade extends BentoFacade {
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(CourseSelectorView, CourseSelectorMediator);
		}
		
	}
	
}