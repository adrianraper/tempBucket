package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class UnitHeaderMediator extends BentoMediator implements IMediator {
		
		public function UnitHeaderMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():UnitHeaderView {
			return viewComponent as UnitHeaderView;
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				RotterdamNotifications.UNIT_STARTED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case RotterdamNotifications.UNIT_STARTED:
					view.unit = note.getBody() as XML;
					break;
			}
		}
		
	}
}
