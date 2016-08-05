package com.clarityenglish.ielts.view.support {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.ielts.IELTSNotifications;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;

	/**
	 * A Mediator
	 */
	public class SupportMediator extends BentoMediator implements IMediator {

		public function SupportMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}

		private function get view():SupportView {
			return viewComponent as SupportView;
		}

		override public function onRegister():void {
			super.onRegister();
		}

		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([

			]);
		}

	}
}
