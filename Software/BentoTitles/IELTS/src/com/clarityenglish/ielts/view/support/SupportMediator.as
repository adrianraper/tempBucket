package com.clarityenglish.ielts.view.support {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.content.Title;
	
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
			
			// Inject required data into the view
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.productVersion = configProxy.getProductVersion();
			view.productCode = configProxy.getProductCode();
			view.licenceType = configProxy.getLicenceType();
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
		
	}
}
