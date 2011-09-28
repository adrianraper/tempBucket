package com.clarityenglish.bento.view {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class DynamicMediator extends BentoMediator {
		
		public function DynamicMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		public function get view():DynamicView {
			return viewComponent as DynamicView;
		}
		
		public override function onRegister():void {
			super.onRegister();
		}
		
		public override function onRemove():void {
			super.onRemove();
		}
		
		public override function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		public override function handleNotification(notification:INotification):void {
			super.handleNotification(notification);
			
			switch (notification.getName()) {
				
			}
		}
		
	}
	
}