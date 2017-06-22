package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	import spark.components.View;
	
	/**
	 * The parent of all mediators for sections in the zone navigator.  This ensure that view.data is always set to the current course.
	 */
	public class AbstractZoneSectionMediator extends BentoMediator implements IMediator {
		
		public function AbstractZoneSectionMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():AbstractZoneSectionView {
			return viewComponent as AbstractZoneSectionView;
		}
		
		
		override public function onRegister():void {
			super.onRegister();
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.isPlatformiPad = configProxy.isPlatformiPad();
			view.isPlatformTablet = configProxy.isPlatformTablet();
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
					(viewComponent as View).data = note.getBody();
					break;
			}
		}
		
	}
}
