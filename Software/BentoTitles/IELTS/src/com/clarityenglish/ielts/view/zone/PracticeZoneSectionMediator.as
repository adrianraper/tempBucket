package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class PracticeZoneSectionMediator extends AbstractZoneSectionMediator implements IMediator {
		
		public function PracticeZoneSectionMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():PracticeZoneSectionView {
			return viewComponent as PracticeZoneSectionView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.exercisesShow.add(onExercisesShow);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exercisesShow.remove(onExercisesShow);
			
			facade.sendNotification(IELTSNotifications.PRACTICE_ZONE_POPUP_HIDE);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				
			}
		}
		
		private function onExercisesShow(exercises:XMLList, caption:String):void {
			sendNotification(IELTSNotifications.PRACTICE_ZONE_POPUP_SHOW, exercises, caption);
		}
		
	}
}
