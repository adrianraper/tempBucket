package com.clarityenglish.bento.view.xhtmlexercise {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	
	import org.puremvc.as3.interfaces.INotification;
	
	public class XHTMLExerciseMediator extends BentoMediator {
		
		public function XHTMLExerciseMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		public function get view():XHTMLExerciseView {
			return viewComponent as XHTMLExerciseView;
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