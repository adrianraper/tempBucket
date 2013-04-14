package com.clarityenglish.tensebuster.view.title {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.model.ExerciseProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	 * A Mediator
	 */
	public class TitleMediator extends BentoMediator implements IMediator {
		
		public function TitleMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():TitleView {
			return viewComponent as TitleView;
		}
		
		public override function onRegister():void {
			super.onRegister();
			
			view.backToMenu.add(onBackToMenu);
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.backToMenu.remove(onBackToMenu);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				BBNotifications.SELECTED_NODE_CHANGED,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				case BBNotifications.SELECTED_NODE_CHANGED:
					view.selectedNode = note.getBody() as XML;
					break;
			}
		}
		
		/**
		 * Click to go back to menu from an exercise. 
		 * Check if the exercise is dirty or with undisplayed feedback
		 */
		private function onBackToMenu():void {
			// #210 - can you simply stop the exercise now, or do you need any warning first?
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			
			if (exerciseProxy.attemptToLeaveExercise(new Notification(BBNotifications.SELECTED_NODE_UP))) {
				sendNotification(BBNotifications.CLOSE_ALL_POPUPS, view); // #265
				sendNotification(BBNotifications.SELECTED_NODE_UP);
			}
		}
		
	}
}
