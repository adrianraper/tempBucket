package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class AuthoringSettingsMediator extends BentoMediator implements IMediator {
		
		public function AuthoringSettingsMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():AuthoringSettingsView {
			return viewComponent as AuthoringSettingsView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// Unlike most views the href is injected directly into the AuthoringSettingsView to make sure it is the same instance as in the AuthoringView (so changes
			// here affect the original XML)
		}
		
		override public function onRemove():void {
			super.onRemove();
			
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
