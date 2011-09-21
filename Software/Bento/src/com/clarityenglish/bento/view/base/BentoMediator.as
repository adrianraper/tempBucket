package com.clarityenglish.bento.view.base {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.XHTMLProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * Bento components (designed to automatically add and remove their associated mediators) should extend this class.
	 * It is *vital* that child classes do not override getMediatorName and let Bento take care of this automatically.
	 * 
	 * @author Dave Keen
	 */
	public class BentoMediator extends Mediator implements IMediator  {
		
		public function BentoMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():BentoView {
			return viewComponent as BentoView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			if (view.href) {
				sendNotification(BBNotifications.XHTML_LOAD, view.href);
			}
		}
		
		public override function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.XHTML_LOADED,
			]);
		}
		
		public override function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.XHTML_LOADED:
					break;
			}
		}
		
	}
}