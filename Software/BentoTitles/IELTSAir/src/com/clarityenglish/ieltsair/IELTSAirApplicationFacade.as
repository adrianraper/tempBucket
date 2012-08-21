package com.clarityenglish.ieltsair {
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.ielts.IELTSApplicationFacade;
	import com.clarityenglish.ieltsair.view.zone.AdviceZoneSectionMediator;
	import com.clarityenglish.ieltsair.view.zone.AdviceZoneSectionView;
	import com.clarityenglish.ieltsair.view.zone.ExamPracticeZoneSectionMediator;
	import com.clarityenglish.ieltsair.view.zone.ExamPracticeZoneSectionView;
	import com.clarityenglish.ieltsair.view.zone.PracticeZonePopoutMediator;
	import com.clarityenglish.ieltsair.view.zone.PracticeZonePopoutView;
	import com.clarityenglish.ieltsair.view.zone.PracticeZoneSectionMediator;
	import com.clarityenglish.ieltsair.view.zone.PracticeZoneSectionView;
	import com.clarityenglish.ieltsair.view.zone.QuestionZoneSectionMediator;
	import com.clarityenglish.ieltsair.view.zone.QuestionZoneSectionView;
	import com.clarityenglish.ieltsair.view.zone.QuestionZoneVideoSectionMediator;
	import com.clarityenglish.ieltsair.view.zone.QuestionZoneVideoSectionView;
	
	public class IELTSAirApplicationFacade extends IELTSApplicationFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new IELTSAirApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(AdviceZoneSectionView, AdviceZoneSectionMediator);
			mapView(QuestionZoneVideoSectionView, QuestionZoneVideoSectionMediator);
			mapView(QuestionZoneSectionView, QuestionZoneSectionMediator);
			mapView(PracticeZoneSectionView, PracticeZoneSectionMediator);
			mapView(PracticeZonePopoutView, PracticeZonePopoutMediator);
			mapView(ExamPracticeZoneSectionView, ExamPracticeZoneSectionMediator);
		}
		
	}
}
