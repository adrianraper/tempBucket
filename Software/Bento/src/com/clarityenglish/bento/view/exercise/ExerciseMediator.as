package com.clarityenglish.bento.view.exercise {
	import com.clarityenglish.bento.view.BentoMediator;
	import com.clarityenglish.bento.view.exercise.components.ExerciseView;
	import org.puremvc.as3.interfaces.INotification;
	
	public class ExerciseMediator extends BentoMediator {
		
		public function ExerciseMediator(mediatorName:String, viewComponent:Object) {
			super(mediatorName, viewComponent);
		}
		
		public function get view():ExerciseView {
			return viewComponent as ExerciseView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			trace("Created exercise mediator!");
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