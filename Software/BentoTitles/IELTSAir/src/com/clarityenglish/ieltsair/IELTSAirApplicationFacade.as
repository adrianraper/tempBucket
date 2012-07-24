package com.clarityenglish.ieltsair {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.bento.vo.content.model.Question;
	import com.clarityenglish.ielts.IELTSApplicationFacade;
	
	import com.clarityenglish.ieltsair.zone.PracticeZonePopoutMediator;
	import com.clarityenglish.ieltsair.zone.PracticeZonePopoutView;
	import com.clarityenglish.ieltsair.zone.PracticeZoneSectionMediator;
	import com.clarityenglish.ieltsair.zone.PracticeZoneSectionView;
	import com.clarityenglish.ieltsair.zone.QuestionZoneSectionMediator;
	import com.clarityenglish.ieltsair.zone.QuestionZoneSectionView;
	
	public class IELTSAirApplicationFacade extends IELTSApplicationFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new IELTSAirApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(QuestionZoneSectionView, QuestionZoneSectionMediator);
			mapView(PracticeZoneSectionView, PracticeZoneSectionMediator);
			mapView(PracticeZonePopoutView, PracticeZonePopoutMediator);
		}
		
	}
}
