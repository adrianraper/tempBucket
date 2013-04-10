package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class ExamPracticeZoneSectionMediator extends AbstractZoneSectionMediator implements IMediator {
		
		public function ExamPracticeZoneSectionMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ExamPracticeZoneSectionView {
			return viewComponent as ExamPracticeZoneSectionView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			view.exerciseSelect.add(onExerciseSelect);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exerciseSelect.remove(onExerciseSelect);
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
					view.stopAllAudio(); // #508
					break;
			}
		}
		
		protected function onExerciseSelect(href:Href):void {
			sendNotification(IELTSNotifications.HREF_SELECTED, href);
		}
		
	}
}
