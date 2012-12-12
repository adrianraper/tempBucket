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
			
			// Inject required data into the view
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.productVersion = configProxy.getProductVersion();
			view.productCode = configProxy.getProductCode();
			view.licenceType = configProxy.getLicenceType();
			
			// listen for these signals
			view.register.add(onRegisterIELTS);
			view.buy.add(onUpgradeIELTS);
			view.manual.add(onManualClick);

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
		
		private function onUpgradeIELTS():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var buyPage:String = (configProxy.getConfig().upgradeURL) ? configProxy.getConfig().upgradeURL : "www.ieltspractice.com";
			sendNotification(IELTSNotifications.IELTS_REGISTER, buyPage);
		}
		
		private function onRegisterIELTS():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var registerPage:String = (configProxy.getConfig().registerURL) ? configProxy.getConfig().registerURL : "www.takeielts.org";
			sendNotification(IELTSNotifications.IELTS_REGISTER, registerPage);
		}
		
		private function onManualClick():void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var manualPage:String = (configProxy.getConfig().manualURL) ? configProxy.getConfig().manualURL : "http://www.clarityenglish.com/support/user/pdf/rti2/RoadToIELTS2_Network_Guide.pdf";
			sendNotification(IELTSNotifications.IELTS_REGISTER, manualPage);
		}
		
		
	}
}
