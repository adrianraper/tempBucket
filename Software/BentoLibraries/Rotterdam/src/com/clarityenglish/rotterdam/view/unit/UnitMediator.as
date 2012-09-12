package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class UnitMediator extends BentoMediator implements IMediator {
		
		public function UnitMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():UnitView {
			return viewComponent as UnitView;
		}
		
		override public function onRegister():void {
			super.onRegister();
		}
		
		override public function onRemove():void {
			super.onRemove();
		}
		
		protected override function onXHTMLReady(xhtml:XHTML):void {
			super.onXHTMLReady(xhtml);
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
