package com.clarityenglish.ieltsair.view.zone {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class PracticeZonePopoutMediator extends BentoMediator implements IMediator {
		
		public function PracticeZonePopoutMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():PracticeZonePopoutView {
			return viewComponent as PracticeZonePopoutView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.exerciseSelect.add(onExerciseSelect);
			
			// This view needs the href of the menu xml in order to construct absolute paths to thumbnails
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			// The popup always starts out invisible
			view.visible = false;
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exerciseSelect.remove(onExerciseSelect);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				IELTSNotifications.PRACTICE_ZONE_POPUP_SHOW,
				IELTSNotifications.PRACTICE_ZONE_POPUP_HIDE,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case IELTSNotifications.PRACTICE_ZONE_POPUP_SHOW:
					view.visible = true;
					
					view.exercises = note.getBody() as XMLList;
					view.caption = note.getType();
					break;
				case IELTSNotifications.PRACTICE_ZONE_POPUP_HIDE:
					view.visible = false;
					break;
			}
		}
		
		protected function onExerciseSelect(href:Href):void {
			sendNotification(IELTSNotifications.PRACTICE_ZONE_POPUP_HIDE);
			sendNotification(IELTSNotifications.HREF_SELECTED, href);
		}
		
	}
}
