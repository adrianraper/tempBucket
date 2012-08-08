package com.clarityenglish.ieltsair.zone {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.IELTSNotifications;
	
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
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				IELTSNotifications.COURSE_SHOW,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case IELTSNotifications.COURSE_SHOW:
					(viewComponent as View).data = note.getBody();
					break;
			}
		}
		
	}
}
