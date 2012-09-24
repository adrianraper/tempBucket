package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.view.unit.widgets.AbstractWidget;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.ProgressEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * Mediator for individual widget.  Note that unlike most mediators this does *not* extend BentoMediator since there is no need for XHTML loading or any of the
	 * other extra functionality BentoMediator provides.
	 */
	public class WidgetMediator extends Mediator implements IMediator {
		
		public function WidgetMediator(mediatorName:String, viewComponent:Object) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():AbstractWidget {
			return viewComponent as AbstractWidget;
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.MEDIA_UPLOAD_START,
				RotterdamNotifications.MEDIA_UPLOAD_PROGRESS,
				RotterdamNotifications.MEDIA_UPLOADED,
				RotterdamNotifications.MEDIA_UPLOAD_ERROR,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			// Only take these actions if the notification is meant for us (i.e. the notification type is the node's id attribute)
			if (note.getType() == view.xml.@id) {
				switch (note.getName()) {
					case RotterdamNotifications.MEDIA_UPLOAD_START:
						view.setUploading(true);
						break;
					case RotterdamNotifications.MEDIA_UPLOAD_PROGRESS:
						view.setProgress(note.getBody() as ProgressEvent);
						break;
					case RotterdamNotifications.MEDIA_UPLOADED:
						view.setUploading(false);
						break;
					case RotterdamNotifications.MEDIA_UPLOAD_ERROR:
						trace("upload error");
						break;
				}
			}
		}
		
	}
}
