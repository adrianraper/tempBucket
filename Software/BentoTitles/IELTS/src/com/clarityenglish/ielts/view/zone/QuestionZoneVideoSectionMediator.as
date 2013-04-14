package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class QuestionZoneVideoSectionMediator extends AbstractZoneSectionMediator implements IMediator {
		
		public function QuestionZoneVideoSectionMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():QuestionZoneVideoSectionView {
			return viewComponent as QuestionZoneVideoSectionView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			view.hrefToUidFunction = bentoProxy.getExerciseUID;
			
			// Inject the available video channels
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
			
			view.videoScore.add(onVideoScore);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.videoScore.remove(onVideoScore);
			
			// This is a special case that writes the score if the user goes away from the view without explicitly paused or stopping the video (GH #50)
			var exerciseMark:ExerciseMark = view.videoSelector.getVideoScore();
			if (exerciseMark)
				onVideoScore(exerciseMark);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.COURSE_STARTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.COURSE_STARTED:
					// #510 - when the course is changed go back to the main starting out view
					view.navigator.popToFirstView(null);
					break;
			}
		}
		
		protected function onVideoScore(exerciseMark:ExerciseMark):void {
			sendNotification(BBNotifications.SCORE_WRITE, exerciseMark);
		}
		
	}
}
