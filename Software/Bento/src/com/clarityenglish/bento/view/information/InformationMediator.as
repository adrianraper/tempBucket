package com.clarityenglish.bento.view.information {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.information.events.InformationEvent;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class InformationMediator extends BentoMediator implements IMediator {
		
		public function InformationMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():InformationView {
			return viewComponent as InformationView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			view.addEventListener(InformationEvent.OK, onOK);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.removeEventListener(InformationEvent.OK, onOK);
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
		
		/**
		 * The user sees the information and clicks OK.
		 */
		protected function onOK(event:Event):void {
			if (view.body is INotification)
				sendNotification(view.body.getName(), view.body.getBody(), view.body.getType());
		}
		
	}
}
