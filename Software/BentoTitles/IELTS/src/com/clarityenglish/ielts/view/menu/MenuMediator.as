package com.clarityenglish.ielts.view.menu {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class MenuMediator extends BentoMediator implements IMediator {
		
		public function MenuMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():MenuView {
			return viewComponent as MenuView;
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
        
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				IELTSNotifications.EXERCISE_SHOW,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case IELTSNotifications.EXERCISE_SHOW:
					var href:Href = note.getBody() as Href;
					view.showExercise(href);
					break;
			}
		}
		
	}
}
