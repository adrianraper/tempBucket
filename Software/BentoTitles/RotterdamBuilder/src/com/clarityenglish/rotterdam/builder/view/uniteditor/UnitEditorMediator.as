package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class UnitEditorMediator extends BentoMediator implements IMediator {
		
		public function UnitEditorMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():UnitEditorView {
			return viewComponent as UnitEditorView;
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				//RotterdamNotifications.WIDGET_ADD,
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				/*case RotterdamNotifications.WIDGET_ADD:
					view.unitCollection.addItem(note.getBody());
					trace(view.data.toXMLString());
					break;*/
			}
		}
		
	}
}
