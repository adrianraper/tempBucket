package com.clarityenglish.tensebuster.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.googlecode.bindagetools.Bind;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ZoneMediator extends BentoMediator implements IMediator {
		
		public function ZoneMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ZoneView {
			return viewComponent as ZoneView;
		}
		
		public override function onRegister():void {
			super.onRegister();

			view.exerciseSelect.add(onExerciseSelect);
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			Bind.fromProperty(bentoProxy, "selectedUnitNode").toProperty(view, "unit");
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.exerciseSelect.remove(onExerciseSelect);
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
		
		protected function onExerciseSelect(node:XML, attribute:String = null):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, node, attribute);
		}
		
	}
}
