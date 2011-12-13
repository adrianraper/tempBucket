package com.clarityenglish.bento.view {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.textLayout.vo.XHTML;
	
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
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
			
			if (!xhtml is Exercise)
				throw new Error("Dynamic view was invoked on something that was not an Exercise");
			
			// As long as this dynamic view isn't for the purpose of printing send an EXERCISE_START notification
			if (view.media != "print") sendNotification(BBNotifications.EXERCISE_START, xhtml);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			// As long as this dynamic view isn't for the purpose of printing send an EXERCISE_STOP notification
			if (view.media != "print") sendNotification(BBNotifications.EXERCISE_STOP);
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